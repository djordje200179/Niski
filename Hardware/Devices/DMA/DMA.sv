module dma#(START_ADDR = 32'h0) (
	input clk, rst,

	output logic bus_req,
	input bus_grant,

	inout [31:0] addr_bus, data_bus,
	inout rd_bus, wr_bus,
	inout [3:0] data_mask_bus,
	inout fc_bus,

	input watchdog
);
	reg [4:0] ctrl_reg;
	reg [31:0] src_reg, dest_reg, cnt_reg;

	wire burst;
	wire move_src, incr_src;
	wire move_dest, incr_dest;

	assign {burst, move_src, incr_src, move_dest, incr_dest} = ctrl_reg[4:0];

	wire addr_hit;
	wire [1:0] reg_index;
	wire [1:0] word_offset;
	addr_splitter#(START_ADDR, 4) addr_splitter (
		.addr_bus(addr_bus),

		.addr_hit(addr_hit),
		.reg_index(reg_index),
		.word_offset(word_offset)
	);

	wire [31:0] incoming_data;
	wire [31:0] existing_data_mask;
	data_shifter data_shifter (
		.data_bus(data_bus),
		.word_offset(word_offset),
		.data_mask_bus(data_mask_bus),

		.existing_data_mask(existing_data_mask),
		.incoming_data(incoming_data)
	);

	wire [31:0] next_ctrl_reg = ctrl_reg & existing_data_mask | incoming_data;
	wire [31:0] next_src_reg = src_reg & existing_data_mask | incoming_data;
	wire [31:0] next_dest_reg = dest_reg & existing_data_mask | incoming_data;
	wire [31:0] next_cnt_reg = cnt_reg & existing_data_mask | incoming_data;

	wire read_req = addr_hit && rd_bus,
		 write_req = addr_hit && wr_bus;

	reg process_started;
	enum {STATE_IDLE, STATE_WAIT_ACK, STATE_WAIT_BUS, STATE_TRANSFER_READING, STATE_TRANSFER_WRITING} state;

	logic [31:0] addr_out, data_out;

	assign addr_bus = bus_grant ? addr_out : 'z,
		   data_bus = (read_req || state == STATE_TRANSFER_WRITING) ? data_out : 'z,
		   rd_bus = bus_grant ? state == STATE_TRANSFER_READING : 'z,
		   wr_bus = bus_grant ? state == STATE_TRANSFER_WRITING : 'z,
		   data_mask_bus = bus_grant ? 4'b0001 : 'z,
		   fc_bus = addr_hit ? (read_req || state == STATE_WAIT_ACK) : 'z;

	always_comb begin
		unique case (state)
		STATE_TRANSFER_READING: addr_out = src_reg;
		STATE_TRANSFER_WRITING: addr_out = dest_reg;
		default: addr_out = 0;
		endcase
	end

	reg [7:0] curr_data;

	always_comb begin
		data_out = 0;

		case (state)
		STATE_IDLE: begin
			unique case (reg_index)
			0: data_out = ctrl_reg;
			1: data_out = src_reg;
			2: data_out = dest_reg;
			3: data_out = cnt_reg;
			endcase

			data_out = data_out >> (8 * word_offset);
		end
		STATE_TRANSFER_WRITING: data_out[7:0] = curr_data;
		endcase
	end

	task automatic reset;
		begin
			state <= STATE_IDLE;
			process_started <= 0;

			bus_req <= 0;
			ctrl_reg <= '0;
		end
	endtask

	task automatic on_clock;
		begin
			unique case (state)
			STATE_IDLE: begin
				if (write_req) begin
					case (reg_index)
					0: ctrl_reg <= next_ctrl_reg;
					1: src_reg <= next_src_reg;
					2: dest_reg <= next_dest_reg;
					3: cnt_reg <= next_cnt_reg;
					endcase

					if (reg_index == 0)
						process_started <= 1;
					
					state <= STATE_WAIT_ACK;
				end
			end
			STATE_WAIT_ACK: begin
				if (!addr_hit) begin
					if (process_started) begin
						if (cnt_reg != 0) begin
							state <= STATE_WAIT_BUS;
							bus_req <= 1;
						end else
							state <= STATE_IDLE;
					
						process_started <= 0;
					end else
						state <= STATE_IDLE;
				end
			end
			STATE_WAIT_BUS: begin
				if (bus_grant)
					state <= STATE_TRANSFER_READING;
			end
			STATE_TRANSFER_READING: begin
				if (watchdog) begin
					bus_req <= 0;
					state <= STATE_IDLE;
				end else if (fc_bus) begin
					curr_data <= data_bus[7:0];
					state <= STATE_TRANSFER_WRITING;

					if (move_src)
						src_reg <= src_reg + (incr_src ? 1 : -1);
				end
			end
			STATE_TRANSFER_WRITING: begin
				if (watchdog) begin
					bus_req <= 0;
					state <= STATE_IDLE;
				end else if (fc_bus) begin
					if (move_dest)
						dest_reg <= dest_reg + (incr_dest ? 1 : -1);

					if (cnt_reg != 0) begin
						cnt_reg <= cnt_reg - 1;
						state <= STATE_TRANSFER_READING;
					end else begin
						bus_req <= 0;
						state <= STATE_IDLE;
					end
				end
			end
			endcase
		end
	endtask

	always @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end
endmodule
module dma (
	input clk, rst,

	output reg bus_req,
	input bus_grant,

	inout [31:0] addr_bus, data_bus,
	inout rd_bus, wr_bus,
	inout [3:0] data_mask_bus,
	inout fc_bus,

	input watchdog
);
	parameter CTRL_REG_ADDR	= 32'h0,
			  SRC_REG_ADDR	= 32'h4,
			  DEST_REG_ADDR	= 32'h8,
			  CNT_REG_ADDR	= 32'hC;

	reg [7:0] ctrl_reg;
	reg [31:0] src_reg, dest_reg, cnt_reg;

	wire move_src, move_dest, incr_src, incr_dest;
	assign {move_src, move_dest, incr_src, incr_dest} = ctrl_reg[3:0];

	`include "../BusInterfaceHelper.vh"

	//wire occupy_bus = ctrl_reg[4];

	reg addr_hit;
	always @* begin
		addr_hit = 1'b0;

		case (addr_base)
		CTRL_REG_ADDR,
		SRC_REG_ADDR,
		DEST_REG_ADDR,
		CNT_REG_ADDR:
			addr_hit = 1'b1;
		endcase
	end

	wire req_valid = rd_bus ^ wr_bus;
	wire req = addr_hit && req_valid,
		 read_req = req && rd_bus,
		 write_req = req && wr_bus;
	
	reg process_started;

	reg [2:0] state;
	localparam STATE_IDLE 		 		= 3'd0,
			   STATE_WAIT_ACK       	= 3'd1,
			   STATE_WAIT_BUS			= 3'd2,
			   STATE_TRANSFER_READING	= 3'd3,
			   STATE_TRANSFER_WRITING	= 3'd4;

	reg [31:0] addr_out, data_out;

	assign addr_bus = bus_grant ? addr_out : 32'bz,
		   data_bus = (read_req || state == STATE_TRANSFER_WRITING) ? data_out : 32'bz,
		   rd_bus = bus_grant ? state == STATE_TRANSFER_READING : 1'bz,
		   wr_bus = bus_grant ? state == STATE_TRANSFER_WRITING : 1'bz,
		   data_mask_bus = bus_grant ? 4'b0001 : 4'bz,
		   fc_bus = req ? (read_req || state == STATE_WAIT_ACK) : 1'bz;

	reg [7:0] curr_data;

	always @* begin
		addr_out = 32'b0;

		case (state)
		STATE_TRANSFER_READING: addr_out = src_reg;
		STATE_TRANSFER_WRITING: addr_out = dest_reg;
		endcase
	end

	always @* begin
		data_out = 32'b0;

		case (state)
		STATE_IDLE: begin
			case (addr_base)
			CTRL_REG_ADDR:	data_out = ctrl_reg;
			SRC_REG_ADDR:	data_out = src_reg;
			DEST_REG_ADDR:	data_out = dest_reg;
			CNT_REG_ADDR:	data_out = cnt_reg;
			endcase

			data_out = data_out >> (8 * addr_offset);
		end
		STATE_TRANSFER_WRITING: data_out[7:0] = curr_data;
		endcase
	end

	task reset;
		begin
			state <= STATE_IDLE;
			bus_req <= 1'b0;
			ctrl_reg <= 8'b0;
			process_started <= 1'b0;
		end
	endtask

	task on_clock;
		begin
			case (state)
			STATE_IDLE: begin
				if (write_req) begin
					case (addr_base)
					CTRL_REG_ADDR:	update_reg(ctrl_reg);
					SRC_REG_ADDR:	update_reg(src_reg);
					DEST_REG_ADDR:	update_reg(dest_reg);
					CNT_REG_ADDR:	update_reg(cnt_reg);
					endcase

					if (addr_base == CTRL_REG_ADDR)
						process_started <= 1'b1;
					
					state <= STATE_WAIT_ACK;
				end
			end
			STATE_WAIT_ACK: begin
				if (!req) begin
					if (process_started) begin
						if (cnt_reg > 32'd0) begin
							state <= STATE_WAIT_BUS;
							bus_req <= 1'b1;
						end else
							state <= STATE_IDLE;
					
						process_started <= 1'b0;
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
					bus_req <= 1'b0;
					state <= STATE_IDLE;
				end else if (fc_bus) begin
					curr_data <= data_bus[7:0];
					state <= STATE_TRANSFER_WRITING;

					if (move_src) begin
						if (incr_src) 
							src_reg <= src_reg + 32'd1;
						else 
							src_reg <= src_reg - 32'd1;
					end
				end
			end
			STATE_TRANSFER_WRITING: begin
				if (watchdog) begin
					bus_req <= 1'b0;
					state <= STATE_IDLE;
				end else if (fc_bus) begin
					if (move_dest) begin
						if (incr_dest) 
							dest_reg <= dest_reg + 32'd1;
						else 
							dest_reg <= dest_reg - 32'd1;
					end

					if (cnt_reg > 32'd0) begin
						cnt_reg <= cnt_reg - 32'd1;
						state <= STATE_TRANSFER_READING;
					end else begin
						bus_req <= 1'b0;
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
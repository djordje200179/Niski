module plic#(START_ADDR = 32'h0, INTR_NUM = 16) (
	input clk, rst,

	input [INTR_NUM-1:1] irqs,
	output has_req,

	input [31:0] addr_bus, 
	inout [31:0] data_bus, 
	input rd_bus, wr_bus,
	input [3:0] data_mask_bus, 
	output fc_bus
); 
	reg [INTR_NUM-1:0] pending_intr_reg, enable_intr_reg;

	wire addr_hit;
	wire [1:0] reg_index;
	wire [1:0] word_offset;
	addr_splitter#(START_ADDR, 3) addr_splitter (
		.addr_bus(addr_bus),

		.addr_hit(addr_hit),
		.reg_index(reg_index),
		.word_offset(word_offset)
	);

	wire read_req = addr_hit && rd_bus,
		 write_req = addr_hit && wr_bus;

	wire [31:0] incoming_data;
	wire [31:0] existing_data_mask;
	data_shifter data_shifter (
		.data_bus(data_bus),
		.word_offset(word_offset),
		.data_mask_bus(data_mask_bus),

		.existing_data_mask(existing_data_mask),
		.incoming_data(incoming_data)
	);
	
	wire [INTR_NUM-1:0] next_pending_intr_reg = pending_intr_reg & existing_data_mask | incoming_data;
	wire [INTR_NUM-1:0] next_enable_intr_reg = enable_intr_reg & existing_data_mask | incoming_data;

	logic [3:0] next_intr;
	always_comb begin
		next_intr = 0;
		for (int i = 1; i < INTR_NUM; i++) begin
			if (pending_intr_reg[i] && enable_intr_reg[i])
				next_intr = i;
		end
	end

	logic [31:0] data_out;
	always_comb begin
		unique case (reg_index)
		0: data_out = pending_intr_reg;
		1: data_out = enable_intr_reg;
		2: data_out = next_intr;
		default: data_out = 0;
		endcase

		data_out = data_out >> (8 * word_offset);
	end

	enum {STATE_IDLE, STATE_READ, STATE_WRITE_DONE} state;

	reg [1:0] readen_reg_index;
	assign data_bus = read_req ? data_out : 'z,
		   fc_bus = addr_hit ? (read_req || state == STATE_WRITE_DONE) : 'z;

	task automatic register_interrupts;
		begin
			for (int i = 1; i < INTR_NUM; i++) begin
				if (irqs[i])
					pending_intr_reg[i] <= 1;
			end
		end
	endtask

	assign has_req = |next_intr;

	task automatic reset;
		begin
			state <= STATE_IDLE;

			pending_intr_reg <= '0;
			enable_intr_reg <= '0;
		end
	endtask

	task automatic on_clock;
		begin
			register_interrupts;

			unique case (state)
			STATE_IDLE: begin
				if (write_req) begin
					state <= STATE_WRITE_DONE;

					unique case (reg_index)
					0: pending_intr_reg <= next_pending_intr_reg;
					1: enable_intr_reg <= next_enable_intr_reg;
					endcase
				end else if (read_req) begin
					state <= STATE_READ;
					readen_reg_index <= reg_index;
				end
			end
			STATE_WRITE_DONE: begin
				if (!write_req)
					state <= STATE_IDLE;
			end
			STATE_READ: begin
				if (!read_req) begin
					state <= STATE_IDLE;

					if (readen_reg_index == 2)
						pending_intr_reg[next_intr] <= 0;
				end
			end
			endcase
		end
	endtask

	always_ff @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end
endmodule
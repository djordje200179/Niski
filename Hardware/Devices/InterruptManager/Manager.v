module interrupt_manager#(parameter START_ADDR = 32'h0) (
	input clk, rst,

	input [15:1] intr_reqs,
	output has_req,

	input [31:0] addr_bus, 
	inout [31:0] data_bus, 
	input rd_bus, wr_bus,
	input [3:0] data_mask_bus, 
	output fc_bus
); 
	reg [15:0] pending_intr_reg;
	reg [15:0] enable_intr_reg;

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
	
	wire [15:0] next_pending_intr_reg = pending_intr_reg & existing_data_mask | incoming_data;
	wire [15:0] next_enable_intr_reg = enable_intr_reg & existing_data_mask | incoming_data;

	reg [3:0] next_intr;
	always @* begin
		next_intr = 4'd0;
		casez (pending_intr_reg & enable_intr_reg)
		16'b1zzzzzzzzzzzzzzz: next_intr = 4'd15;
		16'b01zzzzzzzzzzzzzz: next_intr = 4'd14;
		16'b001zzzzzzzzzzzzz: next_intr = 4'd13;
		16'b0001zzzzzzzzzzzz: next_intr = 4'd12;
		16'b00001zzzzzzzzzzz: next_intr = 4'd11;
		16'b000001zzzzzzzzzz: next_intr = 4'd10;
		16'b0000001zzzzzzzzz: next_intr = 4'd9;
		16'b00000001zzzzzzzz: next_intr = 4'd8;
		16'b000000001zzzzzzz: next_intr = 4'd7;
		16'b0000000001zzzzzz: next_intr = 4'd6;
		16'b00000000001zzzzz: next_intr = 4'd5;
		16'b000000000001zzzz: next_intr = 4'd4;
		16'b0000000000001zzz: next_intr = 4'd3;
		16'b00000000000001zz: next_intr = 4'd2;
		16'b000000000000001z: next_intr = 4'd1;
		endcase
	end

	reg [31:0] data_out;
	always @* begin
		data_out = 32'h0;
		
		case (reg_index)
		2'd0: data_out = pending_intr_reg;
		2'd1: data_out = enable_intr_reg;
		2'd2: data_out = next_intr;
		endcase

		data_out = data_out >> (8 * word_offset);
	end

	reg data_written, data_read;
	reg [1:0] readen_reg_index;
	assign data_bus = read_req ? data_out : 32'bz,
		   fc_bus = addr_hit ? (read_req || data_written) : 1'bz;

	task register_interrupts;
		integer i;
		begin
			for (i = 1; i < 16; i = i + 1) begin
				if (intr_reqs[i])
					pending_intr_reg[i] <= 1'b1;
			end
		end
	endtask

	assign has_req = |next_intr;

	task reset;
		begin
			data_written <= 1'b0;
			data_read <= 1'b0;

			pending_intr_reg <= 16'b0;
			enable_intr_reg <= 16'b0;
		end
	endtask

	task on_clock;
		begin
			register_interrupts;

			if (data_written && !write_req)
				data_written <= 1'b0;
			else if (write_req) begin
				data_written <= 1'b1;

				case (reg_index)
				2'd0: pending_intr_reg <= next_pending_intr_reg;
				2'd1: enable_intr_reg <= next_enable_intr_reg;
				endcase
			end else if (data_read && !read_req) begin
				data_read <= 1'b0;
				
				case (readen_reg_index)
				2'd2: pending_intr_reg[next_intr] <= 1'b0;
				endcase
			end else if (read_req) begin
				data_read <= 1'b1;
				readen_reg_index <= reg_index;
			end
		end
	endtask

	always @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end
endmodule
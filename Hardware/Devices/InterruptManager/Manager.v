module interrupt_manager#(parameter START_ADDR = 32'h0) (
	input clk, rst,

	input [15:0] intr_reqs,
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
	
	wire [31:0] next_pending_intr_reg = pending_intr_reg & existing_data_mask | incoming_data;
	wire [31:0] next_enable_intr_reg = enable_intr_reg & existing_data_mask | incoming_data;

	task get_claimable_intr (output [3:0] intr_code);
		integer i;
		
		begin
			intr_code = 4'b0;
			
			for (i = 0; i < 16; i = i + 1) begin
				if (pending_intr_reg[i] && enable_intr_reg[i])
					intr_code = i;
			end
		end
	endtask

	reg [31:0] data_out;
	always @* begin
		data_out = 32'h0;
		
		case (reg_index)
		2'd0: data_out = pending_intr_reg;
		2'd1: data_out = enable_intr_reg;
		2'd2: begin 
			if (|intr_reqs)
				get_claimable_intr(data_out);
			else
				data_out = 32'hffffffff;
		end
		endcase

		data_out = data_out >> (8 * word_offset);
	end

	reg data_written;
	assign data_bus = read_req ? data_out : 32'bz,
		   fc_bus = addr_hit ? (read_req || data_written) : 1'bz;

	task register_interrupts;
		integer i;
		begin
			for (i = 0; i < 16; i = i + 1) begin
				if (intr_reqs[i] && enable_intr_reg[i])
					pending_intr_reg[i] <= 1'b1;
			end
		end
	endtask

	assign has_req = |pending_intr_reg;

	task reset;
		begin
			data_written <= 1'b0;

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
				2'd2: begin
					if (data_out != 32'hffffffff)
						pending_intr_reg[data_out[3:0]] <= 1'b0;
				end
				endcase
			end
		end
	endtask

	always @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end
endmodule
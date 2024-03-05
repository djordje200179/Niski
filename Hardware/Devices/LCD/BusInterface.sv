module lcd_bus_interface#(START_ADDR = 32'h0) (
	input clk, rst,
	
	output [7:0] ctrl_data,
	output logic ctrl_data_is_cmd, ctrl_data_req,
	input ctrl_data_ack,
	
	input [31:0] addr_bus, 
	inout [31:0] data_bus, 
	input rd_bus, wr_bus,
	input [3:0] data_mask_bus, 
	output fc_bus
);
	wire addr_hit;
	wire [0:0] reg_index;
	wire [1:0] word_offset;
	addr_splitter#(START_ADDR, 2) addr_splitter (
		.addr_bus(addr_bus),

		.addr_hit(addr_hit),
		.reg_index(reg_index),
		.word_offset(word_offset)
	);

	wire read_req = addr_hit && rd_bus,
		 write_req = addr_hit && wr_bus;

	assign data_bus = read_req ? '0 : 'z,
		   fc_bus = addr_hit ? ctrl_data_ack : 'z;

	task automatic reset;
		begin
			ctrl_data_req <= 0;
		end
	endtask

	assign ctrl_data = data_bus[7:0];

	always_comb begin
		unique case (reg_index)
		0: ctrl_data_is_cmd <= 0;
		1: ctrl_data_is_cmd <= 1;
		endcase
	end

	task automatic on_clock;
		begin
			if (ctrl_data_ack && !write_req)
				ctrl_data_req <= 0;
			else if (!ctrl_data_ack && write_req) begin
				if (word_offset == 0 && data_mask_bus[0])
					ctrl_data_req <= 1;
			end
		end
	endtask

	always_ff @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end
endmodule
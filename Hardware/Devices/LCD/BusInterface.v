module lcd_bus_interface#(parameter START_ADDR = 32'h0) (
	input clk, rst,
	
	output [7:0] ctrl_data,
	output reg ctrl_data_is_cmd, ctrl_data_req,
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

	assign data_bus = read_req ? 32'b0 : 32'bz,
		   fc_bus = addr_hit ? ctrl_data_ack : 1'bz;

	task reset;
		begin
			ctrl_data_req <= 1'b0;
		end
	endtask

	assign ctrl_data = data_bus[7:0];

	always @* begin
		case (reg_index)
		1'd0: ctrl_data_is_cmd <= 1'b0;
		1'd1: ctrl_data_is_cmd <= 1'b1;
		endcase
	end

	task on_clock;
		begin
			if (ctrl_data_ack && !write_req)
				ctrl_data_req <= 1'b0;
			else if (!ctrl_data_ack && write_req) begin
				if (word_offset == 2'd0 && data_mask_bus[0])
					ctrl_data_req <= 1'b1;
			end
		end
	endtask

	always @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end
endmodule
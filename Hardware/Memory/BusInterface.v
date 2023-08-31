module memory_bus_interface (
	clk, rst,
	mem_addr, mem_data_out, mem_data_in, mem_wr, mem_wr_mask,
	addr_bus, data_bus, wr_bus, rd_bus, data_mask_bus, fc_bus
);
	parameter MEM_ADDR_WIDTH = 16;
	localparam MEM_SIZE = 2 ** MEM_ADDR_WIDTH * 4;

	parameter START_ADDR = 0;

	input clk, rst;

	output [MEM_ADDR_WIDTH-1:0] mem_addr;
	input [31:0] mem_data_out;
	output [31:0] mem_data_in;
	output mem_wr;
	output [3:0] mem_wr_mask;

	input [31:0] addr_bus;
	inout [31:0] data_bus;
	input wr_bus, rd_bus;
	input [3:0] data_mask_bus;
	output fc_bus;

	wire addr_hit = (addr_bus >= START_ADDR) && (addr_bus < START_ADDR + MEM_SIZE);
	wire req_valid = rd_bus ^ wr_bus;
		 
	wire req = addr_hit && req_valid,
	 	 read_req = req && rd_bus,
	 	 write_req = req && wr_bus;

	reg transfer_completed;

	assign data_bus = read_req ? mem_data_out >> (addr_bus[1:0] * 8) : 32'bz,
		   fc_bus = req ? transfer_completed : 1'bz;

	assign mem_addr = (addr_bus - START_ADDR) >> 2,
		   mem_data_in = data_bus << (addr_bus[1:0] * 8),
		   mem_wr = write_req,
		   mem_wr_mask = data_mask_bus << addr_bus[1:0];

	task reset;
		begin
			transfer_completed <= 1'b0;
		end
	endtask

	task on_clock;
		begin
			if (transfer_completed && !req)
				transfer_completed <= 1'b0;
			else if (req)
				transfer_completed <= 1'b1;
		end
	endtask

	always @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end
endmodule
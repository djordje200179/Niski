module memory_bus_interface (
	clk, rst,
	mem_addr, mem_data_out, mem_data_in, mem_wr, mem_en,
	addr_bus, data_bus, wr_bus, rd_bus, fc_bus
);
	parameter ADDR_BUS_WIDTH = 32,
			  DATA_BUS_WIDTH = 8;

	parameter START_ADDR = 0,
			  MEM_SIZE = 256;

	parameter ADDR_MEM_WIDTH = $clog2(MEM_SIZE);

	input clk, rst;

	output [ADDR_MEM_WIDTH-1:0] mem_addr;
	input [DATA_BUS_WIDTH-1:0] mem_data_out;
	output [DATA_BUS_WIDTH-1:0] mem_data_in;
	output mem_wr, mem_en;

	input [ADDR_BUS_WIDTH-1:0] addr_bus;
	inout [DATA_BUS_WIDTH-1:0] data_bus;
	input wr_bus, rd_bus;
	output fc_bus;

	wire addr_hit = (addr_bus >= START_ADDR) && (addr_bus < START_ADDR + MEM_SIZE);
	wire req_valid = rd_bus ^ wr_bus;
		 
	wire req = addr_hit && req_valid,
		 read_req = req && rd_bus,
		 write_req = req && wr_bus;

	assign mem_addr = addr_bus - START_ADDR,
		   mem_data_in = data_bus,
		   mem_wr = write_req,
		   mem_en = 1'b1;

	reg data_written;

	assign data_bus = read_req ? mem_data_out : {DATA_BUS_WIDTH{1'bz}},
		   fc_bus = req ? (read_req || data_written) : 1'bz;

	task reset;
		begin
			data_written <= 1'b0;
		end
	endtask

	task on_clock;
		begin
			if (write_req)
				data_written <= 1'b1;

			if (data_written && !write_req)
				data_written <= 1'b0;
		end
	endtask

	always @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end
endmodule
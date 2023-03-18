module cpu_reg_file (
    clk, en,
    wr,
	addr_read_1, addr_read_2, addr_write, 
	data_read_1, data_read_2, data_write
);
    parameter BITS = 8;
	parameter SIZE = 16;
	
	localparam ADDRESS_BITS = $clog2(SIZE);
	
	input clk, en;
	input wr;
	
	input [ADDRESS_BITS-1:0] addr_read_1, addr_read_2, addr_write;
	output [BITS-1:0] data_read_1, data_read_2;
	input [BITS-1:0] data_write;
	
	reg [BITS-1:0] registers [SIZE];
	
	assign data_read_1 = en ? registers[addr_read_1] : {BITS{1'bz}};
	assign data_read_2 = en ? registers[addr_read_2] : {BITS{1'bz}};
	
	always @(posedge clk) begin
		if (en && wr)
			registers[addr_write] <= data_write;
	end
endmodule
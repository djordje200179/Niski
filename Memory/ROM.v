module rom (
	en,
	addr, data_out
);
	parameter DATA_BITS = 8;
	parameter SIZE = 2 ** 8;
	parameter MEM_FILE = "";
	
	parameter ADDR_BITS = $clog2(SIZE);
	
	input en;
	
	input [ADDR_BITS-1:0] addr;
	output [DATA_BITS-1:0] data_out;
	
	reg [DATA_BITS-1:0] memory [SIZE];
	initial $readmemh(MEM_FILE, memory);
	
	assign data_out = en ? memory[addr] : {DATA_BITS{1'bz}};
endmodule
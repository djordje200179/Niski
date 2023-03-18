module ram (
	clk, en,
	wr,
	addr, data_in, data_out
);
	parameter DATA_BITS = 8;
	parameter SIZE = 2 ** 8;
	
	parameter ADDR_BITS = $clog2(SIZE);
	
	input clk, en;
	
	input wr;
	
	input [ADDR_BITS-1:0] addr;
	input [DATA_BITS-1:0] data_in;
	output [DATA_BITS-1:0] data_out;
	
	reg [DATA_BITS-1:0] memory [SIZE];
	
	assign data_out = en ? memory[addr] : {DATA_BITS{1'bz}};
	
	task on_clock;
		begin
			
		end
	endtask
	
	always @(posedge clk) begin
		if (en && wr)
			memory[addr] <= data_in;
	end
endmodule
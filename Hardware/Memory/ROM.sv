module rom #(ADDR_BITS = 10, MEM_FILE = "") (
	input clk,

	input [ADDR_BITS-1:0] addr, 
	output reg [31:0] data_out
);
	reg [31:0] memory [2**ADDR_BITS-1:0];
	initial $readmemh(MEM_FILE, memory);
	
	always_ff @(posedge clk) begin
		data_out <= memory[addr];		
	end
endmodule
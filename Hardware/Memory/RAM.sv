module ram#(ADDR_BITS = 10, MEM_FILE = "") (
	input clk,

	input wr, 
	input [3:0] wr_mask,

	input [ADDR_BITS-1:0] addr, 
	input [31:0] data_in,
	output reg [31:0] data_out
);
	reg [3:0][7:0] memory [2**ADDR_BITS];
	initial begin
		if (MEM_FILE != "")
			$readmemh(MEM_FILE, memory);
	end
	
	always_ff @(posedge clk) begin
		if (wr) begin
			// Can't use a for loop here for unknown reason
			if(wr_mask[0]) memory[addr][0] <= data_in[0+:8];
			if(wr_mask[1]) memory[addr][1] <= data_in[8+:8];
			if(wr_mask[2]) memory[addr][2] <= data_in[16+:8];
			if(wr_mask[3]) memory[addr][3] <= data_in[24+:8];
		end

		data_out <= memory[addr];
	end
endmodule
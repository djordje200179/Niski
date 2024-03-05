module cpu_reg_file#(MORE_REGISTERS = 1) (
	input clk,

	input [4:0] addr_rd1, addr_rd2, addr_wr,
	output [31:0] data_rd1, data_rd2,
	input [31:0] data_wr, 
	input wr
);
	reg [31:0] regs [1:(MORE_REGISTERS ? 31 : 15)];

	assign data_rd1 = |addr_rd1 ? regs[addr_rd1] : '0;
	assign data_rd2 = |addr_rd2 ? regs[addr_rd2] : '0;

	always_ff @(posedge clk) begin
		if (wr)
			regs[addr_wr] <= data_wr;
	end	
endmodule
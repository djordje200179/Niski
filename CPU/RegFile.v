module cpu_reg_file#(
	parameter MORE_REGISTERS = 1'b1
) (
	input clk,

	input [4:0] addr_rd1, addr_rd2, addr_wr,
	output [31:0] data_rd1, data_rd2,
	input [31:0] data_wr, 
	input wr
);
	generate
		if (MORE_REGISTERS) begin: registers
			reg [31:0] regs [1:31];
		end else begin : registers
			reg [31:0] regs [1:15];
		end
	endgenerate

	assign data_rd1 = addr_rd1 ? registers.regs[addr_rd1] : 32'b0;
	assign data_rd2 = addr_rd2 ? registers.regs[addr_rd2] : 32'b0;

	always @(posedge clk) begin
		if (wr && addr_wr)
			registers.regs[addr_wr] <= data_wr;
	end	
endmodule
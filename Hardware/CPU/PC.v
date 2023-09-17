module cpu_pc_reg (
	input clk, rst,

	input [31:0] next_pc, 
	input wr,
	output reg [31:0] pc
);
	parameter EXEC_START_ADDR = 32'h40000000;
	
	task reset;
		begin
			pc <= EXEC_START_ADDR;
		end
	endtask

	task on_clock;
		begin
			if (wr)
				pc <= next_pc;
		end
	endtask

	always @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end
endmodule
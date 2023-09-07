module cpu_alu (
	input [9:0] funct,
	output reg invalid_opcode,

	input [31:0] operand_a, operand_b,
	output reg [31:0] result
);
	`include "Instructions.vh"

	wire [63:0] uu_multiplication_result = operand_a * operand_b,
				ss_multiplication_result = $signed(operand_a) * $signed(operand_b),
				su_multiplication_result = $signed(operand_a) * operand_b;

	always @* begin
		result = 32'b0;

		case (funct)
		INST_ARLOG_FUNCT_ADD:		result = operand_a + operand_b;
		INST_ARLOG_FUNCT_SUB:		result = operand_a - operand_b;
		INST_ARLOG_FUNCT_SLL: 		result = operand_a << operand_b[4:0];
		INST_ARLOG_FUNCT_SLT: 		result = $signed(operand_a) < $signed(operand_b);
		INST_ARLOG_FUNCT_SLTU:		result = operand_a < operand_b;
		INST_ARLOG_FUNCT_XOR: 		result = operand_a ^ operand_b;
		INST_ARLOG_FUNCT_SRL:	 	result = operand_a >> operand_b[4:0];
		INST_ARLOG_FUNCT_SRA: 		result = $signed(operand_a) >>> operand_b[4:0];
		INST_ARLOG_FUNCT_OR: 		result = operand_a | operand_b;
		INST_ARLOG_FUNCT_AND: 		result = operand_a & operand_b;
		INST_ARLOG_FUNCT_MUL: 		result = ss_multiplication_result[31:0];
		INST_ARLOG_FUNCT_MULH: 		result = ss_multiplication_result[63:32];
		INST_ARLOG_FUNCT_MULHSU:	result = su_multiplication_result[63:32];
		INST_ARLOG_FUNCT_MULHU: 	result = uu_multiplication_result[63:32];
		// INST_ARLOG_FUNCT_DIV: 	result = $signed(operand_a) / $signed(operand_b);
		// INST_ARLOG_FUNCT_DIVU: 	result = operand_a / operand_b;
		// INST_ARLOG_FUNCT_REM: 	result = $signed(operand_a) % $signed(operand_b);
		// INST_ARLOG_FUNCT_REMU: 	result = operand_a % operand_b;
		endcase
	end
	
	always @* begin
		invalid_opcode = 1'b1;

		case (funct)
		INST_ARLOG_FUNCT_ADD,
		INST_ARLOG_FUNCT_SUB,
		INST_ARLOG_FUNCT_SLL,
		INST_ARLOG_FUNCT_SLT,
		INST_ARLOG_FUNCT_SLTU,
		INST_ARLOG_FUNCT_XOR,
		INST_ARLOG_FUNCT_SRL,
		INST_ARLOG_FUNCT_SRA,
		INST_ARLOG_FUNCT_OR,
		INST_ARLOG_FUNCT_AND,
		INST_ARLOG_FUNCT_MUL,
		INST_ARLOG_FUNCT_MULH,
		INST_ARLOG_FUNCT_MULHSU,
		INST_ARLOG_FUNCT_MULHU,
		INST_ARLOG_FUNCT_DIV,
		INST_ARLOG_FUNCT_DIVU,
		INST_ARLOG_FUNCT_REM,
		INST_ARLOG_FUNCT_REMU:
			invalid_opcode = 1'b0;
		endcase
	end
endmodule
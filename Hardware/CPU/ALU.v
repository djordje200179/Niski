module cpu_alu (
	input [9:0] mod,
	output reg invalid_opcode,

	input [31:0] operand_a, operand_b,
	output reg [31:0] result
);
	`include "Instructions.vh"

	always @* begin
		result = 32'b0;

		case (mod)
		INST_ARLOG_ADD:		result = operand_a + operand_b;
		INST_ARLOG_SUB:		result = operand_a - operand_b;
		INST_ARLOG_SLL: 	result = operand_a << operand_b;
		INST_ARLOG_SLT: 	result = $signed(operand_a) < $signed(operand_b);
		INST_ARLOG_SLTU:	result = operand_a < operand_b;
		INST_ARLOG_XOR: 	result = operand_a ^ operand_b;
		INST_ARLOG_SRL: 	result = operand_a >> operand_b;
		INST_ARLOG_SRA: 	result = $signed(operand_a) >>> operand_b;
		INST_ARLOG_OR: 		result = operand_a | operand_b;
		INST_ARLOG_AND: 	result = operand_a & operand_b;
		// INST_ARLOG_MUL: 	result = $signed(operand_a) * $signed(operand_b);
		// INST_ARLOG_MULH: 	result = ($signed(operand_a) * $signed(operand_b)) >> 32;
		// INST_ARLOG_MULHSU: 	result = ($signed(operand_a) * operand_b) >> 32;
		// INST_ARLOG_MULHU: 	result = (operand_a * operand_b) >> 32;
		// INST_ARLOG_DIV: 	result = $signed(operand_a) / $signed(operand_b);
		// INST_ARLOG_DIVU: 	result = operand_a / operand_b;
		// INST_ARLOG_REM: 	result = $signed(operand_a) % $signed(operand_b);
		// INST_ARLOG_REMU: 	result = operand_a % operand_b;
		endcase
	end
	
	always @* begin
		invalid_opcode = 1'b1;

		case (mod)
		INST_ARLOG_ADD,
		INST_ARLOG_SUB,
		INST_ARLOG_SLL,
		INST_ARLOG_SLT,
		INST_ARLOG_SLTU,
		INST_ARLOG_XOR,
		INST_ARLOG_SRL,
		INST_ARLOG_SRA,
		INST_ARLOG_OR,
		INST_ARLOG_AND,
		INST_ARLOG_MUL,
		INST_ARLOG_MULH,
		INST_ARLOG_MULHSU,
		INST_ARLOG_MULHU,
		INST_ARLOG_DIV,
		INST_ARLOG_DIVU,
		INST_ARLOG_REM,
		INST_ARLOG_REMU:
			invalid_opcode = 1'b0;
		endcase
	end
endmodule
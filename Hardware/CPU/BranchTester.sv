module cpu_branch_tester (
	input [2:0] funct3,

	input [31:0] operand_a, operand_b,
	output logic condition_satisfied
);
	`include "instructions.vh"

	always_comb begin
		unique case (funct3)
		INST_BRANCH_FUNCT3_EQ:	condition_satisfied = operand_a == operand_b;
		INST_BRANCH_FUNCT3_NEQ:	condition_satisfied = operand_a != operand_b;
		INST_BRANCH_FUNCT3_LT:  condition_satisfied = $signed(operand_a) < $signed(operand_b);
		INST_BRANCH_FUNCT3_GE:	condition_satisfied = $signed(operand_a) >= $signed(operand_b);
		INST_BRANCH_FUNCT3_LTU: condition_satisfied = operand_a < operand_b;
		INST_BRANCH_FUNCT3_GEU: condition_satisfied = operand_a >= operand_b;
		default: condition_satisfied = 0;
		endcase
	end
endmodule
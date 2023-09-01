module cpu_branch_tester (
	input [2:0] mod,

	input [31:0] operand_a, operand_b,
	output reg condition_satisfied
);
	`include "instructions.vh"

	always @* begin
		condition_satisfied = 1'b0;

		case (mod)
		INST_BRANCH_EQ:	 condition_satisfied = operand_a == operand_b;
		INST_BRANCH_NEQ: condition_satisfied = operand_a != operand_b;
		INST_BRANCH_LT:  condition_satisfied = operand_a < operand_b;
		INST_BRANCH_GE:	 condition_satisfied = operand_a >= operand_b;
		INST_BRANCH_LTU: condition_satisfied = $signed(operand_a) < $signed(operand_b);
		INST_BRANCH_GEU: condition_satisfied = $signed(operand_a) >= $signed(operand_b);
		endcase
	end
endmodule
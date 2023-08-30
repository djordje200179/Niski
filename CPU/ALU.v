module cpu_alu (
	input [2:0] operation,
	input [6:0] mod,
	output reg invalid_opcode,

	input [31:0] operand_a, operand_b,
	output reg [31:0] result
);
	`include "Instructions.vh"

	always @* begin
		result = 32'b0;

		case (operation)
		INST_ARLOG_SL: 		result = operand_a << operand_b;
		INST_ARLOG_SLT: 	result = $signed(operand_a) < $signed(operand_b);
		INST_ARLOG_SLTU:	result = operand_a < operand_b;
		INST_ARLOG_XOR: 	result = operand_a ^ operand_b;
		INST_ARLOG_OR: 		result = operand_a | operand_b;
		INST_ARLOG_AND: 	result = operand_a & operand_b;
		INST_ARLOG_ADD: begin
			case (mod)
			INST_ADD_MOD_ADD: result = operand_a + operand_b;
			INST_ADD_MOD_SUB: result = operand_a - operand_b;
			endcase
		end
		INST_ARLOG_SR: begin
			case (mod)
			INST_SR_MOD_L: result = operand_a >> operand_b;
			INST_SR_MOD_A: result = operand_a >>> operand_b;
			endcase
		end
		endcase
	end
	
	always @* begin
		invalid_opcode = 1'b1;

		case (operation)
		INST_ARLOG_SL, 
		INST_ARLOG_SLT, 
		INST_ARLOG_SLTU, 
		INST_ARLOG_XOR, 
		INST_ARLOG_OR, 
		INST_ARLOG_AND:
			invalid_opcode = 1'b0; 
		INST_ARLOG_ADD: begin
			case (mod)
			INST_ADD_MOD_ADD, 
			INST_ADD_MOD_SUB:
				invalid_opcode = 1'b0;
			endcase 
		end
		INST_ARLOG_SR: begin
			case (mod)
			INST_SR_MOD_L,
			INST_SR_MOD_A:
				invalid_opcode = 1'b0;
			endcase
		end
		endcase
	end
endmodule
module cpu_ir_reg (
    input clk,

    input [31:0] data_in,
    input wr,

    output [4:0] rd, rs1, rs2,
	output [2:0] oper, 
	output [6:0] mod,
	output reg [32:0] imm,

	output reg inst_lui, inst_auipc, inst_jal, inst_jalr, inst_branch, inst_load, 
			   inst_store, inst_arlog_imm, inst_arlog, inst_misc_mem, inst_system
);
    reg [31:0] ir;

    assign rd = ir[11:7], 
		   rs1 = ir[19:15], 
		   rs2 = ir[24:20];

	wire [6:0] opcode = ir[6:0];
	wire [6:0] funct3 = ir[31:25];
	
	wire [11:0] imm_i = ir[31:20];
	wire [31:12] imm_u = ir[31:12];
	wire [11:0] imm_s = {ir[31:25], ir[11:7]};
	wire [12:1] imm_b = {ir[31], ir[7], ir[30:25], ir[11:8]};
	wire [20:1] imm_j = {ir[31], ir[19:12], ir[20], ir[30:21]};

	`include "Instructions.vh"

	always @* begin
		inst_lui = 1'b0;
		inst_auipc = 1'b0;
		inst_jal = 1'b0;
		inst_jalr = 1'b0;
		inst_branch = 1'b0;
		inst_load = 1'b0;
		inst_store = 1'b0;
		inst_arlog_imm = 1'b0;
		inst_arlog = 1'b0;
		inst_misc_mem = 1'b0;
		inst_system = 1'b0;

		case (opcode)
		INST_LUI: inst_lui = 1'b1;
		INST_AUIPC: inst_auipc = 1'b1;
		INST_JAL: inst_jal = 1'b1;
		INST_JALR: inst_jalr = 1'b1;
		INST_GROUP_BRANCH: inst_branch = 1'b1;
		INST_GROUP_LOAD: inst_load = 1'b1;
		INST_GROUP_STORE: inst_store = 1'b1;
		INST_GROUP_ARLOG_IMM: inst_arlog_imm = 1'b1;
		INST_GROUP_ARLOG: inst_arlog = 1'b1;
		INST_GROUP_MISC_MEM: inst_misc_mem = 1'b1;
		INST_GROUP_SYSTEM: inst_system = 1'b1;
		endcase
	end

	assign oper = ir[14:12];
	assign mod = (inst_arlog_imm && (oper == INST_ARLOG_SL || oper == INST_ARLOG_SR) || inst_arlog) ? funct3 : 7'b0;

	always @* begin
		imm = 32'b0;

		if (inst_lui || inst_auipc)
			imm = {imm_u, 12'b0};
		else if (inst_jal)
			imm = {{12{imm_j[20]}}, imm_j, 1'b0};
		else if (inst_jalr  || inst_load || inst_arlog_imm)
			imm = {{19{imm_i[11]}}, imm_i};
		else if (inst_branch)
			imm = {{18{imm_b[11]}}, imm_b, 1'b0};
		else if (inst_store)
			imm = {{19{imm_s[11]}}, imm_s};
	end

	always @(posedge clk) begin
		if (wr)
			ir <= data_in;
	end
endmodule
module cpu#(
	parameter EXEC_START_ADDR = 32'h40000000,
			  MORE_REGISTERS = 1'b1
) (
	input clk, rst,

	output [31:0] ma_addr, ma_data_out, 
	input [31:0] ma_data_in, 
	output reg ma_rd_req, ma_wr_req, 
	output reg [3:0] ma_data_mask, 
	input ma_done, ma_timeout,

	input clk_1_hz, ext_intr
);
	wire [9:0] inst_funct;
	wire [2:0] inst_funct3 = inst_funct[2:0];
	wire [4:0] inst_rd, inst_rs1, inst_rs2;
	wire [31:0] inst_imm;
	wire inst_lui, inst_auipc, inst_jal, inst_jalr, inst_branch, inst_load, 
		 inst_store, inst_arlog_imm, inst_arlog, inst_misc_mem, 
		 inst_system_ecall, inst_system_sret, inst_system_csrrw;

	wire branch_cond;
	reg pc_wr;
	reg pc_changed;
	reg [31:0] next_pc;
	wire [31:0] pc;

	wire [31:0] gpr_src1, gpr_src2;
	reg [31:0] gpr_dst_in;
	reg gpr_wr;

	wire csr_addr_allowed;
	reg [31:0] csr_data_in;
	wire [31:0] csr_data_out;
	wire csr_wr;

	wire supervisor_mode;
	wire intr_allowed;

	wire alignment_overflow;

	wire [31:0] alu_out;

	reg has_exception;
	reg [31:0] exc_cause, exc_pc, exc_value;
	wire [31:0] exc_handler_addr, exc_continue_addr;

	reg [2:0] state;
	localparam STATE_RD_INST_REQ = 3'd0,
			   STATE_RD_INST_WAIT = 3'd1,
			   STATE_EXEC_INST	= 3'd2,
			   STATE_EXEC_INST_MEM_WAIT = 3'd3,
			   STATE_CHECK_EXC	= 3'd4;

	cpu_pc_reg pc_reg_unit (
		.clk(clk), .rst(rst),

		.next_pc(next_pc), .wr(pc_wr),
		.pc(pc)
	);
	defparam pc_reg_unit.EXEC_START_ADDR = EXEC_START_ADDR;

	cpu_ir_reg ir_reg_unit (
		.clk(clk),

		.data_in(ma_data_in), 
		.wr(state == STATE_RD_INST_WAIT && ma_done),

		.funct(inst_funct),
		.rd(inst_rd), .rs1(inst_rs1), .rs2(inst_rs2),
		.imm(inst_imm),
		
		.inst_lui(inst_lui), .inst_auipc(inst_auipc), 
		.inst_jal(inst_jal), .inst_jalr(inst_jalr),
		.inst_branch(inst_branch),
		.inst_load(inst_load), .inst_store(inst_store),
		.inst_arlog_imm(inst_arlog_imm), .inst_arlog(inst_arlog),
		.inst_misc_mem(inst_misc_mem), 
		.inst_system_ecall(inst_system_ecall), .inst_system_sret(inst_system_sret),
		.inst_system_csrrw(inst_system_csrrw)
	);

	`include "Instructions.vh"
	
	cpu_branch_tester branch_tester_unit (
		.funct3(inst_funct3),
		.operand_a(gpr_src1), .operand_b(gpr_src2),
		.condition_satisfied(branch_cond)
	);

	cpu_reg_file#(MORE_REGISTERS) gprs (
		.clk(clk),

		.addr_rd1(inst_rs1), .addr_rd2(inst_rs2), .addr_wr(inst_rd),
		.data_rd1(gpr_src1), .data_rd2(gpr_src2),
		.data_wr(gpr_dst_in), 
		.wr(gpr_wr)
	);

	cpu_csrs csrs (
		.clk(clk), .rst(rst),

		.addr(inst_imm[11:0]), .addr_allowed(csr_addr_allowed),
		.data_in(csr_data_in), .data_out(csr_data_out),
		.wr(csr_wr), 
		
		.inst_tick(state == STATE_CHECK_EXC),
		.timer_tick(clk_1_hz),

		.exception(has_exception), 
		.exc_leave(state == STATE_EXEC_INST && inst_system_sret),
		.exc_cause(exc_cause),
		.exc_pc(exc_pc), .exc_value(exc_value),
		.exc_handler_addr(exc_handler_addr), .exc_continue_addr(exc_continue_addr),

		.intr_allowed(intr_allowed),
		.supervisor_mode(supervisor_mode)
	);

	`include "ExceptionCauses.vh"

	cpu_alu alu_unit (
		.funct(inst_funct),
		.operand_a(gpr_src1), .operand_b(inst_arlog_imm ? inst_imm : gpr_src2),
		.result(alu_out)
	);

	cpu_alignment_checker alignment_checker_unit (
		.addr_offset(ma_addr[1:0]), .mask(ma_data_mask),
		.overflow(alignment_overflow)
	);

	assign ma_addr = (state == STATE_RD_INST_REQ || state == STATE_RD_INST_WAIT) ? pc : gpr_src1 + inst_imm;
	assign ma_data_out = gpr_src2;

	always @* begin
		ma_data_mask = 4'b1111;

		if (state == STATE_EXEC_INST || state == STATE_EXEC_INST_MEM_WAIT) begin
			case (inst_funct3[1:0])
			2'b00: ma_data_mask = 4'b0001;
			2'b01: ma_data_mask = 4'b0011;
			endcase
		end
	end

	always @* begin
		pc_wr = 1'b0;

		case (state)
		STATE_EXEC_INST: begin
			if (inst_jal || inst_jalr)
				pc_wr = 1'b1;
			else if (inst_branch)
				pc_wr = branch_cond;
			else if (inst_system_sret)
				pc_wr = 1'b1;
		end
		STATE_CHECK_EXC: begin
			if (!pc_changed || has_exception)
				pc_wr = 1'b1;
		end
		endcase
	end
	
	always @* begin
		next_pc = pc + 32'h4;

		case (state)
		STATE_EXEC_INST: begin
			if (inst_jal)
				next_pc = pc + inst_imm;
			else if (inst_jalr)
				next_pc = (gpr_src1 + inst_imm) & ~32'h1;
			else if (inst_branch)
				next_pc = pc + inst_imm;
			else if (inst_system_sret)
				next_pc = exc_continue_addr;
		end
		STATE_CHECK_EXC: begin
			if (has_exception)
				next_pc = exc_handler_addr;
		end
		endcase
	end

	always @* begin
		gpr_wr = 1'b0;

		case (state)
		STATE_EXEC_INST: begin
			if (inst_lui || inst_auipc || inst_jal || inst_jalr || inst_arlog_imm || inst_arlog || inst_system_csrrw)
				gpr_wr = 1'b1;
		end
		STATE_EXEC_INST_MEM_WAIT: begin
			if (ma_rd_req && ma_done)
				gpr_wr = 1'b1;
		end
		endcase
	end

	always @* begin
		gpr_dst_in = 32'b0;

		if (state == STATE_EXEC_INST) begin
			if (inst_lui)
				gpr_dst_in = inst_imm;
			else if (inst_auipc)
				gpr_dst_in = pc + inst_imm;
			else if (inst_jal || inst_jalr)
				gpr_dst_in = pc + 4;
			else if (inst_arlog_imm || inst_arlog)
				gpr_dst_in = alu_out;
			else if (inst_system_csrrw)
				gpr_dst_in = csr_data_out;
		end else begin
			case (inst_funct3)
			INST_LOAD_FUNCT3_BYTE: 		gpr_dst_in = {{24{ma_data_in[7]}}, ma_data_in[7:0]};
			INST_LOAD_FUNCT3_HALF: 		gpr_dst_in = {{16{ma_data_in[15]}}, ma_data_in[15:0]};
			INST_LOAD_FUNCT3_WORD: 		gpr_dst_in = ma_data_in;
			INST_LOAD_FUNCT3_BYTE_UNS:	gpr_dst_in = {{24{1'b0}}, ma_data_in[7:0]};
			INST_LOAD_FUNCT3_HALF_UNS:	gpr_dst_in = {{16{1'b0}}, ma_data_in[15:0]};
			endcase
		end
	end

	always @* begin
		csr_data_in = 32'b0;

		case (inst_funct3)
		INST_SYSTEM_FUNCT3_CSRRW: 	csr_data_in = gpr_src1;
		INST_SYSTEM_FUNCT3_CSRRS: 	csr_data_in = csr_data_out | gpr_src1;
		INST_SYSTEM_FUNCT3_CSRRC: 	csr_data_in = csr_data_out & ~gpr_src1;
		INST_SYSTEM_FUNCT3_CSRRWI: 	csr_data_in = {27'b0, inst_rs1};
		INST_SYSTEM_FUNCT3_CSRRSI: 	csr_data_in = csr_data_out | {27'b0, inst_rs1};
		INST_SYSTEM_FUNCT3_CSRRCI: 	csr_data_in = csr_data_out & ~{27'b0, inst_rs1};
		endcase
	end

	assign csr_wr = state == STATE_EXEC_INST && inst_system_csrrw;

	task raise_exception(input [31:0] cause, value);
		begin
			state <= STATE_CHECK_EXC;

			has_exception <= 1'b1;
			exc_cause <= cause;
			exc_pc <= pc;
			exc_value <= value;
		end
	endtask


	task reset;
		begin
			state <= STATE_RD_INST_REQ;
			ma_wr_req <= 1'b0;
			ma_rd_req <= 1'b0;
			pc_changed <= 1'b0;

			has_exception <= 1'b0;
		end
	endtask

	task on_clock;
		begin
			case (state)
			STATE_RD_INST_REQ: begin
				pc_changed <= 1'b0;

				if (!alignment_overflow) begin
					state <= STATE_RD_INST_WAIT;
					ma_rd_req <= 1'b1;
				end else
					raise_exception(EXC_CAUSE_INSTRUCTION_ADDRESS_MISALIGNED, pc);	
			end
			STATE_RD_INST_WAIT: begin
				if (ma_timeout) begin
					raise_exception(EXC_CAUSE_INSTRUCTION_ACCESS_FAULT, pc);
					ma_rd_req <= 1'b0;
				end else if (ma_done) begin
					state <= STATE_EXEC_INST;
					ma_rd_req <= 1'b0;
				end
			end
			STATE_EXEC_INST: begin
				if (inst_load) begin
					if (!alignment_overflow) begin
						state <= STATE_EXEC_INST_MEM_WAIT;
						ma_rd_req <= 1'b1;
					end else
						raise_exception(EXC_CAUSE_LOAD_ADDRESS_MISALIGNED, ma_addr);
				end else if (inst_store) begin
					if (!alignment_overflow) begin
						state <= STATE_EXEC_INST_MEM_WAIT;
						ma_wr_req <= 1'b1;
					end else
						raise_exception(EXC_CAUSE_STORE_ADDRESS_MISALIGNED, ma_addr);
				end else if (inst_system_ecall)
					raise_exception(supervisor_mode ? EXC_CAUSE_SUPERVISOR_ECALL : EXC_CAUSE_USER_ECALL, pc);
				else if (inst_system_csrrw && !csr_addr_allowed)
					raise_exception(EXC_CAUSE_ILLEGAL_INSTRUCTION, pc);
				else state <= STATE_CHECK_EXC;

				if (pc_wr)
					pc_changed = 1'b1;				
			end
			STATE_EXEC_INST_MEM_WAIT: begin
				if (ma_timeout) begin
					raise_exception(inst_load ? EXC_CAUSE_LOAD_ACCESS_FAULT : EXC_CAUSE_STORE_ACCESS_FAULT, ma_addr);
					ma_rd_req <= 1'b0;
					ma_wr_req <= 1'b0;
				end else if (ma_done) begin
					state <= STATE_CHECK_EXC;
					ma_rd_req <= 1'b0;
					ma_wr_req <= 1'b0;
				end
			end
			STATE_CHECK_EXC: begin
				state <= STATE_RD_INST_REQ;

				if (has_exception)
					has_exception <= 1'b0;
			end
			endcase
		end
	endtask

	always @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end	
endmodule
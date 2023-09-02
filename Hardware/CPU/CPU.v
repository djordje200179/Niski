module cpu (
	clk, rst,
	bus_req, bus_grant,
	addr_bus, data_bus, rd_bus, wr_bus, data_mask_bus, fc_bus
);
	parameter EXEC_START_ADDR = 32'h40000000;
	parameter MORE_REGISTERS = 1'b1;

	input clk, rst;

	output bus_req;
	input bus_grant;

	output [31:0] addr_bus;
	inout [31:0] data_bus;
	output rd_bus, wr_bus;
	output [3:0] data_mask_bus;
	input fc_bus;

	wire [31:0] ma_data;
	reg [3:0] ma_mask;
	reg ma_wr_req, ma_rd_req;
	wire ma_done;

	wire [4:0] inst_rd, inst_rs1, inst_rs2;
	wire [9:0] inst_mod;
	wire [31:0] inst_imm;
	wire inst_lui, inst_auipc, inst_jal, inst_jalr, inst_branch, inst_load, 
		 inst_store, inst_arlog_imm, inst_arlog, inst_misc_mem, inst_system;

	wire branch_cond;
	reg pc_wr;
	reg pc_changed;
	reg [31:0] next_pc;
	wire [31:0] pc;

	wire [31:0] gpr_src1, gpr_src2;
	reg [31:0] gpr_dst_in;
	reg gpr_wr;

	reg [31:0] alu_operand_b;
	wire [31:0] alu_out;

	`include "States.vh"
	reg [7:0] state;

	cpu_memory_access memory_access_unit (
		.clk(clk), .rst(rst),

		.bus_req(bus_req), .bus_grant(bus_grant),
		.addr_bus(addr_bus), .data_bus(data_bus), .data_mask_bus(data_mask_bus),
		.rd_bus(rd_bus), .wr_bus(wr_bus), .fc_bus(fc_bus),

		.wr_req(ma_wr_req), .rd_req(ma_rd_req),
		.addr((state == STATE_RD_INST_REQ || state == STATE_RD_INST_WAIT) ? pc : gpr_src1 + inst_imm), 
		.data_out(gpr_src2), .data_in(ma_data), .data_mask(ma_mask),
		.done(ma_done)
	);

	cpu_pc_reg pc_reg_unit (
		.clk(clk), .rst(rst),

		.next_pc(next_pc), .wr(pc_wr),
		.curr_pc(pc)
	);
	defparam pc_reg_unit.EXEC_START_ADDR = EXEC_START_ADDR;

	cpu_ir_reg ir_reg_unit (
		.clk(clk),
		.data_in(ma_data), 
		.wr(state == STATE_RD_INST_WAIT && ma_done),

		.rd(inst_rd), .rs1(inst_rs1), .rs2(inst_rs2),
		.mod(inst_mod),
		.imm(inst_imm),
		
		.inst_lui(inst_lui), .inst_auipc(inst_auipc), 
		.inst_jal(inst_jal), .inst_jalr(inst_jalr),
		.inst_branch(inst_branch),
		.inst_load(inst_load), .inst_store(inst_store),
		.inst_arlog_imm(inst_arlog_imm), .inst_arlog(inst_arlog),
		.inst_misc_mem(inst_misc_mem), .inst_system(inst_system)
	);
	
	cpu_branch_tester branch_tester_unit (
		.mod(inst_mod[2:0]),
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

	cpu_alu alu_unit (
		.mod(inst_mod),
		.operand_a(gpr_src1), .operand_b(alu_operand_b),
		.result(alu_out)
	);
	
	`include "Instructions.vh"

	always @* begin
		ma_mask = 4'b1111;

		if (state == STATE_EXEC_INST || state == STATE_EXEC_INST_MEM_WAIT) begin
			case (inst_mod[1:0])
			2'b00: ma_mask = 4'b0001;
			2'b01: ma_mask = 4'b0011;
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
		end
		STATE_CHECK_INTR: begin
			if (!pc_changed)
				pc_wr = 1'b1;
		end
		endcase
	end
	
	always @* begin
		next_pc = pc + 32'h4;

		if (state == STATE_EXEC_INST) begin
			if (inst_jal)
				next_pc = pc + inst_imm;
			else if (inst_jalr)
				next_pc = (gpr_src1 + inst_imm) & ~32'h1;
			else if (inst_branch)
				next_pc = pc + inst_imm;
		end
	end

	always @* begin
		gpr_wr = 1'b0;

		case (state)
		STATE_EXEC_INST: begin
			if (inst_lui || inst_auipc || inst_jal || inst_jalr || inst_arlog_imm || inst_arlog)
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
		end else begin
			case (inst_mod[2:0])
			INST_LOAD_BYTE: 	gpr_dst_in = {{24{ma_data[7]}}, ma_data[7:0]};
			INST_LOAD_HALF: 	gpr_dst_in = {{16{ma_data[15]}}, ma_data[15:0]};
			INST_LOAD_WORD: 	gpr_dst_in = ma_data;
			INST_LOAD_BYTE_UNS:	gpr_dst_in = {{24{1'b0}}, ma_data[7:0]};
			INST_LOAD_HALF_UNS:	gpr_dst_in = {{16{1'b0}}, ma_data[15:0]};
			endcase
		end
	end

	always @* begin
		alu_operand_b = 32'b0;

		if(inst_arlog_imm) begin
			case (inst_mod[2:0])
			3'b001, 
			3'b101:
				alu_operand_b = inst_rs2;
			default:
				alu_operand_b = inst_imm;
			endcase
		end else
			alu_operand_b = gpr_src2;
	end

	task reset;
		begin
			state <= STATE_RD_INST_REQ;
			ma_wr_req <= 1'b0;
			ma_rd_req <= 1'b0;
			pc_changed <= 1'b0;
		end
	endtask

	task on_clock;
		begin
			case (state)
			STATE_RD_INST_REQ: begin
				state <= STATE_RD_INST_WAIT;
				ma_rd_req <= 1'b1;
				pc_changed <= 1'b0;
			end
			STATE_RD_INST_WAIT: begin
				if (ma_done) begin
					state <= STATE_EXEC_INST;
					ma_rd_req <= 1'b0;
				end
			end
			STATE_EXEC_INST: begin
				if (inst_load) begin
					state <= STATE_EXEC_INST_MEM_WAIT;
					ma_rd_req <= 1'b1;
				end else if (inst_store) begin
					state <= STATE_EXEC_INST_MEM_WAIT;
					ma_wr_req <= 1'b1;
				end else
					state <= STATE_CHECK_INTR;

				if (inst_jal || inst_jalr || inst_branch && branch_cond)
					pc_changed = 1'b1;				
			end
			STATE_EXEC_INST_MEM_WAIT: begin
				if (ma_done) begin
					state <= STATE_CHECK_INTR;
					ma_rd_req <= 1'b0;
					ma_wr_req <= 1'b0;
				end
			end
			STATE_CHECK_INTR: begin
				state <= STATE_RD_INST_REQ;
			end
			endcase
		end
	endtask

	always @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end	
endmodule
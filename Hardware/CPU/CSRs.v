module cpu_csrs (
	input clk, rst,

	input [11:0] addr,
	output addr_allowed,

	input [31:0] data_in,
	output reg [31:0] data_out,
	input wr, 
	
	input inst_tick, timer_tick, ext_intr_tick,

	input exception, exc_leave, 
	input [31:0] exc_cause, exc_pc, exc_value,
	output [31:0] exc_handler_addr, exc_continue_addr,

	output has_intr,
	output reg [4:0] intr_index,
	output reg supervisor_mode
);
	localparam CYCLE_ADDR		= 12'hC00,
			   CYCLEH_ADDR 		= 12'hC80,
			   TIME_ADDR 		= 12'hC01,
			   TIMEH_ADDR 		= 12'hC81,
			   INSTRET_ADDR		= 12'hC02,
			   INSTRETH_ADDR	= 12'hC82;

	localparam SSTATUS_ADDR 	= 12'h100,
			   SIE_ADDR			= 12'h104,
			   STVEC_ADDR		= 12'h105,
			   SCOUNTEREN_ADDR	= 12'h106,
			   SENVCVG_ADDR		= 12'h10A,
			   SSCRATCH_ADDR	= 12'h140,
			   SEPC_ADDR		= 12'h141,
			   SCAUSE_ADDR		= 12'h142,
			   STVAL_ADDR		= 12'h143,
			   SIP_ADDR			= 12'h144,
			   SATP_ADDR		= 12'h180,
			   SCONTEXT_ADDR	= 12'h5A8;

	// TODO: Add performance counters (hpmcounter3-hpmcounter31)
	// TODO: Add scounteren, senvcfg, scontext, satp

	reg [63:0] cycle_cnt, time_cnt, inst_cnt;
	
	assign addr_allowed = addr[9:8] == 2'b01 ? supervisor_mode : 1'b1;

	reg [31:0] sstatus, sie, stvec, sscratch, sepc, scause, stval, sip;

	wire sstatus_spp = sstatus[8],
		 sstatus_spie = sstatus[5],
		 sstatus_sie = sstatus[1];

	assign exc_handler_addr = stvec;
	assign exc_continue_addr = sepc;

	wire intr_allowed = supervisor_mode ? sstatus_sie : 1'b1;
	assign has_intr = |(sip & sie) && intr_allowed;

	integer i;
	always @* begin
		intr_index = 5'b0;
		for (i = 0; i < 32; i = i + 1) begin
			if (sip[i] && sie[i])
				intr_index = i;
		end
	end

	always @* begin
		data_out = 32'b0;

		case (addr)
		CYCLE_ADDR:     data_out = cycle_cnt[31:0];
		CYCLEH_ADDR:    data_out = cycle_cnt[63:32];
		TIME_ADDR:      data_out = time_cnt[31:0];
		TIMEH_ADDR:     data_out = time_cnt[63:32];
		INSTRET_ADDR:   data_out = inst_cnt[31:0];
		INSTRETH_ADDR:  data_out = inst_cnt[63:32];
		SSTATUS_ADDR:	data_out = sstatus;
		SIE_ADDR:      	data_out = sie;
		STVEC_ADDR:    	data_out = stvec;
		SSCRATCH_ADDR: 	data_out = sscratch;
		SEPC_ADDR:     	data_out = sepc;
		SCAUSE_ADDR:   	data_out = scause;
		STVAL_ADDR:    	data_out = stval;
		SIP_ADDR:      	data_out = sip;
		endcase
	end

	initial supervisor_mode = 1'b1;

	task reset;
		begin
			cycle_cnt <= 64'h0;
			time_cnt <= 64'h0;
			inst_cnt <= 64'h0;

			supervisor_mode <= 1'b1;
			sip <= 32'b0;
		end
	endtask

	task on_clock;
		begin
			if (wr && addr_allowed) begin
				case (addr)
				SSTATUS_ADDR:	sstatus <= data_in;
				SIE_ADDR:		sie <= data_in;
				STVEC_ADDR:		stvec <= data_in;
				SSCRATCH_ADDR:	sscratch <= data_in;
				SEPC_ADDR:		sepc <= data_in;
				SCAUSE_ADDR:	scause <= data_in;
				STVAL_ADDR:		stval <= data_in;
				SIP_ADDR:		sip <= data_in;
				endcase
			end

			if (exception) begin
				sepc <= exc_pc;
				stval <= exc_value;
				scause <= exc_cause;

				supervisor_mode <= 1'b1;
				sstatus[8] <= supervisor_mode;
				sstatus[5] <= sstatus[1];
				sstatus[1] <= 1'b0;
			end else if (exc_leave) begin
				supervisor_mode <= sstatus_spp;
				sstatus[1] <= sstatus_spie;
				sstatus[5] <= 1'b1;
			end

			if (timer_tick) begin
				time_cnt <= time_cnt + 32'b1;
				sip[5] <= 1'b1;
			end

			if (inst_tick)
				inst_cnt <= inst_cnt + 32'b1;

			if (ext_intr_tick)
				sip[1] <= 1'b1;

			cycle_cnt <= cycle_cnt + 32'b1;
		end
	endtask

	always @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end
endmodule
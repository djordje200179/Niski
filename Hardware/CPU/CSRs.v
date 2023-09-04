module cpu_csrs (
	input clk, rst,

	input [11:0] addr,

	input [31:0] data_in,
	output reg [31:0] data_out,
	input wr, incr_inst_count
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

	reg [63:0] CYCLE = 64'h0,
			   TIME, INSTRET;

	reg [31:0] sstatus, sie, stvec, sscratch, sepc, scause, stval, sip;

	always @* begin
		data_out = 32'b0;

		case (addr)
		CYCLE_ADDR:     data_out = CYCLE[31:0];
		CYCLEH_ADDR:    data_out = CYCLE[63:32];
		TIME_ADDR:      data_out = TIME[31:0];
		TIMEH_ADDR:     data_out = TIME[63:32];
		INSTRET_ADDR:   data_out = INSTRET[31:0];
		INSTRETH_ADDR:  data_out = INSTRET[63:32];
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

	task reset;
		begin
			TIME <= 64'h0;
			INSTRET <= 64'h0;
		end
	endtask

	task on_clock;
		begin
			if (wr) begin
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

			CYCLE <= CYCLE + 32'b1;
			TIME <= TIME + 32'b1;

			if (incr_inst_count)
				INSTRET <= INSTRET + 32'b1;
		end
	endtask

	always @(posedge clk or posedge rst) begin 
		if (rst) reset;
		else on_clock;
	end
endmodule
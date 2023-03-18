`ifndef CPU_GPRS
`define CPU_GPRS

localparam GPR_ZERO	= 4'd0,
		   GPR_RA	= 4'd1,
		   GPR_SP	= 4'd2,
		   GPR_GP	= 4'd3,
		   GPR_TP	= 4'd4,
		   GPR_T0	= 4'd5,
		   GPR_T1	= 4'd6,
		   GPR_T2	= 4'd7,
		   GPR_S0	= 4'd8,
		   GPR_S1	= 4'd9,
		   GPR_A0	= 4'd10,
		   GPR_A1	= 4'd11,
		   GPR_A2	= 4'd12,
		   GPR_A3	= 4'd13,
		   GPR_A4	= 4'd14,
		   GPR_A5	= 4'd15;
		   
localparam GPR_A6	= 5'd16,
		   GPR_A7	= 5'd17,
		   GPR_S2	= 5'd18,
		   GPR_S3	= 5'd19,
		   GPR_S4	= 5'd20,
		   GPR_S5	= 5'd21,
		   GPR_S6	= 5'd22,
		   GPR_S7	= 5'd23,
		   GPR_S8	= 5'd24,
		   GPR_S9	= 5'd25,
		   GPR_S10	= 5'd26,
		   GPR_S11	= 5'd27,
		   GPR_T3	= 5'd28,
		   GPR_T4	= 5'd29,
		   GPR_T5	= 5'd30,
		   GPR_T6	= 5'd31;
		   
`endif
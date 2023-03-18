`ifndef CPU_STATES
`define CPU_STATES

localparam STATE_IDLE				= 5'd0,
		   STATE_WAITING_BUS_GRANT	= 5'd1,
		   STATE_WAITING_DATA		= 5'd2,
		   STATE_ACCEPTED_DATA		= 5'd3;

`endif
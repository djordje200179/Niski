`ifndef ARBITRATOR_STATES
`define ARBITRATOR_STATES

localparam STATE_IDLE = 2'b0,
		   STATE_CPU = 2'b1,
		   STATE_DMA = 2'b10;
`endif
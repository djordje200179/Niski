`ifndef SDRAM_STATES
`define SDRAM_STATES

localparam STATE_IDLE 		 = 3'd0,
		   STATE_OPENING_ROW = 3'd1,
		   STATE_CLOSING_ROW = 3'd2,
		   STATE_READING 	 = 3'd3,
		   STATE_WRITING 	 = 3'd4,
		   STATE_REFRESHING	 = 3'd5;
`endif
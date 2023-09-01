localparam STATE_RD_INST_REQ = 8'd0,
		   STATE_RD_INST_WAIT = 8'd1;

localparam STATE_EXEC_INST	= 8'd100,
		   STATE_EXEC_INST_MEM_WAIT = 8'd101;

localparam STATE_CHECK_INTR	= 8'd200;
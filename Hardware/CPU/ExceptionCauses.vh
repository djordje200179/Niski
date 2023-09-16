localparam EXC_CAUSE_ILLEGAL_INSTRUCTION = 32'd2;

localparam EXC_CAUSE_USER_ECALL = 32'd8,
		   EXC_CAUSE_SUPERVISOR_ECALL = 32'd9;

localparam EXC_CAUSE_LOAD_ACCESS_FAULT = 32'd5,
		   EXC_CAUSE_STORE_ACCESS_FAULT = 32'd7;
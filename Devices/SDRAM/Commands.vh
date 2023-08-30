`ifndef SDRAM_COMMANDS
`define SDRAM_COMMANDS

localparam CMD_LOADMODE	 = 3'b000,
		   CMD_REFRESH	 = 3'b001,
		   CMD_PRECHARGE = 3'b010,
		   CMD_ACTIVE 	 = 3'b011,
		   CMD_WRITE 	 = 3'b100,
		   CMD_READ		 = 3'b101,
		   CMD_NOOP		 = 3'b111;
					 
`endif
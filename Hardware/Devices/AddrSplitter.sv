module addr_splitter#(START_ADDR = 32'h0, REGS = 2) (
	input [31:0] addr_bus,

	output addr_hit,
	output [$clog2(REGS) - 3:0] reg_index,
	output [1:0] word_offset 
);
	localparam REG_BITS = $clog2(REGS),
			   DEVICE_BITS = REG_BITS + 2;

	assign reg_index = addr_bus[REG_BITS + 1:2];
	assign word_offset = addr_bus[1:0];

	assign addr_hit = addr_bus[31:DEVICE_BITS] == START_ADDR[31:DEVICE_BITS];
endmodule
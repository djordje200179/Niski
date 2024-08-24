module ps2_keyboard_bus_interface#(parameter START_ADDR = 32'h0) (
	input clk, rst,

	input btn_0, btn_1, btn_2, btn_3,
	output irq,

	input [31:0] addr_bus,
	inout [31:0] data_bus,
	input rd_bus, wr_bus,
	input [3:0] data_mask_bus,
	output fc_bus
);

endmodule
module leds_bus_interface_tb;

reg clk = 0;
always #5 clk = ~clk;

reg rst;

wire ctrl_en, ctrl_led0, ctrl_led1, ctrl_led2, ctrl_led3;

reg [31:0] addr_bus;
wire [31:0] data_bus;
reg rd_bus, wr_bus;
reg [3:0] data_mask_bus;
wire fc_bus;

reg [31:0] data_bus_out;
reg data_bus_out_valid = 0;
assign data_bus = data_bus_out_valid ? data_bus_out : 32'hz;

leds_bus_interface dut (
	.clk(clk), .rst(rst),

	.ctrl_en(ctrl_en), .ctrl_led0(ctrl_led0), .ctrl_led1(ctrl_led1), .ctrl_led2(ctrl_led2), .ctrl_led3(ctrl_led3),
	
	.addr_bus(addr_bus), .data_bus(data_bus),
	.rd_bus(rd_bus), .wr_bus(wr_bus), .data_mask_bus(data_mask_bus),
	.fc_bus(fc_bus)
);

defparam dut.CTRL_REG_ADDR = 32'h70000000;
defparam dut.STATUS_REG_ADDR = 32'h70000004;
defparam dut.DATA_REG_ADDR = 32'h70000008;

initial begin
	$stop;
	#1000;
	$stop;
end

initial begin
	rst = 1'b0;
	#2 rst = 1'b1;
	#2 rst = 1'b0;

	wr_bus = 1'b1;
	rd_bus = 1'b0;
	data_mask_bus = 4'b1111;
	addr_bus = 32'h70000000;
	data_bus_out = 32'h00000001;
	data_bus_out_valid = 1'b1;

	wait (fc_bus);
	wr_bus = 1'b0;
	data_bus_out_valid = 1'b0;

	#10;
	assert (ctrl_en == 1'b1);

	wr_bus = 1'b1;
	addr_bus = 32'h70000008;
	data_bus_out = 32'h0000000a;
	data_bus_out_valid = 1'b1;

	wait (fc_bus);
	wr_bus = 1'b0;
	data_bus_out_valid = 1'b0;

	#10;
	assert (ctrl_en == 1'b1);
	assert (ctrl_led0 == 1'b0);
	assert (ctrl_led1 == 1'b1);
	assert (ctrl_led2 == 1'b0);
	assert (ctrl_led3 == 1'b1);
end

endmodule
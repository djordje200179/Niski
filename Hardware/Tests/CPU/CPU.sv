module cpu_tb;

reg clk = 0;
always #5 clk = ~clk;

reg rst;

wire bus_req;
reg bus_grant;

wire [31:0] addr_bus;
wire [31:0] data_bus;
wire rd_bus, wr_bus;
wire [3:0] data_mask_bus;
reg fc_bus;

reg [31:0] data_bus_out;
reg data_bus_out_valid = 0;
assign data_bus = data_bus_out_valid ? data_bus_out : 32'hz;

cpu dut (
	.clk(clk), .rst(rst),

	.bus_req(bus_req), .bus_grant(bus_grant),
	
	.addr_bus(addr_bus), .data_bus(data_bus),
	.rd_bus(rd_bus), .wr_bus(wr_bus), .data_mask_bus(data_mask_bus),
	.fc_bus(fc_bus)
);

initial begin
	$stop;
	#1000;
	$stop;
end

initial begin
	rst = 1'b0;
	#2 rst = 1'b1;
	#2 rst = 1'b0;

	fc_bus = 1'b0;
	data_bus_out_valid = 1'b0;

	bus_grant = 1'b0;
	wait (bus_req);
	bus_grant = 1'b1;

	wait (rd_bus);
	data_bus_out = 32'h700007B7;
	data_bus_out_valid = 1'b1;
	fc_bus = 1'b1;

	wait (!bus_req);
	bus_grant = 1'b0;
	data_bus_out_valid = 1'b0;
	fc_bus = 1'b0;

	wait (bus_req);
	bus_grant = 1'b1;

	wait (rd_bus);
	data_bus_out = 32'h00100713;
	data_bus_out_valid = 1'b1;
	fc_bus = 1'b1;

	wait (!bus_req);
	bus_grant = 1'b0;
	data_bus_out_valid = 1'b0;
	fc_bus = 1'b0;

	wait (bus_req);
	bus_grant = 1'b1;

	wait (rd_bus);
	data_bus_out = 32'h00e78023;
	data_bus_out_valid = 1'b1;
	fc_bus = 1'b1;

	wait (!bus_req);
	bus_grant = 1'b0;
	data_bus_out_valid = 1'b0;
	fc_bus = 1'b0;

	wait (bus_req);
	bus_grant = 1'b1;

	wait (wr_bus);
	assert (addr_bus == 32'h70000000);
	assert (data_bus == 32'h00000001);
	fc_bus = 1'b1;

	wait (!bus_req);
	bus_grant = 1'b0;
	fc_bus = 1'b0;
end

endmodule
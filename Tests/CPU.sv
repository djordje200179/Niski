module cpu_tb;

reg clk;
always #5 clk = ~clk;

reg rst = 0;

wire bus_req;
reg bus_grant = 0;

wire [31:0] addr_bus;
wire [31:0] data_bus;
wire rd_bus, wr_bus;
wire [2:0] data_mask_bus;
reg fc_bus = 0;

cpu dut (
    .clk(clk),
    .rst(rst),
    .bus_req(bus_req), .bus_grant(bus_grant),
    .addr_bus(addr_bus), .data_bus(data_bus),
    .rd_bus(rd_bus), .wr_bus(wr_bus), .data_mask_bus(data_mask_bus),
    .fc_bus(fc_bus)
);

initial begin
    rst = 1;
    #10 rst = 0;

    @(bus_req);
    bus_grant = 1'b1;

    @(rd_bus);
    assign data_bus = 32'h00000000;
    fc_bus = 1'b1;

    @(!bus_req);
    bus_grant = 1'b0;
    deassign data_bus;
    fc_bus = 1'b0;
end

endmodule
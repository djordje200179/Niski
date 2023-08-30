module bus_arbitrator_tb; 

reg clk = 0;
always #5 clk = ~clk;

reg rst;

reg cpu_req, dma_req;
wire cpu_grant, dma_grant;

wire [31:0] addr_bus,  data_bus;
wire rd_bus, wr_bus;
wire [3:0] data_mask_bus;
wire fc_bus;

bus_arbitrator dut (
    .clk(clk), .rst(rst),

    .cpu_req(cpu_req), .dma_req(dma_req),
    .cpu_grant(cpu_grant), .dma_grant(dma_grant),

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
    cpu_req = 1'b1;

	rst = 1'b0;
	#2 rst = 1'b1;
	#2 rst = 1'b0;

    #11;
    assert (cpu_grant == 1'b1);

    #11;
    cpu_req = 1'b0;

    #11;
    assert (cpu_grant == 1'b0);

    #11;
    cpu_req = 1'b1;

    #11;
    assert (cpu_grant == 1'b1);
end

endmodule
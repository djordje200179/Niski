module niski_tb;

reg clk = 0;
always #5 clk = ~clk;

reg rst;

wire [4:0] btns = {~rst, 4'b0};
wire [3:0] leds;
wire [6:0] sev_seg_segments;
wire [3:0] sev_seg_select;

`include "NiskiDUT.v"
niski_dut dut (
    .CLK_PIN(clk), 

	.BTN_PINS(btns),
	.LED_PINS(leds),

	.SEVSEG_SEG_PINS(sev_seg_segments),
	.SEVSEG_SEL_PINS(sev_seg_select)
);

initial begin
	$stop;
	#6000;
	$stop;
end

initial begin
    rst = 1'b0;
	#2 rst = 1'b1;
	#2 rst = 1'b0;
end

endmodule
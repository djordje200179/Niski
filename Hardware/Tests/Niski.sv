module niski_tb;

reg clk = 0;
always #5 clk = ~clk;

reg rst;

wire [4:0] btns = {~rst, 4'b0};
wire [3:0] leds;
wire [6:0] ssds_segments;
wire [3:0] ssds_select;

`include "NiskiDUT.v"
niski_dut dut (
	.CLK_PIN(clk), 

	.BTN_PINS(btns),
	.LED_PINS(leds),

	.SEVSEG_SEG_PINS(ssds_segments),
	.SEVSEG_SEL_PINS(ssds_select)
);

initial begin
	$stop;
	
	wait (dut.b2v_inst23.pc == 32'h40000020);
	$strobe("PC at %t", $time);

	#10000;
	$stop;
end

initial begin
	rst = 1'b0;
	#2 rst = 1'b1;
	#2 rst = 1'b0;
end

string register_names[32] = {
	"zero",
	"ra", "sp",
	"gp", "tp",
	"t0", "t1", "t2",
	"s0", "s1",
	"a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7",
	"s2", "s3", "s4", "s5", "s6", "s7", "s8", "s9", "s10", "s11",
	"t3", "t4", "t5", "t6"
};

endmodule
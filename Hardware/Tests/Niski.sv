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
	wait (dut.b2v_inst23.pc == 32'h400011b4);

	$strobe("PC at %t", $time);

	#5000;
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

always begin
	wait (dut.wr_bus && dut.addr_bus[31:4] == 28'h7000002);
	$strobe("at %t -> PC: %h, MEM[%h] = %h (%d), (Mask: %b)", $time, dut.b2v_inst23.pc, dut.addr_bus, dut.data_bus, dut.data_bus, dut.data_mask_bus);
	wait (!dut.wr_bus);
end

// always begin
// 	wait (dut.b2v_inst23.gpr_wr);
// 	$strobe("PC: %h, GPR[%s] = %h (%d)", dut.b2v_inst23.pc, register_names[dut.b2v_inst23.inst_rd], dut.b2v_inst23.gpr_dst_in, dut.b2v_inst23.gpr_dst_in);
// 	wait (!dut.b2v_inst23.gpr_wr);
// end

endmodule
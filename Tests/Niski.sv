module niski_tb;

reg clk = 0;
always #5 clk = ~clk;

reg rst;

wire [4:0] btns = {~rst, 4'b0};

`include "NiskiDUT.v"

niski_dut dut (
    .CLK_PIN(clk), 
	.BTN_PINS(btns)
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
end

endmodule
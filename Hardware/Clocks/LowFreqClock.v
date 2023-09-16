module low_freq_clock (
	input clk_2_khz, rst,

	output reg clk_1_khz, 
	output clk_1_hz
);
	frequency_divider#(2_000) seconds_generator (
		.clk(clk_2_khz), 
		.rst(rst),
		.slow_clk(clk_1_hz)
	);

	always @(posedge clk_2_khz or posedge rst) begin
		if (rst) clk_1_khz <= 1'b0;
		else clk_1_khz <= ~clk_1_khz;
	end
endmodule
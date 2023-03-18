module clocks (
	clk, en, 
	clk_50_mhz, clk_1_mhz, clk_1_khz, clk_1_hz
);
	parameter INPUT_FREQ = 50_000_000;
	
	input clk, en;
	
	output clk_50_mhz, clk_1_mhz, clk_1_khz, clk_1_hz;
	
	assign clk_50_mhz = clk;
	frequency_divider#(50) mhz_generator (clk, 0, en, clk_1_mhz);
	frequency_divider#(1000) khz_generator (clk_1_mhz, 0, en, clk_1_khz),
							 hz_generator (clk_1_khz, 0, en, clk_1_hz);
endmodule

module frequency_divider (
	clk, rst, en, 
	slow_clk
);
	parameter RATIO = 1_000;
	
	input clk, rst, en;
	
	output reg slow_clk;
	
	wire counter_tick;
	
	counter#(RATIO / 2) counter (
		.clk(clk), 
		.en(en), 
		.rst(rst),
		.will_overflow(counter_tick)
	);
	
	task reset;
		begin
			slow_clk <= 1'b0;
		end
	endtask
	
	task on_clock;
		begin
			if(counter_tick)
				slow_clk <= ~slow_clk;
		end
	endtask
	
	always @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end
endmodule
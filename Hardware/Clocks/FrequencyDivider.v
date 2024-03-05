module frequency_divider (
	input clk, rst,
	output reg slow_clk
);
	parameter RATIO = 1_000;
	
	wire counter_tick;
	
	counter#(RATIO / 2) counter (
		.clk(clk), 
		.en(1'b1), 
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
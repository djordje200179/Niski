module debouncer (
	clk, rst, 
	raw_input, 
	debounced_input
);
	parameter TICKS = 16;
	
	input clk, rst;
	
	input raw_input;
	
	output reg debounced_input;
	
	reg old_value, curr_value;
	
	wire value_changed = old_value ^ curr_value;
	wire value_stable;
	
	counter#(TICKS) counter (
		.clk(clk),
		.en(~value_stable),
		.rst(value_changed),
		.will_overflow(value_stable)
	);
	
	task reset;
		begin
			old_value <= 1'b0;
			curr_value <= 1'b0;
		end
	endtask
	
	task on_clock;
		begin
			old_value <= curr_value;
			curr_value <= raw_input;
			
			if (value_stable) begin
				debounced_input <= curr_value;
			end
		end
	endtask
	
	always @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end
endmodule
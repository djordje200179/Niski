module counter (
	clk, rst, en, 
	value, 
	will_overflow
);
	parameter LIMIT = 1_000;
	parameter START_FROM = 0;
	parameter CONTINUE_FROM = START_FROM;
	
	localparam BITS = $clog2(LIMIT);
	localparam INCREMENT = 1'b1;

	input clk, rst, en;
	
	output reg [BITS-1:0] value = START_FROM;
	output will_overflow;
	
	assign will_overflow = value + INCREMENT == LIMIT;
	
	task reset;
		begin
			value <= START_FROM;
		end
	endtask
	
	task on_clock;
		begin
			if(en)
				value <= will_overflow ? CONTINUE_FROM : value + INCREMENT;
		end
	endtask
	
	always @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end
endmodule
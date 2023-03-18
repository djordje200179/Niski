module sev_seg_displays_controller (
	clk, rst, en, 
	digit_0, digit_1, digit_2, digit_3, dots, 
	segment_pins, select_pins
);
	parameter REFRESH_RATE = 60;
	parameter CLK_FREQ = 1_000;
	
	localparam REFRESH_PERIOD = CLK_FREQ / (REFRESH_RATE * 4);
	
	input clk, rst, en;
	
	input [6:0] digit_0, digit_1, digit_2, digit_3;
	input [3:0] dots;

	output [7:0] segment_pins;
	output [3:0] select_pins;
	
	wire refresh_clk;
	frequency_divider #(REFRESH_PERIOD) refresh_tick_generator (
		.clk(clk), 
		.rst(rst),
		.en(1),
		.slow_clk(refresh_clk)
	);
	
	wire [1:0] current_digit;
	counter #(4) digit_counter (
		.clk(refresh_clk), 
		.rst(rst),
		.en(1), 
		.value(current_digit)
	);

	wire [6:0] segments [3:0];
	assign {segments[3], segments[2], segments[1], segments[0]} = {digit_3, digit_2, digit_1, digit_0};

	assign segment_pins = en ? ~{dots[current_digit], segments[current_digit]} : 8'hff;
	
	function [3:0] decode_select_pins(input [1:0] index);
		begin
			case (index)
				2'd0: decode_select_pins = 4'b1110;
				2'd1: decode_select_pins = 4'b1101;
				2'd2: decode_select_pins = 4'b1011;
				2'd3: decode_select_pins = 4'b0111;
			endcase
		end
	endfunction
	
	assign select_pins = en ? decode_select_pins(current_digit) : 4'hf;
endmodule
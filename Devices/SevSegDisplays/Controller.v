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
	
	reg [3:0] decoded_digit;
	always @* begin
		case (current_digit)
		2'd0: decoded_digit = 4'b1110;
		2'd1: decoded_digit = 4'b1101;
		2'd2: decoded_digit = 4'b1011;
		2'd3: decoded_digit = 4'b0111;
		endcase
	end

	assign select_pins = en ? decoded_digit : 4'hf;

	wire [6:0] segments [3:0];
	assign {segments[3], segments[2], segments[1], segments[0]} = {digit_3, digit_2, digit_1, digit_0};

	assign segment_pins = en ? ~{dots[current_digit], segments[current_digit]} : 8'hff;
endmodule
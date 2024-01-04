module ssds_controller#(REFRESH_RATE = 60, CLK_FREQ = 1_000) (
	input clk, rst, en, 

	input [6:0] digit_0, digit_1, digit_2, digit_3, 
	input [3:0] dots, 

	output [7:0] segment_pins, 
	output [3:0] select_pins
);
	localparam REFRESH_PERIOD = CLK_FREQ / (REFRESH_RATE * 4);

	wire refresh_clk;
	frequency_divider#(REFRESH_PERIOD) refresh_tick_generator (
		.clk(clk), 
		.rst(rst),
		.slow_clk(refresh_clk)
	);
	
	reg [1:0] current_digit;
	
	logic [3:0] decoded_digit;
	always_comb begin
		case (current_digit)
			0: decoded_digit = 4'b0111;
			1: decoded_digit = 4'b1011;
			2: decoded_digit = 4'b1101;
			3: decoded_digit = 4'b1110;
		endcase
	end

	assign select_pins = en ? decoded_digit : '1;

	wire [6:0] segments [4];
	assign segments = '{digit_3, digit_2, digit_1, digit_0};

	assign segment_pins = en ? ~{dots[current_digit], segments[current_digit]} : '1;

	task automatic reset;
		begin
			current_digit <= 0;
		end
	endtask

	task automatic on_clock;
		begin
			current_digit <= current_digit + 1;
		end
	endtask

	always_ff @(posedge refresh_clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end
endmodule
module buttons_controller (
	clk, 
	button_pins, 
	btn_0, btn_1, btn_2, btn_3, btn_rst
);
	parameter DEBOUNCING_TICKS = 4;
	
	input clk;
	
	output btn_0, btn_1, btn_2, btn_3, btn_rst;
	
	input [4:0] button_pins;
	
	generate
		genvar i;
		for(i = 0; i < 5; i = i + 1) begin : debouncers
			wire debounced_input;
			
			case (i)
			0: assign btn_0 = debounced_input;
			1: assign btn_1 = debounced_input;
			2: assign btn_2 = debounced_input;
			3: assign btn_3 = debounced_input;
			4: assign btn_rst = debounced_input;
			endcase
			
			debouncer#(DEBOUNCING_TICKS) debouncer (
				.clk(clk),
				.raw_input(~button_pins[i]),
				.debounced_input(debounced_input)
			);
		end
	endgenerate
endmodule
module buttons_controller#(DEBOUNCING_TICKS = 4) (
	input clk, 
	
	input [4:0] button_pins, 
	
	output btn_0, btn_1, btn_2, btn_3, btn_rst
);
	assign btn_rst = ~button_pins[4];
	
	generate
		genvar i;
		for(i = 0; i < 4; i++) begin : debouncers
			wire debounced_input;
			
			case (i)
			0: assign btn_0 = debounced_input;
			1: assign btn_1 = debounced_input;
			2: assign btn_2 = debounced_input;
			3: assign btn_3 = debounced_input;
			endcase
			
			debouncer#(DEBOUNCING_TICKS) debouncer (
				.clk(clk),
				.raw_input(~button_pins[i]),
				.debounced_input(debounced_input)
			);
		end
	endgenerate
endmodule
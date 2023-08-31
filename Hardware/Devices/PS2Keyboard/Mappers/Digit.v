module ps2_keyboard_digit_mapper (data, digit);
	input [7:0] data;
	
	output [3:0] digit;
	
	`include "../Keys.vh"

	function [3:0] get_digit(input [7:0] data);
		begin
			case (data)
			PS2_KEYBOARD_NUMPAD_0, PS2_KEYBOARD_0: get_digit = 4'd0;
			PS2_KEYBOARD_NUMPAD_1, PS2_KEYBOARD_1: get_digit = 4'd1;
			PS2_KEYBOARD_NUMPAD_2, PS2_KEYBOARD_2: get_digit = 4'd2;
			PS2_KEYBOARD_NUMPAD_3, PS2_KEYBOARD_3: get_digit = 4'd3;
			PS2_KEYBOARD_NUMPAD_4, PS2_KEYBOARD_4: get_digit = 4'd4;
			PS2_KEYBOARD_NUMPAD_5, PS2_KEYBOARD_5: get_digit = 4'd5;
			PS2_KEYBOARD_NUMPAD_6, PS2_KEYBOARD_6: get_digit = 4'd6;
			PS2_KEYBOARD_NUMPAD_7, PS2_KEYBOARD_7: get_digit = 4'd7;
			PS2_KEYBOARD_NUMPAD_8, PS2_KEYBOARD_8: get_digit = 4'd8;
			PS2_KEYBOARD_NUMPAD_9, PS2_KEYBOARD_9: get_digit = 4'd9;
			default: get_digit = 4'hF;
			endcase
		end
	endfunction
	
	assign digit = get_digit(data);
endmodule
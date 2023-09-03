module ssds_hex_number_mapper (
	number, 
	digit0, digit1, digit2, digit3
);
	input [15:0] number;
	
	output [6:0] digit0, digit1, digit2, digit3;

	ssds_digit_mapper ones (number[0 +: 4], digit0), 
						 tens (number[4 +: 4], digit1),
						 hundreds (number[8 +: 4], digit2),
						 thousands (number[12 +: 4], digit3);
endmodule
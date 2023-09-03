module ssds_dec_number_mapper (
	number, 
	digit0, digit1, digit2, digit3
);
	input [13:0] number;
	
	output [6:0] digit0, digit1, digit2, digit3;
	
	ssds_digit_mapper ones (number / 1 	% 10, digit0), 
						 tens (number / 10 % 10, digit1),
						 hundreds (number / 100 % 10, digit2),
						 thousands (number / 1000 % 10, digit3);
endmodule
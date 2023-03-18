module sev_seg_digit_mapper (digit, segments);
	input [3:0] digit;
	
	output [6:0] segments;

	function [6:0] get_segments(input [3:0] digit);
		begin
			case (digit)
			4'h0: get_segments = 7'b0111111;
			4'h1: get_segments = 7'b0000110;
			4'h2: get_segments = 7'b1011011;
			4'h3: get_segments = 7'b1001111;
			4'h4: get_segments = 7'b1100110;
			4'h5: get_segments = 7'b1101101;
			4'h6: get_segments = 7'b1111101;
			4'h7: get_segments = 7'b0000111;
			4'h8: get_segments = 7'b1111111;
			4'h9: get_segments = 7'b1101111;
			4'ha: get_segments = 7'b1110111;
			4'hb: get_segments = 7'b1111100;
			4'hc: get_segments = 7'b0111001;
			4'hd: get_segments = 7'b1011110;
			4'he: get_segments = 7'b1111001;
			4'hf: get_segments = 7'b1110001;
			endcase
		end
	endfunction
	
	assign segments = get_segments(digit);
endmodule
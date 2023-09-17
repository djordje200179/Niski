module cpu_alignment_checker (
	input [1:0] addr_offset,
	input [3:0] mask,

	output reg overflow
);
	always @* begin
		overflow = 1'b0;

		case (addr_offset)
		2'b01: begin
			if (mask[3:1])
				overflow = 1'b1;
		end
		2'b10: begin
			if (|mask[3:2])
				overflow = 1'b1;
		end
		2'b11: begin
			if (|mask[3:1])
				overflow = 1'b1;
		end
		endcase
	end

endmodule
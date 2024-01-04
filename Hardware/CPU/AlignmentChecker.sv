module cpu_alignment_checker (
	input [1:0] addr_offset,
	input [3:0] mask,

	output logic overflow
);
	always_comb begin
		unique case (addr_offset)
		0: overflow = 0;
		1: begin
			if (mask[3:1])
				overflow = 1;
		end
		2: begin
			if (|mask[3:2])
				overflow = 1;
		end
		3: begin
			if (|mask[3:1])
				overflow = 1;
		end
		endcase
	end
endmodule
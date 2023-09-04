module cpu_csrs (
	input clk, rst,

	input [11:0] addr,

	input [31:0] data_in,
	output reg [31:0] data_out,
	input wr, incr_inst_count
);
	localparam CYCLE_ADDR = 12'hC00,
			   CYCLEH_ADDR = 12'hC80,
			   TIME_ADDR = 12'hC01,
			   TIMEH_ADDR = 12'hC81,
			   INSTRET_ADDR = 12'hC02,
			   INSTRETH_ADDR = 12'hC82;

	reg [63:0] CYCLE = 64'h0,
			   TIME, INSTRET;

	always @* begin
		data_out = 32'b0;

		case (addr)
		CYCLE_ADDR:     data_out = CYCLE[31:0];
		CYCLEH_ADDR:    data_out = CYCLE[63:32];
		TIME_ADDR:      data_out = TIME[31:0];
		TIMEH_ADDR:     data_out = TIME[63:32];
		INSTRET_ADDR:   data_out = INSTRET[31:0];
		INSTRETH_ADDR:  data_out = INSTRET[63:32];
		endcase
	end

	task reset;
		begin
			TIME <= 64'h0;
			INSTRET <= 64'h0;
		end
	endtask

	task on_clock;
		begin
			if (wr) begin
				// case (addr)
				// endcase
			end

			CYCLE <= CYCLE + 32'b1;
			TIME <= TIME + 32'b1;

			if (incr_inst_count)
				INSTRET <= INSTRET + 32'b1;
		end
	endtask

	always @(posedge clk or posedge rst) begin 
		if (rst) reset;
		else on_clock;
	end
endmodule
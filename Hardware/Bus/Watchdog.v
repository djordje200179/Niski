module watchdog #(
	parameter ALLOWED_SECONDS = 1.0
) (
	input clk, rst,
	
	input rd_bus, wr_bus, fc_bus,

	output access_timeout
);
	localparam integer ALLOWED_CYCLES = ALLOWED_SECONDS * 50_000_000;

	reg [$clog2(ALLOWED_CYCLES)-1:0] counter;

	reg [1:0] state;
	localparam STATE_IDLE 		= 2'd0,
			   STATE_COUNTING	= 2'd1,
			   STATE_NOTIFYING	= 2'd2;

	assign access_timeout = state == STATE_NOTIFYING;

	task reset;
		begin
			counter <= 0;
			state <= STATE_IDLE;
		end
	endtask

	task on_clock;
		begin
			case (state)
			STATE_IDLE: begin
				if (rd_bus || wr_bus)
					state <= STATE_COUNTING;
			end
			STATE_COUNTING: begin
				if (fc_bus) begin
					counter <= 0;
					state <= STATE_IDLE;
				end else if (counter == ALLOWED_CYCLES)
					state <= STATE_NOTIFYING;
				else
					counter <= counter + 1;
			end
			STATE_NOTIFYING: begin
				if (!rd_bus && !wr_bus) begin
					counter <= 1;
					state <= STATE_IDLE;
				end
			end
			endcase
		end
	endtask

	always @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end
endmodule
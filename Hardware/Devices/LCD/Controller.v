module lcd_controller (
	input clk, rst,

	output rs_pin, e_pin, rw_pin,
	output [7:0] data_pins,

	input [7:0] data_in, 
	input data_is_cmd, data_req, 
	output data_ack
);
	reg [1:0] state;
	localparam STATE_IDLE 		= 2'b00,
			   STATE_HOLDING_RS = 2'b01,
			   STATE_HOLDING_E	= 2'b10,
			   STATE_WAITING	= 2'b11;

	reg [16:0] counter;
	localparam RS_HOLD_TIME		= 17'd1_000,
			   E_HOLD_TIME		= 17'd1_000,
			   SHORT_WAIT_TIME	= 17'd5_000,
			   LONG_WAIT_TIME	= 17'd110_000;

	reg [7:0] data;
	reg is_cmd;
	reg completed;

	reg [16:0] delay;

	assign rs_pin = ~is_cmd;
	assign rw_pin = 1'b0;
	assign e_pin = state == STATE_HOLDING_E;
	assign data_pins = data;

	assign data_ack = state == STATE_WAITING && !completed;

	always @* begin
		delay = SHORT_WAIT_TIME;

		if (is_cmd && ~|data[7:2])
			delay = LONG_WAIT_TIME;
	end

	task reset;
		begin
			state <= STATE_IDLE;
			counter <= 17'b0;
			data <= 8'b0;
			is_cmd <= 1'b0;
			completed <= 1'b0;
		end
	endtask

	task on_clock;
		begin
			case (state)
			STATE_IDLE: begin
				if (data_req) begin
					data <= data_in;
					is_cmd <= data_is_cmd;
					state <= STATE_HOLDING_RS;
				end
			end
			STATE_HOLDING_RS: begin
				if (counter == RS_HOLD_TIME) begin
					state <= STATE_HOLDING_E;
					counter <= 17'b0;
				end else
					counter <= counter + 1'b1;
			end
			STATE_HOLDING_E: begin
				if (counter == E_HOLD_TIME) begin
					counter <= 17'b0;
					state <= STATE_WAITING;
				end else
					counter <= counter + 1'b1;
			end
			STATE_WAITING: begin
				if (counter == delay) begin
					if (completed) begin
						state <= STATE_IDLE;
						completed <= 1'b0;
						counter <= 16'b0;
					end
				end else
					counter <= counter + 1'b1;
				
				if (!data_req)
					completed <= 1'b1;
			end
			endcase
		end
	endtask

	always @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end
endmodule
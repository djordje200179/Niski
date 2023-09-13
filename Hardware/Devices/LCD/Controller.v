module lcd_controller (
	input clk, rst,

	output rs_pin, e_pin, rw_pin,
	output [7:0] data_pins,

	input [7:0] data_in, 
	input data_is_cmd, data_req, 
	output data_ack
);
	reg [1:0] state;
	localparam STATE_IDLE = 2'b00,
			   STATE_WAITING = 2'b01,
			   STATE_DONE = 2'b10;

	reg [16:0] counter;

	reg [7:0] data;
	reg is_cmd;

	assign rs_pin = ~is_cmd;
	assign rw_pin = 1'b0;
	assign e_pin = (state == STATE_WAITING);
	assign data_pins = data;

	assign data_ack = (state == STATE_DONE);

	task reset;
		begin
			state <= STATE_IDLE;
			counter <= 16'b0;
			data <= 8'b0;
			is_cmd <= 1'b0;
		end
	endtask

	task on_clock;
		begin
			case (state)
			STATE_IDLE: begin
				if (data_req) begin
					data <= data_in;
					is_cmd <= data_is_cmd;
					state <= STATE_WAITING;
					counter <= 17'b0;
				end
			end
			STATE_WAITING: begin
				if (counter == 17'b11111111111111111)
					state <= STATE_DONE;
				else
					counter <= counter + 1'b1;
			end
			STATE_DONE: begin
				if (!data_req)
					state <= STATE_IDLE;
			end
			endcase
		end
	endtask

	always @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end
endmodule
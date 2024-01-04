module lcd_controller (
	input clk, rst,

	output logic rs_pin, e_pin, rw_pin,
	inout [7:0] data_pins,

	input [7:0] data_in, 
	input data_is_cmd, data_req, 
	output data_ack
);
	enum {STATE_IDLE, STATE_WAIT, STATE_WRITE, STATE_DONE} state;

	reg [7:0] counter;
	localparam HOLD_TIME = 150;

	reg [7:0] data;
	reg is_cmd;

	always_comb begin
		rs_pin = 0;
		rw_pin = 0;

		case (state)
		STATE_WAIT: begin
			rs_pin = 0;
			rw_pin = 1;
		end
		STATE_WRITE: begin
			rs_pin = !is_cmd;
			rw_pin = 0;
		end
		endcase
	end

	always_comb begin
		e_pin = 0;

		case (state)
		STATE_WAIT, STATE_WRITE: e_pin = 1;
		endcase
	end

	assign data_pins = state == STATE_WRITE ? data : 'z;

	wire [7:0] status = data_pins;
	wire is_busy = status[7];

	assign data_ack = state == STATE_DONE;

	task automatic reset;
		begin
			state <= STATE_IDLE;
			counter <= 0;
		end
	endtask

	task automatic on_clock;
		begin
			unique case (state)
			STATE_IDLE: begin
				if (data_req) begin
					data <= data_in;
					is_cmd <= data_is_cmd;
					state <= STATE_WAIT;
				end
			end
			STATE_WAIT: begin
				if (counter == HOLD_TIME) begin
					if (!is_busy) begin
						state <= STATE_WRITE;
						counter <= 0;
					end
				end else
					counter <= counter + 1;
			end
			STATE_WRITE: begin
				if (counter == HOLD_TIME) begin
					state <= STATE_DONE;
					counter <= 0;
				end else
					counter <= counter + 1;
			end
			STATE_DONE: begin
				if (!data_req)
					state <= STATE_IDLE;
			end
			endcase
		end
	endtask
	
	always_ff @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end
endmodule
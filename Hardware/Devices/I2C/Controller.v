module i2c_controller (
	clk, rst, en, 
    data_req, data_wr, data_addr, data_bytes, data, data_ack,
	data_pin, clk_pin
);
	input clk, rst, en;

    input data_req, data_wr;
    input [5:0] data_addr;
    input [2:0] data_bytes;
    inout [7:0] data;
    output data_ack;

    inout data_pin;
    output clk_pin;

    reg data_out, data_out_en;
    assign data_pin = data_out_en ? data_out : 1'bz;

    reg i2c_clk_activated;
    frequency_divider#(500) clk_generator (
        .clk(clk),
        .rst(rst),
        .slow_clk(clk_pin)
    );

    `include "States.vh"
	reg [2:0] state;

    task reset;
		begin
			state <= STATE_IDLE;
            i2c_clk_activated <= 1'b0;
		end
	endtask
	
	task on_clock;
		begin
			// case (state)
                
            // endcase
		end
	endtask
	
	always @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end
endmodule
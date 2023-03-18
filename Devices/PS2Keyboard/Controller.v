module ps2_keyboard_controller (
	clk, rst, en, 
	data_req, data, data_err, data_ack, 
	data_pin, clk_pin
);
	input clk, rst, en;
	
	input data_req;
	output reg [7:0] data;
	output reg data_err;
	output reg data_ack;
	
	input data_pin, clk_pin;
	
	reg [10:0] incoming_data;
	wire incoming_data_valid = ^incoming_data[9:1];
	
	wire all_bits_received;
	counter#(12) bit_counter (
		.clk(~clk_pin),
		.en(1),
		.rst(rst || data_ack),
		.will_overflow(all_bits_received)
	);
	
	always @(negedge clk_pin) begin
		incoming_data <= { data_pin, incoming_data[10:1] };
	end

	reg data_ready;
	
	task save_data;
		begin
			data <= incoming_data[8:1];
			data_err <= ~incoming_data_valid;
			data_ready <= 1'b1;
		end
	endtask

	task send_data;
		begin
			data_ready <= 1'b0;
			data_ack <= 1'b1;
		end
	endtask
	
	task reset;
		begin
			data <= 8'b0;
			data_err <= 1'b0;
			data_ack <= 1'b0;
			data_ready <= 1'b1;
		end
	endtask
	
	task on_clock;
		begin
			if(all_bits_received)
				save_data;

			if(data_ready && data_req)
				send_data;
					
			if(data_ack)
				data_ack <= 1'b0;
		end
	endtask
	
	always @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end
endmodule
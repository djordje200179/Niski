module ir_controller (
	clk, rst, en, 
	data_req, data, data_ack, 
	data_pin
);
	input clk, rst, en;
	
	input data_req;
	output [7:0] data;
	output data_ack;
	
	input data_pin;

endmodule
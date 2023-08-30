module uart_tx_controller (
	clk, rst, en,
	tx_data_req, tx_data, tx_data_ack,
	tx_pin 
);
	parameter BAUD_RATE = 9600;
	
	input clk, rst, en;
	
	input tx_data_req;
	input [7:0] tx_data;
	output tx_data_ack;
	
	output tx_pin;
endmodule
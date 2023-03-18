module uart_rx_controller (
	clk, rst, en,
	rx_data_req, rx_data, rx_data_ack,
	rx_pin 
);
	parameter BAUD_RATE = 9600;
	
	input clk, rst, en;
	
	input rx_data_req;
	output [7:0] rx_data;
	output rx_data_ack; 
	
	input rx_pin;
endmodule
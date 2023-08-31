module uart_controller (
	clk, rst, en,
	rx_data_req, rx_data, rx_data_ack,
	tx_data_req, tx_data, tx_data_ack,
	rx_pin, tx_pin 
);
	parameter BAUD_RATE = 9600;
	
	input clk, rst, en;
	
	input rx_data_req;
	output [7:0] rx_data;
	output rx_data_ack; 
	
	input tx_data_req;
	input [7:0] tx_data;
	output tx_data_ack;
	
	input rx_pin;
	output tx_pin;
	
	uart_rx_controller #(BAUD_RATE) rx_controller (
		.clk(clk), .rst(rst), .en(en),
		.rx_data_req(rx_data_req), .rx_data(rx_data), .rx_data_ack(rx_data_ack),
		.rx_pin(rx_pin)
	);
	
	uart_tx_controller #(BAUD_RATE) tx_controller (
		.clk(clk), .rst(rst), .en(en),
		.tx_data_req(tx_data_req), .tx_data(tx_data), .tx_data_ack(tx_data_ack),
		.tx_pin(tx_pin)
	);
endmodule
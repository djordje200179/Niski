module leds_controller (
	en, 
	led0, led1, led2, led3, 
	led_pins
);
	input en;
	
	input led0, led1, led2, led3;
	
	output [3:0] led_pins;
	
	assign led_pins = en ? ~{led3, led2, led1, led0} : 4'b1111;
endmodule
module leds_controller (
	input en, led0, led1, led2, led3, 
	output [3:0] led_pins
);	
	assign led_pins = en ? ~{led3, led2, led1, led0} : 'z;
endmodule
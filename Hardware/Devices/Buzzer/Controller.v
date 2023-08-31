module buzzer_controller (
	en, 
	buzz, 
	buzzer_pin
);	
	input en;
	
	input buzz;
	
	output buzzer_pin;
	
	assign buzzer_pin = en ? ~buzz : 1'b1;
endmodule
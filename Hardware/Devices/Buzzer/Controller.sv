module buzzer_controller (
	input en, buzz, 

	output buzzer_pin
);
	assign buzzer_pin = en ? ~buzz : 1;
endmodule
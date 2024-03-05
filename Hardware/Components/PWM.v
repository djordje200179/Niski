module PWM(
	CLK, RST, EN, 
	activeTime, modulatedOutput
);
	parameter PRECISION_BITS = 8;
	
	localparam MAX_VALUE = 2 ** PRECISION_BITS;
	
	input CLK, RST, EN;
	input [PRECISION_BITS-1:0] activeTime;
	
	output wire modulatedOutput;
	
	reg state;
	wire [PRECISION_BITS-1:0] currValue;
	
	Counter #(MAX_VALUE) counter (
		.CLK(CLK),
		.EN(EN),
		.RST(RST),
		.value(currValue)
	);
	
	task updateState;		
		begin
			if (currValue == activeTime)
				state = 1'b1;
			else if (currValue == 0)
				state = 1'b0;
		end
	endtask
	
	task onReset;
		begin
			state <= 1'b0;
		end
	endtask
	
	task onClock;
		begin
			if (EN)
			updateState();
		end
	endtask
	
	always @(posedge CLK or posedge RST) begin
		if (RST) onReset;
		else onClock;
	end
	
	assign modulatedOutput = EN ? state : 1'b0;
endmodule
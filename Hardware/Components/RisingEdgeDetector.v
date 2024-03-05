module rising_edge_detector (
	input clk, rst, 
	
	input raw_input, 
	output rising_edge
);	
	reg old_value, curr_value;
	
	assign rising_edge = ~old_value && curr_value;
	
	task reset;
		begin
			old_value <= 1'b0;
			curr_value <= 1'b0;
		end
	endtask
	
	task on_clock;
		begin
			old_value <= curr_value;
			curr_value <= raw_input;
		end
	endtask
	
	always @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end
endmodule
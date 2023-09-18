module interrupt_splitter (
	input ps2_incoming_data, uart_incoming_data, ir_incoming_data, btn_pressed,

	output [15:0] requests
);
	parameter PS2_INTR_CODE = 4'd0,
			  UART_INTR_CODE = 4'd1,
			  IR_INTR_CODE = 4'd2,
			  BTN_INTR_CODE = 4'd3;

	generate
		genvar i;
		for (i = 0; i < 16; i = i + 1) begin : request_connection
			case (i)
			PS2_INTR_CODE:	assign requests[i] = ps2_incoming_data;
			UART_INTR_CODE:	assign requests[i] = uart_incoming_data;
			IR_INTR_CODE:	assign requests[i] = ir_incoming_data;
			BTN_INTR_CODE:	assign requests[i] = btn_pressed;
			default: assign requests[i] = 1'b0;
			endcase
		end
	endgenerate
endmodule
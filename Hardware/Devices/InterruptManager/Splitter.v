module interrupt_splitter (
	input ps2_incoming_data, uart_incoming_data, ir_incoming_data, 
	input btn_0_pressed, btn_1_pressed, btn_2_pressed, btn_3_pressed,

	output [15:1] requests
);
	parameter PS2_INTR_CODE = 4'd1,
			  UART_INTR_CODE = 4'd2,
			  IR_INTR_CODE = 4'd3,
			  BTN_0_INTR_CODE = 4'd4,
			  BTN_1_INTR_CODE = 4'd5,
			  BTN_2_INTR_CODE = 4'd6,
			  BTN_3_INTR_CODE = 4'd7;

	generate
		genvar i;
		for (i = 1; i < 16; i = i + 1) begin : request_connection
			case (i)
			PS2_INTR_CODE:	assign requests[i] = ps2_incoming_data;
			UART_INTR_CODE:	assign requests[i] = uart_incoming_data;
			IR_INTR_CODE:	assign requests[i] = ir_incoming_data;
			BTN_0_INTR_CODE: assign requests[i] = btn_0_pressed;
			BTN_1_INTR_CODE: assign requests[i] = btn_1_pressed;
			BTN_2_INTR_CODE: assign requests[i] = btn_2_pressed;
			BTN_3_INTR_CODE: assign requests[i] = btn_3_pressed;
			default: assign requests[i] = 1'b0;
			endcase
		end
	endgenerate
endmodule
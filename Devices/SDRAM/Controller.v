module sdram_controller(
	clk, rst, en, 
	data_req, data_wr, data_addr, data, data_ack, 
	data_pins, addr_pins, bank_pins, mask_pins, cke_pin, clk_pin, cs_pin, ras_pin, cas_pin, we_pin
);
	input clk, rst, en;
	
	input data_req, data_wr;
	input [15:0] data_addr;
	inout [15:0] data;
	output data_ack;
	
	inout [15:0] data_pins;
	output reg [11:0] addr_pins;
	output reg [1:0] bank_pins;
	output reg [1:0] mask_pins;
	output cke_pin, clk_pin, cs_pin, ras_pin, cas_pin, we_pin;
	
	assign cke_pin = 1'b1;
	assign clk_pin = clk;
	assign cs_pin = 1'b1;
	
	`include "States.vh"
	reg [2:0] state;
	
	localparam OP_READ	= 1'b0,
			   OP_WRITE	= 1'b1;
	reg selected_operation;
	
	
	`include "Commands.vh"
	reg [2:0] selected_command;
	assign {ras_pin, cas_pin, we_pin} = selected_command;
	
	task reset;
		begin
			state <= STATE_IDLE;
			selected_command <= CMD_NOOP;
		end
	endtask
	
	task on_clock;
		begin
			case (state)
			STATE_IDLE: begin
				
			end
			STATE_OPENING_ROW: begin
				
			end
			STATE_CLOSING_ROW: begin
				
			end
			STATE_READING: begin
			
			end
			STATE_WRITING: begin
			
			end
			STATE_REFRESHING: begin
			
			end
			endcase
		end
	endtask
	
	always @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end
endmodule
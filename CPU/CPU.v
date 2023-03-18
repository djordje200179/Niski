module cpu (
	clk, rst,
	bus_req, bus_grant,
	addr_bus, data_bus, wr_bus, rd_bus, fc_bus
);
	parameter EXEC_START_ADDR = 0;

	input clk, rst;

	output reg bus_req;
	input bus_grant;

	output [31:0] addr_bus;
	inout [7:0] data_bus;
	output wr_bus, rd_bus;
	input fc_bus;

	reg [31:0] mar;
	reg [7:0] mdr;

	reg wr_req, rd_req;

	assign addr_bus = bus_req ? mar : 32'bz,
		   data_bus = (bus_req && wr_req) ? mdr : 8'bz,
		   wr_bus = bus_req ? wr_req : 1'bz,
		   rd_bus = bus_req ? rd_req : 1'bz;
	
	cpu_reg_file#(32, 16) gpr_file (
		.clk(clk), .en(1'b1)
	);

	reg [31:0] pc;
	reg [32:0] ir;

	`include "States.vh"
	reg [4:0] state;

	task reset;
		begin
			pc <= EXEC_START_ADDR;
			state <= STATE_IDLE;
			
			bus_req <= 1'b0;
			wr_req <= 1'b0;
			rd_req <= 1'b0;
		end
	endtask

	reg [1:0] counter;

	task on_clock;
		begin
			case (state)
			STATE_IDLE: begin
				state <= STATE_WAITING_BUS_GRANT;
			end
			STATE_WAITING_BUS_GRANT: begin
				bus_req <= 1'b1;

				if (bus_grant) begin
					state <= STATE_WAITING_DATA;

					mar <= pc;
					rd_req <= 1'b1;
					counter <= 2'd3;
				end
			end
			STATE_WAITING_DATA: begin
				if (fc_bus) begin
					mdr <= data_bus;
					state <= STATE_ACCEPTED_DATA;
					rd_req <= 1'b0;
				end
			end
			STATE_ACCEPTED_DATA: begin
				ir <= {ir[31:8], mdr};
				pc <= pc + 1'b1;

				if (counter == 2'd0) begin
					state <= STATE_IDLE;
				end else begin
					state <= STATE_WAITING_DATA;
					
					mar <= mar + 1'b1;
					rd_req <= 1'b1;

					counter <= counter - 1'b1;
				end
			end
			endcase
		end
	endtask

	always @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end	
endmodule
module cpu_memory_access (
	input clk, rst,
	
	output reg bus_req,
	input bus_grant,

	output [31:0] addr_bus,
	inout [31:0] data_bus,
	output rd_bus, wr_bus,
	output [3:0] data_mask_bus,
	input fc_bus,

	input wr_req, rd_req,
	input [31:0] addr,
	input [31:0] data_out,
	output reg [31:0] data_in,
	input [3:0] data_mask,
	output done
);
	localparam STATE_WAITING_REQ = 2'd0,
			   STATE_WAITING_BUS = 2'd1,
			   STATE_WAITING_ACK = 2'd2,
			   STATE_DONE = 2'd3;

	reg [1:0] state;

	reg [31:0] mar, mdr;
	reg [3:0] mdr_mask;
	reg is_wr;

	assign addr_bus = bus_grant ? mar : 32'bz,
		   data_bus = bus_grant && wr_req ? mdr: 32'bz,
		   rd_bus = bus_grant ? !is_wr : 1'bz,
		   wr_bus = bus_grant ? is_wr : 1'bz,
		   data_mask_bus = bus_grant ? mdr_mask : 4'bz;

	assign done = state == STATE_DONE;

	task reset;
		begin
			state <= STATE_WAITING_REQ;
		end
	endtask

	task on_clock;
		begin
			case (state)
			STATE_WAITING_REQ: begin
				if (rd_req || wr_req) begin
					state <= STATE_WAITING_BUS;
					
					bus_req <= 1'b1;
					mar <= addr;
					mdr_mask <= data_mask;
					if (wr_req)
						mdr <= data_out;
					is_wr <= wr_req;
				end
			end
			STATE_WAITING_BUS: begin
				if (bus_grant)
					state <= STATE_WAITING_ACK;
			end
			STATE_WAITING_ACK: begin
				if (fc_bus) begin
					state <= STATE_DONE;

					bus_req <= 1'b0;
					if (!is_wr)
						data_in <= mdr;
				end
			end
			STATE_DONE: begin
				if (!rd_req && !wr_req)
					state <= STATE_WAITING_REQ;
			end
			endcase
		end
	endtask

	always @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end	
endmodule
module bus_arbitrator (
	clk, rst,
	cpu_req, dma_req,
	cpu_grant, dma_grant,
	addr_bus, data_bus, wr_bus, rd_bus, data_mask_bus, fc_bus
);
	input clk, rst;

	input cpu_req, dma_req;
	output cpu_grant, dma_grant;

	output [31:0] addr_bus;
	output [31:0] data_bus;
	output wr_bus, rd_bus;
	output [3:0] data_mask_bus;
	output fc_bus;	

	`include "States.vh"
	reg [1:0] state;

	assign cpu_grant = state == STATE_CPU;
	assign dma_grant = state == STATE_DMA;

	task reset;
		begin
			state <= STATE_IDLE;
		end
	endtask

	task on_clock;
		begin
			case (state)
			STATE_IDLE: begin
				if (cpu_req)
					state <= STATE_CPU;
				else if (dma_req)
					state <= STATE_DMA;
			end
			STATE_CPU: begin
				if (!cpu_req)
					if (dma_req)
						state <= STATE_DMA;
					else
						state <= STATE_IDLE;
			end
			STATE_DMA: begin
				if (!dma_req)
					if (cpu_req)
						state <= STATE_CPU;
					else
						state <= STATE_IDLE;
			end
			endcase
		end
	endtask

	always @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end

	wire bus_used = state != STATE_IDLE;
	
	assign addr_bus = bus_used ? 32'bz : 32'b0;
	assign data_bus = bus_used ? 32'bz : 32'b0;
	assign wr_bus = bus_used ? 1'bz : 1'b0;
	assign rd_bus = bus_used ? 1'bz : 1'b0;
	assign data_mask_bus = bus_used ? 4'bz : 4'b0;
	assign fc_bus = bus_used ? 1'bz : 1'b0;
endmodule
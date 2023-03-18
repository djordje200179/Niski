module bus_arbitrator (
	clk, rst,
	cpu_req, dma_req,
	cpu_grant, dma_grant,
	addr_bus, data_bus, wr_bus, rd_bus, fc_bus
);
	parameter ADDR_BUS_WIDTH = 32,
			  DATA_BUS_WIDTH = 8;

	input clk, rst;

	input cpu_req, dma_req;
	output cpu_grant, dma_grant;

	output [ADDR_BUS_WIDTH-1:0] addr_bus;
	output [DATA_BUS_WIDTH-1:0] data_bus;
	output wr_bus, rd_bus, fc_bus;	

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
	
	assign addr_bus = {ADDR_BUS_WIDTH{bus_used ? 1'bz : 1'b0}};
	assign data_bus = {DATA_BUS_WIDTH{bus_used ? 1'bz : 1'b0}};
	assign wr_bus = bus_used ? 1'bz : 1'b0;
	assign rd_bus = bus_used ? 1'bz : 1'b0;
	assign fc_bus = bus_used ? 1'bz : 1'b0;
endmodule
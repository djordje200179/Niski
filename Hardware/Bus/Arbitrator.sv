module bus_arbitrator (
	input clk, rst,
	
	input cpu_req, dma_req,
	output cpu_grant, dma_grant,
	
	output [31:0] addr_bus, data_bus,
	output wr_bus, rd_bus,
	output [3:0] data_mask_bus,
	output fc_bus
);
	enum {STATE_IDLE, STATE_CPU, STATE_DMA} state;

	assign cpu_grant = cpu_req && (!dma_req || state != STATE_DMA);
	assign dma_grant = dma_req && (!cpu_req || state == STATE_DMA);
	
	wire bus_used = cpu_grant || dma_grant;
	
	assign addr_bus = bus_used ? 'z : '0;
	assign data_bus = bus_used ? 'z : '0;
	assign wr_bus = bus_used ? 'z : 0;
	assign rd_bus = bus_used ? 'z : 0;
	assign data_mask_bus = bus_used ? 'z : '0;
	assign fc_bus = bus_used ? 'z : 0;

	task automatic reset;
		begin
			state <= STATE_IDLE;
		end
	endtask

	task automatic on_clock;
		begin
			unique case (state)
			STATE_IDLE: begin
				if (cpu_req)
					state <= STATE_CPU;
				else if (dma_req)
					state <= STATE_DMA;
			end
			STATE_CPU: begin
				if (!cpu_req) begin
					if (dma_req)
						state <= STATE_DMA;
					else
						state <= STATE_IDLE;
				end
			end
			STATE_DMA: begin
				if (!dma_req) begin
					if (cpu_req)
						state <= STATE_CPU;
					else
						state <= STATE_IDLE;
				end
			end
			endcase
		end
	endtask

	always_ff @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end
endmodule
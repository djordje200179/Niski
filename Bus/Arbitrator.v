module bus_arbitrator (
	input clk, rst,
	
	input cpu_req, dma_req,
	output cpu_grant, dma_grant,
	
	output [31:0] addr_bus, data_bus,
	output wr_bus, rd_bus,
	output [3:0] data_mask_bus,
	output fc_bus
);
	reg [1:0] state;
	localparam STATE_IDLE	= 2'd0,
			   STATE_CPU	= 2'd1,
			   STATE_DMA	= 2'd2;

	assign cpu_grant = state == STATE_CPU;
	assign dma_grant = state == STATE_DMA;
	
	wire bus_used = state != STATE_IDLE;
	
	assign addr_bus = bus_used ? 32'bz : 32'b0;
	assign data_bus = bus_used ? 32'bz : 32'b0;
	assign wr_bus = bus_used ? 1'bz : 1'b0;
	assign rd_bus = bus_used ? 1'bz : 1'b0;
	assign data_mask_bus = bus_used ? 4'bz : 4'b0;
	assign fc_bus = bus_used ? 1'bz : 1'b0;

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
endmodule
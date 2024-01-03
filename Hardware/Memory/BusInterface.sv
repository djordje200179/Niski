module memory_bus_interface #(MEM_ADDR_WIDTH = 16, START_ADDR = 0) (
	input clk, rst,

	output [MEM_ADDR_WIDTH-1:0] mem_addr, 
	input [31:0] mem_data_out, 
	output [31:0] mem_data_in, 
	output mem_wr, 
	output [3:0] mem_wr_mask,

	input [31:0] addr_bus,
	inout [31:0] data_bus,
	input wr_bus, rd_bus,
	input [3:0] data_mask_bus,
	output fc_bus
);
	localparam MEM_SIZE = 2 ** MEM_ADDR_WIDTH * 4;

	wire addr_hit = (addr_bus >= START_ADDR) && (addr_bus < START_ADDR + MEM_SIZE);
	wire req_valid = rd_bus ^ wr_bus;
		 
	wire req = addr_hit && req_valid,
	 	 read_req = req && rd_bus,
	 	 write_req = req && wr_bus;

	enum { STATE_IDLE, STATE_DONE } state;

	assign data_bus = read_req ? mem_data_out >> (addr_bus[1:0] * 8) : 'z,
		   fc_bus = req ? (state == STATE_DONE) : 'z;

	assign mem_addr = (addr_bus - START_ADDR) >> 2,
		   mem_data_in = data_bus << (addr_bus[1:0] * 8),
		   mem_wr = write_req,
		   mem_wr_mask = data_mask_bus << addr_bus[1:0];

	task automatic reset;
		begin
			state <= STATE_IDLE;
		end
	endtask

	task automatic on_clock;
		begin
			unique case (state)
			STATE_IDLE: begin
				if (req)
					state <= STATE_DONE;
			end
			STATE_DONE: begin
				if (!req)
					state <= STATE_IDLE;
			end
			endcase
		end
	endtask

	always_ff @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end
endmodule
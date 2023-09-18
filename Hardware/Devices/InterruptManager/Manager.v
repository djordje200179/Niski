module interrupt_manager (
	input clk, rst,

	input [31:0] addr_bus, 
	inout [31:0] data_bus, 
	input rd_bus, wr_bus,
	input [3:0] data_mask_bus, 
	output fc_bus,

	input [15:0] intr_reqs,
	output has_req
);
	parameter PENDING_INTR_REG_ADDR	= 32'h0,
			  ENABLE_INTR_REG_ADDR	= 32'h4,
			  CLAIM_INTR_REG_ADDR	= 32'h8;
			  
	reg [15:0] pending_intr_reg;
	reg [15:0] enable_intr_reg;

	task get_claimable_intr (output [3:0] intr_code);
		integer i;
		begin
			for (i = 0; i < 16; i = i + 1) begin
				if (pending_intr_reg[i] && enable_intr_reg[i])
					intr_code = i;
			end
		end
	endtask

	`include "../BusInterfaceHelper.vh"

	reg addr_hit;
	always @* begin
		addr_hit = 1'b0;

		case (addr_base)
		PENDING_INTR_REG_ADDR,
		ENABLE_INTR_REG_ADDR,
		CLAIM_INTR_REG_ADDR:    
			addr_hit = 1'b1;
		endcase
	end

	wire req_valid = rd_bus ^ wr_bus;

	wire req = addr_hit && req_valid,
		 read_req = req && rd_bus,
		 write_req = req && wr_bus;

	reg [31:0] data_out;
	always @* begin
		case (addr_base)
		PENDING_INTR_REG_ADDR:	data_out = pending_intr_reg;
		ENABLE_INTR_REG_ADDR: 	data_out = enable_intr_reg;
		CLAIM_INTR_REG_ADDR: 	begin
			if (|intr_reqs)
				get_claimable_intr(data_out);
			else
				data_out = 32'hffffffff;
		end
		default: data_out = 32'b0;
		endcase

		data_out = data_out >> (8 * addr_offset);
	end

	reg data_written;
	assign data_bus = read_req ? data_out : 32'bz,
		   fc_bus = req ? (read_req || data_written) : 1'bz;

	task register_interrupt;
		integer i;
		begin
			for (i = 0; i < 16; i = i + 1) begin
				if (intr_reqs[i] && enable_intr_reg[i])
					pending_intr_reg[i] <= 1'b1;
			end
		end
	endtask

	assign has_req = |pending_intr_reg;

	task reset;
		begin
			data_written <= 1'b0;

			pending_intr_reg <= 32'b0;
			enable_intr_reg <= 32'b0;
		end
	endtask

	task on_clock;
		begin
			if (data_written && !write_req)
				data_written <= 1'b0;
			else if (write_req) begin
				data_written <= 1'b1;

				case (addr_base)
				PENDING_INTR_REG_ADDR:	update_reg(pending_intr_reg);
				ENABLE_INTR_REG_ADDR:	update_reg(enable_intr_reg);
				endcase
			end else if (read_req && addr_base == CLAIM_INTR_REG_ADDR) begin // TODO: check offseted addreses
				if (data_out != 32'hffffffff)
					pending_intr_reg[data_out[3:0]] <= 1'b0;
			end
		end
	endtask

	always @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end
endmodule
module buttons_bus_interface (
	input clk, rst,

	input btn_0, btn_1, btn_2, btn_3,
	output interrupt,

	input [31:0] addr_bus, 
	inout [31:0] data_bus, 
	input rd_bus, wr_bus, 
	input [3:0] data_mask_bus, 
	output fc_bus
);
	parameter CTRL_REG_ADDR	= 32'h0,
			  DATA_REG_ADDR	= 32'h4;

	reg [7:0] ctrl_reg;
	reg [31:0] data_reg;

	assign interrupt = data_reg[24] | data_reg[16] | data_reg[8] | data_reg[0];

	`include "../BusInterfaceHelper.vh"

	reg addr_hit;
	always @* begin
		addr_hit = 1'b0;

		case (addr_base)
		CTRL_REG_ADDR,
		DATA_REG_ADDR:    
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
		CTRL_REG_ADDR:	data_out = ctrl_reg;
		DATA_REG_ADDR: 	data_out = data_reg;
		default: data_out = 32'b0;
		endcase

		data_out = data_out >> (8 * addr_offset);
	end

	reg data_written;
	assign data_bus = read_req ? data_out : 32'bz,
		   fc_bus = req ? (read_req || data_written) : 1'bz;

	task reset;
		begin
			data_written <= 1'b0;

			ctrl_reg <= 8'b0;
			data_reg <= 32'b0;
		end
	endtask

	task on_clock;
		begin
			if (data_written && !wr_bus)
				data_written <= 1'b0;
			else if (write_req) begin
				data_written <= 1'b1;

				case (addr_base)
				CTRL_REG_ADDR:	ctrl_reg <= data_bus;
				endcase
			end

			if (btn_0) data_reg[24] <= 1'b1;
			if (btn_1) data_reg[16] <= 1'b1;
			if (btn_2) data_reg[8] <= 1'b1;
			if (btn_3) data_reg[0] <= 1'b1;
		end
	endtask

	always @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end
endmodule
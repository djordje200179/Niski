module ssds_bus_interface (
	input clk, rst,

    output ctrl_en, 
	output [6:0] ctrl_digit_0, ctrl_digit_1, ctrl_digit_2, ctrl_digit_3, 
	output [3:0] ctrl_dots,

	input [31:0] addr_bus, 
	inout [31:0] data_bus, 
	input rd_bus, wr_bus, 
	input [3:0] data_mask_bus, 
	output fc_bus
);
	parameter CTRL_REG_ADDR			= 32'h0,
			  DATA_DIGITS_REG_ADDR	= 32'h4,
			  DATA_DOTS_REG_ADDR 	= 32'h8;

	reg [7:0] ctrl_reg;
	reg [31:0] data_digits_reg;
	reg [7:0] data_dots_reg;

	wire [27:0] segments;
	assign {ctrl_digit_3, ctrl_digit_2, ctrl_digit_1, ctrl_digit_0} = segments;

	assign ctrl_dots = data_dots_reg[3:0];
	assign ctrl_en = ctrl_reg[0];

	wire [6:0] digits_mapped_segments [0:3];
	generate
		genvar i;
		for (i = 0; i < 4; i = i + 1) begin: digit_mappers
			ssds_digit_mapper digit_mapper (
				.digit(data_digits_reg[8 * i +: 4]),
				.segments(digits_mapped_segments[i])
			);

			assign segments[7 * i +: 7] = data_digits_reg[8 * i + 7] ? digits_mapped_segments[i] : data_digits_reg[8 * i +: 7];
		end
	endgenerate
	
	`include "../BusInterfaceHelper.vh"

	reg addr_hit;
	always @* begin
		addr_hit = 1'b0;

		case (addr_base)
		CTRL_REG_ADDR,
		DATA_DIGITS_REG_ADDR,
		DATA_DOTS_REG_ADDR:    
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
		CTRL_REG_ADDR:			data_out = ctrl_reg;
		DATA_DIGITS_REG_ADDR:	data_out = data_digits_reg;
		DATA_DOTS_REG_ADDR:		data_out = data_dots_reg;
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
			data_digits_reg <= 32'b0;
			data_dots_reg <= 8'b0;
		end
	endtask

	task on_clock;
		begin
			if (data_written && !write_req)
				data_written <= 1'b0;
			else if (write_req) begin
				data_written <= 1'b1;

				case (addr_base)
				CTRL_REG_ADDR:			update_reg(ctrl_reg);
				DATA_DIGITS_REG_ADDR:	update_reg(data_digits_reg);
				DATA_DOTS_REG_ADDR:		update_reg(data_dots_reg);
				endcase
			end
		end
	endtask

	always @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end
endmodule
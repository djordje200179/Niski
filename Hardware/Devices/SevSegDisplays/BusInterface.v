module sev_seg_displays_bus_interface (
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
	parameter CONTROL_REG_ADDR		= 32'h0,
			  DATA_DIGITS_REG_ADDR	= 32'h4,
			  DATA_DOTS_REG_ADDR 	= 32'h8;

	reg [7:0] ctrl_reg;
	reg [31:0] data_digits_reg;
	reg [7:0] data_dots_reg;

	wire [7:0] digits_data [0:3];
	assign digits_data[0] = data_digits_reg[7:0];
	assign digits_data[1] = data_digits_reg[15:8];
	assign digits_data[2] = data_digits_reg[23:16];
	assign digits_data[3] = data_digits_reg[31:24];

	wire [6:0] digit_segments [0:3];

	assign ctrl_digit_0 = digits_data[0][7] ? digit_segments[0] : digits_data[0][6:0];
	assign ctrl_digit_1 = digits_data[1][7] ? digit_segments[1] : digits_data[1][6:0];
	assign ctrl_digit_2 = digits_data[2][7] ? digit_segments[2] : digits_data[2][6:0];
	assign ctrl_digit_3 = digits_data[3][7] ? digit_segments[3] : digits_data[3][6:0];

	assign ctrl_dots = data_dots_reg[3:0];
	assign ctrl_en = ctrl_reg[0];

	generate
		genvar i;
		for (i = 0; i < 4; i = i + 1) begin: digit_mappers
			sev_seg_digit_mapper digit_mapper (
				.digit(digits_data[i]),
				.segments(digit_segments[i])
			);
		end
	endgenerate

	wire [55:0] digits_data_out = {24'b0, digits_data[3], digits_data[2], digits_data[1], digits_data[0]};

	reg addr_hit;
	always @* begin
		addr_hit = 1'b0;

		case (addr_bus[31:2])
		CONTROL_REG_ADDR >> 2,
		DATA_DIGITS_REG_ADDR >> 2,
		DATA_DOTS_REG_ADDR >> 2:    
			addr_hit = 1'b1;
		endcase
	end
	
	wire req_valid = rd_bus ^ wr_bus;

	wire req = addr_hit && req_valid,
		 read_req = req && rd_bus,
		 write_req = req && wr_bus;

	reg [31:0] data_out;
	always @* begin
		data_out = 32'b0;

		case (addr_bus[31:2])
		CONTROL_REG_ADDR >> 2:
			data_out[7:0] = ctrl_reg;
		DATA_DIGITS_REG_ADDR >> 2:
			data_out = digits_data_out;
		DATA_DOTS_REG_ADDR >> 2:
			data_out[7:0] = data_dots_reg;
		endcase

		case (addr_bus[1:0])
		2'b01: data_out = {8'b0, data_out[31:8]};
		2'b10: data_out = {16'b0, data_out[31:16]};
		2'b11: data_out = {24'b0, data_out[31:24]};
		endcase
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

				case (addr_bus)
				CONTROL_REG_ADDR: begin
					if (data_mask_bus[0]) ctrl_reg <= data_bus[7:0];
				end
				DATA_DIGITS_REG_ADDR: begin
					if (data_mask_bus[0]) data_digits_reg[7:0] <= data_bus[7:0];
					if (data_mask_bus[1]) data_digits_reg[15:8] <= data_bus[15:8];
					if (data_mask_bus[2]) data_digits_reg[23:16] <= data_bus[23:16];
					if (data_mask_bus[3]) data_digits_reg[31:24] <= data_bus[31:24];
				end
				DATA_DIGITS_REG_ADDR + 32'd1: begin
					if (data_mask_bus[0]) data_digits_reg[15:8] <= data_bus[7:0];
					if (data_mask_bus[1]) data_digits_reg[23:16] <= data_bus[15:8];
					if (data_mask_bus[2]) data_digits_reg[31:24] <= data_bus[23:16];
				end
				DATA_DIGITS_REG_ADDR + 32'd2: begin
					if (data_mask_bus[0]) data_digits_reg[23:16] <= data_bus[7:0];
					if (data_mask_bus[1]) data_digits_reg[31:24] <= data_bus[15:8];
				end
				DATA_DIGITS_REG_ADDR + 32'd3: begin
					if (data_mask_bus[0]) data_digits_reg[31:24] <= data_bus[7:0];
				end
				DATA_DOTS_REG_ADDR: begin
					if (data_mask_bus[0]) data_dots_reg[7:0] <= data_bus[7:0];
				end
				endcase
			end
		end
	endtask

	always @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end
endmodule
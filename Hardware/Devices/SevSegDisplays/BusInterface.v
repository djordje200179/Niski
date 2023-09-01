module sev_seg_bus_interface (
	clk, rst,
    ctrl_en, ctrl_digit_0, ctrl_digit_1, ctrl_digit_2, ctrl_digit_3, ctrl_dots,
	addr_bus, data_bus, rd_bus, wr_bus, data_mask_bus, fc_bus
);
	parameter CONTROL_REG_ADDR		= 32'h0,
			  STATUS_REG_ADDR		= 32'h4,
			  DATA_DIGITS_REG_ADDR	= 32'h8,
			  DATA_DOTS_REG_ADDR 	= 32'hC;

	input clk, rst;
	
	output reg ctrl_en;
    output [6:0] ctrl_digit_0, ctrl_digit_1, ctrl_digit_2, ctrl_digit_3;
    output reg [3:0] ctrl_dots;
	
	input [31:0] addr_bus;
	inout [31:0] data_bus;
	input rd_bus, wr_bus;
	input [3:0] data_mask_bus;
	output fc_bus;

	reg [7:0] digits_data [0:3];
	wire [6:0] digit_segments [0:3];

	assign ctrl_digit_0 = digits_data[0][7] ? digit_segments[0] : digits_data[0][6:0];
	assign ctrl_digit_1 = digits_data[1][7] ? digit_segments[1] : digits_data[1][6:0];
	assign ctrl_digit_2 = digits_data[2][7] ? digit_segments[2] : digits_data[2][6:0];
	assign ctrl_digit_3 = digits_data[3][7] ? digit_segments[3] : digits_data[3][6:0];

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

		if (addr_bus >= DATA_DIGITS_REG_ADDR && addr_bus < DATA_DIGITS_REG_ADDR + 32'd4)
			addr_hit = 1'b1;

		case (addr_bus)
		CONTROL_REG_ADDR,
		STATUS_REG_ADDR,
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
		data_out = 32'b0;

		if (addr_bus == CONTROL_REG_ADDR)
			data_out = {31'b0, ctrl_en};
		else if (addr_bus == STATUS_REG_ADDR)
			data_out = 32'b1;
		else if (addr_bus >= DATA_DIGITS_REG_ADDR && addr_bus < DATA_DIGITS_REG_ADDR + 32'd4)
			data_out = digits_data_out[addr_bus[1:0] * 8 +: 32];
		else if (addr_bus == DATA_DOTS_REG_ADDR)
			data_out = {28'b0, ctrl_dots};
	end

	reg data_written;
	assign data_bus = read_req ? data_out : 32'bz,
		   fc_bus = req ? (read_req || data_written) : 1'bz;

	task reset;
		begin
			data_written <= 1'b0;
			ctrl_en <= 1'b0;
			ctrl_dots <= 4'b0;

			digits_data[0] <= 8'b0;
			digits_data[1] <= 8'b0;
			digits_data[2] <= 8'b0;
			digits_data[3] <= 8'b0;
		end
	endtask

	task on_clock;
		begin
			if (data_written && !write_req)
				data_written <= 1'b0;
			else if (write_req) begin
				data_written <= 1'b1;

				case (addr_bus)
				CONTROL_REG_ADDR: 
					if (data_mask_bus[0])
						ctrl_en <= data_bus[0];
				STATUS_REG_ADDR: ; // TODO: Interrupt!!
				DATA_DIGITS_REG_ADDR: begin
					if (data_mask_bus[0])
						digits_data[0] <= data_bus[0+:8];
					if (data_mask_bus[1])
						digits_data[1] <= data_bus[8+:8];
					if (data_mask_bus[2])
						digits_data[2] <= data_bus[16+:8];
					if (data_mask_bus[3])
						digits_data[3] <= data_bus[24+:8];
				end
				DATA_DIGITS_REG_ADDR + 32'd1: begin
					if (data_mask_bus[0])
						digits_data[1] <= data_bus[0+:8];
					if (data_mask_bus[1])
						digits_data[2] <= data_bus[8+:8];
					if (data_mask_bus[2])
						digits_data[3] <= data_bus[16+:8];

					if (data_mask_bus[3]); // TODO: Interrupt!!
				end
				DATA_DIGITS_REG_ADDR + 32'd2: begin
					if (data_mask_bus[0])
						digits_data[2] <= data_bus[0+:8];
					if (data_mask_bus[1])
						digits_data[3] <= data_bus[8+:8];
					if (data_mask_bus[2] || data_mask_bus[3]); // TODO: Interrupt!!
				end
				DATA_DIGITS_REG_ADDR + 32'd3: begin
					if (data_mask_bus[0])
						digits_data[3] <= data_bus[0+:8];

					if (data_mask_bus[1] || data_mask_bus[2] || data_mask_bus[3]); // TODO: Interrupt!!
				end
				DATA_DOTS_REG_ADDR:
					if (data_mask_bus[0])
						ctrl_dots <= data_bus[3:0];
				endcase
			end
		end
	endtask

	always @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end
endmodule
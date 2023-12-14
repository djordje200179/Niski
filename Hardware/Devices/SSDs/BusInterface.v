module ssds_bus_interface#(parameter START_ADDR = 32'h0) (
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
	reg [7:0] ctrl_reg;
	reg [31:0] data_digits_reg;
	reg [7:0] data_dots_reg;

	wire [27:0] segments;
	assign {ctrl_digit_3, ctrl_digit_2, ctrl_digit_1, ctrl_digit_0} = segments;

	assign ctrl_dots = data_dots_reg[3:0];
	assign ctrl_en = ctrl_reg[0];

	generate
		genvar i;
		for (i = 0; i < 4; i = i + 1) begin: digit_mappers
			wire [6:0] mapped_segments;

			ssds_digit_mapper digit_mapper (
				.digit(data_digits_reg[8 * i +: 4]),
				.segments(mapped_segments)
			);

			assign segments[7 * i +: 7] = data_digits_reg[8 * i + 7] ? mapped_segments : data_digits_reg[8 * i +: 7];
		end
	endgenerate

	wire addr_hit;
	wire [1:0] reg_index;
	wire [1:0] word_offset;
	addr_splitter#(START_ADDR, 3) addr_splitter (
		.addr_bus(addr_bus),

		.addr_hit(addr_hit),
		.reg_index(reg_index),
		.word_offset(word_offset)
	);

	wire [31:0] incoming_data;
	wire [31:0] existing_data_mask;
	data_shifter data_shifter (
		.data_bus(data_bus),
		.word_offset(word_offset),
		.data_mask_bus(data_mask_bus),

		.existing_data_mask(existing_data_mask),
		.incoming_data(incoming_data)
	);

	wire [7:0] next_ctrl_reg = ctrl_reg & existing_data_mask | incoming_data;
	wire [31:0] next_data_digits_reg = data_digits_reg & existing_data_mask | incoming_data;
	wire [7:0] next_data_dots_reg = data_dots_reg & existing_data_mask | incoming_data;

	wire read_req = addr_hit && rd_bus,
		 write_req = addr_hit && wr_bus;

	reg [31:0] data_out;
	always @* begin
		data_out = 32'b0;

		case (reg_index)
		2'd0: data_out = ctrl_reg;
		2'd1: data_out = data_digits_reg;
		2'd2: data_out = data_dots_reg;
		endcase

		data_out = data_out >> (8 * word_offset);
	end

	reg data_written;
	assign data_bus = read_req ? data_out : 32'bz,
		   fc_bus = addr_hit ? (read_req || data_written) : 1'bz;

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

				case (reg_index)
				2'd0: ctrl_reg <= next_ctrl_reg;
				2'd1: data_digits_reg <= next_data_digits_reg;
				2'd2: data_dots_reg <= next_data_dots_reg;
				endcase
			end
		end
	endtask

	always @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end
endmodule
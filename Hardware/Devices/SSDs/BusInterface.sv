module ssds_bus_interface#(START_ADDR = 32'h0) (
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
	reg [0:0] ctrl_reg;
	reg [31:0] data_digits_reg;
	reg [3:0] data_dots_reg;

	assign ctrl_en = ctrl_reg[0];
	assign ctrl_dots = data_dots_reg[3:0];

	wire [6:0] segments [4];
	assign segments = '{ctrl_digit_3, ctrl_digit_2, ctrl_digit_1, ctrl_digit_0};

	generate
		genvar i;
		for (i = 0; i < 4; i++) begin: digit_mappers
			wire [6:0] mapped_segments;

			ssds_digit_mapper digit_mapper (
				.digit(data_digits_reg[8 * i +: 4]),
				.segments(mapped_segments)
			);

			assign segments[i] = data_digits_reg[8 * i + 7] ? mapped_segments : data_digits_reg[8 * i +: 7];
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

	wire [31:0] next_ctrl_reg = ctrl_reg & existing_data_mask | incoming_data;
	wire [31:0] next_data_digits_reg = data_digits_reg & existing_data_mask | incoming_data;
	wire [31:0] next_data_dots_reg = data_dots_reg & existing_data_mask | incoming_data;

	wire read_req = addr_hit && rd_bus,
		 write_req = addr_hit && wr_bus;

	logic [31:0] data_out;
	always_comb begin
		unique case (reg_index)
		0: data_out = ctrl_reg;
		1: data_out = data_digits_reg;
		2: data_out = data_dots_reg;
		default: data_out = '0;
		endcase

		data_out = data_out >> (8 * word_offset);
	end

	enum {STATE_IDLE, STATE_DONE} state;

	assign data_bus = read_req ? data_out : 'z,
		   fc_bus = addr_hit ? (read_req || state == STATE_DONE) : 'z;

	task reset;
		begin
			state <= STATE_IDLE;

			ctrl_reg <= '0;
			data_digits_reg <= '0;
			data_dots_reg <= '0;
		end
	endtask

	task on_clock;
		begin
			case (state)
			STATE_IDLE: begin
				if (write_req) begin
					state <= STATE_DONE;

					case (reg_index)
					0: ctrl_reg <= next_ctrl_reg;
					1: data_digits_reg <= next_data_digits_reg;
					2: data_dots_reg <= next_data_dots_reg;
					endcase
				end
			end
			STATE_DONE: begin
				if (!write_req) 
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
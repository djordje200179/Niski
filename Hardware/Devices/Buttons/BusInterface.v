module buttons_bus_interface#(parameter START_ADDR = 32'h0) (
	input clk, rst,

	input btn_0, btn_1, btn_2, btn_3,
	output intr_0, intr_1, intr_2, intr_3,

	input [31:0] addr_bus, 
	inout [31:0] data_bus, 
	input rd_bus, wr_bus, 
	input [3:0] data_mask_bus, 
	output fc_bus
);
	reg [7:0] ctrl_reg;

	wire btn_0_pressed, btn_1_pressed, btn_2_pressed, btn_3_pressed;
	
	rising_edge_detector red_0 (
		.clk(clk), .rst(rst),

		.raw_input(btn_0),
		.rising_edge(btn_0_pressed)
	);

	rising_edge_detector red_1 (
		.clk(clk), .rst(rst),

		.raw_input(btn_1),
		.rising_edge(btn_1_pressed)
	);

	rising_edge_detector red_2 (
		.clk(clk), .rst(rst),

		.raw_input(btn_2),
		.rising_edge(btn_2_pressed)
	);

	rising_edge_detector red_3 (
		.clk(clk), .rst(rst),

		.raw_input(btn_3),
		.rising_edge(btn_3_pressed)
	);

	assign intr_0 = btn_0_pressed && ctrl_reg[0],
		   intr_1 = btn_1_pressed && ctrl_reg[1],
		   intr_2 = btn_2_pressed && ctrl_reg[2],
		   intr_3 = btn_3_pressed && ctrl_reg[3];

	wire addr_hit;
	wire [0:0] reg_index;
	wire [1:0] word_offset;
	addr_splitter#(START_ADDR, 2) addr_splitter (
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

	wire read_req = addr_hit && rd_bus,
		 write_req = addr_hit && wr_bus;

	reg [31:0] data_out;
	always @* begin
		data_out = 32'b0;

		case (reg_index)
		1'd0: data_out = ctrl_reg;
		1'd1: data_out = {{7{1'b0}}, btn_0, {7{1'b0}}, btn_1, {7{1'b0}}, btn_2, {7{1'b0}}, btn_3};
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
		end
	endtask

	task on_clock;
		begin
			if (data_written && !wr_bus)
				data_written <= 1'b0;
			else if (write_req) begin
				data_written <= 1'b1;

				case (reg_index)
				1'd0: ctrl_reg <= next_ctrl_reg;
				endcase
			end
		end
	endtask

	always @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end
endmodule
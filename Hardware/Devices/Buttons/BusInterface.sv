module buttons_bus_interface#(parameter START_ADDR = 32'h0) (
	input clk, rst,

	input btn_0, btn_1, btn_2, btn_3,
	output irq_0, irq_1, irq_2, irq_3,

	input [31:0] addr_bus,
	inout [31:0] data_bus,
	input rd_bus, wr_bus,
	input [3:0] data_mask_bus,
	output fc_bus
);
	reg [7:0] ctrl_reg;

	wire [3:0] raw_inputs = {btn_0, btn_1, btn_2, btn_3};
	wire [3:0] irqs;

	generate
		genvar i;
		for (i = 0; i < 4; i++) begin : edge_detectors
			wire btn_pressed;
			
			rising_edge_detector red (
				.clk(clk), .rst(rst),

				.raw_input(raw_inputs[i]),
				.rising_edge(btns_pressed)
			);

			assign irqs[i] = btns_pressed && ctrl_reg[i];
		end
	endgenerate

	assign {irq_0, irq_1, irq_2, irq_3} = irqs;

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

	logic [31:0] data_out;
	always_comb begin
		unique case (reg_index)
		0: data_out = ctrl_reg;
		1: data_out = {{7{1'b0}}, btn_0, {7{1'b0}}, btn_1, {7{1'b0}}, btn_2, {7{1'b0}}, btn_3};
		endcase

		data_out = data_out >> (8 * word_offset);
	end

	enum {STATE_IDLE, STATE_DONE} state;

	assign data_bus = read_req ? data_out : 32'bz,
		   fc_bus = addr_hit ? (read_req || state == STATE_DONE) : 1'bz;

	task automatic reset;
		begin
			state <= STATE_IDLE;

			ctrl_reg <= '0;
		end
	endtask

	task automatic on_clock;
		begin
			unique case (state)
			STATE_IDLE: begin
				if (write_req) begin
					state <= STATE_DONE;

					case (reg_index)
					0: ctrl_reg <= next_ctrl_reg;
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
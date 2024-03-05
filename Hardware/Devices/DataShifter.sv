module data_shifter (
	input [31:0] data_bus,
	input [1:0] word_offset,
	input [3:0] data_mask_bus,

	output [31:0] existing_data_mask,
	output [31:0] incoming_data
);
	wire [3:0] shifted_mask = data_mask_bus << word_offset;
	wire [31:0] mask = {{8{shifted_mask[3]}}, {8{shifted_mask[2]}}, {8{shifted_mask[1]}}, {8{shifted_mask[0]}}};
	assign existing_data_mask = ~mask;

	logic [31:0] shifted_data;
	always_comb begin
		unique case (word_offset)
		0: shifted_data = data_bus;
		1: shifted_data = {data_bus[0 +: 24], '0};
		2: shifted_data = {data_bus[0 +: 16], '0};
		3: shifted_data = {data_bus[0 +: 8], '0};
		endcase
	end

	assign incoming_data = shifted_data & mask;
endmodule
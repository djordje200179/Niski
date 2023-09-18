wire [31:0] addr_base = {addr_bus[31:2], 2'b00};
wire [1:0] addr_offset = addr_bus[1:0];

task update_reg (
	inout [31:0] register
);
	integer bus_byte, reg_byte;
	begin
		for (bus_byte = 0; bus_byte < 4; bus_byte = bus_byte + 1) begin
			if (bus_byte + addr_offset < 4) begin
				reg_byte = bus_byte + addr_offset;

				if (data_mask_bus[bus_byte])
					register[8 * reg_byte +: 8] <= data_bus[8 * bus_byte +: 8];
			end
		end
	end
endtask

task adjust_data_out (
	inout [31:0] data_out
);
	begin
		case (addr_offset)
		2'd1: data_out = {8'b0, data_out[8 +: 24]};
		2'd2: data_out = {16'b0, data_out[16 +: 16]};
		2'd3: data_out = {24'b0, data_out[24 +: 8]};
		endcase
	end
endtask
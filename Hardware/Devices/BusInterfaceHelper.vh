wire [29:0] addr_base;
wire [1:0] addr_offset;
assign {addr_base, addr_offset} = addr_bus;

task update_reg(
	inout [31:0] register
);
	integer bus_byte, reg_byte;
	begin
		for (bus_byte = 0; bus_byte < 4; bus_byte = bus_byte + 1) begin
			if (bus_byte + addr_offset < 4) begin
				reg_byte = bus_byte + addr_offset;

				if (data_mask_bus[bus_byte])
					register[8 * reg_byte +: 8] = data_bus[8 * bus_byte +: 8];
			end
		end
	end
endtask
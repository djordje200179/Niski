module buzzer_bus_interface (
	input clk, rst,
	
	output ctrl_en, ctrl_buzz,
	
	input [31:0] addr_bus, 
	inout [31:0] data_bus, 
	input rd_bus, wr_bus,
	input [3:0] data_mask_bus, 
	output fc_bus
);
	parameter CONTROL_REG_ADDR	= 32'h0,
			  DATA_REG_ADDR		= 32'h4;

	wire [29:0] addr_base;
	wire [1:0] addr_offset;
	assign {addr_base, addr_offset} = addr_bus;

	reg [7:0] ctrl_reg;
	reg [7:0] data_reg;

	assign ctrl_en = ctrl_reg[0];
	assign ctrl_buzz = data_reg[0];

	task update_reg(
		inout [31:0] register
	);
		integer i;
		begin
			for (i = 0; i < 4; i = i + 1) begin
				if (i + addr_offset < 4 && data_mask_bus[i])
					register[8 * i +: 8] = register[8 * (i - addr_offset) +: 8];
			end
		end
	endtask

	reg addr_hit;
	always @* begin
		addr_hit = 1'b0;

		case (addr_base)
		CONTROL_REG_ADDR >> 2,
		DATA_REG_ADDR >> 2:
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

		case (addr_base)
		CONTROL_REG_ADDR >> 2:	data_out = ctrl_reg;
		DATA_REG_ADDR >> 2:		data_out = data_reg;
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
			data_reg <= 8'b0;
		end
	endtask

	task on_clock;
		begin
			if (data_written && !write_req)
				data_written <= 1'b0;
			else if (write_req) begin
				data_written <= 1'b1;

				case (addr_base)
				CONTROL_REG_ADDR >> 2:	update_reg(ctrl_reg);
				DATA_REG_ADDR >> 2:		update_reg(data_reg);
				endcase
			end
		end
	endtask

	always @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end
endmodule
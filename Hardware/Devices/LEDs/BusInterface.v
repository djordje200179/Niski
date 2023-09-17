module leds_bus_interface (
	input clk, rst,
	
	output ctrl_en, ctrl_led0, ctrl_led1, ctrl_led2, ctrl_led3,
	
	input [31:0] addr_bus, 
	inout [31:0] data_bus, 
	input rd_bus, wr_bus, 
	input [3:0] data_mask_bus, 
	output fc_bus
);
	parameter CONTROL_REG_ADDR	= 32'h0,
			  DATA_REG_ADDR		= 32'h4;

	reg [7:0] ctrl_reg;
	reg [31:0] data_reg;

	assign ctrl_en = ctrl_reg[0];
	assign {ctrl_led0, ctrl_led1, ctrl_led2, ctrl_led3} = {data_reg[24], data_reg[16], data_reg[8], data_reg[0]};

	`include "../BusInterfaceHelper.vh"

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
		case (addr_base)
		CONTROL_REG_ADDR >> 2:	data_out = ctrl_reg;
		DATA_REG_ADDR >> 2: 	data_out = data_reg;
		default: data_out = 32'b0;
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
			data_reg <= 32'b0;
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
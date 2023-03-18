module leds_bus_interface (
	clk, rst,
	ctrl_en, ctrl_led0, ctrl_led1, ctrl_led2, ctrl_led3,
	addr_bus, data_bus, wr_bus, rd_bus, fc_bus
);
	parameter ADDR_BUS_WIDTH = 32,
			  DATA_BUS_WIDTH = 8;

	parameter CONTROL_REG_ADDR = 0,
			  STATUS_REG_ADDR = 1,
			  DATA_REG_ADDR = 2;

	input clk, rst;
	
	output reg ctrl_en, ctrl_led0, ctrl_led1, ctrl_led2, ctrl_led3;
	
	input [ADDR_BUS_WIDTH-1:0] addr_bus;
	inout [DATA_BUS_WIDTH-1:0] data_bus;
	input wr_bus, rd_bus;
	output fc_bus;

	wire addr_hit = (addr_bus == CONTROL_REG_ADDR) || (addr_bus == STATUS_REG_ADDR) || (addr_bus == DATA_REG_ADDR);
	wire req_valid = rd_bus ^ wr_bus;

	wire req = addr_hit && req_valid,
		 read_req = req && rd_bus,
		 write_req = req && wr_bus;

	function [DATA_BUS_WIDTH-1:0] get_data_out(input [ADDR_BUS_WIDTH-1:0] addr);
		begin
			case (addr)
				CONTROL_REG_ADDR: get_data_out = ctrl_en;
				STATUS_REG_ADDR: get_data_out = 1'b1;
				DATA_REG_ADDR: get_data_out = {ctrl_led3, ctrl_led2, ctrl_led1, ctrl_led0};
				default: get_data_out = {DATA_BUS_WIDTH{1'bz}};
			endcase
		end
	endfunction

	wire [DATA_BUS_WIDTH-1:0] data_out = get_data_out(addr_bus);

	reg data_written;
	assign data_bus = read_req ? data_out : {DATA_BUS_WIDTH{1'bz}},
		   fc_bus = req ? (read_req || data_written) : 1'bz;

	task reset;
		begin
			data_written <= 1'b0;
			ctrl_en <= 1'b0;
			{ctrl_led3, ctrl_led2, ctrl_led1, ctrl_led0} <= 4'b0000;
		end
	endtask

	task on_clock;
		begin
			if (write_req) begin
				data_written <= 1'b1;

				case (addr_bus)
					CONTROL_REG_ADDR: ctrl_en <= data_bus[0];
					STATUS_REG_ADDR: ; // TODO: Interrupt!!
					DATA_REG_ADDR: {ctrl_led3, ctrl_led2, ctrl_led1, ctrl_led0} <= data_bus[3:0];
				endcase
			end

			if (data_written && !write_req)
				data_written <= 1'b0;
		end
	endtask

	always @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end
endmodule
module buzzer_bus_interface (
	clk, rst,
	ctrl_en, ctrl_buzz,
	addr_bus, data_bus, rd_bus, wr_bus, data_mask_bus, fc_bus
);
	parameter CONTROL_REG_ADDR	= 32'h0,
			  STATUS_REG_ADDR	= 32'h4,
			  DATA_REG_ADDR		= 32'h8;

	input clk, rst;
	
	output reg ctrl_en, ctrl_buzz;
	
	input [31:0] addr_bus;
	inout [31:0] data_bus;
	input rd_bus, wr_bus;
	input [3:0] data_mask_bus;
	output fc_bus;

	reg addr_hit;
	always @* begin
		addr_hit = 1'b0;

		case (addr_bus)
		CONTROL_REG_ADDR,
		STATUS_REG_ADDR,
		DATA_REG_ADDR: 
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

		case (addr_bus)
		CONTROL_REG_ADDR: data_out = {31'b0, ctrl_en};
		STATUS_REG_ADDR:  data_out = 32'b1;
		DATA_REG_ADDR: 
			data_out = {31'b0, ctrl_buzz};
		endcase
	end

	reg data_written;
	assign data_bus = read_req ? data_out : 32'bz,
		   fc_bus = req ? (read_req || data_written) : 1'bz;

	task reset;
		begin
			data_written <= 1'b0;
			ctrl_en <= 1'b0;
			ctrl_buzz <= 1'b0;
		end
	endtask

	task on_clock;
		begin
			if (data_written && !write_req)
				data_written <= 1'b0;
			else if (write_req) begin
				data_written <= 1'b1;

				case (addr_bus)
				CONTROL_REG_ADDR: 
					ctrl_en <= data_bus[0];
				STATUS_REG_ADDR: ; // TODO: Interrupt!!
				DATA_REG_ADDR:
					ctrl_buzz <= data_bus[0];
				endcase
			end
		end
	endtask

	always @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end
endmodule
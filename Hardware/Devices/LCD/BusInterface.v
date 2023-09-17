module lcd_bus_interface (
	input clk, rst,
	
	output reg [7:0] ctrl_data,
	output reg ctrl_data_is_cmd, ctrl_data_req,
	input ctrl_data_ack,
	
	input [31:0] addr_bus, 
	inout [31:0] data_bus, 
	input rd_bus, wr_bus,
	input [3:0] data_mask_bus, 
	output fc_bus
);
	parameter DATA_REG_ADDR	= 32'h0,
			  CMD_REG_ADDR	= 32'h4;

	wire [29:0] addr_base;
	wire [1:0] addr_offset;
	assign {addr_base, addr_offset} = addr_bus;

	reg addr_hit;
	always @* begin
		addr_hit = 1'b0;

		case (addr_base)
		DATA_REG_ADDR >> 2,
		CMD_REG_ADDR >> 2:
			addr_hit = 1'b1;
		endcase
	end
	
	wire req_valid = rd_bus ^ wr_bus;

	wire req = addr_hit && req_valid,
		 read_req = req && rd_bus,
		 write_req = req && wr_bus;

	wire [31:0] data_out = 32'b0;

	assign data_bus = read_req ? data_out : 32'bz,
		   fc_bus = req ? ctrl_data_ack : 1'bz;

	task reset;
		begin
			ctrl_data_req <= 1'b0;
		end
	endtask

	task on_clock;
		begin
			if (ctrl_data_ack && !write_req)
				ctrl_data_req <= 1'b0;
			else if (!ctrl_data_ack && write_req) begin
				case (addr_bus)
				DATA_REG_ADDR: begin
					if (data_mask_bus[0]) begin
						ctrl_data <= data_bus[7:0];
						ctrl_data_is_cmd <= 1'b0;
						ctrl_data_req <= 1'b1;
					end
				end
				CMD_REG_ADDR: begin
					if (data_mask_bus[0]) begin
						ctrl_data <= data_bus[7:0];
						ctrl_data_is_cmd <= 1'b1;
						ctrl_data_req <= 1'b1;
					end
				end
				endcase
			end
		end
	endtask

	always @(posedge clk or posedge rst) begin
		if (rst) reset;
		else on_clock;
	end
endmodule
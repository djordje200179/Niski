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
			  STATUS_REG_ADDR	= 32'h4,
			  DATA_REG_ADDR		= 32'h8;

	reg [31:0] ctrl_reg;
	reg [31:0] status_reg;
	reg [31:0] data_reg;

	assign ctrl_en = ctrl_reg[0];
	assign {ctrl_led0, ctrl_led1, ctrl_led2, ctrl_led3} = {data_reg[24], data_reg[16], data_reg[8], data_reg[0]};

	reg addr_hit;
	always @* begin
		addr_hit = 1'b0;

		case (addr_bus[31:2])
		CONTROL_REG_ADDR >> 2,
		STATUS_REG_ADDR >> 2,
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

		case (addr_bus[31:2])
		CONTROL_REG_ADDR >> 2:
			data_out = ctrl_reg;
		STATUS_REG_ADDR >> 2:
			data_out = status_reg;
		DATA_REG_ADDR >> 2:   
			data_out = data_reg;
		endcase

		case (addr_bus[1:0])
		2'b01: data_out = {8'b0, ctrl_reg[31:8]};
		2'b10: data_out = {16'b0, ctrl_reg[31:16]};
		2'b11: data_out = {24'b0, ctrl_reg[31:24]};
		endcase
	end

	reg data_written;
	assign data_bus = read_req ? data_out : 32'bz,
		   fc_bus = req ? (read_req || data_written) : 1'bz;

	task reset;
		begin
			data_written <= 1'b0;
			ctrl_reg <= 32'b0;
			status_reg <= 32'b0;
			data_reg <= 32'b0;
		end
	endtask

	task on_clock;
		begin
			if (data_written && !write_req)
				data_written <= 1'b0;
			else if (write_req) begin
				data_written <= 1'b1;

				case (addr_bus)
					CONTROL_REG_ADDR: begin
						if (data_mask_bus[0]) ctrl_reg[7:0] <= data_bus[7:0];
						if (data_mask_bus[1]) ctrl_reg[15:8] <= data_bus[15:8];
						if (data_mask_bus[2]) ctrl_reg[23:16] <= data_bus[23:16];
						if (data_mask_bus[3]) ctrl_reg[31:24] <= data_bus[31:24];
					end
					CONTROL_REG_ADDR + 32'b1: begin
						if (data_mask_bus[0]) ctrl_reg[15:8] <= data_bus[7:0];
						if (data_mask_bus[1]) ctrl_reg[23:16] <= data_bus[15:8];
						if (data_mask_bus[2]) ctrl_reg[31:24] <= data_bus[23:16];
					end
					CONTROL_REG_ADDR + 32'b10: begin
						if (data_mask_bus[0]) ctrl_reg[23:16] <= data_bus[7:0];
						if (data_mask_bus[1]) ctrl_reg[31:24] <= data_bus[15:8];
					end
					CONTROL_REG_ADDR + 32'b11: begin
						if (data_mask_bus[0]) ctrl_reg[31:24] <= data_bus[7:0];
					end
					STATUS_REG_ADDR: ; // TODO: Interrupt!!
					DATA_REG_ADDR: begin
						if (data_mask_bus[0]) data_reg[7:0] <= data_bus[7:0];
						if (data_mask_bus[1]) data_reg[15:8] <= data_bus[15:8];
						if (data_mask_bus[2]) data_reg[23:16] <= data_bus[23:16];
						if (data_mask_bus[3]) data_reg[31:24] <= data_bus[31:24];
					end
					DATA_REG_ADDR + 32'b1: begin
						if (data_mask_bus[0]) data_reg[15:8] <= data_bus[7:0];
						if (data_mask_bus[1]) data_reg[23:16] <= data_bus[15:8];
						if (data_mask_bus[2]) data_reg[31:24] <= data_bus[23:16];
					end
					DATA_REG_ADDR + 32'b10: begin
						if (data_mask_bus[0]) data_reg[23:16] <= data_bus[7:0];
						if (data_mask_bus[1]) data_reg[31:24] <= data_bus[15:8];
					end
					DATA_REG_ADDR + 32'b11: begin
						if (data_mask_bus[0]) data_reg[31:24] <= data_bus[7:0];
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
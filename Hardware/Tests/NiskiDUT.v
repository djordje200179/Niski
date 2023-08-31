// Copyright (C) 2023  Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions 
// and other software and tools, and any partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License 
// Subscription Agreement, the Intel Quartus Prime License Agreement,
// the Intel FPGA IP License Agreement, or other applicable license
// agreement, including, without limitation, that your use is for
// the sole purpose of programming logic devices manufactured by
// Intel and sold by Intel or its authorized distributors.  Please
// refer to the applicable agreement for further details, at
// https://fpgasoftware.intel.com/eula.

// PROGRAM		"Quartus Prime"
// VERSION		"Version 22.1std.1 Build 917 02/14/2023 SC Lite Edition"
// CREATED		"Wed Aug 30 22:31:29 2023"

module niski_dut(
	CLK_PIN,
	UART_RX_PIN,
	PS2_CLK_PIN,
	PS2_DATA_PIN,
	IR_PIN,
	BTN_PINS,
	BUZZ_PIN,
	UART_TX_PIN,
	SDRAM_CKE_PIN,
	SDRAM_CLK_PIN,
	SDRAM_CS_PIN,
	SDRAM_RAS_PIN,
	SDRAM_CAS_PIN,
	SDRAM_WE_PIN,
	I2C_SCL_PIN,
	LCD_RS_PIN,
	LCD_RW_PIN,
	LCD_E_PIN,
	I2C_SDA_PIN,
	LCD_DATA_PINS,
	LED_PINS,
	SDRAM_ADDR_PINS,
	SDRAM_BANK_PINS,
	SDRAM_DATA_PINS,
	SDRAM_MASK_PINS,
	SEVSEG_SEG_PINS,
	SEVSEG_SEL_PINS
);


input wire	CLK_PIN;
input wire	UART_RX_PIN;
input wire	PS2_CLK_PIN;
input wire	PS2_DATA_PIN;
input wire	IR_PIN;
input wire	[4:0] BTN_PINS;
output wire	BUZZ_PIN;
output wire	UART_TX_PIN;
output wire	SDRAM_CKE_PIN;
output wire	SDRAM_CLK_PIN;
output wire	SDRAM_CS_PIN;
output wire	SDRAM_RAS_PIN;
output wire	SDRAM_CAS_PIN;
output wire	SDRAM_WE_PIN;
output wire	I2C_SCL_PIN;
output wire	LCD_RS_PIN;
output wire	LCD_RW_PIN;
output wire	LCD_E_PIN;
inout wire	I2C_SDA_PIN;
output wire	[7:0] LCD_DATA_PINS;
output wire	[3:0] LED_PINS;
output wire	[11:0] SDRAM_ADDR_PINS;
output wire	[1:0] SDRAM_BANK_PINS;
inout wire	[15:0] SDRAM_DATA_PINS;
output wire	[1:0] SDRAM_MASK_PINS;
output wire	[7:0] SEVSEG_SEG_PINS;
output wire	[3:0] SEVSEG_SEL_PINS;

wire	[31:0] addr_bus;
wire	btn_0;
wire	btn_1;
wire	btn_2;
wire	btn_3;
wire	btn_rst;
wire	clk_1_hz;
wire	clk_1_khz;
wire	clk_1_mhz;
wire	clk_50_mhz;
wire	[31:0] data_bus;
wire	[3:0] data_mask_bus;
wire	fc_bus;
wire	rd_bus;
wire	wr_bus;
wire	SYNTHESIZED_WIRE_0;
wire	[6:0] SYNTHESIZED_WIRE_1;
wire	[6:0] SYNTHESIZED_WIRE_2;
wire	[6:0] SYNTHESIZED_WIRE_3;
wire	[6:0] SYNTHESIZED_WIRE_4;
wire	[3:0] SYNTHESIZED_WIRE_5;
wire	SYNTHESIZED_WIRE_6;
wire	SYNTHESIZED_WIRE_7;
wire	SYNTHESIZED_WIRE_8;
wire	SYNTHESIZED_WIRE_9;
wire	SYNTHESIZED_WIRE_10;
wire	SYNTHESIZED_WIRE_11;
wire	[11:0] SYNTHESIZED_WIRE_12;
wire	SYNTHESIZED_WIRE_13;
wire	[9:0] SYNTHESIZED_WIRE_14;
wire	[31:0] SYNTHESIZED_WIRE_15;
wire	[3:0] SYNTHESIZED_WIRE_16;
wire	[31:0] SYNTHESIZED_WIRE_17;
wire	[31:0] SYNTHESIZED_WIRE_18;
wire	SYNTHESIZED_WIRE_19;
wire	SYNTHESIZED_WIRE_20;
wire	SYNTHESIZED_WIRE_21;





i2c_controller	b2v_inst(
	.clk(clk_50_mhz),
	.rst(btn_rst),
	.en(1),
	
	
	.data_pin(I2C_SDA_PIN),
	
	
	
	
	.clk_pin(I2C_SCL_PIN)
	
	);



sev_seg_displays_controller	b2v_inst10(
	.clk(clk_1_khz),
	.rst(btn_rst),
	.en(SYNTHESIZED_WIRE_0),
	.digit_0(SYNTHESIZED_WIRE_1),
	.digit_1(SYNTHESIZED_WIRE_2),
	.digit_2(SYNTHESIZED_WIRE_3),
	.digit_3(SYNTHESIZED_WIRE_4),
	.dots(SYNTHESIZED_WIRE_5),
	.segment_pins(SEVSEG_SEG_PINS),
	.select_pins(SEVSEG_SEL_PINS));
	defparam	b2v_inst10.CLK_FREQ = 1000;
	defparam	b2v_inst10.REFRESH_RATE = 60;


buzzer_bus_interface	b2v_inst11(
	.clk(clk_50_mhz),
	.rst(btn_rst),
	.rd_bus(rd_bus),
	.wr_bus(wr_bus),
	.addr_bus(addr_bus),
	.data_bus(data_bus),
	.data_mask_bus(data_mask_bus),
	.ctrl_en(SYNTHESIZED_WIRE_20),
	.ctrl_buzz(SYNTHESIZED_WIRE_21),
	.fc_bus(fc_bus)
	);
	defparam	b2v_inst11.CONTROL_REG_ADDR = 32'b01110000000000000000000000010000;
	defparam	b2v_inst11.DATA_REG_ADDR = 32'b01110000000000000000000000011000;
	defparam	b2v_inst11.STATUS_REG_ADDR = 32'b01110000000000000000000000010100;


leds_controller	b2v_inst12(
	.en(SYNTHESIZED_WIRE_6),
	.led0(SYNTHESIZED_WIRE_7),
	.led1(SYNTHESIZED_WIRE_8),
	.led2(SYNTHESIZED_WIRE_9),
	.led3(SYNTHESIZED_WIRE_10),
	.led_pins(LED_PINS));


clocks	b2v_inst13(
	.clk(CLK_PIN),
	.en(1),
	.rst(btn_rst),
	.clk_50_mhz(clk_50_mhz),
	.clk_1_mhz(clk_1_mhz),
	.clk_1_khz(clk_1_khz)
	);
	defparam	b2v_inst13.INPUT_FREQ = 50000000;


leds_bus_interface	b2v_inst14(
	.clk(clk_50_mhz),
	.rst(btn_rst),
	.rd_bus(rd_bus),
	.wr_bus(wr_bus),
	.addr_bus(addr_bus),
	.data_bus(data_bus),
	.data_mask_bus(data_mask_bus),
	.ctrl_en(SYNTHESIZED_WIRE_6),
	.ctrl_led0(SYNTHESIZED_WIRE_7),
	.ctrl_led1(SYNTHESIZED_WIRE_8),
	.ctrl_led2(SYNTHESIZED_WIRE_9),
	.ctrl_led3(SYNTHESIZED_WIRE_10),
	.fc_bus(fc_bus)
	);
	defparam	b2v_inst14.CONTROL_REG_ADDR = 32'b01110000000000000000000000000000;
	defparam	b2v_inst14.DATA_REG_ADDR = 32'b01110000000000000000000000001000;
	defparam	b2v_inst14.STATUS_REG_ADDR = 32'b01110000000000000000000000000100;


bus_arbitrator	b2v_inst16(
	.clk(clk_50_mhz),
	.rst(btn_rst),
	.cpu_req(SYNTHESIZED_WIRE_11),
	.dma_req(0),
	.cpu_grant(SYNTHESIZED_WIRE_19),
	
	.wr_bus(wr_bus),
	.rd_bus(rd_bus),
	.fc_bus(fc_bus),
	.addr_bus(addr_bus),
	.data_bus(data_bus),
	.data_mask_bus(data_mask_bus));


lcd_controller	b2v_inst17(
	.clk(clk_50_mhz),
	.rst(btn_rst),
	.en(1),
	.rs_pin(LCD_RS_PIN),
	.rw_pin(LCD_RW_PIN),
	.e_pin(LCD_E_PIN),
	.data_pins(LCD_DATA_PINS));


rom	b2v_inst18(
	.clk(clk_50_mhz),
	.addr(SYNTHESIZED_WIRE_12),
	.data_out(SYNTHESIZED_WIRE_18));
	defparam	b2v_inst18.ADDR_BITS = 12;
	defparam	b2v_inst18.MEM_FILE = "../../Software/out/rom.mem";



ram	b2v_inst20(
	.clk(clk_50_mhz),
	.wr(SYNTHESIZED_WIRE_13),
	.addr(SYNTHESIZED_WIRE_14),
	.data_in(SYNTHESIZED_WIRE_15),
	.wr_mask(SYNTHESIZED_WIRE_16),
	.data_out(SYNTHESIZED_WIRE_17));
	defparam	b2v_inst20.ADDR_BITS = 10;


memory_bus_interface	b2v_inst21(
	.clk(clk_50_mhz),
	.rst(btn_rst),
	.wr_bus(wr_bus),
	.rd_bus(rd_bus),
	.addr_bus(addr_bus),
	.data_bus(data_bus),
	.data_mask_bus(data_mask_bus),
	.mem_data_out(SYNTHESIZED_WIRE_17),
	.mem_wr(SYNTHESIZED_WIRE_13),
	.fc_bus(fc_bus),
	
	.mem_addr(SYNTHESIZED_WIRE_14),
	.mem_data_in(SYNTHESIZED_WIRE_15),
	.mem_wr_mask(SYNTHESIZED_WIRE_16));
	defparam	b2v_inst21.MEM_ADDR_WIDTH = 10;
	defparam	b2v_inst21.START_ADDR = 32'b10000000000000000000000000000000;


memory_bus_interface	b2v_inst22(
	.clk(clk_50_mhz),
	.rst(btn_rst),
	.wr_bus(wr_bus),
	.rd_bus(rd_bus),
	.addr_bus(addr_bus),
	.data_bus(data_bus),
	.data_mask_bus(data_mask_bus),
	.mem_data_out(SYNTHESIZED_WIRE_18),
	
	.fc_bus(fc_bus),
	
	.mem_addr(SYNTHESIZED_WIRE_12)
	
	);
	defparam	b2v_inst22.MEM_ADDR_WIDTH = 12;
	defparam	b2v_inst22.START_ADDR = 32'b01000000000000000000000000000000;


cpu	b2v_inst23(
	.clk(clk_50_mhz),
	.rst(btn_rst),
	.bus_grant(SYNTHESIZED_WIRE_19),
	.fc_bus(fc_bus),
	.data_bus(data_bus),
	.bus_req(SYNTHESIZED_WIRE_11),
	.wr_bus(wr_bus),
	.rd_bus(rd_bus),
	.addr_bus(addr_bus),
	
	.data_mask_bus(data_mask_bus));
	defparam	b2v_inst23.EXEC_START_ADDR = 32'b01000000000000000000000000000000;
	defparam	b2v_inst23.MORE_REGISTERS = 0;


ps2_keyboard_controller	b2v_inst3(
	.clk(clk_50_mhz),
	.rst(1),
	.en(btn_rst),
	
	.data_pin(PS2_DATA_PIN),
	.clk_pin(PS2_CLK_PIN)
	
	
	);


buttons_controller	b2v_inst4(
	.clk(clk_1_mhz),
	.button_pins(BTN_PINS),
	
	
	
	
	.btn_rst(btn_rst));
	defparam	b2v_inst4.DEBOUNCING_TICKS = 32;


sdram_controller	b2v_inst5(
	.clk(clk_50_mhz),
	.rst(btn_rst),
	.en(1),
	
	
	
	
	.data_pins(SDRAM_DATA_PINS),
	.cke_pin(SDRAM_CKE_PIN),
	.clk_pin(SDRAM_CLK_PIN),
	.cs_pin(SDRAM_CS_PIN),
	.ras_pin(SDRAM_RAS_PIN),
	.cas_pin(SDRAM_CAS_PIN),
	.we_pin(SDRAM_WE_PIN),
	
	.addr_pins(SDRAM_ADDR_PINS),
	.bank_pins(SDRAM_BANK_PINS),
	
	
	.mask_pins(SDRAM_MASK_PINS));


uart_controller	b2v_inst6(
	.clk(clk_50_mhz),
	.rst(btn_rst),
	.en(1),
	
	
	.rx_pin(UART_RX_PIN),
	
	
	
	.tx_pin(UART_TX_PIN)
	);
	defparam	b2v_inst6.BAUD_RATE = 9600;


sev_seg_bus_interface	b2v_inst7(
	.clk(clk_50_mhz),
	.rst(btn_rst),
	.rd_bus(rd_bus),
	.wr_bus(wr_bus),
	.addr_bus(addr_bus),
	.data_bus(data_bus),
	.data_mask_bus(data_mask_bus),
	.ctrl_en(SYNTHESIZED_WIRE_0),
	.fc_bus(fc_bus),
	.ctrl_digit_0(SYNTHESIZED_WIRE_1),
	.ctrl_digit_1(SYNTHESIZED_WIRE_2),
	.ctrl_digit_2(SYNTHESIZED_WIRE_3),
	.ctrl_digit_3(SYNTHESIZED_WIRE_4),
	.ctrl_dots(SYNTHESIZED_WIRE_5)
	);
	defparam	b2v_inst7.CONTROL_REG_ADDR = 32'b01110000000000000000000000100000;
	defparam	b2v_inst7.DATA_DIGITS_REG_ADDR = 32'b01110000000000000000000000101000;
	defparam	b2v_inst7.DATA_DOTS_REG_ADDR = 32'b01110000000000000000000000101100;
	defparam	b2v_inst7.STATUS_REG_ADDR = 32'b01110000000000000000000000100100;


ir_controller	b2v_inst8(
	.clk(clk_50_mhz),
	.rst(btn_rst),
	.en(1),
	
	.data_pin(IR_PIN)
	
	);


buzzer_controller	b2v_inst9(
	.en(SYNTHESIZED_WIRE_20),
	.buzz(SYNTHESIZED_WIRE_21),
	.buzzer_pin(BUZZ_PIN));

endmodule

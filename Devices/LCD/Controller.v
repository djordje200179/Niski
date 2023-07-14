module lcd_controller (
    clk, rst, en,
    rs_pin, rw_pin, e_pin, data_pins
);
    input clk, rst, en;

    output rs_pin, rw_pin, e_pin;
    output [7:0] data_pins;

endmodule
## Generated SDC file "C:/Programiranje/Projekti/Niski/Hardware/Clocks/Timings.sdc"

## Copyright (C) 2023  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and any partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details, at
## https://fpgasoftware.intel.com/eula.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 22.1std.1 Build 917 02/14/2023 SC Lite Edition"

## DATE    "Mon Oct  9 22:12:40 2023"

##
## DEVICE  "EP4CE6E22C8"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk_50_mhz} -period 20.000 -waveform { 0.000 10.000 } [get_ports {CLK_PIN}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {inst17|altpll_component|auto_generated|pll1|clk[1]} -source [get_pins {inst17|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 1 -divide_by 25000 -master_clock {clk_50_mhz} [get_pins {inst17|altpll_component|auto_generated|pll1|clk[1]}] 
create_generated_clock -name {clk_1_khz} -source [get_pins {inst17|altpll_component|auto_generated|pll1|clk[1]}] -divide_by 2 -master_clock {inst17|altpll_component|auto_generated|pll1|clk[1]} [get_nets {inst24|clk_1_khz}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************



#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************


create_clock -period 10.000 -name sys_clk_pin [get_ports clk]

set_operating_conditions -process maximum
set_load 5.000 [all_outputs]
set_property LOAD 5 [get_ports {OUTDATA[0]}]
set_property LOAD 5 [get_ports {OUTDATA[10]}]
set_property LOAD 5 [get_ports {OUTDATA[11]}]
set_property LOAD 5 [get_ports {OUTDATA[1]}]
set_property LOAD 5 [get_ports {OUTDATA[2]}]
set_property LOAD 5 [get_ports {OUTDATA[3]}]
set_property LOAD 5 [get_ports {OUTDATA[4]}]
set_property LOAD 5 [get_ports {OUTDATA[5]}]
set_property LOAD 5 [get_ports {OUTDATA[6]}]
set_property LOAD 5 [get_ports {OUTDATA[7]}]
set_property LOAD 5 [get_ports {OUTDATA[8]}]
set_property LOAD 5 [get_ports {OUTDATA[9]}]
set_property LOAD 5 [get_ports System_ReadyO]
set_switching_activity -default_toggle_rate 87.500

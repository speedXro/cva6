
set bdName sila02
create_bd_design $bdName

create_bd_cell -type ip -vlnv xilinx.com:ip:system_ila:1.1 ila_0

set_property -dict [list \
    CONFIG.C_MON_TYPE {INTERFACE} \
    CONFIG.C_NUM_MONITOR_SLOTS {4} \
    CONFIG.C_DATA_DEPTH {1024} \
    CONFIG.C_SLOT_0_INTF_TYPE {xilinx.com:interface:aximm_rtl:1.0} \
    CONFIG.C_SLOT_1_INTF_TYPE {xilinx.com:interface:aximm_rtl:1.0} \
    CONFIG.C_SLOT_2_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0} \
    CONFIG.C_SLOT_3_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0} \
] [get_bd_cells ila_0]


create_bd_port -dir I -type clk aclk
connect_bd_net [get_bd_ports aclk] [get_bd_pins ila_0/clk]


create_bd_intf_port -mode Monitor -vlnv xilinx.com:interface:aximm_rtl:1.0 MON_S00
set_property -dict [list CONFIG.PROTOCOL {AXI4} CONFIG.DATA_WIDTH {32} \
    CONFIG.ADDR_WIDTH {64} CONFIG.ID_WIDTH {7} CONFIG.FREQ_HZ {100000000} \
    CONFIG.CLK_DOMAIN {slave_clk}] [get_bd_intf_ports MON_S00]

create_bd_intf_port -mode Monitor -vlnv xilinx.com:interface:aximm_rtl:1.0 MON_S01
set_property -dict [list CONFIG.PROTOCOL {AXI4} CONFIG.DATA_WIDTH {64} \
    CONFIG.ADDR_WIDTH {64} CONFIG.ID_WIDTH {7} CONFIG.FREQ_HZ {100000000} \
    CONFIG.CLK_DOMAIN {slave_clk}] [get_bd_intf_ports MON_S01]


create_bd_intf_port -mode Monitor -vlnv xilinx.com:interface:axis_rtl:1.0 MON_AXIS0
set_property -dict [list CONFIG.TDATA_NUM_BYTES {2} CONFIG.HAS_TKEEP {1} \
    CONFIG.HAS_TLAST {1} CONFIG.HAS_TSTRB {0} CONFIG.HAS_TREADY {1} \
    CONFIG.TID_WIDTH {0} CONFIG.TDEST_WIDTH {0} CONFIG.TUSER_WIDTH {0} \
    CONFIG.FREQ_HZ {100000000} CONFIG.CLK_DOMAIN {slave_clk}] \
    [get_bd_intf_ports MON_AXIS0]

create_bd_intf_port -mode Monitor -vlnv xilinx.com:interface:axis_rtl:1.0 MON_AXIS1
set_property -dict [list CONFIG.TDATA_NUM_BYTES {4} CONFIG.HAS_TKEEP {1} \
    CONFIG.HAS_TLAST {1} CONFIG.HAS_TSTRB {0} CONFIG.HAS_TREADY {1} \
    CONFIG.TID_WIDTH {0} CONFIG.TDEST_WIDTH {0} CONFIG.TUSER_WIDTH {0} \
    CONFIG.FREQ_HZ {100000000} CONFIG.CLK_DOMAIN {slave_clk}] \
    [get_bd_intf_ports MON_AXIS1]

set_property -dict [list \
    CONFIG.C_SLOT_0_AXI_ADDR_WIDTH {64} \
    CONFIG.C_SLOT_0_AXI_DATA_WIDTH {32} \
    CONFIG.C_SLOT_1_AXI_ADDR_WIDTH {64} \
    CONFIG.C_SLOT_1_AXI_DATA_WIDTH {64} \
    CONFIG.C_SLOT_2_AXIS_TDATA_WIDTH {16} \
    CONFIG.C_SLOT_3_AXIS_TDATA_WIDTH {32} \
] [get_bd_cells ila_0]

# connect AFTER widths are set
connect_bd_intf_net [get_bd_intf_ports MON_S00]   [get_bd_intf_pins ila_0/SLOT_0_AXI]
connect_bd_intf_net [get_bd_intf_ports MON_S01]   [get_bd_intf_pins ila_0/SLOT_1_AXI]
connect_bd_intf_net [get_bd_intf_ports MON_AXIS0] [get_bd_intf_pins ila_0/SLOT_2_AXIS]
connect_bd_intf_net [get_bd_intf_ports MON_AXIS1] [get_bd_intf_pins ila_0/SLOT_3_AXIS]


set_property -dict [list CONFIG.ASSOCIATED_BUSIF {MON_S00:MON_S01:MON_AXIS0:MON_AXIS1} \
    CONFIG.CLK_DOMAIN {slave_clk} CONFIG.FREQ_HZ {100000000}] [get_bd_ports aclk]

validate_bd_design

foreach {slot want_d} {0 32 1 64} {
    set got_d [get_property CONFIG.C_SLOT_${slot}_AXI_DATA_WIDTH [get_bd_cells ila_0]]
    set got_a [get_property CONFIG.C_SLOT_${slot}_AXI_ADDR_WIDTH [get_bd_cells ila_0]]
    puts "sila02: SLOT_$slot AXI DATA=$got_d ADDR=$got_a"
    if {$got_d != $want_d} { error "sila02: SLOT_$slot data $got_d, expected $want_d" }
    if {$got_a != 64}      { error "sila02: SLOT_$slot addr $got_a, expected 64" }
}

foreach {slot want_b} {2 16 3 32} {
    set got [get_property CONFIG.C_SLOT_${slot}_AXIS_TDATA_WIDTH [get_bd_cells ila_0]]
    puts "sila02: SLOT_$slot AXIS TDATA_WIDTH=$got"
    if {$got != $want_b} { error "sila02: SLOT_$slot tdata $got bits, expected $want_b" }
}

save_bd_design

reset_target all [get_files sila02.bd]
generate_target all [get_files sila02.bd]

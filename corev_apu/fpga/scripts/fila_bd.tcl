
set bdName fila
create_bd_design $bdName


create_bd_cell -type ip -vlnv xilinx.com:ip:system_ila:1.1 ila_slv
set_property -dict [list \
    CONFIG.C_MON_TYPE {INTERFACE} \
    CONFIG.C_NUM_MONITOR_SLOTS {3} \
    CONFIG.C_DATA_DEPTH {1024} \
    CONFIG.C_SLOT_0_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0} \
    CONFIG.C_SLOT_1_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0} \
    CONFIG.C_SLOT_2_INTF_TYPE {xilinx.com:interface:aximm_rtl:1.0} \
] [get_bd_cells ila_slv]


create_bd_cell -type ip -vlnv xilinx.com:ip:system_ila:1.1 ila_mig
set_property -dict [list \
    CONFIG.C_MON_TYPE {INTERFACE} \
    CONFIG.C_NUM_MONITOR_SLOTS {1} \
    CONFIG.C_DATA_DEPTH {1024} \
    CONFIG.C_SLOT_0_INTF_TYPE {xilinx.com:interface:aximm_rtl:1.0} \
] [get_bd_cells ila_mig]


create_bd_port -dir I -type clk aclk
create_bd_port -dir I -type clk aclk1
connect_bd_net [get_bd_ports aclk]  [get_bd_pins ila_slv/clk]
connect_bd_net [get_bd_ports aclk1] [get_bd_pins ila_mig/clk]


create_bd_intf_port -mode Monitor -vlnv xilinx.com:interface:axis_rtl:1.0 AXIS_FDCT_IN
set_property -dict [list CONFIG.TDATA_NUM_BYTES {64} CONFIG.HAS_TKEEP {1} \
    CONFIG.HAS_TLAST {1} CONFIG.HAS_TSTRB {0} CONFIG.HAS_TREADY {1} \
    CONFIG.TID_WIDTH {0} CONFIG.TDEST_WIDTH {0} CONFIG.TUSER_WIDTH {0} \
    CONFIG.FREQ_HZ {100000000} CONFIG.CLK_DOMAIN {slave_clk}] \
    [get_bd_intf_ports AXIS_FDCT_IN]

create_bd_intf_port -mode Monitor -vlnv xilinx.com:interface:axis_rtl:1.0 AXIS_FDCT_OUT
set_property -dict [list CONFIG.TDATA_NUM_BYTES {128} CONFIG.HAS_TKEEP {1} \
    CONFIG.HAS_TLAST {1} CONFIG.HAS_TSTRB {0} CONFIG.HAS_TREADY {1} \
    CONFIG.TID_WIDTH {0} CONFIG.TDEST_WIDTH {0} CONFIG.TUSER_WIDTH {0} \
    CONFIG.FREQ_HZ {100000000} CONFIG.CLK_DOMAIN {slave_clk}] \
    [get_bd_intf_ports AXIS_FDCT_OUT]


create_bd_intf_port -mode Monitor -vlnv xilinx.com:interface:aximm_rtl:1.0 AXI_FDCT
set_property -dict [list CONFIG.PROTOCOL {AXI4} CONFIG.DATA_WIDTH {64} \
    CONFIG.ADDR_WIDTH {64} CONFIG.ID_WIDTH {0} CONFIG.FREQ_HZ {100000000} \
    CONFIG.CLK_DOMAIN {slave_clk}] [get_bd_intf_ports AXI_FDCT]

create_bd_intf_port -mode Monitor -vlnv xilinx.com:interface:aximm_rtl:1.0 AXI_MIG
set_property -dict [list CONFIG.PROTOCOL {AXI4} CONFIG.DATA_WIDTH {256} \
    CONFIG.ADDR_WIDTH {30} CONFIG.ID_WIDTH {0} CONFIG.FREQ_HZ {200000000} \
    CONFIG.CLK_DOMAIN {mig_clk}] [get_bd_intf_ports AXI_MIG]

set_property -dict [list \
    CONFIG.C_SLOT_0_AXIS_TDATA_WIDTH {512} \
    CONFIG.C_SLOT_1_AXIS_TDATA_WIDTH {1024} \
    CONFIG.C_SLOT_2_AXI_ADDR_WIDTH {64} \
    CONFIG.C_SLOT_2_AXI_DATA_WIDTH {64} \
] [get_bd_cells ila_slv]

set_property -dict [list \
    CONFIG.C_SLOT_0_AXI_ADDR_WIDTH {30} \
    CONFIG.C_SLOT_0_AXI_DATA_WIDTH {256} \
] [get_bd_cells ila_mig]

connect_bd_intf_net [get_bd_intf_ports AXIS_FDCT_IN]  [get_bd_intf_pins ila_slv/SLOT_0_AXIS]
connect_bd_intf_net [get_bd_intf_ports AXIS_FDCT_OUT] [get_bd_intf_pins ila_slv/SLOT_1_AXIS]
connect_bd_intf_net [get_bd_intf_ports AXI_FDCT]      [get_bd_intf_pins ila_slv/SLOT_2_AXI]
connect_bd_intf_net [get_bd_intf_ports AXI_MIG]       [get_bd_intf_pins ila_mig/SLOT_0_AXI]

set_property -dict [list CONFIG.ASSOCIATED_BUSIF \
    {AXIS_FDCT_IN:AXIS_FDCT_OUT:AXI_FDCT} \
    CONFIG.CLK_DOMAIN {slave_clk} CONFIG.FREQ_HZ {100000000}] [get_bd_ports aclk]
set_property -dict [list CONFIG.ASSOCIATED_BUSIF {AXI_MIG} \
    CONFIG.CLK_DOMAIN {mig_clk} CONFIG.FREQ_HZ {200000000}] [get_bd_ports aclk1]

validate_bd_design


foreach {slot want} {0 512 1 1024} {
    set got [get_property CONFIG.C_SLOT_${slot}_AXIS_TDATA_WIDTH [get_bd_cells ila_slv]]
    puts "fila: ila_slv SLOT_$slot AXIS TDATA_WIDTH=$got"
    if {$got != $want} { error "fila: ila_slv SLOT_$slot tdata $got, expected $want" }
}

set d [get_property CONFIG.C_SLOT_2_AXI_DATA_WIDTH [get_bd_cells ila_slv]]
set a [get_property CONFIG.C_SLOT_2_AXI_ADDR_WIDTH [get_bd_cells ila_slv]]
puts "fila: ila_slv SLOT_2 AXI DATA=$d ADDR=$a"
if {$d != 64 || $a != 64} { error "fila: ila_slv SLOT_2 expected 64/64, got $d/$a" }

set d [get_property CONFIG.C_SLOT_0_AXI_DATA_WIDTH [get_bd_cells ila_mig]]
set a [get_property CONFIG.C_SLOT_0_AXI_ADDR_WIDTH [get_bd_cells ila_mig]]
puts "fila: ila_mig SLOT_0 AXI DATA=$d ADDR=$a"
if {$d != 256 || $a != 30} { error "fila: ila_mig SLOT_0 expected 256/30, got $d/$a" }

save_bd_design

reset_target all [get_files fila.bd]
generate_target all [get_files fila.bd]

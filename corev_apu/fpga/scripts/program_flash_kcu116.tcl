# program_flash_kcu116.tcl
#
# Usage:
#   vivado -mode batch -nolog -nojournal \
#          -source program_flash_kcu116.tcl \
#          -tclargs work-fpga/ariane_xilinx.mcs work-fpga/ariane_xilinx.bit
#
if {$argc < 2 || $argc > 3} {
    puts {Error: Invalid number of arguments}
    puts {Usage: program_flash_kcu116.tcl mcsfile bitfile [datafile]}
    exit 1
}

lassign $argv mcsfile bitfile datafile

set hw_target  {localhost:3121/xilinx_tcf/Digilent/210308AE5B0C}
set hw_part    xcku5p_0
set cfgmem_part {mt25qu01g-spi-x1_x2_x4}

# ---------------------------------------------------------------- build the mcs
if {$datafile ne {}} {
    write_cfgmem -format mcs -interface SPIx4 -size 512 \
        -loadbit "up 0x00000000 $bitfile" \
        -loaddata "up 0x01000000 $datafile" \
        -file $mcsfile -force
} else {
    write_cfgmem -format mcs -interface SPIx4 -size 512 \
        -loadbit "up 0x00000000 $bitfile" \
        -file $mcsfile -force
}

# ------------------------------------------------------------- open the hardware
open_hw_manager
connect_hw_server -url localhost:3121
open_hw_target $hw_target

set device [get_hw_devices $hw_part]
current_hw_device $device
refresh_hw_device -update_hw_probes false $device

# ------------------------------------------------------- attach the flash device
create_hw_cfgmem -hw_device $device [lindex [get_cfgmem_parts $cfgmem_part] 0]
set cfgmem [get_property PROGRAM.HW_CFGMEM $device]

set_property PROGRAM.BLANK_CHECK              0            $cfgmem
set_property PROGRAM.ERASE                    1            $cfgmem
set_property PROGRAM.CFG_PROGRAM              1            $cfgmem
set_property PROGRAM.VERIFY                   1            $cfgmem
set_property PROGRAM.CHECKSUM                 0            $cfgmem
set_property PROGRAM.ADDRESS_RANGE            {use_file}   $cfgmem
set_property PROGRAM.FILES                    [list $mcsfile] $cfgmem
set_property PROGRAM.PRM_FILE                 {}           $cfgmem
set_property PROGRAM.UNUSED_PIN_TERMINATION   {pull-none}  $cfgmem


create_hw_bitstream -hw_device $device \
    [get_property PROGRAM.HW_CFGMEM_BITFILE $device]
program_hw_devices $device
refresh_hw_device $device

program_hw_cfgmem -hw_cfgmem $cfgmem


boot_hw_device $device

close_hw_target
disconnect_hw_server
close_hw_manager
exit 0
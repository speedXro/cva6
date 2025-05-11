#set partNumber xcku5p-ffvb676-2-e
#set boardName  xilinx.com:kcu116:part0:1.5
#set boardNameShort kcu116 
set partNumber $::env(XILINX_PART)
set boardName  $::env(XILINX_BOARD)
set boardNameShort $::env(BOARD)

set ipName xlnx_mig_ddr4

create_project $ipName . -force -part $partNumber
set_property board_part $boardName [current_project]

create_ip -name ddr4 -vendor xilinx.com -library ip -version 2.2 -module_name $ipName


set_property -dict [list \
        CONFIG.C0_DDR4_BOARD_INTERFACE {ddr4_sdram_075} \
        CONFIG.System_Clock {Differential} \
	CONFIG.ADDN_UI_CLKOUT1_FREQ_HZ {200} \
	CONFIG.C0.DDR4_AxiAddressWidth {30} \
  	CONFIG.C0.DDR4_AxiDataWidth {256} \
  	CONFIG.C0.DDR4_AxiSelection {false} \
  	CONFIG.C0.DDR4_DataWidth {32} \
  	CONFIG.C0.DDR4_InputClockPeriod {3334} \
  	CONFIG.C0.DDR4_MemoryPart {MT40A256M16GE-075E} \
  	CONFIG.C0_CLOCK_BOARD_INTERFACE {default_sysclk1_300} \
  	CONFIG.Debug_Signal {Disable} \
  	CONFIG.Example_TG {ADVANCED_TG} \
] [get_ips $ipName]

set_property -dict [list\
  	CONFIG.C0.DDR4_AxiNarrowBurst {false} \
  	CONFIG.C0.DDR4_AxiSelection {true} \
] [get_ips $ipName]

generate_target {instantiation_template} [get_files ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
generate_target all [get_files  ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
create_ip_run [get_files -of_objects [get_fileset sources_1] ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
launch_run -jobs 8 ${ipName}_synth_1
wait_on_run ${ipName}_synth_1

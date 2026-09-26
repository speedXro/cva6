#set partNumber xcku5p-ffvb676-2-e
#set boardName  xilinx.com:kcu116:part0:1.5
#set boardNameShort kcu116 
set partNumber $::env(XILINX_PART)
set boardName  $::env(XILINX_BOARD)
set boardNameShort $::env(BOARD)

set ipName xlnx_axi_dma_512_1024

create_project $ipName . -force -part $partNumber
set_property board_part $boardName [current_project]

create_ip -name axi_dma -vendor xilinx.com -library ip -module_name $ipName

set_property -dict [list \
  CONFIG.c_addr_width {64} \
  CONFIG.c_sg_length_width {17} \
  CONFIG.c_include_sg {0} \
  CONFIG.c_m_axi_mm2s_data_width {512} \
  CONFIG.c_m_axi_s2mm_data_width {1024} \
  CONFIG.c_m_axis_mm2s_tdata_width {512} \
  CONFIG.c_s_axis_s2mm_tdata_width {1024} \
  CONFIG.c_mm2s_burst_size {32} \
  CONFIG.c_s2mm_burst_size {32} \
  CONFIG.c_include_mm2s_dre {1} \
  CONFIG.c_include_s2mm_dre {1} \
  CONFIG.c_sg_include_stscntrl_strm {0} \
] [get_ips $ipName]

generate_target {instantiation_template} [get_files ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
generate_target all [get_files  ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
create_ip_run [get_files -of_objects [get_fileset sources_1] ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
launch_run -jobs 8 ${ipName}_synth_1
wait_on_run ${ipName}_synth_1


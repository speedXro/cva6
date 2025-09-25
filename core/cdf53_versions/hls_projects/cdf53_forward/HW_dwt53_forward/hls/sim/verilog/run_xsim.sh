
/tools/Xilinx/Vivado/2024.2/bin/xelab xil_defaultlib.apatb_HW_dwt53_forward_top glbl -Oenable_linking_all_libraries  -prj HW_dwt53_forward.prj -L smartconnect_v1_0 -L axi_protocol_checker_v1_1_12 -L axi_protocol_checker_v1_1_13 -L axis_protocol_checker_v1_1_11 -L axis_protocol_checker_v1_1_12 -L xil_defaultlib -L unisims_ver -L xpm  -L floating_point_v7_0_24 -L floating_point_v7_1_19 --lib "ieee_proposed=./ieee_proposed" -s HW_dwt53_forward 
/tools/Xilinx/Vivado/2024.2/bin/xsim --noieeewarnings HW_dwt53_forward -tclbatch HW_dwt53_forward.tcl 


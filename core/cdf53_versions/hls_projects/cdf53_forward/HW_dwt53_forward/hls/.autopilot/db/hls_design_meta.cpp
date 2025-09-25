#include "hls_design_meta.h"
const Port_Property HLS_Design_Meta::port_props[]={
	Port_Property("ap_clk", 1, hls_in, -1, "", "", 1),
	Port_Property("ap_rst", 1, hls_in, -1, "", "", 1),
	Port_Property("ap_start", 1, hls_in, -1, "", "", 1),
	Port_Property("ap_done", 1, hls_out, -1, "", "", 1),
	Port_Property("ap_idle", 1, hls_out, -1, "", "", 1),
	Port_Property("ap_ready", 1, hls_out, -1, "", "", 1),
	Port_Property("op1", 64, hls_in, 0, "ap_none", "in_data", 1),
	Port_Property("op2", 64, hls_in, 1, "ap_none", "in_data", 1),
	Port_Property("p_low_03", 64, hls_out, 2, "ap_vld", "out_data", 1),
	Port_Property("p_low_03_ap_vld", 1, hls_out, 2, "ap_vld", "out_vld", 1),
	Port_Property("p_low_47", 64, hls_out, 3, "ap_vld", "out_data", 1),
	Port_Property("p_low_47_ap_vld", 1, hls_out, 3, "ap_vld", "out_vld", 1),
	Port_Property("p_high_03", 64, hls_out, 4, "ap_vld", "out_data", 1),
	Port_Property("p_high_03_ap_vld", 1, hls_out, 4, "ap_vld", "out_vld", 1),
	Port_Property("p_high_47", 64, hls_out, 5, "ap_vld", "out_data", 1),
	Port_Property("p_high_47_ap_vld", 1, hls_out, 5, "ap_vld", "out_vld", 1),
};
const char* HLS_Design_Meta::dut_name = "HW_dwt53_forward";

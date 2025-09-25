set moduleName HW_dwt53_inverse
set isTopModule 1
set isCombinational 0
set isDatapathOnly 0
set isPipelined 0
set pipeline_type none
set FunctionProtocol ap_ctrl_hs
set isOneStateSeq 0
set ProfileFlag 0
set StallSigGenFlag 0
set isEnableWaveformDebug 1
set hasInterrupt 0
set DLRegFirstOffset 0
set DLRegItemOffset 0
set svuvm_can_support 1
set cdfgNum 3
set C_modelName {HW_dwt53_inverse}
set C_modelType { void 0 }
set ap_memory_interface_dict [dict create]
set C_modelArgList {
	{ low_03 int 64 regular  }
	{ low_47 int 64 regular  }
	{ high_03 int 64 regular  }
	{ high_47 int 64 regular  }
	{ p_out_0 int 64 regular {pointer 1}  }
	{ p_out_1 int 64 regular {pointer 1}  }
}
set hasAXIMCache 0
set l_AXIML2Cache [list]
set AXIMCacheInstDict [dict create]
set C_modelArgMapList {[ 
	{ "Name" : "low_03", "interface" : "wire", "bitwidth" : 64, "direction" : "READONLY"} , 
 	{ "Name" : "low_47", "interface" : "wire", "bitwidth" : 64, "direction" : "READONLY"} , 
 	{ "Name" : "high_03", "interface" : "wire", "bitwidth" : 64, "direction" : "READONLY"} , 
 	{ "Name" : "high_47", "interface" : "wire", "bitwidth" : 64, "direction" : "READONLY"} , 
 	{ "Name" : "p_out_0", "interface" : "wire", "bitwidth" : 64, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out_1", "interface" : "wire", "bitwidth" : 64, "direction" : "WRITEONLY"} ]}
# RTL Port declarations: 
set portNum 14
set portList { 
	{ ap_clk sc_in sc_logic 1 clock -1 } 
	{ ap_rst sc_in sc_logic 1 reset -1 active_high_sync } 
	{ ap_start sc_in sc_logic 1 start -1 } 
	{ ap_done sc_out sc_logic 1 predone -1 } 
	{ ap_idle sc_out sc_logic 1 done -1 } 
	{ ap_ready sc_out sc_logic 1 ready -1 } 
	{ low_03 sc_in sc_lv 64 signal 0 } 
	{ low_47 sc_in sc_lv 64 signal 1 } 
	{ high_03 sc_in sc_lv 64 signal 2 } 
	{ high_47 sc_in sc_lv 64 signal 3 } 
	{ p_out_0 sc_out sc_lv 64 signal 4 } 
	{ p_out_0_ap_vld sc_out sc_logic 1 outvld 4 } 
	{ p_out_1 sc_out sc_lv 64 signal 5 } 
	{ p_out_1_ap_vld sc_out sc_logic 1 outvld 5 } 
}
set NewPortList {[ 
	{ "name": "ap_clk", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "clock", "bundle":{"name": "ap_clk", "role": "default" }} , 
 	{ "name": "ap_rst", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "reset", "bundle":{"name": "ap_rst", "role": "default" }} , 
 	{ "name": "ap_start", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "start", "bundle":{"name": "ap_start", "role": "default" }} , 
 	{ "name": "ap_done", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "predone", "bundle":{"name": "ap_done", "role": "default" }} , 
 	{ "name": "ap_idle", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "done", "bundle":{"name": "ap_idle", "role": "default" }} , 
 	{ "name": "ap_ready", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "ready", "bundle":{"name": "ap_ready", "role": "default" }} , 
 	{ "name": "low_03", "direction": "in", "datatype": "sc_lv", "bitwidth":64, "type": "signal", "bundle":{"name": "low_03", "role": "default" }} , 
 	{ "name": "low_47", "direction": "in", "datatype": "sc_lv", "bitwidth":64, "type": "signal", "bundle":{"name": "low_47", "role": "default" }} , 
 	{ "name": "high_03", "direction": "in", "datatype": "sc_lv", "bitwidth":64, "type": "signal", "bundle":{"name": "high_03", "role": "default" }} , 
 	{ "name": "high_47", "direction": "in", "datatype": "sc_lv", "bitwidth":64, "type": "signal", "bundle":{"name": "high_47", "role": "default" }} , 
 	{ "name": "p_out_0", "direction": "out", "datatype": "sc_lv", "bitwidth":64, "type": "signal", "bundle":{"name": "p_out_0", "role": "default" }} , 
 	{ "name": "p_out_0_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out_0", "role": "ap_vld" }} , 
 	{ "name": "p_out_1", "direction": "out", "datatype": "sc_lv", "bitwidth":64, "type": "signal", "bundle":{"name": "p_out_1", "role": "default" }} , 
 	{ "name": "p_out_1_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out_1", "role": "ap_vld" }}  ]}

set RtlHierarchyInfo {[
	{"ID" : "0", "Level" : "0", "Path" : "`AUTOTB_DUT_INST", "Parent" : "", "Child" : ["1"],
		"CDFG" : "HW_dwt53_inverse",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "0", "ap_idle" : "1", "real_start" : "0",
		"Pipeline" : "None", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "0",
		"VariableLatency" : "1", "ExactLatency" : "-1", "EstimateLatencyMin" : "1", "EstimateLatencyMax" : "1",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"IsBlackBox" : "0",
		"Port" : [
			{"Name" : "low_03", "Type" : "None", "Direction" : "I"},
			{"Name" : "low_47", "Type" : "None", "Direction" : "I"},
			{"Name" : "high_03", "Type" : "None", "Direction" : "I"},
			{"Name" : "high_47", "Type" : "None", "Direction" : "I"},
			{"Name" : "p_out_0", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out_1", "Type" : "Vld", "Direction" : "O"}]},
	{"ID" : "1", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.call_ret_HW_dwt53_inverse_core_fu_94", "Parent" : "0",
		"CDFG" : "HW_dwt53_inverse_core",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "0", "ap_start" : "0", "ap_ready" : "1", "ap_done" : "0", "ap_continue" : "0", "ap_idle" : "0", "real_start" : "0",
		"Pipeline" : "None", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "1",
		"VariableLatency" : "0", "ExactLatency" : "0", "EstimateLatencyMin" : "0", "EstimateLatencyMax" : "0",
		"Combinational" : "1",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"IsBlackBox" : "0",
		"Port" : [
			{"Name" : "low_read", "Type" : "None", "Direction" : "I"},
			{"Name" : "low_read_23", "Type" : "None", "Direction" : "I"},
			{"Name" : "low_read_24", "Type" : "None", "Direction" : "I"},
			{"Name" : "low_read_25", "Type" : "None", "Direction" : "I"},
			{"Name" : "low_read_26", "Type" : "None", "Direction" : "I"},
			{"Name" : "low_read_27", "Type" : "None", "Direction" : "I"},
			{"Name" : "low_read_28", "Type" : "None", "Direction" : "I"},
			{"Name" : "low_read_29", "Type" : "None", "Direction" : "I"},
			{"Name" : "high_read", "Type" : "None", "Direction" : "I"},
			{"Name" : "high_read_23", "Type" : "None", "Direction" : "I"},
			{"Name" : "high_read_24", "Type" : "None", "Direction" : "I"},
			{"Name" : "high_read_25", "Type" : "None", "Direction" : "I"},
			{"Name" : "high_read_26", "Type" : "None", "Direction" : "I"},
			{"Name" : "high_read_27", "Type" : "None", "Direction" : "I"},
			{"Name" : "high_read_28", "Type" : "None", "Direction" : "I"},
			{"Name" : "high_read_29", "Type" : "None", "Direction" : "I"}]}]}


set ArgLastReadFirstWriteLatency {
	HW_dwt53_inverse {
		low_03 {Type I LastRead 0 FirstWrite -1}
		low_47 {Type I LastRead 0 FirstWrite -1}
		high_03 {Type I LastRead 0 FirstWrite -1}
		high_47 {Type I LastRead 0 FirstWrite -1}
		p_out_0 {Type O LastRead -1 FirstWrite 0}
		p_out_1 {Type O LastRead -1 FirstWrite 0}}
	HW_dwt53_inverse_core {
		low_read {Type I LastRead 0 FirstWrite -1}
		low_read_23 {Type I LastRead 0 FirstWrite -1}
		low_read_24 {Type I LastRead 0 FirstWrite -1}
		low_read_25 {Type I LastRead 0 FirstWrite -1}
		low_read_26 {Type I LastRead 0 FirstWrite -1}
		low_read_27 {Type I LastRead 0 FirstWrite -1}
		low_read_28 {Type I LastRead 0 FirstWrite -1}
		low_read_29 {Type I LastRead 0 FirstWrite -1}
		high_read {Type I LastRead 0 FirstWrite -1}
		high_read_23 {Type I LastRead 0 FirstWrite -1}
		high_read_24 {Type I LastRead 0 FirstWrite -1}
		high_read_25 {Type I LastRead 0 FirstWrite -1}
		high_read_26 {Type I LastRead 0 FirstWrite -1}
		high_read_27 {Type I LastRead 0 FirstWrite -1}
		high_read_28 {Type I LastRead 0 FirstWrite -1}
		high_read_29 {Type I LastRead 0 FirstWrite -1}}}

set hasDtUnsupportedChannel 0

set PerformanceInfo {[
	{"Name" : "Latency", "Min" : "1", "Max" : "1"}
	, {"Name" : "Interval", "Min" : "2", "Max" : "2"}
]}

set PipelineEnableSignalInfo {[
]}

set Spec2ImplPortList { 
	low_03 { ap_none {  { low_03 in_data 0 64 } } }
	low_47 { ap_none {  { low_47 in_data 0 64 } } }
	high_03 { ap_none {  { high_03 in_data 0 64 } } }
	high_47 { ap_none {  { high_47 in_data 0 64 } } }
	p_out_0 { ap_vld {  { p_out_0 out_data 1 64 }  { p_out_0_ap_vld out_vld 1 1 } } }
	p_out_1 { ap_vld {  { p_out_1 out_data 1 64 }  { p_out_1_ap_vld out_vld 1 1 } } }
}

set maxi_interface_dict [dict create]

# RTL port scheduling information:
set fifoSchedulingInfoList { 
}

# RTL bus port read request latency information:
set busReadReqLatencyList { 
}

# RTL bus port write response latency information:
set busWriteResLatencyList { 
}

# RTL array port load latency information:
set memoryLoadLatencyList { 
}

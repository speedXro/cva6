set moduleName HW_dwt53_inverse_core
set isTopModule 0
set isCombinational 1
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
set C_modelName {HW_dwt53_inverse_core}
set C_modelType { int 128 }
set ap_memory_interface_dict [dict create]
set C_modelArgList {
	{ low_read int 16 regular  }
	{ low_read_23 int 16 regular  }
	{ low_read_24 int 16 regular  }
	{ low_read_25 int 16 regular  }
	{ low_read_26 int 16 regular  }
	{ low_read_27 int 16 regular  }
	{ low_read_28 int 16 regular  }
	{ low_read_29 int 16 regular  }
	{ high_read int 16 regular  }
	{ high_read_23 int 16 regular  }
	{ high_read_24 int 16 regular  }
	{ high_read_25 int 16 regular  }
	{ high_read_26 int 16 regular  }
	{ high_read_27 int 16 regular  }
	{ high_read_28 int 16 regular  }
	{ high_read_29 int 16 regular  }
}
set hasAXIMCache 0
set l_AXIML2Cache [list]
set AXIMCacheInstDict [dict create]
set C_modelArgMapList {[ 
	{ "Name" : "low_read", "interface" : "wire", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "low_read_23", "interface" : "wire", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "low_read_24", "interface" : "wire", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "low_read_25", "interface" : "wire", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "low_read_26", "interface" : "wire", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "low_read_27", "interface" : "wire", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "low_read_28", "interface" : "wire", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "low_read_29", "interface" : "wire", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "high_read", "interface" : "wire", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "high_read_23", "interface" : "wire", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "high_read_24", "interface" : "wire", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "high_read_25", "interface" : "wire", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "high_read_26", "interface" : "wire", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "high_read_27", "interface" : "wire", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "high_read_28", "interface" : "wire", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "high_read_29", "interface" : "wire", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "ap_return", "interface" : "wire", "bitwidth" : 128} ]}
# RTL Port declarations: 
set portNum 34
set portList { 
	{ ap_ready sc_out sc_logic 1 ready -1 } 
	{ low_read sc_in sc_lv 16 signal 0 } 
	{ low_read_23 sc_in sc_lv 16 signal 1 } 
	{ low_read_24 sc_in sc_lv 16 signal 2 } 
	{ low_read_25 sc_in sc_lv 16 signal 3 } 
	{ low_read_26 sc_in sc_lv 16 signal 4 } 
	{ low_read_27 sc_in sc_lv 16 signal 5 } 
	{ low_read_28 sc_in sc_lv 16 signal 6 } 
	{ low_read_29 sc_in sc_lv 16 signal 7 } 
	{ high_read sc_in sc_lv 16 signal 8 } 
	{ high_read_23 sc_in sc_lv 16 signal 9 } 
	{ high_read_24 sc_in sc_lv 16 signal 10 } 
	{ high_read_25 sc_in sc_lv 16 signal 11 } 
	{ high_read_26 sc_in sc_lv 16 signal 12 } 
	{ high_read_27 sc_in sc_lv 16 signal 13 } 
	{ high_read_28 sc_in sc_lv 16 signal 14 } 
	{ high_read_29 sc_in sc_lv 16 signal 15 } 
	{ ap_return_0 sc_out sc_lv 8 signal -1 } 
	{ ap_return_1 sc_out sc_lv 8 signal -1 } 
	{ ap_return_2 sc_out sc_lv 8 signal -1 } 
	{ ap_return_3 sc_out sc_lv 8 signal -1 } 
	{ ap_return_4 sc_out sc_lv 8 signal -1 } 
	{ ap_return_5 sc_out sc_lv 8 signal -1 } 
	{ ap_return_6 sc_out sc_lv 8 signal -1 } 
	{ ap_return_7 sc_out sc_lv 8 signal -1 } 
	{ ap_return_8 sc_out sc_lv 8 signal -1 } 
	{ ap_return_9 sc_out sc_lv 8 signal -1 } 
	{ ap_return_10 sc_out sc_lv 8 signal -1 } 
	{ ap_return_11 sc_out sc_lv 8 signal -1 } 
	{ ap_return_12 sc_out sc_lv 8 signal -1 } 
	{ ap_return_13 sc_out sc_lv 8 signal -1 } 
	{ ap_return_14 sc_out sc_lv 8 signal -1 } 
	{ ap_return_15 sc_out sc_lv 8 signal -1 } 
	{ ap_rst sc_in sc_logic 1 reset -1 active_high_sync } 
}
set NewPortList {[ 
	{ "name": "ap_ready", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "ready", "bundle":{"name": "ap_ready", "role": "default" }} , 
 	{ "name": "low_read", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "low_read", "role": "default" }} , 
 	{ "name": "low_read_23", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "low_read_23", "role": "default" }} , 
 	{ "name": "low_read_24", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "low_read_24", "role": "default" }} , 
 	{ "name": "low_read_25", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "low_read_25", "role": "default" }} , 
 	{ "name": "low_read_26", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "low_read_26", "role": "default" }} , 
 	{ "name": "low_read_27", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "low_read_27", "role": "default" }} , 
 	{ "name": "low_read_28", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "low_read_28", "role": "default" }} , 
 	{ "name": "low_read_29", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "low_read_29", "role": "default" }} , 
 	{ "name": "high_read", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "high_read", "role": "default" }} , 
 	{ "name": "high_read_23", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "high_read_23", "role": "default" }} , 
 	{ "name": "high_read_24", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "high_read_24", "role": "default" }} , 
 	{ "name": "high_read_25", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "high_read_25", "role": "default" }} , 
 	{ "name": "high_read_26", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "high_read_26", "role": "default" }} , 
 	{ "name": "high_read_27", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "high_read_27", "role": "default" }} , 
 	{ "name": "high_read_28", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "high_read_28", "role": "default" }} , 
 	{ "name": "high_read_29", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "high_read_29", "role": "default" }} , 
 	{ "name": "ap_return_0", "direction": "out", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "ap_return_0", "role": "default" }} , 
 	{ "name": "ap_return_1", "direction": "out", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "ap_return_1", "role": "default" }} , 
 	{ "name": "ap_return_2", "direction": "out", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "ap_return_2", "role": "default" }} , 
 	{ "name": "ap_return_3", "direction": "out", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "ap_return_3", "role": "default" }} , 
 	{ "name": "ap_return_4", "direction": "out", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "ap_return_4", "role": "default" }} , 
 	{ "name": "ap_return_5", "direction": "out", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "ap_return_5", "role": "default" }} , 
 	{ "name": "ap_return_6", "direction": "out", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "ap_return_6", "role": "default" }} , 
 	{ "name": "ap_return_7", "direction": "out", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "ap_return_7", "role": "default" }} , 
 	{ "name": "ap_return_8", "direction": "out", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "ap_return_8", "role": "default" }} , 
 	{ "name": "ap_return_9", "direction": "out", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "ap_return_9", "role": "default" }} , 
 	{ "name": "ap_return_10", "direction": "out", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "ap_return_10", "role": "default" }} , 
 	{ "name": "ap_return_11", "direction": "out", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "ap_return_11", "role": "default" }} , 
 	{ "name": "ap_return_12", "direction": "out", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "ap_return_12", "role": "default" }} , 
 	{ "name": "ap_return_13", "direction": "out", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "ap_return_13", "role": "default" }} , 
 	{ "name": "ap_return_14", "direction": "out", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "ap_return_14", "role": "default" }} , 
 	{ "name": "ap_return_15", "direction": "out", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "ap_return_15", "role": "default" }} , 
 	{ "name": "ap_rst", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "reset", "bundle":{"name": "ap_rst", "role": "default" }}  ]}

set RtlHierarchyInfo {[
	{"ID" : "0", "Level" : "0", "Path" : "`AUTOTB_DUT_INST", "Parent" : "",
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
	{"Name" : "Latency", "Min" : "0", "Max" : "0"}
	, {"Name" : "Interval", "Min" : "0", "Max" : "0"}
]}

set PipelineEnableSignalInfo {[
]}

set Spec2ImplPortList { 
	low_read { ap_none {  { low_read in_data 0 16 } } }
	low_read_23 { ap_none {  { low_read_23 in_data 0 16 } } }
	low_read_24 { ap_none {  { low_read_24 in_data 0 16 } } }
	low_read_25 { ap_none {  { low_read_25 in_data 0 16 } } }
	low_read_26 { ap_none {  { low_read_26 in_data 0 16 } } }
	low_read_27 { ap_none {  { low_read_27 in_data 0 16 } } }
	low_read_28 { ap_none {  { low_read_28 in_data 0 16 } } }
	low_read_29 { ap_none {  { low_read_29 in_data 0 16 } } }
	high_read { ap_none {  { high_read in_data 0 16 } } }
	high_read_23 { ap_none {  { high_read_23 in_data 0 16 } } }
	high_read_24 { ap_none {  { high_read_24 in_data 0 16 } } }
	high_read_25 { ap_none {  { high_read_25 in_data 0 16 } } }
	high_read_26 { ap_none {  { high_read_26 in_data 0 16 } } }
	high_read_27 { ap_none {  { high_read_27 in_data 0 16 } } }
	high_read_28 { ap_none {  { high_read_28 in_data 0 16 } } }
	high_read_29 { ap_none {  { high_read_29 in_data 0 16 } } }
}

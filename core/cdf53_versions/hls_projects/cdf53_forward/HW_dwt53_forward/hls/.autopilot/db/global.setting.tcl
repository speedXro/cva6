
set TopModule "HW_dwt53_forward"
set ClockPeriod 10
set ClockList ap_clk
set AxiliteClockList {}
set HasVivadoClockPeriod 0
set CombLogicFlag 0
set PipelineFlag 0
set DataflowTaskPipelineFlag 1
set TrivialPipelineFlag 0
set noPortSwitchingFlag 0
set FloatingPointFlag 0
set FftOrFirFlag 0
set NbRWValue 0
set intNbAccess 0
set NewDSPMapping 1
set HasDSPModule 0
set ResetLevelFlag 1
set ResetStyle control
set ResetSyncFlag 1
set ResetRegisterFlag 0
set ResetVariableFlag 0
set ResetRegisterNum 0
set FsmEncStyle onehot
set MaxFanout 0
set RtlPrefix {}
set RtlSubPrefix HW_dwt53_forward_
set ExtraCCFlags {}
set ExtraCLdFlags {}
set SynCheckOptions {}
set PresynOptions {}
set PreprocOptions {}
set SchedOptions {}
set BindOptions {}
set RtlGenOptions {}
set RtlWriterOptions {}
set CbcGenFlag {}
set CasGenFlag {}
set CasMonitorFlag {}
set AutoSimOptions {}
set ExportMCPathFlag 0
set SCTraceFileName mytrace
set SCTraceFileFormat vcd
set SCTraceOption all
set TargetInfo xcku5p:-ffvb676:-2-e
set SourceFiles {sc {} c ../../../c_sources/dwt_idwt_cdf_5_3.c}
set SourceFlags {sc {} c {{}}}
set DirectiveFile {}
set TBFiles {verilog /tools/repos/cva6/core/cdf53_versions/hls_projects/c_sources/main.c bc /tools/repos/cva6/core/cdf53_versions/hls_projects/c_sources/main.c vhdl /tools/repos/cva6/core/cdf53_versions/hls_projects/c_sources/main.c sc /tools/repos/cva6/core/cdf53_versions/hls_projects/c_sources/main.c cas /tools/repos/cva6/core/cdf53_versions/hls_projects/c_sources/main.c c {}}
set SpecLanguage C
set TVInFiles {bc {} c {} sc {} cas {} vhdl {} verilog {}}
set TVOutFiles {bc {} c {} sc {} cas {} vhdl {} verilog {}}
set TBTops {verilog {} bc {} vhdl {} sc {} cas {} c {}}
set TBInstNames {verilog {} bc {} vhdl {} sc {} cas {} c {}}
set XDCFiles {}
set ExtraGlobalOptions {"area_timing" 1 "clock_gate" 1 "impl_flow" map "power_gate" 0}
set TBTVFileNotFound {}
set AppFile {}
set ApsFile hls.aps
set AvePath ../../.
set DefaultPlatform DefaultPlatform
set multiClockList {}
set SCPortClockMap {}
set intNbAccess 0
set PlatformFiles {{DefaultPlatform {xilinx/kintexuplus/kintexuplus}}}
set HPFPO 0

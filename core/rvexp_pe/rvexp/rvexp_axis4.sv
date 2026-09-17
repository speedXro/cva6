`timescale 1ns / 1ps

module rvexp_axis4 (
    input  logic                        clock,
    input  logic                        reset_n,

    //From CV-X-IF Adapter Interface
    input  logic            instr_commit,
    input  logic [ 6:0]     instr_funct7,
    input  logic [ 2:0]     instr_funct3,
    //input  logic [ 6:0]   instr_opcode,
    input  logic [63:0]     instr_rs1_val,
    input  logic [63:0]     instr_rs2_val,
    
    //To CV-X-IF Adapter Interface
    output logic            result_we,
    output logic [   63:0]  result_rd,

    // AXIS4
    input  logic [ 511: 0]  m0_axis_mm2s_tdata, 
    input  logic [  63: 0]  m0_axis_mm2s_tkeep,  
    input  logic            m0_axis_mm2s_tvalid,          
    output logic            m0_axis_mm2s_tready,       
    input  logic            m0_axis_mm2s_tlast,          
    output logic [1023 : 0] s0_axis_s2mm_tdata,
    output logic [ 127 : 0] s0_axis_s2mm_tkeep, 
    output logic            s0_axis_s2mm_tvalid,          
    input  logic            s0_axis_s2mm_tready,         
    output logic            s0_axis_s2mm_tlast,           
	
	input  logic [1023: 0]  m1_axis_mm2s_tdata, 
    input  logic [ 127: 0]  m1_axis_mm2s_tkeep, 
    input  logic            m1_axis_mm2s_tvalid,         
    output logic            m1_axis_mm2s_tready,         
    input  logic            m1_axis_mm2s_tlast,           
    output logic [ 511 : 0] s1_axis_s2mm_tdata, 
    output logic [  63 : 0] s1_axis_s2mm_tkeep,  
    output logic            s1_axis_s2mm_tvalid,           
    input  logic            s1_axis_s2mm_tready,          
    output logic            s1_axis_s2mm_tlast,            

    //AXI4 Lite Interface
	output logic [31 : 0] m0_axi_awaddr,
	output logic [ 2 : 0] m0_axi_awprot,
	output logic          m0_axi_awvalid,
	input  logic          m0_axi_awready,
	output logic [31 : 0] m0_axi_wdata,
	output logic [ 3 : 0] m0_axi_wstrb,
	output logic          m0_axi_wvalid,
	input  logic          m0_axi_wready,
	input  logic [ 1 : 0] m0_axi_bresp,
	input  logic          m0_axi_bvalid,
	output logic          m0_axi_bready,
	output logic [31 : 0] m0_axi_araddr,
	output logic [ 2 : 0] m0_axi_arprot,
	output logic          m0_axi_arvalid,
	input  logic          m0_axi_arready,
	input  logic [31 : 0] m0_axi_rdata,
	input  logic [ 1 : 0] m0_axi_rresp,
	input  logic          m0_axi_rvalid,
	output logic          m0_axi_rready,
	
	output logic [31 : 0] m1_axi_awaddr,
	output logic [ 2 : 0] m1_axi_awprot,
	output logic          m1_axi_awvalid,
	input  logic          m1_axi_awready,
	output logic [31 : 0] m1_axi_wdata,
	output logic [ 3 : 0] m1_axi_wstrb,
	output logic          m1_axi_wvalid,
	input  logic          m1_axi_wready,
	input  logic [ 1 : 0] m1_axi_bresp,
	input  logic          m1_axi_bvalid,
	output logic          m1_axi_bready,
	output logic [31 : 0] m1_axi_araddr,
	output logic [ 2 : 0] m1_axi_arprot,
	output logic          m1_axi_arvalid,
	input  logic          m1_axi_arready,
	input  logic [31 : 0] m1_axi_rdata,
	input  logic [ 1 : 0] m1_axi_rresp,
	input  logic          m1_axi_rvalid,
	output logic          m1_axi_rready
);

    logic [31:0] axis_timers_values [0:7];

    logic [31:0] mvalid_cnt;
    logic [31:0] mlast_cnt;
    logic [31:0] svalid_cnt;
    logic [31:0] slast_cnt;

    rvexp_controller i_rvexp_controller(
        .clock(clock),
        .reset_n(reset_n),

        .instr_commit(instr_commit),
        .instr_funct7(instr_funct7),
        .instr_funct3(instr_funct3),
        .instr_rs1_val(instr_rs1_val),
        .instr_rs2_val(instr_rs2_val),

        .result_we(result_we),
        .result_rd(result_rd),

        .axis_timers_values(axis_timers_values),

        .mvalid_cnt(mvalid_cnt),
        .mlast_cnt(mlast_cnt),
        .svalid_cnt(svalid_cnt),
        .slast_cnt(slast_cnt),

        .m0_axi_awaddr(m0_axi_awaddr),
		.m0_axi_awprot(m0_axi_awprot),
		.m0_axi_awvalid(m0_axi_awvalid),
		.m0_axi_awready(m0_axi_awready),
		.m0_axi_wdata(m0_axi_wdata),
		.m0_axi_wstrb(m0_axi_wstrb),
		.m0_axi_wvalid(m0_axi_wvalid),
		.m0_axi_wready(m0_axi_wready),
		.m0_axi_bresp(m0_axi_bresp),
		.m0_axi_bvalid(m0_axi_bvalid),
		.m0_axi_bready(m0_axi_bready),
		.m0_axi_araddr(m0_axi_araddr),
		.m0_axi_arprot(m0_axi_arprot),
		.m0_axi_arvalid(m0_axi_arvalid),
		.m0_axi_arready(m0_axi_arready),
		.m0_axi_rdata(m0_axi_rdata),
		.m0_axi_rresp(m0_axi_rresp),
		.m0_axi_rvalid(m0_axi_rvalid),
		.m0_axi_rready(m0_axi_rready),
		
		.m1_axi_awaddr(m1_axi_awaddr),
		.m1_axi_awprot(m1_axi_awprot),
		.m1_axi_awvalid(m1_axi_awvalid),
		.m1_axi_awready(m1_axi_awready),
		.m1_axi_wdata(m1_axi_wdata),
		.m1_axi_wstrb(m1_axi_wstrb),
		.m1_axi_wvalid(m1_axi_wvalid),
		.m1_axi_wready(m1_axi_wready),
		.m1_axi_bresp(m1_axi_bresp),
		.m1_axi_bvalid(m1_axi_bvalid),
		.m1_axi_bready(m1_axi_bready),
		.m1_axi_araddr(m1_axi_araddr),
		.m1_axi_arprot(m1_axi_arprot),
		.m1_axi_arvalid(m1_axi_arvalid),
		.m1_axi_arready(m1_axi_arready),
		.m1_axi_rdata(m1_axi_rdata),
		.m1_axi_rresp(m1_axi_rresp),
		.m1_axi_rvalid(m1_axi_rvalid),
		.m1_axi_rready(m1_axi_rready)
    );

	top_pp_fdwt_cdf53_opt i_top_pp_fdwt_cdf53_opt(
        .aclk(clock),
        .aresetn(reset_n),

        .si_tdata(m0_axis_mm2s_tdata),
        .si_tvalid(m0_axis_mm2s_tvalid),
        .si_tkeep(m0_axis_mm2s_tkeep),
        .si_tready(m0_axis_mm2s_tready),
        .si_tlast(m0_axis_mm2s_tlast),

        .mo_tdata(s0_axis_s2mm_tdata),
        .mo_tvalid(s0_axis_s2mm_tvalid),
        .mo_tkeep(s0_axis_s2mm_tkeep),
        .mo_tready(s0_axis_s2mm_tready),
        .mo_tlast(s0_axis_s2mm_tlast)
    );

    top_pp_idwt_cdf53_opt i_top_pp_idwt_cdf53_opt(
        .aclk(clock),
        .aresetn(reset_n),

        .si_tdata(m1_axis_mm2s_tdata),
        .si_tvalid(m1_axis_mm2s_tvalid),
        .si_tkeep(m1_axis_mm2s_tkeep),
        .si_tready(m1_axis_mm2s_tready),
        .si_tlast(m1_axis_mm2s_tlast),

        .mo_tdata(s1_axis_s2mm_tdata),
        .mo_tvalid(s1_axis_s2mm_tvalid),
        .mo_tkeep(s1_axis_s2mm_tkeep),
        .mo_tready(s1_axis_s2mm_tready),
        .mo_tlast(s1_axis_s2mm_tlast)
    );

    AXIS_PerfCnts i_AXIS_PerfCnts(
        .clock(clock),
        .reset_n(reset_n),

        .m_valid(m0_axis_mm2s_tvalid),
        .m_ready(m0_axis_mm2s_tready),
        .m_last(m0_axis_mm2s_tlast),

        .s_valid(s0_axis_s2mm_tvalid),
        .s_ready(s0_axis_s2mm_tready),
        .s_last(s0_axis_s2mm_tlast),

        .axis_timers_values(axis_timers_values),

        .mvalid_cnt(mvalid_cnt),
        .mlast_cnt(mlast_cnt),
        .svalid_cnt(svalid_cnt),
        .slast_cnt(slast_cnt)
    );
    


endmodule

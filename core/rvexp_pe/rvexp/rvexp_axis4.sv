`timescale 1ns / 1ps

module rvexp_axis4(
    input  logic            clock,
    input  logic            reset_n,

    input  logic            instr_commit,
    input  logic [ 6:0]     instr_funct7,
    input  logic [ 2:0]     instr_funct3,
    input  logic [63:0]     instr_rs1_val,
    input  logic [63:0]     instr_rs2_val,
    
    output logic            result_we,
    output logic [   63:0]  result_rd,

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

    input  logic [  15: 0]  m2_axis_mm2s_tdata, 
    input  logic [   1: 0]  m2_axis_mm2s_tkeep,  
    input  logic            m2_axis_mm2s_tvalid,          
    output logic            m2_axis_mm2s_tready,          
    input  logic            m2_axis_mm2s_tlast,           
    output logic [  31 : 0] s2_axis_s2mm_tdata, 
    output logic [   3 : 0] s2_axis_s2mm_tkeep,  
    output logic            s2_axis_s2mm_tvalid,           
    input  logic            s2_axis_s2mm_tready,           
    output logic            s2_axis_s2mm_tlast,             
	
	input  logic [ 511: 0]  m3_axis_mm2s_tdata, 
    input  logic [  63: 0]  m3_axis_mm2s_tkeep,  
    input  logic            m3_axis_mm2s_tvalid,          
    output logic            m3_axis_mm2s_tready,          
    input  logic            m3_axis_mm2s_tlast,           
    output logic [ 511 : 0] s3_axis_s2mm_tdata, 
    output logic [  63 : 0] s3_axis_s2mm_tkeep,  
    output logic            s3_axis_s2mm_tvalid,           
    input  logic            s3_axis_s2mm_tready,           
    output logic            s3_axis_s2mm_tlast,             

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
	output logic          m1_axi_rready,

    output logic [31 : 0] m2_axi_awaddr,
	output logic [ 2 : 0] m2_axi_awprot,
	output logic          m2_axi_awvalid,
	input  logic          m2_axi_awready,
	output logic [31 : 0] m2_axi_wdata,
	output logic [ 3 : 0] m2_axi_wstrb,
	output logic          m2_axi_wvalid,
	input  logic          m2_axi_wready,
	input  logic [ 1 : 0] m2_axi_bresp,
	input  logic          m2_axi_bvalid,
	output logic          m2_axi_bready,
	output logic [31 : 0] m2_axi_araddr,
	output logic [ 2 : 0] m2_axi_arprot,
	output logic          m2_axi_arvalid,
	input  logic          m2_axi_arready,
	input  logic [31 : 0] m2_axi_rdata,
	input  logic [ 1 : 0] m2_axi_rresp,
	input  logic          m2_axi_rvalid,
	output logic          m2_axi_rready,
	
	output logic [31 : 0] m3_axi_awaddr,
	output logic [ 2 : 0] m3_axi_awprot,
	output logic          m3_axi_awvalid,
	input  logic          m3_axi_awready,
	output logic [31 : 0] m3_axi_wdata,
	output logic [ 3 : 0] m3_axi_wstrb,
	output logic          m3_axi_wvalid,
	input  logic          m3_axi_wready,
	input  logic [ 1 : 0] m3_axi_bresp,
	input  logic          m3_axi_bvalid,
	output logic          m3_axi_bready,
	output logic [31 : 0] m3_axi_araddr,
	output logic [ 2 : 0] m3_axi_arprot,
	output logic          m3_axi_arvalid,
	input  logic          m3_axi_arready,
	input  logic [31 : 0] m3_axi_rdata,
	input  logic [ 1 : 0] m3_axi_rresp,
	input  logic          m3_axi_rvalid,
	output logic          m3_axi_rready,

    output logic          ad_cs_n,
    output logic          ad_sclk,
    input  logic          ad_dout,

    output logic          o_uart_tx,
    input  logic          i_uart_rx,

    output logic          da_sync_n,
    output logic          da_sclk,
    output logic          da_din
);

    localparam  int unsigned AD_DATA_WIDTH  = 64;
    localparam  int unsigned AD_MEM_DEPTH  = 1024;
	localparam  int unsigned AD_ADDR_WIDTH = $clog2(AD_MEM_DEPTH);

    localparam  int unsigned UA_DATA_WIDTH  = 64;
    localparam  int unsigned UA_MEM_DEPTH  = 8192;
	localparam  int unsigned UA_ADDR_WIDTH = $clog2(UA_MEM_DEPTH);

    localparam  int unsigned DA_DATA_WIDTH  = 64;
    localparam  int unsigned DA_MEM_DEPTH  = 32;
	localparam  int unsigned DA_ADDR_WIDTH = $clog2(DA_MEM_DEPTH);

    logic          qm_we;
    logic [  7:0]  qm [0:63];

    logic [31:0] axis_timers_values [0:7];

    logic [31:0] mvalid_cnt;
    logic [31:0] mlast_cnt;
    logic [31:0] svalid_cnt;
    logic [31:0] slast_cnt;

    logic [1:0]              stft_cfg_window_sel;
	logic                    stft_cfg_enable;
	logic [1:0]              stft_cfg_out_fmt;
	logic [1:0]              stft_cfg_pix_floor;
	logic                    stft_start_pulse;
	logic                    stft_soft_reset;
	logic                    stft_stat_read_ack;

	logic                    stft_ctrl_busy;
	logic                    stft_frame_done;     // sticky; cleared by stat_read_ack
	logic                    stft_frame_full;
	logic [7:0]              stft_frame_count;

    

    logic                       ad_aq_enable;
    logic                       ad_aq_clear;
    logic                       ad_aq_full;
    logic                       ad_en_b;
    logic                       ad_we_b;
    logic [AD_ADDR_WIDTH-1:0]   ad_addr_b;
    logic [AD_DATA_WIDTH-1:0]   ad_din_b;
    logic [AD_DATA_WIDTH-1:0]   ad_dout_b;
    logic  [AD_ADDR_WIDTH:0]    ad_wr_cnt_out;
    logic  [AD_ADDR_WIDTH:0]    ad_lim;

    logic                       ua_start;
    logic                       ua_clear;
    logic                       ua_empty;
    logic                       ua_en_b;
    logic                       ua_we_b;
    logic [UA_ADDR_WIDTH-1:0]   ua_addr_b;
    logic [UA_DATA_WIDTH-1:0]   ua_din_b;
    logic [UA_DATA_WIDTH-1:0]   ua_dout_b;
    logic  [UA_ADDR_WIDTH:0]    ua_rd_cnt_out;
    logic  [UA_ADDR_WIDTH:0]    ua_lim;

    logic                       da_start;
    logic                       da_clear;
    logic                       da_empty;
    logic                       da_en_b;
    logic                       da_we_b;
    logic [DA_ADDR_WIDTH-1:0]   da_addr_b;
    logic [DA_DATA_WIDTH-1:0]   da_din_b;
    logic [DA_DATA_WIDTH-1:0]   da_dout_b;
    logic  [DA_ADDR_WIDTH:0]    da_rd_cnt_out;
    logic  [DA_ADDR_WIDTH:0]    da_lim;

    logic                       ur_stop;
    logic                       ur_ready;
    logic                       ur_clear_stop;
    logic                       ur_clear_ready;
    logic [7:0]                 ur_qf;
    logic [1:0]                 ur_pf;
    logic                       ur_ws;

    rvexp_controller #(
        .AD_DATA_WIDTH(AD_DATA_WIDTH),
		.AD_MEM_DEPTH(AD_MEM_DEPTH),
		.UA_DATA_WIDTH(UA_DATA_WIDTH),
		.UA_MEM_DEPTH(UA_MEM_DEPTH),
        .DA_DATA_WIDTH(DA_DATA_WIDTH),
        .DA_MEM_DEPTH(DA_MEM_DEPTH)
    ) i_rvexp_controller(
        .clock(clock),
        .reset_n(reset_n),

        .instr_commit(instr_commit),
        .instr_funct7(instr_funct7),
        .instr_funct3(instr_funct3),
        .instr_rs1_val(instr_rs1_val),
        .instr_rs2_val(instr_rs2_val),

        .result_we(result_we),
        .result_rd(result_rd),

        .qm_we(qm_we),
        .qm(qm),
        
        .axis_timers_values(axis_timers_values),

        .mvalid_cnt(mvalid_cnt),
        .mlast_cnt(mlast_cnt),
        .svalid_cnt(svalid_cnt),
        .slast_cnt(slast_cnt),

        .stft_cfg_window_sel(stft_cfg_window_sel),
        .stft_cfg_enable(stft_cfg_enable),
        .stft_cfg_out_fmt(stft_cfg_out_fmt),
        .stft_cfg_pix_floor(stft_cfg_pix_floor),
        .stft_start_pulse(stft_start_pulse),
        .stft_soft_reset(stft_soft_reset),
        .stft_stat_read_ack(stft_stat_read_ack),

        .stft_ctrl_busy(stft_ctrl_busy),
        .stft_frame_done(stft_frame_done),
        .stft_frame_full(stft_frame_full),
        .stft_frame_count(stft_frame_count),

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
		.m1_axi_rready(m1_axi_rready),

        .m2_axi_awaddr(m2_axi_awaddr),
		.m2_axi_awprot(m2_axi_awprot),
		.m2_axi_awvalid(m2_axi_awvalid),
		.m2_axi_awready(m2_axi_awready),
		.m2_axi_wdata(m2_axi_wdata),
		.m2_axi_wstrb(m2_axi_wstrb),
		.m2_axi_wvalid(m2_axi_wvalid),
		.m2_axi_wready(m2_axi_wready),
		.m2_axi_bresp(m2_axi_bresp),
		.m2_axi_bvalid(m2_axi_bvalid),
		.m2_axi_bready(m2_axi_bready),
		.m2_axi_araddr(m2_axi_araddr),
		.m2_axi_arprot(m2_axi_arprot),
		.m2_axi_arvalid(m2_axi_arvalid),
		.m2_axi_arready(m2_axi_arready),
		.m2_axi_rdata(m2_axi_rdata),
		.m2_axi_rresp(m2_axi_rresp),
		.m2_axi_rvalid(m2_axi_rvalid),
		.m2_axi_rready(m2_axi_rready),
		
		.m3_axi_awaddr(m3_axi_awaddr),
		.m3_axi_awprot(m3_axi_awprot),
		.m3_axi_awvalid(m3_axi_awvalid),
		.m3_axi_awready(m3_axi_awready),
		.m3_axi_wdata(m3_axi_wdata),
		.m3_axi_wstrb(m3_axi_wstrb),
		.m3_axi_wvalid(m3_axi_wvalid),
		.m3_axi_wready(m3_axi_wready),
		.m3_axi_bresp(m3_axi_bresp),
		.m3_axi_bvalid(m3_axi_bvalid),
		.m3_axi_bready(m3_axi_bready),
		.m3_axi_araddr(m3_axi_araddr),
		.m3_axi_arprot(m3_axi_arprot),
		.m3_axi_arvalid(m3_axi_arvalid),
		.m3_axi_arready(m3_axi_arready),
		.m3_axi_rdata(m3_axi_rdata),
		.m3_axi_rresp(m3_axi_rresp),
		.m3_axi_rvalid(m3_axi_rvalid),
		.m3_axi_rready(m3_axi_rready),

        .ad_en_b(ad_en_b),
        .ad_we_b(ad_we_b),
        .ad_addr_b(ad_addr_b),
        .ad_din_b(ad_din_b),
        .ad_dout_b(ad_dout_b),

        .ua_en_b(ua_en_b),
        .ua_we_b(ua_we_b),
        .ua_addr_b(ua_addr_b),
        .ua_din_b(ua_din_b),
        .ua_dout_b(ua_dout_b),

        .da_en_b(da_en_b),
        .da_we_b(da_we_b),
        .da_addr_b(da_addr_b),
        .da_din_b(da_din_b),
        .da_dout_b(da_dout_b),

        .ad_aq_enable(ad_aq_enable),
        .ad_aq_clear(ad_aq_clear),
        .ad_aq_full(ad_aq_full),
        .ad_wr_cnt_out(ad_wr_cnt_out),
        .ad_lim(ad_lim),

        .ua_start(ua_start),
        .ua_clear(ua_clear),
        .ua_empty(ua_empty),
        .ua_rd_cnt_out(ua_rd_cnt_out),
        .ua_lim(ua_lim),

        .da_start(da_start),
        .da_clear(da_clear),
        .da_empty(da_empty),
        .da_rd_cnt_out(da_rd_cnt_out),
        .da_lim(da_lim),

        .ur_stop(ur_stop),
        .ur_ready(ur_ready),
        .ur_clear_stop(ur_clear_stop),
        .ur_clear_ready(ur_clear_ready),
        .ur_qf(ur_qf),
        .ur_pf(ur_pf),
        .ur_ws(ur_ws),

        .cvxif_busy()
    );

    top_pp_fdct_2d i0_top_pp_fdct_2d(
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
        .mo_tlast(s0_axis_s2mm_tlast),

        .qm_we(qm_we),
        .qm(qm)
    );

    top_pp_idct_2d i0_top_pp_idct_2d(
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
        .mo_tlast(s1_axis_s2mm_tlast),

        .qm_we(qm_we),
        .qm(qm)
    );

    stft128_core i2_stft128_core(
        .clk(clock),
        .rst_n(reset_n),
        
        .s_axis_tvalid(m2_axis_mm2s_tvalid),    // input wire s_axis_tvalid
        .s_axis_tready(m2_axis_mm2s_tready),    // output wire s_axis_tready
        .s_axis_tdata($signed(m2_axis_mm2s_tdata)),      // input wire [511 : 0] s_axis_tdata
        //.s_axis_tdata(m2_axis_mm2s_tdata),      // input wire [511 : 0] s_axis_tdata
        .s_axis_tlast(m2_axis_mm2s_tlast),      // input wire s_axis_tlast

        .m_axis_tvalid(s2_axis_s2mm_tvalid),    // output wire m_axis_tvalid
        .m_axis_tready(s2_axis_s2mm_tready),    // input wire m_axis_tready
        .m_axis_tdata(s2_axis_s2mm_tdata),      // output wire [511 : 0] m_axis_tdata
        .m_axis_tlast(s2_axis_s2mm_tlast),      // output wire m_axis_tlast

        .cfg_window_sel(stft_cfg_window_sel),
        .cfg_enable(stft_cfg_enable),
        .cfg_out_fmt(stft_cfg_out_fmt),
        .cfg_pix_floor(stft_cfg_pix_floor),
        .start_pulse(stft_start_pulse),
        .soft_reset(stft_soft_reset),
        .stat_read_ack(stft_stat_read_ack),

        .ctrl_busy(stft_ctrl_busy),
        .frame_done(stft_frame_done),
        .frame_full(stft_frame_full),
        .frame_count(stft_frame_count)
    );

    assign s2_axis_s2mm_tkeep = 4'hF;

    xlnx_axis_data_fifo i3_axi_data_fifo (
        .s_axis_aresetn(reset_n),  // input wire s_axis_aresetn
        .s_axis_aclk(clock),        // input wire s_axis_aclk

        .s_axis_tvalid(m3_axis_mm2s_tvalid),    // input wire s_axis_tvalid
        .s_axis_tready(m3_axis_mm2s_tready),    // output wire s_axis_tready
        .s_axis_tdata(m3_axis_mm2s_tdata),      // input wire [511 : 0] s_axis_tdata
        .s_axis_tkeep(m3_axis_mm2s_tkeep),      // input wire [63 : 0] s_axis_tkeep
        .s_axis_tlast(m3_axis_mm2s_tlast),      // input wire s_axis_tlast

        .m_axis_tvalid(s3_axis_s2mm_tvalid),    // output wire m_axis_tvalid
        .m_axis_tready(s3_axis_s2mm_tready),    // input wire m_axis_tready
        .m_axis_tdata(s3_axis_s2mm_tdata),      // output wire [511 : 0] m_axis_tdata
        .m_axis_tkeep(s3_axis_s2mm_tkeep),      // output wire [63 : 0] m_axis_tkeep
        .m_axis_tlast(s3_axis_s2mm_tlast)      // output wire m_axis_tlast
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
    
    AD_Block #(
        .DATA_WIDTH(AD_DATA_WIDTH),
        .MEM_DEPTH(AD_MEM_DEPTH)
    ) i_AD_Block(
        .clk_100(clock),
        .reset_n(reset_n),

        .ad_cs_n(ad_cs_n),
        .ad_sclk(ad_sclk),
        .ad_dout(ad_dout),

        .ad_aq_enable(ad_aq_enable),
        .ad_aq_clear(ad_aq_clear),
        .ad_aq_full(ad_aq_full),

        .en_b(ad_en_b),
        .we_b(ad_we_b),
        .addr_b(ad_addr_b),
        .din_b(ad_din_b),
        .dout_b(ad_dout_b),

        .wr_cnt_out(ad_wr_cnt_out),
        .ad_lim(ad_lim)
    );

    UA_Block #(
        .DATA_WIDTH(UA_DATA_WIDTH),
        .MEM_DEPTH(UA_MEM_DEPTH)
    ) i_UA_Block(
        .clock(clock),
        .reset_n(reset_n),

        .ua_enable(ua_start),
        .ua_clear(ua_clear),
        .ua_empty(ua_empty),

        .en_b(ua_en_b),
        .we_b(ua_we_b),
        .addr_b(ua_addr_b),
        .din_b(ua_din_b),
        .dout_b(ua_dout_b),

        .rd_cnt_out(ua_rd_cnt_out),
        .ua_lim(ua_lim),

        .o_uart_tx(o_uart_tx)
    );

    DA_Block #(
        .DATA_WIDTH(DA_DATA_WIDTH),
        .MEM_DEPTH(DA_MEM_DEPTH)
    ) i_DA_Block(
        .clk_100(clock),
        .reset_n(reset_n),

        .da_enable(da_start),
        .da_clear(da_clear),
        .da_empty(da_empty),

        .en_b(da_en_b),
        .we_b(da_we_b),
        .addr_b(da_addr_b),
        .din_b(da_din_b),
        .dout_b(da_dout_b),

        .rd_cnt_out(da_rd_cnt_out),
        .da_lim(da_lim),

        .da_sync_n(da_sync_n),
        .da_sclk(da_sclk),
        .da_din(da_din)
    );

    UR_Block i_UR_Block(
        .clock(clock),
        .reset_n(reset_n),

        .i_uart_rx(i_uart_rx),

        .ur_stop(ur_stop),
        .ur_ready(ur_ready),
        .ur_clear_stop(ur_clear_stop),
        .ur_clear_ready(ur_clear_ready),
        .ur_qf(ur_qf),
        .ur_pf(ur_pf),
        .ur_ws(ur_ws)
    );

endmodule

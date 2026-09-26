`timescale 1ns / 1ps

module top_pp_fdct_2d(
    input  logic                   aclk,
    input  logic                   aresetn,

    input  logic [512-1:0]         si_tdata,
    input  logic                   si_tvalid,
    input  logic [(512/8)-1:0]     si_tkeep,
    output logic                   si_tready,
    input  logic                   si_tlast,

    output logic [1024-1:0]        mo_tdata,
    output logic                   mo_tvalid,
    output logic [(1024/8)-1:0]    mo_tkeep,
    input  logic                   mo_tready,
    output logic                   mo_tlast,

    input logic                    qm_we,
    input logic  [7:0]             qm [0:63]
);

    localparam int unsigned INPUT_WIDTH            =  8;
    localparam int unsigned QM_PASSTHROUGH         =  0;
    localparam int unsigned OUTPUT_WIDTH_R         = 13;    
    localparam int unsigned OUTPUT_WIDTH_C         = 16;
    
    localparam int unsigned FRACTIONAL_WIDTH_R     =  9; 
    localparam int unsigned FRACTIONAL_WIDTH_C     =  9;
    
    localparam int unsigned QUANT_FRACTIONAL_WIDTH = 17;
    localparam int unsigned ROUND                  =  1;

    localparam int unsigned OUTPUT_WIDTH           = 13;
    localparam int unsigned NORMAL_OUTPUT_WIDTH    = 16;


    logic [512-1:0]         tdata_ip;
    logic [(512/8)-1:0]     tkeep_ip;
    logic                   tvalid_ip;
    logic                   tready_ip;
    logic                   tlast_ip;

    logic [1024-1:0]        tdata_po;
    logic                   tvalid_po;
    logic                   tready_po;
    logic                   tlast_po;

    axis_input #(
        .AXIS4_DATAWITH(512)
    ) i_axis_input (
        .aclk(aclk),
        .aresetn(aresetn),

        .s_tdata(si_tdata),
        .s_tvalid(si_tvalid),
        .s_tlast(si_tlast),
        .s_tkeep(si_tkeep),
        .s_tready(si_tready),

        .out_data(tdata_ip),
        .out_valid(tvalid_ip),
        .out_last(tlast_ip),
        .out_keep(tkeep_ip),
        .out_ready(tready_ip)
    );

    pp_fdct_2d #(
        .INPUT_WIDTH(INPUT_WIDTH),
        .QM_PASSTHROUGH(QM_PASSTHROUGH),
        .OUTPUT_WIDTH_R(OUTPUT_WIDTH_R),
        .OUTPUT_WIDTH_C(OUTPUT_WIDTH_C),
        .FRACTIONAL_WIDTH_R(FRACTIONAL_WIDTH_R),
        .FRACTIONAL_WIDTH_C(FRACTIONAL_WIDTH_C),
        .QUANT_FRACTIONAL_WIDTH(QUANT_FRACTIONAL_WIDTH),
        .ROUND(ROUND),
        .OUTPUT_WIDTH(OUTPUT_WIDTH),
        .NORMAL_OUTPUT_WIDTH(NORMAL_OUTPUT_WIDTH)
    ) i_pp_fdct_2d (
        .clk(aclk),
        .reset_n(aresetn),

        .in_ready(tready_ip),
        .in_valid(tvalid_ip),
        .in_last(tlast_ip),
        .in_data(tdata_ip),
        
        .out_valid(tvalid_po),
        .out_last(tlast_po),
        .out_data(tdata_po),
        .out_ready(tready_po),
        
        .qm_we(qm_we),
        .qm(qm) 
    );

    axis_output #(
        .AXIS4_DATAWITH(1024)
    ) i_axis_output (
        .aclk(aclk),
        .aresetn(aresetn),

        .in_ready(tready_po),
        .in_valid(tvalid_po),
        .in_last(tlast_po),
        .in_data(tdata_po),
        .in_keep({128{1'b1}}),

        .m_tdata(mo_tdata),
        .m_tvalid(mo_tvalid),
        .m_tkeep(mo_tkeep),
        .m_tready(mo_tready),
        .m_tlast(mo_tlast)
    );

endmodule

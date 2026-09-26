`timescale 1ns / 1ps

module top_pp_idct_2d(
    input  logic                    aclk,
    input  logic                    aresetn,

    input  logic [1024-1:0]         si_tdata,
    input  logic                    si_tvalid,
    input  logic [(1024/8)-1:0]     si_tkeep,
    output logic                    si_tready,
    input  logic                    si_tlast,

    output logic [512-1:0]          mo_tdata,
    output logic                    mo_tvalid,
    output logic [(512/8)-1:0]      mo_tkeep,
    input  logic                    mo_tready,
    output logic                    mo_tlast,

    input logic                     qm_we,
    input logic  [7:0]              qm [0:63]
);

    localparam int unsigned NORMAL_INPUT_WIDTH   = 16;
    localparam int unsigned INPUT_WIDTH          = 13;
    localparam int unsigned EXTRA                =  1;
    localparam int unsigned OUTPUT_WIDTH_C       = 13;
    localparam int unsigned OUTPUT_WIDTH_R       = 13;
    localparam int unsigned FRACTIONAL_WIDTH_C   =  9;
    localparam int unsigned FRACTIONAL_WIDTH_R   =  9;
    localparam int unsigned ROUND                =  1;
    localparam int unsigned OUTPUT_WIDTH         =  8;

    logic [1024-1:0]        tdata_ip;
    logic [(1024/8)-1:0]    tkeep_ip;
    logic                   tvalid_ip;
    logic                   tready_ip;
    logic                   tlast_ip;

    logic [512-1:0]         tdata_po;
    logic                   tvalid_po;
    logic                   tready_po;
    logic                   tlast_po;



    axis_input #(
        .AXIS4_DATAWITH(1024)
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

    pp_idct_2d #(
        .NORMAL_INPUT_WIDTH(NORMAL_INPUT_WIDTH),
        .INPUT_WIDTH(INPUT_WIDTH),
        .EXTRA(EXTRA),
        .OUTPUT_WIDTH_C(OUTPUT_WIDTH_C),
        .OUTPUT_WIDTH_R(OUTPUT_WIDTH_R),
        .FRACTIONAL_WIDTH_C(FRACTIONAL_WIDTH_C),
        .FRACTIONAL_WIDTH_R(FRACTIONAL_WIDTH_R),
        .ROUND(ROUND),
        .OUTPUT_WIDTH(OUTPUT_WIDTH)
    ) i_pp_idct_2d(
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
        .AXIS4_DATAWITH(512)
    ) i_axis_output (
        .aclk(aclk),
        .aresetn(aresetn),

        .in_ready(tready_po),
        .in_valid(tvalid_po),
        .in_last(tlast_po),
        .in_data(tdata_po),
        .in_keep({64{1'b1}}),

        .m_tdata(mo_tdata),
        .m_tvalid(mo_tvalid),
        .m_tkeep(mo_tkeep),
        .m_tready(mo_tready),
        .m_tlast(mo_tlast)
    );

endmodule

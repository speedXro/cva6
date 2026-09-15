`timescale 1ns / 1ps

module top_pp_fdwt_cdf53_opt (
    input  logic            aclk,
    input  logic            aresetn,

    input  logic [512-1:0]  si_tdata,
    input  logic            si_tvalid,
    input  logic [ 64-1:0]  si_tkeep,
    output logic            si_tready,
    input  logic            si_tlast,

    output logic [1024-1:0] mo_tdata,
    output logic            mo_tvalid,
    output logic [128-1:0]  mo_tkeep,
    input  logic            mo_tready,
    output logic            mo_tlast
);

    localparam int unsigned IS_DIRECT_PP           =    1;
    localparam int unsigned AXIS4_INPUT_DATAWITH   =  512;
    localparam int unsigned AXIS4_OUTPUT_DATAWITH  = 1024;

    top_pp_dwt_cdf53_opt #(
        .AXIS4_INPUT_DATAWITH(AXIS4_INPUT_DATAWITH),
        .AXIS4_OUTPUT_DATAWITH(AXIS4_OUTPUT_DATAWITH),
        .IS_DIRECT_PP(IS_DIRECT_PP)
    ) i_top_pp_dwt_cdf53 (
        .aclk(aclk),
        .aresetn(aresetn),

        .si_tdata(si_tdata),
        .si_tvalid(si_tvalid),
        .si_tkeep(si_tkeep),
        .si_tready(si_tready),
        .si_tlast(si_tlast),

        .mo_tdata(mo_tdata),
        .mo_tvalid(mo_tvalid),
        .mo_tkeep(mo_tkeep),
        .mo_tready(mo_tready),
        .mo_tlast(mo_tlast)
    );
endmodule

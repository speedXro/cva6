`timescale 1ns / 1ps

module top_pp_dwt_cdf53_opt #(
    parameter  int unsigned AXIS4_INPUT_DATAWITH  = 128,
    parameter  int unsigned AXIS4_OUTPUT_DATAWITH = 256,
    parameter  int unsigned IS_DIRECT_PP          =   1
) (
    input  logic                                    aclk,
    input  logic                                    aresetn,

    input  logic [AXIS4_INPUT_DATAWITH-1:0]         si_tdata,
    input  logic                                    si_tvalid,
    input  logic [(AXIS4_INPUT_DATAWITH/8)-1:0]     si_tkeep,
    output logic                                    si_tready,
    input  logic                                    si_tlast,

    output logic [AXIS4_OUTPUT_DATAWITH-1:0]        mo_tdata,
    output logic                                    mo_tvalid,
    output logic [(AXIS4_OUTPUT_DATAWITH/8)-1:0]    mo_tkeep,
    input  logic                                    mo_tready,
    output logic                                    mo_tlast

);
    localparam int unsigned NO_OF_INPUT_WORDS           = 16;
    localparam int unsigned INPUT_WORD_BITWIDTH         = (IS_DIRECT_PP == 1) ?  8 : 16;
    localparam int unsigned ACCELERATOR_INPUT_BITWIDTH  = NO_OF_INPUT_WORDS * INPUT_WORD_BITWIDTH;

    localparam int unsigned NO_OF_OUTPUT_WORDS          = 16;
    localparam int unsigned OUTPUT_WORD_BITWIDTH        = (IS_DIRECT_PP == 1) ? 16 :  8;
    localparam int unsigned ACCELERATOR_OUTPUT_BITWIDTH = NO_OF_OUTPUT_WORDS * OUTPUT_WORD_BITWIDTH;

    localparam int unsigned NO_OF_ACCELERATORS   =  AXIS4_INPUT_DATAWITH / ACCELERATOR_INPUT_BITWIDTH;

    logic [AXIS4_INPUT_DATAWITH-1:0]        s_tdata;
    logic                                   s_tvalid;
    logic [(AXIS4_INPUT_DATAWITH/8)-1:0]    s_tkeep;
    logic                                   s_tready;
    logic                                   s_tlast;

    logic [AXIS4_OUTPUT_DATAWITH-1:0]       m_tdata;
    logic                                   m_tvalid;
    logic [(AXIS4_OUTPUT_DATAWITH/8)-1:0]   m_tkeep;
    logic                                   m_tready;
    logic                                   m_tlast;


    logic [NO_OF_ACCELERATORS-1:0]           sacc_tready;
    logic [NO_OF_ACCELERATORS-1:0]           sacc_tvalid;
    logic [NO_OF_ACCELERATORS-1:0]           sacc_tlast;
    logic [ACCELERATOR_INPUT_BITWIDTH-1:0]   sacc_tdata [0:NO_OF_ACCELERATORS-1];

    logic [NO_OF_ACCELERATORS-1:0]           macc_tvalid;
    logic [NO_OF_ACCELERATORS-1:0]           macc_tlast;
    logic [ACCELERATOR_OUTPUT_BITWIDTH-1:0]  macc_tdata [0:NO_OF_ACCELERATORS-1];
    logic [NO_OF_ACCELERATORS-1:0]           macc_tready;

    axis_input #(
        .AXIS4_DATAWITH(AXIS4_INPUT_DATAWITH)
    ) i_axis_input (
        .aclk(aclk),
        .aresetn(aresetn),

        .s_tdata(si_tdata),
        .s_tvalid(si_tvalid),
        .s_tkeep(si_tkeep),
        .s_tready(si_tready),
        .s_tlast(si_tlast),

        .out_data(s_tdata),
        .out_keep(s_tkeep),
        .out_last(s_tlast),
        .out_valid(s_tvalid),
        .out_ready(s_tready)
    );

    assign s_tready = &sacc_tready;

    input_wiring_i #(
        .AXIS4_DATAWITH(AXIS4_INPUT_DATAWITH),
        .ACCELERATOR_INPUT_BITWIDTH(ACCELERATOR_INPUT_BITWIDTH)
    ) i_input_wiring_axi (
        .s_tdata(s_tdata),
        .s_tvalid(s_tvalid),
        .s_tlast(s_tlast),

        .sacc_tvalid(sacc_tvalid),
        .sacc_tlast(sacc_tlast),
        .sacc_tdata(sacc_tdata)
    );

    genvar i;

    generate
        for(i=0;i<NO_OF_ACCELERATORS;++i) begin
            wrapper_pipeline #(
                .ACCELERATOR_INPUT_BITWIDTH(ACCELERATOR_INPUT_BITWIDTH),
                .INPUT_WORD_BITWIDTH(INPUT_WORD_BITWIDTH),
                .ACCELERATOR_OUTPUT_BITWIDTH(ACCELERATOR_OUTPUT_BITWIDTH),
                .OUTPUT_WORD_BITWIDTH(OUTPUT_WORD_BITWIDTH),
                .IS_DIRECT_PP(IS_DIRECT_PP)
            ) i_pp_wrapper(
                .aclk(aclk),
                .aresetn(aresetn),

                .sacc_tready(sacc_tready[i]),
                .sacc_tvalid(sacc_tvalid[i]),
                .sacc_tlast(sacc_tlast[i]),
                .sacc_tdata(sacc_tdata[i]),

                .macc_tvalid(macc_tvalid[i]),
                .macc_tlast(macc_tlast[i]),
                .macc_tdata(macc_tdata[i]),
                .macc_tready(macc_tready[i])
            );  
            assign macc_tready[i] = mo_tready;
        end
    endgenerate

    output_wiring_o #(
        .AXIS4_DATAWITH(AXIS4_OUTPUT_DATAWITH),
        .ACCELERATOR_OUTPUT_BITWIDTH(ACCELERATOR_OUTPUT_BITWIDTH)
    ) i_output_wiring(
        .macc_tvalid(macc_tvalid),
        .macc_tlast(macc_tlast),
        .macc_tdata(macc_tdata),

        .m_tvalid(m_tvalid),
        .m_tlast(m_tlast),
        .m_tdata(m_tdata)
    );

    assign m_tkeep = {(AXIS4_OUTPUT_DATAWITH/8){1'b1}};    

    axis_output #(
        .AXIS4_DATAWITH(AXIS4_OUTPUT_DATAWITH)
    ) i_axis_output (
        .aclk(aclk),
        .aresetn(aresetn),

        .in_data(m_tdata),
        .in_keep(m_tkeep),
        .in_last(m_tlast),
        .in_valid(m_tvalid),
        .in_ready(m_tready),

        .m_tdata(mo_tdata),
        .m_tvalid(mo_tvalid),
        .m_tkeep(mo_tkeep),
        .m_tready(mo_tready),
        .m_tlast(mo_tlast)
    );


endmodule

`timescale 1ns / 1ps

module wrapper_pipeline #(
    parameter int unsigned ACCELERATOR_INPUT_BITWIDTH   = 128,
    parameter int unsigned INPUT_WORD_BITWIDTH          =   8,
    parameter int unsigned ACCELERATOR_OUTPUT_BITWIDTH  = 256,
    parameter int unsigned OUTPUT_WORD_BITWIDTH         =  16,
    parameter int unsigned IS_DIRECT_PP                 =   1
) (
    input  logic                                    aclk,
    input  logic                                    aresetn,

    output logic                                    sacc_tready,
    input  logic                                    sacc_tvalid,
    input  logic                                    sacc_tlast,
    input  logic [ACCELERATOR_INPUT_BITWIDTH-1:0]   sacc_tdata,

    output logic                                    macc_tvalid,
    output logic                                    macc_tlast,
    output logic [ACCELERATOR_OUTPUT_BITWIDTH-1:0]  macc_tdata,
    input  logic                                    macc_tready
);
    localparam NO_OF_IN_WORDS  = ACCELERATOR_INPUT_BITWIDTH  / INPUT_WORD_BITWIDTH;
    localparam NO_OF_OUT_WORDS = ACCELERATOR_OUTPUT_BITWIDTH / OUTPUT_WORD_BITWIDTH;

    logic [INPUT_WORD_BITWIDTH-1:0]  sacc_tdata_words [0:(NO_OF_IN_WORDS)  - 1];
    logic [OUTPUT_WORD_BITWIDTH-1:0] macc_tdata_words [0:(NO_OF_OUT_WORDS) - 1];

    input_splitter #(
        .DATA_BITWIDTH(ACCELERATOR_INPUT_BITWIDTH),
        .WORD_BITWIDTH(INPUT_WORD_BITWIDTH)
    ) i_input_splitter (
        .s_tdata(sacc_tdata),
        .sacc_tdata(sacc_tdata_words)
    );

    generate
        if(IS_DIRECT_PP == 1) begin : gen_inst_pp_fdwt
            fdwt_cdf53_pipeline i_fdwt_cdf53_pipeline(
                .clk(aclk),
                .reset_n(aresetn),

                .in_ready(sacc_tready),
                .in_valid(sacc_tvalid),
                .in_last(sacc_tlast),
                .in_data(sacc_tdata_words),

                .out_valid(macc_tvalid),
                .out_last(macc_tlast),
                .out_values_low(macc_tdata_words[(NO_OF_OUT_WORDS)/2:(NO_OF_OUT_WORDS-1)]),
                .out_values_high(macc_tdata_words[0:(((NO_OF_OUT_WORDS))/2)-1]),
                .out_ready(macc_tready)
            );
        end
        else begin : gen_inst_pp_idwt
            idwt_cdf53_pipeline i_idwt_cdf53_pipeline(
                .clk(aclk),
                .reset_n(aresetn),

                .in_ready(sacc_tready),
                .in_valid(sacc_tvalid),
                .in_last(sacc_tlast),
                .in_values_low(sacc_tdata_words[(NO_OF_IN_WORDS/2):(NO_OF_IN_WORDS-1)]),
                .in_values_high(sacc_tdata_words[0:(NO_OF_IN_WORDS/2)-1]),

                .out_valid(macc_tvalid),
                .out_last(macc_tlast),
                .out_ready(macc_tready),
                .out_values(macc_tdata_words)
            );
        end
    endgenerate

    output_aggregator # (
        .DATA_BITWIDTH(ACCELERATOR_OUTPUT_BITWIDTH),
        .WORD_BITWIDTH(OUTPUT_WORD_BITWIDTH)
    ) i_output_aggregator (
        .macc_tdata(macc_tdata_words),
        .m_tdata(macc_tdata)
    );


endmodule

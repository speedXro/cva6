`timescale 1ns / 1ps

module output_aggregator #(
    parameter  int unsigned DATA_BITWIDTH  = 512,
    parameter  int unsigned WORD_BITWIDTH  = 128,
    localparam int unsigned NO_OF_ACCELERATORS = DATA_BITWIDTH / WORD_BITWIDTH
) (
    input  logic [WORD_BITWIDTH-1:0]  macc_tdata [0:NO_OF_ACCELERATORS-1],

    output logic [DATA_BITWIDTH-1:0]  m_tdata
);

    genvar i;
    generate
        for (i = 0; i < NO_OF_ACCELERATORS; i++) begin : gen_unite_0
            assign m_tdata[(NO_OF_ACCELERATORS-1-i)*WORD_BITWIDTH +: WORD_BITWIDTH] = macc_tdata[i];
        end
    endgenerate

endmodule

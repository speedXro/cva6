`timescale 1ns / 1ps

module input_splitter #(
    parameter  int unsigned DATA_BITWIDTH               = 512,
    parameter  int unsigned WORD_BITWIDTH               = 128,
    localparam int unsigned NO_OF_ACCELERATORS          = DATA_BITWIDTH / WORD_BITWIDTH
)(
    input  logic [DATA_BITWIDTH-1:0]   s_tdata,

    output logic [WORD_BITWIDTH-1:0]   sacc_tdata [0:NO_OF_ACCELERATORS-1]
);

    genvar i;
    generate
        for (i = 0; i < NO_OF_ACCELERATORS; i++) begin : gen_split_0
            assign sacc_tdata[i]  = s_tdata[(NO_OF_ACCELERATORS-1-i)*WORD_BITWIDTH +: WORD_BITWIDTH];
        end
    endgenerate
    
endmodule

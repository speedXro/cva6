`timescale 1ns / 1ps

module input_wiring_i #(
    parameter  int unsigned AXIS4_DATAWITH              = 512,
    parameter  int unsigned ACCELERATOR_INPUT_BITWIDTH  = 128,
    localparam int unsigned NO_OF_ACCELERATORS          = AXIS4_DATAWITH / ACCELERATOR_INPUT_BITWIDTH
)(
    input  logic                                    s_tvalid,
    input  logic                                    s_tlast,
    input  logic [AXIS4_DATAWITH-1:0]               s_tdata,

    output logic [NO_OF_ACCELERATORS-1:0]           sacc_tvalid,
    output logic [NO_OF_ACCELERATORS-1:0]           sacc_tlast,
    output logic [ACCELERATOR_INPUT_BITWIDTH-1:0]   sacc_tdata [0:NO_OF_ACCELERATORS-1]
);

    genvar i;
    generate
        for (i = 0; i < NO_OF_ACCELERATORS; i++) begin : gen_split_1
            assign sacc_tdata[i]  = s_tdata[(NO_OF_ACCELERATORS-1-i)*ACCELERATOR_INPUT_BITWIDTH +: ACCELERATOR_INPUT_BITWIDTH];
            assign sacc_tvalid[i] = s_tvalid;
            assign sacc_tlast[i]  = s_tlast;
        end
    endgenerate
    
endmodule

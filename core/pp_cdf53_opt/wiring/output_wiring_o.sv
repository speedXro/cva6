`timescale 1ns / 1ps

module output_wiring_o #(
    parameter  int unsigned AXIS4_DATAWITH              = 512,
    parameter  int unsigned ACCELERATOR_OUTPUT_BITWIDTH  = 128,
    localparam int unsigned NO_OF_ACCELERATORS = AXIS4_DATAWITH / ACCELERATOR_OUTPUT_BITWIDTH
) (
    input  logic [NO_OF_ACCELERATORS-1:0]           macc_tvalid,
    input  logic [NO_OF_ACCELERATORS-1:0]           macc_tlast,
    input  logic [ACCELERATOR_OUTPUT_BITWIDTH-1:0]  macc_tdata [0:NO_OF_ACCELERATORS-1],

    output logic                                    m_tvalid,
    output logic                                    m_tlast,
    output logic [AXIS4_DATAWITH-1:0]               m_tdata
);

    genvar i;
    generate
        for (i = 0; i < NO_OF_ACCELERATORS; i++) begin : gen_unite_1
            assign m_tdata[(NO_OF_ACCELERATORS-1-i)*ACCELERATOR_OUTPUT_BITWIDTH +: ACCELERATOR_OUTPUT_BITWIDTH] = macc_tdata[i];
        end
    endgenerate

    assign m_tvalid = &macc_tvalid;
    assign m_tlast  = &macc_tlast;

endmodule

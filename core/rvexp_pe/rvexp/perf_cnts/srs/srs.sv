`timescale 1ns / 1 ps

module srs #(
    parameter NO_OF_REGS = 10,
    parameter WIDTH = 8
)(

    input  logic                   clock,
    input  logic                   reset_n,

    input  logic [NO_OF_REGS-1:0]  shift_ins,
    input  logic [WIDTH-1:0]       data_in,

    input  logic [NO_OF_REGS-1:0]  pl_ins,
    input  logic [WIDTH-1:0]       pl_in_datas [0:NO_OF_REGS-1],

    output logic [WIDTH-1:0]       data_out,

    output logic [WIDTH-1:0]       datas_out [0:NO_OF_REGS-1]
);

    logic [WIDTH-1:0] data_ins  [0:NO_OF_REGS-1];
    logic [WIDTH-1:0] data_outs [0:NO_OF_REGS-1];

    genvar i;

    generate
        for(i=0;i<NO_OF_REGS;++i) begin
            assign data_ins[i]  = (i == 0) ? data_in : data_outs[i-1];

            regg #(
                .WIDTH(WIDTH)
            ) reg_inst (
                .clock(clock),
                .reset_n(reset_n),

                .shift_in(shift_ins[i]),
                .data_in(data_ins[i]),

                .pl_in(pl_ins[i]),
                .pl_in_data(pl_in_datas[i]),

                .data_out(data_outs[i])
            );
        end
    endgenerate

    assign data_out = data_outs[NO_OF_REGS-1];
    assign datas_out = data_outs;



endmodule

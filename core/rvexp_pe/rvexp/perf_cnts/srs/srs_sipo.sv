`timescale 1ns / 1 ps

module srs_sipo #(
    parameter NO_OF_REGS = 10,
    parameter WIDTH = 8
)(
    input  logic                   clock,
    input  logic                   reset_n,

    input  logic                   serial_input_valid,
    input  logic                   serial_input_last,
    input  logic [WIDTH-1:0]       serial_input_data,
    output logic                   serial_input_ready,

    output logic                   parallel_datas_out_commit,
    output logic [WIDTH-1:0]       parallel_datas_out [0:NO_OF_REGS-1]
);
    logic [NO_OF_REGS-1:0]  shift_ins;
    logic [WIDTH-1:0]       data_in;

    logic [NO_OF_REGS-1:0]  pl_ins;
    logic [WIDTH-1:0]       pl_in_datas [0:NO_OF_REGS-1];

    logic [WIDTH-1:0]       data_out;

    logic [WIDTH-1:0]       datas_out [0:NO_OF_REGS-1];

    ctrl_sipo #(
        .NO_OF_REGS(NO_OF_REGS),
        .WIDTH(WIDTH)
    ) i_ctrl_sipo (
        .clock(clock),
        .reset_n(reset_n),

        //Controller Interface
        .serial_input_valid(serial_input_valid),
        .serial_input_last(serial_input_last),
        .serial_input_data(serial_input_data),
        .serial_input_ready(serial_input_ready),

        .parallel_datas_out_commit(parallel_datas_out_commit),
        .parallel_datas_out(parallel_datas_out),

        //SRS Interface
        .shift_ins(shift_ins),
        .data_in(data_in),
        
        .pl_ins(pl_ins),
        .pl_in_datas(pl_in_datas),

        .data_out(data_out),

        .datas_out(datas_out)
    );

    srs #(
        .NO_OF_REGS(NO_OF_REGS),
        .WIDTH(WIDTH)
    ) i_srs_for_sipo (
        .clock(clock),
        .reset_n(reset_n),

        .shift_ins(shift_ins),
        .data_in(data_in),
        
        .pl_ins(pl_ins),
        .pl_in_datas(pl_in_datas),

        .data_out(data_out),

        .datas_out(datas_out)
    );

endmodule

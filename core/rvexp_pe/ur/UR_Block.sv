`timescale 1ns / 1ps

module UR_Block(
    input  logic        clock,
    input  logic        reset_n,

    input  logic        i_uart_rx,

    output logic        ur_stop,
    output logic        ur_ready,
    input  logic        ur_clear_stop,
    input  logic        ur_clear_ready,

    output logic [7:0]  ur_qf,
    output logic [1:0]  ur_pf,
    output logic        ur_ws 
);

    logic       o_Rx_DV;
    logic [7:0] o_Rx_Byte;

    uart_rx #(
        .CLKS_PER_BIT(108)
    ) i_uart_receiver(
        .i_Clock(clock),

        .i_Rx_Serial(i_uart_rx),

        .o_Rx_DV(o_Rx_DV),
        .o_Rx_Byte(o_Rx_Byte)
    );

    UR_Control i_UR_Control(
        .clock(clock),
        .reset_n(reset_n),

        .o_Rx_DV(o_Rx_DV),
        .o_Rx_Byte(o_Rx_Byte),

        .ur_stop(ur_stop),
        .ur_ready(ur_ready),
        .ur_clear_stop(ur_clear_stop),
        .ur_clear_ready(ur_clear_ready),

        .ur_qf(ur_qf),
        .ur_pf(ur_pf),
        .ur_ws(ur_ws)
    );

endmodule

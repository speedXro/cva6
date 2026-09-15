`timescale 1 ns / 1 ps //pp_fdwt_cdf53.sv

module idwt_cdf53_pipeline(
    input  logic        clk,
    input  logic        reset_n,

    output logic        in_ready,
    input  logic        in_valid,
    input  logic        in_last,
    input  logic [15:0] in_values_low [0:7],
    input  logic [15:0] in_values_high [0:7],

    output logic        out_valid,
    output logic        out_last,
    output logic [ 7:0] out_values  [0:15],
    input  logic        out_ready
);

    logic valid_01;
    logic last_01;
    logic ready_01;
    logic [15:0] out_stage_0_r_16_odd_01  [0:7];
    logic [16:0] out_stage_0_r_17_even_01 [0:7];
    
    idwt_cdf53_stage_0 i_fdwt_cdf53_stage_0(
        .clk(clk),
        .reset_n(reset_n),

        .in_ready(in_ready),
        .in_valid(in_valid),
        .in_last(in_last),
        .in_values_low(in_values_low),
        .in_values_high(in_values_high),

        .out_valid(valid_01),
        .out_last(last_01),
        .out_stage_0_r_16_odd(out_stage_0_r_16_odd_01),
        .out_stage_0_r_17_even(out_stage_0_r_17_even_01),
        .out_ready(ready_01)
    );

    logic valid_12;
    logic last_12;
    logic ready_12;
    logic [16:0] out_stage_1_r_17_even_12 [0:7];
    logic [17:0] out_stage_1_r_18_odd_12  [0:7];

    idwt_cdf53_stage_1 i_fdwt_cdf53_stage_1(
        .clk(clk),
        .reset_n(reset_n),

        .in_ready(ready_01),
        .in_valid(valid_01),
        .in_last(last_01),
        .in_stage_0_r_16_odd(out_stage_0_r_16_odd_01),
        .in_stage_0_r_17_even(out_stage_0_r_17_even_01),

        .out_valid(valid_12),
        .out_last(last_12),
        .out_stage_1_r_17_even(out_stage_1_r_17_even_12),
        .out_stage_1_r_18_odd(out_stage_1_r_18_odd_12),
        .out_ready(ready_12)
    );

    idwt_cdf53_stage_2 i_fdwt_cdf53_stage_2(
        .clk(clk),
        .reset_n(reset_n),

        .in_ready(ready_12),
        .in_valid(valid_12),
        .in_last(last_12),
        .in_stage_1_r_17_even(out_stage_1_r_17_even_12),
        .in_stage_1_r_18_odd(out_stage_1_r_18_odd_12),


        .out_valid(out_valid),
        .out_last(out_last),
        .out_values(out_values),
        .out_ready(out_ready)
    );

endmodule

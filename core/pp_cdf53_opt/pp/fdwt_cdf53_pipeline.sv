`timescale 1 ns / 1 ps //pp_fdwt_cdf53.sv

module fdwt_cdf53_pipeline(
    input  logic        clk,
    input  logic        reset_n,

    output logic        in_ready,
    input  logic        in_valid,
    input  logic        in_last,
    input  logic [ 7:0] in_data [0:15],


    output logic        out_valid,
    output logic        out_last,
    output logic [15:0] out_values_low  [0:7],
    output logic [15:0] out_values_high [0:7],
    input  logic        out_ready
);

    logic valid_01;
    logic last_01;
    logic ready_01;
    logic [ 7:0] stage_0_r_8_even_reg [0:7];
    logic [ 8:0] stage_0_r_9_odd_reg [0:7];

    fdwt_cdf53_stage_0 i_fdwt_cdf53_stage_0(
        .clk(clk),
        .reset_n(reset_n),

        .in_ready(in_ready),
        .in_valid(in_valid),
        .in_last(in_last),
        .in_data(in_data),

        .out_valid(valid_01),
        .out_last(last_01),
        .out_stage_0_r_8_even(stage_0_r_8_even_reg),
        .out_stage_0_r_9_odd(stage_0_r_9_odd_reg),
        .out_ready(ready_01)
    );

    logic [ 8:0] stage_1_r_9_odd [0:7];
    logic [ 9:0] stage_1_r_10_even [0:7];  

    fdwt_cdf53_stage_1 i_fdwt_cdf53_stage_1(
        .clk(clk),
        .reset_n(reset_n),

        .in_ready(ready_01),
        .in_valid(valid_01),
        .in_last(last_01),
        .in_stage_0_r_8_even(stage_0_r_8_even_reg),
        .in_stage_0_r_9_odd(stage_0_r_9_odd_reg),

        .out_valid(out_valid),
        .out_last(out_last),
        .out_stage_1_r_9_odd(stage_1_r_9_odd),
        .out_stage_1_r_10_even(stage_1_r_10_even),
        .out_ready(out_ready)
    );

    genvar m;

    generate
        for(m=0;m<8;++m) begin //: gen_assign_outputs
            assign out_values_low[m]  = { {6{stage_1_r_10_even[m][9]}}, stage_1_r_10_even[m]};
            assign out_values_high[m] = { {7{stage_1_r_9_odd[m][8]}}  , stage_1_r_9_odd[m]};
        end
    endgenerate

endmodule

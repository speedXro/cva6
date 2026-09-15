`timescale 1 ns / 1 ps //pp_fdwt_cdf53.sv

module fdwt_cdf53_stage_1(
    input  logic        clk,
    input  logic        reset_n,

    output logic        in_ready,
    input  logic        in_valid,
    input  logic        in_last,
    input  logic [ 7:0] in_stage_0_r_8_even [0:7],
    input  logic [ 8:0] in_stage_0_r_9_odd [0:7],

    output logic        out_valid,
    output logic        out_last,
    output logic [ 8:0] out_stage_1_r_9_odd [0:7],
    output logic [ 9:0] out_stage_1_r_10_even [0:7],     
    input  logic        out_ready
);

    logic       valid_reg;
    logic       last_reg;
    logic [8:0] stage_1_r_9_odd_reg [0:7];
    logic [9:0] stage_1_r_10_even_reg [0:7];


    localparam IN_WIDTH_8_10  = 8;
    localparam OUT_WIDTH_8_10 = 10;

    function automatic [OUT_WIDTH_8_10-1:0] sign_extend_8_10;
        input [IN_WIDTH_8_10-1:0] in;
        begin
            sign_extend_8_10 = {{(OUT_WIDTH_8_10 - IN_WIDTH_8_10){in[IN_WIDTH_8_10-1]}}, in};
        end
    endfunction


    localparam IN_WIDTH_9_10  = 9;
    localparam OUT_WIDTH_9_10 = 10;

    function automatic [OUT_WIDTH_9_10-1:0] sign_extend_9_10;
        input [IN_WIDTH_9_10-1:0] in;
        begin
            sign_extend_9_10 = {{(OUT_WIDTH_9_10 - IN_WIDTH_9_10){in[IN_WIDTH_9_10-1]}}, in};
        end
    endfunction


    function automatic [9:0] sum_stage_1 (
        input logic [9:0] in0,
        input logic [9:0] in1
    );
        begin
            sum_stage_1 = in0 + in1;
        end
    endfunction


    function automatic [8:0] sum_plus_2_slr_2 (
        input logic [10:0] in_0,
        input logic [10:0] in_1
    );
        logic [10:0] sum;
        begin
            sum              = in_0 + in_1 + 11'd2;
            sum_plus_2_slr_2 = sum[10:2];
        end
    endfunction


    localparam IN_WIDTH_9_11  = 9;
    localparam OUT_WIDTH_9_11 = 11;

    function automatic [OUT_WIDTH_9_11-1:0] sign_extend_9_11;
        input [IN_WIDTH_9_11-1:0] in;
        begin
            sign_extend_9_11 = {{(OUT_WIDTH_9_11 - IN_WIDTH_9_11){in[IN_WIDTH_9_11-1]}}, in};
        end
    endfunction

    integer k1, i1;

    always_ff @(posedge clk or negedge reset_n) begin
        if(reset_n == 1'b0) begin
            valid_reg <= 1'b0;
            last_reg  <= 1'b0;
        end
        else begin
            if (out_ready) begin
                valid_reg <= in_valid & in_ready;
                if (in_valid & in_ready) begin
                    //data_reg <= ~in_data;   
                    for(i1=0;i1<8;++i1) begin
                        stage_1_r_9_odd_reg[i1]   <= in_stage_0_r_9_odd[i1];
                        stage_1_r_10_even_reg[i1] <= sum_stage_1(sign_extend_8_10(in_stage_0_r_8_even[i1]), sign_extend_9_10(sum_plus_2_slr_2(sign_extend_9_11(in_stage_0_r_9_odd[i1]),sign_extend_9_11(in_stage_0_r_9_odd[(i1 == 0) ? 7 : (i1 - 1)]))));
                    end
                    last_reg <=  in_last;
                end
                else begin last_reg <= 1'b0; end
            end else if (!valid_reg) begin
                if (in_valid) begin
                    valid_reg <= 1'b1;
                    //data_reg  <= ~in_data;
                    for(i1=0;i1<8;++i1) begin
                        stage_1_r_9_odd_reg[i1]   <= in_stage_0_r_9_odd[i1];
                        stage_1_r_10_even_reg[i1] <= sum_stage_1(sign_extend_8_10(in_stage_0_r_8_even[i1]), sign_extend_9_10(sum_plus_2_slr_2(sign_extend_9_11(in_stage_0_r_9_odd[i1]),sign_extend_9_11(in_stage_0_r_9_odd[(i1 == 0) ? 7 : (i1 - 1)]))));
                    end
                    last_reg  <=  in_last;
                end
                else begin last_reg <= 1'b0; end
            end
            else begin last_reg <= 1'b0; end
        end
    end

    assign in_ready                 = !valid_reg | out_ready;
    assign out_stage_1_r_9_odd      = stage_1_r_9_odd_reg;
    assign out_stage_1_r_10_even    = stage_1_r_10_even_reg;
    assign out_last                 = last_reg;
    assign out_valid                = valid_reg;

endmodule

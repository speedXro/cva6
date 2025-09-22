`timescale 1 ns / 1 ps 

module fdwt_cdf_53(
    input logic         clk,
    input logic         reset,

    input logic         input_valid,
    input logic  [63:0] input_values_1,
    input logic  [63:0] input_values_2,

    output logic        fdwt_busy,

    output logic        output_ready,
    output logic [63:0] output_values_low_03,
    output logic [63:0] output_values_low_47,
    output logic [63:0] output_values_high_03,
    output logic [63:0] output_values_high_47
);

    logic [7:0] w_8_input_00;
    logic [7:0] w_8_input_01;
    logic [7:0] w_8_input_02;
    logic [7:0] w_8_input_03;
    logic [7:0] w_8_input_04;
    logic [7:0] w_8_input_05;
    logic [7:0] w_8_input_06;
    logic [7:0] w_8_input_07;
    logic [7:0] w_8_input_08;
    logic [7:0] w_8_input_09;
    logic [7:0] w_8_input_10;
    logic [7:0] w_8_input_11;
    logic [7:0] w_8_input_12;
    logic [7:0] w_8_input_13;
    logic [7:0] w_8_input_14;
    logic [7:0] w_8_input_15;

    logic [7:0] w_8_even_0;
    logic [7:0] w_8_even_1;
    logic [7:0] w_8_even_2;
    logic [7:0] w_8_even_3;
    logic [7:0] w_8_even_4;
    logic [7:0] w_8_even_5;
    logic [7:0] w_8_even_6;
    logic [7:0] w_8_even_7;

    logic [7:0] w_8_odd_0;
    logic [7:0] w_8_odd_1;
    logic [7:0] w_8_odd_2;
    logic [7:0] w_8_odd_3;
    logic [7:0] w_8_odd_4;
    logic [7:0] w_8_odd_5;
    logic [7:0] w_8_odd_6;
    logic [7:0] w_8_odd_7;

    //for stage 1
    logic [8:0] r_9_odd_0;
    logic [8:0] r_9_odd_1;
    logic [8:0] r_9_odd_2;
    logic [8:0] r_9_odd_3;
    logic [8:0] r_9_odd_4;
    logic [8:0] r_9_odd_5;
    logic [8:0] r_9_odd_6;
    logic [8:0] r_9_odd_7;

    //for stage2
    logic [ 9:0] r_10_even_0;
    logic [ 9:0] r_10_even_1;
    logic [ 9:0] r_10_even_2;
    logic [ 9:0] r_10_even_3;
    logic [ 9:0] r_10_even_4;
    logic [ 9:0] r_10_even_5;
    logic [ 9:0] r_10_even_6;
    logic [ 9:0] r_10_even_7;

    //for outputs assignments
    logic [15:0] output_low_0;
    logic [15:0] output_low_1;
    logic [15:0] output_low_2;
    logic [15:0] output_low_3;
    logic [15:0] output_low_4;
    logic [15:0] output_low_5;
    logic [15:0] output_low_6;
    logic [15:0] output_low_7;

    logic [15:0] output_high_0;
    logic [15:0] output_high_1;
    logic [15:0] output_high_2;
    logic [15:0] output_high_3;
    logic [15:0] output_high_4;
    logic [15:0] output_high_5;
    logic [15:0] output_high_6;
    logic [15:0] output_high_7;

    logic [1:0] state;

    localparam IN_WIDTH_8_9  = 8;
    localparam OUT_WIDTH_8_9 = 9;

    function automatic [OUT_WIDTH_8_9-1:0] sign_extend_8_9;
        input [IN_WIDTH_8_9-1:0] in;
        begin
            sign_extend_8_9 = {{(OUT_WIDTH_8_9 - IN_WIDTH_8_9){in[IN_WIDTH_8_9-1]}}, in};
        end
    endfunction

    function automatic [7:0] sum_slr_1 (
        input logic [8:0] in_0,
        input logic [8:0] in_1
    );
        logic [8:0] sum;
        begin
            sum       = in_0 + in_1;
            sum_slr_1 = sum[8:1];
        end
    endfunction

    function automatic [8:0] diff_stage_0 (
        input logic [8:0] in0,
        input logic [8:0] in1
    );
        begin
            diff_stage_0 = in0 - in1;
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

    localparam IN_WIDTH_9_10  = 9;
    localparam OUT_WIDTH_9_10 = 10;

    function automatic [OUT_WIDTH_9_10-1:0] sign_extend_9_10;
        input [IN_WIDTH_9_10-1:0] in;
        begin
            sign_extend_9_10 = {{(OUT_WIDTH_9_10 - IN_WIDTH_9_10){in[IN_WIDTH_9_10-1]}}, in};
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

    localparam IN_WIDTH_8_10  = 8;
    localparam OUT_WIDTH_8_10 = 10;

    function automatic [OUT_WIDTH_8_10-1:0] sign_extend_8_10;
        input [IN_WIDTH_8_10-1:0] in;
        begin
            sign_extend_8_10 = {{(OUT_WIDTH_8_10 - IN_WIDTH_8_10){in[IN_WIDTH_8_10-1]}}, in};
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

    assign {
        w_8_input_00, w_8_input_01, w_8_input_02, w_8_input_03,
        w_8_input_04, w_8_input_05, w_8_input_06, w_8_input_07,
        w_8_input_08, w_8_input_09, w_8_input_10, w_8_input_11,
        w_8_input_12, w_8_input_13, w_8_input_14, w_8_input_15
    } = {input_values_1, input_values_2};

    assign {
        w_8_even_0, w_8_even_1, w_8_even_2, w_8_even_3,
        w_8_even_4, w_8_even_5, w_8_even_6, w_8_even_7
    } = {
        w_8_input_00, w_8_input_02, w_8_input_04, w_8_input_06,
        w_8_input_08, w_8_input_10, w_8_input_12, w_8_input_14
    };

    assign {
        w_8_odd_0, w_8_odd_1, w_8_odd_2, w_8_odd_3,
        w_8_odd_4, w_8_odd_5, w_8_odd_6, w_8_odd_7
    } = {
        w_8_input_01, w_8_input_03, w_8_input_05, w_8_input_07,
        w_8_input_09, w_8_input_11, w_8_input_13, w_8_input_15
    };

    always @(posedge clk) begin
        if(reset == 1'b1) begin
            state        <= 2'd0;

            fdwt_busy    <= 1'd0;
            output_ready <= 1'd0;

            r_9_odd_0   <= 9'd0;
            r_9_odd_1   <= 9'd0;
            r_9_odd_2   <= 9'd0;
            r_9_odd_3   <= 9'd0;
            r_9_odd_4   <= 9'd0;
            r_9_odd_5   <= 9'd0;
            r_9_odd_6   <= 9'd0;
            r_9_odd_7   <= 9'd0;

            r_10_even_0  <= 10'd0;
            r_10_even_1  <= 10'd0;
            r_10_even_2  <= 10'd0;
            r_10_even_3  <= 10'd0;
            r_10_even_4  <= 10'd0;
            r_10_even_5  <= 10'd0;
            r_10_even_6  <= 10'd0;
            r_10_even_7  <= 10'd0;
        end

        else if(state == 2'd0 && input_valid == 1'b1) begin
            fdwt_busy <= 1'b1;

            r_9_odd_0 <= diff_stage_0(sign_extend_8_9(w_8_odd_0), sign_extend_8_9(sum_slr_1(sign_extend_8_9(w_8_even_0),sign_extend_8_9(w_8_even_1))));
            r_9_odd_1 <= diff_stage_0(sign_extend_8_9(w_8_odd_1), sign_extend_8_9(sum_slr_1(sign_extend_8_9(w_8_even_1),sign_extend_8_9(w_8_even_2))));
            r_9_odd_2 <= diff_stage_0(sign_extend_8_9(w_8_odd_2), sign_extend_8_9(sum_slr_1(sign_extend_8_9(w_8_even_2),sign_extend_8_9(w_8_even_3))));
            r_9_odd_3 <= diff_stage_0(sign_extend_8_9(w_8_odd_3), sign_extend_8_9(sum_slr_1(sign_extend_8_9(w_8_even_3),sign_extend_8_9(w_8_even_4))));
            r_9_odd_4 <= diff_stage_0(sign_extend_8_9(w_8_odd_4), sign_extend_8_9(sum_slr_1(sign_extend_8_9(w_8_even_4),sign_extend_8_9(w_8_even_5))));
            r_9_odd_5 <= diff_stage_0(sign_extend_8_9(w_8_odd_5), sign_extend_8_9(sum_slr_1(sign_extend_8_9(w_8_even_5),sign_extend_8_9(w_8_even_6))));
            r_9_odd_6 <= diff_stage_0(sign_extend_8_9(w_8_odd_6), sign_extend_8_9(sum_slr_1(sign_extend_8_9(w_8_even_6),sign_extend_8_9(w_8_even_7))));
            r_9_odd_7 <= diff_stage_0(sign_extend_8_9(w_8_odd_7), sign_extend_8_9(sum_slr_1(sign_extend_8_9(w_8_even_7),sign_extend_8_9(w_8_even_0))));

            state <= 2'd1;

            
        end

        else if(state == 2'd1) begin
            $display("Stage 0 odds : %d, %d, %d, %d, %d, %d, %d, %d", 
                r_9_odd_0, r_9_odd_1, r_9_odd_2, r_9_odd_3, r_9_odd_4, r_9_odd_5, r_9_odd_6, r_9_odd_7);
            r_10_even_0 <= sum_stage_1(sign_extend_8_10(w_8_even_0), sign_extend_9_10(sum_plus_2_slr_2(sign_extend_9_11(r_9_odd_0),sign_extend_9_11(r_9_odd_7))));
            r_10_even_1 <= sum_stage_1(sign_extend_8_10(w_8_even_1), sign_extend_9_10(sum_plus_2_slr_2(sign_extend_9_11(r_9_odd_1),sign_extend_9_11(r_9_odd_0))));
            r_10_even_2 <= sum_stage_1(sign_extend_8_10(w_8_even_2), sign_extend_9_10(sum_plus_2_slr_2(sign_extend_9_11(r_9_odd_2),sign_extend_9_11(r_9_odd_1))));
            r_10_even_3 <= sum_stage_1(sign_extend_8_10(w_8_even_3), sign_extend_9_10(sum_plus_2_slr_2(sign_extend_9_11(r_9_odd_3),sign_extend_9_11(r_9_odd_2))));
            r_10_even_4 <= sum_stage_1(sign_extend_8_10(w_8_even_4), sign_extend_9_10(sum_plus_2_slr_2(sign_extend_9_11(r_9_odd_4),sign_extend_9_11(r_9_odd_3))));
            r_10_even_5 <= sum_stage_1(sign_extend_8_10(w_8_even_5), sign_extend_9_10(sum_plus_2_slr_2(sign_extend_9_11(r_9_odd_5),sign_extend_9_11(r_9_odd_4))));
            r_10_even_6 <= sum_stage_1(sign_extend_8_10(w_8_even_6), sign_extend_9_10(sum_plus_2_slr_2(sign_extend_9_11(r_9_odd_6),sign_extend_9_11(r_9_odd_5))));
            r_10_even_7 <= sum_stage_1(sign_extend_8_10(w_8_even_7), sign_extend_9_10(sum_plus_2_slr_2(sign_extend_9_11(r_9_odd_7),sign_extend_9_11(r_9_odd_6))));

            output_ready <= 1'b1;

            state <= 2'd2;
        end

        else if(state == 2'd2) begin
            $display("Outs: %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d",
                output_low_0, output_low_1, output_low_2, output_low_3, output_low_4, output_low_5, output_low_6, output_low_7,
                output_high_0, output_high_1, output_high_2, output_high_3, output_high_4, output_high_5, output_high_6, output_high_7);
            state        <= 2'd0;

            fdwt_busy    <= 1'd0;
            output_ready <= 1'd0;

            r_9_odd_0   <= 9'd0;
            r_9_odd_1   <= 9'd0;
            r_9_odd_2   <= 9'd0;
            r_9_odd_3   <= 9'd0;
            r_9_odd_4   <= 9'd0;
            r_9_odd_5   <= 9'd0;
            r_9_odd_6   <= 9'd0;
            r_9_odd_7   <= 9'd0;

            r_10_even_0  <= 10'd0;
            r_10_even_1  <= 10'd0;
            r_10_even_2  <= 10'd0;
            r_10_even_3  <= 10'd0;
            r_10_even_4  <= 10'd0;
            r_10_even_5  <= 10'd0;
            r_10_even_6  <= 10'd0;
            r_10_even_7  <= 10'd0;
        end
    end

    assign output_low_0 = { {6{r_10_even_0[9]}}, r_10_even_0};
    assign output_low_1 = { {6{r_10_even_1[9]}}, r_10_even_1};
    assign output_low_2 = { {6{r_10_even_2[9]}}, r_10_even_2};
    assign output_low_3 = { {6{r_10_even_3[9]}}, r_10_even_3};
    assign output_low_4 = { {6{r_10_even_4[9]}}, r_10_even_4};
    assign output_low_5 = { {6{r_10_even_5[9]}}, r_10_even_5};
    assign output_low_6 = { {6{r_10_even_6[9]}}, r_10_even_6};
    assign output_low_7 = { {6{r_10_even_7[9]}}, r_10_even_7};

    assign output_high_0 = { {7{r_9_odd_0[8]}}, r_9_odd_0};
    assign output_high_1 = { {7{r_9_odd_1[8]}}, r_9_odd_1};
    assign output_high_2 = { {7{r_9_odd_2[8]}}, r_9_odd_2};
    assign output_high_3 = { {7{r_9_odd_3[8]}}, r_9_odd_3};
    assign output_high_4 = { {7{r_9_odd_4[8]}}, r_9_odd_4};
    assign output_high_5 = { {7{r_9_odd_5[8]}}, r_9_odd_5};
    assign output_high_6 = { {7{r_9_odd_6[8]}}, r_9_odd_6};
    assign output_high_7 = { {7{r_9_odd_7[8]}}, r_9_odd_7};

    assign output_values_low_03 = {output_low_0, output_low_1, output_low_2, output_low_3};
    assign output_values_low_47 = {output_low_4, output_low_5, output_low_6, output_low_7};
    assign output_values_high_03 = {output_high_0, output_high_1, output_high_2, output_high_3};
    assign output_values_high_47 = {output_high_4, output_high_5, output_high_6, output_high_7};


endmodule
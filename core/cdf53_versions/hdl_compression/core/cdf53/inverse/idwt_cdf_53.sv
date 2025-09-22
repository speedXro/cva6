`timescale 1 ns / 1 ps 

module idwt_cdf_53(
    input  logic        clk,
    input  logic        reset,

    input  logic        input_valid,
    input  logic [63:0] input_values_low_03,
    input  logic [63:0] input_values_low_47,
    input  logic [63:0] input_values_high_03,
    input  logic [63:0] input_values_high_47,

    output logic        idwt_busy,

    output logic        output_ready,
    output logic [63:0] output_values_1,
    output logic [63:0] output_values_2

);

    logic [15:0] w_16_low_0;
    logic [15:0] w_16_low_1;
    logic [15:0] w_16_low_2;
    logic [15:0] w_16_low_3;
    logic [15:0] w_16_low_4;
    logic [15:0] w_16_low_5;
    logic [15:0] w_16_low_6;
    logic [15:0] w_16_low_7;

    logic [15:0] w_16_high_0;
    logic [15:0] w_16_high_1;
    logic [15:0] w_16_high_2;
    logic [15:0] w_16_high_3;
    logic [15:0] w_16_high_4;
    logic [15:0] w_16_high_5;
    logic [15:0] w_16_high_6;
    logic [15:0] w_16_high_7;

    logic [15:0] w_16_even_0;
    logic [15:0] w_16_even_1;
    logic [15:0] w_16_even_2;
    logic [15:0] w_16_even_3;
    logic [15:0] w_16_even_4;
    logic [15:0] w_16_even_5;
    logic [15:0] w_16_even_6;
    logic [15:0] w_16_even_7;

    logic [15:0] w_16_odd_0;
    logic [15:0] w_16_odd_1;
    logic [15:0] w_16_odd_2;
    logic [15:0] w_16_odd_3;
    logic [15:0] w_16_odd_4;
    logic [15:0] w_16_odd_5;
    logic [15:0] w_16_odd_6;
    logic [15:0] w_16_odd_7;

    //for stage 1
    logic [16:0] r_17_even_0;
    logic [16:0] r_17_even_1;
    logic [16:0] r_17_even_2;
    logic [16:0] r_17_even_3;
    logic [16:0] r_17_even_4;
    logic [16:0] r_17_even_5;
    logic [16:0] r_17_even_6;
    logic [16:0] r_17_even_7;

    //for stage 2
    logic [17:0] r_18_odd_0;
    logic [17:0] r_18_odd_1;
    logic [17:0] r_18_odd_2;
    logic [17:0] r_18_odd_3;
    logic [17:0] r_18_odd_4;
    logic [17:0] r_18_odd_5;
    logic [17:0] r_18_odd_6;
    logic [17:0] r_18_odd_7;

    //for stage3
    logic [7:0] r_8_out_00;
    logic [7:0] r_8_out_01;
    logic [7:0] r_8_out_02;
    logic [7:0] r_8_out_03;
    logic [7:0] r_8_out_04;
    logic [7:0] r_8_out_05;
    logic [7:0] r_8_out_06;
    logic [7:0] r_8_out_07;
    logic [7:0] r_8_out_08;
    logic [7:0] r_8_out_09;
    logic [7:0] r_8_out_10;
    logic [7:0] r_8_out_11;
    logic [7:0] r_8_out_12;
    logic [7:0] r_8_out_13;
    logic [7:0] r_8_out_14;
    logic [7:0] r_8_out_15;

    logic [1:0] state;

    localparam IN_WIDTH_16_18  = 16;
    localparam OUT_WIDTH_16_18 = 18;

    function automatic [OUT_WIDTH_16_18-1:0] sign_extend_16_18;
        input [IN_WIDTH_16_18-1:0] in;
        begin
            sign_extend_16_18 = {{(OUT_WIDTH_16_18 - IN_WIDTH_16_18){in[IN_WIDTH_16_18-1]}}, in};
        end
    endfunction

    localparam IN_WIDTH_16_17  = 16;
    localparam OUT_WIDTH_16_17 = 17;

    function automatic [OUT_WIDTH_16_17-1:0] sign_extend_16_17;
        input [IN_WIDTH_16_17-1:0] in;
        begin
            sign_extend_16_17 = {{(OUT_WIDTH_16_17 - IN_WIDTH_16_17){in[IN_WIDTH_16_17-1]}}, in};
        end
    endfunction

    function automatic [15:0] sum_plus_2_slr_2 (
        input logic [17:0] in_0,
        input logic [17:0] in_1
    );
        logic [17:0] sum;
        begin
            sum              = in_0 + in_1 + 18'd2;
            sum_plus_2_slr_2 = sum[17:2];
        end
    endfunction

    function automatic [16:0] diff_stage_0 (
        input logic [16:0] in0,
        input logic [16:0] in1
    );
        begin
            diff_stage_0 = in0 - in1;
        end
    endfunction

    localparam IN_WIDTH_17_18  = 17;
    localparam OUT_WIDTH_17_18 = 18;

    function automatic [OUT_WIDTH_17_18-1:0] sign_extend_17_18;
        input [IN_WIDTH_17_18-1:0] in;
        begin
            sign_extend_17_18 = {{(OUT_WIDTH_17_18 - IN_WIDTH_17_18){in[IN_WIDTH_17_18-1]}}, in};
        end
    endfunction

    function automatic [16:0] sum_slr_1 (
        input logic [17:0] in_0,
        input logic [17:0] in_1
    );
        logic [17:0] sum;
        begin
            sum       = in_0 + in_1;
            sum_slr_1 = sum[17:1];
        end
    endfunction

    function automatic [17:0] sum_stage_1 (
        input logic [17:0] in0,
        input logic [17:0] in1
    );
        begin
            sum_stage_1 = in0 + in1;
        end
    endfunction

    function automatic logic signed [7:0] clamp_i8_in_17b (input logic signed [16:0] in);
        logic signed [16:0] aux;
        begin
            if(in > 127) begin aux = 17'd127; end
            else if(in < -128) begin aux = -128; end
            else aux = in;

            clamp_i8_in_17b = aux[7:0];
        end
    endfunction

    function automatic logic signed [7:0] clamp_i8_in_18b (input logic signed [17:0] in);
        logic signed [17:0] aux;
        begin
            if(in > 127) begin aux = 18'd127; end
            else if(in < -128) begin aux = -128; end
            else aux = in;

            clamp_i8_in_18b = aux[7:0];
        end
    endfunction

    assign {
        w_16_low_0, w_16_low_1, w_16_low_2, w_16_low_3,
        w_16_low_4, w_16_low_5, w_16_low_6, w_16_low_7
    } = {input_values_low_03, input_values_low_47};

    assign {
        w_16_high_0, w_16_high_1, w_16_high_2, w_16_high_3,
        w_16_high_4, w_16_high_5, w_16_high_6, w_16_high_7
    } = {input_values_high_03, input_values_high_47};

    assign {
        w_16_even_0, w_16_even_1, w_16_even_2, w_16_even_3,
        w_16_even_4, w_16_even_5, w_16_even_6, w_16_even_7
    } = {
        w_16_low_0, w_16_low_1, w_16_low_2, w_16_low_3,
        w_16_low_4, w_16_low_5, w_16_low_6, w_16_low_7
    };

    assign {
        w_16_odd_0, w_16_odd_1, w_16_odd_2, w_16_odd_3,
        w_16_odd_4, w_16_odd_5, w_16_odd_6, w_16_odd_7
    } = {
        w_16_high_0, w_16_high_1, w_16_high_2, w_16_high_3,
        w_16_high_4, w_16_high_5, w_16_high_6, w_16_high_7
    };

    always @(posedge clk) begin
        if(reset == 1'b1) begin
            state     <= 2'd0;

            idwt_busy <= 1'b0;

            output_ready <= 1'd0;

            r_17_even_0 <= 17'd0;
            r_17_even_1 <= 17'd0;
            r_17_even_2 <= 17'd0;
            r_17_even_3 <= 17'd0;
            r_17_even_4 <= 17'd0;
            r_17_even_5 <= 17'd0;
            r_17_even_6 <= 17'd0;
            r_17_even_7 <= 17'd0;

            r_18_odd_0 <= 18'd0;
            r_18_odd_1 <= 18'd0;
            r_18_odd_2 <= 18'd0;
            r_18_odd_3 <= 18'd0;
            r_18_odd_4 <= 18'd0;
            r_18_odd_5 <= 18'd0;
            r_18_odd_6 <= 18'd0;
            r_18_odd_7 <= 18'd0;

            r_8_out_00 <= 8'd0;
            r_8_out_01 <= 8'd0;
            r_8_out_02 <= 8'd0;
            r_8_out_03 <= 8'd0;
            r_8_out_04 <= 8'd0;
            r_8_out_05 <= 8'd0;
            r_8_out_06 <= 8'd0;
            r_8_out_07 <= 8'd0;
            r_8_out_08 <= 8'd0;
            r_8_out_09 <= 8'd0;
            r_8_out_10 <= 8'd0;
            r_8_out_11 <= 8'd0;
            r_8_out_12 <= 8'd0;
            r_8_out_13 <= 8'd0;
            r_8_out_14 <= 8'd0;
            r_8_out_15 <= 8'd0;
        end

        else if(state == 2'd0 && input_valid == 1'b1) begin
            idwt_busy   <= 1'b1;

            r_17_even_0 <= diff_stage_0(sign_extend_16_17(w_16_even_0), sign_extend_16_17(sum_plus_2_slr_2(sign_extend_16_18(w_16_odd_0), sign_extend_16_18(w_16_odd_7))));
            r_17_even_1 <= diff_stage_0(sign_extend_16_17(w_16_even_1), sign_extend_16_17(sum_plus_2_slr_2(sign_extend_16_18(w_16_odd_1), sign_extend_16_18(w_16_odd_0))));
            r_17_even_2 <= diff_stage_0(sign_extend_16_17(w_16_even_2), sign_extend_16_17(sum_plus_2_slr_2(sign_extend_16_18(w_16_odd_2), sign_extend_16_18(w_16_odd_1))));
            r_17_even_3 <= diff_stage_0(sign_extend_16_17(w_16_even_3), sign_extend_16_17(sum_plus_2_slr_2(sign_extend_16_18(w_16_odd_3), sign_extend_16_18(w_16_odd_2))));
            r_17_even_4 <= diff_stage_0(sign_extend_16_17(w_16_even_4), sign_extend_16_17(sum_plus_2_slr_2(sign_extend_16_18(w_16_odd_4), sign_extend_16_18(w_16_odd_3))));
            r_17_even_5 <= diff_stage_0(sign_extend_16_17(w_16_even_5), sign_extend_16_17(sum_plus_2_slr_2(sign_extend_16_18(w_16_odd_5), sign_extend_16_18(w_16_odd_4))));
            r_17_even_6 <= diff_stage_0(sign_extend_16_17(w_16_even_6), sign_extend_16_17(sum_plus_2_slr_2(sign_extend_16_18(w_16_odd_6), sign_extend_16_18(w_16_odd_5))));
            r_17_even_7 <= diff_stage_0(sign_extend_16_17(w_16_even_7), sign_extend_16_17(sum_plus_2_slr_2(sign_extend_16_18(w_16_odd_7), sign_extend_16_18(w_16_odd_6))));

            state <= 2'd1;
        end

        else if(state == 2'd1) begin
            $display("Stage 0 evens : %06h, %06h, %06h, %06h, %06h, %06h, %06h, %06h", 
                r_17_even_0, r_17_even_1, r_17_even_2, r_17_even_3, r_17_even_4, r_17_even_5, r_17_even_6, r_17_even_7);
            r_18_odd_0 <= sum_stage_1(sign_extend_16_18(w_16_odd_0), sign_extend_17_18(sum_slr_1(sign_extend_17_18(r_17_even_0), sign_extend_17_18(r_17_even_1))));
            r_18_odd_1 <= sum_stage_1(sign_extend_16_18(w_16_odd_1), sign_extend_17_18(sum_slr_1(sign_extend_17_18(r_17_even_1), sign_extend_17_18(r_17_even_2))));
            r_18_odd_2 <= sum_stage_1(sign_extend_16_18(w_16_odd_2), sign_extend_17_18(sum_slr_1(sign_extend_17_18(r_17_even_2), sign_extend_17_18(r_17_even_3))));
            r_18_odd_3 <= sum_stage_1(sign_extend_16_18(w_16_odd_3), sign_extend_17_18(sum_slr_1(sign_extend_17_18(r_17_even_3), sign_extend_17_18(r_17_even_4))));
            r_18_odd_4 <= sum_stage_1(sign_extend_16_18(w_16_odd_4), sign_extend_17_18(sum_slr_1(sign_extend_17_18(r_17_even_4), sign_extend_17_18(r_17_even_5))));
            r_18_odd_5 <= sum_stage_1(sign_extend_16_18(w_16_odd_5), sign_extend_17_18(sum_slr_1(sign_extend_17_18(r_17_even_5), sign_extend_17_18(r_17_even_6))));
            r_18_odd_6 <= sum_stage_1(sign_extend_16_18(w_16_odd_6), sign_extend_17_18(sum_slr_1(sign_extend_17_18(r_17_even_6), sign_extend_17_18(r_17_even_7))));
            r_18_odd_7 <= sum_stage_1(sign_extend_16_18(w_16_odd_7), sign_extend_17_18(sum_slr_1(sign_extend_17_18(r_17_even_7), sign_extend_17_18(r_17_even_0))));

            state <= 2'd2;
        end

        else if(state == 2'd2) begin
            $display("Stage 1 odds : %06h, %06h, %06h, %06h, %06h, %06h, %06h, %06h", 
                r_18_odd_0, r_18_odd_1, r_18_odd_2, r_18_odd_3, r_18_odd_4, r_18_odd_5, r_18_odd_6, r_18_odd_7);

            r_8_out_00 <= clamp_i8_in_17b(r_17_even_0);
            r_8_out_02 <= clamp_i8_in_17b(r_17_even_1);
            r_8_out_04 <= clamp_i8_in_17b(r_17_even_2);
            r_8_out_06 <= clamp_i8_in_17b(r_17_even_3);
            r_8_out_08 <= clamp_i8_in_17b(r_17_even_4);
            r_8_out_10 <= clamp_i8_in_17b(r_17_even_5);
            r_8_out_12 <= clamp_i8_in_17b(r_17_even_6);
            r_8_out_14 <= clamp_i8_in_17b(r_17_even_7);

            r_8_out_01 <= clamp_i8_in_18b(r_18_odd_0);
            r_8_out_03 <= clamp_i8_in_18b(r_18_odd_1);
            r_8_out_05 <= clamp_i8_in_18b(r_18_odd_2);
            r_8_out_07 <= clamp_i8_in_18b(r_18_odd_3);
            r_8_out_09 <= clamp_i8_in_18b(r_18_odd_4);
            r_8_out_11 <= clamp_i8_in_18b(r_18_odd_5);
            r_8_out_13 <= clamp_i8_in_18b(r_18_odd_6);
            r_8_out_15 <= clamp_i8_in_18b(r_18_odd_7);

            output_ready <= 1'b1;

            state <= 2'd3;
        end

        else if(state == 2'd3) begin
            $display("Stage 2 outs : %04h, %04h, %04h, %04h, %04h, %04h, %04h, %04h, %04h, %04h, %04h, %04h, %04h, %04h, %04h, %04h", 
                r_8_out_00, r_8_out_01, r_8_out_02, r_8_out_03, r_8_out_04, r_8_out_05, r_8_out_06, r_8_out_07, 
                r_8_out_08, r_8_out_09, r_8_out_10, r_8_out_11, r_8_out_12, r_8_out_13, r_8_out_14, r_8_out_15);
            
            state        <= 2'd0;

            idwt_busy    <= 1'b0;

            output_ready <= 1'd0;

            r_17_even_0 <= 17'd0;
            r_17_even_1 <= 17'd0;
            r_17_even_2 <= 17'd0;
            r_17_even_3 <= 17'd0;
            r_17_even_4 <= 17'd0;
            r_17_even_5 <= 17'd0;
            r_17_even_6 <= 17'd0;
            r_17_even_7 <= 17'd0;

            r_18_odd_0 <= 18'd0;
            r_18_odd_1 <= 18'd0;
            r_18_odd_2 <= 18'd0;
            r_18_odd_3 <= 18'd0;
            r_18_odd_4 <= 18'd0;
            r_18_odd_5 <= 18'd0;
            r_18_odd_6 <= 18'd0;
            r_18_odd_7 <= 18'd0;

            r_8_out_00 <= 8'd0;
            r_8_out_01 <= 8'd0;
            r_8_out_02 <= 8'd0;
            r_8_out_03 <= 8'd0;
            r_8_out_04 <= 8'd0;
            r_8_out_05 <= 8'd0;
            r_8_out_06 <= 8'd0;
            r_8_out_07 <= 8'd0;
            r_8_out_08 <= 8'd0;
            r_8_out_09 <= 8'd0;
            r_8_out_10 <= 8'd0;
            r_8_out_11 <= 8'd0;
            r_8_out_12 <= 8'd0;
            r_8_out_13 <= 8'd0;
            r_8_out_14 <= 8'd0;
            r_8_out_15 <= 8'd0;
        end
    end

    assign output_values_1 = {
        r_8_out_00, r_8_out_01, r_8_out_02, r_8_out_03,
        r_8_out_04, r_8_out_05, r_8_out_06, r_8_out_07
    };
    assign output_values_2 = {
        r_8_out_08, r_8_out_09, r_8_out_10, r_8_out_11,
        r_8_out_12, r_8_out_13, r_8_out_14, r_8_out_15
    };
    

endmodule
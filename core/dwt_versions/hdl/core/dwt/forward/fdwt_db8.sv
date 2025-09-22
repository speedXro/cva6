`timescale 1 ns / 1 ps 

module fdwt_db8(
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

    logic signed [7:0] w_8_input_00;
    logic signed [7:0] w_8_input_01;
    logic signed [7:0] w_8_input_02;
    logic signed [7:0] w_8_input_03;
    logic signed [7:0] w_8_input_04;
    logic signed [7:0] w_8_input_05;
    logic signed [7:0] w_8_input_06;
    logic signed [7:0] w_8_input_07;
    logic signed [7:0] w_8_input_08;
    logic signed [7:0] w_8_input_09;
    logic signed [7:0] w_8_input_10;
    logic signed [7:0] w_8_input_11;
    logic signed [7:0] w_8_input_12;
    logic signed [7:0] w_8_input_13;
    logic signed [7:0] w_8_input_14;
    logic signed [7:0] w_8_input_15;

    logic signed [31:0] sumL_0;
    logic signed [31:0] sumL_1;
    logic signed [31:0] sumL_2;
    logic signed [31:0] sumL_3;
    logic signed [31:0] sumL_4;
    logic signed [31:0] sumL_5;
    logic signed [31:0] sumL_6;
    logic signed [31:0] sumL_7;

    logic signed [31:0] sumH_0;
    logic signed [31:0] sumH_1;
    logic signed [31:0] sumH_2;
    logic signed [31:0] sumH_3;
    logic signed [31:0] sumH_4;
    logic signed [31:0] sumH_5;
    logic signed [31:0] sumH_6;
    logic signed [31:0] sumH_7;

    logic [3:0] state;

    //constants
    localparam logic signed [15:0] H_00 =   1784;
    localparam logic signed [15:0] H_01 =  10239;
    localparam logic signed [15:0] H_02 =  22193;
    localparam logic signed [15:0] H_03 =  19166;
    localparam logic signed [15:0] H_04 =   -518;
    localparam logic signed [15:0] H_05 =  -9305;
    localparam logic signed [15:0] H_06 =     15;
    localparam logic signed [15:0] H_07 =   4216;
    localparam logic signed [15:0] H_08 =   -569;
    localparam logic signed [15:0] H_09 =  -1443;
    localparam logic signed [15:0] H_10 =    458;
    localparam logic signed [15:0] H_11 =    287;
    localparam logic signed [15:0] H_12 =   -160;
    localparam logic signed [15:0] H_13 =    -13;
    localparam logic signed [15:0] H_14 =     22;
    localparam logic signed [15:0] H_15 =     -4;

    localparam logic signed [15:0] G_00 =     -4;
    localparam logic signed [15:0] G_01 =    -22;
    localparam logic signed [15:0] G_02 =    -13;
    localparam logic signed [15:0] G_03 =    160;
    localparam logic signed [15:0] G_04 =    287;
    localparam logic signed [15:0] G_05 =   -458;
    localparam logic signed [15:0] G_06 =  -1443;
    localparam logic signed [15:0] G_07 =    569;
    localparam logic signed [15:0] G_08 =   4216;
    localparam logic signed [15:0] G_09 =    -15;
    localparam logic signed [15:0] G_10 =  -9305;
    localparam logic signed [15:0] G_11 =    518;
    localparam logic signed [15:0] G_12 =  19166;
    localparam logic signed [15:0] G_13 = -22193;
    localparam logic signed [15:0] G_14 =  10239;
    localparam logic signed [15:0] G_15 =  -1784;

    //inputs wiring
    assign {
        w_8_input_00, w_8_input_01, w_8_input_02, w_8_input_03,
        w_8_input_04, w_8_input_05, w_8_input_06, w_8_input_07,
        w_8_input_08, w_8_input_09, w_8_input_10, w_8_input_11,
        w_8_input_12, w_8_input_13, w_8_input_14, w_8_input_15
    } = {input_values_1, input_values_2};

    //FSM
    always_ff @(posedge clk) begin
        if(reset == 1'b1) begin
            state  <=  4'd0;

            fdwt_busy <= 1'd0;

            sumL_0 <= 32'd0;
            sumL_1 <= 32'd0;
            sumL_2 <= 32'd0;
            sumL_3 <= 32'd0;
            sumL_4 <= 32'd0;
            sumL_5 <= 32'd0;
            sumL_6 <= 32'd0;
            sumL_7 <= 32'd0;

            sumH_0 <= 32'd0;
            sumH_1 <= 32'd0;
            sumH_2 <= 32'd0;
            sumH_3 <= 32'd0;
            sumH_4 <= 32'd0;
            sumH_5 <= 32'd0;
            sumH_6 <= 32'd0;
            sumH_7 <= 32'd0;

            output_ready <= 1'd0;
        end

        if(state == 4'd0 && input_valid == 1'b1) begin
            fdwt_busy <= 1'b1;

            sumL_0 <= sumL_0 + ((w_8_input_00 * H_00) + (w_8_input_01 * H_01));
            sumH_0 <= sumH_0 + ((w_8_input_00 * G_00) + (w_8_input_01 * G_01));

            sumL_1 <= sumL_1 + ((w_8_input_02 * H_00) + (w_8_input_03 * H_01));
            sumH_1 <= sumH_1 + ((w_8_input_02 * G_00) + (w_8_input_03 * G_01));

            sumL_2 <= sumL_2 + ((w_8_input_04 * H_00) + (w_8_input_05 * H_01));
            sumH_2 <= sumH_2 + ((w_8_input_04 * G_00) + (w_8_input_05 * G_01));

            sumL_3 <= sumL_3 + ((w_8_input_06 * H_00) + (w_8_input_07 * H_01));
            sumH_3 <= sumH_3 + ((w_8_input_06 * G_00) + (w_8_input_07 * G_01));

            sumL_4 <= sumL_4 + ((w_8_input_08 * H_00) + (w_8_input_09 * H_01));
            sumH_4 <= sumH_4 + ((w_8_input_08 * G_00) + (w_8_input_09 * G_01));

            sumL_5 <= sumL_5 + ((w_8_input_10 * H_00) + (w_8_input_11 * H_01));
            sumH_5 <= sumH_5 + ((w_8_input_10 * G_00) + (w_8_input_11 * G_01));

            sumL_6 <= sumL_6 + ((w_8_input_12 * H_00) + (w_8_input_13 * H_01));
            sumH_6 <= sumH_6 + ((w_8_input_12 * G_00) + (w_8_input_13 * G_01));

            sumL_7 <= sumL_7 + ((w_8_input_14 * H_00) + (w_8_input_15 * H_01));
            sumH_7 <= sumH_7 + ((w_8_input_14 * G_00) + (w_8_input_15 * G_01));

            state <= 4'd1;
        end

        else if(state == 4'd1) begin

            sumL_0 <= sumL_0 + ((w_8_input_02 * H_02) + (w_8_input_03 * H_03));
            sumH_0 <= sumH_0 + ((w_8_input_02 * G_02) + (w_8_input_03 * G_03));

            sumL_1 <= sumL_1 + ((w_8_input_04 * H_02) + (w_8_input_05 * H_03));
            sumH_1 <= sumH_1 + ((w_8_input_04 * G_02) + (w_8_input_05 * G_03));

            sumL_2 <= sumL_2 + ((w_8_input_06 * H_02) + (w_8_input_07 * H_03));
            sumH_2 <= sumH_2 + ((w_8_input_06 * G_02) + (w_8_input_07 * G_03));

            sumL_3 <= sumL_3 + ((w_8_input_08 * H_02) + (w_8_input_09 * H_03));
            sumH_3 <= sumH_3 + ((w_8_input_08 * G_02) + (w_8_input_09 * G_03));

            sumL_4 <= sumL_4 + ((w_8_input_10 * H_02) + (w_8_input_11 * H_03));
            sumH_4 <= sumH_4 + ((w_8_input_10 * G_02) + (w_8_input_11 * G_03));

            sumL_5 <= sumL_5 + ((w_8_input_12 * H_02) + (w_8_input_13 * H_03));
            sumH_5 <= sumH_5 + ((w_8_input_12 * G_02) + (w_8_input_13 * G_03));

            sumL_6 <= sumL_6 + ((w_8_input_14 * H_02) + (w_8_input_15 * H_03));
            sumH_6 <= sumH_6 + ((w_8_input_14 * G_02) + (w_8_input_15 * G_03));

            sumL_7 <= sumL_7 + ((w_8_input_00 * H_02) + (w_8_input_01 * H_03));
            sumH_7 <= sumH_7 + ((w_8_input_00 * G_02) + (w_8_input_01 * G_03));

            state <= 4'd2;
        end

        else if(state == 4'd2) begin

            sumL_0 <= sumL_0 + ((w_8_input_04 * H_04) + (w_8_input_05 * H_05));
            sumH_0 <= sumH_0 + ((w_8_input_04 * G_04) + (w_8_input_05 * G_05));

            sumL_1 <= sumL_1 + ((w_8_input_06 * H_04) + (w_8_input_07 * H_05));
            sumH_1 <= sumH_1 + ((w_8_input_06 * G_04) + (w_8_input_07 * G_05));

            sumL_2 <= sumL_2 + ((w_8_input_08 * H_04) + (w_8_input_09 * H_05));
            sumH_2 <= sumH_2 + ((w_8_input_08 * G_04) + (w_8_input_09 * G_05));

            sumL_3 <= sumL_3 + ((w_8_input_10 * H_04) + (w_8_input_11 * H_05));
            sumH_3 <= sumH_3 + ((w_8_input_10 * G_04) + (w_8_input_11 * G_05));

            sumL_4 <= sumL_4 + ((w_8_input_12 * H_04) + (w_8_input_13 * H_05));
            sumH_4 <= sumH_4 + ((w_8_input_12 * G_04) + (w_8_input_13 * G_05));

            sumL_5 <= sumL_5 + ((w_8_input_14 * H_04) + (w_8_input_15 * H_05));
            sumH_5 <= sumH_5 + ((w_8_input_14 * G_04) + (w_8_input_15 * G_05));

            sumL_6 <= sumL_6 + ((w_8_input_00 * H_04) + (w_8_input_01 * H_05));
            sumH_6 <= sumH_6 + ((w_8_input_00 * G_04) + (w_8_input_01 * G_05));

            sumL_7 <= sumL_7 + ((w_8_input_02 * H_04) + (w_8_input_03 * H_05));
            sumH_7 <= sumH_7 + ((w_8_input_02 * G_04) + (w_8_input_03 * G_05));

            state <= 4'd3;
        end

        else if(state == 4'd3) begin

            sumL_0 <= sumL_0 + ((w_8_input_06 * H_06) + (w_8_input_07 * H_07));
            sumH_0 <= sumH_0 + ((w_8_input_06 * G_06) + (w_8_input_07 * G_07));

            sumL_1 <= sumL_1 + ((w_8_input_08 * H_06) + (w_8_input_09 * H_07));
            sumH_1 <= sumH_1 + ((w_8_input_08 * G_06) + (w_8_input_09 * G_07));

            sumL_2 <= sumL_2 + ((w_8_input_10 * H_06) + (w_8_input_11 * H_07));
            sumH_2 <= sumH_2 + ((w_8_input_10 * G_06) + (w_8_input_11 * G_07));

            sumL_3 <= sumL_3 + ((w_8_input_12 * H_06) + (w_8_input_13 * H_07));
            sumH_3 <= sumH_3 + ((w_8_input_12 * G_06) + (w_8_input_13 * G_07));

            sumL_4 <= sumL_4 + ((w_8_input_14 * H_06) + (w_8_input_15 * H_07));
            sumH_4 <= sumH_4 + ((w_8_input_14 * G_06) + (w_8_input_15 * G_07));

            sumL_5 <= sumL_5 + ((w_8_input_00 * H_06) + (w_8_input_01 * H_07));
            sumH_5 <= sumH_5 + ((w_8_input_00 * G_06) + (w_8_input_01 * G_07));

            sumL_6 <= sumL_6 + ((w_8_input_02 * H_06) + (w_8_input_03 * H_07));
            sumH_6 <= sumH_6 + ((w_8_input_02 * G_06) + (w_8_input_03 * G_07));

            sumL_7 <= sumL_7 + ((w_8_input_04 * H_06) + (w_8_input_05 * H_07));
            sumH_7 <= sumH_7 + ((w_8_input_04 * G_06) + (w_8_input_05 * G_07));

            state <= 4'd4;
        end

        else if(state == 4'd4) begin

            sumL_0 <= sumL_0 + ((w_8_input_08 * H_08) + (w_8_input_09 * H_09));
            sumH_0 <= sumH_0 + ((w_8_input_08 * G_08) + (w_8_input_09 * G_09));

            sumL_1 <= sumL_1 + ((w_8_input_10 * H_08) + (w_8_input_11 * H_09));
            sumH_1 <= sumH_1 + ((w_8_input_10 * G_08) + (w_8_input_11 * G_09));

            sumL_2 <= sumL_2 + ((w_8_input_12 * H_08) + (w_8_input_13 * H_09));
            sumH_2 <= sumH_2 + ((w_8_input_12 * G_08) + (w_8_input_13 * G_09));

            sumL_3 <= sumL_3 + ((w_8_input_14 * H_08) + (w_8_input_15 * H_09));
            sumH_3 <= sumH_3 + ((w_8_input_14 * G_08) + (w_8_input_15 * G_09));

            sumL_4 <= sumL_4 + ((w_8_input_00 * H_08) + (w_8_input_01 * H_09));
            sumH_4 <= sumH_4 + ((w_8_input_00 * G_08) + (w_8_input_01 * G_09));

            sumL_5 <= sumL_5 + ((w_8_input_02 * H_08) + (w_8_input_03 * H_09));
            sumH_5 <= sumH_5 + ((w_8_input_02 * G_08) + (w_8_input_03 * G_09));

            sumL_6 <= sumL_6 + ((w_8_input_04 * H_08) + (w_8_input_05 * H_09));
            sumH_6 <= sumH_6 + ((w_8_input_04 * G_08) + (w_8_input_05 * G_09));

            sumL_7 <= sumL_7 + ((w_8_input_06 * H_08) + (w_8_input_07 * H_09));
            sumH_7 <= sumH_7 + ((w_8_input_06 * G_08) + (w_8_input_07 * G_09));

            state <= 4'd5;
        end

        else if(state == 4'd5) begin

            sumL_0 <= sumL_0 + ((w_8_input_10 * H_10) + (w_8_input_11 * H_11));
            sumH_0 <= sumH_0 + ((w_8_input_10 * G_10) + (w_8_input_11 * G_11));

            sumL_1 <= sumL_1 + ((w_8_input_12 * H_10) + (w_8_input_13 * H_11));
            sumH_1 <= sumH_1 + ((w_8_input_12 * G_10) + (w_8_input_13 * G_11));

            sumL_2 <= sumL_2 + ((w_8_input_14 * H_10) + (w_8_input_15 * H_11));
            sumH_2 <= sumH_2 + ((w_8_input_14 * G_10) + (w_8_input_15 * G_11));

            sumL_3 <= sumL_3 + ((w_8_input_00 * H_10) + (w_8_input_01 * H_11));
            sumH_3 <= sumH_3 + ((w_8_input_00 * G_10) + (w_8_input_01 * G_11));

            sumL_4 <= sumL_4 + ((w_8_input_02 * H_10) + (w_8_input_03 * H_11));
            sumH_4 <= sumH_4 + ((w_8_input_02 * G_10) + (w_8_input_03 * G_11));

            sumL_5 <= sumL_5 + ((w_8_input_04 * H_10) + (w_8_input_05 * H_11));
            sumH_5 <= sumH_5 + ((w_8_input_04 * G_10) + (w_8_input_05 * G_11));

            sumL_6 <= sumL_6 + ((w_8_input_06 * H_10) + (w_8_input_07 * H_11));
            sumH_6 <= sumH_6 + ((w_8_input_06 * G_10) + (w_8_input_07 * G_11));

            sumL_7 <= sumL_7 + ((w_8_input_08 * H_10) + (w_8_input_09 * H_11));
            sumH_7 <= sumH_7 + ((w_8_input_08 * G_10) + (w_8_input_09 * G_11));

            state <= 4'd6;
        end

        else if(state == 4'd6) begin

            sumL_0 <= sumL_0 + ((w_8_input_12 * H_12) + (w_8_input_13 * H_13));
            sumH_0 <= sumH_0 + ((w_8_input_12 * G_12) + (w_8_input_13 * G_13));

            sumL_1 <= sumL_1 + ((w_8_input_14 * H_12) + (w_8_input_15 * H_13));
            sumH_1 <= sumH_1 + ((w_8_input_14 * G_12) + (w_8_input_15 * G_13));

            sumL_2 <= sumL_2 + ((w_8_input_00 * H_12) + (w_8_input_01 * H_13));
            sumH_2 <= sumH_2 + ((w_8_input_00 * G_12) + (w_8_input_01 * G_13));

            sumL_3 <= sumL_3 + ((w_8_input_02 * H_12) + (w_8_input_03 * H_13));
            sumH_3 <= sumH_3 + ((w_8_input_02 * G_12) + (w_8_input_03 * G_13));

            sumL_4 <= sumL_4 + ((w_8_input_04 * H_12) + (w_8_input_05 * H_13));
            sumH_4 <= sumH_4 + ((w_8_input_04 * G_12) + (w_8_input_05 * G_13));

            sumL_5 <= sumL_5 + ((w_8_input_06 * H_12) + (w_8_input_07 * H_13));
            sumH_5 <= sumH_5 + ((w_8_input_06 * G_12) + (w_8_input_07 * G_13));

            sumL_6 <= sumL_6 + ((w_8_input_08 * H_12) + (w_8_input_09 * H_13));
            sumH_6 <= sumH_6 + ((w_8_input_08 * G_12) + (w_8_input_09 * G_13));

            sumL_7 <= sumL_7 + ((w_8_input_10 * H_12) + (w_8_input_11 * H_13));
            sumH_7 <= sumH_7 + ((w_8_input_10 * G_12) + (w_8_input_11 * G_13));

            state <= 4'd7;
        end

        else if(state == 4'd7) begin
            sumL_0 <= sumL_0 + ((w_8_input_14 * H_14) + (w_8_input_15 * H_15));
            sumH_0 <= sumH_0 + ((w_8_input_14 * G_14) + (w_8_input_15 * G_15));

            sumL_1 <= sumL_1 + ((w_8_input_00 * H_14) + (w_8_input_01 * H_15));
            sumH_1 <= sumH_1 + ((w_8_input_00 * G_14) + (w_8_input_01 * G_15));

            sumL_2 <= sumL_2 + ((w_8_input_02 * H_14) + (w_8_input_03 * H_15));
            sumH_2 <= sumH_2 + ((w_8_input_02 * G_14) + (w_8_input_03 * G_15));

            sumL_3 <= sumL_3 + ((w_8_input_04 * H_14) + (w_8_input_05 * H_15));
            sumH_3 <= sumH_3 + ((w_8_input_04 * G_14) + (w_8_input_05 * G_15));

            sumL_4 <= sumL_4 + ((w_8_input_06 * H_14) + (w_8_input_07 * H_15));
            sumH_4 <= sumH_4 + ((w_8_input_06 * G_14) + (w_8_input_07 * G_15));

            sumL_5 <= sumL_5 + ((w_8_input_08 * H_14) + (w_8_input_09 * H_15));
            sumH_5 <= sumH_5 + ((w_8_input_08 * G_14) + (w_8_input_09 * G_15));

            sumL_6 <= sumL_6 + ((w_8_input_10 * H_14) + (w_8_input_11 * H_15));
            sumH_6 <= sumH_6 + ((w_8_input_10 * G_14) + (w_8_input_11 * G_15));

            sumL_7 <= sumL_7 + ((w_8_input_12 * H_14) + (w_8_input_13 * H_15));
            sumH_7 <= sumH_7 + ((w_8_input_12 * G_14) + (w_8_input_13 * G_15));

            output_ready <= 1'b1;

            state <= 4'd8;
        end

        else if(state == 4'd8) begin
            state  <=  4'd0;

            fdwt_busy <= 1'b0;

            sumL_0 <= 32'd0;
            sumL_1 <= 32'd0;
            sumL_2 <= 32'd0;
            sumL_3 <= 32'd0;
            sumL_4 <= 32'd0;
            sumL_5 <= 32'd0;
            sumL_6 <= 32'd0;
            sumL_7 <= 32'd0;

            sumH_0 <= 32'd0;
            sumH_1 <= 32'd0;
            sumH_2 <= 32'd0;
            sumH_3 <= 32'd0;
            sumH_4 <= 32'd0;
            sumH_5 <= 32'd0;
            sumH_6 <= 32'd0;
            sumH_7 <= 32'd0;
        end
    end

    
    //outputs wiring
    assign output_values_low_03 = {
        sumL_0[30:15],
        sumL_1[30:15],
        sumL_2[30:15],
        sumL_3[30:15]
    };
    assign output_values_low_47 = {
        sumL_4[30:15],
        sumL_5[30:15],
        sumL_6[30:15],
        sumL_7[30:15]
    };

    assign output_values_high_03 = {
        sumH_0[30:15],
        sumH_1[30:15],
        sumH_2[30:15],
        sumH_3[30:15]
    };
    assign output_values_high_47 = {
        sumH_4[30:15],
        sumH_5[30:15],
        sumH_6[30:15],
        sumH_7[30:15]
    };

endmodule
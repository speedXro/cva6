`timescale 1 ns / 1 ps 

module idwt_db8(
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
    localparam logic signed [15:0] HR_00 =     -4;
    localparam logic signed [15:0] HR_01 =     22;
    localparam logic signed [15:0] HR_02 =    -13;
    localparam logic signed [15:0] HR_03 =   -160;
    localparam logic signed [15:0] HR_04 =    287;
    localparam logic signed [15:0] HR_05 =    458;
    localparam logic signed [15:0] HR_06 =  -1443;
    localparam logic signed [15:0] HR_07 =   -569;
    localparam logic signed [15:0] HR_08 =   4216;
    localparam logic signed [15:0] HR_09 =     15;
    localparam logic signed [15:0] HR_10 =  -9305;
    localparam logic signed [15:0] HR_11 =   -518;
    localparam logic signed [15:0] HR_12 =  19166;
    localparam logic signed [15:0] HR_13 =  22193;
    localparam logic signed [15:0] HR_14 =  10239;
    localparam logic signed [15:0] HR_15 =   1784;

    localparam logic signed [15:0] GR_00 =  -1784;
    localparam logic signed [15:0] GR_01 =  10239;
    localparam logic signed [15:0] GR_02 = -22193;
    localparam logic signed [15:0] GR_03 =  19166;
    localparam logic signed [15:0] GR_04 =    518;
    localparam logic signed [15:0] GR_05 =  -9305;
    localparam logic signed [15:0] GR_06 =    -15;
    localparam logic signed [15:0] GR_07 =   4216;
    localparam logic signed [15:0] GR_08 =   -569;
    localparam logic signed [15:0] GR_09 =   1443;
    localparam logic signed [15:0] GR_10 =   -458;
    localparam logic signed [15:0] GR_11 =    287;
    localparam logic signed [15:0] GR_12 =   -160;
    localparam logic signed [15:0] GR_13 =     13;
    localparam logic signed [15:0] GR_14 =    -22;
    localparam logic signed [15:0] GR_15 =     -4;

    function automatic logic signed [7:0] clamp_i8_in_25b (input logic signed [24:0] in);
        logic signed [24:0] aux;
        begin
            if(in > 127) begin aux = 25'd127; end
            else if(in < -128) begin aux = -128; end
            else aux = in;

            clamp_i8_in_25b = aux[7:0];
        end
    endfunction

    logic [3:0] state;

    logic signed [39:0] acc_00;
    logic signed [39:0] acc_01;
    logic signed [39:0] acc_02;
    logic signed [39:0] acc_03;
    logic signed [39:0] acc_04;
    logic signed [39:0] acc_05;
    logic signed [39:0] acc_06;
    logic signed [39:0] acc_07;
    logic signed [39:0] acc_08;
    logic signed [39:0] acc_09;
    logic signed [39:0] acc_10;
    logic signed [39:0] acc_11;
    logic signed [39:0] acc_12;
    logic signed [39:0] acc_13;
    logic signed [39:0] acc_14;
    logic signed [39:0] acc_15;

    logic signed [15:0] w_16_low_00;
    logic signed [15:0] w_16_low_01;
    logic signed [15:0] w_16_low_02;
    logic signed [15:0] w_16_low_03;
    logic signed [15:0] w_16_low_04;
    logic signed [15:0] w_16_low_05;
    logic signed [15:0] w_16_low_06;
    logic signed [15:0] w_16_low_07;

    logic signed [15:0] w_16_high_00;
    logic signed [15:0] w_16_high_01;
    logic signed [15:0] w_16_high_02;
    logic signed [15:0] w_16_high_03;
    logic signed [15:0] w_16_high_04;
    logic signed [15:0] w_16_high_05;
    logic signed [15:0] w_16_high_06;
    logic signed [15:0] w_16_high_07;

    assign {
        w_16_low_00, w_16_low_01, w_16_low_02, w_16_low_03,
        w_16_low_04, w_16_low_05, w_16_low_06, w_16_low_07
    } = { input_values_low_03, input_values_low_47 };

    assign {
        w_16_high_00, w_16_high_01, w_16_high_02, w_16_high_03,
        w_16_high_04, w_16_high_05, w_16_high_06, w_16_high_07
    } = { input_values_high_03, input_values_high_47 };

    //dummy FSM

    always_ff @(posedge clk) begin
        if(reset == 1'b1) begin
            state        <=  4'd0;
            idwt_busy    <=  1'd0;
            output_ready <=  1'd0;
            acc_00       <= 40'd0;
            acc_01       <= 40'd0;
            acc_02       <= 40'd0;
            acc_03       <= 40'd0;
            acc_04       <= 40'd0;
            acc_05       <= 40'd0;
            acc_06       <= 40'd0;
            acc_07       <= 40'd0;
            acc_08       <= 40'd0;
            acc_09       <= 40'd0;
            acc_10       <= 40'd0;
            acc_11       <= 40'd0;
            acc_12       <= 40'd0;
            acc_13       <= 40'd0;
            acc_14       <= 40'd0;
            acc_15       <= 40'd0;
        end
        else if(state == 4'd0 && input_valid == 1'b1) begin
            idwt_busy <= 1'b1;
            state     <= 4'd1;

            acc_00    <= acc_00 + (w_16_low_00*HR_00) + (w_16_high_00*GR_00);
            acc_01    <= acc_01 + (w_16_low_00*HR_01) + (w_16_high_00*GR_01);
            acc_02    <= acc_02 + (w_16_low_01*HR_00) + (w_16_high_01*GR_00);
            acc_03    <= acc_03 + (w_16_low_01*HR_01) + (w_16_high_01*GR_01);
            acc_04    <= acc_04 + (w_16_low_02*HR_00) + (w_16_high_02*GR_00);
            acc_05    <= acc_05 + (w_16_low_02*HR_01) + (w_16_high_02*GR_01);
            acc_06    <= acc_06 + (w_16_low_03*HR_00) + (w_16_high_03*GR_00);
            acc_07    <= acc_07 + (w_16_low_03*HR_01) + (w_16_high_03*GR_01);
            acc_08    <= acc_08 + (w_16_low_04*HR_00) + (w_16_high_04*GR_00);
            acc_09    <= acc_09 + (w_16_low_04*HR_01) + (w_16_high_04*GR_01);
            acc_10    <= acc_10 + (w_16_low_05*HR_00) + (w_16_high_05*GR_00);
            acc_11    <= acc_11 + (w_16_low_05*HR_01) + (w_16_high_05*GR_01);
            acc_12    <= acc_12 + (w_16_low_06*HR_00) + (w_16_high_06*GR_00);
            acc_13    <= acc_13 + (w_16_low_06*HR_01) + (w_16_high_06*GR_01);
            acc_14    <= acc_14 + (w_16_low_07*HR_00) + (w_16_high_07*GR_00);
            acc_15    <= acc_15 + (w_16_low_07*HR_01) + (w_16_high_07*GR_01);
        end
        else if(state == 4'd1) begin
            state     <= 4'd2;

            acc_00    <= acc_00 + (w_16_low_07*HR_02) + (w_16_high_07*GR_02);
            acc_01    <= acc_01 + (w_16_low_07*HR_03) + (w_16_high_07*GR_03);
            acc_02    <= acc_02 + (w_16_low_00*HR_02) + (w_16_high_00*GR_02);
            acc_03    <= acc_03 + (w_16_low_00*HR_03) + (w_16_high_00*GR_03);
            acc_04    <= acc_04 + (w_16_low_01*HR_02) + (w_16_high_01*GR_02);
            acc_05    <= acc_05 + (w_16_low_01*HR_03) + (w_16_high_01*GR_03);
            acc_06    <= acc_06 + (w_16_low_02*HR_02) + (w_16_high_02*GR_02);
            acc_07    <= acc_07 + (w_16_low_02*HR_03) + (w_16_high_02*GR_03);
            acc_08    <= acc_08 + (w_16_low_03*HR_02) + (w_16_high_03*GR_02);
            acc_09    <= acc_09 + (w_16_low_03*HR_03) + (w_16_high_03*GR_03);
            acc_10    <= acc_10 + (w_16_low_04*HR_02) + (w_16_high_04*GR_02);
            acc_11    <= acc_11 + (w_16_low_04*HR_03) + (w_16_high_04*GR_03);
            acc_12    <= acc_12 + (w_16_low_05*HR_02) + (w_16_high_05*GR_02);
            acc_13    <= acc_13 + (w_16_low_05*HR_03) + (w_16_high_05*GR_03);
            acc_14    <= acc_14 + (w_16_low_06*HR_02) + (w_16_high_06*GR_02);
            acc_15    <= acc_15 + (w_16_low_06*HR_03) + (w_16_high_06*GR_03);
        end
        else if(state == 4'd2) begin
            state     <= 4'd3;

            acc_00    <= acc_00 + (w_16_low_06*HR_04) + (w_16_high_06*GR_04);
            acc_01    <= acc_01 + (w_16_low_06*HR_05) + (w_16_high_06*GR_05);
            acc_02    <= acc_02 + (w_16_low_07*HR_04) + (w_16_high_07*GR_04);
            acc_03    <= acc_03 + (w_16_low_07*HR_05) + (w_16_high_07*GR_05);
            acc_04    <= acc_04 + (w_16_low_00*HR_04) + (w_16_high_00*GR_04);
            acc_05    <= acc_05 + (w_16_low_00*HR_05) + (w_16_high_00*GR_05);
            acc_06    <= acc_06 + (w_16_low_01*HR_04) + (w_16_high_01*GR_04);
            acc_07    <= acc_07 + (w_16_low_01*HR_05) + (w_16_high_01*GR_05);
            acc_08    <= acc_08 + (w_16_low_02*HR_04) + (w_16_high_02*GR_04);
            acc_09    <= acc_09 + (w_16_low_02*HR_05) + (w_16_high_02*GR_05);
            acc_10    <= acc_10 + (w_16_low_03*HR_04) + (w_16_high_03*GR_04);
            acc_11    <= acc_11 + (w_16_low_03*HR_05) + (w_16_high_03*GR_05);
            acc_12    <= acc_12 + (w_16_low_04*HR_04) + (w_16_high_04*GR_04);
            acc_13    <= acc_13 + (w_16_low_04*HR_05) + (w_16_high_04*GR_05);
            acc_14    <= acc_14 + (w_16_low_05*HR_04) + (w_16_high_05*GR_04);
            acc_15    <= acc_15 + (w_16_low_05*HR_05) + (w_16_high_05*GR_05);
        end
        else if(state == 4'd3) begin
            state     <= 4'd4;

            acc_00    <= acc_00 + (w_16_low_05*HR_06) + (w_16_high_05*GR_06);
            acc_01    <= acc_01 + (w_16_low_05*HR_07) + (w_16_high_05*GR_07);
            acc_02    <= acc_02 + (w_16_low_06*HR_06) + (w_16_high_06*GR_06);
            acc_03    <= acc_03 + (w_16_low_06*HR_07) + (w_16_high_06*GR_07);
            acc_04    <= acc_04 + (w_16_low_07*HR_06) + (w_16_high_07*GR_06);
            acc_05    <= acc_05 + (w_16_low_07*HR_07) + (w_16_high_07*GR_07);
            acc_06    <= acc_06 + (w_16_low_00*HR_06) + (w_16_high_00*GR_06);
            acc_07    <= acc_07 + (w_16_low_00*HR_07) + (w_16_high_00*GR_07);
            acc_08    <= acc_08 + (w_16_low_01*HR_06) + (w_16_high_01*GR_06);
            acc_09    <= acc_09 + (w_16_low_01*HR_07) + (w_16_high_01*GR_07);
            acc_10    <= acc_10 + (w_16_low_02*HR_06) + (w_16_high_02*GR_06);
            acc_11    <= acc_11 + (w_16_low_02*HR_07) + (w_16_high_02*GR_07);
            acc_12    <= acc_12 + (w_16_low_03*HR_06) + (w_16_high_03*GR_06);
            acc_13    <= acc_13 + (w_16_low_03*HR_07) + (w_16_high_03*GR_07);
            acc_14    <= acc_14 + (w_16_low_04*HR_06) + (w_16_high_04*GR_06);
            acc_15    <= acc_15 + (w_16_low_04*HR_07) + (w_16_high_04*GR_07);
        end

        else if(state == 4'd4) begin
            state     <= 4'd5;

            acc_00    <= acc_00 + (w_16_low_04*HR_08) + (w_16_high_04*GR_08);
            acc_01    <= acc_01 + (w_16_low_04*HR_09) + (w_16_high_04*GR_09);
            acc_02    <= acc_02 + (w_16_low_05*HR_08) + (w_16_high_05*GR_08);
            acc_03    <= acc_03 + (w_16_low_05*HR_09) + (w_16_high_05*GR_09);
            acc_04    <= acc_04 + (w_16_low_06*HR_08) + (w_16_high_06*GR_08);
            acc_05    <= acc_05 + (w_16_low_06*HR_09) + (w_16_high_06*GR_09);
            acc_06    <= acc_06 + (w_16_low_07*HR_08) + (w_16_high_07*GR_08);
            acc_07    <= acc_07 + (w_16_low_07*HR_09) + (w_16_high_07*GR_09);
            acc_08    <= acc_08 + (w_16_low_00*HR_08) + (w_16_high_00*GR_08);
            acc_09    <= acc_09 + (w_16_low_00*HR_09) + (w_16_high_00*GR_09);
            acc_10    <= acc_10 + (w_16_low_01*HR_08) + (w_16_high_01*GR_08);
            acc_11    <= acc_11 + (w_16_low_01*HR_09) + (w_16_high_01*GR_09);
            acc_12    <= acc_12 + (w_16_low_02*HR_08) + (w_16_high_02*GR_08);
            acc_13    <= acc_13 + (w_16_low_02*HR_09) + (w_16_high_02*GR_09);
            acc_14    <= acc_14 + (w_16_low_03*HR_08) + (w_16_high_03*GR_08);
            acc_15    <= acc_15 + (w_16_low_03*HR_09) + (w_16_high_03*GR_09);
        end

        else if(state == 4'd5) begin
            state     <= 4'd6;

            acc_00    <= acc_00 + (w_16_low_03*HR_10) + (w_16_high_03*GR_10);
            acc_01    <= acc_01 + (w_16_low_03*HR_11) + (w_16_high_03*GR_11);
            acc_02    <= acc_02 + (w_16_low_04*HR_10) + (w_16_high_04*GR_10);
            acc_03    <= acc_03 + (w_16_low_04*HR_11) + (w_16_high_04*GR_11);
            acc_04    <= acc_04 + (w_16_low_05*HR_10) + (w_16_high_05*GR_10);
            acc_05    <= acc_05 + (w_16_low_05*HR_11) + (w_16_high_05*GR_11);
            acc_06    <= acc_06 + (w_16_low_06*HR_10) + (w_16_high_06*GR_10);
            acc_07    <= acc_07 + (w_16_low_06*HR_11) + (w_16_high_06*GR_11);
            acc_08    <= acc_08 + (w_16_low_07*HR_10) + (w_16_high_07*GR_10);
            acc_09    <= acc_09 + (w_16_low_07*HR_11) + (w_16_high_07*GR_11);
            acc_10    <= acc_10 + (w_16_low_00*HR_10) + (w_16_high_00*GR_10);
            acc_11    <= acc_11 + (w_16_low_00*HR_11) + (w_16_high_00*GR_11);
            acc_12    <= acc_12 + (w_16_low_01*HR_10) + (w_16_high_01*GR_10);
            acc_13    <= acc_13 + (w_16_low_01*HR_11) + (w_16_high_01*GR_11);
            acc_14    <= acc_14 + (w_16_low_02*HR_10) + (w_16_high_02*GR_10);
            acc_15    <= acc_15 + (w_16_low_02*HR_11) + (w_16_high_02*GR_11);
        end

        else if(state == 4'd6) begin
            state     <= 4'd7;

            acc_00    <= acc_00 + (w_16_low_02*HR_12) + (w_16_high_02*GR_12);
            acc_01    <= acc_01 + (w_16_low_02*HR_13) + (w_16_high_02*GR_13);
            acc_02    <= acc_02 + (w_16_low_03*HR_12) + (w_16_high_03*GR_12);
            acc_03    <= acc_03 + (w_16_low_03*HR_13) + (w_16_high_03*GR_13);
            acc_04    <= acc_04 + (w_16_low_04*HR_12) + (w_16_high_04*GR_12);
            acc_05    <= acc_05 + (w_16_low_04*HR_13) + (w_16_high_04*GR_13);
            acc_06    <= acc_06 + (w_16_low_05*HR_12) + (w_16_high_05*GR_12);
            acc_07    <= acc_07 + (w_16_low_05*HR_13) + (w_16_high_05*GR_13);
            acc_08    <= acc_08 + (w_16_low_06*HR_12) + (w_16_high_06*GR_12);
            acc_09    <= acc_09 + (w_16_low_06*HR_13) + (w_16_high_06*GR_13);
            acc_10    <= acc_10 + (w_16_low_07*HR_12) + (w_16_high_07*GR_12);
            acc_11    <= acc_11 + (w_16_low_07*HR_13) + (w_16_high_07*GR_13);
            acc_12    <= acc_12 + (w_16_low_00*HR_12) + (w_16_high_00*GR_12);
            acc_13    <= acc_13 + (w_16_low_00*HR_13) + (w_16_high_00*GR_13);
            acc_14    <= acc_14 + (w_16_low_01*HR_12) + (w_16_high_01*GR_12);
            acc_15    <= acc_15 + (w_16_low_01*HR_13) + (w_16_high_01*GR_13);
        end

        else if(state == 4'd7) begin
            state        <= 4'd8;
            

            acc_00    <= acc_00 + (w_16_low_01*HR_14) + (w_16_high_01*GR_14);
            acc_01    <= acc_01 + (w_16_low_01*HR_15) + (w_16_high_01*GR_15);
            acc_02    <= acc_02 + (w_16_low_02*HR_14) + (w_16_high_02*GR_14);
            acc_03    <= acc_03 + (w_16_low_02*HR_15) + (w_16_high_02*GR_15);
            acc_04    <= acc_04 + (w_16_low_03*HR_14) + (w_16_high_03*GR_14);
            acc_05    <= acc_05 + (w_16_low_03*HR_15) + (w_16_high_03*GR_15);
            acc_06    <= acc_06 + (w_16_low_04*HR_14) + (w_16_high_04*GR_14);
            acc_07    <= acc_07 + (w_16_low_04*HR_15) + (w_16_high_04*GR_15);
            acc_08    <= acc_08 + (w_16_low_05*HR_14) + (w_16_high_05*GR_14);
            acc_09    <= acc_09 + (w_16_low_05*HR_15) + (w_16_high_05*GR_15);
            acc_10    <= acc_10 + (w_16_low_06*HR_14) + (w_16_high_06*GR_14);
            acc_11    <= acc_11 + (w_16_low_06*HR_15) + (w_16_high_06*GR_15);
            acc_12    <= acc_12 + (w_16_low_07*HR_14) + (w_16_high_07*GR_14);
            acc_13    <= acc_13 + (w_16_low_07*HR_15) + (w_16_high_07*GR_15);
            acc_14    <= acc_14 + (w_16_low_00*HR_14) + (w_16_high_00*GR_14);
            acc_15    <= acc_15 + (w_16_low_00*HR_15) + (w_16_high_00*GR_15);
        end

        else if(state == 4'd8) begin
            $display("Accumulators : %7h, %7h, %7h, %7h, %7h, %7h, %7h, %7h, %7h, %7h, %7h, %7h, %7h, %7h, %7h, %7h",
                acc_00[39:15], acc_01[39:15], acc_02[39:15], acc_03[39:15], acc_04[39:15], acc_05[39:15], acc_06[39:15], acc_07[39:15],
                acc_08[39:15], acc_09[39:15], acc_10[39:15], acc_11[39:15], acc_12[39:15], acc_13[39:15], acc_14[39:15], acc_15[39:15] 
            );
            output_ready <= 1'b1;
            state <= 4'd9;
            acc_00 <= {32'd0, clamp_i8_in_25b(acc_00[39:15])};
            acc_01 <= {32'd0, clamp_i8_in_25b(acc_01[39:15])};
            acc_02 <= {32'd0, clamp_i8_in_25b(acc_02[39:15])};
            acc_03 <= {32'd0, clamp_i8_in_25b(acc_03[39:15])};
            acc_04 <= {32'd0, clamp_i8_in_25b(acc_04[39:15])};
            acc_05 <= {32'd0, clamp_i8_in_25b(acc_05[39:15])};
            acc_06 <= {32'd0, clamp_i8_in_25b(acc_06[39:15])};
            acc_07 <= {32'd0, clamp_i8_in_25b(acc_07[39:15])};
            acc_08 <= {32'd0, clamp_i8_in_25b(acc_08[39:15])};
            acc_09 <= {32'd0, clamp_i8_in_25b(acc_09[39:15])};
            acc_10 <= {32'd0, clamp_i8_in_25b(acc_10[39:15])};
            acc_11 <= {32'd0, clamp_i8_in_25b(acc_11[39:15])};
            acc_12 <= {32'd0, clamp_i8_in_25b(acc_12[39:15])};
            acc_13 <= {32'd0, clamp_i8_in_25b(acc_13[39:15])};
            acc_14 <= {32'd0, clamp_i8_in_25b(acc_14[39:15])};
            acc_15 <= {32'd0, clamp_i8_in_25b(acc_15[39:15])};
        end

        else if(state == 4'd9) begin
            $display("Accumulators : %7h, %7h, %7h, %7h, %7h, %7h, %7h, %7h, %7h, %7h, %7h, %7h, %7h, %7h, %7h, %7h",
                acc_00[7:0], acc_01[7:0], acc_02[7:0], acc_03[7:0], acc_04[7:0], acc_05[7:0], acc_06[7:0], acc_07[7:0],
                acc_08[7:0], acc_09[7:0], acc_10[7:0], acc_11[7:0], acc_12[7:0], acc_13[7:0], acc_14[7:0], acc_15[7:0] 
            );
            state        <=  4'd0;
            idwt_busy    <=  1'd0;
            output_ready <=  1'd0;
            acc_00       <= 40'd0;
            acc_01       <= 40'd0;
            acc_02       <= 40'd0;
            acc_03       <= 40'd0;
            acc_04       <= 40'd0;
            acc_05       <= 40'd0;
            acc_06       <= 40'd0;
            acc_07       <= 40'd0;
            acc_08       <= 40'd0;
            acc_09       <= 40'd0;
            acc_10       <= 40'd0;
            acc_11       <= 40'd0;
            acc_12       <= 40'd0;
            acc_13       <= 40'd0;
            acc_14       <= 40'd0;
            acc_15       <= 40'd0;
        end
    end

    assign output_values_1 = {
        acc_00[7:0], acc_01[7:0], acc_02[7:0], acc_03[7:0],
        acc_04[7:0], acc_05[7:0], acc_06[7:0], acc_07[7:0]
    };

    assign output_values_2 = {
        acc_08[7:0], acc_09[7:0], acc_10[7:0], acc_11[7:0],
        acc_12[7:0], acc_13[7:0], acc_14[7:0], acc_15[7:0]
    };

endmodule
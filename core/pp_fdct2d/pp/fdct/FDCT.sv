`timescale 1ns / 1ps

//https://siko1056.github.io/blog/2021/12/23/octave-matlab-directed-rounding.html
//octave:1> mex --std=c11 setround.c 
//octave:2> setround(+1);
//octave:3> setround(+1);

module FDCT #(
    parameter int unsigned INPUT_WIDTH      = 8,        // i
    parameter int unsigned INPUT_UNSIGNED   = 1,
    parameter int unsigned FRACTIONAL_WIDTH = 13,  // f
    parameter int unsigned ROUND            = 1,
    parameter int unsigned OUTPUT_WIDTH     = 11,       // o
    parameter int unsigned DEBUG            =  1 //0 - no debug, 1 - display instance params, 2 - change events
) (
    input  logic        [INPUT_WIDTH-1:0]   ins  [0:7],
    output logic signed [OUTPUT_WIDTH-1:0]  outs [0:7]
);  
    localparam OUTPUT_INTEGER_WIDTH     = (INPUT_WIDTH + 3);
    localparam OUTPUT_FRACTIONAL_WIDTH  = (OUTPUT_WIDTH - OUTPUT_INTEGER_WIDTH);
    localparam CONST_INTEGER_WIDTH      = 3;
    localparam CONST_WIDTH              = (CONST_INTEGER_WIDTH + FRACTIONAL_WIDTH);

    localparam ROUNDING_BIT_INDEX = (FRACTIONAL_WIDTH - (OUTPUT_WIDTH -(INPUT_WIDTH + 3))) - 1;

    if (DEBUG>0) initial begin
        $display("FDCT parameters:");
        $display("    INPUT_WIDTH      = %1d", INPUT_WIDTH);
        $display("    INPUT_UNSIGNED   = %1d", INPUT_UNSIGNED);
        $display("    FRACTIONAL_WIDTH = %1d", FRACTIONAL_WIDTH);
        $display("    ROUND            = %1d", ROUND);
        $display("    OUTPUT_WIDTH     = %1d", OUTPUT_WIDTH);
    end

    if (INPUT_UNSIGNED & ~1) $error("INPUT_UNSIGNED not 0 or 1!");
    if (ROUND & ~1) $error("ROUND not 0 or 1!");
    if (OUTPUT_WIDTH > INPUT_WIDTH + FRACTIONAL_WIDTH + 3) $error("OUTPUT_WIDTH > INPUT_WIDTH + FRACTIONAL_WIDTH + 3!");

    `define CONST_MAX_FRACTIONAL_WIDTH 54  
    if (FRACTIONAL_WIDTH > `CONST_MAX_FRACTIONAL_WIDTH) $error("Fractional width > ", `CONST_MAX_FRACTIONAL_WIDTH);
    `define FIX(x) FRACTIONAL_WIDTH < `CONST_MAX_FRACTIONAL_WIDTH ? (((x >> (`CONST_MAX_FRACTIONAL_WIDTH - FRACTIONAL_WIDTH - 1)) + 1) >> 1) : (x) 

    logic [(INPUT_WIDTH + 1) - 1 : 0] s11, s12, s13, s14, s15, s16, s17, s18;
    logic [(INPUT_WIDTH + 2) - 1 : 0] s21, s22, s23, s24;
    logic [(INPUT_WIDTH + 3) - 1 : 0] s31, s32;

    logic unsigned [$high(s31) : 0] tmp;

    logic signed [(INPUT_WIDTH + 2) - 1 : 0] s25, s26, s27, s28;
    logic signed [(INPUT_WIDTH + 3) -1 : 0] s33;
    logic signed [(INPUT_WIDTH + 3) -1 : 0] s34;

    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH + 3) - 1 : 0] s41;  // Q(i+3+1).f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH + 3) - 1 : 0] s42;  // Q(i+3+0).f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH + 2) - 1 : 0] s43;  // Q(i+3+0).f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH + 2) - 1 : 0] s44;  // Q(i+3+0).f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH + 0) - 1 : 0] s45;  // Q(i+3-1).f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH + 3) - 1 : 0] s46;  // Q(i+3+1).f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH + 3) - 1 : 0] s47;  // Q(i+3+2).f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH + 4) - 1 : 0] s48;  // Q(i+3+1).f  ?????
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH + 3) - 1 : 0] s49;  // Q(i+3+2).f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH + 1) - 1 : 0] s4A;  // Q(i+3-1).f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH + 2) - 1 : 0] s4B;  // Q(i+3+1).f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH + 4) - 1 : 0] s4C;  // Q(i+3+2).f
    logic signed [$high(s42):0] t42;
    logic signed [$high(s48):0] t48;

    logic signed [((INPUT_WIDTH + 3 + FRACTIONAL_WIDTH) + 0) -1 : 0] s51, s52, s54, s55, s56, s57;
    logic signed [((INPUT_WIDTH + 3 + FRACTIONAL_WIDTH) - 1) -1 : 0] s53, s58;

    logic signed [(INPUT_WIDTH + 3 + FRACTIONAL_WIDTH) - 1 : 0] s61, s62, s63, s64;

    always_comb begin
        //generate
            if (INPUT_UNSIGNED) begin : unsigned_inputs
                /* Stage 1 unsigned part */
                s11 = $unsigned(ins[0]) + $unsigned(ins[7]);
                s12 = $unsigned(ins[1]) + $unsigned(ins[6]);
                s13 = $unsigned(ins[2]) + $unsigned(ins[5]);
                s14 = $unsigned(ins[3]) + $unsigned(ins[4]);
                s15 = $unsigned(ins[3]) - $unsigned(ins[4]);
                s16 = $unsigned(ins[2]) - $unsigned(ins[5]);
                s17 = $unsigned(ins[1]) - $unsigned(ins[6]);
                s18 = $unsigned(ins[0]) - $unsigned(ins[7]);   
                /* Stage 2 unsigned part */
                s21 = $unsigned(s11) + $unsigned(s14);
                s22 = $unsigned(s12) + $unsigned(s13);
                s23 = $unsigned(s12) - $unsigned(s13);
                s24 = $unsigned(s11) - $unsigned(s14);
                /* Stage 3 unsigned part */
                tmp = $unsigned(s21) + $unsigned(s22);
                s31 = {~tmp[$high(tmp)], tmp[$high(tmp) - 1 : 0]};
                s32 = $unsigned(s21) - $unsigned(s22); 
            end
            else begin : signed_inputs
                s11 = $signed(ins[0]) + $signed(ins[7]);
                s12 = $signed(ins[1]) + $signed(ins[6]);
                s13 = $signed(ins[2]) + $signed(ins[5]);
                s14 = $signed(ins[3]) + $signed(ins[4]);
                s15 = $signed(ins[3]) - $signed(ins[4]);
                s16 = $signed(ins[2]) - $signed(ins[5]);
                s17 = $signed(ins[1]) - $signed(ins[6]);
                s18 = $signed(ins[0]) - $signed(ins[7]);    
                /* Stage 2 signed part */
                s21 = $signed(s11) + $signed(s14);
                s22 = $signed(s12) + $signed(s13);
                s23 = $signed(s12) - $signed(s13);
                s24 = $signed(s11) - $signed(s14);
                /* Stage 3 signed part */
                s31 = $signed(s21) + $signed(s22);
                s32 = $signed(s21) - $signed(s22);
            end
        //endgenerate
    end

    always_comb begin
        /* Stage 3 common (both signed and unsigned) part*/
        s25 = $signed(s15) + $signed(s18);
        s26 = $signed(s15) + $signed(s17);
        s27 = $signed(s16) + $signed(s18);
        s28 = $signed(s16) + $signed(s17);
        /* Stage 3 common (both signed and unsigned) part*/
        s33 = $signed(s23) + $signed(s24);
        s34 = $signed(s26) + $signed(s27);  
    end

    /* Stage 4: Multiplications */
    always_comb begin
        s41 = $signed(s23) * $signed(`FIX(57'b001_110110010000011010111100111100110010100011010100011000));  // (c2+c6)
        t42 = $signed(s33) * $signed(`FIX(57'b000_100010101000101111010011110111101101100111000100101010));  // (c6)
        s43 = $signed(s24) * $signed(`FIX(57'b000_110000111110111100010101001101010111010101001011000110));  // (c2-c6)
        s44 = $signed(s25) * $signed(`FIX(57'b000_111001100110010011010111011111011000110001101010110000));  // (c3-c7)
        s45 = $signed(s15) * $signed(`FIX(57'b000_010011000111001100011010011011101000101110110000110101));  // (-c1+c3+c5-c7)
        s46 = $signed(s26) * $signed(`FIX(57'b001_111101100010100101111100111111110111010111001011000000));  // (c3+c5)
        s47 = $signed(s16) * $signed(`FIX(57'b010_000011011001100101000011100000101001000010110010011000));  // (c1+c3-c5+c7)
        t48 = $signed(s34) * $signed(`FIX(57'b001_001011010000011000101110111110001000111000110001101000));  // (c3)
        s49 = $signed(s17) * $signed(`FIX(57'b011_000100101001110100110000100110100101110001010111100000));  // (c1+c3+c5-c7)
        s4A = $signed(s27) * $signed(`FIX(57'b000_011000111110001011100000111100011010011010011000001011));  // (c3-c5)
        s4B = $signed(s18) * $signed(`FIX(57'b001_100000000101011010010100100011001000110100100100101100));  // (c1+c3-c5-c7)
        s4C = $signed(s28) * $signed(`FIX(57'b010_100100000001101100111010000011100111011010000101000000));  // (c1+c3)
    end

    always_comb begin
        if (ROUND) begin:rounded_outputs
            s42 = {t42[$high(t42) : ROUNDING_BIT_INDEX] + 1, t42[ROUNDING_BIT_INDEX - 1 : 0]};
            s48 = {t48[$high(t48) : ROUNDING_BIT_INDEX] + 1, t48[ROUNDING_BIT_INDEX - 1 : 0]};
        end  
        else begin:truncated_outputs
            s42 = t42;
            s48 = t48;
        end
    end

    /* Stage 5 */
    always_comb begin
        s51 = s42 - s41;
        s52 = s42 + s43;
        s53 = s45 - s44;
        s54 = s48 - s46;
        s55 = s47 - s4C;
        s56 = s49 - s4C;
        s57 = s48 - s4A;
        s58 = s4B - s44;
    end

    /* Stage 6 */
    always_comb begin
        s61 = s53 + s54;
        s62 = s55 + s57;
        s63 = s54 + s56;
        s64 = s57 + s58;
    end

    /* Output: */
    always_comb begin
        if (OUTPUT_WIDTH >= (INPUT_WIDTH + 3)) begin
            outs[0] = {s31, {(OUTPUT_FRACTIONAL_WIDTH){1'b0}} };
            outs[4] = {s32, {(OUTPUT_FRACTIONAL_WIDTH){1'b0}} };
        end
        else begin
            outs[0] = s31[$high(s31) : $high(s31)-$high(outs[0])];
            outs[4] = s32[$high(s32) : $high(s32)-$high(outs[4])];
        end
        outs[6] = s51[$high(s51) : $high(s51)-$high(outs[6])];
        outs[2] = s52[$high(s52) : $high(s52)-$high(outs[2])];
        outs[7] = s61[$high(s61) : $high(s61)-$high(outs[7])];
        outs[5] = s62[$high(s62) : $high(s62)-$high(outs[5])];
        outs[3] = s63[$high(s63) : $high(s63)-$high(outs[3])];
        outs[1] = s64[$high(s64) : $high(s64)-$high(outs[1])];
    end

    if (DEBUG>1) always @(*) begin
        $display("TIME = %0t", $time);
        $display("s47=%0d, s49=%0d, s4C[%0d]=%0d, s55=%0d, s56=%0d, s62=%0d, s63=%0d, outs[5]=%0d, outs[3]=%0d", 
                  s47,     s49, $high(s4C)+1,s4C, s55,     s56,     s62,     s63,     outs[5],     outs[3]);
        $display("%b - %b = %b", s47, s4C, s55);
    end

endmodule

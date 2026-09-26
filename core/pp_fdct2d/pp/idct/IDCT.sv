`timescale 1ns / 1ps


module IDCT#(
    parameter int unsigned INPUT_WIDTH      = 11,       // i = input data width
    parameter int unsigned FRACTIONAL_WIDTH = 13,  // f = internal fixed point added precision (multiplications)
    parameter int unsigned ROUND            =  1,              // fixed point roundness (0 = truncate directly, 1 = rounded => add 0.5 before truncating)
    parameter int unsigned OUTPUT_WIDTH     = 11,      // o = output data width (can keep some fractional bits for extra precision)
    parameter int unsigned OUTPUT_UNSIGNED  =  0,    // output signedess (0 = signed, 1 = unsigned)
    parameter int unsigned DEBUG            =  1, 
    parameter int unsigned EXTRA            =  0               // verbosity level (0 = no debug messeges, 1 = display instance params, 2 = also display change events)
)(
        input  logic signed [INPUT_WIDTH - 1 : 0]   ins  [0:7],
        output logic        [OUTPUT_WIDTH - 1 : 0]  outs [0:7]
    );

    if (DEBUG > 0) initial begin
        $display("IDCT parameters:");
        $display("    INPUT_WIDTH = %0d", INPUT_WIDTH);
        $display("    FRACTIONAL_WIDTH = %0d", FRACTIONAL_WIDTH);
        $display("    ROUND = %0d", ROUND);
        $display("    OUTPUT_WIDTH = %0d", OUTPUT_WIDTH);
        $display("    OUTPUT_UNSIGNED = %0d", OUTPUT_UNSIGNED);
    end
    
    if (OUTPUT_UNSIGNED & ~1) $error("IDCT: INPUT_UNSIGNED not 0 or 1!");
    if (ROUND & ~1) $error("IDCT: ROUND not 0 or 1!");
    //if (OUTPUT_WIDTH < INPUT_WIDTH - 3) $error("IDCT: OUTPUT_WIDTH < INPUT_WIDTH - 3!", );
    if (OUTPUT_WIDTH > INPUT_WIDTH + FRACTIONAL_WIDTH) $error("IDCT: OUTPUT_WIDTH > INPUT_WIDTH + FRACTIONAL_WIDTH!");
 
    localparam INPUT_INTEGER_WIDTH = INPUT_WIDTH - 3;   // Input is scaled with 2*√2
    localparam OUTPUT_INTEGER_WIDTH = INPUT_INTEGER_WIDTH;
    localparam OUTPUT_FRACTIONAL_WIDTH = OUTPUT_WIDTH - OUTPUT_INTEGER_WIDTH;
    localparam CONST_INTEGER_WIDTH = 3;
    localparam CONST_WIDTH = CONST_INTEGER_WIDTH + FRACTIONAL_WIDTH;
      
    /* signed/unsigned conversion for "ins[0]" if needed (parameter OUTPUT_UNSIGNED = 0) */
    logic signed [INPUT_WIDTH - 1 : 0] DC1;  // Qi.0 
    logic signed [INPUT_WIDTH - 1 : 0] DC2;  // Qi.0
    
    generate 
        if (0 && OUTPUT_UNSIGNED) begin:unsigned_outputs  
            assign DC1 = ins[0] + (1<<($high(ins[0])-EXTRA)); 
        end
        else begin:signed_outputs // pass-through
            assign DC1 = ins[0];
        end
    endgenerate
   
    
    generate
        if (ROUND==1 && OUTPUT_WIDTH < INPUT_WIDTH) begin:rounded_smaller_outputs
            localparam ROUNDING_BIT_INDEX = INPUT_WIDTH - EXTRA - OUTPUT_WIDTH - 1;
    
            if (ROUNDING_BIT_INDEX) begin
                logic signed [$high(DC1) - ROUNDING_BIT_INDEX : 0] DC0 = DC1[$high(DC1) : ROUNDING_BIT_INDEX];
                assign DC2 = {DC0+1, DC1[ROUNDING_BIT_INDEX - 1 : 0]};
            end else
                assign DC2 = DC1 + 1;
        end
        else // pass-through
            assign DC2 = DC1;
    endgenerate
   
 
    /* Stage 7 */  
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH + 0) - 1 : 0] s71; // Qi.f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH + 0) - 1 : 0] s72; // Qi.f
    generate
        if (ROUND && OUTPUT_WIDTH >= INPUT_WIDTH) begin:rounded_biger_outputs2
            localparam ROUNDING_BIT_INDEX = (FRACTIONAL_WIDTH - (OUTPUT_WIDTH - INPUT_WIDTH) - 1);
            assign s71[$high(s71) : FRACTIONAL_WIDTH] = DC2 + ins[4];
            assign s71[FRACTIONAL_WIDTH - 1 : 0] = 1 << (ROUNDING_BIT_INDEX);
            assign s72[$high(s71) : FRACTIONAL_WIDTH] = DC2 - ins[4];
            assign s72[FRACTIONAL_WIDTH - 1 : 0] = 1 << (ROUNDING_BIT_INDEX);
        end
        else begin:truncated_outputs
            assign s71 = {DC2 + ins[4], {(FRACTIONAL_WIDTH){1'b0}}};
            assign s72 = {DC2 - ins[4], {(FRACTIONAL_WIDTH){1'b0}}};        
        end
    endgenerate       
    logic signed [(INPUT_WIDTH + 1) - 1 : 0] s73;
    logic signed [(INPUT_WIDTH + 1) - 1 : 0] s74;
    logic signed [(INPUT_WIDTH + 1) - 1 : 0] s75;
    logic signed [(INPUT_WIDTH + 1) - 1 : 0] s76;
    logic signed [(INPUT_WIDTH + 1) - 1 : 0] s77;

    assign s73 = ins[6] + ins[2];
    assign s74 = ins[7] + ins[1];
    assign s75 = ins[7] + ins[3];
    assign s76 = ins[5] + ins[1];
    assign s77 = ins[5] + ins[3];
    
    /* Stage 8 */
    logic signed [(INPUT_WIDTH + 1) - 1 : 0] s81;  
    assign s81 = s75 + s76;        
    
    `define CONST_MAX_FRACTIONAL_WIDTH 54  
    if (FRACTIONAL_WIDTH > `CONST_MAX_FRACTIONAL_WIDTH) $error("Fractional width > ", `CONST_MAX_FRACTIONAL_WIDTH);
    `define FIX(x) FRACTIONAL_WIDTH < `CONST_MAX_FRACTIONAL_WIDTH ? (((x >> (`CONST_MAX_FRACTIONAL_WIDTH - FRACTIONAL_WIDTH - 1)) + 1) >> 1) : (x) 
        
    /* Stage 9:  Multiplications */
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH + 1) - 1 : 0] s91;  // Q(i+1).f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH + 0) - 1 : 0] s92;  // Q(i+0).f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH + 0) - 1 : 0] s93;  // Q(i+0).f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH + 1) - 1 : 0] s94;  // Q(i+1).f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH - 1) - 1 : 0] s95;  // Q(i-1).f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH + 2) - 1 : 0] s96;  // Q(i+2).f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH + 1) - 1 : 0] s97;  // Q(i+1).f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH + 1) - 1 : 0] s98;  // Q(i+1).f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH + 2) - 1 : 0] s99;  // Q(i+2).f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH - 1) - 1 : 0] s9A;  // Q(i-1).f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH + 1) - 1 : 0] s9B;  // Q(i+1).f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH + 2) - 1 : 0] s9C;  // Q(i+2).f
    assign s91 = $signed(ins[6]) * $signed(`FIX(57'b001_110110010000011010111100111100110010100011010100011000));  // (c2+c6)
    assign s92 = $signed(s73) * $signed(`FIX(57'b000_100010101000101111010011110111101101100111000100101010));  // (c6)
    assign s93 = $signed(ins[2]) * $signed(`FIX(57'b000_110000111110111100010101001101010111010101001011000110));  // (c2-c6)
    assign s94 = $signed(s74) * $signed(`FIX(57'b000_111001100110010011010111011111011000110001101010110000));  // (c3-c7)
    assign s95 = $signed(ins[7]) * $signed(`FIX(57'b000_010011000111001100011010011011101000101110110000110101));  // (-c1+c3+c5-c7)
    assign s96 = $signed(s75) * $signed(`FIX(57'b001_111101100010100101111100111111110111010111001011000000));  // (c3+c5)
    assign s97 = $signed(ins[5]) * $signed(`FIX(57'b010_000011011001100101000011100000101001000010110010011000));  // (c1+c3-c5+c7)
    assign s98 = $signed(s81) * $signed(`FIX(57'b001_001011010000011000101110111110001000111000110001101000));  // (c3)
    assign s99 = $signed(ins[3]) * $signed(`FIX(57'b011_000100101001110100110000100110100101110001010111100000));  // (c1+c3+c5-c7)
    assign s9A = $signed(s76) * $signed(`FIX(57'b000_011000111110001011100000111100011010011010011000001011));  // (c3-c5)
    assign s9B = $signed(ins[1]) * $signed(`FIX(57'b001_100000000101011010010100100011001000110100100100101100));  // (c1+c3-c5-c7)
    assign s9C = $signed(s77) * $signed(`FIX(57'b010_100100000001101100111010000011100111011010000101000000));  // (c1+c3)
      
    /* Stage A (10) */
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH + 0) - 1 : 0] sA1; // Qi.f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH + 0) - 1 : 0] sA2; // Qi.f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH + 0) - 1 : 0] sA3; // Q0.f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH + 1) - 1 : 0] sA4; // Q(i+1).f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH + 1) - 1 : 0] sA5; // Q(i+1).f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH + 1) - 1 : 0] sA6; // Q(i+1).f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH + 1) - 1 : 0] sA7; // Q(i+1).f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH + 0) - 1 : 0] sA8; // Qi.f

    assign sA1 = s92 - s91; // Qi.f
    assign sA2 = s92 + s93; // Qi.f
    assign sA3 = s95 - s94; // Q0.f
    assign sA4 = s98 - s96; // Q(i+1).f
    assign sA5 = s97 - s9C; // Q(i+1).f
    assign sA6 = s99 - s9C; // Q(i+1).f
    assign sA7 = s98 - s9A; // Q(i+1).f
    assign sA8 = s9B - s94; // Qi.f
 
    /* Stage B */
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH) - 1 : 0] sB1; // Q0.f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH) - 1 : 0] sB2; // Q0.f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH) - 1 : 0] sB3; // Q0.f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH) - 1 : 0] sB4; // Q0.f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH) - 1 : 0] sB5; // Q0.f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH) - 1 : 0] sB6; // Q0.f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH) - 1 : 0] sB7; // Q0.f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH) - 1 : 0] sB8; // Q0.f

    assign sB1 = s71 + sA2; // Q0.f
    assign sB2 = s72 + sA1; // Q0.f
    assign sB3 = s72 - sA1; // Q0.f
    assign sB4 = s71 - sA2; // Q0.f
    assign sB5 = sA3 + sA4; // Q0.f
    assign sB6 = sA5 + sA7; // Q0.f
    assign sB7 = sA4 + sA6; // Q0.f
    assign sB8 = sA7 + sA8; // Q0.f
 
    /* Stage C */
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH) - 1 : 0] sC1; // Q0.f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH) - 1 : 0] sC2; // Q0.f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH) - 1 : 0] sC3; // Q0.f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH) - 1 : 0] sC4; // Q0.f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH) - 1 : 0] sC5; // Q0.f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH) - 1 : 0] sC6; // Q0.f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH) - 1 : 0] sC7; // Q0.f
    logic signed [(INPUT_WIDTH + FRACTIONAL_WIDTH) - 1 : 0] sC8; // Q0.f    

    assign sC1 = sB1 + sB8; // Q0.f
    assign sC2 = sB2 + sB7; // Q0.f
    assign sC3 = sB3 + sB6; // Q0.f
    assign sC4 = sB4 + sB5; // Q0.f
    assign sC5 = sB4 - sB5; // Q0.f
    assign sC6 = sB3 - sB6; // Q0.f
    assign sC7 = sB2 - sB7; // Q0.f
    assign sC8 = sB1 - sB8; // Q0.f  
    
    //CONDITIONAL CLAMPING - when extra bits are used clamping is required if higher E+1 (sign bits) do not agree, then the appropiate saturated value is used, otherwise leading E bits are skipped and up to OUTPUT_WIDTH bits following are kept
   `define CLAMP_EXTRA(x, E) $signed(((E>0) && ((~&x[$high(x):$high(x)-E])&(|x[$high(x):$high(x)-E]))) ? {x[$high(x)], {(OUTPUT_WIDTH-1){~x[$high(x)]}}} : x[$high(x)-E:$high(x)-OUTPUT_WIDTH+1-E])

    logic signed [OUTPUT_WIDTH-1:0] cout0;
    logic signed [OUTPUT_WIDTH-1:0] cout1;
    logic signed [OUTPUT_WIDTH-1:0] cout2;
    logic signed [OUTPUT_WIDTH-1:0] cout3;
    logic signed [OUTPUT_WIDTH-1:0] cout4;
    logic signed [OUTPUT_WIDTH-1:0] cout5;
    logic signed [OUTPUT_WIDTH-1:0] cout6;
    logic signed [OUTPUT_WIDTH-1:0] cout7;

    assign cout0 = `CLAMP_EXTRA(sC1, EXTRA);
    assign cout1 = `CLAMP_EXTRA(sC2, EXTRA);
    assign cout2 = `CLAMP_EXTRA(sC3, EXTRA);
    assign cout3 = `CLAMP_EXTRA(sC4, EXTRA);
    assign cout4 = `CLAMP_EXTRA(sC5, EXTRA);
    assign cout5 = `CLAMP_EXTRA(sC6, EXTRA);
    assign cout6 = `CLAMP_EXTRA(sC7, EXTRA);
    assign cout7 = `CLAMP_EXTRA(sC8, EXTRA);
        
    /* Output: */
    assign outs[0] = OUTPUT_UNSIGNED ? {~cout0[$high(cout0)],cout0[$high(cout0)-1:0]} : cout0; 
    assign outs[1] = OUTPUT_UNSIGNED ? {~cout1[$high(cout1)],cout1[$high(cout1)-1:0]} : cout1;
    assign outs[2] = OUTPUT_UNSIGNED ? {~cout2[$high(cout2)],cout2[$high(cout2)-1:0]} : cout2;
    assign outs[3] = OUTPUT_UNSIGNED ? {~cout3[$high(cout3)],cout3[$high(cout3)-1:0]} : cout3;
    assign outs[4] = OUTPUT_UNSIGNED ? {~cout4[$high(cout4)],cout4[$high(cout4)-1:0]} : cout4;
    assign outs[5] = OUTPUT_UNSIGNED ? {~cout5[$high(cout5)],cout5[$high(cout5)-1:0]} : cout5;
    assign outs[6] = OUTPUT_UNSIGNED ? {~cout6[$high(cout6)],cout6[$high(cout6)-1:0]} : cout6;
    assign outs[7] = OUTPUT_UNSIGNED ? {~cout7[$high(cout7)],cout7[$high(cout7)-1:0]} : cout7;          
endmodule

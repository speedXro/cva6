`timescale 1 ns / 1 ps //pp_idwt_cdf53.sv

module pp_idwt_cdf53(
    input  logic        clk,
    input  logic        reset_n,

    input  logic        input_valid,
    input  logic        input_last,
    input  logic [15:0] input_values_low  [0:7],
    input  logic [15:0] input_values_high [0:7],

    output logic        busy,

    output logic        output_ready,
    output logic        output_last,
    output logic [ 7:0] output_values     [0:15]
);
    //functions
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

    //signals

    logic [15:0] w_16_even [0:7];
    logic [15:0] w_16_odd  [0:7];

    logic        stage_0_busy;
    logic        stage_0_last;
    logic [15:0] stage_0_r_16_odd  [0:7];
    logic [16:0] stage_0_r_17_even [0:7];

    logic        stage_1_busy;
    logic        stage_1_last;
    logic [16:0] stage_1_r_17_even [0:7];
    logic [17:0] stage_1_r_18_odd  [0:7];

    genvar i;

    //buses assigns
    generate
        for(i=0;i<8;i++) begin //: gen_assign_lows
            assign w_16_even[i] = input_values_low[i];
            assign w_16_odd[i]  = input_values_high[i];
        end
    endgenerate

    //stages

    integer k0, i0;

    always_ff @(posedge clk or negedge reset_n) begin
        if(reset_n == 1'b0) begin
            stage_0_busy       <=  1'd0;
            stage_0_last       <=  1'd0;

            for(k0=0;k0<8;++k0) begin
                stage_0_r_16_odd[k0]  <= 16'd0;
                stage_0_r_17_even[k0] <= 17'd0;
            end
        end
        else begin
            stage_0_busy <= input_valid;
            stage_0_last <= input_last;

            for(i0=0;i0<8;++i0) begin
                stage_0_r_16_odd[i0] <= w_16_odd[i0];
                stage_0_r_17_even[i0] <= diff_stage_0(sign_extend_16_17(w_16_even[i0]), sign_extend_16_17(sum_plus_2_slr_2(sign_extend_16_18(w_16_odd[i0]), sign_extend_16_18(w_16_odd[(i0 == 0) ? 7 : (i0 - 1)]))));
            end
        end
    end

    integer k1, i1;

    always_ff @(posedge clk or negedge reset_n) begin
        if(reset_n == 1'b0) begin
            stage_1_busy        <= 1'd0;
            stage_1_last        <= 1'd0;

            for(k1=0;k1<8;++k1) begin
                stage_1_r_17_even[k1] <= 17'd0;
                stage_1_r_18_odd[k1]  <= 18'd0;
            end
        end
        else begin
            stage_1_busy <= stage_0_busy;
            stage_1_last <= stage_0_last;

            for(i1=0;i1<8;++i1) begin
                stage_1_r_17_even[i1] <= stage_0_r_17_even[i1];
                stage_1_r_18_odd[i1] <= sum_stage_1(sign_extend_16_18(stage_0_r_16_odd[i1]), sign_extend_17_18(sum_slr_1(sign_extend_17_18(stage_0_r_17_even[i1]), sign_extend_17_18(stage_0_r_17_even[(i1 == 7) ? (0) : (i1 + 1)]))));
            end
        end
    end

    integer k2,i2;

    always_ff @(posedge clk or negedge reset_n) begin
        if(reset_n == 1'b0) begin
            output_ready <= 1'd0;
            output_last  <= 1'd0;

            for(k2=0;k2<16;++k2) begin
                output_values[k2] <= 8'd0;
            end
        end
        else begin
            output_ready <= stage_1_busy;
            output_last  <= stage_1_last;
            
            for(i2=0;i2<8;++i2) begin
                output_values[2*i2]     <= clamp_i8_in_17b(stage_1_r_17_even[i2]);
                output_values[(2*i2)+1] <= clamp_i8_in_18b(stage_1_r_18_odd[i2]);
            end
        end
    end

    assign busy = stage_0_busy | stage_1_busy;

endmodule

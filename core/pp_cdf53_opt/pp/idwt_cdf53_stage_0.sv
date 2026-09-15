`timescale 1 ns / 1 ps

module idwt_cdf53_stage_0(
    input  logic        clk,
    input  logic        reset_n,

    output logic        in_ready,
    input  logic        in_valid,
    input  logic        in_last,
    input  logic [15:0] in_values_low [0:7],
    input  logic [15:0] in_values_high [0:7],

    output logic        out_valid,
    output logic        out_last,
    output logic [15:0] out_stage_0_r_16_odd  [0:7],
    output logic [16:0] out_stage_0_r_17_even [0:7],
    input  logic        out_ready
);

    logic [15:0] w_16_even [0:7];
    logic [15:0] w_16_odd  [0:7];

    logic        valid_reg;
    logic        last_reg;

    logic [15:0] stage_0_r_16_odd  [0:7];
    logic [16:0] stage_0_r_17_even [0:7];

    genvar j;

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

    //buses assigns
    generate
        for(j=0;j<8;j++) begin //: gen_assign_lows
            assign w_16_even[j] = in_values_low[j];
            assign w_16_odd[j]  = in_values_high[j];
        end
    endgenerate

    integer i;

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
                    for(i=0;i<8;++i) begin
                        stage_0_r_16_odd[i] <= w_16_odd[i];
                        stage_0_r_17_even[i] <= diff_stage_0(sign_extend_16_17(w_16_even[i]), sign_extend_16_17(sum_plus_2_slr_2(sign_extend_16_18(w_16_odd[i]), sign_extend_16_18(w_16_odd[(i == 0) ? 7 : (i - 1)]))));
                    end
                    last_reg <=  in_last;
                end
            end else if (!valid_reg) begin
                if (in_valid) begin
                    valid_reg <= 1'b1;
                    //data_reg  <= ~in_data;
                    for(i=0;i<8;++i) begin
                        stage_0_r_16_odd[i] <= w_16_odd[i];
                        stage_0_r_17_even[i] <= diff_stage_0(sign_extend_16_17(w_16_even[i]), sign_extend_16_17(sum_plus_2_slr_2(sign_extend_16_18(w_16_odd[i]), sign_extend_16_18(w_16_odd[(i == 0) ? 7 : (i - 1)]))));
                    end
                    last_reg  <=  in_last;
                end
            end
        end
    end

    assign in_ready             = !valid_reg | out_ready;
    //assign out_data  = data_reg;
    assign out_stage_0_r_16_odd = stage_0_r_16_odd;
    assign out_stage_0_r_17_even  = stage_0_r_17_even; 
    
    assign out_last             = last_reg;
    assign out_valid            = valid_reg;

endmodule


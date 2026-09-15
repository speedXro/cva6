`timescale 1 ns / 1 ps //pp_fdwt_cdf53.sv

module fdwt_cdf53_stage_0(
    input  logic        clk,
    input  logic        reset_n,

    output logic        in_ready,
    input  logic        in_valid,
    input  logic        in_last,
    input  logic [ 7:0] in_data [0:15],

    output logic        out_valid,
    output logic        out_last,
    output logic [ 7:0] out_stage_0_r_8_even [0:7],
    output logic [ 8:0] out_stage_0_r_9_odd [0:7],
    input  logic        out_ready
);
    logic        valid_reg;
    logic        last_reg;
    logic [ 7:0] stage_0_r_8_even_reg [0:7];
    logic [ 8:0] stage_0_r_9_odd_reg [0:7];
    

    localparam IN_WIDTH_8_9  = 8;
    localparam OUT_WIDTH_8_9 = 9;

    function automatic [OUT_WIDTH_8_9-1:0] sign_extend_8_9;
        input [IN_WIDTH_8_9-1:0] in;
        begin
            sign_extend_8_9 = {{(OUT_WIDTH_8_9 - IN_WIDTH_8_9){in[IN_WIDTH_8_9-1]}}, in};
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

    logic [7:0] w_8_even [0:7];
    logic [7:0] w_8_odd  [0:7];

    genvar i;
    generate
        for(i=0;i<8;++i) begin //: gen_assign_even_inputs
            assign w_8_even[i] = in_data[2*i];
            assign w_8_odd[i] = in_data[(2*i)+1];
        end
    endgenerate

    integer k0, i0;

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
                    for(i0=0;i0<8;++i0) begin
                        stage_0_r_8_even_reg[i0] <= w_8_even[i0];
                        stage_0_r_9_odd_reg[i0] <= diff_stage_0(sign_extend_8_9(w_8_odd[i0]), sign_extend_8_9(sum_slr_1(sign_extend_8_9(w_8_even[i0]),sign_extend_8_9(w_8_even[(i0 == 7) ? (0) : (i0 + 1)]))));
                    end
                    last_reg <=  in_last;
                end
                else begin last_reg <= 1'b0; end
            end else if (!valid_reg) begin
                if (in_valid) begin
                    valid_reg <= 1'b1;
                    //data_reg  <= ~in_data;
                    for(i0=0;i0<8;++i0) begin
                        stage_0_r_8_even_reg[i0] <= w_8_even[i0];
                        stage_0_r_9_odd_reg[i0] <= diff_stage_0(sign_extend_8_9(w_8_odd[i0]), sign_extend_8_9(sum_slr_1(sign_extend_8_9(w_8_even[i0]),sign_extend_8_9(w_8_even[(i0 == 7) ? (0) : (i0 + 1)]))));
                    end
                    last_reg  <=  in_last;
                end
                else begin last_reg <= 1'b0; end
            end
            else begin last_reg <= 1'b0; end
        end
    end

    assign in_ready             = !valid_reg | out_ready;
    //assign out_data  = data_reg;
    assign out_stage_0_r_8_even = stage_0_r_8_even_reg;
    assign out_stage_0_r_9_odd  = stage_0_r_9_odd_reg; 
    
    assign out_last             = last_reg;
    assign out_valid            = valid_reg;

endmodule

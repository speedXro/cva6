`timescale 1ns / 1ps


module pp_fdct_2d #(
    parameter int unsigned INPUT_WIDTH            =  8,
    parameter int unsigned QM_PASSTHROUGH         =  0,
    parameter int unsigned OUTPUT_WIDTH_R         = 13,     
    parameter int unsigned OUTPUT_WIDTH_C         = 16,
    
    parameter int unsigned FRACTIONAL_WIDTH_R     =  9, 
    parameter int unsigned FRACTIONAL_WIDTH_C     =  9,
    
    parameter int unsigned QUANT_FRACTIONAL_WIDTH = 17,
    parameter int unsigned ROUND                  =  1,

    parameter int unsigned OUTPUT_WIDTH           = 13,
    parameter int unsigned NORMAL_OUTPUT_WIDTH    = 16 
)(
    input  logic                                clk,
    input  logic                                reset_n,

    output logic                                in_ready,
    input  logic                                in_valid,
    input  logic                                in_last,
    input  logic [INPUT_WIDTH*64-1:0]           in_data,

    output logic                                out_valid,
    output logic                                out_last,
    output logic [NORMAL_OUTPUT_WIDTH*64-1:0]   out_data,
    input  logic                                out_ready,

    input logic                                 qm_we,
    input logic  [7:0]                          qm [0:63]
);

    genvar i,j,k,m;

    logic        [INPUT_WIDTH-1   :0] qs  [0:63];
    logic        [INPUT_WIDTH-1   :0] i1r [0:63];
    logic signed [OUTPUT_WIDTH_R-1:0] o1r [0:63];
    logic        [OUTPUT_WIDTH_R-1:0] i2c [0:63];
    logic signed [OUTPUT_WIDTH_C-1:0] o2c [0:63];
    logic signed [OUTPUT_WIDTH_C-1:0] iqc [0:63];
    logic        [OUTPUT_WIDTH-1  :0] oqc [0:63];

    logic [               7:0] ready_0_bus;

    logic [               7:0] w_01_valid;
    logic [               7:0] w_01_last;
    logic [               7:0] w_01_ready;

    logic [               7:0] w_12_valid;
    logic [               7:0] w_12_last;
    logic [               7:0] w_12_ready;

    logic [               7:0] w_2o_valid;
    logic [               7:0] w_2o_last;
    //logic [               7:0] w_2o_ready;

    logic [OUTPUT_WIDTH*64-1:0] out_data_minimal;

    assign in_ready = &ready_0_bus;

    generate
        for(i=0;i<8;++i) begin
            logic        [INPUT_WIDTH-1   :0] i1r_array [0:7];
            logic signed [OUTPUT_WIDTH_R-1:0] o1r_array [0:7];

            logic        [OUTPUT_WIDTH_R-1:0] i2c_array [0:7];
            logic signed [OUTPUT_WIDTH_C-1:0] o2c_array [0:7];

            logic signed [OUTPUT_WIDTH_C-1:0] iqc_array [0:7];
            logic signed [OUTPUT_WIDTH-1  :0] oqc_array [0:7];

            logic        [               7:0] q_array   [0:7];

            for(j=0;j<8;++j) begin
                assign i1r[i*8+j] = in_data[(i*8+j+1)*INPUT_WIDTH-1:(i*8+j)*INPUT_WIDTH];
            end

            for(k=0;k<8;++k) begin
                assign i1r_array[k] = i1r[i*8+k];
                assign o1r[i*8+k] = o1r_array[k];
            end

            pp_FDCT_stage #(
                .INPUT_WIDTH(INPUT_WIDTH),
                .INPUT_UNSIGNED(1),
                .FRACTIONAL_WIDTH(FRACTIONAL_WIDTH_R),
                .ROUND(ROUND),
                .OUTPUT_WIDTH(OUTPUT_WIDTH_R)
            ) i_pp_FDCT_stage_0(
                .clk(clk),
                .reset_n(reset_n),

                .in_ready(ready_0_bus[i]),
                .in_valid(in_valid),
                .in_last(in_last),
                .in_data(i1r_array),

                .out_valid(w_01_valid[i]),
                .out_last(w_01_last[i]),
                .out_ready(w_01_ready[i]),
                .out_data(o1r_array)
            );

            for(j=0;j<8;++j) begin
                assign i2c[i*8+j] = o1r[j*8+i];
            end

            for(k=0;k<8;++k) begin
                assign i2c_array[k] = i2c[i*8+k];
                assign o2c[i*8+k] = o2c_array[k];
            end

            pp_FDCT_stage #(
                .INPUT_WIDTH(OUTPUT_WIDTH_R),
                .INPUT_UNSIGNED(0),
                .FRACTIONAL_WIDTH(FRACTIONAL_WIDTH_C),
                .ROUND(ROUND),
                .OUTPUT_WIDTH(OUTPUT_WIDTH_C)
            ) i_pp_FDCT_stage_1(
                .clk(clk),
                .reset_n(reset_n),

                .in_ready(w_01_ready[i]),
                .in_valid(w_01_valid[i]),
                .in_last(w_01_last[i]),
                .in_data(i2c_array),

                .out_valid(w_12_valid[i]),
                .out_last(w_12_last[i]),
                .out_ready(w_12_ready[i]),
                .out_data(o2c_array)
            );

            for(j=0;j<8;++j) begin
                assign iqc[i*8+j] = o2c[i*8+j];
            end

            for(k=0;k<8;++k) begin
                assign iqc_array[k] = iqc[i*8+k];
                assign oqc[i*8+k] = oqc_array[k];
                assign q_array[k] = qs[i*8+k];
            end

            pp_quant80_stage #(
                .INPUT_WIDTH(OUTPUT_WIDTH_C),
                .FRACTIONAL_WIDTH(QUANT_FRACTIONAL_WIDTH),
                .OUTPUT_WIDTH(OUTPUT_WIDTH)
            ) i_pp_quant80_stage (
                .clk(clk),
                .reset_n(reset_n),

                .q(q_array),

                .in_ready(w_12_ready[i]),
                .in_valid(w_12_valid[i]),
                .in_last(w_12_last[i]),
                .in_data(iqc_array),

                .out_valid(w_2o_valid[i]),
                .out_last(w_2o_last[i]),
                .out_ready(out_ready),
                .out_data(oqc_array)
            );

            for(j=0;j<8;++j) begin
                assign out_data_minimal[(i*8+j)*OUTPUT_WIDTH+:OUTPUT_WIDTH] = oqc[j*8+i];
            end
        end

        for (m = 0; m < 64; ++m) begin
            assign out_data[m*NORMAL_OUTPUT_WIDTH +: NORMAL_OUTPUT_WIDTH] =
                {{(NORMAL_OUTPUT_WIDTH - OUTPUT_WIDTH){out_data_minimal[m*OUTPUT_WIDTH + OUTPUT_WIDTH - 1]}},
                out_data_minimal[m*OUTPUT_WIDTH +: OUTPUT_WIDTH]};
        end

    endgenerate

    assign out_valid = &w_2o_valid;
    assign out_last = &w_2o_last;

    always_ff @(posedge clk) begin
        if(qm_we == 1'b1) begin
            qs <= qm;
        end
    end

endmodule

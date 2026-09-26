`timescale 1ns / 1ps

module pp_idct_2d #(
    parameter int unsigned NORMAL_INPUT_WIDTH   = 16,
    parameter int unsigned INPUT_WIDTH          = 13,
    parameter int unsigned EXTRA                =  1,
    parameter int unsigned OUTPUT_WIDTH_C       = 13,
    parameter int unsigned OUTPUT_WIDTH_R       = 13,
    parameter int unsigned FRACTIONAL_WIDTH_C   =  9,
    parameter int unsigned FRACTIONAL_WIDTH_R   =  9,
    parameter int unsigned ROUND                =  1,
    parameter int unsigned OUTPUT_WIDTH         =  8
)(
    input  logic                                clk,
    input  logic                                reset_n,

    output logic                                in_ready,
    input  logic                                in_valid,
    input  logic                                in_last,
    input  logic [64*NORMAL_INPUT_WIDTH-1:0]    in_data,

    output logic                                out_valid,
    output logic                                out_last,
    output logic [64*OUTPUT_WIDTH-1:0]          out_data,
    input  logic                                out_ready,

    input logic                                 qm_we,
    input logic  [7:0]                          qm [0:63]
);

    logic [64*INPUT_WIDTH-1:0]         in_data_minimal;

    logic unsigned [8-1                    :0] qm0 [0:63];
    logic signed   [INPUT_WIDTH-1          :0] i1q [0:63];
    logic signed   [OUTPUT_WIDTH_C+EXTRA-1 :0] o1q [0:63];
    logic signed   [OUTPUT_WIDTH_C+EXTRA-1 :0] i2c [0:63];
    logic          [OUTPUT_WIDTH_R+EXTRA-1 :0] o2c [0:63];
    logic signed   [OUTPUT_WIDTH_R+EXTRA-1 :0] i3r [0:63];
    logic          [OUTPUT_WIDTH-1         :0] o3r [0:63];

    genvar i,j,k,m;

    logic [               7:0] ready_0_bus;

    logic [               7:0] w_01_valid;
    logic [               7:0] w_01_last;
    logic [               7:0] w_01_ready;

    logic [               7:0] w_12_valid;
    logic [               7:0] w_12_last;

    assign in_ready = &ready_0_bus;

    generate
        for(m=0;m<64;++m) begin
            //assign in_data_minimal[m*INPUT_WIDTH +: INPUT_WIDTH] = in_data[m*NORMAL_INPUT_WIDTH +: NORMAL_INPUT_WIDTH][INPUT_WIDTH-1:0];

            logic [NORMAL_INPUT_WIDTH-1:0] in_data_elem;
            assign in_data_elem = in_data[m*NORMAL_INPUT_WIDTH +: NORMAL_INPUT_WIDTH];
            assign in_data_minimal[m*INPUT_WIDTH +: INPUT_WIDTH] = in_data_elem[INPUT_WIDTH-1:0];
        end

        for(i=0;i<8;++i) begin
            
            logic signed   [OUTPUT_WIDTH_C+EXTRA-1 :0] i2c_array [0:7];
            logic          [OUTPUT_WIDTH_R+EXTRA-1 :0] o2c_array [0:7];
            logic signed   [OUTPUT_WIDTH_R+EXTRA-1 :0] i3r_array [0:7];
            logic          [OUTPUT_WIDTH-1         :0] o3r_array [0:7];

            

            for(j=0;j<8;++j) begin
                
                assign i1q[i*8+j] = in_data_minimal[(i*8+j)*INPUT_WIDTH+:INPUT_WIDTH];
                assign o1q[i*8+j] = (i1q[i*8+j] * $signed({1'b0, qm0[i*8+j]}))<<(OUTPUT_WIDTH_C-INPUT_WIDTH);
                assign i2c[i*8+j] = o1q[j*8+i];
            end

            for(k=0;k<8;++k) begin
                assign i2c_array[k] = i2c[i*8+k];
                assign o2c[i*8+k] = o2c_array[k];
            end

            pp_IDCT_stage #(
                .INPUT_WIDTH(OUTPUT_WIDTH_C+EXTRA),
                .OUTPUT_WIDTH(OUTPUT_WIDTH_R+EXTRA),
                .FRACTIONAL_WIDTH(FRACTIONAL_WIDTH_C),
                .ROUND(ROUND),
                .OUTPUT_UNSIGNED(0)

            ) i_pp_IDCT_stage_0(
                .clk(clk),
                .reset_n(reset_n),

                .in_ready(ready_0_bus[i]),
                .in_valid(in_valid),
                .in_last(in_last),
                .in_data(i2c_array),

                .out_valid(w_01_valid[i]),
                .out_last(w_01_last[i]),
                .out_data(o2c_array),
                .out_ready(w_01_ready[i])
            );

            for(j=0;j<8;++j) begin
                assign i3r[i*8+j] = o2c[j*8+i];
            end

            for(k=0;k<8;++k) begin
                assign i3r_array[k] = i3r[i*8+k];
                assign o3r[i*8+k]   = o3r_array[k];
            end

            pp_IDCT_stage #(
                .INPUT_WIDTH(OUTPUT_WIDTH_R+EXTRA),
                .OUTPUT_WIDTH(OUTPUT_WIDTH),
                .FRACTIONAL_WIDTH(FRACTIONAL_WIDTH_R),
                .ROUND(ROUND),
                .OUTPUT_UNSIGNED(1),
                .EXTRA(EXTRA)
            ) i_pp_IDCT_stage_1(
                .clk(clk),
                .reset_n(reset_n),

                .in_ready(w_01_ready[i]),
                .in_valid(w_01_valid[i]),
                .in_last(w_01_last[i]),
                .in_data(i3r_array),

                .out_valid(w_12_valid[i]),
                .out_last(w_12_last[i]),
                .out_data(o3r_array),
                .out_ready(out_ready)
            );

            for(j=0;j<8;++j) begin
                assign out_data[(i*8+j)*OUTPUT_WIDTH+:OUTPUT_WIDTH] = o3r[i*8+j];
            end
        end

    endgenerate

    assign out_valid = &w_12_valid;
    assign out_last  = &w_12_last;

    always_ff @(posedge clk) begin
        if(reset_n == 1'b0) begin
            qm0 <= '{default: 8'd1};
        end
        else if(qm_we == 1'b1) begin
            qm0 <= qm;
        end
    end
endmodule


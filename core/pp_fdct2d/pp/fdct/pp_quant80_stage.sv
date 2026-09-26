`timescale 1ns / 1ps


module pp_quant80_stage #(
    parameter int unsigned INPUT_WIDTH=16, 
    parameter int unsigned OUTPUT_WIDTH=8, 
    parameter int unsigned FRACTIONAL_WIDTH=48
)(
    input  logic                    clk,
    input  logic                    reset_n,

    input  logic [            7:0]  q [0:7],

    output logic                    in_ready,
    input  logic                    in_valid,
    input  logic                    in_last,
    input  logic signed [INPUT_WIDTH-1:0]  in_data [0:7],

    output logic                    out_valid,
    output logic                    out_last,
    output logic signed [OUTPUT_WIDTH-1:0] out_data [0:7],
    input  logic                    out_ready
);


    logic        valid_reg;
    logic        last_reg;

    logic signed [ INPUT_WIDTH-1:0]  q80_in_data [0:7];
    logic signed [OUTPUT_WIDTH-1:0]  q80_out_data [0:7];
    logic signed [OUTPUT_WIDTH-1:0]  q80_reg_out_data [0:7];

    assign q80_in_data = in_data;

    always_ff @(posedge clk or negedge reset_n) begin
        if(reset_n == 1'b0) begin
            valid_reg <= 1'b0;
            last_reg  <= 1'b0;
        end
        else begin
            if (out_ready) begin
                valid_reg <= in_valid & in_ready;
                if (in_valid & in_ready) begin  
                    q80_reg_out_data <= q80_out_data;
                    last_reg <=  in_last;
                end
                else begin last_reg <= 1'b0; end
            end else if (!valid_reg) begin
                if (in_valid) begin
                    valid_reg <= 1'b1;
                    q80_reg_out_data <= q80_out_data;
                    last_reg  <=  in_last;
                end
            end
        end
    end

    quant80 #(
        .INPUT_WIDTH(INPUT_WIDTH),
        .OUTPUT_WIDTH(OUTPUT_WIDTH),
        .FRACTIONAL_WIDTH(FRACTIONAL_WIDTH)
    ) i_QUANT80(
        .qi(q),
        .in(q80_in_data),
        .ou(q80_out_data)
    );

    assign in_ready             = !valid_reg | out_ready;
    assign out_data             = q80_reg_out_data;
    
    assign out_last             = last_reg;
    assign out_valid            = valid_reg;

endmodule

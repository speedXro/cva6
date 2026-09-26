`timescale 1ns / 1ps

module pp_FDCT_stage#(
    parameter int unsigned INPUT_WIDTH      = 8,        // i
    parameter int unsigned INPUT_UNSIGNED   = 1,
    parameter int unsigned FRACTIONAL_WIDTH = 13,       // f
    parameter int unsigned ROUND            = 1,
    parameter int unsigned OUTPUT_WIDTH     = 11,       // o
    parameter int unsigned DEBUG=1 //0 - no debug, 1 - display instance params, 2 - change events
)(
    input  logic                    clk,
    input  logic                    reset_n,

    output logic                    in_ready,
    input  logic                    in_valid,
    input  logic                    in_last,
    input  logic [INPUT_WIDTH-1:0]  in_data [0:7],

    output logic                    out_valid,
    output logic                    out_last,
    output logic signed [OUTPUT_WIDTH-1:0] out_data [0:7],
    input  logic                    out_ready
);

    logic        valid_reg;
    logic        last_reg;

    logic [ INPUT_WIDTH-1:0] fdct_in_data  [0:7];
    logic signed [OUTPUT_WIDTH-1:0] fdct_out_data [0:7];
    logic signed [OUTPUT_WIDTH-1:0] fdct_reg_out_data [0:7];

    assign fdct_in_data = in_data;

    always_ff @(posedge clk or negedge reset_n) begin
        if(reset_n == 1'b0) begin
            valid_reg <= 1'b0;
            last_reg  <= 1'b0;
        end
        else begin
            if (out_ready) begin
                valid_reg <= in_valid & in_ready;
                if (in_valid & in_ready) begin  
                    fdct_reg_out_data <= fdct_out_data;
                    last_reg <=  in_last;
                end
                else begin last_reg <= 1'b0; end
            end else if (!valid_reg) begin
                if (in_valid) begin
                    valid_reg <= 1'b1;
                    fdct_reg_out_data <= fdct_out_data;
                    last_reg  <=  in_last;
                end
            end
        end
    end

    FDCT #(
        .INPUT_WIDTH(INPUT_WIDTH),
        .INPUT_UNSIGNED(INPUT_UNSIGNED),
        .FRACTIONAL_WIDTH(FRACTIONAL_WIDTH),
        .ROUND(ROUND),
        .OUTPUT_WIDTH(OUTPUT_WIDTH),
        .DEBUG(DEBUG)
    ) i_FDCT_0(
        .ins(fdct_in_data),
        .outs(fdct_out_data)
    ); 

    assign in_ready             = !valid_reg | out_ready;

    assign out_data             = fdct_reg_out_data;
    
    assign out_last             = last_reg;
    assign out_valid            = valid_reg;

endmodule

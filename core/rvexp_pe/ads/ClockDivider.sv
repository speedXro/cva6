//`timescale 1ns / 1ps

module ClockDivider
(
    input  logic clk,
    input  logic reset_n,

    output logic clk_per_4,
    output logic clk_per_10
);

    logic [1:0] bcnt4;
    logic [3:0] bcnt10;

    always_ff @(posedge clk) begin
        if(reset_n == 1'b0) begin
            bcnt4 <= 2'd0;
        end
        else begin
            bcnt4 <= bcnt4 + 2'd1;
        end
        clk_per_4 <= (bcnt4 < 2'd2) ? (1'b1) : (1'b0);
    end


    always_ff @(posedge clk) begin
        if(reset_n == 1'b0) begin
            bcnt10 <= 4'd0;
        end
        else if(bcnt10 == 4'd7) begin //9
            bcnt10 <= 4'd0;
        end
        else begin
            bcnt10 <= bcnt10 + 4'd1;
        end
        clk_per_10 <= (bcnt10 < 4'd4) ? (1'b1) : (1'b0); //5
    end

endmodule

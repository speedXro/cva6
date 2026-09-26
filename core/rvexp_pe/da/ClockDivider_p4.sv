`timescale 1ns / 1ps

module ClockDivider_p4
(
    input  logic clk,
    input  logic reset_n,

    output logic clk_per_4
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

endmodule

//`timescale 1ns / 1ps

module DA_BB_Busy_CDC(
    input  logic clk,
    input  logic reset,

    input  logic da_busy,

    output logic DA_BB_Busy
);

    logic busy_old;
    logic busy_new;

    always_ff @(posedge clk) begin
        if(reset == 1'b1) begin
            busy_old <= 1'b0;
            busy_new <= 1'b0;
        end
        else begin
            busy_old <= busy_new;
            busy_new <= da_busy;
        end
    end

    always_ff @(posedge clk) begin
        if(reset == 1'b1) begin
            DA_BB_Busy <= 1'd0;
        end
        else if(busy_new != busy_old) begin
            DA_BB_Busy <= busy_new;
        end
    end

endmodule
//`timescale 1ns / 1ps

module AD_Timestamp(
    input  logic        clk,
    input  logic        reset,

    input  logic        reset_stats,
    input  logic        ad_broadcast_we,

    output logic [31:0] US_TS
);

    logic [31:0] cnt_us;
    logic [ 6:0] cnt_ns;

    //1000 ns Counter 
    always_ff @(posedge clk) begin
        if(reset == 1'b1) begin
            cnt_ns <= 7'd0;
        end
        else if(reset_stats == 1'b1 && ad_broadcast_we == 1'b1) begin
            cnt_ns <= 7'd0;
        end
        else if(cnt_ns <= 7'd98) begin
            cnt_ns <= cnt_ns + 7'd1;
        end
        else if(cnt_ns == 7'd99) begin
            cnt_ns <= 7'd0;
        end
    end

    //us Counter
    always_ff @(posedge clk) begin
        if(reset == 1'b1) begin
            cnt_us <= 32'd0;
        end
        else if(reset_stats == 1'b1 && ad_broadcast_we == 1'b1) begin
            cnt_us <= 32'd0;
        end
        else if(cnt_ns == 7'd99) begin
            cnt_us <= cnt_us + 32'd1;
        end
    end

    assign US_TS = cnt_us;

endmodule
`timescale 1ns / 1ps

module DA_FourWrite(
    input  logic        clk_100,
    input  logic        reset_n,

    output logic        idle,
    input  logic        commit_en,
    input  logic [63:0] commit_value,
    
    input  logic        one_idle,
    output logic        wr_en,
    output logic [15:0] wr_val
);

    logic [ 3:0] state;
    logic [63:0] value;

    always_ff @(posedge clk_100) begin
        if(reset_n == 1'b0) begin
            state <= 4'd0;
            wr_en <= 1'd0;
            idle  <= 1'b1;
        end

        else if(state == 4'd0 && commit_en == 1'b1) begin
            state <= 4'd1;
            value <= commit_value;
            idle  <= 1'b0;
        end 

        //Word 0
        else if(state == 4'd1 && one_idle == 1'b1) begin
            state <= 4'd2;
            wr_en <= 1'b1;
            wr_val <= value[63:48];
        end
        else if(state == 4'd2) begin
            state <= 4'd3;
            wr_en <= 1'b0;
        end
        else if(state == 4'd3 && one_idle == 1'b1) begin
            state <= 4'd4;
        end

        //Word 1
        else if(state == 4'd4 && one_idle == 1'b1) begin
            state <= 4'd5;
            wr_en <= 1'b1;
            wr_val <= value[47:32];
        end
        else if(state == 4'd5) begin
            state <= 4'd6;
            wr_en <= 1'b0;
        end
        else if(state == 4'd6 && one_idle == 1'b1) begin
            state <= 4'd7;
        end

        //Word 2
        else if(state == 4'd7 && one_idle == 1'b1) begin
            state <= 4'd8;
            wr_en <= 1'b1;
            wr_val <= value[31:16];
        end
        else if(state == 4'd8) begin
            state <= 4'd9;
            wr_en <= 1'b0;
        end
        else if(state == 4'd9 && one_idle == 1'b1) begin
            state <= 4'd10;
        end

        //Word 3
        else if(state == 4'd10 && one_idle == 1'b1) begin
            state <= 4'd11;
            wr_en <= 1'b1;
            wr_val <= value[15: 0];
        end
        else if(state == 4'd11) begin
            state <= 4'd12;
            wr_en <= 1'b0;
        end
        else if(state == 4'd12 && one_idle == 1'b1) begin
            state <= 4'd0;
            idle  <= 1'b1;
        end
    end

endmodule

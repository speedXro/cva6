`timescale 1ns / 1ps

module DA_OneWrite(
    input  logic        clk_100,
    input  logic        reset_n,

    output logic        idle,
    input  logic        wr_en,
    input  logic [15:0] wr_val,

    input  logic        da_100_working_busy,
    output logic        da_100_val_we,
    output logic [11:0] da_100_val_value    
);

    localparam TIMEOUT = 8'd200;

    logic [7:0] cnt; 
    logic [3:0] state;

    always_ff @(posedge clk_100) begin
        if(reset_n == 1'b0) begin
            state <= 4'd0;
            cnt   <= 8'd0;
            idle  <= 1'd1;
            da_100_val_we <= 1'd0;
        end

        else if(state == 4'd0 && wr_en == 1'b1 && da_100_working_busy == 1'b0) begin
            state <= 4'd1;
            idle  <= 1'b0;
            da_100_val_we    <= 1'b1;
            da_100_val_value <= wr_val[11:0];
        end
        else if(state == 4'd1) begin
            state <= 4'd2;
            da_100_val_we    <= 1'd0;
            cnt              <= 8'd1;
        end

        else if(state == 4'd2 && cnt < TIMEOUT) begin
            state <= 4'd2;
            cnt   <= cnt + 8'd1;
        end
        else if(state == 4'd2 && cnt == TIMEOUT) begin
            state <= 4'd0;
            idle  <= 1'b1;
        end
    end



endmodule

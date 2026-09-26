`timescale 1ns / 1ps

module DA_Configurator(
    input  logic         clk_100,
    input  logic         reset_n,

    input  logic         val_we,
    input  logic [11:0]  val,

    output logic [11:0]  da_config_val,


    input  logic         da_busy,
    output logic         busy
);

    logic [ 1:0] state;
    logic [11:0] value;

    always_ff @(posedge clk_100) begin
        if(reset_n == 1'b0) begin
            state         <= 2'd0;
            da_config_val <= 12'd0;
        end

        else if(state == 2'd0 && val_we == 1'b1) begin
            value <= val;
            state <= 2'd1;
        end

        else if(state == 2'd1 && da_busy == 1'b1) begin
            state <= 2'd1;
        end
        else if(state == 2'd1 && da_busy == 1'b0) begin
            da_config_val <= value;
            state         <= 2'd0;
        end
    end

    assign busy = da_busy;

endmodule

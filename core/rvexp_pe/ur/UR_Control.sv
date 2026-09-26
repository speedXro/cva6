`timescale 1ns / 1ps

module UR_Control(
    input  logic        clock,
    input  logic        reset_n,

    input  logic        o_Rx_DV,
    input  logic [7:0]  o_Rx_Byte,

    output logic        ur_stop,
    output logic        ur_ready,
    input  logic        ur_clear_stop,
    input  logic        ur_clear_ready,

    output logic [7:0]  ur_qf,
    output logic [1:0]  ur_pf,
    output logic        ur_ws       
);
    logic [7:0] w_pf;
    logic [7:0] w_ws;

    always_ff @(posedge clock) begin
        if(reset_n == 1'b0) begin
            ur_ready <= 1'd0;
            ur_stop  <= 1'd0;
            ur_qf    <= 8'd100;
            ur_pf    <= 2'd0;
            ur_ws    <= 1'd0;
        end
        else if(o_Rx_DV == 1'b1 && o_Rx_Byte == 8'h97) begin
            ur_ready <= 1'b1;
        end
        else if(o_Rx_DV == 1'b1 && o_Rx_Byte == 8'h98) begin
            ur_stop  <= 1'b1;
        end
        else if(o_Rx_DV == 1'b1 && (o_Rx_Byte >= 8'h32 && o_Rx_Byte <= 8'h95)) begin
            ur_qf    <= o_Rx_Byte - 8'h31;
        end
        else if(o_Rx_DV == 1'b1 && (o_Rx_Byte >= 8'h2E && o_Rx_Byte <= 8'h31)) begin
            ur_pf    <= w_pf[1:0];
        end
        else if(o_Rx_DV == 1'b1 && (o_Rx_Byte >= 8'h2C && o_Rx_Byte <= 8'h2D)) begin
            ur_ws    <= w_ws[1:0];
        end
        else if(ur_clear_stop == 1'b1) begin
            ur_stop <= 1'b0;
        end
        else if(ur_clear_ready == 1'b1) begin
            ur_ready <= 1'b0;
        end
    end

    assign w_pf = o_Rx_Byte - 8'h2E;
    assign w_ws = o_Rx_Byte - 8'h2C;

endmodule

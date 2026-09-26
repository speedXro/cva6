`timescale 1ns / 1ps

module AD_UART_Sender(
    input logic         clk,
    input logic         reset_n,
    
    input logic         i_result_commit,
    input logic  [63:0] i_result_data,

    output logic        o_ready,

    output logic        i_Tx_DV,
    output logic [ 7:0] i_Tx_Byte,
    input  logic        o_Tx_Active,
    input  logic        o_Tx_Done
);
    
    integer i;
    
    reg [ 2:0] state;
    reg [ 3:0] Tx_Cnt;
    reg [ 7:0] Tx_Buffer [0:8];
    
    always_ff @(posedge clk) begin
        if(reset_n == 1'b0) begin
            i_Tx_DV   <= 1'd0;
            i_Tx_Byte <= 8'd0;
            state     <= 3'd0;
            Tx_Cnt    <= 4'd0;
        end
        else if(state == 3'd0 && i_result_commit == 1'b1) begin
            Tx_Buffer[ 0] <= 8'h96;
            {
                Tx_Buffer[1], Tx_Buffer[2], Tx_Buffer[3], Tx_Buffer[4], 
                Tx_Buffer[5], Tx_Buffer[6], Tx_Buffer[7], Tx_Buffer[8]
            } <= i_result_data;
            
            state         <= 3'd2;
        end
        else if(state==3'd2 && o_Tx_Active==1'b0) begin
            i_Tx_DV       <= 1'b1;
            i_Tx_Byte     <= Tx_Buffer[Tx_Cnt];
            Tx_Cnt        <= Tx_Cnt+1;
            state         <= 3'd3;
        end
        else if(state==3'd3) begin
            i_Tx_DV       <= 1'b0;
            state         <= 3'd4;
        end
        else if(state==3'd4 && o_Tx_Active==1'b0 && o_Tx_Done==1'b0 && Tx_Cnt < 8) begin
            state         <= 3'd2;
        end
        else if(state==3'd4 && o_Tx_Active==1'b0 && o_Tx_Done==1'b0 && Tx_Cnt == 8) begin
            state         <= 3'd5;
        end
        else if(state==3'd5 && o_Tx_Active==1'b0) begin
            i_Tx_DV       <= 1'b1;
            i_Tx_Byte     <= Tx_Buffer[Tx_Cnt];
            state         <= 3'd6;
        end
        else if(state==3'd6) begin
            i_Tx_DV       <= 1'b0;
            state         <= 3'd7;
        end
        else if(state==3'd7 && o_Tx_Active==1'b0 && o_Tx_Done==1'b0) begin
            i_Tx_DV   <= 1'd0;
            i_Tx_Byte <= 8'd0;
            state     <= 3'd0;
            Tx_Cnt    <= 4'd0;
        end
    end

    assign o_ready = (state == 3'd0);
    
endmodule

`timescale 1 ns / 1 ps

module AXIS_Probes(
    input  logic clock,
    input  logic reset_n,
    
    input  logic m_valid,
    input  logic m_ready,
    input  logic m_last,

    input  logic s_valid,
    input  logic s_ready,
    input  logic s_last,


    output logic outter_start,
    output logic outter_stop,

    output logic inner_start,
    output logic inner_inc,
    output logic inner_stop,

    output logic mvalid_inc,
    output logic mlast_inc,
    output logic svalid_inc,
    output logic slast_inc
);

    always_ff @(posedge clock) begin
        if(reset_n == 1'b0) begin
            outter_start <= 1'd0;
            outter_stop  <= 1'd0;

            inner_start  <= 1'd0;
            inner_stop   <= 1'd0;

            mvalid_inc   <= 1'd0;
            mlast_inc    <= 1'd0;
            svalid_inc   <= 1'd0;
            slast_inc    <= 1'd0;
        end
        else begin
            outter_start <= (m_ready == 1'b1 && m_valid == 1'b1 && m_last == 1'b0) ? 1'b1 : 1'b0;
            outter_stop  <= (s_ready == 1'b1 && s_valid == 1'b1 && s_last == 1'b1) ? 1'b1 : 1'b0;

            inner_start  <= (m_ready == 1'b1 && m_valid == 1'b1 && m_last == 1'b0) ? 1'b1 : 1'b0;
            inner_inc    <= (s_ready == 1'b1 && s_valid == 1'b1 && s_last == 1'b0) ? 1'b1 : 1'b0;
            inner_stop   <= (s_ready == 1'b1 && s_valid == 1'b1 && s_last == 1'b1) ? 1'b1 : 1'b0;

            mvalid_inc   <= m_valid;
            mlast_inc    <= m_last;
            svalid_inc   <= s_valid;
            slast_inc    <= s_last;
        end
    end


endmodule

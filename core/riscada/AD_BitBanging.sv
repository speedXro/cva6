//`timescale 1ns / 1ps

module AD_BitBanging(
    input  logic        clk,
    input  logic        reset,

    output logic        ad_cs_n,
    output logic        ad_sclk,
    input  logic        ad_dout,

    output logic        ad_eoc,
    output logic [11:0] ad_value
);

    logic [ 1:0] state;
    logic [ 4:0] cnt_aq;

    logic        cs_n;
    logic [11:0] value;
    logic        eoc;

    logic [2:0]  cnt_ql;

    always_ff @(posedge clk) begin
        if(reset == 1'b1) begin
            state  <=  2'd0;
            cnt_aq <=  5'd0;
            cs_n   <=  1'b1;
            value  <= 12'd0;
            eoc    <=  1'd0;
            cnt_ql <=  3'd0; 
        end
        else if(state == 2'd0/* && ad_soc == 1'b1*/) begin
            cnt_aq <= 5'd16;
            cnt_ql <= 3'd1; //7 
            state  <= 2'd1;
        end
        else if(state == 2'd1 && cnt_aq == 5'd16) begin
            cs_n   <= 1'b0;
            cnt_aq <= cnt_aq - 5'd1;
            state  <= 2'd1;
        end
        else if(state == 2'd1 && (cnt_aq >= 5'd13 && cnt_aq <= 5'd15)) begin
            cs_n   <= 1'b0;
            cnt_aq <= cnt_aq - 5'd1;
            state  <= 2'd1;
        end
        else if(state == 2'd1 && (cnt_aq >= 5'd1 && cnt_aq <= 5'd12)) begin
            cs_n   <= 1'b0;
            cnt_aq <= cnt_aq - 5'd1;
            value  <= {value[10:0], ad_dout};
            eoc    <= (cnt_aq == 5'd1) ? 1'b1 : 1'b0;
            state  <= 2'd1;
        end
        else if(state == 2'd1 && cnt_aq == 5'd0) begin
            state  <=  2'd2;
            cnt_aq <=  5'd0;
            cs_n   <=  1'b1;
            value  <= 12'd0;
            eoc    <=  1'd0;
        end
        else if(state == 2'd2 && cnt_ql > 3'd0) begin
            cnt_ql <= cnt_ql - 3'd1;
            state  <= 2'd2;
        end
        else if(state == 2'd2 && cnt_ql == 3'd0) begin
            state  <= 2'd0;
        end
    end

    always_comb begin
        ad_cs_n  = cs_n;
        ad_sclk  = clk & (~cs_n);
        ad_eoc   = eoc;
        ad_value = value;      
    end

endmodule
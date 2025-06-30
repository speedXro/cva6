//`timescale 1ns / 1ps

module AD_Values_CDC(
    input  logic        clk,
    input  logic        reset,

    input  logic        ad_eoc,
    input  logic [11:0] ad_value,

    output logic        AD_Eofc,
    output logic [11:0] AD_Val
);

    logic ad_eoc_old;
    logic ad_eoc_new;
    logic eoc;

    logic [11:0] ad_value_new;

    always_ff @(posedge clk) begin
        if(reset == 1'b1) begin
            ad_eoc_old   <=  1'b0;
            ad_eoc_new   <=  1'b0;
            ad_value_new <= 12'd0;
        end
        else begin
            ad_eoc_old   <= ad_eoc_new;
            ad_eoc_new   <= ad_eoc;
            ad_value_new <= ad_value;
        end
    end

    always_ff @(posedge clk) begin
        if(reset == 1'b1) begin
            AD_Val <= 12'd0;
            eoc    <= 1'b0;
        end
        else if((ad_eoc_new != ad_eoc_old) && (ad_eoc_new == 1'b1)) begin
            AD_Val <= ad_value_new;
            eoc    <= 1'b1;
        end
        else if(eoc == 1'b1) begin
            eoc    <= 1'b0;
        end
    end

    assign AD_Eofc = eoc;

endmodule
//`timescale 1ns / 1ps

module AD_SigCon(
    input  logic        clk,

    input  logic        reset,

    input  logic        ADC_Threshold_we,
    input  logic [11:0] ADC_Threshold_value,

    input  logic        ADC_Hysteresis_we,
    input  logic [11:0] ADC_Hysteresis_value,

    input  logic [11:0] ADC_Value_instant,

    output logic        ad_digitized,

    output logic [11:0] ADC_Threshold_out,
    output logic [11:0] ADC_Hysteresis_out

);

    localparam HYST_INIT = 12'd1;

    logic [11:0] hystersis;
    logic [11:0] threshold;

    always_ff @(posedge clk) begin
        if(reset == 1'b1) begin
            hystersis <= HYST_INIT;
        end
        else if(ADC_Hysteresis_we == 1'b1) begin
            hystersis <= ADC_Hysteresis_value;
        end
    end

    always_ff @(posedge clk) begin
        if(reset == 1'b1) begin
            threshold <= HYST_INIT;
        end
        else if(ADC_Threshold_we == 1'b1) begin
            threshold <= ADC_Threshold_value;
        end
    end

    always_ff @(posedge clk) begin
        if(reset == 1'b1) begin
            ad_digitized <= 1'b0;
        end
        else if(ADC_Value_instant > threshold + hystersis) begin
            ad_digitized <= 1'b1;
        end
        else if(ADC_Value_instant < threshold - hystersis) begin
            ad_digitized <= 1'b0;
        end
    end 

    assign ADC_Threshold_out  = threshold;
    assign ADC_Hysteresis_out = hystersis;

endmodule
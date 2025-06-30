//`timescale 1ns / 1ps

module AD_Block #(
    parameter mod_addr = 8'd0
)(
    input  logic        clk_100,
    input  logic        clk_10,

    input  logic        reset,

    input  logic [ 7:0] addr,

    input  logic        ad_broadcast_we,

    input  logic        reset_stats,

    input  logic        ADC_Threshold_we,
    input  logic [11:0] ADC_Threshold_value,

    input  logic        ADC_Hysteresis_we,
    input  logic [11:0] ADC_Hysteresis_value,

    input  logic [31:0] US_TS,    

    output logic        ad_cs_n,
    output logic        ad_sclk,
    input  logic        ad_dout,
    output logic        ad_digitized, 

    output logic [11:0] ADC_Val,
    output logic [11:0] ADC_Otd,
    output logic [11:0] ADC_Sma,
    output logic [11:0] ADC_Min,
    output logic [11:0] ADC_Max,

    output logic [11:0] ADC_Threshold,
    output logic [11:0] ADC_Hysteresis
);

    logic        ad_eoc;
    logic [11:0] ad_value;

    logic        AD_Eofc;
    logic [11:0] AD_Val;

    logic        enable;

    logic [11:0] w_ADC_Val;

    logic        w_ad_digitized;

    AD_BitBanging AD_BitBanging_inst(
        .clk(clk_10),
        .reset(reset),

        .ad_cs_n(ad_cs_n),
        .ad_sclk(ad_sclk),
        .ad_dout(ad_dout),

        .ad_eoc(ad_eoc),
        .ad_value(ad_value)
    );

    AD_Values_CDC AD_Values_CDC_inst(
        .clk(clk_100),
        .reset(reset),

        .ad_eoc(ad_eoc),
        .ad_value(ad_value),

        .AD_Eofc(AD_Eofc),
        .AD_Val(AD_Val)        
    );

    AD_Meas AD_Meas_inst(
        .clk(clk_100),
        .reset(reset),

        .reset_stats(reset_stats & enable),

        .US_TS(US_TS),

        .ad_digitized(w_ad_digitized),

        .AD_Eofc(AD_Eofc),
        .AD_Val(AD_Val),

        .ADC_Val(w_ADC_Val),
        .ADC_Otd(ADC_Otd),
        .ADC_Sma(ADC_Sma),
        .ADC_Min(ADC_Min),
        .ADC_Max(ADC_Max)
    );

    AD_SigCon AD_SigCon_inst(
        .clk(clk_100),
        .reset(reset),

        .ADC_Threshold_we(ADC_Threshold_we & enable),
        .ADC_Threshold_value(ADC_Threshold_value),

        .ADC_Hysteresis_we(ADC_Hysteresis_we & enable),
        .ADC_Hysteresis_value(ADC_Hysteresis_value),

        .ADC_Value_instant(w_ADC_Val),

        .ad_digitized(w_ad_digitized),

        .ADC_Threshold_out(ADC_Threshold),
        .ADC_Hysteresis_out(ADC_Hysteresis)
    );



    assign enable = ((mod_addr == addr) || (ad_broadcast_we == 1'b1)) ? 1'b1 : 1'b0;

    assign ADC_Val = w_ADC_Val;

    assign ad_digitized = w_ad_digitized; 
endmodule
//`timescale 1ns / 1ps

module AD_Extension #(
    parameter N_AD = 2
)(
    input  logic            clk_100,
    input  logic            clk_10,

    input  logic            reset,

    input  logic            ad_enb,
    input  logic [     2:0] ad_fct3,
    input  logic [     6:0] ad_fct7,
    input  logic [    63:0] ad_op1,
    input  logic [    63:0] ad_op2,

    output logic            ad_rd_we,
    output logic [    63:0] ad_rd,

    output logic [N_AD-1:0] bus_ad_cs_n,
    output logic [N_AD-1:0] bus_ad_sclk,
    input  logic [N_AD-1:0] bus_ad_dout,
    output logic [N_AD-1:0] bus_ad_digitized
);

    logic [     7:0] addr;

    logic            ad_broadcast_we;

    logic            reset_stats;

    logic            ADC_Threshold_we;
    logic [11:0]     ADC_Threshold_value;

    logic            ADC_Hysteresis_we;
    logic [11:0]     ADC_Hysteresis_value; 


    logic [    11:0] ADC_Val;
    logic [    11:0] ADC_Otd;
    logic [    11:0] ADC_Sma;
    logic [    11:0] ADC_Min;
    logic [    11:0] ADC_Max;

    logic [    11:0] ADC_Threshold;
    logic [    11:0] ADC_Hysteresis;

    logic [    31:0] US_TS;

    logic [N_AD-1:0] w_bus_ad_digitized;

    AD_Controller #(.N_AD(N_AD)) AD_Controller_inst(
        .clk_100(clk_100),
        .reset(reset),

        .ad_enb(ad_enb),
        .ad_fct3(ad_fct3),
        .ad_fct7(ad_fct7),
        .ad_op1(ad_op1),
        .ad_op2(ad_op2),

        .addr(addr),

        .ad_broadcast_we(ad_broadcast_we),
        
        .reset_stats(reset_stats),

        .ADC_Threshold_we(ADC_Threshold_we),
        .ADC_Threshold_value(ADC_Threshold_value),

        .ADC_Hysteresis_we(ADC_Hysteresis_we),
        .ADC_Hysteresis_value(ADC_Hysteresis_value),

        .US_TS(US_TS),

        .ADC_Val(ADC_Val),
        .ADC_Otd(ADC_Otd),
        .ADC_Sma(ADC_Sma),
        .ADC_Min(ADC_Min),
        .ADC_Max(ADC_Max),

        .ADC_Threshold(ADC_Threshold),
        .ADC_Hysteresis(ADC_Hysteresis),

        .ad_rd_we(ad_rd_we),
        .ad_rd(ad_rd)
    );

    AD_Timestamp AD_Timestamp_inst(
        .clk(clk_100),
        .reset(reset),

        .reset_stats(reset_stats),
        .ad_broadcast_we(ad_broadcast_we),

        .US_TS(US_TS)
    );

    AD_Blocks #(.N_AD(N_AD)) AD_Blocks_inst(
        .clk_100(clk_100),
        .clk_10(clk_10),

        .reset(reset),

        .addr(addr),

        .ad_broadcast_we(ad_broadcast_we),
        
        .reset_stats(reset_stats),

        .ADC_Threshold_we(ADC_Threshold_we),
        .ADC_Threshold_value(ADC_Threshold_value),

        .ADC_Hysteresis_we(ADC_Hysteresis_we),
        .ADC_Hysteresis_value(ADC_Hysteresis_value),

        .US_TS(US_TS),

        .bus_ad_cs_n(bus_ad_cs_n),
        .bus_ad_sclk(bus_ad_sclk),
        .bus_ad_dout(bus_ad_dout),
        .bus_ad_digitized(w_bus_ad_digitized),

        .ADC_Val(ADC_Val),
        .ADC_Otd(ADC_Otd),
        .ADC_Sma(ADC_Sma),
        .ADC_Min(ADC_Min),
        .ADC_Max(ADC_Max),

        .ADC_Threshold(ADC_Threshold),
        .ADC_Hysteresis(ADC_Hysteresis)
    );

    assign bus_ad_digitized = w_bus_ad_digitized;

endmodule
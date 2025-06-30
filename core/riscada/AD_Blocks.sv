//`timescale 1ns / 1ps

module AD_Blocks #(
    parameter N_AD = 2
)(
    input  logic            clk_100,
    input  logic            clk_10,

    input  logic            reset,

    input  logic [     7:0] addr,

    input  logic            ad_broadcast_we,

    input  logic            reset_stats,

    input  logic            ADC_Threshold_we,
    input  logic [11:0]     ADC_Threshold_value,

    input  logic            ADC_Hysteresis_we,
    input  logic [11:0]     ADC_Hysteresis_value, 

    input  logic [31:0]     US_TS,

    output logic [N_AD-1:0] bus_ad_cs_n,
    output logic [N_AD-1:0] bus_ad_sclk,
    input  logic [N_AD-1:0] bus_ad_dout,
    output logic [N_AD-1:0] bus_ad_digitized,

    output logic [    11:0] ADC_Val,
    output logic [    11:0] ADC_Otd,
    output logic [    11:0] ADC_Sma,
    output logic [    11:0] ADC_Min,
    output logic [    11:0] ADC_Max,

    output logic [    11:0] ADC_Threshold,
    output logic [    11:0] ADC_Hysteresis
);

    logic [11:0] ADC_Val_out_val        [0:N_AD-1];
    logic [11:0] ADC_Otd_out_val        [0:N_AD-1];
    logic [11:0] ADC_Sma_out_val        [0:N_AD-1];
    logic [11:0] ADC_Min_out_val        [0:N_AD-1];
    logic [11:0] ADC_Max_out_val        [0:N_AD-1];
    
    logic [11:0] ADC_Threshold_out_val  [0:N_AD-1];
    logic [11:0] ADC_Hysteresis_out_val [0:N_AD-1];

    genvar i;

    generate
        for(i=0;i<N_AD;i=i+1) begin
            AD_Block #(.mod_addr(i)) AD_Block_inst(
                .clk_100(clk_100),
                .clk_10(clk_10),

                .reset(reset),

                .addr(addr),

                .ad_broadcast_we(ad_broadcast_we),

                .reset_stats(reset_stats),

                .US_TS(US_TS),

                .ADC_Threshold_we(ADC_Threshold_we),
                .ADC_Threshold_value(ADC_Threshold_value),

                .ADC_Hysteresis_we(ADC_Hysteresis_we),
                .ADC_Hysteresis_value(ADC_Hysteresis_value),

                .ad_cs_n(bus_ad_cs_n[i]),
                .ad_sclk(bus_ad_sclk[i]),
                .ad_dout(bus_ad_dout[i]),
                .ad_digitized(bus_ad_digitized[i]),

                .ADC_Val(ADC_Val_out_val[i]),
                .ADC_Otd(ADC_Otd_out_val[i]),
                .ADC_Sma(ADC_Sma_out_val[i]),
                .ADC_Min(ADC_Min_out_val[i]),
                .ADC_Max(ADC_Max_out_val[i]),

                .ADC_Threshold(ADC_Threshold_out_val[i]),
                .ADC_Hysteresis(ADC_Hysteresis_out_val[i])
            );
        end
    endgenerate

    assign ADC_Val = ADC_Val_out_val[addr];
    assign ADC_Otd = ADC_Otd_out_val[addr];
    assign ADC_Sma = ADC_Sma_out_val[addr];
    assign ADC_Min = ADC_Min_out_val[addr];
    assign ADC_Max = ADC_Max_out_val[addr];

    assign ADC_Threshold  = ADC_Threshold_out_val[addr];
    assign ADC_Hysteresis = ADC_Hysteresis_out_val[addr];
    
endmodule
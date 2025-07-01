//`timescale 1ns / 1ps

module AD_Meas(

    input  logic        clk,
    input  logic        reset,

    input  logic        reset_stats,

    input  logic [31:0] US_TS,

    input  logic        ad_digitized,

    input  logic        AD_Eofc,
    input  logic [11:0] AD_Val,

    output logic [11:0] ADC_Val,
    output logic [11:0] ADC_Otd,
    output logic [11:0] ADC_Sma,
    output logic [11:0] ADC_Min,
    output logic [11:0] ADC_Max
);

    logic [11:0] ADC_Sma_Vals [0:15];
    logic [15:0] ADC_Sma_Sum;

    //Saving latest ADC 12-bit value
    always_ff @(posedge clk) begin
        if(reset == 1'b1) begin
            ADC_Val <= 12'd0;
        end
        else if(AD_Eofc == 1'b1) begin
            ADC_Val <= AD_Val;
        end
    end

    //Simple Moving Average
    always_ff @(posedge clk) begin
        if(reset == 1'b1) begin
            ADC_Sma_Sum      <= 16'd0;
            ADC_Sma          <= 12'd0;
        end
        else if(AD_Eofc == 1'b1) begin
            ADC_Sma_Sum      <= ADC_Sma_Sum + AD_Val - ADC_Sma_Vals[15];
            
            ADC_Sma_Vals[ 0] <= AD_Val;
            ADC_Sma_Vals[ 1] <= ADC_Sma_Vals[ 0];
            ADC_Sma_Vals[ 2] <= ADC_Sma_Vals[ 1];
            ADC_Sma_Vals[ 3] <= ADC_Sma_Vals[ 2];
            ADC_Sma_Vals[ 4] <= ADC_Sma_Vals[ 3];
            ADC_Sma_Vals[ 5] <= ADC_Sma_Vals[ 4];
            ADC_Sma_Vals[ 6] <= ADC_Sma_Vals[ 5];
            ADC_Sma_Vals[ 7] <= ADC_Sma_Vals[ 6];
            ADC_Sma_Vals[ 8] <= ADC_Sma_Vals[ 7];
            ADC_Sma_Vals[ 9] <= ADC_Sma_Vals[ 8];
            ADC_Sma_Vals[10] <= ADC_Sma_Vals[ 9];
            ADC_Sma_Vals[11] <= ADC_Sma_Vals[10];
            ADC_Sma_Vals[12] <= ADC_Sma_Vals[11];
            ADC_Sma_Vals[13] <= ADC_Sma_Vals[12];
            ADC_Sma_Vals[14] <= ADC_Sma_Vals[13];
            ADC_Sma_Vals[15] <= ADC_Sma_Vals[14];
            
            ADC_Sma          <= ADC_Sma_Sum[15:4];
        end
    end

    //Minimum
    always_ff @(posedge clk) begin
        if(reset == 1'b1) begin
            ADC_Min <= 12'hFFF;
        end
        else if(reset_stats == 1'b1) begin
            ADC_Min <= 12'hFFF;
        end
        else if(AD_Eofc == 1'b1 && AD_Val < ADC_Min) begin
            ADC_Min <= AD_Val;
        end 
    end

    //Maximum
    always_ff @(posedge clk) begin
        if(reset == 1'b1) begin
            ADC_Max <= 12'h000;
        end
        else if(reset_stats == 1'b1) begin
            ADC_Max <= 12'h000;
        end
        else if(AD_Eofc == 1'b1 && AD_Val > ADC_Max) begin
            ADC_Max <= AD_Val;
        end 
    end

    //Measuring Over-Threshold Duration
    logic        ad_digitized_old;

    logic [31:0] over_ts_start_ts;
    logic [31:0] over_ts_duration;

    always @(posedge clk) begin
        if(reset == 1'b0) begin
            ad_digitized_old = 1'b0;
        end
        else begin
            ad_digitized_old = ad_digitized;
        end
    end

    always @(posedge clk) begin
        if(reset == 1'b1) begin
            over_ts_start_ts <= 32'd0;
            over_ts_duration <= 32'd0;
            ADC_Otd          <= 12'd0;
        end
        else if(reset_stats == 1'b1) begin
            over_ts_start_ts <= 32'd0;
            over_ts_duration <= 32'd0;
            ADC_Otd          <= 12'd0;
        end

        else if(over_ts_duration != 32'd0) begin
            ADC_Otd          <= over_ts_duration[11:0];
            over_ts_duration <= 32'd0;
        end

        else if(ad_digitized_old == 1'b0 && ad_digitized == 1'b1) begin
            ADC_Otd          <= 12'd0;
            over_ts_start_ts <= US_TS;
        end
        else if(ad_digitized_old == 1'b1 && ad_digitized == 1'b0 && ((US_TS - over_ts_start_ts) <= 32'd4094)) begin
            over_ts_start_ts <= 32'd0;
            over_ts_duration <= US_TS - over_ts_start_ts;
        end
        else if(ad_digitized_old == 1'b1 && ad_digitized == 1'b0 && ((US_TS - over_ts_start_ts) > 32'd4094)) begin
            over_ts_start_ts <= 32'd0;
            over_ts_duration <= 32'd4095;
        end
    end

endmodule


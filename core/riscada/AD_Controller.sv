//`timescale 1ns / 1ps

module AD_Controller #(
    parameter N_AD = 2
)(
    input  logic         clk_100,
    input  logic         reset,

    input  logic         ad_enb,
    input  logic [  2:0] ad_fct3,
    input  logic [  6:0] ad_fct7,
    input  logic [ 63:0] ad_op1,
    input  logic [ 63:0] ad_op2,

    output logic [  7:0] addr,


    output logic         ad_broadcast_we,

    output logic         reset_stats,

    output logic         ADC_Threshold_we,
    output logic [11:0]  ADC_Threshold_value,

    output logic         ADC_Hysteresis_we,
    output logic [11:0]  ADC_Hysteresis_value,

    input  logic [31:0]  US_TS,

    input  logic [11:0]  ADC_Val,
    input  logic [11:0]  ADC_Otd,
    input  logic [11:0]  ADC_Sma,
    input  logic [11:0]  ADC_Min,
    input  logic [11:0]  ADC_Max,

    input  logic [11:0] ADC_Threshold,
    input  logic [11:0] ADC_Hysteresis,

    output logic        ad_rd_we,
    output logic [63:0] ad_rd  
);

    localparam FUNC_SET_STATISTICS_RESET                = 7'b10_1_1000;
    localparam FUNC_SET_SC_THRESHOLD_AND_HYSTERESIS     = 7'b10_1_1001;

    localparam FUNC_GET_ALL_STATS                       = 7'b11_1_1000;
    localparam FUNC_GET_SC_THRESHOLD_AND_HYSTERESIS     = 7'b11_1_1001;
    localparam FUNC_GET_VAL                             = 7'b11_1_1011;
    localparam FUNC_GET_OTD                             = 7'b11_1_1100;
    localparam FUNC_GET_SMA                             = 7'b11_1_1101;
    localparam FUNC_GET_MIN                             = 7'b11_1_1110;
    localparam FUNC_GET_MAX                             = 7'b11_1_1111;

    localparam SRC_GET_ALL_STATS                        = FUNC_GET_ALL_STATS[3:0];
    localparam SRC_GET_SC_THRESHOLD_AND_HYSTERESIS      = FUNC_GET_SC_THRESHOLD_AND_HYSTERESIS[3:0];
    localparam SRC_GET_VAL                              = FUNC_GET_VAL[3:0];
    localparam SRC_GET_OTD                              = FUNC_GET_OTD[3:0];
    localparam SRC_GET_SMA                              = FUNC_GET_SMA[3:0];
    localparam SRC_GET_MIN                              = FUNC_GET_MIN[3:0];
    localparam SRC_GET_MAX                              = FUNC_GET_MAX[3:0];

    logic [1:0] state;
    logic [3:0] data_src;

    logic f3_broadcast;

    assign f3_broadcast = ad_fct3[2];
    
    always_ff @(posedge clk_100) begin
        if(reset == 1'b1) begin
            state                <=   2'd0;
            
            data_src             <=   4'd0;

            addr                 <=   8'd0;

            ad_broadcast_we      <=   1'd0;

            reset_stats          <=   1'd0;

            ADC_Threshold_we     <=   1'd0;
            ADC_Threshold_value  <=  12'd0;

            ADC_Hysteresis_we    <=   1'd0;
            ADC_Hysteresis_value <=  12'd0;

            ad_rd_we             <=   1'd0;
            ad_rd                <=  64'd0;
        end

        //Resetting statistics
        else if(state == 2'd0 && ad_enb == 1'b1 && f3_broadcast == 1'b0 && ad_fct7 == FUNC_SET_STATISTICS_RESET) begin
            addr                 <= {ad_op1[63:60], ad_op2[63:60]};
            ad_broadcast_we      <= 1'b0;
            reset_stats          <= 1'b1;
            ad_rd_we             <= 1'b1;
            ad_rd                <= ad_op1 ^ ad_op2;
            state                <= 2'd3;
        end
        else if(state == 2'd0 && ad_enb == 1'b1 && f3_broadcast == 1'b1 && ad_fct7 == FUNC_SET_STATISTICS_RESET) begin
            addr                 <= 8'd0;
            ad_broadcast_we      <= 1'b0;
            reset_stats          <= 1'b1;
            ad_rd_we             <= 1'b1;
            ad_rd                <= ad_op1 ^ ad_op2;
            state                <= 2'd3;
        end

        //Set Threshold and Hysteresis
        else if(state == 2'd0 && ad_enb == 1'b1 && f3_broadcast == 1'b0 && ad_fct7 == FUNC_SET_SC_THRESHOLD_AND_HYSTERESIS) begin
            addr                 <= {ad_op1[63:60], ad_op2[63:60]};
            ad_broadcast_we      <= 1'b0;
            ADC_Threshold_we     <=  1'b1;
            ADC_Threshold_value  <= ad_op1[11:0];
            ADC_Hysteresis_we    <=  1'b1;
            ADC_Hysteresis_value <= ad_op2[11:0];
            ad_rd_we             <= 1'b1;
            ad_rd                <= ad_op1 ^ ad_op2;
            state                <= 2'd3;
        end
        else if(state == 2'd0 && ad_enb == 1'b1 && f3_broadcast == 1'b1 && ad_fct7 == FUNC_SET_SC_THRESHOLD_AND_HYSTERESIS) begin
            addr                 <= {ad_op1[63:60], ad_op2[63:60]};
            ad_broadcast_we      <= 1'b0;
            ADC_Threshold_we     <=  1'b1;
            ADC_Threshold_value  <= ad_op1[11:0];
            ADC_Hysteresis_we    <=  1'b1;
            ADC_Hysteresis_value <= ad_op2[11:0];
            ad_rd_we             <= 1'b1;
            ad_rd                <= ad_op1 ^ ad_op2;
            state                <= 2'd3;
        end

        //Get Values
        else if(state == 2'd0 && ad_enb == 1'b1 && f3_broadcast == 1'b0 && ad_fct7[6:4] == 3'b111) begin
            addr                 <= {ad_op1[63:60], ad_op2[63:60]};
            data_src             <= ad_fct7[3:0];
            state                <= 2'd1;
        end

        else if(state == 2'd1 && data_src == SRC_GET_ALL_STATS) begin
            ad_rd_we             <= 1'b1;
            ad_rd                <= {4'd0, ADC_Min, ADC_Max, ADC_Sma, ADC_Otd, ADC_Val};
            state                <= 2'd3;
        end
        else if(state == 2'd1 && data_src == SRC_GET_SC_THRESHOLD_AND_HYSTERESIS) begin
            ad_rd_we             <= 1'b1;
            ad_rd                <= {40'd0, ADC_Threshold, ADC_Hysteresis};
            state                <= 2'd3;
        end
        else if(state == 2'd1 && data_src == SRC_GET_VAL) begin
            ad_rd_we             <= 1'b1;
            ad_rd                <= {US_TS, 20'd0, ADC_Val};
            state                <= 2'd3;
        end
        else if(state == 2'd1 && data_src == SRC_GET_OTD) begin
            ad_rd_we             <= 1'b1;
            ad_rd                <= {US_TS, 20'd0, ADC_Otd};
            state                <= 2'd3;
        end
        else if(state == 2'd1 && data_src == SRC_GET_SMA) begin
            ad_rd_we             <= 1'b1;
            ad_rd                <= {US_TS, 20'd0, ADC_Sma};
            state                <= 2'd3;
        end
        else if(state == 2'd1 && data_src == SRC_GET_MIN) begin
            ad_rd_we             <= 1'b1;
            ad_rd                <= {US_TS, 20'd0, ADC_Min};
            state                <= 2'd3;
        end
        else if(state == 2'd1 && data_src == SRC_GET_MAX) begin
            ad_rd_we             <= 1'b1;
            ad_rd                <= {US_TS, 20'd0, ADC_Max};
            state                <= 2'd3;
        end

        else if(state == 2'd3) begin
            state                <=   2'd0;
            
            data_src             <=   4'd0;

            addr                 <=   8'd0;

            ad_broadcast_we      <=   1'd0;

            reset_stats          <=   1'd0;

            ADC_Threshold_we     <=   1'd0;
            ADC_Threshold_value  <=  12'd0;

            ADC_Hysteresis_we    <=   1'd0;
            ADC_Hysteresis_value <=  12'd0;

            ad_rd_we             <=   1'd0;
            ad_rd                <=  64'd0;
        end

    end
endmodule
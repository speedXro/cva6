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

//https://github.com/ozan956/fpga-fir/blob/main/CSE3017_PROJECT.srcs/sources_1/new/FIR_Filter_Design.v
//https://github.com/abdallahhalfa/Weighted-Moving-Average-Filter/tree/main
//https://pdf.sciencedirectassets.com/282073/1-s2.0-S2212017312X00057/1-s2.0-S2212017312003490/main.pdf?X-Amz-Security-Token=IQoJb3JpZ2luX2VjEOj%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCXVzLWVhc3QtMSJGMEQCIDm1XnxvbTmglfP%2BDUy6VBYM4g%2F22HckAtvp5vEOfIfjAiB2vpxRFjiK5fPCSfFYc5%2FrteRsKN1MqxKUW4UvlD0yMSqzBQgQEAUaDDA1OTAwMzU0Njg2NSIMzul35KFTFsdk70SDKpAFCTx%2BAsopfG55OH3Maivk5TDvfz3Pcn6GlFI36IDbg4f2C76gbGHQssvT85TIYupmnrFNGOOkevZN6qKJEsqodaaCsIGe10D4igLdLamHT8yjlO1hAvLoeLeaiiHp02Al1SI3KVtzrUfkBDCCu%2FcOKp4PsOZXCuCFDHCzSQmZPBqdJmOcWoLCt4b1UgzQlvE%2F2JeZlgb03Wj8sDYxkLKY%2F%2FBr8zycyyCM1EzFD%2BCIKvXLpTrnV0Kjua8Sh3gKyzk8TUrIRVW95me7VT7BiaPpHWtWxNK7neMkygdWM8nDT7MwZrkG8iNR6mBMnlFEMwwt%2F6r6O8%2FwipFIumAU2RWFlqB3kjU9bjMf7y0MN5IPI%2F%2FzDggUB0nYWhpIn2zjaHl3g%2BK%2FlgC98v%2FG9YSt33ej%2FAcFTivH1IMnBhGUdzXMHuzvG7dydf8658g%2BQjM%2B%2F8V2fu5vCihN7%2FPAC%2FMWNJUeF0B5q0NIn0hQFFWCb4KfbDKbqcyKD43zaFx%2ByRvbb2eB8WmwXTIlJtiX%2BtkjqF0TEIT02gBSR98hIHu52sbPlkTbj6SM4GHi1YK2HOWveInsRxEnsB7yBrhkLdgBeciQg2nJl5Q%2BbF3eM%2FJqSZi8HAN4WpG1xK6CArxGGq5zrR%2BDMIDfh%2BPLqU2Sfnvho3Ht5vZJm6PKYYQaDltcjuwhHbwJLk5cuvKn0qwwU2NrqsFOYGSUkBurfJ5%2FNIKt94eRJ9tCSKUUKt1d%2B15AfQfr6Zk5PimVWLLfsOyJuZlCWkipwV03Rkl6QFfLMOppTUNohexEzDYXqcaNX9Q%2BM%2FkZam3bA4I%2FKUZ1zcmpdwtTDbwRPmDzkg8pJIYwHn64t1Cbl5QTZvI%2BiPecBajt5jqx%2BC0wpLa2vQY6sgGoNmFYJIhKBr6AVEjCH3I5sbjF8Jup%2BJM0Ot%2F71v119ycOlo%2F9fQ5BIiDKo4iowqxuZXC6F%2BH51BEDTE6BlS0m0gAa1Vz03I%2FrVQLh7mHZb01%2F8spsDqJXhki%2Bp2BYTynsipozjnhBYikFtI3S7IWDBxWf5B1jUDrJl3rwR9s%2Be9StNGUlKfgYJqvzTI64D7bpVOJGQ%2FsNjrilYteRlM3urM0bP%2Fi4KzV3fGxYmJDjEjFn&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20250213T085008Z&X-Amz-SignedHeaders=host&X-Amz-Expires=300&X-Amz-Credential=ASIAQ3PHCVTYZJDPY2Q6%2F20250213%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Signature=51467713c0caa4036a3618a875510f17b3bee0d40c78c036b3040637ec2e39fd&hash=070822572e7227f13b31fd6388417b6937f03cfb458c84a76d276bf19006c9e8&host=68042c943591013ac2b2430a89b270f6af2c76d8dfd086a07176afe7c76c2c61&pii=S2212017312003490&tid=spdf-120c41d0-03fc-45ab-bff8-7c1879b00817&sid=09c77b6a495598488d092de82769cba552a2gxrqb&type=client&tsoh=d3d3LnNjaWVuY2VkaXJlY3QuY29t&ua=14015c52535457570054&rr=911391b48b0ae0c5&cc=ro
//https://user42.tuxfamily.org/chart/manual/Exponential-Moving-Average.html


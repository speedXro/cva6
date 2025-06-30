//`timescale 1ns / 1ps

module DA_Config_CDC(
    input  logic        clk,
    input  logic        reset,

    input  logic [11:0] DA_Config_Value,

    output logic        da_we,
    output logic [11:0] da_value
);

    logic [11:0] DA_Config;
    logic [11:0] DA_Config_old;
    logic [11:0] DA_Config_new;

    logic        da_clr;

    assign DA_Config = DA_Config_Value; 

    always_ff @(posedge clk) begin
        if(reset == 1'b1) begin
            DA_Config_old <= 12'd4095;
            DA_Config_new <= 12'd0;
        end
        else begin
            DA_Config_old <= DA_Config_new;
            DA_Config_new <= DA_Config;
        end
    end

    always_ff @(posedge clk) begin
        if(reset == 1'b1) begin
            da_we      <=  1'd0;
            da_value   <= 12'd0;
            da_clr     <=  1'd0;
        end
        else if(da_clr == 1'b1) begin
            da_we      <=  1'd0;
            da_value   <= 12'd0;
            da_clr     <=  1'd0;           
        end
        else if(DA_Config_new != DA_Config_old) begin
            da_we      <=  1'b1;
            da_value   <=  DA_Config_new;
            da_clr     <= 1'b1;
        end
    end

endmodule
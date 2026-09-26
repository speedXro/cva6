`timescale 1ns / 1ps

module DA_Module(
    input  logic         clk_100,
    input  logic         clk_25,

    input  logic         reset_n,

    output logic         da_sync_n,
    output logic         da_sclk,
    output logic         da_din,

    output logic         da_100_working_busy,
    input  logic         da_100_val_we,
    input  logic [ 11:0] da_100_val_value
);

    logic [11:0] DA_Config_Value;

    logic        da_we;
    logic [11:0] da_value;
    logic        da_busy;
    logic        da_busy_100;

    DA_Configurator i_DA_Configurator(
        .clk_100(clk_100),
        .reset_n(reset_n),

        .val_we(da_100_val_we),
        .val(da_100_val_value),

        .da_config_val(DA_Config_Value),

        .da_busy(da_busy_100),
        .busy(da_100_working_busy)
    );

    DA_Config_CDC i_DA_Config_CDC(
        .clk(clk_25),
        .reset_n(reset_n),

        .DA_Config_Value(DA_Config_Value),

        .da_we(da_we),
        .da_value(da_value)
    );

    DA_BitBanging i_DA_BitBanging(
        .clk(clk_25),
        .reset_n(reset_n),

        .da_we(da_we),
        .da_value(da_value),

        .da_sync_n(da_sync_n),
        .da_sclk(da_sclk),
        .da_din(da_din),
        .da_busy(da_busy)
    );

    DA_BB_Busy_CDC i_DA_BB_Busy_CDC(
        .clk(clk_100),
        .reset_n(reset_n),

        .da_busy(da_busy),

        .DA_BB_Busy(da_busy_100)
    );

    assign da_100_working_busy = da_busy_100;
 
endmodule

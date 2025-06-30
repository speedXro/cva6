//`timescale 1ns / 1ps

module DA_Block #(
    parameter mod_addr = 8'd0
)(
    input  logic         clk_100,
    input  logic         clk_25,
    input  logic         reset,

    input  logic [  7:0] addr,

    // from ISA FSM

    input  logic         da_broadcast_we,

    input  logic         da_val_we,
    input  logic [ 11:0] da_val_value,

    input  logic         da_seq_values_we,
    input  logic [119:0] da_seq_values,
    
    input  logic         da_seq_lengths_we,
    input  logic [119:0] da_seq_lengths,

    input  logic         da_seq_length_we,
    input  logic [  3:0] da_seq_length,

    input  logic         da_seq_start_we,

    output logic         da_configurator_busy,
    output logic         da_sequence_running,
    output logic [ 11:0] da_out_val,

    output logic         da_sync_n,
    output logic         da_sclk,
    output logic         da_din
);

    logic        enable;

    logic        DA_BB_Busy;
    logic [11:0] DA_Config_Value;

    logic        da_we;
    logic [11:0] da_value;

    logic        da_busy;

    DA_Configurator DA_Configurator_inst(
        .clk(clk_100),
        .reset(reset),

        .da_val_we(da_val_we & enable),
        .da_val_value(da_val_value),

        .da_seq_values_we(da_seq_values_we & enable),
        .da_seq_values(da_seq_values),

        .da_seq_lengths_we(da_seq_lengths_we & enable),
        .da_seq_lengths(da_seq_lengths),

        .da_seq_length_we(da_seq_length_we & enable),
        .da_seq_length(da_seq_length),

        .da_seq_start_we(da_seq_start_we & enable),

        .DA_BB_Busy(DA_BB_Busy),

        .DA_Config_Value(DA_Config_Value),

        .da_configurator_busy(da_configurator_busy),
        .da_sequence_running(da_sequence_running),

        .da_out_val(da_out_val)
    );

    DA_Config_CDC DA_Config_CDC_inst(
        .clk(clk_25),
        .reset(reset),

        .DA_Config_Value(DA_Config_Value),

        .da_we(da_we),
        .da_value(da_value)
    );

    DA_BitBanging DA_BitBanging_inst(
        .clk(clk_25),
        .reset(reset),

        .da_we(da_we),
        .da_value(da_value),

        .da_sync_n(da_sync_n),
        .da_sclk(da_sclk),
        .da_din(da_din),
        .da_busy(da_busy)
    );

    DA_BB_Busy_CDC DA_BB_Busy_CDC_inst(
        .clk(clk_100),
        .reset(reset),

        .da_busy(da_busy),

        .DA_BB_Busy(DA_BB_Busy)
    );

    assign enable = ((mod_addr == addr) || (da_broadcast_we == 1'b1)) ? 1'b1 : 1'b0;

endmodule
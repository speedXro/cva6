//`timescale 1ns / 1ps

module DA_Extension #(
    parameter N_DA = 2
)(
    input  logic            clk_100,
    input  logic            clk_25,

    input  logic            reset,

    input  logic            da_enb,
    input  logic [     2:0] da_fct3,
    input  logic [     6:0] da_fct7,
    input  logic [    63:0] da_op1,
    input  logic [    63:0] da_op2,

    output logic            da_rd_we,
    output logic [    63:0] da_rd,

    output logic [N_DA-1:0] bus_da_sync_n,
    output logic [N_DA-1:0] bus_da_sclk,
    output logic [N_DA-1:0] bus_da_din 
);

    logic [  7:0]    addr;

    logic            da_broadcast_we;

    logic            da_val_we;
    logic [ 11:0]    da_val_value;

    logic            da_seq_values_we;
    logic [119:0]    da_seq_values;
    
    logic            da_seq_lengths_we;
    logic [119:0]    da_seq_lengths;

    logic            da_seq_length_we;
    logic [  3:0]    da_seq_length;

    logic            da_seq_start_we;

    logic [N_DA-1:0] bus_da_configurator_busy;
    logic [N_DA-1:0] bus_da_sequence_running;
    logic [    11:0] da_val_output;

    DA_Controller #(.N_DA(N_DA)) DA_Controller_inst(
        .clk_100(clk_100),
        .reset(reset),

        .da_enb(da_enb),
        .da_fct3(da_fct3),
        .da_fct7(da_fct7),
        .da_op1(da_op1),
        .da_op2(da_op2),

        .addr(addr),

        .da_broadcast_we(da_broadcast_we),
        
        .da_val_we(da_val_we),
        .da_val_value(da_val_value),

        .da_seq_values_we(da_seq_values_we),
        .da_seq_values(da_seq_values),

        .da_seq_lengths_we(da_seq_lengths_we),
        .da_seq_lengths(da_seq_lengths),

        .da_seq_length_we(da_seq_length_we),
        .da_seq_length(da_seq_length),

        .da_seq_start_we(da_seq_start_we),

        .bus_da_configurator_busy(bus_da_configurator_busy),
        .bus_da_sequence_running(bus_da_sequence_running),
        .da_val_output(da_val_output),

        .da_rd_we(da_rd_we),
        .da_rd(da_rd)
    );

    DA_Blocks #(.N_DA(N_DA)) DA_Blocks_inst(
        .clk_100(clk_100),
        .clk_25(clk_25),

        .reset(reset),

        .addr(addr),

        .da_broadcast_we(da_broadcast_we),
        
        .da_val_we(da_val_we),
        .da_val_value(da_val_value),

        .da_seq_values_we(da_seq_values_we),
        .da_seq_values(da_seq_values),

        .da_seq_lengths_we(da_seq_lengths_we),
        .da_seq_lengths(da_seq_lengths),

        .da_seq_length_we(da_seq_length_we),
        .da_seq_length(da_seq_length),

        .da_seq_start_we(da_seq_start_we),

        .bus_da_configurator_busy(bus_da_configurator_busy),
        .bus_da_sequence_running(bus_da_sequence_running),
        .da_val_output(da_val_output),

        .bus_da_sync_n(bus_da_sync_n),
        .bus_da_sclk(bus_da_sclk),
        .bus_da_din(bus_da_din)
    );


endmodule
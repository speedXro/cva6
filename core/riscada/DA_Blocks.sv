//`timescale 1ns / 1ps

module DA_Blocks #(
    parameter N_DA = 2
)(
    input  logic            clk_100,
    input  logic            clk_25,
    input  logic            reset,

    input  logic [     7:0] addr,

    // from ISA FSM

    input  logic            da_broadcast_we,

    input  logic            da_val_we,
    input  logic [    11:0] da_val_value,

    input  logic            da_seq_values_we,
    input  logic [   119:0] da_seq_values,
    
    input  logic            da_seq_lengths_we,
    input  logic [   119:0] da_seq_lengths,

    input  logic            da_seq_length_we,
    input  logic [     3:0] da_seq_length,

    input  logic            da_seq_start_we,

    output logic [N_DA-1:0] bus_da_configurator_busy,
    output logic [N_DA-1:0] bus_da_sequence_running,
    output logic [    11:0] da_val_output,

    output logic [N_DA-1:0] bus_da_sync_n,
    output logic [N_DA-1:0] bus_da_sclk,
    output logic [N_DA-1:0] bus_da_din
);

    genvar i;

    logic [11:0] da_out_val [0:N_DA-1];

    generate
        for(i=0;i<N_DA;i=i+1) begin
            DA_Block #(.mod_addr(i)) DA_BLOCK_inst(
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

                .da_configurator_busy(bus_da_configurator_busy[i]),
                .da_sequence_running(bus_da_sequence_running[i]),
                .da_out_val(da_out_val[i]),

                .da_sync_n(bus_da_sync_n[i]),
                .da_sclk(bus_da_sclk[i]),
                .da_din(bus_da_din[i])
            );
        end
    endgenerate

    assign da_val_output = da_out_val[addr];

endmodule
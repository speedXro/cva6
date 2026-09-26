`timescale 1ns / 1ps

module DA_Block #(
    parameter int unsigned DATA_WIDTH  = 64,
    parameter int unsigned MEM_DEPTH  = 1024,
    localparam int unsigned ADDR_WIDTH = $clog2(MEM_DEPTH)
)(
    input  logic                    clk_100,

    input  logic                    reset_n,

    input  logic                    da_enable,
    input  logic                    da_clear,
    output logic                    da_empty,

    input  logic                    en_b,
    input  logic                    we_b,
    input  logic [ADDR_WIDTH-1:0]   addr_b,
    input  logic [DATA_WIDTH-1:0]   din_b,
    output logic [DATA_WIDTH-1:0]   dout_b,

    output logic  [ADDR_WIDTH:0]    rd_cnt_out,
    input  logic  [ADDR_WIDTH:0]    da_lim,

    output logic                    da_sync_n,
    output logic                    da_sclk,
    output logic                    da_din
);

    logic                    en_a;
    logic                    we_a;
    logic [ADDR_WIDTH-1:0]   addr_a;
    logic [DATA_WIDTH-1:0]   din_a;
    logic [DATA_WIDTH-1:0]   dout_a;

    logic clk_25;

    logic         da_100_val_we;
    logic [ 11:0] da_100_val_value;

    logic         da_100_working_busy;
    logic         idle_one;

    logic        commit_en;
    logic [63:0] commit_value;
    logic        idle;

    logic        wr_en;
    logic [15:0] wr_val;

    ClockDivider_p4 i_ClockDivider_p4(
        .clk(clk_100),
        .reset_n(reset_n),

        .clk_per_4(clk_25)
    );

    DA_DB_BRAM #(
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_DEPTH(MEM_DEPTH),
        .OUT_REG_EN(0),
        .SYNTH(1)
    ) i_DA_DB_BRAM(
        .clk_a(clk_100),
        .rst_a(~reset_n),
        .en_a(en_a),
        .we_a(we_a),
        .addr_a(addr_a),
        .din_a(din_a),
        .dout_a(dout_a),

        .clk_b(clk_100),
        .rst_b(~reset_n),
        .en_b(en_b),
        .we_b(we_b),
        .addr_b(addr_b),
        .din_b(din_b),
        .dout_b(dout_b)
    );

    DA_Control #(
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_DEPTH(MEM_DEPTH)
    ) i_DA_Control(
        .clock(clk_100),
        .reset_n(reset_n),

        .da_enable(da_enable),
        .da_clear(da_clear),
        .da_empty(da_empty),

        .en_a(en_a),
        .we_a(we_a),
        .addr_a(addr_a),
        .din_a(din_a),
        .dout_a(dout_a),

        .idle(idle),
        .commit_en(commit_en),
        .commit_value(commit_value),

        .rd_cnt_out(rd_cnt_out),
        .da_lim(da_lim)
    );

    DA_FourWrite i_DA_FourWrite(
        .clk_100(clk_100),
        .reset_n(reset_n),

        .idle(idle),
        .commit_en(commit_en),
        .commit_value(commit_value),

        .one_idle(idle_one),
        .wr_en(wr_en),
        .wr_val(wr_val)
    );

    DA_OneWrite i_DA_OneWrite(
        .clk_100(clk_100),
        .reset_n(reset_n),

        .idle(idle_one),
        .wr_en(wr_en),
        .wr_val(wr_val),

        .da_100_working_busy(da_100_working_busy),
        .da_100_val_we(da_100_val_we),
        .da_100_val_value(da_100_val_value)
    );

    DA_Module i_DA_Module(
        .clk_100(clk_100),
        .clk_25(clk_25),

        .reset_n(reset_n),

        .da_sync_n(da_sync_n),
        .da_sclk(da_sclk),
        .da_din(da_din),

        .da_100_working_busy(da_100_working_busy),
        .da_100_val_we(da_100_val_we),
        .da_100_val_value(da_100_val_value)
    );

endmodule

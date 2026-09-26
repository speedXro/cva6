`timescale 1ns / 1ps

module AD_Block #(
    parameter int unsigned DATA_WIDTH  = 64,
    parameter int unsigned MEM_DEPTH  = 1024,
    localparam int unsigned ADDR_WIDTH = $clog2(MEM_DEPTH)
)(
    input  logic                    clk_100,

    input  logic                    reset_n,

    output logic                    ad_cs_n,
    output logic                    ad_sclk,
    input  logic                    ad_dout,

    input  logic                    ad_aq_enable,
    input  logic                    ad_aq_clear,
    output logic                    ad_aq_full,

    input  logic                    en_b,
    input  logic                    we_b,
    input  logic [ADDR_WIDTH-1:0]   addr_b,
    input  logic [DATA_WIDTH-1:0]   din_b,
    output logic [DATA_WIDTH-1:0]   dout_b,

    output logic  [ADDR_WIDTH:0]    wr_cnt_out,
    input  logic  [ADDR_WIDTH:0]    ad_lim
);

    logic        clk_10;

    logic        ad_eoc;
    logic [11:0] ad_value;

    logic        AD_Eofc;
    logic [11:0] AD_Val;

    logic                    en_a;
    logic                    we_a;
    logic [ADDR_WIDTH-1:0]   addr_a;
    logic [DATA_WIDTH-1:0]   din_a;
    logic [DATA_WIDTH-1:0]   dout_a;

    ClockDivider i_ClockDivider_10(
        .clk(clk_100),
        .reset_n(reset_n),

        .clk_per_4(),
        .clk_per_10(clk_10)
    );

    AD_BitBanging AD_BitBanging_inst(
        .clk(clk_10),
        .reset_n(reset_n),

        .ad_cs_n(ad_cs_n),
        .ad_sclk(ad_sclk),
        .ad_dout(ad_dout),

        .ad_eoc(ad_eoc),
        .ad_value(ad_value)
    );

    AD_Values_CDC AD_Values_CDC_inst(
        .clk(clk_100),
        .reset_n(reset_n),

        .ad_eoc(ad_eoc),
        .ad_value(ad_value),

        .AD_Eofc(AD_Eofc),
        .AD_Val(AD_Val)        
    );

    AD_Aq_Control #(
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_DEPTH(MEM_DEPTH)
    ) i_AD_Aq_Control(
        .clk(clk_100),
        .reset_n(reset_n),

        .AD_Eofc(AD_Eofc),
        .AD_Val(AD_Val),

        .ad_aq_enable(ad_aq_enable),
        .ad_aq_clear(ad_aq_clear),
        .ad_aq_full(ad_aq_full),

        .en_a(en_a),
        .we_a(we_a),
        .addr_a(addr_a),
        .din_a(din_a),
        .dout_a(dout_a),

        .wr_cnt_out(wr_cnt_out),
        .ad_lim(ad_lim)
    );

    AD_DB_BRAM #(
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_DEPTH(MEM_DEPTH),
        .OUT_REG_EN(0),
        .SYNTH(1)
    ) i_AD_DB_BRAM(
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

endmodule

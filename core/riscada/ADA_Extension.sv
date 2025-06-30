//`timescale 1ns / 1ps

module ADA_Extension(
    input  logic        clk,
    input  logic        reset,
    
    input  logic        instr_commit,
    input  logic [ 6:0] instr_funct7,
    input  logic [ 2:0] instr_funct3,
    input  logic [ 6:0] instr_opcode,
    input  logic [63:0] instr_rs1_val,
    input  logic [63:0] instr_rs2_val,
    
    output logic        result_we,
    output logic [63:0] result_rd,
    
    output logic        result_mem_en,
    output logic [63:0] result_mem_adr,
    output logic [63:0] result_mem_dat,
    
    output logic [ 0:0] da_sync_n,
    output logic [ 0:0] da_sclk,
    output logic [ 0:0] da_din,

    output logic [ 0:0] ad_cs_n,
    output logic [ 0:0] ad_sclk,
    input  logic [ 0:0] ad_dout, 
    output logic [ 0:0] ad_digitized
);
    localparam OPCODE_ADA = 7'b1111011;

    logic        clk_per_1;
    logic        clk_per_4;
    logic        clk_per_10;   

    logic        da_rd_we;
    logic [63:0] da_rd;

    logic        ad_rd_we;
    logic [63:0] ad_rd;

    logic instr_enable;

    assign instr_enable = ((instr_commit == 1'b1) && (instr_opcode == OPCODE_ADA));

    ClockDivider ClockDivider_inst(
        .clk(clk),
        .reset(reset),

        .clk_per_1(clk_per_1),
        .clk_per_4(clk_per_4),
        .clk_per_10(clk_per_10)
    );

    DA_Extension #(.N_DA(1)) DA_Extension_inst(
        .clk_100(clk_per_1),
        .clk_25(clk_per_4),

        .reset(reset),

        .da_enb(instr_enable),
        .da_fct3(instr_funct3),
        .da_fct7(instr_funct7),
        .da_op1(instr_rs1_val),
        .da_op2(instr_rs2_val),

        .da_rd_we(da_rd_we),
        .da_rd(da_rd),

        .bus_da_sync_n(da_sync_n),
        .bus_da_sclk(da_sclk),
        .bus_da_din(da_din)
    );

    AD_Extension #(.N_AD(1)) AD_Extension_inst(
        .clk_100(clk_per_1),
        .clk_10(clk_per_10),

        .reset(reset),

        .ad_enb(instr_enable),
        .ad_fct3(instr_funct3),
        .ad_fct7(instr_funct7),
        .ad_op1(instr_rs1_val),
        .ad_op2(instr_rs2_val),

        .ad_rd_we(ad_rd_we),
        .ad_rd(ad_rd),

        .bus_ad_cs_n(ad_cs_n),
        .bus_ad_sclk(ad_sclk),
        .bus_ad_dout(ad_dout),
        .bus_ad_digitized(ad_digitized)
    );

    ADA_Rd_Mux ADA_Rd_Mux_inst(
        .da_rd_we(da_rd_we),
        .da_rd(da_rd),

        .ad_rd_we(ad_rd_we),
        .ad_rd(ad_rd),

        .result_we(result_we),
        .result_rd(result_rd)
    );

    assign result_mem_en = 1'b0;
    assign result_mem_adr = 64'd0;
    assign result_mem_dat = 64'd0;

endmodule


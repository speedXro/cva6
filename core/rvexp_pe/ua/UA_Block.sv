`timescale 1ns / 1ps

module UA_Block #(
    parameter  int unsigned DATA_WIDTH = 64,
    parameter  int unsigned MEM_DEPTH  = 1024,
    localparam int unsigned ADDR_WIDTH = $clog2(MEM_DEPTH)
)(
    input  logic                    clock,
    input  logic                    reset_n,

    input  logic                    ua_enable,
    input  logic                    ua_clear,
    output logic                    ua_empty,

    input  logic                    en_b,
    input  logic                    we_b,
    input  logic [ADDR_WIDTH-1:0]   addr_b,
    input  logic [DATA_WIDTH-1:0]   din_b,
    output logic [DATA_WIDTH-1:0]   dout_b,

    output logic  [ADDR_WIDTH:0]    rd_cnt_out,
    input  logic  [ADDR_WIDTH:0]    ua_lim,

    output logic                    o_uart_tx
);

    logic                    en_a;
    logic                    we_a;
    logic [ADDR_WIDTH-1:0]   addr_a;
    logic [DATA_WIDTH-1:0]   din_a;
    logic [DATA_WIDTH-1:0]   dout_a;

    logic                    o_ready;
    logic                    i_result_commit;
    logic [          63:0]   i_result_data;

    logic                    i_Tx_DV;
    logic [           7:0]   i_Tx_Byte;
    logic                    o_Tx_Active;
    logic                    o_Tx_Done;

    UA_UART_Control #(
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_DEPTH(MEM_DEPTH)
    ) i_UA_UART_Control(
        .clock(clock),
        .reset_n(reset_n),

        .ua_enable(ua_enable),
        .ua_clear(ua_clear),
        .ua_empty(ua_empty),

        .en_a(en_a),
        .we_a(we_a),
        .addr_a(addr_a),
        .din_a(din_a),
        .dout_a(dout_a),

        .o_ready(o_ready),
        .i_result_commit(i_result_commit),
        .i_result_data(i_result_data),

        .rd_cnt_out(rd_cnt_out),
        .ua_lim(ua_lim)
    );

    UA_DB_BRAM #(
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_DEPTH(MEM_DEPTH),
        .OUT_REG_EN(0),
        .SYNTH(1)
    ) i_UA_DB_BRAM(
        .clk_a(clock),
        .rst_a(~reset_n),
        .en_a(en_a),
        .we_a(we_a),
        .addr_a(addr_a),
        .din_a(din_a),
        .dout_a(dout_a),

        .clk_b(clock),
        .rst_b(~reset_n),
        .en_b(en_b),
        .we_b(we_b),
        .addr_b(addr_b),
        .din_b(din_b),
        .dout_b(dout_b)
    );

    AD_UART_Sender i_AD_UART_Sender(
        .clk(clock),
        .reset_n(reset_n),
        
        .o_ready(o_ready),
        .i_result_commit(i_result_commit),
        .i_result_data(i_result_data),

        .i_Tx_DV(i_Tx_DV),
        .i_Tx_Byte(i_Tx_Byte),
        .o_Tx_Active(o_Tx_Active),
        .o_Tx_Done(o_Tx_Done)
    );

    uart_tx #(
        .CLKS_PER_BIT(108)
    ) i_uart_tx(
        .i_Clock(clock),

        .i_Tx_DV(i_Tx_DV),
        .i_Tx_Byte(i_Tx_Byte),
        .o_Tx_Active(o_Tx_Active),
        .o_Tx_Done(o_Tx_Done),

        .o_Tx_Serial(o_uart_tx)
    );

endmodule

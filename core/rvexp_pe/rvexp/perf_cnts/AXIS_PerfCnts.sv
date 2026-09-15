`timescale 1 ns / 1 ps

module AXIS_PerfCnts(
    input  logic clock,
    input  logic reset_n,

    input  logic m_valid,
    input  logic m_ready,
    input  logic m_last,

    input  logic s_valid,
    input  logic s_ready,
    input  logic s_last,

    output logic [31:0] axis_timers_values [0:7],

    output logic [31:0] mvalid_cnt,
    output logic [31:0] mlast_cnt,
    output logic [31:0] svalid_cnt,
    output logic [31:0] slast_cnt
);

    logic outter_start;
    logic outter_stop;

    logic inner_start;
    logic inner_inc;
    logic inner_stop;

    logic mvalid_inc;
    logic mlast_inc;
    logic svalid_inc;
    logic slast_inc;

    AXIS_Probes i_AXIS_Probes(
        .clock(clock),
        .reset_n(reset_n),

        .m_valid(m_valid),
        .m_ready(m_ready),
        .m_last(m_last),

        .s_valid(s_valid),
        .s_ready(s_ready),
        .s_last(s_last),

        .outter_start(outter_start),
        .outter_stop(outter_stop),

        .inner_start(inner_start),
        .inner_inc(inner_inc),
        .inner_stop(inner_stop),

        .mvalid_inc(mvalid_inc),
        .mlast_inc(mlast_inc),
        .svalid_inc(svalid_inc),
        .slast_inc(slast_inc)
    );

    logic        outter_commit;
    logic [15:0] outter_value;

    logic        inner_commit; 
    logic [15:0] inner_value;

    DualTimer i_DualTimer(
        .clock(clock),
        .reset_n(reset_n),

        .outter_start(outter_start),
        .outter_stop(outter_stop),
        .outter_commit(outter_commit),
        .outter_value(outter_value),

        .inner_start(inner_start),
        .inner_inc(inner_inc),
        .inner_stop(inner_stop),
        .inner_commit(inner_commit),
        .inner_value(inner_value)
    );

    logic [16-1:0] outter_values [0:8-1];
    logic [16-1:0] inner_values  [0:8-1];


    srs_sipo #(
        .NO_OF_REGS(8),
        .WIDTH(16)
    ) i_srs_sipo_outter_values (
        .clock(clock),
        .reset_n(reset_n),

        .serial_input_valid(outter_commit),
        .serial_input_last(1'b0),
        .serial_input_ready(),
        .serial_input_data(outter_value),

        .parallel_datas_out_commit(),
        .parallel_datas_out(outter_values)
    );

    srs_sipo #(
        .NO_OF_REGS(8),
        .WIDTH(16)
    ) i_srs_sipo_inner_values (
        .clock(clock),
        .reset_n(reset_n),

        .serial_input_valid(inner_commit),
        .serial_input_last(1'b0),
        .serial_input_ready(),
        .serial_input_data(inner_value),

        .parallel_datas_out_commit(),
        .parallel_datas_out(inner_values)
    );

    ValidLastCounters i_ValidLastCounters(
        .clock(clock),
        .reset_n(reset_n),

        .mvalid_inc(mvalid_inc),
        .mlast_inc(mlast_inc),
        .svalid_inc(svalid_inc),
        .slast_inc(slast_inc),

        .mvalid_cnt(mvalid_cnt),
        .mlast_cnt(mlast_cnt),
        .svalid_cnt(svalid_cnt),
        .slast_cnt(slast_cnt)
    );

    genvar i;
    generate
        for (i = 0; i < 8; i++) begin : g_pack
            assign axis_timers_values[i] = {outter_values[i], inner_values[i]};
        end
    endgenerate

endmodule
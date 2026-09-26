
`timescale 1ns / 1ps

module stft128_top
  import stft128_pkg::*;
#(
  parameter X_ID_WIDTH = 4
)(
  input  logic                    clk,
  input  logic                    rst_n,

  input  logic signed [SMP_W-1:0] s_axis_tdata,
  input  logic                    s_axis_tvalid,
  output logic                    s_axis_tready,
  input  logic                    s_axis_tlast,

  output logic [CPX_W-1:0]        m_axis_tdata,
  output logic                    m_axis_tvalid,
  input  logic                    m_axis_tready,
  output logic                    m_axis_tlast,

  input  logic                    x_issue_valid,
  output logic                    x_issue_ready,
  input  logic [31:0]             x_issue_req_instr,
  input  logic [X_ID_WIDTH-1:0]   x_issue_req_id,
  input  logic [31:0]             x_issue_req_rs1,
  input  logic [31:0]             x_issue_req_rs2,
  input  logic [1:0]              x_issue_req_rs_valid,
  output logic                    x_issue_resp_accept,
  output logic                    x_issue_resp_writeback,
  output logic                    x_issue_resp_dualwrite,
  output logic                    x_issue_resp_loadstore,
  input  logic                    x_commit_valid,
  input  logic [X_ID_WIDTH-1:0]   x_commit_id,
  input  logic                    x_commit_kill,
  output logic                    x_result_valid,
  input  logic                    x_result_ready,
  output logic [X_ID_WIDTH-1:0]   x_result_id,
  output logic [31:0]             x_result_data,
  output logic [4:0]              x_result_rd,
  output logic                    x_result_we
);

  logic [1:0] cfg_window_sel, cfg_out_fmt, cfg_pix_floor;
  logic       cfg_enable, start_pulse, soft_reset, stat_read_ack;
  logic       ctrl_busy, frame_done, frame_full;
  logic [7:0] frame_count;

  stft128_core u_core (
    .clk(clk), .rst_n(rst_n),
    .s_axis_tdata(s_axis_tdata), .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tready(s_axis_tready), .s_axis_tlast(s_axis_tlast),
    .m_axis_tdata(m_axis_tdata), .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(m_axis_tready), .m_axis_tlast(m_axis_tlast),
    .cfg_window_sel(cfg_window_sel), .cfg_enable(cfg_enable),
    .cfg_out_fmt(cfg_out_fmt), .cfg_pix_floor(cfg_pix_floor),
    .start_pulse(start_pulse), .soft_reset(soft_reset), .stat_read_ack(stat_read_ack),
    .ctrl_busy(ctrl_busy), .frame_done(frame_done),
    .frame_full(frame_full), .frame_count(frame_count)
  );

  stft128_cvxif #(.X_ID_WIDTH(X_ID_WIDTH)) u_cvxif (
    .clk(clk), .rst_n(rst_n),
    .x_issue_valid(x_issue_valid), .x_issue_ready(x_issue_ready),
    .x_issue_req_instr(x_issue_req_instr), .x_issue_req_id(x_issue_req_id),
    .x_issue_req_rs1(x_issue_req_rs1), .x_issue_req_rs2(x_issue_req_rs2),
    .x_issue_req_rs_valid(x_issue_req_rs_valid),
    .x_issue_resp_accept(x_issue_resp_accept),
    .x_issue_resp_writeback(x_issue_resp_writeback),
    .x_issue_resp_dualwrite(x_issue_resp_dualwrite),
    .x_issue_resp_loadstore(x_issue_resp_loadstore),
    .x_commit_valid(x_commit_valid), .x_commit_id(x_commit_id),
    .x_commit_kill(x_commit_kill),
    .x_result_valid(x_result_valid), .x_result_ready(x_result_ready),
    .x_result_id(x_result_id), .x_result_data(x_result_data),
    .x_result_rd(x_result_rd), .x_result_we(x_result_we),
    .cfg_window_sel(cfg_window_sel), .cfg_enable(cfg_enable),
    .cfg_out_fmt(cfg_out_fmt), .cfg_pix_floor(cfg_pix_floor),
    .start_pulse(start_pulse), .soft_reset(soft_reset), .stat_read_ack(stat_read_ack),
    .ctrl_busy(ctrl_busy), .frame_done(frame_done),
    .frame_full(frame_full), .frame_count(frame_count)
  );

endmodule

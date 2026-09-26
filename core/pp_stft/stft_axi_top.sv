`timescale 1ns / 1ps

module stft_axi_top
  import stft128_pkg::*;
#(
  parameter AXIL_ADDR_W = 4
)(
  input  logic                    aclk,
  input  logic                    aresetn,        // active-low

  input  logic [AXIL_ADDR_W-1:0]  s_axil_awaddr,
  input  logic [2:0]              s_axil_awprot,
  input  logic                    s_axil_awvalid,
  output logic                    s_axil_awready,
  input  logic [31:0]             s_axil_wdata,
  input  logic [3:0]              s_axil_wstrb,
  input  logic                    s_axil_wvalid,
  output logic                    s_axil_wready,
  output logic [1:0]              s_axil_bresp,
  output logic                    s_axil_bvalid,
  input  logic                    s_axil_bready,
  input  logic [AXIL_ADDR_W-1:0]  s_axil_araddr,
  input  logic [2:0]              s_axil_arprot,
  input  logic                    s_axil_arvalid,
  output logic                    s_axil_arready,
  output logic [31:0]             s_axil_rdata,
  output logic [1:0]              s_axil_rresp,
  output logic                    s_axil_rvalid,
  input  logic                    s_axil_rready,

  input  logic [31:0]             s_axis_tdata,   // sample in [15:0]
  input  logic                    s_axis_tvalid,
  output logic                    s_axis_tready,
  input  logic                    s_axis_tlast,

  output logic [31:0]             m_axis_tdata,
  output logic                    m_axis_tvalid,
  input  logic                    m_axis_tready,
  output logic                    m_axis_tlast
);

  logic [1:0] cfg_window_sel, cfg_out_fmt, cfg_pix_floor;
  logic       cfg_enable, start_pulse, soft_reset, stat_read_ack;
  logic       ctrl_busy, frame_done, frame_full;
  logic [7:0] frame_count;

  stft_axil_regs #(.ADDR_W(AXIL_ADDR_W)) u_regs (
    .aclk(aclk), .aresetn(aresetn),
    .s_axi_awaddr(s_axil_awaddr), .s_axi_awprot(s_axil_awprot),
    .s_axi_awvalid(s_axil_awvalid), .s_axi_awready(s_axil_awready),
    .s_axi_wdata(s_axil_wdata), .s_axi_wstrb(s_axil_wstrb),
    .s_axi_wvalid(s_axil_wvalid), .s_axi_wready(s_axil_wready),
    .s_axi_bresp(s_axil_bresp), .s_axi_bvalid(s_axil_bvalid), .s_axi_bready(s_axil_bready),
    .s_axi_araddr(s_axil_araddr), .s_axi_arprot(s_axil_arprot),
    .s_axi_arvalid(s_axil_arvalid), .s_axi_arready(s_axil_arready),
    .s_axi_rdata(s_axil_rdata), .s_axi_rresp(s_axil_rresp),
    .s_axi_rvalid(s_axil_rvalid), .s_axi_rready(s_axil_rready),
    .cfg_window_sel(cfg_window_sel), .cfg_enable(cfg_enable),
    .cfg_out_fmt(cfg_out_fmt), .cfg_pix_floor(cfg_pix_floor),
    .start_pulse(start_pulse), .soft_reset(soft_reset), .stat_read_ack(stat_read_ack),
    .ctrl_busy(ctrl_busy), .frame_done(frame_done),
    .frame_full(frame_full), .frame_count(frame_count)
  );

  stft128_core u_core (
    .clk(aclk), .rst_n(aresetn),
    .s_axis_tdata(s_axis_tdata[SMP_W-1:0]), .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tready(s_axis_tready), .s_axis_tlast(s_axis_tlast),
    .m_axis_tdata(m_axis_tdata), .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(m_axis_tready), .m_axis_tlast(m_axis_tlast),
    .cfg_window_sel(cfg_window_sel), .cfg_enable(cfg_enable),
    .cfg_out_fmt(cfg_out_fmt), .cfg_pix_floor(cfg_pix_floor),
    .start_pulse(start_pulse), .soft_reset(soft_reset), .stat_read_ack(stat_read_ack),
    .ctrl_busy(ctrl_busy), .frame_done(frame_done),
    .frame_full(frame_full), .frame_count(frame_count)
  );

endmodule


// Register map (word-addressed, offset = word*4):
//   0x00 ID       RO  0x53544631 ("STF1")            -- bring-up readback
//   0x04 CONFIG   RW  [1:0] window_sel  [2] enable
//                     [4:3] out_fmt     [6:5] pix_floor   (mirrors pkg layout)
//   0x08 CONTROL  WO  [0] start  [1] soft_reset  [2] ack_done  (self-clearing)
//   0x0C STATUS   RO  [0] busy [1] frame_done [2] frame_full [15:8] frame_count

`timescale 1ns / 1ps

module stft_axil_regs
  import stft128_pkg::*;
#(
  parameter int ADDR_W = 4                       // 16-byte window (4 registers)
)(

  input  logic                aclk,
  input  logic                aresetn,           // active-low
  input  logic [ADDR_W-1:0]   s_axi_awaddr,
  input  logic [2:0]          s_axi_awprot,
  input  logic                s_axi_awvalid,
  output logic                s_axi_awready,
  input  logic [31:0]         s_axi_wdata,
  input  logic [3:0]          s_axi_wstrb,
  input  logic                s_axi_wvalid,
  output logic                s_axi_wready,
  output logic [1:0]          s_axi_bresp,
  output logic                s_axi_bvalid,
  input  logic                s_axi_bready,
  input  logic [ADDR_W-1:0]   s_axi_araddr,
  input  logic [2:0]          s_axi_arprot,
  input  logic                s_axi_arvalid,
  output logic                s_axi_arready,
  output logic [31:0]         s_axi_rdata,
  output logic [1:0]          s_axi_rresp,
  output logic                s_axi_rvalid,
  input  logic                s_axi_rready,

  output logic [1:0]          cfg_window_sel,
  output logic                cfg_enable,
  output logic [1:0]          cfg_out_fmt,
  output logic [1:0]          cfg_pix_floor,
  output logic                start_pulse,
  output logic                soft_reset,
  output logic                stat_read_ack,
  input  logic                ctrl_busy,
  input  logic                frame_done,        // sticky (cleared by ack)
  input  logic                frame_full,
  input  logic [7:0]          frame_count
);
  localparam logic [1:0] REG_ID = 2'd0, REG_CFG = 2'd1, REG_CTL = 2'd2, REG_STAT = 2'd3;
  localparam logic [31:0] ID_MAGIC = 32'h5354_4631;    // "STF1"

  logic [6:0] cfg_q;
  assign cfg_window_sel = cfg_q[CFG_WSEL_HI:CFG_WSEL_LO];
  assign cfg_enable     = cfg_q[CFG_ENABLE];
  assign cfg_out_fmt    = cfg_q[CFG_OFMT_HI:CFG_OFMT_LO];
  assign cfg_pix_floor  = cfg_q[CFG_PXFL_HI:CFG_PXFL_LO];

  logic [31:0] status_w;
  assign status_w = {16'b0, frame_count, 5'b0, frame_full, frame_done, ctrl_busy};

  logic        bvalid_q;
  wire         wr_fire = s_axi_awvalid & s_axi_wvalid & ~bvalid_q;
  wire [1:0]   wr_word = s_axi_awaddr[3:2];
  assign s_axi_awready = wr_fire;
  assign s_axi_wready  = wr_fire;
  assign s_axi_bresp   = 2'b00;                  // OKAY
  assign s_axi_bvalid  = bvalid_q;

  always_ff @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
      cfg_q         <= {2'd0, FMT_CPX, 1'b0, 2'd1};  // pix_floor=0,out_fmt=cpx,en=0,win=hann
      bvalid_q      <= 1'b0;
      start_pulse   <= 1'b0;
      soft_reset    <= 1'b0;
      stat_read_ack <= 1'b0;
    end else begin
      start_pulse   <= 1'b0;                     // default: pulses are 1 cycle
      soft_reset    <= 1'b0;
      stat_read_ack <= 1'b0;

      if (wr_fire) begin
        case (wr_word)
          REG_CFG: cfg_q <= s_axi_wdata[6:0];
          REG_CTL: begin
            start_pulse   <= s_axi_wdata[0];
            soft_reset    <= s_axi_wdata[1];
            stat_read_ack <= s_axi_wdata[2];
          end
          default: ;                             // ID/STATUS writes ignored
        endcase
        bvalid_q <= 1'b1;                         // response pending
      end else if (s_axi_bready && bvalid_q) begin
        bvalid_q <= 1'b0;
      end
    end
  end

  // ---- read channel -------------------------------------------------------
  logic        rvalid_q;
  logic [31:0] rdata_q;
  assign s_axi_arready = ~rvalid_q;
  assign s_axi_rresp   = 2'b00;                  // OKAY
  assign s_axi_rvalid  = rvalid_q;
  assign s_axi_rdata   = rdata_q;

  always_ff @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
      rvalid_q <= 1'b0;
      rdata_q  <= 32'b0;
    end else begin
      if (s_axi_arvalid && ~rvalid_q) begin
        case (s_axi_araddr[3:2])
          REG_ID:   rdata_q <= ID_MAGIC;
          REG_CFG:  rdata_q <= {25'b0, cfg_q};
          REG_STAT: rdata_q <= status_w;
          default:  rdata_q <= 32'b0;
        endcase
        rvalid_q <= 1'b1;
      end else if (s_axi_rready && rvalid_q) begin
        rvalid_q <= 1'b0;
      end
    end
  end
endmodule

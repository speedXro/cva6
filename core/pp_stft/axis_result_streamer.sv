`timescale 1ns / 1ps

module axis_result_streamer
  import stft128_pkg::*;
(
  input  logic                clk,
  input  logic                rst_n,

  input  logic                start,       
  input  logic [1:0]          out_fmt,     
  input  logic [1:0]          pix_floor,  
  output logic                busy,
  output logic                done,       

  output logic [LOG2N-1:0]    r_addr,
  input  logic [CPX_W-1:0]    r_rdata,

  // AXI-Stream master
  //   FMT_CPX   : {real[31:16], imag[15:0]} (signed), 128 bins
  //   FMT_PWR32 : |X|^2 = real^2 + imag^2   (unsigned 32-bit), 128 bins
  //   FMT_PIX8  : 8-bit log pixel in tdata[7:0] (upper bits 0), 64 bins (0..63)
  output logic [CPX_W-1:0]    m_axis_tdata,
  output logic                m_axis_tvalid,
  input  logic                m_axis_tready,
  output logic                m_axis_tlast
);
  typedef enum logic [1:0] {R_IDLE, R_ADDR, R_HOLD} rstate_t;
  rstate_t st;
  logic [LOG2N-1:0] idx;

  logic signed [CPX_W-1:0] re_x, im_x;
  logic        [CPX_W-1:0] power;
  logic        [7:0]       pixel;
  assign re_x  = $signed(r_rdata[CPX_W-1:DAT_W]);
  assign im_x  = $signed(r_rdata[DAT_W-1:0]);
  assign power = $unsigned(re_x * re_x) + $unsigned(im_x * im_x);
  assign pixel = logpix(power, pix_floor);

  logic [LOG2N-1:0] last_idx;
  assign last_idx = (out_fmt == FMT_PIX8) ? LOG2N'(N_PIX-1) : LOG2N'(N-1);

  assign r_addr        = idx;
  assign m_axis_tdata  = (out_fmt == FMT_PWR32) ? power
                       : (out_fmt == FMT_PIX8)  ? {{(CPX_W-8){1'b0}}, pixel}
                       :                          r_rdata;
  assign m_axis_tvalid = (st == R_HOLD);
  assign m_axis_tlast  = (st == R_HOLD) && (idx == last_idx);
  assign busy          = (st != R_IDLE);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      st <= R_IDLE; idx <= '0; done <= 1'b0;
    end else begin
      done <= 1'b0;
      unique case (st)
        R_IDLE: if (start) begin idx <= '0; st <= R_ADDR; end
        R_ADDR: st <= R_HOLD;                   
        R_HOLD: if (m_axis_tvalid && m_axis_tready) begin
                  if (idx == last_idx) begin
                    done <= 1'b1; st <= R_IDLE;
                  end else begin
                    idx <= idx + 1'b1; st <= R_ADDR;
                  end
                end
        default: st <= R_IDLE;
      endcase
    end
  end
endmodule

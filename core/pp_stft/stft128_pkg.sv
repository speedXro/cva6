`timescale 1ns / 1ps

package stft128_pkg;

  // ---- transform geometry -------------------------------------------------
  localparam N        = 128;          // FFT length
  localparam LOG2N    = 7;            // log2(N)
  localparam NWIN     = 2;            // window presets: 0=rect 1=hann

  // ---- data widths --------------------------------------------------------
  localparam SMP_W    = 16;           // AXI-S input sample width (signed)
  localparam COEF_W   = 16;           // window / twiddle width (Q15 signed)
  localparam DAT_W    = 16;           // internal real/imag storage width
  localparam CPX_W    = 2*DAT_W;      // packed {real,imag}
  localparam QFRAC    = 15;           // fractional bits of coefficients

  // ---- CV-X-IF instruction encoding --------------------------------------
  //  R-type, custom-0 opcode. funct3 selects the operation.
  localparam logic [6:0] OPC_CUSTOM0 = 7'b000_1011;   // 0x0B
  localparam logic [2:0] F3_CFG    = 3'b000;  // rd<=old_cfg ; cfg<=rs1
  localparam logic [2:0] F3_START  = 3'b001;  // one-shot frame trigger ; rd<=accepted
  localparam logic [2:0] F3_STATUS = 3'b010;  // rd<=status word
  localparam logic [2:0] F3_RESET  = 3'b011;  // soft reset ; rd<=0

  // ---- config-word (rs1) bit layout for F3_CFG ---------------------------
  //  [1:0] window_sel   0=rect 1=hann   (bit[1] reserved; only rect/hann kept)
  //  [2]   enable       1 = free-running (auto load->compute->readout loop)
  //  [4:3] out_fmt      0 = complex {real,imag}, 1 = power |X|^2 (32b),
  //                     2 = power8_log  (8-bit log pixel, bins 0..63 only)
  //  [6:5] pix_floor    log-pixel dynamic range (out_fmt=2 only):
  //                     0 = ~-48 dB (default), 1 = ~-24 dB, 2 = ~-96 dB, 3 = ~-12 dB
  localparam CFG_WSEL_LO = 0;
  localparam CFG_WSEL_HI = 1;
  localparam CFG_ENABLE  = 2;
  localparam CFG_OFMT_LO = 3;
  localparam CFG_OFMT_HI = 4;
  localparam CFG_PXFL_LO = 5;
  localparam CFG_PXFL_HI = 6;

  // out_fmt codes
  localparam [1:0] FMT_CPX   = 2'd0;   // {real,imag} 32-bit
  localparam [1:0] FMT_PWR32 = 2'd1;   // |X|^2 unsigned 32-bit
  localparam [1:0] FMT_PIX8  = 2'd2;   // 8-bit log pixel, 64 bins

  localparam N_PIX = 64;               // bins emitted in pixel mode (0..63)

  // ---- status-word layout for F3_STATUS ----------------------------------
  //  [0]     busy         (pipeline not idle)
  //  [1]     frame_done   (sticky; cleared on read)
  //  [2]     frame_full   (loader holds a complete frame)
  //  [15:8]  frame_count  (frames completed, wraps)
  localparam ST_BUSY    = 0;
  localparam ST_DONE    = 1;
  localparam ST_FULL    = 2;
  localparam ST_CNT_LO  = 8;
  localparam ST_CNT_HI  = 15;

  // ---- helpers ------------------------------------------------------------
  // arithmetic right shift by S with round-half-up (add half-LSB then floor)
  function automatic logic signed [63:0] rnd_shr
      (input logic signed [63:0] x, input integer s);
    if (s == 0) rnd_shr = x;
    else        rnd_shr = (x + (64'sd1 <<< (s-1))) >>> s;
  endfunction

  // saturate to signed DAT_W bits
  function automatic logic signed [DAT_W-1:0] sat
      (input logic signed [63:0] x);
    localparam logic signed [63:0] MX =  (64'sd1 <<< (DAT_W-1)) - 1;
    localparam logic signed [63:0] MN = -(64'sd1 <<< (DAT_W-1));
    if      (x > MX) sat = MX[DAT_W-1:0];
    else if (x < MN) sat = MN[DAT_W-1:0];
    else             sat = x[DAT_W-1:0];
  endfunction

  // reverse the low LOG2N bits of an index (natural -> bit-reversed order)
  function automatic logic [LOG2N-1:0] bitrev (input logic [LOG2N-1:0] i);
    for (int b = 0; b < LOG2N; b++) bitrev[b] = i[LOG2N-1-b];
  endfunction

  // 8-bit log pixel from a 32-bit unsigned power value |X|^2.
  //   Multiplier-free: leading-one position = exponent (~3 dB/octave), the
  //   bits just below it = mantissa. fl selects the exponent/mantissa split
  //   (dynamic range); values below the floor clamp to 0.
  //     fl=0 -> 4b exp + 4b mant (~48 dB)   fl=1 -> 3b exp + 5b mant (~24 dB)
  //     fl=2 -> 5b exp + 3b mant (~96 dB)   fl=3 -> 2b exp + 6b mant (~12 dB)
  function automatic logic [7:0] logpix
      (input logic [CPX_W-1:0] pwr, input logic [1:0] fl);
    integer i, msb, ew, mw, efloor, e;
    logic               nz;
    logic [CPX_W-1:0]   norm;
    logic [5:0]         frac6, mant;
    begin
      msb = 0; nz = 1'b0;
      for (i = 0; i < CPX_W; i++) if (pwr[i]) begin msb = i; nz = 1'b1; end
      case (fl)
        2'd0:    begin ew = 4; mw = 4; efloor = 16; end
        2'd1:    begin ew = 3; mw = 5; efloor = 24; end
        2'd2:    begin ew = 5; mw = 3; efloor = 0;  end
        default: begin ew = 2; mw = 6; efloor = 28; end
      endcase
      norm  = pwr << (CPX_W-1 - msb);       // leading 1 to bit CPX_W-1
      frac6 = norm[CPX_W-2 -: 6];           // 6 fractional bits below leading 1
      mant  = frac6 >> (6 - mw);            // keep top mw fractional bits
      if (!nz || msb < efloor) begin
        logpix = 8'd0;
      end else begin
        e = msb - efloor;
        if (e > (1 << ew) - 1) e = (1 << ew) - 1;
        logpix = (e[7:0] << mw) | (mant & ((6'd1 << mw) - 6'd1));
      end
    end
  endfunction

endpackage : stft128_pkg

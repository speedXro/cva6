`timescale 1ns / 1ps

module fft128_engine
  import stft128_pkg::*;
(
  input  logic              clk,
  input  logic              rst_n,
  input  logic              start,      // 1-cycle pulse
  output logic              busy,
  output logic              done,       // 1-cycle pulse when frame complete


  output logic [LOG2N-1:0]  a_addr,
  output logic              a_we,
  output logic [CPX_W-1:0]  a_wdata,
  input  logic [CPX_W-1:0]  a_rdata,

  output logic [LOG2N-1:0]  b_addr,
  output logic              b_we,
  output logic [CPX_W-1:0]  b_wdata,
  input  logic [CPX_W-1:0]  b_rdata
);

  logic [CPX_W-1:0] tw_rom [0:N/2-1];
  initial $readmemh("twiddle.mem", tw_rom);


  logic [2:0]        s;               // stage 0..LOG2N-1
  logic [LOG2N-2:0]  b;               // butterfly 0..N/2-1  (7 bits -> 0..63 used)

  logic [LOG2N-1:0] hspan, jj, grp, kk, p_c, q_c;
  logic [LOG2N-1:0] twidx;
  always_comb begin
    hspan = (LOG2N'(1) << s);              // butterfly half-span = 2^s
    grp   = (b >> s);                      // group index
    kk    = (grp << (s + 1));              // group base
    jj    = b & (hspan - 1);               // in-group index (0 when s==0)
    p_c   = kk + jj;
    q_c   = p_c + hspan;
    twidx = (jj << (LOG2N-1-s));           // = jj * (N/m)
  end

  logic signed [DAT_W-1:0] wr, wi;
  assign wr = tw_rom[twidx][CPX_W-1:DAT_W];
  assign wi = tw_rom[twidx][DAT_W-1:0];

  logic signed [DAT_W-1:0] ur, ui, vr, vi;
  logic signed [DAT_W-1:0] wr_q, wi_q;
  logic signed [2*DAT_W:0] tr, ti;       // twiddle-product results

  typedef enum logic [2:0] {E_IDLE, E_RD, E_CAP, E_MUL, E_WB} estate_t;
  estate_t st;

  wire last_bf = (b == (N/2-1));
  wire last_st = (s == (LOG2N-1));

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      st   <= E_IDLE; s <= '0; b <= '0;
      busy <= 1'b0;   done <= 1'b0;
    end else begin
      done <= 1'b0;
      unique case (st)
        E_IDLE: begin
          busy <= 1'b0;
          if (start) begin
            s <= '0; b <= '0; busy <= 1'b1; st <= E_RD;
          end
        end
        E_RD: begin
          st <= E_CAP;
        end
        E_CAP: begin
          ur   <= a_rdata[CPX_W-1:DAT_W];  ui <= a_rdata[DAT_W-1:0];
          vr   <= b_rdata[CPX_W-1:DAT_W];  vi <= b_rdata[DAT_W-1:0];
          wr_q <= wr;                      wi_q <= wi;
          st   <= E_MUL;
        end
        E_MUL: begin
          tr <= rnd_shr(vr*wr_q - vi*wi_q, QFRAC);
          ti <= rnd_shr(vr*wi_q + vi*wr_q, QFRAC);
          st <= E_WB;
        end
        E_WB: begin
          if (last_bf) begin
            b <= '0;
            if (last_st) begin
              done <= 1'b1; busy <= 1'b0; st <= E_IDLE;
            end else begin
              s <= s + 3'd1; st <= E_RD;
            end
          end else begin
            b <= b + 1'b1; st <= E_RD;
          end
        end
        default: st <= E_IDLE;
      endcase
    end
  end

  logic signed [DAT_W-1:0] pr, pi, qr, qi;
  assign pr = sat(rnd_shr(ur + tr, 1));
  assign pi = sat(rnd_shr(ui + ti, 1));
  assign qr = sat(rnd_shr(ur - tr, 1));
  assign qi = sat(rnd_shr(ui - ti, 1));

  assign a_addr  = p_c;
  assign b_addr  = q_c;
  assign a_we    = (st == E_WB);      // combinational: aligned with addr/data
  assign b_we    = (st == E_WB);
  assign a_wdata = {pr, pi};
  assign b_wdata = {qr, qi};

endmodule

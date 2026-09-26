`timescale 1ns / 1ps

module axis_frame_loader
  import stft128_pkg::*;
(
  input  logic                clk,
  input  logic                rst_n,

  input  logic                enable,    
  input  logic                clear,      
  input  logic [1:0]          window_sel,
  output logic                frame_full,

  // AXI-Stream slave
  input  logic signed [SMP_W-1:0] s_axis_tdata,
  input  logic                    s_axis_tvalid,
  output logic                    s_axis_tready,
  input  logic                    s_axis_tlast,   

  // frame RAM write port
  output logic [LOG2N-1:0]    w_addr,
  output logic                w_we,
  output logic [CPX_W-1:0]    w_wdata
);

  logic [COEF_W-1:0] win_rom [0:NWIN*N-1];
  initial $readmemh("window.mem", win_rom);

  logic [LOG2N-1:0] cnt;                 
  assign s_axis_tready = enable & ~frame_full;

  wire accept = s_axis_tvalid & s_axis_tready;

  logic signed [COEF_W-1:0] wcoef;
  assign wcoef = win_rom[{window_sel[0], cnt}];

  logic signed [DAT_W-1:0] xw;
  assign xw = sat(rnd_shr(s_axis_tdata * wcoef, QFRAC));

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cnt <= '0; frame_full <= 1'b0; w_we <= 1'b0;
    end else begin
      w_we <= 1'b0;
      if (clear) begin
        cnt <= '0; frame_full <= 1'b0;
      end else if (accept) begin
        w_we    <= 1'b1;
        w_addr  <= bitrev(cnt);                
        w_wdata <= {xw, {DAT_W{1'b0}}};        
        if (cnt == LOG2N'(N-1) || s_axis_tlast) begin
          frame_full <= 1'b1;
          cnt        <= '0;
        end else begin
          cnt <= cnt + 1'b1;
        end
      end
    end
  end
endmodule

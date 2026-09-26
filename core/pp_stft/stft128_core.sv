`timescale 1ns / 1ps

module stft128_core
  import stft128_pkg::*;
(
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

  input  logic [1:0]              cfg_window_sel,
  input  logic                    cfg_enable,
  input  logic [1:0]              cfg_out_fmt,
  input  logic [1:0]              cfg_pix_floor,
  input  logic                    start_pulse,
  input  logic                    soft_reset,
  input  logic                    stat_read_ack,

  output logic                    ctrl_busy,
  output logic                    frame_done,     // sticky; cleared by stat_read_ack
  output logic                    frame_full,
  output logic [7:0]              frame_count
);
  logic rstn_i;
  assign rstn_i = rst_n & ~soft_reset;  

  typedef enum logic [1:0] {P_IDLE, P_LOAD, P_COMPUTE, P_READOUT} pstate_t;
  pstate_t phase;

  logic ld_enable, ld_clear, fft_start, st_start;
  logic fft_busy, fft_done, st_busy, st_done;

  assign ctrl_busy = (phase != P_IDLE);

  always_ff @(posedge clk or negedge rstn_i) begin
    if (!rstn_i) begin
      phase <= P_IDLE; ld_clear <= 1'b0; fft_start <= 1'b0; st_start <= 1'b0;
      frame_count <= 8'd0; frame_done <= 1'b0; 
    end else begin
      ld_clear <= 1'b0; fft_start <= 1'b0; st_start <= 1'b0;
      if (stat_read_ack) frame_done <= 1'b0;
      unique case (phase)
        P_IDLE: if (start_pulse || cfg_enable) begin
                  ld_clear <= 1'b1; phase <= P_LOAD;
                end
        P_LOAD: if (frame_full && !ld_clear) begin  
                  fft_start <= 1'b1; phase <= P_COMPUTE;
                end
        P_COMPUTE: if (fft_done) begin
                  st_start <= 1'b1; phase <= P_READOUT;
                end
        P_READOUT: if (st_done) begin
                  frame_count <= frame_count + 8'd1;
                  frame_done  <= 1'b1;
                  if (cfg_enable) begin ld_clear <= 1'b1; phase <= P_LOAD; end
                  else            phase <= P_IDLE;
                end
        default: phase <= P_IDLE;
      endcase
    end
  end

  assign ld_enable = (phase == P_LOAD);

  logic [LOG2N-1:0] ram_a_addr, ram_b_addr;
  logic             ram_a_we,   ram_b_we;
  logic [CPX_W-1:0] ram_a_wdata,ram_b_wdata;
  logic [CPX_W-1:0] ram_a_rdata,ram_b_rdata;

  logic [LOG2N-1:0] ld_addr;  logic ld_we;  logic [CPX_W-1:0] ld_wdata;
  logic [LOG2N-1:0] eng_a_addr, eng_b_addr;
  logic             eng_a_we,   eng_b_we;
  logic [CPX_W-1:0] eng_a_wdata,eng_b_wdata;
  logic [LOG2N-1:0] st_addr;

  always_comb begin
    unique case (phase)
      P_LOAD: begin
        ram_a_addr = ld_addr;  ram_a_we = ld_we;  ram_a_wdata = ld_wdata;
      end
      P_COMPUTE: begin
        ram_a_addr = eng_a_addr; ram_a_we = eng_a_we; ram_a_wdata = eng_a_wdata;
      end
      P_READOUT: begin
        ram_a_addr = st_addr;  ram_a_we = 1'b0;   ram_a_wdata = '0;
      end
      default: begin
        ram_a_addr = '0; ram_a_we = 1'b0; ram_a_wdata = '0;
      end
    endcase
    ram_b_addr  = eng_b_addr;
    ram_b_we    = (phase == P_COMPUTE) ? eng_b_we : 1'b0;
    ram_b_wdata = eng_b_wdata;
  end

  cmplx_dpram u_ram (
    .clk(clk),
    .a_addr(ram_a_addr), .a_we(ram_a_we), .a_wdata(ram_a_wdata), .a_rdata(ram_a_rdata),
    .b_addr(ram_b_addr), .b_we(ram_b_we), .b_wdata(ram_b_wdata), .b_rdata(ram_b_rdata)
  );

  axis_frame_loader u_loader (
    .clk(clk), .rst_n(rstn_i),
    .enable(ld_enable), .clear(ld_clear), .window_sel(cfg_window_sel),
    .frame_full(frame_full),
    .s_axis_tdata(s_axis_tdata), .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tready(s_axis_tready), .s_axis_tlast(s_axis_tlast),
    .w_addr(ld_addr), .w_we(ld_we), .w_wdata(ld_wdata)
  );

  fft128_engine u_fft (
    .clk(clk), .rst_n(rstn_i),
    .start(fft_start), .busy(fft_busy), .done(fft_done),
    .a_addr(eng_a_addr), .a_we(eng_a_we), .a_wdata(eng_a_wdata), .a_rdata(ram_a_rdata),
    .b_addr(eng_b_addr), .b_we(eng_b_we), .b_wdata(eng_b_wdata), .b_rdata(ram_b_rdata)
  );

  axis_result_streamer u_stream (
    .clk(clk), .rst_n(rstn_i),
    .start(st_start), .out_fmt(cfg_out_fmt), .pix_floor(cfg_pix_floor),
    .busy(st_busy), .done(st_done),
    .r_addr(st_addr), .r_rdata(ram_a_rdata),
    .m_axis_tdata(m_axis_tdata), .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(m_axis_tready), .m_axis_tlast(m_axis_tlast)
  );

endmodule

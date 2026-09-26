`timescale 1ns / 1ps

module cmplx_dpram
  import stft128_pkg::*;
#(
  parameter int DEPTH = N,
  parameter int AW    = LOG2N,
  parameter int DW    = CPX_W
)(
  input  logic              clk,
  // port A
  input  logic [AW-1:0]     a_addr,
  input  logic              a_we,
  input  logic [DW-1:0]     a_wdata,
  output logic [DW-1:0]     a_rdata,
  // port B
  input  logic [AW-1:0]     b_addr,
  input  logic              b_we,
  input  logic [DW-1:0]     b_wdata,
  output logic [DW-1:0]     b_rdata
);
  logic [DW-1:0] mem [0:DEPTH-1];

  always @(posedge clk) begin
    if (a_we) mem[a_addr] <= a_wdata;
    a_rdata <= mem[a_addr];
  end

  always @(posedge clk) begin
    if (b_we) mem[b_addr] <= b_wdata;
    b_rdata <= mem[b_addr];
  end
endmodule

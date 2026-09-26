// Copyright 2017-2019 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// Author: Florian Zaruba, ETH Zurich
// Date: 19.03.2017
// Description: Ariane Top-level module

`include "cvxif_types.svh"

module ariane import ariane_pkg::*; #(
  parameter config_pkg::cva6_cfg_t CVA6Cfg = config_pkg::cva6_cfg_empty,
  parameter type rvfi_probes_instr_t = logic,
  parameter type rvfi_probes_csr_t = logic,
  parameter type rvfi_probes_t = struct packed {
    logic csr;
    logic instr;
  },
  // CVXIF Types
  localparam type readregflags_t      = `READREGFLAGS_T(CVA6Cfg),
  localparam type writeregflags_t     = `WRITEREGFLAGS_T(CVA6Cfg),
  localparam type id_t                = `ID_T(CVA6Cfg),
  localparam type hartid_t            = `HARTID_T(CVA6Cfg),
  localparam type x_compressed_req_t  = `X_COMPRESSED_REQ_T(CVA6Cfg, hartid_t),
  localparam type x_compressed_resp_t = `X_COMPRESSED_RESP_T(CVA6Cfg),
  localparam type x_issue_req_t       = `X_ISSUE_REQ_T(CVA6Cfg, hartit_t, id_t),
  localparam type x_issue_resp_t      = `X_ISSUE_RESP_T(CVA6Cfg, writeregflags_t, readregflags_t),
  localparam type x_register_t        = `X_REGISTER_T(CVA6Cfg, hartid_t, id_t, readregflags_t),
  localparam type x_commit_t          = `X_COMMIT_T(CVA6Cfg, hartid_t, id_t),
  localparam type x_result_t          = `X_RESULT_T(CVA6Cfg, hartid_t, id_t, writeregflags_t),
  localparam type cvxif_req_t         = `CVXIF_REQ_T(CVA6Cfg, x_compressed_req_t, x_issue_req_t, x_register_req_t, x_commit_t),
  localparam type cvxif_resp_t        = `CVXIF_RESP_T(CVA6Cfg, x_compressed_resp_t, x_issue_resp_t, x_result_t),
  // AXI Types
  parameter int unsigned AxiAddrWidth = ariane_axi::AddrWidth,
  parameter int unsigned AxiDataWidth = ariane_axi::DataWidth,
  parameter int unsigned AxiIdWidth   = ariane_axi::IdWidth,
  parameter type axi_ar_chan_t = ariane_axi::ar_chan_t,
  parameter type axi_aw_chan_t = ariane_axi::aw_chan_t,
  parameter type axi_w_chan_t  = ariane_axi::w_chan_t,
  parameter type noc_req_t = ariane_axi::req_t,
  parameter type noc_resp_t = ariane_axi::resp_t
) (
  input  logic                         clk_i,
  input  logic                         rst_ni,
  // Core ID, Cluster ID and boot address are considered more or less static
  input  logic [CVA6Cfg.VLEN-1:0]       boot_addr_i,  // reset boot address
  input  logic [CVA6Cfg.XLEN-1:0]       hart_id_i,    // hart id in a multicore environment (reflected in a CSR)

  // Interrupt inputs
  input  logic [1:0]                   irq_i,        // level sensitive IR lines, mip & sip (async)
  input  logic                         ipi_i,        // inter-processor interrupts (async)
  // Timer facilities
  input  logic                         time_irq_i,   // timer interrupt in (async)
  input  logic                         debug_req_i,  // debug request (async)
  // RISC-V formal interface port (`rvfi`):
  // Can be left open when formal tracing is not needed.
  output rvfi_probes_t rvfi_probes_o,
  // memory side
  output noc_req_t                     noc_req_o,
  input  noc_resp_t                    noc_resp_i,

  input  logic [ 511 : 0] m0_axis_mm2s_tdata, 
  input  logic [  63 : 0] m0_axis_mm2s_tkeep,  
  input  logic 			      m0_axis_mm2s_tvalid,          
  output logic 			      m0_axis_mm2s_tready,          
  input  logic 			      m0_axis_mm2s_tlast,           
  output logic [1023 : 0] s0_axis_s2mm_tdata, 
  output logic [ 127 : 0] s0_axis_s2mm_tkeep,  
  output logic 		        s0_axis_s2mm_tvalid,           
  input  logic 			      s0_axis_s2mm_tready,           
  output logic 			      s0_axis_s2mm_tlast,             
  
  input  logic [1023 : 0] m1_axis_mm2s_tdata, 
  input  logic [ 127 : 0] m1_axis_mm2s_tkeep,  
  input  logic 			      m1_axis_mm2s_tvalid,          
  output logic 			      m1_axis_mm2s_tready,          
  input  logic 			      m1_axis_mm2s_tlast,           
  output logic [ 511 : 0] s1_axis_s2mm_tdata, 
  output logic [  63 : 0] s1_axis_s2mm_tkeep,  
  output logic 		        s1_axis_s2mm_tvalid,           
  input  logic 			      s1_axis_s2mm_tready,           
  output logic 			      s1_axis_s2mm_tlast,             

  input  logic [  15 : 0] m2_axis_mm2s_tdata, 
  input  logic [   1 : 0] m2_axis_mm2s_tkeep,  
  input  logic            m2_axis_mm2s_tvalid,          
  output logic            m2_axis_mm2s_tready,          
  input  logic            m2_axis_mm2s_tlast,           
  output logic [  31 : 0] s2_axis_s2mm_tdata, 
  output logic [   3 : 0] s2_axis_s2mm_tkeep,  
  output logic            s2_axis_s2mm_tvalid,           
  input  logic            s2_axis_s2mm_tready,           
  output logic            s2_axis_s2mm_tlast,             

  input  logic [ 511 : 0] m3_axis_mm2s_tdata, 
  input  logic [  63 : 0] m3_axis_mm2s_tkeep,  
  input  logic            m3_axis_mm2s_tvalid,          
  output logic            m3_axis_mm2s_tready,          
  input  logic            m3_axis_mm2s_tlast,           
  output logic [ 511 : 0] s3_axis_s2mm_tdata, 
  output logic [  63 : 0] s3_axis_s2mm_tkeep,  
  output logic            s3_axis_s2mm_tvalid,           
  input  logic            s3_axis_s2mm_tready,           
  output logic            s3_axis_s2mm_tlast,             

  output logic [31 : 0] m0_axi_awaddr,
  output logic [ 2 : 0] m0_axi_awprot,
  output logic          m0_axi_awvalid,
  input  logic          m0_axi_awready,
  output logic [31 : 0] m0_axi_wdata,
  output logic [ 3 : 0] m0_axi_wstrb,
  output logic          m0_axi_wvalid,
  input  logic          m0_axi_wready,
  input  logic [ 1 : 0] m0_axi_bresp,
  input  logic          m0_axi_bvalid,
  output logic          m0_axi_bready,
  output logic [31 : 0] m0_axi_araddr,
  output logic [ 2 : 0] m0_axi_arprot,
  output logic          m0_axi_arvalid,
  input  logic          m0_axi_arready,
  input  logic [31 : 0] m0_axi_rdata,
  input  logic [ 1 : 0] m0_axi_rresp,
  input  logic          m0_axi_rvalid,
  output logic          m0_axi_rready,
  
  output logic [31 : 0] m1_axi_awaddr,
  output logic [ 2 : 0] m1_axi_awprot,
  output logic          m1_axi_awvalid,
  input  logic          m1_axi_awready,
  output logic [31 : 0] m1_axi_wdata,
  output logic [ 3 : 0] m1_axi_wstrb,
  output logic          m1_axi_wvalid,
  input  logic          m1_axi_wready,
  input  logic [ 1 : 0] m1_axi_bresp,
  input  logic          m1_axi_bvalid,
  output logic          m1_axi_bready,
  output logic [31 : 0] m1_axi_araddr,
  output logic [ 2 : 0] m1_axi_arprot,
  output logic          m1_axi_arvalid,
  input  logic          m1_axi_arready,
  input  logic [31 : 0] m1_axi_rdata,
  input  logic [ 1 : 0] m1_axi_rresp,
  input  logic          m1_axi_rvalid,
  output logic          m1_axi_rready,

  output logic [31 : 0] m2_axi_awaddr,
	output logic [ 2 : 0] m2_axi_awprot,
	output logic          m2_axi_awvalid,
	input  logic          m2_axi_awready,
	output logic [31 : 0] m2_axi_wdata,
	output logic [ 3 : 0] m2_axi_wstrb,
	output logic          m2_axi_wvalid,
	input  logic          m2_axi_wready,
	input  logic [ 1 : 0] m2_axi_bresp,
	input  logic          m2_axi_bvalid,
	output logic          m2_axi_bready,
	output logic [31 : 0] m2_axi_araddr,
	output logic [ 2 : 0] m2_axi_arprot,
	output logic          m2_axi_arvalid,
	input  logic          m2_axi_arready,
	input  logic [31 : 0] m2_axi_rdata,
	input  logic [ 1 : 0] m2_axi_rresp,
	input  logic          m2_axi_rvalid,
	output logic          m2_axi_rready,
	
	output logic [31 : 0] m3_axi_awaddr,
	output logic [ 2 : 0] m3_axi_awprot,
	output logic          m3_axi_awvalid,
	input  logic          m3_axi_awready,
	output logic [31 : 0] m3_axi_wdata,
	output logic [ 3 : 0] m3_axi_wstrb,
	output logic          m3_axi_wvalid,
	input  logic          m3_axi_wready,
	input  logic [ 1 : 0] m3_axi_bresp,
	input  logic          m3_axi_bvalid,
	output logic          m3_axi_bready,
	output logic [31 : 0] m3_axi_araddr,
	output logic [ 2 : 0] m3_axi_arprot,
	output logic          m3_axi_arvalid,
	input  logic          m3_axi_arready,
	input  logic [31 : 0] m3_axi_rdata,
	input  logic [ 1 : 0] m3_axi_rresp,
	input  logic          m3_axi_rvalid,
	output logic          m3_axi_rready,

  output logic          ad_cs_n,
  output logic          ad_sclk,
  input  logic          ad_dout,

  output logic          o_uart_tx,
  input  logic          i_uart_rx,

  output logic          da_sync_n,
  output logic          da_sclk,
  output logic          da_din

);

  cvxif_req_t  cvxif_req;
  cvxif_resp_t cvxif_resp;

  cva6 #(
    .CVA6Cfg ( CVA6Cfg ),
    .rvfi_probes_instr_t ( rvfi_probes_instr_t ),
    .rvfi_probes_csr_t ( rvfi_probes_csr_t ),
    .rvfi_probes_t ( rvfi_probes_t ),
    .axi_ar_chan_t (axi_ar_chan_t),
    .axi_aw_chan_t (axi_aw_chan_t),
    .axi_w_chan_t (axi_w_chan_t),
    .noc_req_t (noc_req_t),
    .noc_resp_t (noc_resp_t),
    .readregflags_t (readregflags_t),
    .writeregflags_t (writeregflags_t),
    .id_t (id_t),
    .hartid_t (hartid_t),
    .x_compressed_req_t (x_compressed_req_t),
    .x_compressed_resp_t (x_compressed_resp_t),
    .x_issue_req_t (x_issue_req_t),
    .x_issue_resp_t (x_issue_resp_t),
    .x_register_t (x_register_t),
    .x_commit_t (x_commit_t),
    .x_result_t (x_result_t),
    .cvxif_req_t (cvxif_req_t),
    .cvxif_resp_t (cvxif_resp_t)
  ) i_cva6 (
    .clk_i                ( clk_i                     ),
    .rst_ni               ( rst_ni                    ),
    .boot_addr_i          ( boot_addr_i               ),
    .hart_id_i            ( hart_id_i                 ),
    .irq_i                ( irq_i                     ),
    .ipi_i                ( ipi_i                     ),
    .time_irq_i           ( time_irq_i                ),
    .debug_req_i          ( debug_req_i               ),
    .rvfi_probes_o        ( rvfi_probes_o             ),
    .cvxif_req_o          ( cvxif_req                 ),
    .cvxif_resp_i         ( cvxif_resp                ),
    .noc_req_o            ( noc_req_o                 ),
    .noc_resp_i           ( noc_resp_i                )
  );



  /*if (CVA6Cfg.CvxifEn) begin: gen_cvxif
    if (CVA6Cfg.CoproType == config_pkg::COPRO_EXAMPLE) begin: gen_COPRO_EXAMPLE
      cvxif_example_coprocessor #(
        .NrRgprPorts (CVA6Cfg.NrRgprPorts),
        .XLEN (CVA6Cfg.XLEN),
        .readregflags_t (readregflags_t),
        .writeregflags_t (writeregflags_t),
        .id_t (id_t),
        .hartid_t (hartid_t),
        .x_compressed_req_t (x_compressed_req_t),
        .x_compressed_resp_t (x_compressed_resp_t),
        .x_issue_req_t (x_issue_req_t),
        .x_issue_resp_t (x_issue_resp_t),
        .x_register_t (x_register_t),
        .x_commit_t (x_commit_t),
        .x_result_t (x_result_t),
        .cvxif_req_t (cvxif_req_t),
        .cvxif_resp_t (cvxif_resp_t)
      ) i_cvxif_coprocessor (
        .clk_i                ( clk_i                          ),
        .rst_ni               ( rst_ni                         ),
        .cvxif_req_i          ( cvxif_req                      ),
        .cvxif_resp_o         ( cvxif_resp                     )
      );
    end else begin: gen_COPRO_NONE
      assign cvxif_resp = '{compressed_ready: 1'b1, issue_ready: 1'b1, register_ready: 1'b1, default: '0};
    end
  end else begin: gen_no_cvxif
    assign cvxif_resp = '0;
  end*/

  if (CVA6Cfg.CvxifEn) begin : gen_rvexp_coprocessor
    rvexp_coprocessor #(
      .NrRgprPorts (CVA6Cfg.NrRgprPorts),
      .XLEN (CVA6Cfg.XLEN),
      .X_HARTID_WIDTH(CVA6Cfg.X_HARTID_WIDTH),
      .X_ID_WIDTH(CVA6Cfg.X_ID_WIDTH),
      .X_DUALWRITE(CVA6Cfg.X_DUALWRITE),
      .X_NUM_RS(CVA6Cfg.X_NUM_RS),

      .readregflags_t (readregflags_t),
      .writeregflags_t (writeregflags_t),
      .id_t (id_t),
      .hartid_t (hartid_t),
      .x_compressed_req_t (x_compressed_req_t),
      .x_compressed_resp_t (x_compressed_resp_t),
      .x_issue_req_t (x_issue_req_t),
      .x_issue_resp_t (x_issue_resp_t),
      .x_register_t (x_register_t),
      .x_commit_t (x_commit_t),
      .x_result_t (x_result_t),
      .cvxif_req_t (cvxif_req_t),
      .cvxif_resp_t (cvxif_resp_t)
    ) i_rvexp_coprocessor (
      .clk_i                ( clk_i                          ),
      .rst_ni               ( rst_ni                         ),
      
      .cvxif_req_i          ( cvxif_req                      ),
      .cvxif_resp_o         ( cvxif_resp                     ),

      .m0_axis_mm2s_tdata(m0_axis_mm2s_tdata),
      .m0_axis_mm2s_tkeep(m0_axis_mm2s_tkeep),
      .m0_axis_mm2s_tvalid(m0_axis_mm2s_tvalid),
      .m0_axis_mm2s_tready(m0_axis_mm2s_tready),
      .m0_axis_mm2s_tlast(m0_axis_mm2s_tlast),
      .s0_axis_s2mm_tdata(s0_axis_s2mm_tdata),
      .s0_axis_s2mm_tkeep(s0_axis_s2mm_tkeep),
      .s0_axis_s2mm_tvalid(s0_axis_s2mm_tvalid),
      .s0_axis_s2mm_tready(s0_axis_s2mm_tready),
      .s0_axis_s2mm_tlast(s0_axis_s2mm_tlast),
	  
	    .m1_axis_mm2s_tdata(m1_axis_mm2s_tdata),
      .m1_axis_mm2s_tkeep(m1_axis_mm2s_tkeep),
      .m1_axis_mm2s_tvalid(m1_axis_mm2s_tvalid),
      .m1_axis_mm2s_tready(m1_axis_mm2s_tready),
      .m1_axis_mm2s_tlast(m1_axis_mm2s_tlast),
      .s1_axis_s2mm_tdata(s1_axis_s2mm_tdata),
      .s1_axis_s2mm_tkeep(s1_axis_s2mm_tkeep),
      .s1_axis_s2mm_tvalid(s1_axis_s2mm_tvalid),
      .s1_axis_s2mm_tready(s1_axis_s2mm_tready),
      .s1_axis_s2mm_tlast(s1_axis_s2mm_tlast),

      .m2_axis_mm2s_tdata(m2_axis_mm2s_tdata),
      .m2_axis_mm2s_tkeep(m2_axis_mm2s_tkeep),
      .m2_axis_mm2s_tvalid(m2_axis_mm2s_tvalid),
      .m2_axis_mm2s_tready(m2_axis_mm2s_tready),
      .m2_axis_mm2s_tlast(m2_axis_mm2s_tlast),
      .s2_axis_s2mm_tdata(s2_axis_s2mm_tdata),
      .s2_axis_s2mm_tkeep(s2_axis_s2mm_tkeep),
      .s2_axis_s2mm_tvalid(s2_axis_s2mm_tvalid),
      .s2_axis_s2mm_tready(s2_axis_s2mm_tready),
      .s2_axis_s2mm_tlast(s2_axis_s2mm_tlast),

      .m3_axis_mm2s_tdata(m3_axis_mm2s_tdata),
      .m3_axis_mm2s_tkeep(m3_axis_mm2s_tkeep),
      .m3_axis_mm2s_tvalid(m3_axis_mm2s_tvalid),
      .m3_axis_mm2s_tready(m3_axis_mm2s_tready),
      .m3_axis_mm2s_tlast(m3_axis_mm2s_tlast),
      .s3_axis_s2mm_tdata(s3_axis_s2mm_tdata),
      .s3_axis_s2mm_tkeep(s3_axis_s2mm_tkeep),
      .s3_axis_s2mm_tvalid(s3_axis_s2mm_tvalid),
      .s3_axis_s2mm_tready(s3_axis_s2mm_tready),
      .s3_axis_s2mm_tlast(s3_axis_s2mm_tlast),

      .m0_axi_awaddr(m0_axi_awaddr),
      .m0_axi_awprot(m0_axi_awprot),
      .m0_axi_awvalid(m0_axi_awvalid),
      .m0_axi_awready(m0_axi_awready),
      .m0_axi_wdata(m0_axi_wdata),
      .m0_axi_wstrb(m0_axi_wstrb),
      .m0_axi_wvalid(m0_axi_wvalid),
      .m0_axi_wready(m0_axi_wready),
      .m0_axi_bresp(m0_axi_bresp),
      .m0_axi_bvalid(m0_axi_bvalid),
      .m0_axi_bready(m0_axi_bready),
      .m0_axi_araddr(m0_axi_araddr),
      .m0_axi_arprot(m0_axi_arprot),
      .m0_axi_arvalid(m0_axi_arvalid),
      .m0_axi_arready(m0_axi_arready),
      .m0_axi_rdata(m0_axi_rdata),
      .m0_axi_rresp(m0_axi_rresp),
      .m0_axi_rvalid(m0_axi_rvalid),
      .m0_axi_rready(m0_axi_rready),
	  
	    .m1_axi_awaddr(m1_axi_awaddr),
      .m1_axi_awprot(m1_axi_awprot),
      .m1_axi_awvalid(m1_axi_awvalid),
      .m1_axi_awready(m1_axi_awready),
      .m1_axi_wdata(m1_axi_wdata),
      .m1_axi_wstrb(m1_axi_wstrb),
      .m1_axi_wvalid(m1_axi_wvalid),
      .m1_axi_wready(m1_axi_wready),
      .m1_axi_bresp(m1_axi_bresp),
      .m1_axi_bvalid(m1_axi_bvalid),
      .m1_axi_bready(m1_axi_bready),
      .m1_axi_araddr(m1_axi_araddr),
      .m1_axi_arprot(m1_axi_arprot),
      .m1_axi_arvalid(m1_axi_arvalid),
      .m1_axi_arready(m1_axi_arready),
      .m1_axi_rdata(m1_axi_rdata),
      .m1_axi_rresp(m1_axi_rresp),
      .m1_axi_rvalid(m1_axi_rvalid),
      .m1_axi_rready(m1_axi_rready),

      .m2_axi_awaddr(m2_axi_awaddr),
      .m2_axi_awprot(m2_axi_awprot),
      .m2_axi_awvalid(m2_axi_awvalid),
      .m2_axi_awready(m2_axi_awready),
      .m2_axi_wdata(m2_axi_wdata),
      .m2_axi_wstrb(m2_axi_wstrb),
      .m2_axi_wvalid(m2_axi_wvalid),
      .m2_axi_wready(m2_axi_wready),
      .m2_axi_bresp(m2_axi_bresp),
      .m2_axi_bvalid(m2_axi_bvalid),
      .m2_axi_bready(m2_axi_bready),
      .m2_axi_araddr(m2_axi_araddr),
      .m2_axi_arprot(m2_axi_arprot),
      .m2_axi_arvalid(m2_axi_arvalid),
      .m2_axi_arready(m2_axi_arready),
      .m2_axi_rdata(m2_axi_rdata),
      .m2_axi_rresp(m2_axi_rresp),
      .m2_axi_rvalid(m2_axi_rvalid),
      .m2_axi_rready(m2_axi_rready),

      .m3_axi_awaddr(m3_axi_awaddr),
      .m3_axi_awprot(m3_axi_awprot),
      .m3_axi_awvalid(m3_axi_awvalid),
      .m3_axi_awready(m3_axi_awready),
      .m3_axi_wdata(m3_axi_wdata),
      .m3_axi_wstrb(m3_axi_wstrb),
      .m3_axi_wvalid(m3_axi_wvalid),
      .m3_axi_wready(m3_axi_wready),
      .m3_axi_bresp(m3_axi_bresp),
      .m3_axi_bvalid(m3_axi_bvalid),
      .m3_axi_bready(m3_axi_bready),
      .m3_axi_araddr(m3_axi_araddr),
      .m3_axi_arprot(m3_axi_arprot),
      .m3_axi_arvalid(m3_axi_arvalid),
      .m3_axi_arready(m3_axi_arready),
      .m3_axi_rdata(m3_axi_rdata),
      .m3_axi_rresp(m3_axi_rresp),
      .m3_axi_rvalid(m3_axi_rvalid),
      .m3_axi_rready(m3_axi_rready),

      .ad_cs_n(ad_cs_n),
      .ad_sclk(ad_sclk),
      .ad_dout(ad_dout),

      .o_uart_tx(o_uart_tx),
      .i_uart_rx(i_uart_rx),

      .da_sync_n(da_sync_n),
      .da_sclk(da_sclk),
      .da_din(da_din)

      //.cvxif_busy(cvxif_busy)
    );
  end else begin
    always_comb begin
      cvxif_resp = '0;
      cvxif_resp.compressed_ready = 1'b1;
      cvxif_resp.issue_ready = 1'b1;
      cvxif_resp.register_ready = 1'b1;
    end
  end


endmodule // ariane

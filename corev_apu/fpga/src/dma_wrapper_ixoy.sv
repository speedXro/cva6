`include "register_interface/assign.svh"
`include "register_interface/typedef.svh"
`include "kcu116.svh"

`define KCU116

module dma_wrapper_ixoy #(
    parameter int unsigned AXIS_MM2S_DATA_WIDTH = 512,
    localparam int unsigned AXIS_MM2S_KEEP_WIDTH = AXIS_MM2S_DATA_WIDTH/8,

    parameter int unsigned AXIS_S2MM_DATA_WIDTH = 512,
    localparam int unsigned AXIS_S2MM_KEEP_WIDTH = AXIS_S2MM_DATA_WIDTH/8
)(


    input  logic       clk_i,
    input  logic       rst_ni,

    AXI_BUS.Master      mm_axi,

    //AXIS
    output logic [AXIS_MM2S_DATA_WIDTH-1 : 0] m_axis_mm2s_tdata,
    output logic [AXIS_MM2S_KEEP_WIDTH-1 : 0] m_axis_mm2s_tkeep,  
    output logic m_axis_mm2s_tvalid,         
    input  logic m_axis_mm2s_tready,          
    output logic m_axis_mm2s_tlast,           

    input  logic [AXIS_S2MM_DATA_WIDTH-1 : 0] s_axis_s2mm_tdata, 
    input  logic [AXIS_S2MM_KEEP_WIDTH-1 : 0] s_axis_s2mm_tkeep,  
    input  logic s_axis_s2mm_tvalid,           
    output logic s_axis_s2mm_tready,           
    input  logic s_axis_s2mm_tlast,           

    //AXI Lite
    input logic [31 : 0] m_axi_awaddr,
	input logic [ 2 : 0] m_axi_awprot,
	input logic          m_axi_awvalid,
	output  logic          m_axi_awready,

	input logic [31 : 0] m_axi_wdata,
	input logic [ 3 : 0] m_axi_wstrb,
	input logic          m_axi_wvalid,
	output  logic          m_axi_wready,
	
    output  logic [ 1 : 0] m_axi_bresp,
	output  logic          m_axi_bvalid,
	input logic          m_axi_bready,
	
    input logic [31 : 0] m_axi_araddr,
	input logic [ 2 : 0] m_axi_arprot,
	input logic          m_axi_arvalid,
	output  logic          m_axi_arready,
	
    output  logic [31 : 0] m_axi_rdata,
	output  logic [ 1 : 0] m_axi_rresp,
	output  logic          m_axi_rvalid,
	input logic          m_axi_rready
);

    logic [6 : 0]   dcmm_axi_awid;
    logic [63 : 0]  dcmm_axi_awaddr;
    logic [7 : 0]   dcmm_axi_awlen;
    logic [2 : 0]   dcmm_axi_awsize;
    logic [1 : 0]   dcmm_axi_awburst;
    logic [0 : 0]   dcmm_axi_awlock;
    logic [3 : 0]   dcmm_axi_awcache;
    logic [2 : 0]   dcmm_axi_awprot;
    logic [3 : 0]   dcmm_axi_awregion;
    logic [3 : 0]   dcmm_axi_awqos;
    logic           dcmm_axi_awvalid;
    logic           dcmm_axi_awready;
    logic [AXIS_S2MM_DATA_WIDTH-1 : 0] dcmm_axi_wdata;
    logic [AXIS_S2MM_KEEP_WIDTH-1 : 0]  dcmm_axi_wstrb;
    logic           dcmm_axi_wlast;
    logic           dcmm_axi_wvalid;
    logic           dcmm_axi_wready;
    logic [6 : 0]   dcmm_axi_bid;
    logic [1 : 0]   dcmm_axi_bresp;
    logic           dcmm_axi_bvalid;
    logic           dcmm_axi_bready;

    logic [6 : 0]   dcmm_axi_arid;
    logic [63 : 0]  dcmm_axi_araddr;
    logic [7 : 0]   dcmm_axi_arlen;
    logic [2 : 0]   dcmm_axi_arsize;
    logic [1 : 0]   dcmm_axi_arburst;
    logic [0 : 0]   dcmm_axi_arlock;
    logic [3 : 0]   dcmm_axi_arcache;
    logic [2 : 0]   dcmm_axi_arprot;
    logic [3 : 0]   dcmm_axi_arregion;
    logic [3 : 0]   dcmm_axi_arqos;
    logic           dcmm_axi_arvalid;
    logic           dcmm_axi_arready;
    logic [6 : 0]   dcmm_axi_rid;
    logic [AXIS_MM2S_DATA_WIDTH-1 : 0] dcmm_axi_rdata;
    logic [1 : 0]   dcmm_axi_rresp;
    logic           dcmm_axi_rlast;
    logic           dcmm_axi_rvalid;
    logic           dcmm_axi_rready;

    generate
        if(AXIS_MM2S_DATA_WIDTH == 512) begin
            xlnx_axi_dma_512_1024 i_xlnx_axi_dma_512_1024 (
                .s_axi_lite_aclk(clk_i),                // input wire s_axi_lite_aclk
                .m_axi_mm2s_aclk(clk_i),                // input wire m_axi_mm2s_aclk
                .m_axi_s2mm_aclk(clk_i),                // input wire m_axi_s2mm_aclk

                .axi_resetn(rst_ni),                          // input wire axi_resetn

                .s_axi_lite_awvalid(m_axi_awvalid),          // input wire s_axi_lite_awvalid
                .s_axi_lite_awready(m_axi_awready),          // output wire s_axi_lite_awready
                .s_axi_lite_awaddr(m_axi_awaddr),            // input wire [9 : 0] s_axi_lite_awaddr
                .s_axi_lite_wvalid(m_axi_wvalid),            // input wire s_axi_lite_wvalid
                .s_axi_lite_wready(m_axi_wready),            // output wire s_axi_lite_wready
                .s_axi_lite_wdata(m_axi_wdata),              // input wire [31 : 0] s_axi_lite_wdata
                .s_axi_lite_bresp(m_axi_bresp),              // output wire [1 : 0] s_axi_lite_bresp
                .s_axi_lite_bvalid(m_axi_bvalid),            // output wire s_axi_lite_bvalid
                .s_axi_lite_bready(m_axi_bready),            // input wire s_axi_lite_bready
                .s_axi_lite_arvalid(m_axi_arvalid),          // input wire s_axi_lite_arvalid
                .s_axi_lite_arready(m_axi_arready),          // output wire s_axi_lite_arready
                .s_axi_lite_araddr(m_axi_araddr),            // input wire [9 : 0] s_axi_lite_araddr
                .s_axi_lite_rvalid(m_axi_rvalid),            // output wire s_axi_lite_rvalid
                .s_axi_lite_rready(m_axi_rready),            // input wire s_axi_lite_rready
                .s_axi_lite_rdata(m_axi_rdata),              // output wire [31 : 0] s_axi_lite_rdata
                .s_axi_lite_rresp(m_axi_rresp),              // output wire [1 : 0] s_axi_lite_rresp
                
                .m_axi_mm2s_araddr(dcmm_axi_araddr),            // output wire [63 : 0] m_axi_mm2s_araddr
                .m_axi_mm2s_arlen(dcmm_axi_arlen),              // output wire [7 : 0] m_axi_mm2s_arlen
                .m_axi_mm2s_arsize(dcmm_axi_arsize),            // output wire [2 : 0] m_axi_mm2s_arsize
                .m_axi_mm2s_arburst(dcmm_axi_arburst),          // output wire [1 : 0] m_axi_mm2s_arburst
                .m_axi_mm2s_arprot(dcmm_axi_arprot),            // output wire [2 : 0] m_axi_mm2s_arprot
                .m_axi_mm2s_arcache(dcmm_axi_arcache),          // output wire [3 : 0] m_axi_mm2s_arcache
                .m_axi_mm2s_arvalid(dcmm_axi_arvalid),          // output wire m_axi_mm2s_arvalid
                .m_axi_mm2s_arready(dcmm_axi_arready),          // input wire m_axi_mm2s_arready
                .m_axi_mm2s_rdata(dcmm_axi_rdata),              // input wire [63 : 0] m_axi_mm2s_rdata
                .m_axi_mm2s_rresp(dcmm_axi_rresp),              // input wire [1 : 0] m_axi_mm2s_rresp
                .m_axi_mm2s_rlast(dcmm_axi_rlast),              // input wire m_axi_mm2s_rlast
                .m_axi_mm2s_rvalid(dcmm_axi_rvalid),            // input wire m_axi_mm2s_rvalid
                .m_axi_mm2s_rready(dcmm_axi_rready),            // output wire m_axi_mm2s_rready

                .m_axi_s2mm_awaddr(dcmm_axi_awaddr),            // output wire [63 : 0] m_axi_s2mm_awaddr
                .m_axi_s2mm_awlen(dcmm_axi_awlen),              // output wire [7 : 0] m_axi_s2mm_awlen
                .m_axi_s2mm_awsize(dcmm_axi_awsize),            // output wire [2 : 0] m_axi_s2mm_awsize
                .m_axi_s2mm_awburst(dcmm_axi_awburst),          // output wire [1 : 0] m_axi_s2mm_awburst
                .m_axi_s2mm_awprot(dcmm_axi_awprot),            // output wire [2 : 0] m_axi_s2mm_awprot
                .m_axi_s2mm_awcache(dcmm_axi_awcache),          // output wire [3 : 0] m_axi_s2mm_awcache
                .m_axi_s2mm_awvalid(dcmm_axi_awvalid),          // output wire m_axi_s2mm_awvalid
                .m_axi_s2mm_awready(dcmm_axi_awready),          // input wire m_axi_s2mm_awready
                .m_axi_s2mm_wdata(dcmm_axi_wdata),              // output wire [63 : 0] m_axi_s2mm_wdata
                .m_axi_s2mm_wstrb(dcmm_axi_wstrb),              // output wire [7 : 0] m_axi_s2mm_wstrb
                .m_axi_s2mm_wlast(dcmm_axi_wlast),              // output wire m_axi_s2mm_wlast
                .m_axi_s2mm_wvalid(dcmm_axi_wvalid),            // output wire m_axi_s2mm_wvalid
                .m_axi_s2mm_wready(dcmm_axi_wready),            // input wire m_axi_s2mm_wready
                .m_axi_s2mm_bresp(dcmm_axi_bresp),              // input wire [1 : 0] m_axi_s2mm_bresp
                .m_axi_s2mm_bvalid(dcmm_axi_bvalid),            // input wire m_axi_s2mm_bvalid
                .m_axi_s2mm_bready(dcmm_axi_bready),            // output wire m_axi_s2mm_bready
                
                .mm2s_prmry_reset_out_n(),  // output wire mm2s_prmry_reset_out_n
                .s2mm_prmry_reset_out_n(),  // output wire s2mm_prmry_reset_out_n

                .m_axis_mm2s_tdata(m_axis_mm2s_tdata),            // output wire [63 : 0] m_axis_mm2s_tdata
                .m_axis_mm2s_tkeep(m_axis_mm2s_tkeep),            // output wire [7 : 0] m_axis_mm2s_tkeep
                .m_axis_mm2s_tvalid(m_axis_mm2s_tvalid),          // output wire m_axis_mm2s_tvalid
                .m_axis_mm2s_tready(m_axis_mm2s_tready),          // input wire m_axis_mm2s_tready
                .m_axis_mm2s_tlast(m_axis_mm2s_tlast),            // output wire m_axis_mm2s_tlast

                .s_axis_s2mm_tdata(s_axis_s2mm_tdata),            // input wire [63 : 0] s_axis_s2mm_tdata
                .s_axis_s2mm_tkeep(s_axis_s2mm_tkeep),            // input wire [7 : 0] s_axis_s2mm_tkeep
                .s_axis_s2mm_tvalid(s_axis_s2mm_tvalid),          // input wire s_axis_s2mm_tvalid
                .s_axis_s2mm_tready(s_axis_s2mm_tready),          // output wire s_axis_s2mm_tready
                .s_axis_s2mm_tlast(s_axis_s2mm_tlast),            // input wire s_axis_s2mm_tlast
                
                .mm2s_introut(),                      // output wire mm2s_introut
                .s2mm_introut(),                      // output wire s2mm_introut
                
                .axi_dma_tstvec()                  // output wire [31 : 0] axi_dma_tstvec
                );
        end
        else begin
            xlnx_axi_dma_1024_512 i_xlnx_axi_dma_1024_512 (
                .s_axi_lite_aclk(clk_i),                // input wire s_axi_lite_aclk
                .m_axi_mm2s_aclk(clk_i),                // input wire m_axi_mm2s_aclk
                .m_axi_s2mm_aclk(clk_i),                // input wire m_axi_s2mm_aclk

                .axi_resetn(rst_ni),                          // input wire axi_resetn

                .s_axi_lite_awvalid(m_axi_awvalid),          // input wire s_axi_lite_awvalid
                .s_axi_lite_awready(m_axi_awready),          // output wire s_axi_lite_awready
                .s_axi_lite_awaddr(m_axi_awaddr),            // input wire [9 : 0] s_axi_lite_awaddr
                .s_axi_lite_wvalid(m_axi_wvalid),            // input wire s_axi_lite_wvalid
                .s_axi_lite_wready(m_axi_wready),            // output wire s_axi_lite_wready
                .s_axi_lite_wdata(m_axi_wdata),              // input wire [31 : 0] s_axi_lite_wdata
                .s_axi_lite_bresp(m_axi_bresp),              // output wire [1 : 0] s_axi_lite_bresp
                .s_axi_lite_bvalid(m_axi_bvalid),            // output wire s_axi_lite_bvalid
                .s_axi_lite_bready(m_axi_bready),            // input wire s_axi_lite_bready
                .s_axi_lite_arvalid(m_axi_arvalid),          // input wire s_axi_lite_arvalid
                .s_axi_lite_arready(m_axi_arready),          // output wire s_axi_lite_arready
                .s_axi_lite_araddr(m_axi_araddr),            // input wire [9 : 0] s_axi_lite_araddr
                .s_axi_lite_rvalid(m_axi_rvalid),            // output wire s_axi_lite_rvalid
                .s_axi_lite_rready(m_axi_rready),            // input wire s_axi_lite_rready
                .s_axi_lite_rdata(m_axi_rdata),              // output wire [31 : 0] s_axi_lite_rdata
                .s_axi_lite_rresp(m_axi_rresp),              // output wire [1 : 0] s_axi_lite_rresp
                
                .m_axi_mm2s_araddr(dcmm_axi_araddr),            // output wire [63 : 0] m_axi_mm2s_araddr
                .m_axi_mm2s_arlen(dcmm_axi_arlen),              // output wire [7 : 0] m_axi_mm2s_arlen
                .m_axi_mm2s_arsize(dcmm_axi_arsize),            // output wire [2 : 0] m_axi_mm2s_arsize
                .m_axi_mm2s_arburst(dcmm_axi_arburst),          // output wire [1 : 0] m_axi_mm2s_arburst
                .m_axi_mm2s_arprot(dcmm_axi_arprot),            // output wire [2 : 0] m_axi_mm2s_arprot
                .m_axi_mm2s_arcache(dcmm_axi_arcache),          // output wire [3 : 0] m_axi_mm2s_arcache
                .m_axi_mm2s_arvalid(dcmm_axi_arvalid),          // output wire m_axi_mm2s_arvalid
                .m_axi_mm2s_arready(dcmm_axi_arready),          // input wire m_axi_mm2s_arready
                .m_axi_mm2s_rdata(dcmm_axi_rdata),              // input wire [63 : 0] m_axi_mm2s_rdata
                .m_axi_mm2s_rresp(dcmm_axi_rresp),              // input wire [1 : 0] m_axi_mm2s_rresp
                .m_axi_mm2s_rlast(dcmm_axi_rlast),              // input wire m_axi_mm2s_rlast
                .m_axi_mm2s_rvalid(dcmm_axi_rvalid),            // input wire m_axi_mm2s_rvalid
                .m_axi_mm2s_rready(dcmm_axi_rready),            // output wire m_axi_mm2s_rready

                .m_axi_s2mm_awaddr(dcmm_axi_awaddr),            // output wire [63 : 0] m_axi_s2mm_awaddr
                .m_axi_s2mm_awlen(dcmm_axi_awlen),              // output wire [7 : 0] m_axi_s2mm_awlen
                .m_axi_s2mm_awsize(dcmm_axi_awsize),            // output wire [2 : 0] m_axi_s2mm_awsize
                .m_axi_s2mm_awburst(dcmm_axi_awburst),          // output wire [1 : 0] m_axi_s2mm_awburst
                .m_axi_s2mm_awprot(dcmm_axi_awprot),            // output wire [2 : 0] m_axi_s2mm_awprot
                .m_axi_s2mm_awcache(dcmm_axi_awcache),          // output wire [3 : 0] m_axi_s2mm_awcache
                .m_axi_s2mm_awvalid(dcmm_axi_awvalid),          // output wire m_axi_s2mm_awvalid
                .m_axi_s2mm_awready(dcmm_axi_awready),          // input wire m_axi_s2mm_awready
                .m_axi_s2mm_wdata(dcmm_axi_wdata),              // output wire [63 : 0] m_axi_s2mm_wdata
                .m_axi_s2mm_wstrb(dcmm_axi_wstrb),              // output wire [7 : 0] m_axi_s2mm_wstrb
                .m_axi_s2mm_wlast(dcmm_axi_wlast),              // output wire m_axi_s2mm_wlast
                .m_axi_s2mm_wvalid(dcmm_axi_wvalid),            // output wire m_axi_s2mm_wvalid
                .m_axi_s2mm_wready(dcmm_axi_wready),            // input wire m_axi_s2mm_wready
                .m_axi_s2mm_bresp(dcmm_axi_bresp),              // input wire [1 : 0] m_axi_s2mm_bresp
                .m_axi_s2mm_bvalid(dcmm_axi_bvalid),            // input wire m_axi_s2mm_bvalid
                .m_axi_s2mm_bready(dcmm_axi_bready),            // output wire m_axi_s2mm_bready
                
                .mm2s_prmry_reset_out_n(),  // output wire mm2s_prmry_reset_out_n
                .s2mm_prmry_reset_out_n(),  // output wire s2mm_prmry_reset_out_n

                .m_axis_mm2s_tdata(m_axis_mm2s_tdata),            // output wire [63 : 0] m_axis_mm2s_tdata
                .m_axis_mm2s_tkeep(m_axis_mm2s_tkeep),            // output wire [7 : 0] m_axis_mm2s_tkeep
                .m_axis_mm2s_tvalid(m_axis_mm2s_tvalid),          // output wire m_axis_mm2s_tvalid
                .m_axis_mm2s_tready(m_axis_mm2s_tready),          // input wire m_axis_mm2s_tready
                .m_axis_mm2s_tlast(m_axis_mm2s_tlast),            // output wire m_axis_mm2s_tlast

                .s_axis_s2mm_tdata(s_axis_s2mm_tdata),            // input wire [63 : 0] s_axis_s2mm_tdata
                .s_axis_s2mm_tkeep(s_axis_s2mm_tkeep),            // input wire [7 : 0] s_axis_s2mm_tkeep
                .s_axis_s2mm_tvalid(s_axis_s2mm_tvalid),          // input wire s_axis_s2mm_tvalid
                .s_axis_s2mm_tready(s_axis_s2mm_tready),          // output wire s_axis_s2mm_tready
                .s_axis_s2mm_tlast(s_axis_s2mm_tlast),            // input wire s_axis_s2mm_tlast
                
                .mm2s_introut(),                      // output wire mm2s_introut
                .s2mm_introut(),                      // output wire s2mm_introut
                
                .axi_dma_tstvec()                  // output wire [31 : 0] axi_dma_tstvec
                );

        end
    endgenerate

        generate
            if(AXIS_MM2S_DATA_WIDTH == 1024) begin
                xlnx_axi_dwidth_converter_1024_64 i_dwc_1024_64_mm2s (

                    .s_axi_aclk(clk_i),          // input wire s_axi_aclk
                    .s_axi_aresetn(rst_ni),    // input wire s_axi_aresetn

                    //Write Interface
                    .m_axi_awaddr(),      // output wire [63 : 0] m_axi_awaddr
                    .m_axi_awlen(),        // output wire [7 : 0] m_axi_awlen
                    .m_axi_awsize(),      // output wire [2 : 0] m_axi_awsize
                    .m_axi_awburst(),    // output wire [1 : 0] m_axi_awburst
                    .m_axi_awlock(),      // output wire [0 : 0] m_axi_awlock
                    .m_axi_awcache(),    // output wire [3 : 0] m_axi_awcache
                    .m_axi_awprot(),      // output wire [2 : 0] m_axi_awprot
                    .m_axi_awregion(),  // output wire [3 : 0] m_axi_awregion
                    .m_axi_awqos(),        // output wire [3 : 0] m_axi_awqos
                    .m_axi_awvalid(),    // output wire m_axi_awvalid
                    .m_axi_awready(0),    // input wire m_axi_awready
                    
                    .m_axi_wdata(),        // output wire [63 : 0] m_axi_wdata
                    .m_axi_wstrb(),        // output wire [7 : 0] m_axi_wstrb
                    .m_axi_wlast(),        // output wire m_axi_wlast
                    .m_axi_wvalid(),      // output wire m_axi_wvalid
                    .m_axi_wready(0),      // input wire m_axi_wready
                    .m_axi_bresp(0),        // input wire [1 : 0] m_axi_bresp
                    .m_axi_bvalid(0),      // input wire m_axi_bvalid
                    .m_axi_bready(),      // output wire m_axi_bready

                    // Read Interface
                    .m_axi_araddr(mm_axi.ar_addr),      // output wire [63 : 0] m_axi_araddr
                    .m_axi_arlen(mm_axi.ar_len),        // output wire [7 : 0] m_axi_arlen
                    .m_axi_arsize(mm_axi.ar_size),      // output wire [2 : 0] m_axi_arsize
                    .m_axi_arburst(mm_axi.ar_burst),    // output wire [1 : 0] m_axi_arburst
                    .m_axi_arlock(),      // output wire [0 : 0] m_axi_arlock
                    .m_axi_arcache(mm_axi.ar_cache),    // output wire [3 : 0] m_axi_arcache
                    .m_axi_arprot(mm_axi.ar_prot),      // output wire [2 : 0] m_axi_arprot
                    .m_axi_arregion(),  // output wire [3 : 0] m_axi_arregion
                    .m_axi_arqos(),        // output wire [3 : 0] m_axi_arqos
                    .m_axi_arvalid(mm_axi.ar_valid),    // output wire m_axi_arvalid
                    .m_axi_arready(mm_axi.ar_ready),    // input wire m_axi_arready
                    .m_axi_rdata(mm_axi.r_data),        // input wire [63 : 0] m_axi_rdata
                    .m_axi_rresp(mm_axi.r_resp),        // input wire [1 : 0] m_axi_rresp
                    .m_axi_rlast(mm_axi.r_last),        // input wire m_axi_rlast
                    .m_axi_rvalid(mm_axi.r_valid),      // input wire m_axi_rvalid
                    .m_axi_rready(mm_axi.r_ready),      // output wire m_axi_rready

                    //Write Interfaces
                    .s_axi_awid('0),          // input wire [5 : 0] s_axi_awid
                    .s_axi_awaddr('0),      // input wire [63 : 0] s_axi_awaddr
                    .s_axi_awlen('0),        // input wire [7 : 0] s_axi_awlen
                    .s_axi_awsize('0),      // input wire [2 : 0] s_axi_awsize
                    .s_axi_awburst('0),    // input wire [1 : 0] s_axi_awburst
                    .s_axi_awlock('0),      // input wire [0 : 0] s_axi_awlock
                    .s_axi_awcache('0),    // input wire [3 : 0] s_axi_awcache
                    .s_axi_awprot('0),      // input wire [2 : 0] s_axi_awprot
                    .s_axi_awregion('0),  // input wire [3 : 0] s_axi_awregion
                    .s_axi_awqos('0),        // input wire [3 : 0] s_axi_awqos
                    .s_axi_awvalid(0),    // input wire s_axi_awvalid
                    .s_axi_awready(),    // output wire s_axi_awready
                    
                    .s_axi_wdata('0),        // input wire [511 : 0] s_axi_wdata
                    .s_axi_wstrb('0),        // input wire [63 : 0] s_axi_wstrb
                    .s_axi_wlast('0),        // input wire s_axi_wlast
                    .s_axi_wvalid('0),      // input wire s_axi_wvalid
                    .s_axi_wready(),      // output wire s_axi_wready


                    .s_axi_bid(),            // output wire [5 : 0] s_axi_bid
                    .s_axi_bresp(),        // output wire [1 : 0] s_axi_bresp
                    .s_axi_bvalid(),      // output wire s_axi_bvalid
                    .s_axi_bready(0),      // input wire s_axi_bready


                    //Read Interfaces
                    .s_axi_arid(dcmm_axi_arid),          // input wire [5 : 0] s_axi_arid
                    .s_axi_araddr(dcmm_axi_araddr),      // input wire [63 : 0] s_axi_araddr
                    .s_axi_arlen(dcmm_axi_arlen),        // input wire [7 : 0] s_axi_arlen
                    .s_axi_arsize(dcmm_axi_arsize),      // input wire [2 : 0] s_axi_arsize
                    .s_axi_arburst(dcmm_axi_arburst),    // input wire [1 : 0] s_axi_arburst
                    .s_axi_arlock(dcmm_axi_arlock),      // input wire [0 : 0] s_axi_arlock
                    .s_axi_arcache(dcmm_axi_arcache),    // input wire [3 : 0] s_axi_arcache
                    .s_axi_arprot(dcmm_axi_arprot),      // input wire [2 : 0] s_axi_arprot
                    .s_axi_arregion(dcmm_axi_arregion),  // input wire [3 : 0] s_axi_arregion
                    .s_axi_arqos(dcmm_axi_arqos),        // input wire [3 : 0] s_axi_arqos
                    .s_axi_arvalid(dcmm_axi_arvalid),    // input wire s_axi_arvalid
                    .s_axi_arready(dcmm_axi_arready),    // output wire s_axi_arready

                    .s_axi_rid(dcmm_axi_rid),            // output wire [5 : 0] s_axi_rid
                    .s_axi_rdata(dcmm_axi_rdata),        // output wire [511 : 0] s_axi_rdata
                    .s_axi_rresp(dcmm_axi_rresp),        // output wire [1 : 0] s_axi_rresp
                    
                    .s_axi_rlast(dcmm_axi_rlast),        // output wire s_axi_rlast
                    .s_axi_rvalid(dcmm_axi_rvalid),      // output wire s_axi_rvalid
                    .s_axi_rready(dcmm_axi_rready)       // input wire s_axi_rready
                );
            end
            else begin
                xlnx_axi_dwidth_converter_512_64 i_dwc_512_64_mm2s (

                    .s_axi_aclk(clk_i),          // input wire s_axi_aclk
                    .s_axi_aresetn(rst_ni),    // input wire s_axi_aresetn

                    //Write Interface
                    .m_axi_awaddr(),      // output wire [63 : 0] m_axi_awaddr
                    .m_axi_awlen(),        // output wire [7 : 0] m_axi_awlen
                    .m_axi_awsize(),      // output wire [2 : 0] m_axi_awsize
                    .m_axi_awburst(),    // output wire [1 : 0] m_axi_awburst
                    .m_axi_awlock(),      // output wire [0 : 0] m_axi_awlock
                    .m_axi_awcache(),    // output wire [3 : 0] m_axi_awcache
                    .m_axi_awprot(),      // output wire [2 : 0] m_axi_awprot
                    .m_axi_awregion(),  // output wire [3 : 0] m_axi_awregion
                    .m_axi_awqos(),        // output wire [3 : 0] m_axi_awqos
                    .m_axi_awvalid(),    // output wire m_axi_awvalid
                    .m_axi_awready(0),    // input wire m_axi_awready
                    
                    .m_axi_wdata(),        // output wire [63 : 0] m_axi_wdata
                    .m_axi_wstrb(),        // output wire [7 : 0] m_axi_wstrb
                    .m_axi_wlast(),        // output wire m_axi_wlast
                    .m_axi_wvalid(),      // output wire m_axi_wvalid
                    .m_axi_wready(0),      // input wire m_axi_wready
                    .m_axi_bresp(0),        // input wire [1 : 0] m_axi_bresp
                    .m_axi_bvalid(0),      // input wire m_axi_bvalid
                    .m_axi_bready(),      // output wire m_axi_bready

                    // Read Interface
                    .m_axi_araddr(mm_axi.ar_addr),      // output wire [63 : 0] m_axi_araddr
                    .m_axi_arlen(mm_axi.ar_len),        // output wire [7 : 0] m_axi_arlen
                    .m_axi_arsize(mm_axi.ar_size),      // output wire [2 : 0] m_axi_arsize
                    .m_axi_arburst(mm_axi.ar_burst),    // output wire [1 : 0] m_axi_arburst
                    .m_axi_arlock(),      // output wire [0 : 0] m_axi_arlock
                    .m_axi_arcache(mm_axi.ar_cache),    // output wire [3 : 0] m_axi_arcache
                    .m_axi_arprot(mm_axi.ar_prot),      // output wire [2 : 0] m_axi_arprot
                    .m_axi_arregion(),  // output wire [3 : 0] m_axi_arregion
                    .m_axi_arqos(),        // output wire [3 : 0] m_axi_arqos
                    .m_axi_arvalid(mm_axi.ar_valid),    // output wire m_axi_arvalid
                    .m_axi_arready(mm_axi.ar_ready),    // input wire m_axi_arready
                    .m_axi_rdata(mm_axi.r_data),        // input wire [63 : 0] m_axi_rdata
                    .m_axi_rresp(mm_axi.r_resp),        // input wire [1 : 0] m_axi_rresp
                    .m_axi_rlast(mm_axi.r_last),        // input wire m_axi_rlast
                    .m_axi_rvalid(mm_axi.r_valid),      // input wire m_axi_rvalid
                    .m_axi_rready(mm_axi.r_ready),      // output wire m_axi_rready

                    //Write Interfaces
                    .s_axi_awid('0),          // input wire [5 : 0] s_axi_awid
                    .s_axi_awaddr('0),      // input wire [63 : 0] s_axi_awaddr
                    .s_axi_awlen('0),        // input wire [7 : 0] s_axi_awlen
                    .s_axi_awsize('0),      // input wire [2 : 0] s_axi_awsize
                    .s_axi_awburst('0),    // input wire [1 : 0] s_axi_awburst
                    .s_axi_awlock('0),      // input wire [0 : 0] s_axi_awlock
                    .s_axi_awcache('0),    // input wire [3 : 0] s_axi_awcache
                    .s_axi_awprot('0),      // input wire [2 : 0] s_axi_awprot
                    .s_axi_awregion('0),  // input wire [3 : 0] s_axi_awregion
                    .s_axi_awqos('0),        // input wire [3 : 0] s_axi_awqos
                    .s_axi_awvalid(0),    // input wire s_axi_awvalid
                    .s_axi_awready(),    // output wire s_axi_awready
                    
                    .s_axi_wdata('0),        // input wire [511 : 0] s_axi_wdata
                    .s_axi_wstrb('0),        // input wire [63 : 0] s_axi_wstrb
                    .s_axi_wlast('0),        // input wire s_axi_wlast
                    .s_axi_wvalid('0),      // input wire s_axi_wvalid
                    .s_axi_wready(),      // output wire s_axi_wready


                    .s_axi_bid(),            // output wire [5 : 0] s_axi_bid
                    .s_axi_bresp(),        // output wire [1 : 0] s_axi_bresp
                    .s_axi_bvalid(),      // output wire s_axi_bvalid
                    .s_axi_bready(0),      // input wire s_axi_bready


                    //Read Interfaces
                    .s_axi_arid(dcmm_axi_arid),          // input wire [5 : 0] s_axi_arid
                    .s_axi_araddr(dcmm_axi_araddr),      // input wire [63 : 0] s_axi_araddr
                    .s_axi_arlen(dcmm_axi_arlen),        // input wire [7 : 0] s_axi_arlen
                    .s_axi_arsize(dcmm_axi_arsize),      // input wire [2 : 0] s_axi_arsize
                    .s_axi_arburst(dcmm_axi_arburst),    // input wire [1 : 0] s_axi_arburst
                    .s_axi_arlock(dcmm_axi_arlock),      // input wire [0 : 0] s_axi_arlock
                    .s_axi_arcache(dcmm_axi_arcache),    // input wire [3 : 0] s_axi_arcache
                    .s_axi_arprot(dcmm_axi_arprot),      // input wire [2 : 0] s_axi_arprot
                    .s_axi_arregion(dcmm_axi_arregion),  // input wire [3 : 0] s_axi_arregion
                    .s_axi_arqos(dcmm_axi_arqos),        // input wire [3 : 0] s_axi_arqos
                    .s_axi_arvalid(dcmm_axi_arvalid),    // input wire s_axi_arvalid
                    .s_axi_arready(dcmm_axi_arready),    // output wire s_axi_arready

                    .s_axi_rid(dcmm_axi_rid),            // output wire [5 : 0] s_axi_rid
                    .s_axi_rdata(dcmm_axi_rdata),        // output wire [511 : 0] s_axi_rdata
                    .s_axi_rresp(dcmm_axi_rresp),        // output wire [1 : 0] s_axi_rresp
                    
                    .s_axi_rlast(dcmm_axi_rlast),        // output wire s_axi_rlast
                    .s_axi_rvalid(dcmm_axi_rvalid),      // output wire s_axi_rvalid
                    .s_axi_rready(dcmm_axi_rready)       // input wire s_axi_rready
                );
            end
        endgenerate

        generate
            if(AXIS_S2MM_DATA_WIDTH == 1024) begin
                xlnx_axi_dwidth_converter_1024_64 i_dwc_1024_64_s2mm (
                    .s_axi_aclk(clk_i),          // input wire s_axi_aclk
                    .s_axi_aresetn(rst_ni),    // input wire s_axi_aresetn

                    //Write Interface
                    .m_axi_awaddr(mm_axi.aw_addr),      // output wire [63 : 0] m_axi_awaddr
                    .m_axi_awlen(mm_axi.aw_len),        // output wire [7 : 0] m_axi_awlen
                    .m_axi_awsize(mm_axi.aw_size),      // output wire [2 : 0] m_axi_awsize
                    .m_axi_awburst(mm_axi.aw_burst),    // output wire [1 : 0] m_axi_awburst
                    .m_axi_awlock(),      // output wire [0 : 0] m_axi_awlock
                    .m_axi_awcache(mm_axi.aw_cache),    // output wire [3 : 0] m_axi_awcache
                    .m_axi_awprot(mm_axi.aw_prot),      // output wire [2 : 0] m_axi_awprot
                    .m_axi_awregion(),  // output wire [3 : 0] m_axi_awregion
                    .m_axi_awqos(),        // output wire [3 : 0] m_axi_awqos
                    .m_axi_awvalid(mm_axi.aw_valid),    // output wire m_axi_awvalid
                    .m_axi_awready(mm_axi.aw_ready),    // input wire m_axi_awready
                    
                    .m_axi_wdata(mm_axi.w_data),        // output wire [63 : 0] m_axi_wdata
                    .m_axi_wstrb(mm_axi.w_strb),        // output wire [7 : 0] m_axi_wstrb
                    .m_axi_wlast(mm_axi.w_last),        // output wire m_axi_wlast
                    .m_axi_wvalid(mm_axi.w_valid),      // output wire m_axi_wvalid
                    .m_axi_wready(mm_axi.w_ready),      // input wire m_axi_wready
                    .m_axi_bresp(mm_axi.b_resp),        // input wire [1 : 0] m_axi_bresp
                    .m_axi_bvalid(mm_axi.b_valid),      // input wire m_axi_bvalid
                    .m_axi_bready(mm_axi.b_ready),      // output wire m_axi_bready

                    // Read Interface
                    .m_axi_araddr(),      // output wire [63 : 0] m_axi_araddr
                    .m_axi_arlen(),        // output wire [7 : 0] m_axi_arlen
                    .m_axi_arsize(),      // output wire [2 : 0] m_axi_arsize
                    .m_axi_arburst(),    // output wire [1 : 0] m_axi_arburst
                    .m_axi_arlock(),      // output wire [0 : 0] m_axi_arlock
                    .m_axi_arcache(),    // output wire [3 : 0] m_axi_arcache
                    .m_axi_arprot(),      // output wire [2 : 0] m_axi_arprot
                    .m_axi_arregion(),  // output wire [3 : 0] m_axi_arregion
                    .m_axi_arqos(),        // output wire [3 : 0] m_axi_arqos
                    .m_axi_arvalid(),    // output wire m_axi_arvalid
                    .m_axi_arready(0),    // input wire m_axi_arready
                    .m_axi_rdata('0),        // input wire [63 : 0] m_axi_rdata
                    .m_axi_rresp('0),        // input wire [1 : 0] m_axi_rresp
                    .m_axi_rlast(0),        // input wire m_axi_rlast
                    .m_axi_rvalid(0),      // input wire m_axi_rvalid
                    .m_axi_rready(),      // output wire m_axi_rready

                    //Write Interfaces
                    .s_axi_awid(dcmm_axi_awid),          // input wire [5 : 0] s_axi_awid
                    .s_axi_awaddr(dcmm_axi_awaddr),      // input wire [63 : 0] s_axi_awaddr
                    .s_axi_awlen(dcmm_axi_awlen),        // input wire [7 : 0] s_axi_awlen
                    .s_axi_awsize(dcmm_axi_awsize),      // input wire [2 : 0] s_axi_awsize
                    .s_axi_awburst(dcmm_axi_awburst),    // input wire [1 : 0] s_axi_awburst
                    .s_axi_awlock(dcmm_axi_awlock),      // input wire [0 : 0] s_axi_awlock
                    .s_axi_awcache(dcmm_axi_awcache),    // input wire [3 : 0] s_axi_awcache
                    .s_axi_awprot(dcmm_axi_awprot),      // input wire [2 : 0] s_axi_awprot
                    .s_axi_awregion(dcmm_axi_awregion),  // input wire [3 : 0] s_axi_awregion
                    .s_axi_awqos(dcmm_axi_awqos),        // input wire [3 : 0] s_axi_awqos
                    .s_axi_awvalid(dcmm_axi_awvalid),    // input wire s_axi_awvalid
                    .s_axi_awready(dcmm_axi_awready),    // output wire s_axi_awready
                    

                    .s_axi_wdata(dcmm_axi_wdata),        // input wire [511 : 0] s_axi_wdata
                    .s_axi_wstrb(dcmm_axi_wstrb),        // input wire [63 : 0] s_axi_wstrb
                    .s_axi_wlast(dcmm_axi_wlast),        // input wire s_axi_wlast
                    .s_axi_wvalid(dcmm_axi_wvalid),      // input wire s_axi_wvalid
                    .s_axi_wready(dcmm_axi_wready),      // output wire s_axi_wready


                    .s_axi_bid(dcmm_axi_bid),            // output wire [5 : 0] s_axi_bid
                    .s_axi_bresp(dcmm_axi_bresp),        // output wire [1 : 0] s_axi_bresp
                    .s_axi_bvalid(dcmm_axi_bvalid),      // output wire s_axi_bvalid
                    .s_axi_bready(dcmm_axi_bready),      // input wire s_axi_bready


                    //Read Interfaces
                    .s_axi_arid('0),          // input wire [5 : 0] s_axi_arid
                    .s_axi_araddr('0),      // input wire [63 : 0] s_axi_araddr
                    .s_axi_arlen('0),        // input wire [7 : 0] s_axi_arlen
                    .s_axi_arsize('0),      // input wire [2 : 0] s_axi_arsize
                    .s_axi_arburst('0),    // input wire [1 : 0] s_axi_arburst
                    .s_axi_arlock('0),      // input wire [0 : 0] s_axi_arlock
                    .s_axi_arcache('0),    // input wire [3 : 0] s_axi_arcache
                    .s_axi_arprot('0),      // input wire [2 : 0] s_axi_arprot
                    .s_axi_arregion('0),  // input wire [3 : 0] s_axi_arregion
                    .s_axi_arqos('0),        // input wire [3 : 0] s_axi_arqos
                    .s_axi_arvalid('0),    // input wire s_axi_arvalid
                    .s_axi_arready('0),    // output wire s_axi_arready

                    .s_axi_rid(),            // output wire [5 : 0] s_axi_rid
                    .s_axi_rdata(),        // output wire [511 : 0] s_axi_rdata
                    .s_axi_rresp(),        // output wire [1 : 0] s_axi_rresp
                    .s_axi_rlast(),        // output wire s_axi_rlast
                    .s_axi_rvalid(),      // output wire s_axi_rvalid
                    .s_axi_rready(0)       // input wire s_axi_rready
                );
            end
            else begin
                xlnx_axi_dwidth_converter_512_64 i_dwc_512_64_s2mm (
                    .s_axi_aclk(clk_i),          // input wire s_axi_aclk
                    .s_axi_aresetn(rst_ni),    // input wire s_axi_aresetn

                    //Write Interface
                    .m_axi_awaddr(mm_axi.aw_addr),      // output wire [63 : 0] m_axi_awaddr
                    .m_axi_awlen(mm_axi.aw_len),        // output wire [7 : 0] m_axi_awlen
                    .m_axi_awsize(mm_axi.aw_size),      // output wire [2 : 0] m_axi_awsize
                    .m_axi_awburst(mm_axi.aw_burst),    // output wire [1 : 0] m_axi_awburst
                    .m_axi_awlock(),      // output wire [0 : 0] m_axi_awlock
                    .m_axi_awcache(mm_axi.aw_cache),    // output wire [3 : 0] m_axi_awcache
                    .m_axi_awprot(mm_axi.aw_prot),      // output wire [2 : 0] m_axi_awprot
                    .m_axi_awregion(),  // output wire [3 : 0] m_axi_awregion
                    .m_axi_awqos(),        // output wire [3 : 0] m_axi_awqos
                    .m_axi_awvalid(mm_axi.aw_valid),    // output wire m_axi_awvalid
                    .m_axi_awready(mm_axi.aw_ready),    // input wire m_axi_awready
                    
                    .m_axi_wdata(mm_axi.w_data),        // output wire [63 : 0] m_axi_wdata
                    .m_axi_wstrb(mm_axi.w_strb),        // output wire [7 : 0] m_axi_wstrb
                    .m_axi_wlast(mm_axi.w_last),        // output wire m_axi_wlast
                    .m_axi_wvalid(mm_axi.w_valid),      // output wire m_axi_wvalid
                    .m_axi_wready(mm_axi.w_ready),      // input wire m_axi_wready
                    .m_axi_bresp(mm_axi.b_resp),        // input wire [1 : 0] m_axi_bresp
                    .m_axi_bvalid(mm_axi.b_valid),      // input wire m_axi_bvalid
                    .m_axi_bready(mm_axi.b_ready),      // output wire m_axi_bready

                    // Read Interface
                    .m_axi_araddr(),      // output wire [63 : 0] m_axi_araddr
                    .m_axi_arlen(),        // output wire [7 : 0] m_axi_arlen
                    .m_axi_arsize(),      // output wire [2 : 0] m_axi_arsize
                    .m_axi_arburst(),    // output wire [1 : 0] m_axi_arburst
                    .m_axi_arlock(),      // output wire [0 : 0] m_axi_arlock
                    .m_axi_arcache(),    // output wire [3 : 0] m_axi_arcache
                    .m_axi_arprot(),      // output wire [2 : 0] m_axi_arprot
                    .m_axi_arregion(),  // output wire [3 : 0] m_axi_arregion
                    .m_axi_arqos(),        // output wire [3 : 0] m_axi_arqos
                    .m_axi_arvalid(),    // output wire m_axi_arvalid
                    .m_axi_arready(0),    // input wire m_axi_arready
                    .m_axi_rdata('0),        // input wire [63 : 0] m_axi_rdata
                    .m_axi_rresp('0),        // input wire [1 : 0] m_axi_rresp
                    .m_axi_rlast(0),        // input wire m_axi_rlast
                    .m_axi_rvalid(0),      // input wire m_axi_rvalid
                    .m_axi_rready(),      // output wire m_axi_rready

                    //Write Interfaces
                    .s_axi_awid(dcmm_axi_awid),          // input wire [5 : 0] s_axi_awid
                    .s_axi_awaddr(dcmm_axi_awaddr),      // input wire [63 : 0] s_axi_awaddr
                    .s_axi_awlen(dcmm_axi_awlen),        // input wire [7 : 0] s_axi_awlen
                    .s_axi_awsize(dcmm_axi_awsize),      // input wire [2 : 0] s_axi_awsize
                    .s_axi_awburst(dcmm_axi_awburst),    // input wire [1 : 0] s_axi_awburst
                    .s_axi_awlock(dcmm_axi_awlock),      // input wire [0 : 0] s_axi_awlock
                    .s_axi_awcache(dcmm_axi_awcache),    // input wire [3 : 0] s_axi_awcache
                    .s_axi_awprot(dcmm_axi_awprot),      // input wire [2 : 0] s_axi_awprot
                    .s_axi_awregion(dcmm_axi_awregion),  // input wire [3 : 0] s_axi_awregion
                    .s_axi_awqos(dcmm_axi_awqos),        // input wire [3 : 0] s_axi_awqos
                    .s_axi_awvalid(dcmm_axi_awvalid),    // input wire s_axi_awvalid
                    .s_axi_awready(dcmm_axi_awready),    // output wire s_axi_awready
                    

                    .s_axi_wdata(dcmm_axi_wdata),        // input wire [511 : 0] s_axi_wdata
                    .s_axi_wstrb(dcmm_axi_wstrb),        // input wire [63 : 0] s_axi_wstrb
                    .s_axi_wlast(dcmm_axi_wlast),        // input wire s_axi_wlast
                    .s_axi_wvalid(dcmm_axi_wvalid),      // input wire s_axi_wvalid
                    .s_axi_wready(dcmm_axi_wready),      // output wire s_axi_wready


                    .s_axi_bid(dcmm_axi_bid),            // output wire [5 : 0] s_axi_bid
                    .s_axi_bresp(dcmm_axi_bresp),        // output wire [1 : 0] s_axi_bresp
                    .s_axi_bvalid(dcmm_axi_bvalid),      // output wire s_axi_bvalid
                    .s_axi_bready(dcmm_axi_bready),      // input wire s_axi_bready


                    //Read Interfaces
                    .s_axi_arid('0),          // input wire [5 : 0] s_axi_arid
                    .s_axi_araddr('0),      // input wire [63 : 0] s_axi_araddr
                    .s_axi_arlen('0),        // input wire [7 : 0] s_axi_arlen
                    .s_axi_arsize('0),      // input wire [2 : 0] s_axi_arsize
                    .s_axi_arburst('0),    // input wire [1 : 0] s_axi_arburst
                    .s_axi_arlock('0),      // input wire [0 : 0] s_axi_arlock
                    .s_axi_arcache('0),    // input wire [3 : 0] s_axi_arcache
                    .s_axi_arprot('0),      // input wire [2 : 0] s_axi_arprot
                    .s_axi_arregion('0),  // input wire [3 : 0] s_axi_arregion
                    .s_axi_arqos('0),        // input wire [3 : 0] s_axi_arqos
                    .s_axi_arvalid('0),    // input wire s_axi_arvalid
                    .s_axi_arready('0),    // output wire s_axi_arready

                    .s_axi_rid(),            // output wire [5 : 0] s_axi_rid
                    .s_axi_rdata(),        // output wire [511 : 0] s_axi_rdata
                    .s_axi_rresp(),        // output wire [1 : 0] s_axi_rresp
                    .s_axi_rlast(),        // output wire s_axi_rlast
                    .s_axi_rvalid(),      // output wire s_axi_rvalid
                    .s_axi_rready(0)       // input wire s_axi_rready
                );
            end
        endgenerate
endmodule

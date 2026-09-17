`timescale 1ns / 1ps

module rvexp_coprocessor
    //import cvxif_instr_pkg::*;
#(
    parameter  int unsigned NrRgprPorts         = 2,
    
    parameter  int unsigned XLEN                = 64,
    parameter  int unsigned X_HARTID_WIDTH      = 64,
    parameter  int unsigned X_ID_WIDTH          =  3,
    parameter  int unsigned X_DUALWRITE         =  0,
    parameter  int unsigned X_NUM_RS            =  2,

    parameter  type         readregflags_t      = logic,
    parameter  type         writeregflags_t     = logic,
    parameter  type         id_t                = logic,
    parameter  type         hartid_t            = logic,
    parameter  type         x_compressed_req_t  = logic,
    parameter  type         x_compressed_resp_t = logic,
    parameter  type         x_issue_req_t       = logic,
    parameter  type         x_issue_resp_t      = logic,
    parameter  type         x_register_t        = logic,
    parameter  type         x_commit_t          = logic,
    parameter  type         x_result_t          = logic,
    parameter  type         cvxif_req_t         = logic,
    parameter  type         cvxif_resp_t        = logic,
    localparam type         registers_t         = logic [NrRgprPorts-1:0][XLEN-1:0]
) (
    input  logic        clk_i,
    input  logic        rst_ni,

    input  cvxif_req_t  cvxif_req_i,
    output cvxif_resp_t cvxif_resp_o,

	input  logic [ 511 : 0] m0_axis_mm2s_tdata,
    input  logic [  63 : 0] m0_axis_mm2s_tkeep, 
    input  logic            m0_axis_mm2s_tvalid,         
    output logic            m0_axis_mm2s_tready,         
    input  logic            m0_axis_mm2s_tlast,          
    output logic [1023 : 0] s0_axis_s2mm_tdata,
    output logic [ 127 : 0] s0_axis_s2mm_tkeep,  
    output logic            s0_axis_s2mm_tvalid,          
    input  logic            s0_axis_s2mm_tready,          
    output logic            s0_axis_s2mm_tlast,             

    input  logic [1023 : 0] m1_axis_mm2s_tdata,
    input  logic [ 127 : 0] m1_axis_mm2s_tkeep,  
    input  logic            m1_axis_mm2s_tvalid,         
    output logic            m1_axis_mm2s_tready,          
    input  logic            m1_axis_mm2s_tlast,           
    output logic [ 511 : 0] s1_axis_s2mm_tdata, 
    output logic [  63 : 0] s1_axis_s2mm_tkeep,  
    output logic            s1_axis_s2mm_tvalid,           
    input  logic            s1_axis_s2mm_tready,           
    output logic            s1_axis_s2mm_tlast,             

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
	output logic          m1_axi_rready
);

    localparam OPCODE = 7'b1111011;

    logic         reset_p;

    logic        instr_commit;
    logic [ 6:0] instr_funct7;
    logic [ 2:0] instr_funct3;
    logic [ 6:0] instr_opcode;
    logic [63:0] instr_rs1_val;
    logic [63:0] instr_rs2_val;
    
    logic        result_we;
    logic [63:0] result_rd;

    //Modules Instantiations
    rvexp_CVXIF_Adapter #(
        .XLEN(XLEN),
        .X_HARTID_WIDTH(X_HARTID_WIDTH),
        .X_ID_WIDTH(X_ID_WIDTH),
        .X_DUALWRITE(X_DUALWRITE),
        .X_NUM_RS(X_NUM_RS),
        .OPCODE(OPCODE)
    ) CDF53_CVXIF_Adapter_inst(
        //Clock Interface
        .clk(clk_i),

        //Reset
        .reset_n_i(rst_ni),

        //Compressed Interface Signals Assignation
        .cvxif_compressed_valid_i(cvxif_req_i.compressed_valid),
        .cvxif_compressed_ready_o(cvxif_resp_o.compressed_ready),

        .cvxif_compressed_req_instr_i(cvxif_req_i.compressed_req.instr),
        .cvxif_compressed_req_hartid_i(cvxif_req_i.compressed_req.hartid),

        .cvxif_compressed_resp_instr_o(cvxif_resp_o.compressed_resp.instr),
        .cvxif_compressed_resp_accept_o(cvxif_resp_o.compressed_resp.accept),

        //Issue Interface Signals Assignation
        .cvxif_issue_valid_i(cvxif_req_i.issue_valid),
        .cvxif_issue_ready_o(cvxif_resp_o.issue_ready),

        .cvxif_issue_req_instr_i(cvxif_req_i.issue_req.instr),
        .cvxif_issue_req_hartid_i(cvxif_req_i.issue_req.hartid),
        .cvxif_issue_req_id_i(cvxif_req_i.issue_req.id),

        .cvxif_issue_resp_accept_o(cvxif_resp_o.issue_resp.accept),
        .cvxif_issue_resp_writeback_o(cvxif_resp_o.issue_resp.writeback),
        .cvxif_issue_resp_register_read_o(cvxif_resp_o.issue_resp.register_read),

        //Register Interface Signals Assignation
        .cvxif_register_register_valid_i(cvxif_req_i.register_valid),
        .cvxif_register_register_ready_o(cvxif_resp_o.register_ready),

        .cvxif_register_register_hartid_i(cvxif_req_i.register.hartid),
        .cvxif_register_register_id_i(cvxif_req_i.register.id),
        .cvxif_register_register_rs_1_i(cvxif_req_i.register.rs[1]),
        .cvxif_register_register_rs_0_i(cvxif_req_i.register.rs[0]),
        .cvxif_register_register_rs_valid_i(cvxif_req_i.register.rs_valid),

        //Commit Interface Signals Assignation
        .cvxif_commit_valid_i(cvxif_req_i.commit_valid),

        .cvxif_commit_commit_hartid_i(cvxif_req_i.commit.hartid),
        .cvxif_commit_commit_id_i(cvxif_req_i.commit.id),
        .cvxif_commit_commit_kill_i(cvxif_req_i.commit.commit_kill),

        //Result Interface Signals Assignation
        .cvxif_result_valid_o(cvxif_resp_o.result_valid),
        .cvxif_result_ready_i(cvxif_req_i.result_ready),

        .cvxif_result_result_hartid_o(cvxif_resp_o.result.hartid),
        .cvxif_result_result_id_o(cvxif_resp_o.result.id),
        .cvxif_result_result_data_o(cvxif_resp_o.result.data),
        .cvxif_result_result_rd_o(cvxif_resp_o.result.rd),
        .cvxif_result_result_we_o(cvxif_resp_o.result.we),

        .instr_commit(instr_commit),
        .instr_funct7(instr_funct7),
        .instr_funct3(instr_funct3),
        .instr_opcode(instr_opcode),
        .instr_rs1_val(instr_rs1_val),
        .instr_rs2_val(instr_rs2_val),

        .i_result_we(result_we),
        .i_result_rd(result_rd)
    );

    rvexp_axis4 i_rvexp_axis4 (
        .clock(clk_i),
        .reset_n(rst_ni),

        .instr_commit(instr_commit),
        .instr_funct7(instr_funct7),
        .instr_funct3(instr_funct3),
        .instr_rs1_val(instr_rs1_val),
        .instr_rs2_val(instr_rs2_val),

        .result_we(result_we),
        .result_rd(result_rd),

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
		.m1_axi_rready(m1_axi_rready)
    );

endmodule

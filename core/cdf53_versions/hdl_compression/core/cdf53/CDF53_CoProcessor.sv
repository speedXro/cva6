//`include "cvxif_types.svh"

module CDF53_CoProcessor
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
    output cvxif_resp_t cvxif_resp_o
);
    //assign ada_issued = instr_commit;

    localparam CDF53_OPCODE = 7'b1111011;

    //ADA Signals
    logic         reset_p;

    logic        instr_commit;
    logic [ 6:0] instr_funct7;
    logic [ 2:0] instr_funct3;
    logic [ 6:0] instr_opcode;
    logic [63:0] instr_rs1_val;
    logic [63:0] instr_rs2_val;
    
    logic        result_we;
    logic [63:0] result_rd;
    
    logic        result_mem_en;
    logic [63:0] result_mem_adr;
    logic [63:0] result_mem_dat;


    //Modules Instantiations

    CDF53_CVXIF_Adapter #(
        .XLEN(XLEN),
        .X_HARTID_WIDTH(X_HARTID_WIDTH),
        .X_ID_WIDTH(X_ID_WIDTH),
        .X_DUALWRITE(X_DUALWRITE),
        .X_NUM_RS(X_NUM_RS),
        .CDF53_OPCODE(CDF53_OPCODE)
    ) CDF53_CVXIF_Adapter_inst(
        //Clock Interface
        .clk(clk_i),

        //Reset
        .reset_n_i(rst_ni),
        .reset_o(reset_p),

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

        //SigWavy Extension Control Interface Signals Assignation
        .instr_commit(instr_commit),
        .instr_funct7(instr_funct7),
        .instr_funct3(instr_funct3),
        .instr_opcode(instr_opcode),
        .instr_rs1_val(instr_rs1_val),
        .instr_rs2_val(instr_rs2_val),

        .i_result_we(result_we),
        .i_result_rd(result_rd),
        .i_result_mem_en(result_mem_en),
        .i_result_mem_adr(result_mem_adr),
        .i_result_mem_dat(result_mem_dat)
    );

    fi_dwt_hdl fi_dwt_hdl_inst(
        .clk(clk_i),
        .reset(reset_p),

        .instr_commit(instr_commit),
        .instr_funct7(instr_funct7),
        .instr_funct3(instr_funct3),
        .instr_opcode(instr_opcode),
        .instr_rs1_val(instr_rs1_val),
        .instr_rs2_val(instr_rs2_val),

        .result_we(result_we),
        .result_rd(result_rd),

        .result_mem_en(result_mem_en),
        .result_mem_adr(result_mem_adr),
        .result_mem_dat(result_mem_dat)
    );

endmodule
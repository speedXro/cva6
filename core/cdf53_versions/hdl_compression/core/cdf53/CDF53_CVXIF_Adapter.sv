//`timescale 1ns / 1ps

module CDF53_CVXIF_Adapter 
#(
    parameter XLEN           = 64,
    parameter X_HARTID_WIDTH = 64,
    parameter X_ID_WIDTH     =  3,    // ($clog2(CVA6Cfg.NrScoreboardEntries); // NrScoreboardEntries = 8 for CV64A_IMAFDC)
    parameter X_DUALWRITE    =  0,
    parameter X_NUM_RS       =  2,
    
    parameter CDF53_OPCODE = 7'b1111011
)
(
    input  logic                             clk,
    
    input  logic                             reset_n_i,
    output logic                             reset_o,

    

    //CV-X-IF Compressed Interface
    input  logic                             cvxif_compressed_valid_i,
    output logic                             cvxif_compressed_ready_o,
    
    input  logic [                      15:0] cvxif_compressed_req_instr_i,
    input  logic [        X_HARTID_WIDTH-1:0] cvxif_compressed_req_hartid_i,

    
    output logic                             cvxif_compressed_resp_accept_o,
    output logic [                      31:0] cvxif_compressed_resp_instr_o,

    //CV-X-IF Issue Interface
    input  logic                             cvxif_issue_valid_i,
    output logic                             cvxif_issue_ready_o,

    input  logic [                      31:0] cvxif_issue_req_instr_i,
    input  logic [        X_HARTID_WIDTH-1:0] cvxif_issue_req_hartid_i,
    input  logic [           X_ID_WIDTH -1:0] cvxif_issue_req_id_i,

    output logic                              cvxif_issue_resp_accept_o,
    output logic [             X_DUALWRITE:0] cvxif_issue_resp_writeback_o,
    output logic [  X_NUM_RS+X_DUALWRITE-1:0] cvxif_issue_resp_register_read_o,

    //CV-X-IF Register Interface
    input  logic                             cvxif_register_register_valid_i,
    output logic                             cvxif_register_register_ready_o,

    input  logic [         X_HARTID_WIDTH-1:0] cvxif_register_register_hartid_i,
    input  logic [            X_ID_WIDTH -1:0] cvxif_register_register_id_i,
    input  logic [                   XLEN-1:0] cvxif_register_register_rs_1_i,
    input  logic [                   XLEN-1:0] cvxif_register_register_rs_0_i,
    input  logic [   X_NUM_RS+X_DUALWRITE-1:0] cvxif_register_register_rs_valid_i,

    //CV-X-IF Commit Interface
    input  logic                              cvxif_commit_valid_i,

    input  logic [         X_HARTID_WIDTH-1:0] cvxif_commit_commit_hartid_i,
    input  logic [            X_ID_WIDTH -1:0] cvxif_commit_commit_id_i,
    input  logic                               cvxif_commit_commit_kill_i,

    //Result Interface
    output logic                               cvxif_result_valid_o,
    input  logic                               cvxif_result_ready_i,

    output logic [        X_HARTID_WIDTH-1:0] cvxif_result_result_hartid_o,
    output logic [           X_ID_WIDTH -1:0] cvxif_result_result_id_o,
    output logic [                  XLEN-1:0] cvxif_result_result_data_o,
    output logic [                       4:0] cvxif_result_result_rd_o,
    output logic [             X_DUALWRITE:0] cvxif_result_result_we_o,

    //ADA Extension Control Interface       

    output logic        instr_commit,
    output logic [ 6:0] instr_funct7,
    output logic [ 2:0] instr_funct3,
    output logic [ 6:0] instr_opcode,
    output logic [63:0] instr_rs1_val,
    output logic [63:0] instr_rs2_val,
    
    input  logic        i_result_we,
    input  logic [63:0] i_result_rd,
    
    input  logic        i_result_mem_en,
    input  logic [63:0] i_result_mem_adr,
    input  logic [63:0] i_result_mem_dat

);
    wire                             reset;

    wire                             issue_valid;

    wire [                      6:0] issue_instr_funct7;
    wire [                      6:0] issue_instr_funct3;
    wire [                      4:0] issue_instr_rs2;
    wire [                      4:0] issue_instr_rs1;
    wire [                      4:0] issue_instr_rd;
    wire [                      6:0] issue_instr_opcode;
    wire [       X_HARTID_WIDTH-1:0] issue_hartid;
    wire [          X_ID_WIDTH -1:0] issue_id;
    wire [                      4:0] issue_rd;

    reg                              issue_ready;
    reg                              issue_accept;
    reg  [           X_DUALWRITE:0] issue_write_back;
    reg  [X_NUM_RS+X_DUALWRITE-1:0] issue_register_read;

    wire                             register_valid; 
    wire                             register_ready;

    wire [                 XLEN-1:0] register_rs_1_i;
    wire [                 XLEN-1:0] register_rs_0_i;
    wire [ X_NUM_RS+X_DUALWRITE-1:0] register_rs_valid_i;

    reg                              result_valid;
    reg  [       X_HARTID_WIDTH-1:0] result_hartid;
    reg  [          X_ID_WIDTH -1:0] result_id;
    reg  [                 XLEN-1:0] result_data;
    reg  [                      4:0] result_rd;
    reg  [            X_DUALWRITE:0] result_we;
    //reg                              result_waiting;
    //reg                              result_writing;
    //reg                              result_reading;

    reg                              rtemp_valid;
    reg  [       X_HARTID_WIDTH-1:0] rtemp_hartid;
    reg  [          X_ID_WIDTH -1:0] rtemp_id;
    reg  [                 XLEN-1:0] rtemp_data;
    reg  [                      4:0] rtemp_rd;
    reg  [            X_DUALWRITE:0] rtemp_we;

    reg commit;

    assign reset_o = ~reset_n_i;
    assign reset   = ~reset_n_i;

    assign issue_valid         = cvxif_issue_valid_i; 

    assign issue_instr_funct7  = cvxif_issue_req_instr_i[31:25];
    assign issue_instr_rs2     = cvxif_issue_req_instr_i[24:20];
    assign issue_instr_rs1     = cvxif_issue_req_instr_i[19:15];
    assign issue_instr_funct3  = cvxif_issue_req_instr_i[14:12];
    assign issue_instr_rd      = cvxif_issue_req_instr_i[11: 7];
    assign issue_instr_opcode  = cvxif_issue_req_instr_i[ 6: 0];

    assign issue_hartid        = cvxif_issue_req_hartid_i;
    assign issue_id            = cvxif_issue_req_id_i;
    assign issue_rd            = issue_instr_rd;

    assign register_valid      = cvxif_register_register_valid_i;
    assign register_rs_valid_i = cvxif_register_register_rs_valid_i;
    assign register_rs_1_i     = cvxif_register_register_rs_1_i;
    assign register_rs_0_i     = cvxif_register_register_rs_0_i;

    always_comb begin
        issue_accept        = 1'b0;
        issue_write_back    = 1'b0;
        issue_register_read = {X_NUM_RS+X_DUALWRITE{1'b0}};
        if(issue_valid == 1'b1 && issue_instr_opcode == CDF53_OPCODE) begin
            issue_accept        <= 1'b1;
            issue_write_back    <= 1'b1;
            issue_register_read <= {X_NUM_RS+X_DUALWRITE{1'b1}};
        end
        else begin
            issue_accept        <= 1'b0;
            issue_write_back    <= 1'b0;
            issue_register_read <= {X_NUM_RS+X_DUALWRITE{1'b0}};
        end
    end

    always_comb begin
        issue_ready     = 1'b0;
        if(issue_valid == 1'b1 && issue_instr_opcode == CDF53_OPCODE && register_rs_valid_i == 2'b11) begin
            issue_ready         <= 1'b1;
        end
        else begin
            issue_ready         <= 1'b0; 
        end
    end

    logic [1:0] state;
    logic       input_all_valid;

    logic [X_HARTID_WIDTH-1:0] hid;
    logic [   X_ID_WIDTH -1:0] iid;
    logic [               4:0] rdd;


    assign input_all_valid = (issue_valid == 1'b1 && issue_instr_opcode == CDF53_OPCODE && register_rs_valid_i == 2'b11);

    always_ff @(posedge clk or negedge reset_n_i) begin
        if(reset_n_i == 1'b0) begin
            state <= 2'd0;

            hid            <= {X_HARTID_WIDTH{1'b0}};
            iid            <= {X_ID_WIDTH{1'b0}};
            rdd            <= 5'd0;

            result_valid   <= 1'b0;
            result_hartid  <= {X_HARTID_WIDTH{1'b0}};
            result_id      <= {X_ID_WIDTH{1'b0}};
            result_data    <= {XLEN{1'b0}};
            result_rd      <= 5'd0;
            result_we      <= 1'b0;

            instr_commit   <= 1'b0;
            instr_funct7   <= 7'd0;
            instr_funct3   <= 3'd0;
            instr_opcode   <= 7'd0;
            instr_rs1_val  <= {XLEN{1'b0}};
            instr_rs2_val  <= {XLEN{1'b0}};
        end

        else if(state == 2'd0 && input_all_valid == 1'b0) begin
            state          <= 2'd0;
            $display("State 0 cu 0"); 
        end
        else if(state == 2'd0 && input_all_valid == 1'b1) begin
            hid            <= issue_hartid;
            iid            <= issue_id;
            rdd            <= issue_rd;

            instr_commit   <= 1'b1;
            instr_funct7   <= issue_instr_funct7;
            instr_funct3   <= issue_instr_funct3;
            instr_opcode   <= issue_instr_opcode;
            instr_rs1_val  <= register_rs_0_i;
            instr_rs2_val  <= register_rs_1_i;

            state          <= 2'd1;
            $display("State 0 cu 1 : %07b | %07b | %3b", instr_opcode, instr_funct7, instr_funct3);
        end

        else if(state == 2'd1 && i_result_we == 1'b0) begin
            instr_commit   <= 1'b0;
            instr_funct7   <= 7'd0;
            instr_funct3   <= 3'd0;
            instr_opcode   <= 7'd0;
            instr_rs1_val  <= {XLEN{1'b0}};
            instr_rs2_val  <= {XLEN{1'b0}};

            state          <= 2'd1;
            $display("State 1 cu 0");
        end
        else if(state == 2'd1 && i_result_we == 1'b1) begin
            instr_commit   <= 1'b0;
            instr_funct7   <= 7'd0;
            instr_funct3   <= 3'd0;
            instr_opcode   <= 7'd0;
            instr_rs1_val  <= {XLEN{1'b0}};
            instr_rs2_val  <= {XLEN{1'b0}};

            result_valid   <= 1'b1;
            result_hartid  <= hid;
            result_id      <= iid;
            result_data    <= i_result_rd;
            result_rd      <= rdd;
            result_we      <= 1'b1;

            state          <= 2'd2;
            $display("State 1 cu 1");
        end
        

        else if(state == 2'd2) begin
            state          <= 2'd0;

            result_valid   <= 1'b0;
            result_hartid  <= {X_HARTID_WIDTH{1'b0}};
            result_id      <= {X_ID_WIDTH{1'b0}};
            result_data    <= {XLEN{1'b0}};
            result_rd      <= 5'd0;
            result_we      <= 1'b0;

            instr_commit   <= 1'b0;
            instr_funct7   <= 7'd0;
            instr_funct3   <= 3'd0;
            instr_opcode   <= 7'd0;
            instr_rs1_val  <= {XLEN{1'b0}};
            instr_rs2_val  <= {XLEN{1'b0}};
        end

    end

    assign cvxif_compressed_ready_o         =  1'b1;
    assign cvxif_compressed_resp_accept_o   =  1'b0;
    assign cvxif_compressed_resp_instr_o    = 32'd0;

    assign cvxif_issue_ready_o              = issue_ready;
    assign cvxif_issue_resp_accept_o        = issue_accept;
    assign cvxif_issue_resp_writeback_o     = issue_write_back;
    assign cvxif_issue_resp_register_read_o = issue_register_read;

    assign register_ready                   = issue_ready;
    assign cvxif_register_register_ready_o  = register_ready;

    assign cvxif_result_valid_o             = result_valid;
    assign cvxif_result_result_hartid_o     = result_hartid;
    assign cvxif_result_result_id_o         = result_id;
    assign cvxif_result_result_data_o       = result_data;
    assign cvxif_result_result_rd_o         = result_rd;
    assign cvxif_result_result_we_o         = result_we;

endmodule
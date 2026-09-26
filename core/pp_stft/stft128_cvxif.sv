`timescale 1ns / 1ps

module stft128_cvxif
  import stft128_pkg::*;
#(
  parameter X_ID_WIDTH = 4
)(
  input  logic                    clk,
  input  logic                    rst_n,

  input  logic                    x_issue_valid,
  output logic                    x_issue_ready,
  input  logic [31:0]             x_issue_req_instr,
  input  logic [X_ID_WIDTH-1:0]   x_issue_req_id,
  input  logic [31:0]             x_issue_req_rs1,
  input  logic [31:0]             x_issue_req_rs2,
  input  logic [1:0]              x_issue_req_rs_valid,   
  output logic                    x_issue_resp_accept,
  output logic                    x_issue_resp_writeback,
  output logic                    x_issue_resp_dualwrite,
  output logic                    x_issue_resp_loadstore,

  input  logic                    x_commit_valid,
  input  logic [X_ID_WIDTH-1:0]   x_commit_id,
  input  logic                    x_commit_kill,

  output logic                    x_result_valid,
  input  logic                    x_result_ready,
  output logic [X_ID_WIDTH-1:0]   x_result_id,
  output logic [31:0]             x_result_data,
  output logic [4:0]              x_result_rd,
  output logic                    x_result_we,

  output logic [1:0]              cfg_window_sel,
  output logic                    cfg_enable,
  output logic [1:0]              cfg_out_fmt,
  output logic [1:0]              cfg_pix_floor,
  output logic                    start_pulse,     // STFT_START one-shot
  output logic                    soft_reset,      // STFT_RESET one-shot
  output logic                    stat_read_ack,   // clears sticky frame_done

  input  logic                    ctrl_busy,
  input  logic                    frame_done,      // sticky
  input  logic                    frame_full,
  input  logic [7:0]              frame_count
);

  logic [6:0] opcode; logic [2:0] funct3; logic [4:0] rd_field;
  assign opcode   = x_issue_req_instr[6:0];
  assign funct3   = x_issue_req_instr[14:12];
  assign rd_field = x_issue_req_instr[11:7];

  logic       rs1_valid;
  logic       f3_known;
  logic       dec_ok;
  assign rs1_valid = x_issue_req_rs_valid[0];
  assign f3_known  = (funct3 == F3_CFG) || (funct3 == F3_START) ||
                     (funct3 == F3_STATUS) || (funct3 == F3_RESET);
  assign dec_ok = (opcode == OPC_CUSTOM0) && f3_known &&
                  ((funct3 != F3_CFG) || rs1_valid);

  logic [1:0] wsel_q; logic en_q; logic [1:0] ofmt_q, pxfl_q;
  assign cfg_window_sel = wsel_q;
  assign cfg_enable     = en_q;
  assign cfg_out_fmt    = ofmt_q;
  assign cfg_pix_floor  = pxfl_q;

  // layout: [15:8]=frame_count [7:3]=0 [2]=full [1]=done [0]=busy
  logic [31:0] status_w;
  assign status_w = {16'b0, frame_count, 5'b0, frame_full, frame_done, ctrl_busy};

  typedef enum logic [1:0] {C_IDLE, C_COMMIT, C_RESULT} cstate_t;
  cstate_t st;

  logic [X_ID_WIDTH-1:0] id_q;
  logic [2:0]            f3_q;
  logic [31:0]           rs1_q;
  logic [4:0]            rd_q;
  logic [31:0]           res_data_q;

  assign x_issue_ready          = (st == C_IDLE);
  assign x_issue_resp_accept    = (st == C_IDLE) && x_issue_valid && dec_ok;
  assign x_issue_resp_writeback = x_issue_resp_accept;   // all ops write rd
  assign x_issue_resp_dualwrite = 1'b0;
  assign x_issue_resp_loadstore = 1'b0;

  assign x_result_valid = (st == C_RESULT);
  assign x_result_id    = id_q;
  assign x_result_data  = res_data_q;
  assign x_result_rd    = rd_q;
  assign x_result_we    = 1'b1;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      st <= C_IDLE; wsel_q <= 2'd1; en_q <= 1'b0; ofmt_q <= 2'd0; pxfl_q <= 2'd0;  // Hann, idle, complex
      start_pulse <= 1'b0; soft_reset <= 1'b0; stat_read_ack <= 1'b0;
    end else begin
      start_pulse <= 1'b0; soft_reset <= 1'b0; stat_read_ack <= 1'b0;
      unique case (st)
        C_IDLE: if (x_issue_valid && x_issue_resp_accept) begin
          id_q  <= x_issue_req_id;
          f3_q  <= funct3;
          rs1_q <= x_issue_req_rs1;
          rd_q  <= rd_field;
          st    <= C_COMMIT;
        end
        C_COMMIT: if (x_commit_valid && (x_commit_id == id_q)) begin
          if (x_commit_kill) begin
            st <= C_IDLE;                       // speculative squash
          end else begin
            unique case (f3_q)
              F3_CFG: begin
                res_data_q <= {25'b0, pxfl_q, ofmt_q, en_q, wsel_q};  // return old cfg
                wsel_q     <= rs1_q[CFG_WSEL_HI:CFG_WSEL_LO];
                en_q       <= rs1_q[CFG_ENABLE];
                ofmt_q     <= rs1_q[CFG_OFMT_HI:CFG_OFMT_LO];
                pxfl_q     <= rs1_q[CFG_PXFL_HI:CFG_PXFL_LO];
              end
              F3_START: begin
                start_pulse <= 1'b1;
                res_data_q  <= 32'd1;                       // accepted
              end
              F3_STATUS: begin
                res_data_q    <= status_w;
                stat_read_ack <= 1'b1;                      // clear sticky done
              end
              F3_RESET: begin
                soft_reset <= 1'b1;
                res_data_q <= 32'd0;
              end
              default: res_data_q <= 32'd0;
            endcase
            st <= C_RESULT;
          end
        end
        C_RESULT: if (x_result_ready) st <= C_IDLE;
        default: st <= C_IDLE;
      endcase
    end
  end
endmodule

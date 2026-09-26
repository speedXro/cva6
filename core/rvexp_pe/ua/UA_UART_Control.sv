`timescale 1ns / 1ps

module UA_UART_Control #(
    parameter  int unsigned DATA_WIDTH = 64,
    parameter  int unsigned MEM_DEPTH  = 1024,
    localparam int unsigned ADDR_WIDTH = $clog2(MEM_DEPTH)
)(
    input  logic                    clock,
    input  logic                    reset_n,

    input  logic                    ua_enable,
    input  logic                    ua_clear,
    output logic                    ua_empty,

    output logic                    en_a,
    output logic                    we_a,
    output logic [ADDR_WIDTH-1:0]   addr_a,
    output logic [DATA_WIDTH-1:0]   din_a,
    input  logic [DATA_WIDTH-1:0]   dout_a,

    input  logic                    o_ready,
    output logic                    i_result_commit,
    output logic [          63:0]   i_result_data,

    output logic  [ADDR_WIDTH:0]    rd_cnt_out,
    input  logic  [ADDR_WIDTH:0]    ua_lim
);

    logic [3:0] state;

    logic  [ADDR_WIDTH:0]    rd_cnt;

    always_ff @(posedge clock) begin 
        if(reset_n == 1'b0) begin
            en_a            <= 1'd0;
            we_a            <= 1'd0;

            i_result_commit <= 1'd0;

            rd_cnt          <= '0;
            ua_empty        <= 1'd0;
            state           <= 4'd0;
        end

        else if(state == 4'd0 && ua_enable == 1'b1) begin
            state           <= 4'd1; 
        end

        else if(state == 4'd1 && rd_cnt < ua_lim) begin
            en_a            <= 1'b1;
            addr_a          <= rd_cnt[ADDR_WIDTH-1:0];
            rd_cnt          <= rd_cnt + 1;
            state           <= 4'd2;
        end
        else if(state == 4'd1 && rd_cnt == ua_lim) begin
            ua_empty        <= 1'b1;
            state           <= 4'd8;
        end

        else if(state == 4'd2) begin
            en_a            <= 1'b0;
            state           <= 4'd3;
        end

        else if(state == 4'd3) begin
            i_result_commit <= 1'b1;
            i_result_data   <= dout_a;
            state           <= 4'd4;
        end
        else if(state == 4'd4) begin
            i_result_commit <= 1'b0;
            state           <= 4'd5;
        end
        else if(state == 4'd5) begin state <= 4'd6; end
        else if(state == 4'd6) begin state <= 4'd7; end

        else if(state == 4'd7 && o_ready == 1'b1) begin
            state           <= 4'd1;
        end

        else if(state == 4'd8 && ua_clear == 1'b1) begin
            rd_cnt          <= '0;
            ua_empty        <= 1'd0;
            state           <= 4'd0;
        end
    end

    assign rd_cnt_out = rd_cnt;

endmodule

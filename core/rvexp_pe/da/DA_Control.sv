`timescale 1ns / 1ps

module DA_Control #(
    parameter  int unsigned DATA_WIDTH = 64,
    parameter  int unsigned MEM_DEPTH  = 1024,
    localparam int unsigned ADDR_WIDTH = $clog2(MEM_DEPTH)
)(
    input  logic                    clock,
    input  logic                    reset_n,

    input  logic                    da_enable,
    input  logic                    da_clear,
    output logic                    da_empty,

    output logic                    en_a,
    output logic                    we_a,
    output logic [ADDR_WIDTH-1:0]   addr_a,
    output logic [DATA_WIDTH-1:0]   din_a,
    input  logic [DATA_WIDTH-1:0]   dout_a,

    input  logic                    idle,
    output logic                    commit_en,
    output logic [DATA_WIDTH-1:0]   commit_value,

    output logic  [ADDR_WIDTH:0]    rd_cnt_out,
    input  logic  [ADDR_WIDTH:0]    da_lim
);

    logic [3:0] state;

    logic  [ADDR_WIDTH:0]    rd_cnt;

    always_ff @(posedge clock) begin 
        if(reset_n == 1'b0) begin
            en_a            <= 1'd0;
            we_a            <= 1'd0;

            commit_en       <= 1'd0;

            rd_cnt          <= '0;
            da_empty        <= 1'd0;
            state           <= 4'd0;
        end

        else if(state == 4'd0 && da_enable == 1'b1) begin
            state           <= 4'd1; 
        end

        else if(state == 4'd1 && rd_cnt < da_lim) begin
            en_a            <= 1'b1;
            addr_a          <= rd_cnt[ADDR_WIDTH-1:0];
            rd_cnt          <= rd_cnt + 1;
            state           <= 4'd2;
        end
        else if(state == 4'd1 && rd_cnt == da_lim) begin
            da_empty        <= 1'b1;
            state           <= 4'd8;
        end

        else if(state == 4'd2) begin
            en_a            <= 1'b0;
            state           <= 4'd3;
        end

        else if(state == 4'd3) begin
            commit_en    <= 1'b1;
            commit_value <= dout_a;
            state        <= 4'd4;
        end
        else if(state == 4'd4) begin
            commit_en <= 1'b0;
            state         <= 4'd5;
        end
        else if(state == 4'd5) begin state <= 4'd6; end
        else if(state == 4'd6) begin state <= 4'd7; end

        else if(state == 4'd7 && idle == 1'b1) begin
            state           <= 4'd1;
        end

        else if(state == 4'd8 && da_clear == 1'b1) begin
            rd_cnt          <= '0;
            da_empty        <= 1'd0;
            state           <= 4'd0;
        end
    end

    assign rd_cnt_out = rd_cnt;

endmodule

`timescale 1ns / 1ps

module AD_Aq_Control #(
    parameter  int unsigned DATA_WIDTH = 64,
    parameter  int unsigned MEM_DEPTH  = 1024,
    localparam int unsigned ADDR_WIDTH = $clog2(MEM_DEPTH)
)(
    input  logic                    clk,
    input  logic                    reset_n,

    input  logic                    AD_Eofc,
    input  logic [          11:0]   AD_Val,

    input  logic                    ad_aq_enable,
    input  logic                    ad_aq_clear,
    output logic                    ad_aq_full,

    output logic                    en_a,
    output logic                    we_a,
    output logic [ADDR_WIDTH-1:0]   addr_a,
    output logic [DATA_WIDTH-1:0]   din_a,
    input  logic [DATA_WIDTH-1:0]   dout_a,

    output logic  [ADDR_WIDTH:0]    wr_cnt_out,
    input  logic  [ADDR_WIDTH:0]    ad_lim
);

    logic        aq_enabled;
    logic [ 2:0] pack_cnt;
    logic [47:0] pack_value;

    logic [ADDR_WIDTH:0] wr_cnt;

    always_ff @(posedge clk) begin
        if(reset_n == 1'b0) begin
            aq_enabled <= 1'd0;
        end
        else if(ad_aq_enable == 1'b1) begin
            aq_enabled <= 1'b1;
        end
        else if(ad_aq_clear == 1'b1) begin
            aq_enabled <= 1'd0;
        end
    end

    always_ff @(posedge clk) begin
        if(reset_n == 1'b0) begin
            pack_cnt   <= 3'd0;
            wr_cnt     <= '0;
            en_a       <= 1'd0;
            we_a       <= 1'd0;
            ad_aq_full <= 1'd0;
        end
        
        else if(pack_cnt == 3'd0 && AD_Eofc == 1'b1 && aq_enabled == 1'b1) begin pack_value[47:32] <= {4'd0, AD_Val}; pack_cnt <= 3'd1; end
        else if(pack_cnt == 3'd1 && AD_Eofc == 1'b1 && aq_enabled == 1'b1) begin pack_value[31:16] <= {4'd0, AD_Val}; pack_cnt <= 3'd2; end
        else if(pack_cnt == 3'd2 && AD_Eofc == 1'b1 && aq_enabled == 1'b1) begin pack_value[15: 0] <= {4'd0, AD_Val}; pack_cnt <= 3'd3; end
        else if(pack_cnt == 3'd3 && AD_Eofc == 1'b1 && aq_enabled == 1'b1) begin
            en_a       <= 1'b1;
            we_a       <= 1'b1;
            addr_a     <= wr_cnt[ADDR_WIDTH-1:0];
            din_a      <= {pack_value, {4'd0, AD_Val}};
            wr_cnt     <= wr_cnt + 1;
            pack_cnt   <= 3'd4;
        end

        else if(pack_cnt == 3'd4 && wr_cnt < ad_lim) begin
            en_a       <= 1'd0;
            we_a       <= 1'd0;
            pack_cnt   <= 3'd0;
        end
        else if(pack_cnt == 3'd4 && wr_cnt == ad_lim) begin
            en_a       <= 1'd0;
            we_a       <= 1'd0;
            ad_aq_full <= 1'd1;
            pack_cnt   <= 3'd5;
        end

        else if(ad_aq_clear == 1'b1) begin
            pack_cnt   <= 3'd0;
            wr_cnt     <= '0;
            ad_aq_full <= 1'd0;
        end
    end

    assign wr_cnt_out = wr_cnt;


endmodule

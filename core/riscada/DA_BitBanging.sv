//`timescale 1ns / 1ps

module DA_BitBanging(
    input  logic        clk,
    input  logic        reset,
    
    input  logic        da_we,
    input  logic [11:0] da_value,
    
    output logic        da_sync_n,
    output logic        da_sclk,
    output logic        da_din,
    output logic        da_busy
);

    parameter da_mode = 2'b00;

    logic [ 1:0] state;
    logic [ 3:0] cnt;
    logic [15:0] data_out;
    
    logic  sync_n;
    logic  din;

    always_ff @(posedge clk) begin
        if(reset == 1'b1) begin
            data_out    <= 16'd0;
            state       <=  2'd0;
            cnt         <=  4'd15;
            sync_n      <=  1'b1;
            din         <=  1'd0;
        end
        else if(state == 2'd0 && da_we == 1'b1) begin
            data_out   <= {2'b00, da_mode, da_value};            
            state      <= 2'd1;
        end
        else if(state == 2'd1 && (cnt == 4'd15)) begin
            sync_n     <= 1'b0;
            din        <= data_out[15];
            data_out   <= {data_out[14:0], 1'b0};
            cnt        <= cnt - 4'd1;
            state      <= 2'd1;
        end
        else if(state == 2'd1 && (cnt >= 4'd1 && cnt <= 4'd14)) begin
            din        <= data_out[15];
            data_out   <= {data_out[14:0], 1'b0};
            cnt        <= cnt - 4'd1;
            state      <= 2'd1;
        end
        else if(state == 2'd1 && cnt == 4'd0) begin
            din        <= data_out[15];
            data_out   <= 16'd0;
            cnt        <=  4'd15;
            state      <=  2'd2;
        end
        else if(state == 2'd2) begin
            sync_n    <= 1'b1;
            state     <= 2'd0;
        end
        da_busy <= (state != 2'd0);
    end
    
    always_comb begin
        da_sync_n <= sync_n;
        da_sclk   <= clk & (~sync_n);
        da_din    <= din;    
    end

endmodule
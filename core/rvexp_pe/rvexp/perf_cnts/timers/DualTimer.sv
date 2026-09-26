`timescale 1 ns / 1 ps

module DualTimer(
    input  logic clock,
    input  logic reset_n,

    //Outter Timer Interface
    input  logic        outter_start,
    input  logic        outter_stop,
    output logic        outter_commit,
    output logic [15:0] outter_value,

    input  logic        inner_start,
    input  logic        inner_inc,
    input  logic        inner_stop,
    output logic        inner_commit, 
    output logic [15:0] inner_value
);

    //Outter Timer
    logic [ 1:0] outter_state;
    logic [15:0] outter_cnt;
    logic        outter_comm;
    logic [15:0] outter_val;

    always_ff @(posedge clock) begin
        if(reset_n == 1'b0) begin
            outter_state <=  2'd0;
            //outter_cnt   <= 16'd0;
            outter_comm  <=  1'd0;
        end
        else if(outter_state == 2'd0 && outter_start == 1'b1) begin
            outter_state <=  2'd1;
            outter_cnt   <= 16'd1;
        end

        else if(outter_state == 2'd1 && outter_stop == 1'b0) begin
            outter_state <=  2'd1;
            outter_cnt   <= outter_cnt + 16'd1;
        end
        else if(outter_state == 2'd1 && outter_stop == 1'b1) begin
            outter_state <=  2'd2;
            //outter_cnt   <= 16'd0;

            outter_comm  <= 1'b1;
            outter_val   <= outter_cnt;
        end

        else if(outter_state == 2'd2 && outter_start == 1'b0) begin
            outter_state <= 2'd0;
            outter_comm  <= 1'b0;
        end
        else if(outter_state == 2'd2 && outter_start == 1'b1) begin
            outter_state <=  2'd1;
            outter_comm  <= 1'b0;
            outter_cnt   <= 16'd1;
        end 
    end

    
    //Inner Timer
    logic [ 1:0] inner_state;
    logic [15:0] inner_cnt;
    logic        inner_comm;
    logic [15:0] inner_val;

    always_ff @(posedge clock) begin
        if(reset_n == 1'b0) begin
            inner_state <= 2'd0;
            //inner_cnt   <= 16'd0;
            inner_comm  <= 1'd0;
        end
        else if(inner_state == 2'd0 && inner_start == 2'b1) begin
            inner_state <=  2'd1;
            inner_cnt   <= 16'd1;
        end

        else if(inner_state == 2'd1 && inner_stop == 1'b0 && inner_inc == 1'b1) begin
            inner_state <= 2'd1;
            inner_cnt   <= inner_cnt + 16'd1;
        end

        else if(inner_state == 2'd1 && inner_stop == 1'b1) begin
            inner_state <= 2'd2;
            inner_comm  <= 1'b1;
            inner_val   <= inner_cnt;
        end

        else if(inner_state == 2'd2 && inner_start == 1'b0) begin
            inner_state <= 2'd0;
            inner_comm  <= 1'b0;
        end
        else if(inner_state == 2'd2 && inner_start == 1'b1) begin
            inner_state <=  2'd1;
            inner_comm  <= 1'b0;
            inner_cnt   <= 16'd1;
        end 
    end

    //Output stages
    always_ff @(posedge clock) begin
        if(reset_n == 1'b0) begin
            outter_commit <= 1'd0;
        end
        else begin
            outter_commit <= outter_comm;
            outter_value  <= outter_val;
        end 
    end

    always_ff @(posedge clock) begin
        if(reset_n == 1'b0) begin
            inner_commit <= 1'd0;
        end
        else begin
            inner_commit <= inner_comm;
            inner_value  <= inner_val;
        end 
    end
endmodule

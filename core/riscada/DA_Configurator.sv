//`timescale 1ns / 1ps

module DA_Configurator(
    input  logic         clk,
    input  logic         reset,

    input  logic         da_val_we,
    input  logic [ 11:0] da_val_value,

    input  logic         da_seq_values_we,
    input  logic [119:0] da_seq_values,
    
    input  logic         da_seq_lengths_we,
    input  logic [119:0] da_seq_lengths,

    input  logic         da_seq_length_we,
    input  logic [  3:0] da_seq_length,

    input  logic         da_seq_start_we,

    output logic         da_configurator_busy,
    output logic         da_sequence_running,
    output logic [ 11:0] da_out_val,

    input  logic         DA_BB_Busy,
    output logic [ 11:0] DA_Config_Value
);

    logic [  3:0] state;

    logic [ 11:0] da_val;

    logic [ 11:0] da_seq_vals[0:9];
    logic [ 11:0] da_seq_lens[0:9];

    logic [  3:0] da_seq_len;

    logic         da_seq_enable;

    logic [3:0]   seq_cnt;

    logic         ms1_reset;
    logic         seq_reset;

    //for 1 ms passed tick gen
    logic [16:0] cnt;
    logic        ms1_tick;

    logic [11:0] ms_cnt;
    logic        seq_tick;
    logic [11:0] seq_len;

    initial begin
        DA_Config_Value <= 12'd0;
        da_val          <= 12'd0;
        {
            da_seq_vals[0], da_seq_vals[1], 
            da_seq_vals[2], da_seq_vals[3], 
            da_seq_vals[4], da_seq_vals[5], 
            da_seq_vals[6], da_seq_vals[7], 
            da_seq_vals[8], da_seq_vals[9] 
        } <= 120'd0;
        {
            da_seq_lens[0], da_seq_lens[1], 
            da_seq_lens[2], da_seq_lens[3], 
            da_seq_lens[4], da_seq_lens[5], 
            da_seq_lens[6], da_seq_lens[7], 
            da_seq_lens[8], da_seq_lens[9] 
        } <= 120'd0;
        da_seq_len   <= 4'd1;
        da_seq_enable <= 1'd0;

        seq_cnt      <= 4'd0;
        
        ms1_reset    <= 1'd0;
        seq_reset    <= 1'd0;
        seq_len      <= 12'd0;
    end
    always_ff @(posedge clk) begin
        if(reset == 1'b1) begin
            state  <= 4'd0;
        end
        
        else if(state == 4'd0 && da_val_we == 1'b1) begin
            da_val <= da_val_value;
            state  <= 4'd1;
        end
        else if(state == 4'd1 && DA_BB_Busy == 1'b1) begin
            state <= 4'd1;
        end
        else if(state == 4'd1 && DA_BB_Busy == 1'b0) begin
            DA_Config_Value <= da_val;
            state           <= 4'd0;
        end

        else if(state == 4'd0 && da_seq_values_we == 1'b1) begin
            {
                da_seq_vals[0], da_seq_vals[1], 
                da_seq_vals[2], da_seq_vals[3], 
                da_seq_vals[4], da_seq_vals[5], 
                da_seq_vals[6], da_seq_vals[7], 
                da_seq_vals[8], da_seq_vals[9] 
            } <= da_seq_values;
            state  <= 4'd0;
        end

        else if(state == 4'd0 && da_seq_lengths_we == 1'b1) begin
            {
                da_seq_lens[0], da_seq_lens[1], 
                da_seq_lens[2], da_seq_lens[3], 
                da_seq_lens[4], da_seq_lens[5], 
                da_seq_lens[6], da_seq_lens[7], 
                da_seq_lens[8], da_seq_lens[9] 
            } <= da_seq_lengths;
            state  <= 4'd0;
        end

        else if(state == 4'd0 && da_seq_length_we == 1'b1) begin
            da_seq_len <= da_seq_length;
            state      <= 4'd0;
        end

        else if(state == 4'd0 && da_seq_start_we == 1'b1) begin
            da_seq_enable <= 1'b1;
            seq_cnt      <= 4'd0;
            state        <= 4'd2;
        end
        else if(state == 4'd2 && DA_BB_Busy == 1'b1) begin
            state        <= 4'd2;
        end
        else if(state == 4'd2 && DA_BB_Busy == 1'b0) begin
            ms1_reset    <= 1'b1;
            seq_reset    <= 1'b1;
            seq_len         <= da_seq_lens[seq_cnt];
            da_val          <= da_seq_vals[seq_cnt];
            DA_Config_Value <= da_seq_vals[seq_cnt];
            //seq_cnt      <= seq_cnt + 4'd1;
            state        <= 4'd3;
        end

        else if(state == 4'd3) begin
            ms1_reset    <= 1'b0;
            seq_reset    <= 1'b0;
            state        <= 4'd4;
        end

        else if(state == 4'd4 && seq_tick == 1'b0) begin
            state        <= 4'd4;
        end
        else if(state == 4'd4 && seq_tick == 1'b1) begin
            state        <= 4'd5;
        end

        else if(state == 4'd5 && seq_cnt < da_seq_len - 4'd1) begin
            seq_cnt      <= seq_cnt + 4'd1;
            state        <= 4'd2;
        end
        else if(state == 4'd5 && seq_cnt == da_seq_len - 4'd1) begin
            da_seq_enable <= 1'b0;
            seq_cnt      <= 4'd0;
            state        <= 4'd0;
        end
        da_configurator_busy <= (state != 4'd0);
    end

    assign da_sequence_running = da_seq_enable;
    assign da_out_val = DA_Config_Value;

    always_ff @(posedge clk) begin
        if(reset == 1'b1) begin
            cnt      <= 17'd0;
            ms1_tick <=  1'd0;
        end
        else if(ms1_reset == 1'b1) begin
            cnt      <= 17'd0;
            ms1_tick <=  1'd0;
        end
        else if((da_seq_enable == 1'b1) && (cnt >= 17'd0 && cnt <= 17'd99_998)) begin
            cnt      <= cnt + 17'd1;
            ms1_tick <= 1'b0;
        end
        else if(cnt == 17'd99_999) begin
            cnt      <= 17'd0;
            ms1_tick <=  1'b1;
        end
    end

    //for 1 seq length passed


    always_ff @(posedge clk) begin
        if(reset == 1'b1) begin
            ms_cnt   <= 12'd0;
            seq_tick <=  1'd0;
        end
        else if(seq_reset == 1'b1) begin
            ms_cnt   <= 12'd0;
            seq_tick <=  1'd0;
        end
        else if((ms1_tick == 1'b1) && (ms_cnt >= 12'd0 && ms_cnt <= seq_len-2)) begin
            ms_cnt   <= ms_cnt + 12'd1;
            seq_tick <=  1'd0;
        end
        else if(ms_cnt == seq_len-1) begin
            ms_cnt   <= 12'd0;
            seq_tick <=  1'b1;
        end
    end




endmodule
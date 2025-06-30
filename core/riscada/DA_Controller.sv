//`timescale 1ns / 1ps

module DA_Controller #(
    parameter N_DA = 2
)(
    input  logic            clk_100,
    input  logic            reset,

    input  logic            da_enb,
    input  logic [     2:0] da_fct3,
    input  logic [     6:0] da_fct7,
    input  logic [    63:0] da_op1,
    input  logic [    63:0] da_op2,

    output logic [     7:0] addr,

    output logic            da_broadcast_we,

    output logic            da_val_we,
    output logic [    11:0] da_val_value,

    output logic            da_seq_values_we,
    output logic [   119:0] da_seq_values,
    
    output logic            da_seq_lengths_we,
    output logic [   119:0] da_seq_lengths,

    output logic            da_seq_length_we,
    output logic [     3:0] da_seq_length,

    output logic            da_seq_start_we,


    input  logic [N_DA-1:0] bus_da_configurator_busy,
    input  logic [N_DA-1:0] bus_da_sequence_running,
    input  logic [    11:0] da_val_output,

    output logic            da_rd_we,
    output logic [    63:0] da_rd      
);

    localparam FUNC_SET_VAL         = 7'b10_0_1000;
    localparam FUNC_SET_SEQ_LEN     = 7'b10_0_1001;
    localparam FUNC_SET_SEQ_VALS    = 7'b10_0_1010;
    localparam FUNC_SET_SEQ_DURS    = 7'b10_0_1011;
    localparam FUNC_SET_SEQ_START   = 7'b10_0_1100;

    localparam FUNC_GET_VAL         = 7'b11_0_1000;
    localparam FUNC_GET_SEQ_RUNNING = 7'b11_0_1001;
    localparam FUNC_GET_DA_BUSY     = 7'b11_0_1010;

    localparam PADDED_ZEROES        = 64 - N_DA;

    logic [2:0] state;

    logic f3_broadcast;

    assign f3_broadcast = da_fct3[2];

    always_ff @(posedge clk_100) begin
        if(reset == 1'b1) begin
            state             <=   3'd0;
            
            addr              <=   8'd0;

            da_broadcast_we   <=   1'd0;

            da_val_we         <=   1'd0;
            da_val_value      <=  12'd0;

            da_seq_values_we  <=   1'd0;
            da_seq_values     <= 120'd0;

            da_seq_lengths_we <=   1'd0;
            da_seq_lengths    <= 120'd0;

            da_seq_length_we  <=   1'd0;
            da_seq_length     <=   4'd0;

            da_seq_start_we   <=   1'd0;

            da_rd_we          <=   1'd0;
            da_rd             <=  64'd0;
        end

        //Setting instant DA Value
        else if(state == 3'd0 && da_enb == 1'b1 && f3_broadcast == 1'b0 && da_fct7 == FUNC_SET_VAL) begin
            addr              <= {da_op1[63:60], da_op2[63:60]};
            da_broadcast_we   <=   1'b0;
            da_val_we         <=   1'b1;
            da_val_value      <=  da_op2[11:0];
            da_rd_we          <=   1'b1;
            da_rd             <=  da_op1 ^ da_op2;
            state             <=   3'd3;
        end
        else if(state == 3'd0 && da_enb == 1'b1 && f3_broadcast == 1'b1 && da_fct7 == FUNC_SET_VAL) begin
            addr              <=   8'd0;
            da_broadcast_we   <=   1'b1;
            da_val_we         <=   1'b1;
            da_val_value      <=  da_op2[11:0];
            da_rd_we          <=   1'b1;
            da_rd             <=  da_op1 ^ da_op2;
            state             <=   3'd3;
        end

        //Setting sequence lengths
        else if(state == 3'd0 && da_enb == 1'b1 && f3_broadcast == 1'b0 && da_fct7 == FUNC_SET_SEQ_LEN) begin
            addr              <= {da_op1[63:60], da_op2[63:60]};
            da_broadcast_we   <=   1'b0;
            da_seq_length_we  <=   1'b1;
            da_seq_length     <=  da_op2[ 3:0];
            da_rd_we          <=   1'b1;
            da_rd             <=  da_op1 ^ da_op2;
            state             <=   3'd3;
        end
        else if(state == 3'd0 && da_enb == 1'b1 && f3_broadcast == 1'b1 && da_fct7 == FUNC_SET_SEQ_LEN) begin
            addr              <=   8'd0;
            da_broadcast_we   <=   1'b1;
            da_seq_length_we  <=   1'b1;
            da_seq_length     <=  da_op2[ 3:0];
            da_rd_we          <=   1'b1;
            da_rd             <=  da_op1 ^ da_op2;
            state             <=   3'd3;
        end

        //Setting sequence values
        else if(state == 3'd0 && da_enb == 1'b1 && f3_broadcast == 1'b0 && da_fct7 == FUNC_SET_SEQ_VALS) begin
            addr              <= {da_op1[63:60], da_op2[63:60]};
            da_broadcast_we   <=   1'b0;
            da_seq_values_we  <=   1'b1;
            da_seq_values     <= {da_op1[59:0], da_op2[59:0]};
            da_rd_we          <=   1'b1;
            da_rd             <=  da_op1 ^ da_op2;
            state             <=   3'd3;
        end
        else if(state == 3'd0 && da_enb == 1'b1 && f3_broadcast == 1'b1 && da_fct7 == FUNC_SET_SEQ_VALS) begin
            addr              <=   8'd0;
            da_broadcast_we   <=   1'b1;
            da_seq_values_we  <=   1'b1;
            da_seq_values     <= {da_op1[59:0], da_op2[59:0]};
            da_rd_we          <=   1'b1;
            da_rd             <=  da_op1 ^ da_op2;
            state             <=   3'd3;
        end

        //Setting sequence lengths
        else if(state == 3'd0 && da_enb == 1'b1 && f3_broadcast == 1'b0 && da_fct7 == FUNC_SET_SEQ_DURS) begin
            addr              <= {da_op1[63:60], da_op2[63:60]};
            da_broadcast_we   <=   1'b0;
            da_seq_lengths_we <=   1'b1;
            da_seq_lengths    <= {da_op1[59:0], da_op2[59:0]};
            da_rd_we          <=   1'b1;
            da_rd             <=  da_op1 ^ da_op2;
            state             <=   3'd3;
        end
        else if(state == 3'd0 && da_enb == 1'b1 && f3_broadcast == 1'b1 && da_fct7 == FUNC_SET_SEQ_DURS) begin
            addr              <=   8'd0;
            da_broadcast_we   <=   1'b1;
            da_seq_lengths_we <=   1'b1;
            da_seq_lengths    <= {da_op1[59:0], da_op2[59:0]};
            da_rd_we          <=   1'b1;
            da_rd             <=  da_op1 ^ da_op2;
            state             <=   3'd3;
        end

        //Starting sequence
        else if(state == 3'd0 && da_enb == 1'b1 && f3_broadcast == 1'b0 && da_fct7 == FUNC_SET_SEQ_START) begin
            addr              <= {da_op1[63:60], da_op2[63:60]};
            da_broadcast_we   <=   1'b0;
            da_seq_start_we   <=   1'b1;
            da_rd_we          <=   1'b1;
            da_rd             <=  da_op1 ^ da_op2;
            state             <=   3'd3;
        end
        else if(state == 3'd0 && da_enb == 1'b1 && f3_broadcast == 1'b1 && da_fct7 == FUNC_SET_SEQ_START) begin
            addr              <=   8'd0;
            da_broadcast_we   <=   1'b1;
            da_seq_start_we   <=   1'b1;
            da_rd_we          <=   1'b1;
            da_rd             <=  da_op1 ^ da_op2;
            state             <=   3'd3;
        end

        //Getting things
        else if(state == 3'd0 && da_enb == 1'b1 && da_fct7 == FUNC_GET_VAL) begin
            addr              <= {da_op1[63:60], da_op2[63:60]};
            state             <=   3'd1;
        end
        else if(state == 3'd1) begin
            da_rd_we          <=   1'b1;
            da_rd             <= {50'b0, da_val_output};
            state             <=   3'd3;
        end

        else if(state == 3'd0 && da_enb == 1'b1 && da_fct7 == FUNC_GET_SEQ_RUNNING) begin
            da_rd_we          <=   1'b1;
            da_rd             <= {{PADDED_ZEROES{1'b0}}, bus_da_sequence_running};
            state             <=   3'd3;
        end
        else if(state == 3'd0 && da_enb == 1'b1 && da_fct7 == FUNC_GET_DA_BUSY) begin
            da_rd_we          <=   1'b1;
            da_rd             <= {{PADDED_ZEROES{1'b0}}, bus_da_configurator_busy};
            state             <=   3'd3;
        end

        else if(state == 3'd3) begin            
            state             <=   3'd0;
            
            addr              <=   8'd0;

            da_broadcast_we   <=   1'd0;

            da_val_we         <=   1'd0;
            da_val_value      <=  12'd0;

            da_seq_values_we  <=   1'd0;
            da_seq_values     <= 120'd0;

            da_seq_lengths_we <=   1'd0;
            da_seq_lengths    <= 120'd0;

            da_seq_length_we  <=   1'd0;
            da_seq_length     <=   4'd0;

            da_seq_start_we   <=   1'd0;

            da_rd_we          <=   1'd0;
            da_rd             <=  64'd0;
        end
    end

endmodule
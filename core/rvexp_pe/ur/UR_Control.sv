`timescale 1ns / 1ps

module UR_Control(
    input  logic        clock,
    input  logic        reset_n,

    input  logic        o_Rx_DV,
    input  logic [7:0]  o_Rx_Byte,

    output logic        ur_stop,
    output logic        ur_ready,
    input  logic        ur_clear_stop,
    input  logic        ur_clear_ready,

    output logic [7:0]  ur_qf,
    output logic [1:0]  ur_pf,
    output logic        ur_ws
);

    // Command decode
    logic cmd_ready, cmd_stop, cmd_qf, cmd_pf, cmd_ws;

    assign cmd_ready = o_Rx_DV && (o_Rx_Byte == 8'h97);
    assign cmd_stop  = o_Rx_DV && (o_Rx_Byte == 8'h98);
    assign cmd_qf    = o_Rx_DV && (o_Rx_Byte >= 8'h32) && (o_Rx_Byte <= 8'h95);
    assign cmd_pf    = o_Rx_DV && (o_Rx_Byte >= 8'h2E) && (o_Rx_Byte <= 8'h31);
    assign cmd_ws    = o_Rx_DV && (o_Rx_Byte >= 8'h2C) && (o_Rx_Byte <= 8'h2D);

    logic [7:0] pf_diff, ws_diff;
    assign pf_diff = o_Rx_Byte - 8'h2E;
    assign ws_diff = o_Rx_Byte - 8'h2C;

    // Flags: set has priority over clear (explicit)
    always_ff @(posedge clock) begin
        if (!reset_n) begin
            ur_ready <= 1'b0;
            ur_stop  <= 1'b0;
        end else begin
            if (cmd_ready)           ur_ready <= 1'b1;
            else if (ur_clear_ready) ur_ready <= 1'b0;

            if (cmd_stop)            ur_stop  <= 1'b1;
            else if (ur_clear_stop)  ur_stop  <= 1'b0;
        end
    end

    // Parameters
    always_ff @(posedge clock) begin
        if (!reset_n) begin
            ur_qf <= 8'd100;
            ur_pf <= 2'd0;
            ur_ws <= 1'b0;
        end else begin
            if (cmd_qf) ur_qf <= o_Rx_Byte - 8'h31;
            if (cmd_pf) ur_pf <= pf_diff[1:0];
            if (cmd_ws) ur_ws <= ws_diff[0];
        end
    end

endmodule

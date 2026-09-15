`timescale 1ns / 1 ps
// =============================================================================
// axis_output.sv
// AXI-Stream output module for the bit-flip accelerator.
//
// Accepts processed beats from the processing module and drives them onto
// the AXI4-Stream master port toward the downstream slave (DMA / sink).
//
// A skid buffer is included so the upstream processing pipeline is never
// stalled purely because of a one-cycle combinational tready deassertion
// from the downstream slave.  This makes the module fully AXI4-Stream
// compliant and prevents long combinational ready chains.
// =============================================================================

module axis_output #(
    parameter int unsigned AXIS4_DATAWITH = 512
) (
    input  logic                            aclk,
    input  logic                            aresetn,

    // ---- From processing module --------------------------------------------
    input  logic [AXIS4_DATAWITH-1:0]       in_data,
    input  logic [(AXIS4_DATAWITH/8)-1:0] in_keep,
    input  logic                            in_last,
    input  logic                            in_valid,
    output logic                            in_ready,

    // ---- AXI4-Stream master port (to DMA / downstream slave) ---------------
    output logic [AXIS4_DATAWITH-1:0]       m_tdata,
    output logic                            m_tvalid,
    output logic [(AXIS4_DATAWITH/8)-1:0]   m_tkeep,
    input  logic                            m_tready,
    output logic                            m_tlast
);

    // -------------------------------------------------------------------------
    // Two-entry skid buffer
    //
    // Slot A: the "output" register driven onto the AXI-Stream master port.
    // Slot B: the "overflow" register that absorbs one beat when the downstream
    //         slave de-asserts tready while we are still receiving from upstream.
    //
    // State machine (state = {b_valid, a_valid}):
    //   00 -> idle, accept into A
    //   01 -> A has data; if tready=1 send and accept new beat into A, else
    //         if upstream has data, load B
    //   11 -> both full; stall upstream (in_ready = 0)
    //   10 -> impossible (B full, A empty) by construction
    // -------------------------------------------------------------------------
    logic [AXIS4_DATAWITH-1:0] a_data, b_data;
    logic [(AXIS4_DATAWITH/8)-1:0]  a_keep, b_keep;
    logic        a_last, b_last;
    logic        a_valid, b_valid;

    always_ff @(posedge aclk) begin
        if (!aresetn) begin
            a_valid <= 1'b0; b_valid <= 1'b0;
            a_data <= '0; b_data <= '0;
            a_keep <= '0; b_keep <= '0;
            a_last <= 1'b0; b_last <= 1'b0;
        end else begin
            case ({b_valid, a_valid})

                2'b00: begin
                    // Idle: accept into slot A
                    if (in_valid) begin
                        a_valid <= 1'b1;
                        a_data  <= in_data;
                        a_keep  <= in_keep;
                        a_last  <= in_last;
                    end
                end

                2'b01: begin
                    if (m_tready) begin
                        // Downstream accepting: shift B->A, or load new into A
                        if (b_valid) begin
                            // Should not reach here since b_valid=0 in this arm, but
                            // kept for completeness
                            a_valid <= 1'b1;
                            a_data  <= b_data;
                            a_keep  <= b_keep;
                            a_last  <= b_last;
                            b_valid <= 1'b0;
                            b_last  <= 1'b0;
                        end else if (in_valid) begin
                            a_valid <= 1'b1;
                            a_data  <= in_data;
                            a_keep  <= in_keep;
                            a_last  <= in_last;
                        end else begin
                            a_valid <= 1'b0;
                            a_last  <= 1'b0;
                        end
                    end else begin
                        // Downstream stalling: absorb new beat into B if presented
                        if (in_valid && !b_valid) begin
                            b_valid <= 1'b1;
                            b_data  <= in_data;
                            b_keep  <= in_keep;
                            b_last  <= in_last;
                        end
                    end
                end

                2'b11: begin
                    // Both slots full: can only drain A into downstream
                    if (m_tready) begin
                        // Move B into A, clear B
                        a_valid <= 1'b1;
                        a_data  <= b_data;
                        a_keep  <= b_keep;
                        a_last  <= b_last;
                        b_valid <= 1'b0;
                        b_last  <= 1'b0;
                    end
                end

                default: ; // 2'b10: unreachable

            endcase
        end
    end

    // in_ready: we can accept as long as slot B is free
    assign in_ready = !b_valid;

    // Drive AXI-Stream master port from slot A
    assign m_tdata  = a_data;
    assign m_tkeep  = a_keep;
    assign m_tlast  = a_last;
    assign m_tvalid = a_valid;

endmodule

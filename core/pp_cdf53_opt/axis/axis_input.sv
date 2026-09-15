`timescale 1ns / 1 ps
// =============================================================================
// axis_input.sv
// AXI-Stream input module for the bit-flip accelerator.
//
// Receives an AXI-Stream beat from the upstream master and presents the
// captured data/keep/last to the processing module via a simple
// valid/ready handshake (internal interface).
//
// Backpressure:  tready is de-asserted whenever the internal output register
//                is full and the downstream consumer (processing) has not yet
//                accepted it.  This makes the module fully AXI4-Stream
//                compliant (no combinational path from tvalid to tready).
// =============================================================================

module axis_input #(
    parameter int unsigned AXIS4_DATAWITH = 512
) (
    input  logic                            aclk,
    input  logic                            aresetn,   

    // ---- AXI4-Stream slave port (from DMA / upstream master) ---------------
    input  logic [AXIS4_DATAWITH-1:0]       s_tdata,
    input  logic                            s_tvalid,
    input  logic [(AXIS4_DATAWITH/8)-1:0]   s_tkeep,
    output logic                            s_tready,
    input  logic                            s_tlast,

    // ---- Internal output to processing module ------------------------------
    output logic [AXIS4_DATAWITH-1:0]       out_data,
    output logic [(AXIS4_DATAWITH/8)-1:0]   out_keep,
    output logic                            out_last,
    output logic                            out_valid,
    input  logic                            out_ready       // processing module asserts when it can accept
);

    // -------------------------------------------------------------------------
    // Single-entry skid buffer (output register)
    // Holds one beat while waiting for the processing module to accept it.
    // -------------------------------------------------------------------------
    logic [AXIS4_DATAWITH-1:0]      data_reg;
    logic [(AXIS4_DATAWITH/8)-1:0]  keep_reg;
    logic                           last_reg;
    logic                           valid_reg;

    always_ff @(posedge aclk) begin
        if (!aresetn) begin
            valid_reg <= 1'b0;
            data_reg  <= '0;
            keep_reg  <= '0;
            last_reg  <= 1'b0;
        end else begin
            if (out_ready) begin
                // Downstream accepted whatever was in the register; we can
                // accept a new beat from the AXI-Stream master this cycle.
                valid_reg <= s_tvalid & s_tready;
                if (s_tvalid & s_tready) begin
                    data_reg <= s_tdata;
                    keep_reg <= s_tkeep;
                    last_reg <= s_tlast;
                end
                else begin last_reg <= 1'b0; end
            end else if (!valid_reg) begin
                // Register is empty; accept from upstream if presented.
                if (s_tvalid) begin
                    valid_reg <= 1'b1;
                    data_reg  <= s_tdata;
                    keep_reg  <= s_tkeep;
                    last_reg  <= s_tlast;
                end
                //else begin last_reg <= 1'b0; end
            end
            //else begin last_reg <= 1'b0; end
            // If valid_reg is set and out_ready is 0: hold, do not accept new data.
        end
    end

    // tready: we can accept a new beat whenever the register is empty
    // OR the processing module is draining it this cycle.
    assign s_tready = !valid_reg | out_ready;

    // Drive internal output port
    assign out_data  = data_reg;
    assign out_keep  = keep_reg;
    assign out_last  = last_reg;
    assign out_valid = valid_reg;

endmodule

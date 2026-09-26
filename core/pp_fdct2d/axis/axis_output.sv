`timescale 1ns / 1 ps


module axis_output #(
    parameter int unsigned AXIS4_DATAWITH = 512
) (
    input  logic                            aclk,
    input  logic                            aresetn,

    input  logic [AXIS4_DATAWITH-1:0]       in_data,
    input  logic [(AXIS4_DATAWITH/8)-1:0] in_keep,
    input  logic                            in_last,
    input  logic                            in_valid,
    output logic                            in_ready,

    output logic [AXIS4_DATAWITH-1:0]       m_tdata,
    output logic                            m_tvalid,
    output logic [(AXIS4_DATAWITH/8)-1:0]   m_tkeep,
    input  logic                            m_tready,
    output logic                            m_tlast
);

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
                        if (b_valid) begin
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
                        if (in_valid && !b_valid) begin
                            b_valid <= 1'b1;
                            b_data  <= in_data;
                            b_keep  <= in_keep;
                            b_last  <= in_last;
                        end
                    end
                end

                2'b11: begin
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

                default: ;

            endcase
        end
    end

    assign in_ready = !b_valid;

    assign m_tdata  = a_data;
    assign m_tkeep  = a_keep;
    assign m_tlast  = a_last;
    assign m_tvalid = a_valid;

endmodule

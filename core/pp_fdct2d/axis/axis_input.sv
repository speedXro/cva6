`timescale 1ns / 1 ps

module axis_input #(
    parameter int unsigned AXIS4_DATAWITH = 512
) (
    input  logic                            aclk,
    input  logic                            aresetn,   

    input  logic [AXIS4_DATAWITH-1:0]       s_tdata,
    input  logic                            s_tvalid,
    input  logic [(AXIS4_DATAWITH/8)-1:0]   s_tkeep,
    output logic                            s_tready,
    input  logic                            s_tlast,

    output logic [AXIS4_DATAWITH-1:0]       out_data,
    output logic [(AXIS4_DATAWITH/8)-1:0]   out_keep,
    output logic                            out_last,
    output logic                            out_valid,
    input  logic                            out_ready       
);


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
                valid_reg <= s_tvalid & s_tready;
                if (s_tvalid & s_tready) begin
                    data_reg <= s_tdata;
                    keep_reg <= s_tkeep;
                    last_reg <= s_tlast;
                end
                else begin last_reg <= 1'b0; end
            end else if (!valid_reg) begin
                if (s_tvalid) begin
                    valid_reg <= 1'b1;
                    data_reg  <= s_tdata;
                    keep_reg  <= s_tkeep;
                    last_reg  <= s_tlast;
                end
            end
        end
    end

    assign s_tready = !valid_reg | out_ready;

    assign out_data  = data_reg;
    assign out_keep  = keep_reg;
    assign out_last  = last_reg;
    assign out_valid = valid_reg;

endmodule

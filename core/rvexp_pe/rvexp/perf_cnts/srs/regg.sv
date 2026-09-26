`timescale 1ns / 1 ps

module regg #(
    parameter WIDTH = 8
)(
    input  logic             clock,
    input  logic             reset_n,

    input  logic             shift_in,
    input  logic [WIDTH-1:0] data_in,

    input  logic             pl_in,
    input  logic [WIDTH-1:0] pl_in_data,

    output logic [WIDTH-1:0] data_out
);

    logic [WIDTH-1:0] data;

    always_ff @(posedge clock or negedge reset_n) begin
        if(reset_n == 1'b0) begin
            data      <= '0;
        end
        else if(shift_in == 1'b1) begin
            data      <= data_in;
        end
        else if(pl_in == 1'b1) begin
            data      <= pl_in_data; 
        end
    end

    assign data_out = data;

endmodule

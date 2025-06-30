//`timescale 1ns / 1ps

module ADA_Rd_Mux(
    input  logic        da_rd_we,
    input  logic [63:0] da_rd,

    input  logic        ad_rd_we,
    input  logic [63:0] ad_rd,

    output logic        result_we,
    output logic [63:0] result_rd
);

    always_comb begin
        result_we =  1'd0;

        if(ad_rd_we == 1'b1) begin
            result_we = 1'b1;
        end
        else if(da_rd_we == 1'b1) begin
            result_we = 1'b1;
        end
        else begin
            result_we = 1'b0;
        end
    end

    always_comb begin
        result_rd =  64'd0;

        if(ad_rd_we == 1'b1) begin
            result_rd = ad_rd;
        end
        else if(da_rd_we == 1'b1) begin
            result_rd = da_rd;
        end
        else begin
            result_rd = 64'd0;
        end
    end
endmodule
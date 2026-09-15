`timescale 1 ns / 1 ps

module ValidLastCounters(
    input  logic clock,
    input  logic reset_n,

    input  logic mvalid_inc,
    input  logic mlast_inc,
    input  logic svalid_inc,
    input  logic slast_inc,

    output logic [31:0] mvalid_cnt,
    output logic [31:0] mlast_cnt,
    output logic [31:0] svalid_cnt,
    output logic [31:0] slast_cnt
);

    logic [31:0] mvalid_counter;
    logic [31:0] mlast_counter;
    logic [31:0] svalid_counter;
    logic [31:0] slast_counter;

    always_ff @(posedge clock) begin
        if(reset_n == 1'b0) begin mvalid_counter <= 32'd0; end
        else if(mvalid_inc == 1'b1) begin mvalid_counter <= mvalid_counter + 32'd1; end
    end

    always_ff @(posedge clock) begin
        if(reset_n == 1'b0) begin mlast_counter <= 32'd0; end
        else if(mlast_inc == 1'b1) begin mlast_counter <= mlast_counter + 32'd1; end
    end

    always_ff @(posedge clock) begin
        if(reset_n == 1'b0) begin svalid_counter <= 32'd0; end
        else if(svalid_inc == 1'b1) begin svalid_counter <= svalid_counter + 32'd1; end
    end

    always_ff @(posedge clock) begin
        if(reset_n == 1'b0) begin slast_counter <= 32'd0; end
        else if(slast_inc == 1'b1) begin slast_counter <= slast_counter + 32'd1; end
    end

    always_ff @(posedge clock) begin
        mvalid_cnt <= mvalid_counter;
        mlast_cnt  <= mlast_counter;
        svalid_cnt <= svalid_counter;
        slast_cnt  <= slast_counter;
    end

endmodule

`timescale 1ns / 1ps

module AD_DB_BRAM #(
    parameter  int unsigned DATA_WIDTH = 64,
    parameter  int unsigned MEM_DEPTH  = 1024,
    localparam int unsigned ADDR_WIDTH = $clog2(MEM_DEPTH),
    parameter  int unsigned OUT_REG_EN = 0,
    parameter  int unsigned SYNTH = 1
) (
    input  logic                     clk_a,
    input  logic                     rst_a,
    input  logic                     en_a,
    input  logic                     we_a,
    input  logic [ADDR_WIDTH-1:0]    addr_a,
    input  logic [DATA_WIDTH-1:0]    din_a,
    output logic [DATA_WIDTH-1:0]    dout_a,

    input  logic                     clk_b,
    input  logic                     rst_b,
    input  logic                     en_b,
    input  logic                     we_b,
    input  logic [ADDR_WIDTH-1:0]    addr_b,
    input  logic [DATA_WIDTH-1:0]    din_b,
    output logic [DATA_WIDTH-1:0]    dout_b
);

    (* ram_style = "block" *)
    logic [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];

    logic [DATA_WIDTH-1:0] dout_a_r, dout_b_r;
    logic [DATA_WIDTH-1:0] dout_a_r2, dout_b_r2;

    generate
        if(SYNTH == 1) begin
            always_ff @(posedge clk_a) begin
                if (en_a) begin
                    if (we_a) begin
                        mem[addr_a] <= din_a;
                        dout_a_r    <= din_a;
                    end else begin
                        dout_a_r    <= mem[addr_a];
                    end
                end
            end

            always_ff @(posedge clk_b) begin
                if (en_b) begin
                    if (we_b) begin
                        mem[addr_b] <= din_b;
                        dout_b_r    <= din_b;     
                    end else begin
                        dout_b_r    <= mem[addr_b];
                    end
                end
            end
        end
        else begin
            always_ff @(posedge clk_a) begin
                if (en_a) begin
                    if (we_a) begin
                        mem[addr_a] <= din_a;
                        dout_a_r    <= din_a;
                    end else begin
                        dout_a_r    <= mem[addr_a];
                    end
                end
                if (en_b) begin
                    if (we_b) begin
                        mem[addr_b] <= din_b;
                        dout_b_r    <= din_b;     
                    end else begin
                        dout_b_r    <= mem[addr_b];
                    end
                end
            end
        end
    endgenerate

    

    generate
        if (OUT_REG_EN != 0) begin : gen_out_reg
            always @(posedge clk_a) begin
                if (rst_a)
                    dout_a_r2 <= {DATA_WIDTH{1'b0}};
                else if (en_a)
                    dout_a_r2 <= dout_a_r;
            end

            always @(posedge clk_b) begin
                if (rst_b)
                    dout_b_r2 <= {DATA_WIDTH{1'b0}};
                else if (en_b)
                    dout_b_r2 <= dout_b_r;
            end

            assign dout_a = dout_a_r2;
            assign dout_b = dout_b_r2;
        end else begin : gen_no_out_reg
            assign dout_a = dout_a_r;
            assign dout_b = dout_b_r;
        end
    endgenerate

endmodule

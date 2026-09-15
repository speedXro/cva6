`timescale 1 ns / 1 ps

module idwt_cdf53_stage_2(
    input  logic        clk,
    input  logic        reset_n,

    output logic        in_ready,
    input  logic        in_valid,
    input  logic        in_last,
    input  logic [16:0] in_stage_1_r_17_even [0:7],
    input  logic [17:0] in_stage_1_r_18_odd  [0:7],

    output logic        out_valid,
    output logic        out_last,
    output logic [ 7:0] out_values [0:15],
    input  logic        out_ready
);

    logic        valid_reg;
    logic        last_reg;
    logic [ 7:0] values     [0:15];

    //functions
    function automatic logic signed [7:0] clamp_i8_in_17b (input logic signed [16:0] in);
        logic signed [16:0] aux;
        begin
            if(in > 127) begin aux = 17'd127; end
            else if(in < -128) begin aux = -128; end
            else aux = in;

            clamp_i8_in_17b = aux[7:0];
        end
    endfunction

    function automatic logic signed [7:0] clamp_i8_in_18b (input logic signed [17:0] in);
        logic signed [17:0] aux;
        begin
            if(in > 127) begin aux = 18'd127; end
            else if(in < -128) begin aux = -128; end
            else aux = in;

            clamp_i8_in_18b = aux[7:0];
        end
    endfunction



    integer i;

    always_ff @(posedge clk or negedge reset_n) begin
        if(reset_n == 1'b0) begin
            valid_reg <= 1'b0;
            last_reg  <= 1'b0;
        end
        else begin
            if (out_ready) begin
                valid_reg <= in_valid & in_ready;
                if (in_valid & in_ready) begin
                    //data_reg <= ~in_data;   
                    for(i=0;i<8;++i) begin
                        values[2*i]     <= clamp_i8_in_17b(in_stage_1_r_17_even[i]);
                        values[(2*i)+1] <= clamp_i8_in_18b(in_stage_1_r_18_odd[i]);
                    end
                    last_reg <=  in_last;
                end
            end else if (!valid_reg) begin
                if (in_valid) begin
                    valid_reg <= 1'b1;
                    //data_reg  <= ~in_data;
                    for(i=0;i<8;++i) begin
                        values[2*i]     <= clamp_i8_in_17b(in_stage_1_r_17_even[i]);
                        values[(2*i)+1] <= clamp_i8_in_18b(in_stage_1_r_18_odd[i]);
                    end
                    last_reg  <=  in_last;
                end
            end
        end
    end

    assign in_ready             = !valid_reg | out_ready;
    //assign out_values  = data_reg;
    assign out_values             = values;
    
    assign out_last             = last_reg;
    assign out_valid            = valid_reg;

endmodule


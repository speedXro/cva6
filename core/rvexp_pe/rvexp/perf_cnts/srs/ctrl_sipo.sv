`timescale 1ns / 1 ps

module ctrl_sipo #(
    parameter NO_OF_REGS = 10,
    parameter WIDTH = 8
)(
    input  logic                   clock,
    input  logic                   reset_n,

    //Controller Interface
    input  logic                   serial_input_valid,
    input  logic                   serial_input_last,
    input  logic [WIDTH-1:0]       serial_input_data,
    output logic                   serial_input_ready,

    output logic                   parallel_datas_out_commit,
    output logic [WIDTH-1:0]       parallel_datas_out [0:NO_OF_REGS-1],

    //SRS Interface
    output logic [NO_OF_REGS-1:0]  shift_ins,
    output logic [WIDTH-1:0]       data_in,

    output logic [NO_OF_REGS-1:0]  pl_ins,
    output logic [WIDTH-1:0]       pl_in_datas [0:NO_OF_REGS-1],

    input  logic [WIDTH-1:0]       data_out,

    input  logic [WIDTH-1:0]       datas_out [0:NO_OF_REGS-1]
);

    localparam CNT_WIDTH = $clog2(NO_OF_REGS);

    logic [CNT_WIDTH-1:0] cnt;

    genvar i;

    assign pl_ins = '0;
    assign pl_in_datas = '{default: '0};

    always_ff @(posedge clock or negedge reset_n) begin
        if(reset_n == 1'b0) begin
            parallel_datas_out_commit <= 1'b0;
            cnt       <= '0;
            shift_ins <= '0;
            data_in   <= '0;
            serial_input_ready <= 1'b1;
        end
        else if(serial_input_valid == 1'b1 && serial_input_last == 1'b0 && cnt < (NO_OF_REGS - 1)) begin
            shift_ins <= {NO_OF_REGS{1'b1}};
            data_in   <= serial_input_data;
            cnt       <= cnt + 1;
        end
        else if(serial_input_valid == 1'b1 && /*serial_input_last == 1'b1 &&*/ cnt == (NO_OF_REGS -1)) begin
            parallel_datas_out_commit <= 1'b0;
            shift_ins <= {NO_OF_REGS{1'b1}};
            data_in   <= serial_input_data;
            cnt       <= cnt + 1;
            //serial_input_ready <= 1'b0;
        end
        else if(cnt == (NO_OF_REGS)) begin
            parallel_datas_out_commit <= 1'b1;
            shift_ins <= {NO_OF_REGS{1'b0}};
            data_in   <= '0; //comment for synthesis
            cnt       <= '0;
            serial_input_ready <= 1'b0;
        end
        else if(serial_input_valid == 1'b0) begin
            parallel_datas_out_commit <= 1'b0;
            shift_ins <= {NO_OF_REGS{1'b0}};
            data_in   <= '0; //comment for synthesis
            serial_input_ready <= 1'b1;
        end
    end

    generate
        for(i=0;i<NO_OF_REGS;++i) begin
            assign parallel_datas_out[i] = datas_out[NO_OF_REGS-i-1];
        end
    endgenerate

endmodule

`timescale 1 ns / 1 ps 

module fi_dwt_hdl(
    input             clk,
    input             reset,
    
    input             instr_commit,

    input      [ 6:0] instr_funct7,
    input      [ 2:0] instr_funct3,
    input      [ 6:0] instr_opcode,
    input      [63:0] instr_rs1_val,
    input      [63:0] instr_rs2_val,
    
    output reg        result_we,
    output reg [63:0] result_rd,
    
    output            result_mem_en,
    output     [63:0] result_mem_adr,
    output     [63:0] result_mem_dat
);

    localparam OPCODE = 7'b1111011; //0x7B
    
    //CDF 5/3
    localparam FUNCT7_FDWT_CDF_5_3_EXC   = 7'b1000011;    //0x43
    localparam FUNCT3_FDWT_CDF_5_3_EXC   = 3'b011;        //0x3

    localparam FUNCT7_FDWT_CDF_5_3_GET     = 7'b1000011;  //0x43
    localparam FUNCT3_FDWT_CDF_5_3_GET_L03 = 3'b100;      //0x4
    localparam FUNCT3_FDWT_CDF_5_3_GET_L47 = 3'b101;      //0x5
    localparam FUNCT3_FDWT_CDF_5_3_GET_H03 = 3'b110;      //0x6
    localparam FUNCT3_FDWT_CDF_5_3_GET_H47 = 3'b111;      //0x7

    
    localparam FUNCT7_IDWT_CDF_5_3_EXC      = 7'b1000100; //0x44
    localparam FUNCT3_IDWT_CDF_5_3_SET_LOW  = 3'b010;     //0x2
    localparam FUNCT3_IDWT_CDF_5_3_SET_HIGH = 3'b011;     //0x3

    localparam FUNCT7_IDWT_CDF_5_3_GET   = 7'b1000100;    //0x44
    localparam FUNCT3_IDWT_CDF_5_3_GET_0 = 3'b100;         //0x4
    localparam FUNCT3_IDWT_CDF_5_3_GET_1 = 3'b101;         //0x5

    // regs and wires for FDWT CDF 5/3
    reg           fdwt_cdf_53_ap_start;
    wire          fdwt_cdf_53_ap_done;
    wire          fdwt_cdf_53_ap_busy;
    wire          fdwt_cdf_53_ap_ready;
    reg  [63:0]   fdwt_cdf_53_op1;
    reg  [63:0]   fdwt_cdf_53_op2;

    wire          fdwt_cdf_53_output_ready;
    wire [63:0]   fdwt_cdf_53_p_low_03;
    wire [63:0]   fdwt_cdf_53_p_low_47;
    wire [63:0]   fdwt_cdf_53_p_high_03;
    wire [63:0]   fdwt_cdf_53_p_high_47;

    reg  [63:0]   result_fdwt_cdf_53_low_03;
    reg  [63:0]   result_fdwt_cdf_53_low_47;
    reg  [63:0]   result_fdwt_cdf_53_high_03;
    reg  [63:0]   result_fdwt_cdf_53_high_47;

    // regs and wires for IDWT CDF 5/3
    reg           idwt_cdf_53_ap_start;
    wire          idwt_cdf_53_ap_done;
    wire          idwt_cdf_53_ap_busy;
    wire          idwt_cdf_53_ap_ready;
    reg  [63:0]   idwt_cdf_53_low_03;
    reg  [63:0]   idwt_cdf_53_low_47;
    reg  [63:0]   idwt_cdf_53_high_03;
    reg  [63:0]   idwt_cdf_53_high_47;

    reg  [63:0]   store_idwt_cdf_53_low_03;
    reg  [63:0]   store_idwt_cdf_53_low_47;

    wire          idwt_cdf_53_output_ready;
    wire [63:0]   idwt_cdf_53_p_out_0;
    wire [63:0]   idwt_cdf_53_p_out_1;

    reg  [63:0]   result_idwt_cdf_53_p_out_0;
    reg  [63:0]   result_idwt_cdf_53_p_out_1;

    //other regs and wires
    reg [3:0] state;

    //FSM
    always @(posedge clk) begin
        if(reset == 1'b1) begin
            //CDF 5/3
            fdwt_cdf_53_ap_start <=  1'b0;
            fdwt_cdf_53_op1      <= 64'd0;
            fdwt_cdf_53_op2      <= 64'd0;

            result_fdwt_cdf_53_low_03 <= 64'd0;
            result_fdwt_cdf_53_low_47 <= 64'd0;

            result_fdwt_cdf_53_high_03 <= 64'd0;
            result_fdwt_cdf_53_high_47 <= 64'd0;

            idwt_cdf_53_ap_start <=  1'b0;
            idwt_cdf_53_low_03   <= 64'd0;
            idwt_cdf_53_low_47   <= 64'd0;
            idwt_cdf_53_high_03  <= 64'd0;
            idwt_cdf_53_high_47  <= 64'd0;

            store_idwt_cdf_53_low_03 <= 64'd0;
            store_idwt_cdf_53_low_47 <= 64'd0;

            result_idwt_cdf_53_p_out_0 <= 64'd0;
            result_idwt_cdf_53_p_out_1 <= 64'd0;

            result_we <=  1'b0;
            result_rd <= 64'd0;

            state <= 4'd0;
        end

        //CDF 53
        //FDWT
        else if(state        == 4'd0 &&
                instr_commit == 1'b1 &&
                instr_opcode == OPCODE && 
                instr_funct7 == FUNCT7_FDWT_CDF_5_3_EXC &&
                instr_funct3 == FUNCT3_FDWT_CDF_5_3_EXC &&
                fdwt_cdf_53_ap_busy == 1'b0) begin
                    state <= 4'd1;
                    fdwt_cdf_53_ap_start <= 1'b1;
                    fdwt_cdf_53_op1      <= instr_rs1_val;
                    fdwt_cdf_53_op2      <= instr_rs2_val;
        end
        else if(state == 4'd1 && fdwt_cdf_53_output_ready == 1'b1) begin
                    state                      <= 4'd15;
                    result_fdwt_cdf_53_low_03  <= fdwt_cdf_53_p_low_03;
                    result_fdwt_cdf_53_low_47  <= fdwt_cdf_53_p_low_47;
                    result_fdwt_cdf_53_high_03 <= fdwt_cdf_53_p_high_03;
                    result_fdwt_cdf_53_high_47 <= fdwt_cdf_53_p_high_47;
                    result_we                  <=  4'd1;
                    result_rd                  <= 64'd1;
                    fdwt_cdf_53_ap_start       <=  1'b0;
                    fdwt_cdf_53_op1            <= 64'd0;
                    fdwt_cdf_53_op2            <= 64'd0;
        end

        else if(state        == 4'd0 &&
                instr_commit == 1'b1 &&
                instr_opcode == OPCODE && 
                instr_funct7 == FUNCT7_FDWT_CDF_5_3_GET &&
                instr_funct3 == FUNCT3_FDWT_CDF_5_3_GET_L03) begin
                    state     <= 4'd15;
                    result_we <= 4'd1;
                    result_rd <= result_fdwt_cdf_53_low_03;
        end
        else if(state        == 4'd0 &&
                instr_commit == 1'b1 &&
                instr_opcode == OPCODE && 
                instr_funct7 == FUNCT7_FDWT_CDF_5_3_GET &&
                instr_funct3 == FUNCT3_FDWT_CDF_5_3_GET_L47) begin
                    state     <= 4'd15;
                    result_we <= 4'd1;
                    result_rd <= result_fdwt_cdf_53_low_47;
        end
        else if(state        == 4'd0 &&
                instr_commit == 1'b1 &&
                instr_opcode == OPCODE && 
                instr_funct7 == FUNCT7_FDWT_CDF_5_3_GET &&
                instr_funct3 == FUNCT3_FDWT_CDF_5_3_GET_H03) begin
                    state     <= 4'd15;
                    result_we <= 4'd1;
                    result_rd <= result_fdwt_cdf_53_high_03;
        end
        else if(state        == 4'd0 &&
                instr_commit == 1'b1 &&
                instr_opcode == OPCODE && 
                instr_funct7 == FUNCT7_FDWT_CDF_5_3_GET &&
                instr_funct3 == FUNCT3_FDWT_CDF_5_3_GET_H47) begin
                    state     <= 4'd15;
                    result_we <= 4'd1;
                    result_rd <= result_fdwt_cdf_53_high_47;
        end

        //IDWT
        else if(state        == 4'd0 &&
                instr_commit == 1'b1 &&
                instr_opcode == OPCODE && 
                instr_funct7 == FUNCT7_IDWT_CDF_5_3_EXC &&
                instr_funct3 == FUNCT3_IDWT_CDF_5_3_SET_LOW &&
                idwt_cdf_53_ap_busy == 1'b0) begin
                    state                    <=  4'd15;
                    result_we                <=  4'd1;
                    result_rd                <= 64'd2;
                    store_idwt_cdf_53_low_03 <= instr_rs1_val;
                    store_idwt_cdf_53_low_47 <= instr_rs2_val;
        end
        else if(state        == 4'd0 &&
                instr_commit == 1'b1 &&
                instr_opcode == OPCODE && 
                instr_funct7 == FUNCT7_IDWT_CDF_5_3_EXC &&
                instr_funct3 == FUNCT3_IDWT_CDF_5_3_SET_HIGH &&
                idwt_cdf_53_ap_busy == 1'b0) begin
                state                <= 4'd2;    
                idwt_cdf_53_ap_start <= 1'b1;
                idwt_cdf_53_low_03   <= store_idwt_cdf_53_low_03;
                idwt_cdf_53_low_47   <= store_idwt_cdf_53_low_47;
                idwt_cdf_53_high_03  <= instr_rs1_val;
                idwt_cdf_53_high_47  <= instr_rs2_val;
        end
        else if(state == 4'd2 && idwt_cdf_53_output_ready == 1'b1 ) begin
                    state                      <= 4'd15;
                    result_idwt_cdf_53_p_out_0 <= idwt_cdf_53_p_out_0;
                    result_idwt_cdf_53_p_out_1 <= idwt_cdf_53_p_out_1;
                    result_we                  <=  4'd1;
                    result_rd                  <= 64'd3;
                    idwt_cdf_53_ap_start       <= 1'b0;
                    idwt_cdf_53_low_03         <= 64'd0;
                    idwt_cdf_53_low_47         <= 64'd0;
                    idwt_cdf_53_high_03        <= 64'd0;
                    idwt_cdf_53_high_47        <= 64'd0;
        end

        else if(state        == 4'd0 &&
                instr_commit == 1'b1 &&
                instr_opcode == OPCODE && 
                instr_funct7 == FUNCT7_IDWT_CDF_5_3_GET &&
                instr_funct3 == FUNCT3_IDWT_CDF_5_3_GET_0) begin
                    state     <= 4'd15;
                    result_we <= 4'd1;
                    result_rd <= result_idwt_cdf_53_p_out_0;
        end
        else if(state        == 4'd0 &&
                instr_commit == 1'b1 &&
                instr_opcode == OPCODE && 
                instr_funct7 == FUNCT7_IDWT_CDF_5_3_GET &&
                instr_funct3 == FUNCT3_IDWT_CDF_5_3_GET_1) begin
                    state     <= 4'd15;
                    result_we <= 4'd1;
                    result_rd <= result_idwt_cdf_53_p_out_1;
        end

        //clear
        else if(state == 4'd15) begin
            state          <=  4'd0;
            result_we      <=  1'b0;
            result_rd      <= 64'd0;
        end
    end
    


    //modules instantiations

    fdwt_cdf_53 fdwt_cdf_53_inst(
        .clk(clk),
        .reset(reset),

        .input_valid(fdwt_cdf_53_ap_start),
        .input_values_1(fdwt_cdf_53_op1),
        .input_values_2(fdwt_cdf_53_op2),

        .fdwt_busy(fdwt_cdf_53_ap_busy),

        .output_ready(fdwt_cdf_53_output_ready),

        .output_values_low_03(fdwt_cdf_53_p_low_03),
        .output_values_low_47(fdwt_cdf_53_p_low_47),
        .output_values_high_03(fdwt_cdf_53_p_high_03),
        .output_values_high_47(fdwt_cdf_53_p_high_47)
    );

    idwt_cdf_53 idwt_cdf_53_inst(
        .clk(clk),
        .reset(reset),

        .input_valid(idwt_cdf_53_ap_start),
        .input_values_low_03(idwt_cdf_53_low_03),
        .input_values_low_47(idwt_cdf_53_low_47),
        .input_values_high_03(idwt_cdf_53_high_03),
        .input_values_high_47(idwt_cdf_53_high_47),

        .idwt_busy(idwt_cdf_53_ap_busy),

        .output_ready(idwt_cdf_53_output_ready),

        .output_values_1(idwt_cdf_53_p_out_0),
        .output_values_2(idwt_cdf_53_p_out_1)
    );

    assign result_mem_en = 1'd0;
    assign result_mem_adr=64'd0;
    assign result_mem_dat=64'd0;

endmodule
`timescale 1ns / 1ps

module rvexp_controller (
    input  logic clock,
    input  logic reset_n,

    //From CV-X-IF Adapter Interface
    input  logic        instr_commit,
    input  logic [ 6:0] instr_funct7,
    input  logic [ 2:0] instr_funct3,
    //input  logic [ 6:0] instr_opcode,
    input  logic [63:0] instr_rs1_val,
    input  logic [63:0] instr_rs2_val,
    
    //To CV-X-IF Adapter Interface
    output logic        result_we,
    output logic [63:0] result_rd,

    input logic [31:0] axis_timers_values [0:7],

    input logic [31:0] mvalid_cnt,
    input logic [31:0] mlast_cnt,
    input logic [31:0] svalid_cnt,
    input logic [31:0] slast_cnt,
	
	//AXI4 Lite Interface
	output logic [31 : 0] m0_axi_awaddr,
	output logic [ 2 : 0] m0_axi_awprot,
	output logic          m0_axi_awvalid,
	input  logic          m0_axi_awready,
	output logic [31 : 0] m0_axi_wdata,
	output logic [ 3 : 0] m0_axi_wstrb,
	output logic          m0_axi_wvalid,
	input  logic          m0_axi_wready,
	input  logic [ 1 : 0] m0_axi_bresp,
	input  logic          m0_axi_bvalid,
	output logic          m0_axi_bready,
	output logic [31 : 0] m0_axi_araddr,
	output logic [ 2 : 0] m0_axi_arprot,
	output logic          m0_axi_arvalid,
	input  logic          m0_axi_arready,
	input  logic [31 : 0] m0_axi_rdata,
	input  logic [ 1 : 0] m0_axi_rresp,
	input  logic          m0_axi_rvalid,
	output logic          m0_axi_rready,
	
	output logic [31 : 0] m1_axi_awaddr,
	output logic [ 2 : 0] m1_axi_awprot,
	output logic          m1_axi_awvalid,
	input  logic          m1_axi_awready,
	output logic [31 : 0] m1_axi_wdata,
	output logic [ 3 : 0] m1_axi_wstrb,
	output logic          m1_axi_wvalid,
	input  logic          m1_axi_wready,
	input  logic [ 1 : 0] m1_axi_bresp,
	input  logic          m1_axi_bvalid,
	output logic          m1_axi_bready,
	output logic [31 : 0] m1_axi_araddr,
	output logic [ 2 : 0] m1_axi_arprot,
	output logic          m1_axi_arvalid,
	input  logic          m1_axi_arready,
	input  logic [31 : 0] m1_axi_rdata,
	input  logic [ 1 : 0] m1_axi_rresp,
	input  logic          m1_axi_rvalid,
	output logic          m1_axi_rready
);

    //localparam int unsigned OPCODE = 7'b1111011; //0x7B

    localparam bit [6:0] F7_GET_AXIS_TMRS  = 7'h60;
    localparam bit [6:0] F7_GET_AXIS_CNTS  = 7'h61;
	
	localparam bit [6:0] F7_DMA_OPERATION  = 7'h70;
	localparam bit [6:0] F3_DMA_SELECTION  = 3'h3;
	localparam bit [6:0] F3_DMA_RESET      = 3'h4;
	localparam bit [6:0] F3_DMA_INIT       = 3'h5;
	localparam bit [6:0] F3_DMA_TRANSFER   = 3'h6;
	localparam bit [6:0] F3_DMA_GET_STATUS = 3'h7;
	
	
	localparam bit [31:0] REG_SRC_CTRL      = 32'h00000000;
	localparam bit [31:0] REG_SRC_STS       = 32'h00000004;
	localparam bit [31:0] REG_SRC_ADDR_LSB  = 32'h00000018;
	localparam bit [31:0] REG_SRC_LEN       = 32'h00000028;

	localparam bit [31:0] REG_DST_CTRL      = 32'h00000030;
	localparam bit [31:0] REG_DST_STS       = 32'h00000034;
	localparam bit [31:0] REG_DST_ADDR_LSB  = 32'h00000048;
	localparam bit [31:0] REG_DST_LEN       = 32'h00000058;
	
	localparam bit [31:0] VAL_RESET_MASK = 32'h00000004;
	localparam bit [31:0] VAL_INIT_MASK  = 32'd4097; //32'd1 w/o IRQ 32'd4097 with IRQ Enabled

    logic [ 4:0] state;

    logic        dr;
	
	logic        i_write_enable;
	logic [31:0] i_write_address;
	logic [31:0] i_write_data;
	logic        o_write_finished;
	
	logic        i_read_enable;
	logic [31:0] i_read_address;
	logic        o_read_finished;
	logic [31:0] o_read_data;
	
    logic [31:0] store_SRC_LSB;
	logic [31:0] store_DST_LEN;
	logic [31:0] store_SRC_LEN;
	
	logic [31:0] store_DST_STS;
	
	logic dma_selection;
	
	logic        i0_write_enable;
	logic [31:0] i0_write_address;
	logic [31:0] i0_write_data;
	logic        o0_write_finished;
	
	logic        i0_read_enable;
	logic [31:0] i0_read_address;
	logic        o0_read_finished;
	logic [31:0] o0_read_data;
	
	logic        i1_write_enable;
	logic [31:0] i1_write_address;
	logic [31:0] i1_write_data;
	logic        o1_write_finished;
	
	logic        i1_read_enable;
	logic [31:0] i1_read_address;
	logic        o1_read_finished;
	logic [31:0] o1_read_data;

    always_ff @(posedge clock or negedge reset_n) begin
        if(reset_n == 1'b0) begin
            state 						  <= 5'd0;

            result_we                     <= 1'd0;
            result_rd                     <= 64'd0;

            dr                            <= 1'b0;
			
			i_write_enable                <= 1'b0;
			i_read_enable                 <= 1'b0;
			
			dma_selection                 <= 1'b0;
        end

		//DMA Reset
		else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_DMA_OPERATION && instr_funct3 == F3_DMA_SELECTION) begin
            dma_selection                 <= instr_rs1_val[0];
			
			result_we                     <= 1'b1;
            result_rd                     <= {{63{1'b1}}, instr_rs1_val[0]};
			
			state           		      <= 5'd31;
        end
		
		else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_DMA_OPERATION && instr_funct3 == F3_DMA_RESET) begin
            i_write_enable  <= 1'b1;
			i_write_address <= REG_SRC_CTRL;
			i_write_data    <= VAL_RESET_MASK;
			state           <= 5'd24;
        end
		else if(state == 5'd24 && o_write_finished == 1'b0) begin
			i_write_enable  <= 1'b0;
			state           <= 5'd24;
		end
		else if(state == 5'd24 && o_write_finished == 1'b1) begin
			i_write_enable  <= 1'b0;
			result_we       <= 1'd1;
            result_rd       <= 64'd11;
			state           <= 5'd31;
		end
		
		//DMA Init
		else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_DMA_OPERATION && instr_funct3 == F3_DMA_INIT) begin
            i_write_enable  <= 1'b1;
			i_write_address <= REG_DST_CTRL;
			i_write_data    <= VAL_INIT_MASK;
			state           <= 5'd2;
        end
		else if(state == 5'd2 && o_write_finished == 1'b0) begin
			i_write_enable  <= 1'b0;
			state           <= 5'd2;
		end
		else if(state == 5'd2 && o_write_finished == 1'b1) begin
			i_write_enable  <= 1'b0;
			state           <= 5'd3;
		end
		
		else if(state == 5'd3) begin
			i_read_enable   <= 1'b1;
			i_read_address  <= REG_DST_STS;
			state           <= 5'd4;
		end
		else if(state == 5'd4 && o_read_finished == 1'b0) begin
			i_read_enable   <= 1'b0;
			state           <= 5'd4;
		end
		else if(state == 5'd4 && o_read_finished == 1'b1 && o_read_data[0] == 1) begin
			i_read_enable   <= 1'b0;
			state           <= 5'd3;
		end
		else if(state == 5'd4 && o_read_finished == 1'b1 && o_read_data[0] == 0) begin
			i_read_enable   <= 1'b0;
			state           <= 5'd5;
		end
		
		else if(state == 5'd5) begin
			i_write_enable  <= 1'b1;
			i_write_address <= REG_SRC_CTRL;
			i_write_data    <= VAL_INIT_MASK;
			state           <= 5'd6;
		end
		else if(state == 5'd6 && o_write_finished == 1'b0) begin
			i_write_enable  <= 1'b0;
			state           <= 5'd6;
		end
		else if(state == 5'd6 && o_write_finished == 1'b1) begin
			i_write_enable  <= 1'b0;
			state           <= 5'd7;
		end
		
		else if(state == 5'd7) begin
			i_read_enable   <= 1'b1;
			i_read_address  <= REG_SRC_STS;
			state           <= 5'd8;
		end
		else if(state == 5'd8 && o_read_finished == 1'b0) begin
			i_read_enable   <= 1'b0;
			state           <= 5'd8;
		end
		else if(state == 5'd8 && o_read_finished == 1'b1 && o_read_data[0] == 1) begin
			i_read_enable   <= 1'b0;
			state           <= 5'd7;
		end
		else if(state == 5'd8 && o_read_finished == 1'b1 && o_read_data[0] == 0) begin
			i_read_enable   <= 1'b0;
			state           <= 5'd9;
		end
		
		else if(state == 5'd9) begin
			result_we       <= 1'd1;
            result_rd       <= 64'd22;
			state           <= 5'd31;
		end
		
		//DMA Transfer
		else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_DMA_OPERATION && instr_funct3 == F3_DMA_TRANSFER) begin
            i_write_enable  <= 1'b1;
			i_write_address <= REG_DST_ADDR_LSB;
			i_write_data    <= instr_rs1_val[63:32];
			store_DST_LEN   <= instr_rs1_val[31: 0];
			store_SRC_LSB   <= instr_rs2_val[63:32];
			store_SRC_LEN   <= instr_rs2_val[31: 0];
			state           <= 5'd10;
        end
		else if(state == 5'd10 && o_write_finished == 1'b0) begin
			i_write_enable  <= 1'b0;
			state           <= 5'd10;
		end
		else if(state == 5'd10 && o_write_finished == 1'b1) begin
			i_write_enable  <= 1'b0;
			state           <= 5'd11;
		end
		
		else if(state == 5'd11) begin
			i_write_enable  <= 1'b1;
			i_write_address <= REG_SRC_ADDR_LSB;
			i_write_data    <= store_SRC_LSB;
			state           <= 5'd12;
		end
		else if(state == 5'd12 && o_write_finished == 1'b0) begin
			i_write_enable  <= 1'b0;
			state           <= 5'd12;
		end
		else if(state == 5'd12 && o_write_finished == 1'b1) begin
			i_write_enable  <= 1'b0;
			state           <= 5'd13;
		end
		
		else if(state == 5'd13) begin
			i_write_enable  <= 1'b1;
			i_write_address <= REG_DST_LEN;
			i_write_data    <= store_DST_LEN;
			state           <= 5'd14;
		end
		else if(state == 5'd14 && o_write_finished == 1'b0) begin
			i_write_enable  <= 1'b0;
			state           <= 5'd14;
		end
		else if(state == 5'd14 && o_write_finished == 1'b1) begin
			i_write_enable  <= 1'b0;
			state           <= 5'd15;
		end
		
		else if(state == 5'd15) begin
			i_write_enable  <= 1'b1;
			i_write_address <= REG_SRC_LEN;
			i_write_data    <= store_SRC_LEN;
			state           <= 5'd16;
		end
		else if(state == 5'd16 && o_write_finished == 1'b0) begin
			i_write_enable  <= 1'b0;
			state           <= 5'd16;
		end
		else if(state == 5'd16 && o_write_finished == 1'b1) begin
			i_write_enable  <= 1'b0;
			state           <= 5'd17;
		end
		
		/*else if(state == 5'd17) begin
			result_we       <= 1'd1;
            result_rd       <= 64'd33;
			state           <= 5'd31;
		end*/

		else if(state == 5'd17) begin
			i_read_enable   <= 1'b1;
			i_read_address  <= REG_SRC_STS;
			state           <= 5'd18;
 		end
		else if(state == 5'd18 && o_read_finished == 1'b0) begin
			i_read_enable   <= 1'b0;
			state           <= 5'd18;
		end
		else if(state == 5'd18 && o_read_finished == 1'b1 && o_read_data[1] == 1'b0) begin
			i_read_enable   <= 1'b0;
			state           <= 5'd17;
		end
		else if(state == 5'd18 && o_read_finished == 1'b1 && o_read_data[1] == 1'b1) begin
			i_read_enable   <= 1'b0;
			state           <= 5'd19;
		end

		else if(state == 5'd19) begin
			i_read_enable   <= 1'b1;
			i_read_address  <= REG_DST_STS;
			state           <= 5'd20;
 		end
		else if(state == 5'd20 && o_read_finished == 1'b0) begin
			i_read_enable   <= 1'b0;
			state           <= 5'd20;
		end
		else if(state == 5'd20 && o_read_finished == 1'b1 && o_read_data[1] == 1'b0) begin
			i_read_enable   <= 1'b0;
			state           <= 5'd19;
		end
		else if(state == 5'd20 && o_read_finished == 1'b1 && o_read_data[1] == 1'b1) begin
			i_read_enable   <= 1'b0;
			result_we       <= 1'd1;
            result_rd       <= 64'd33;
			state           <= 5'd31;
		end
 
		
		//DMA Get Status
		else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_DMA_OPERATION && instr_funct3 == F3_DMA_GET_STATUS) begin
            i_read_enable   <= 1'b1;
			i_read_address  <= REG_DST_STS;
			state           <= 5'd21;
        end
		else if(state == 5'd21 && o_read_finished == 1'b0) begin
			i_read_enable   <= 1'b0;
			state           <= 5'd21;
		end
		else if(state == 5'd21 && o_read_finished == 1'b1) begin
			i_read_enable   <= 1'b0;
			store_DST_STS   <= o_read_data;
			state           <= 5'd22;
		end
		
		else if(state == 5'd22) begin
			i_read_enable   <= 1'b1;
			i_read_address  <= REG_SRC_STS;
			state           <= 5'd23;
		end
		else if(state == 5'd23 && o_read_finished == 1'b0) begin
			i_read_enable   <= 1'b0;
			state           <= 5'd23;
		end
		else if(state == 5'd23 && o_read_finished == 1'b1) begin
			i_read_enable   <= 1'b0;
			result_we 		<= 1'd1;
            result_rd 		<= {store_DST_STS, o_read_data};
			state           <= 5'd31;
		end
        
		//Get Perf Timers
        else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_GET_AXIS_TMRS) begin
            result_we <= 1'd1;
            casez(instr_funct3)
                3'h0: begin result_rd <= {32'd0, axis_timers_values[0]}; end
                3'h1: begin result_rd <= {32'd0, axis_timers_values[1]}; end
                3'h2: begin result_rd <= {32'd0, axis_timers_values[2]}; end
                3'h3: begin result_rd <= {32'd0, axis_timers_values[3]}; end
                3'h4: begin result_rd <= {32'd0, axis_timers_values[4]}; end
                3'h5: begin result_rd <= {32'd0, axis_timers_values[5]}; end
                3'h6: begin result_rd <= {32'd0, axis_timers_values[6]}; end
                3'h7: begin result_rd <= {32'd0, axis_timers_values[7]}; end
                default: begin dr <= ~dr; end
            endcase
            state     <= 5'd31;
        end

		//Get Perf Counters
        else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_GET_AXIS_CNTS) begin
            result_we <= 1'd1;
            casez(instr_funct3)
                3'h0: begin result_rd <= {mlast_cnt, mvalid_cnt}; end
                3'h1: begin result_rd <= {svalid_cnt, slast_cnt}; end
                default: begin dr <= ~dr; end
            endcase
            state     <= 5'd31;
        end
    

        //Clear Outputs
        else if(state == 5'd31) begin
            state                         <= 5'd0;

            result_we                     <= 1'd0;
            result_rd                     <= 64'd0;
        end
    end
	
	assign i0_write_enable = dma_selection == 0 ? i_write_enable : 1'b0;
	assign i1_write_enable = dma_selection == 1 ? i_write_enable : 1'b0;
	
	assign i0_write_address = dma_selection == 0 ? i_write_address : '0;
	assign i1_write_address = dma_selection == 1 ? i_write_address : '0;
	
	assign i0_write_data = dma_selection == 0 ? i_write_data : '0;
	assign i1_write_data = dma_selection == 1 ? i_write_data : '0;
	
	assign i0_read_enable = dma_selection == 0 ? i_read_enable : 1'b0;
	assign i1_read_enable = dma_selection == 1 ? i_read_enable : 1'b0;
	
	assign i0_read_address = dma_selection == 0 ? i_read_address : '0;
	assign i1_read_address = dma_selection == 1 ? i_read_address : '0;
	
	assign o_write_finished = dma_selection == 0 ? o0_write_finished : o1_write_finished;
	assign o_read_finished = dma_selection == 0 ? o0_read_finished : o1_read_finished;
	assign o_read_data = dma_selection == 0 ? o0_read_data : o1_read_data;
	
	axi4_lite_controller i_axi4_lite_controller_0(
		.clock(clock),
		.reset_n(reset_n),
		
		.i_write_enable(i0_write_enable),
		.i_write_address(i0_write_address),
		.i_write_data(i0_write_data),
		.o_write_finished(o0_write_finished),
		
		.i_read_enable(i0_read_enable),
		.i_read_address(i0_read_address),
		.o_read_finished(o0_read_finished),
		.o_read_data(o0_read_data),
		
		.m_axi_awaddr(m0_axi_awaddr),
		.m_axi_awprot(m0_axi_awprot),
		.m_axi_awvalid(m0_axi_awvalid),
		.m_axi_awready(m0_axi_awready),
		.m_axi_wdata(m0_axi_wdata),
		.m_axi_wstrb(m0_axi_wstrb),
		.m_axi_wvalid(m0_axi_wvalid),
		.m_axi_wready(m0_axi_wready),
		.m_axi_bresp(m0_axi_bresp),
		.m_axi_bvalid(m0_axi_bvalid),
		.m_axi_bready(m0_axi_bready),
		.m_axi_araddr(m0_axi_araddr),
		.m_axi_arprot(m0_axi_arprot),
		.m_axi_arvalid(m0_axi_arvalid),
		.m_axi_arready(m0_axi_arready),
		.m_axi_rdata(m0_axi_rdata),
		.m_axi_rresp(m0_axi_rresp),
		.m_axi_rvalid(m0_axi_rvalid),
		.m_axi_rready(m0_axi_rready)
	);
	
	axi4_lite_controller i_axi4_lite_controller_1(
		.clock(clock),
		.reset_n(reset_n),
		
		.i_write_enable(i1_write_enable),
		.i_write_address(i1_write_address),
		.i_write_data(i1_write_data),
		.o_write_finished(o1_write_finished),
		
		.i_read_enable(i1_read_enable),
		.i_read_address(i1_read_address),
		.o_read_finished(o1_read_finished),
		.o_read_data(o1_read_data),
		
		.m_axi_awaddr(m1_axi_awaddr),
		.m_axi_awprot(m1_axi_awprot),
		.m_axi_awvalid(m1_axi_awvalid),
		.m_axi_awready(m1_axi_awready),
		.m_axi_wdata(m1_axi_wdata),
		.m_axi_wstrb(m1_axi_wstrb),
		.m_axi_wvalid(m1_axi_wvalid),
		.m_axi_wready(m1_axi_wready),
		.m_axi_bresp(m1_axi_bresp),
		.m_axi_bvalid(m1_axi_bvalid),
		.m_axi_bready(m1_axi_bready),
		.m_axi_araddr(m1_axi_araddr),
		.m_axi_arprot(m1_axi_arprot),
		.m_axi_arvalid(m1_axi_arvalid),
		.m_axi_arready(m1_axi_arready),
		.m_axi_rdata(m1_axi_rdata),
		.m_axi_rresp(m1_axi_rresp),
		.m_axi_rvalid(m1_axi_rvalid),
		.m_axi_rready(m1_axi_rready)
	);

endmodule

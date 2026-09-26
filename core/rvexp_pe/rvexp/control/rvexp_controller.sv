`timescale 1ns / 1ps

module rvexp_controller #(
	parameter   int unsigned AD_DATA_WIDTH  = 64,
    parameter   int unsigned AD_MEM_DEPTH   = 1024,
	localparam  int unsigned AD_ADDR_WIDTH  = $clog2(AD_MEM_DEPTH),

    parameter   int unsigned UA_DATA_WIDTH  = 64,
    parameter   int unsigned UA_MEM_DEPTH   = 1024,
	localparam  int unsigned UA_ADDR_WIDTH  = $clog2(UA_MEM_DEPTH),

	parameter   int unsigned DA_DATA_WIDTH  = 64,
    parameter   int unsigned DA_MEM_DEPTH   = 1024,
	localparam  int unsigned DA_ADDR_WIDTH  = $clog2(DA_MEM_DEPTH)
)(
    input  logic clock,
    input  logic reset_n,

    input  logic        instr_commit,
    input  logic [ 6:0] instr_funct7,
    input  logic [ 2:0] instr_funct3,
    input  logic [63:0] instr_rs1_val,
    input  logic [63:0] instr_rs2_val,
    
    output logic        result_we,
    output logic [63:0] result_rd,

    output logic          qm_we,
    output logic [  7:0]  qm [0:63],

    input  logic [31:0] axis_timers_values [0:7],

    input  logic [31:0] mvalid_cnt,
    input  logic [31:0] mlast_cnt,
    input  logic [31:0] svalid_cnt,
    input  logic [31:0] slast_cnt,

	output logic [1:0]              stft_cfg_window_sel,
	output logic                    stft_cfg_enable,
	output logic [1:0]              stft_cfg_out_fmt,
	output logic [1:0]              stft_cfg_pix_floor,
	output logic                    stft_start_pulse,
	output logic                    stft_soft_reset,
	output logic                    stft_stat_read_ack,

	input  logic                    stft_ctrl_busy,
	input  logic                    stft_frame_done,     // sticky; cleared by stat_read_ack
	input  logic                    stft_frame_full,
	input  logic [7:0]              stft_frame_count,

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
	output logic          m1_axi_rready,

	output logic [31 : 0] m2_axi_awaddr,
	output logic [ 2 : 0] m2_axi_awprot,
	output logic          m2_axi_awvalid,
	input  logic          m2_axi_awready,
	output logic [31 : 0] m2_axi_wdata,
	output logic [ 3 : 0] m2_axi_wstrb,
	output logic          m2_axi_wvalid,
	input  logic          m2_axi_wready,
	input  logic [ 1 : 0] m2_axi_bresp,
	input  logic          m2_axi_bvalid,
	output logic          m2_axi_bready,
	output logic [31 : 0] m2_axi_araddr,
	output logic [ 2 : 0] m2_axi_arprot,
	output logic          m2_axi_arvalid,
	input  logic          m2_axi_arready,
	input  logic [31 : 0] m2_axi_rdata,
	input  logic [ 1 : 0] m2_axi_rresp,
	input  logic          m2_axi_rvalid,
	output logic          m2_axi_rready,
	
	output logic [31 : 0] m3_axi_awaddr,
	output logic [ 2 : 0] m3_axi_awprot,
	output logic          m3_axi_awvalid,
	input  logic          m3_axi_awready,
	output logic [31 : 0] m3_axi_wdata,
	output logic [ 3 : 0] m3_axi_wstrb,
	output logic          m3_axi_wvalid,
	input  logic          m3_axi_wready,
	input  logic [ 1 : 0] m3_axi_bresp,
	input  logic          m3_axi_bvalid,
	output logic          m3_axi_bready,
	output logic [31 : 0] m3_axi_araddr,
	output logic [ 2 : 0] m3_axi_arprot,
	output logic          m3_axi_arvalid,
	input  logic          m3_axi_arready,
	input  logic [31 : 0] m3_axi_rdata,
	input  logic [ 1 : 0] m3_axi_rresp,
	input  logic          m3_axi_rvalid,
	output logic          m3_axi_rready,

	output logic                       	ad_en_b,
    output logic                       	ad_we_b,
    output logic [AD_ADDR_WIDTH-1:0]   	ad_addr_b,
    output logic [AD_DATA_WIDTH-1:0]   	ad_din_b,
    input  logic [AD_DATA_WIDTH-1:0]   	ad_dout_b,

	output logic                       	ua_en_b,
    output logic                       	ua_we_b,
    output logic [UA_ADDR_WIDTH-1:0]   	ua_addr_b,
    output logic [UA_DATA_WIDTH-1:0]   	ua_din_b,
    input  logic [UA_DATA_WIDTH-1:0]   	ua_dout_b,

	output logic                       	da_en_b,
    output logic                       	da_we_b,
    output logic [DA_ADDR_WIDTH-1:0]   	da_addr_b,
    output logic [DA_DATA_WIDTH-1:0]   	da_din_b,
    input  logic [DA_DATA_WIDTH-1:0]   	da_dout_b,

	output logic          				ad_aq_enable,
    output logic          				ad_aq_clear,
    input  logic          				ad_aq_full,
	input  logic  [AD_ADDR_WIDTH:0]     ad_wr_cnt_out,
	output logic  [AD_ADDR_WIDTH:0]     ad_lim,

	output logic                        ua_start,
    output logic                        ua_clear,
    input  logic                        ua_empty,
	input  logic  [UA_ADDR_WIDTH:0]     ua_rd_cnt_out,
	output logic  [UA_ADDR_WIDTH:0]     ua_lim,

	output logic                        da_start,
    output logic                        da_clear,
    input  logic                        da_empty,
	input  logic  [DA_ADDR_WIDTH:0]     da_rd_cnt_out,
	output logic  [DA_ADDR_WIDTH:0]     da_lim,

	input  logic                        ur_stop,
	input  logic                        ur_ready,
	output logic                        ur_clear_stop,
	output logic                        ur_clear_ready,
	input  logic  [7:0]                 ur_qf,
	input  logic  [1:0]                 ur_pf,
	input  logic                        ur_ws,

	output logic                        cvxif_busy
);
    localparam bit [6:0] F7_SET_QM_WORD_0  = 7'h40;
    localparam bit [6:0] F7_GET_QM_WORD_0  = 7'h50;

    localparam bit [6:0] F7_GET_AXIS_TMRS  = 7'h60;
    localparam bit [6:0] F7_GET_AXIS_CNTS  = 7'h61;

	localparam bit [6:0] F7_PRAM_OPERATION  = 7'h68;
	localparam bit [2:0] F3_SELECT_PRAM     = 3'h5;
	localparam bit [2:0] F3_WRITE_PRAM      = 3'h6;
	localparam bit [2:0] F3_READ_PRAM       = 3'h7;

	localparam bit [6:0] F7_AD_OPERATION   = 7'h69;
	localparam bit [2:0] F3_AD_START       = 3'h1;
	localparam bit [2:0] F3_AD_CLEAR       = 3'h2;
	localparam bit [2:0] F3_AD_GET_STATS   = 3'h4;
	localparam bit [2:0] F3_AD_GET_WR_CNT  = 3'h5;
	localparam bit [2:0] F3_AD_SET_LIM     = 3'h7;

	localparam bit [6:0] F7_UA_OPERATION   = 7'h6A;
	localparam bit [2:0] F3_UA_START       = 3'h1;
	localparam bit [2:0] F3_UA_CLEAR       = 3'h2;
	localparam bit [2:0] F3_UA_GET_STATS   = 3'h4;
	localparam bit [2:0] F3_UA_GET_RD_CNT  = 3'h6;
	localparam bit [2:0] F3_UA_SET_LIM     = 3'h7;

	localparam bit [6:0] F7_DA_OPERATION   = 7'h6B;
	localparam bit [2:0] F3_DA_START       = 3'h1;
	localparam bit [2:0] F3_DA_CLEAR       = 3'h2;
	localparam bit [2:0] F3_DA_GET_STATS   = 3'h4;
	localparam bit [2:0] F3_DA_GET_RD_CNT  = 3'h6;
	localparam bit [2:0] F3_DA_SET_LIM     = 3'h7;

	localparam bit [6:0] F7_UR_OPERATION   = 7'h6C;
	localparam bit [2:0] F3_UR_GET_STOP    = 3'h1;
	localparam bit [2:0] F3_UR_GET_READY   = 3'h2;
	localparam bit [2:0] F3_UR_CLR_STOP    = 3'h3;
	localparam bit [2:0] F3_UR_CLR_READY   = 3'h4;
	localparam bit [2:0] F3_UR_GET_QFACT   = 3'h5;
	localparam bit [2:0] F3_UR_GET_PIXFLR  = 3'h6;
	localparam bit [2:0] F3_UR_GET_WSEL    = 3'h7;


	localparam bit [6:0] F7_DMA_OPERATION  = 7'h70;
	localparam bit [6:0] F3_DMA_SELECTION  = 3'h3;
	localparam bit [6:0] F3_DMA_RESET      = 3'h4;
	localparam bit [6:0] F3_DMA_INIT       = 3'h5;
	localparam bit [6:0] F3_DMA_TRANSFER   = 3'h6;
	localparam bit [6:0] F3_DMA_GET_STATUS = 3'h7;

	localparam bit [6:0] F7_STFT_OPERATION  = 7'h78;
	localparam bit [2:0] F3_STFT_CFG        = 3'h4;
	localparam bit [2:0] F3_STFT_START      = 3'h5;
	localparam bit [2:0] F3_STFT_STATUS     = 3'h6;
	localparam bit [2:0] F3_STFT_RESET      = 3'h7;

	localparam bit [6:0] F7_ERR_HANDLING    = 7'h7F;
	localparam bit [2:0] F3_GET_ERR_DATA    = 3'h7;

	localparam CFG_WSEL_LO = 0;
	localparam CFG_WSEL_HI = 1;
	localparam CFG_ENABLE  = 2;
	localparam CFG_OFMT_LO = 3;
	localparam CFG_OFMT_HI = 4;
	localparam CFG_PXFL_LO = 5;
	localparam CFG_PXFL_HI = 6;
	
	
	localparam bit [31:0] REG_SRC_CTRL      = 32'h00000000;
	localparam bit [31:0] REG_SRC_STS       = 32'h00000004;
	localparam bit [31:0] REG_SRC_ADDR_LSB  = 32'h00000018;
	localparam bit [31:0] REG_SRC_LEN       = 32'h00000028;

	localparam bit [31:0] REG_DST_CTRL      = 32'h00000030;
	localparam bit [31:0] REG_DST_STS       = 32'h00000034;
	localparam bit [31:0] REG_DST_ADDR_LSB  = 32'h00000048;
	localparam bit [31:0] REG_DST_LEN       = 32'h00000058;
	
	localparam bit [31:0] VAL_RESET_MASK = 32'h00000004;
	localparam bit [31:0] VAL_INIT_MASK  = 32'd1; //32'd4097; //32'd1 w/o IRQ 32'd4097 with IRQ Enabled

	localparam  int unsigned TIMEOUT_CNT_LIMIT = 28'd100000000;

	localparam  int unsigned ERROR_SUCCES      = 8'h00;
	localparam  int unsigned ERROR_TIMEOUT     = 8'h01;
	localparam  int unsigned ERROR_COMMIT_KILL = 8'h02;

    logic [ 4:0] state;

    logic        dr;
    
    logic [ 511:0] qm_hold;
    logic [2047:0] rm_hold;

    logic [ 511:0]  qm_chunk;
    //logic [2047:0]  rm_chunk;
	
	logic        i_write_enable;
	logic [31:0] i_write_address;
	logic [31:0] i_write_data;
	logic        o_write_finished;
	
	logic        i_read_enable;
	logic [31:0] i_read_address;
	logic        o_read_finished;
	logic [31:0] o_read_data;

	logic        ib_write_enable;
	logic [63:0] ib_write_address;
	logic [63:0] ib_write_data;
	logic        ob_write_finished;
	
	logic        ib_read_enable;
	logic [63:0] ib_read_address;
	logic        ob_read_finished;
	logic [63:0] ob_read_data;
	
    logic [31:0] store_SRC_LSB;
	logic [31:0] store_DST_LEN;
	logic [31:0] store_SRC_LEN;
	
	logic [31:0] store_DST_STS;
	
	logic [1:0] dma_selection;
	
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

	logic        i2_write_enable;
	logic [31:0] i2_write_address;
	logic [31:0] i2_write_data;
	logic        o2_write_finished;
	
	logic        i2_read_enable;
	logic [31:0] i2_read_address;
	logic        o2_read_finished;
	logic [31:0] o2_read_data;
	
	logic        i3_write_enable;
	logic [31:0] i3_write_address;
	logic [31:0] i3_write_data;
	logic        o3_write_finished;
	
	logic        i3_read_enable;
	logic [31:0] i3_read_address;
	logic        o3_read_finished;
	logic [31:0] o3_read_data;

	logic [31:0] stft_status_w;

	logic [1:0] pram_selection;

	logic [ 4:0] state_prev;

	logic [27:0] timeout_cnt;
	logic        timeout_cnt_reset;

	logic        timeout_cnt_start;
	logic        timeout_cnt_stop;

	logic        timeout_cnt_full;

	logic [63:0] error_data;
	logic [ 4:0] error_state; 

	assign timeout_cnt_start = ((state_prev == 5'd0) && (state > 5'd0 && state <5'd31));
	assign timeout_cnt_stop  = ((state_prev > 5'd0 && state_prev < 5'd31) && (state == 5'd31)); 

	always_ff @(posedge clock) begin
		if(reset_n == 1'b0) begin state_prev <= 5'd0;  end
		else                begin state_prev <= state; end
	end

	always_ff @(posedge clock) begin
		if(reset_n == 1'b0) begin
			timeout_cnt <= 28'd0;
			timeout_cnt_full <= 1'd0;
		end
		else if(timeout_cnt_reset == 1'b1) begin
			timeout_cnt <= 28'd0;
			timeout_cnt_full <= 1'd0;
			error_state      <= 5'd0;
		end
		else if(timeout_cnt == 28'd0 && timeout_cnt_start == 1'b1) begin
			timeout_cnt <= 28'd1;
		end
		else if(timeout_cnt > 28'd0 && timeout_cnt < TIMEOUT_CNT_LIMIT && timeout_cnt_stop == 1'b0) begin
			timeout_cnt <= timeout_cnt + 28'd1;
		end
		else if(timeout_cnt > 28'd0 && timeout_cnt < TIMEOUT_CNT_LIMIT && timeout_cnt_stop == 1'b1) begin
			timeout_cnt <= 28'd0;
		end
		else if(timeout_cnt == TIMEOUT_CNT_LIMIT) begin
			error_state      <= state;
			timeout_cnt_full <= 1'b1;
		end
	end

    always_ff @(posedge clock or negedge reset_n) begin
		if(reset_n == 1'b0) begin
            state 						  <= 5'd0;

            result_we                     <= 1'd0;
            result_rd                     <= 64'd0;

            qm_we                         <= 1'd0;
            //rm_we                         <= 1'd0;

            dr                            <= 1'b0;
			
			i_write_enable                <= 1'b0;
			i_read_enable                 <= 1'b0;			
			dma_selection                 <= 2'd0;

			ib_write_enable               <= 1'b0;
			ib_read_enable                <= 1'b0;
			pram_selection                <= 2'd0;

			stft_cfg_window_sel           <= 2'd1;
			stft_cfg_enable               <= 1'd0;        
			stft_cfg_out_fmt              <= 2'd0;
			stft_cfg_pix_floor            <= 2'd0;

			stft_start_pulse              <= 1'd0;
			stft_soft_reset               <= 1'd0;
			stft_stat_read_ack            <= 1'd0;

			ad_aq_enable                  <= 1'd0;
			ad_aq_clear                   <= 1'd0;

			ua_start                      <= 1'd0;
			ua_clear                      <= 1'd0;

			timeout_cnt_reset             <= 1'd0;

			error_data                    <= 64'd0;

			ad_lim                        <= AD_MEM_DEPTH;
			ua_lim                        <= UA_MEM_DEPTH;
			da_lim                        <= DA_MEM_DEPTH;

			ur_clear_stop                 <= 1'd0;
			ur_clear_ready                <= 1'd0;
        end

		//DMA Reset
		else if(timeout_cnt_full == 1'b1) begin
			result_we                     <= 1'b1;
			result_rd                     <= {16'h9876, 32'd0, 3'd0, state, 8'h01};
			error_data                    <= {16'h9876, 32'd0, 3'd0, state, 8'h01};

			timeout_cnt_reset             <= 1'b1;

			state           		      <= 5'd31;
		end

		else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_DMA_OPERATION && instr_funct3 == F3_DMA_SELECTION) begin
            dma_selection                 <= instr_rs1_val[1:0];
			
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
		
		//QM Set
        else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_SET_QM_WORD_0) begin
            result_we <= 1'd1;
            result_rd <= 64'd1;
            state     <= 5'd31;
            casez(instr_funct3)
                3'h4: begin qm_hold[511:384] <= {instr_rs1_val, instr_rs2_val}; end
                3'h5: begin qm_hold[383:256] <= {instr_rs1_val, instr_rs2_val}; end
                3'h6: begin qm_hold[255:128] <= {instr_rs1_val, instr_rs2_val}; end
                3'h7: begin qm_hold[127:  0] <= {instr_rs1_val, instr_rs2_val}; qm_we <= 1'b1; qm_chunk <= {qm_hold[511:128], instr_rs1_val, instr_rs2_val}; end
                default: begin dr <= ~dr; end
            endcase
        end
		
		//QM Get
        else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_GET_QM_WORD_0) begin
            result_we <= 1'd1;
            casez(instr_funct3)
                3'h0: begin result_rd <= qm_hold[511:448]; end
                3'h1: begin result_rd <= qm_hold[447:384]; end
                3'h2: begin result_rd <= qm_hold[383:320]; end
                3'h3: begin result_rd <= qm_hold[319:256]; end
                3'h4: begin result_rd <= qm_hold[255:192]; end
                3'h5: begin result_rd <= qm_hold[191:128]; end
                3'h6: begin result_rd <= qm_hold[127: 64]; end
                3'h7: begin result_rd <= qm_hold[ 63:  0]; end
                default: begin dr <= ~dr; end
            endcase
            state     <= 5'd31;
        end

		

		else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_STFT_OPERATION && instr_funct3 == F3_STFT_CFG) begin
			result_we <= 1'd1;
			result_rd <= {25'd0, stft_cfg_pix_floor, stft_cfg_out_fmt, stft_cfg_enable, stft_cfg_window_sel};
			stft_cfg_window_sel <= instr_rs1_val[CFG_WSEL_HI:CFG_WSEL_LO];
			stft_cfg_enable     <= instr_rs1_val[CFG_ENABLE];
			stft_cfg_out_fmt    <= instr_rs1_val[CFG_OFMT_HI:CFG_OFMT_LO];
			stft_cfg_pix_floor  <= instr_rs1_val[CFG_PXFL_HI:CFG_PXFL_LO];
			state     <= 5'd31;
		end
		else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_STFT_OPERATION && instr_funct3 == F3_STFT_START) begin
			result_we <= 1'd1;
			result_rd <= 64'd1;
			stft_start_pulse <= 1'b1;
			state     <= 5'd31;
		end
		else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_STFT_OPERATION && instr_funct3 == F3_STFT_RESET) begin
			result_we <= 1'd1;
			result_rd <= 64'd0;
			stft_soft_reset <= 1'b1;
			state     <= 5'd31;
		end
		else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_STFT_OPERATION && instr_funct3 == F3_STFT_STATUS) begin
			result_we <= 1'd1;
			result_rd <= {32'd0, stft_status_w};
			stft_stat_read_ack <= 1'b1;
			state     <= 5'd31;
		end

		else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_ERR_HANDLING && instr_funct3 == F3_GET_ERR_DATA) begin
			result_we  <= 1'd1;
			result_rd  <= error_data;
			error_data <= 64'd0;
			state      <= 5'd31;
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

		else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_PRAM_OPERATION && instr_funct3 == F3_SELECT_PRAM) begin
			pram_selection <= instr_rs1_val[1:0];
			result_we      <= 1'b1;
			result_rd      <= 64'd1;
			state          <= 5'd31;
		end
    
		else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_PRAM_OPERATION && instr_funct3 == F3_WRITE_PRAM) begin
			ib_write_enable  <= 1'b1;
			ib_write_address <= instr_rs1_val;
			ib_write_data    <= instr_rs2_val;
			state            <= 5'd25; 
		end
		else if(state == 5'd25 && ob_write_finished == 1'b0) begin
			ib_write_enable  <= 1'b0;	
			state            <= 5'd25;
		end
		else if(state == 5'd25 && ob_write_finished == 1'b1) begin
			ib_write_enable  <= 1'b0;	
			result_we     <= 1'b1;
			result_rd     <= 64'd1;
			state         <= 5'd31;
		end

		else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_PRAM_OPERATION && instr_funct3 == F3_READ_PRAM) begin
			ib_read_enable  <= 1'b1;
			ib_read_address <= instr_rs1_val;
			state            <= 5'd26; 
		end
		else if(state == 5'd26 && ob_read_finished == 1'b0) begin
			ib_read_enable  <= 1'b0;	
			state            <= 5'd26;
		end
		else if(state == 5'd26 && ob_read_finished == 1'b1) begin
			ib_read_enable  <= 1'b0;	
			result_we     <= 1'b1;
			result_rd     <= ob_read_data;
			state         <= 5'd31;
		end

		//AD AQ
		else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_AD_OPERATION && instr_funct3 == F3_AD_START) begin
			ad_aq_enable  <= 1'b1;
			result_we     <= 1'b1;
			result_rd     <= 64'd1;
			state         <= 5'd31;
		end
		else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_AD_OPERATION && instr_funct3 == F3_AD_CLEAR) begin
			ad_aq_clear  <= 1'b1;
			result_we     <= 1'b1;
			result_rd     <= 64'd1;
			state         <= 5'd31;
		end
		else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_AD_OPERATION && instr_funct3 == F3_AD_GET_STATS) begin
			result_we     <= 1'b1;
			result_rd     <= {63'd0, ad_aq_full};
			state         <= 5'd31;
		end
		else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_AD_OPERATION && instr_funct3 == F3_AD_GET_WR_CNT) begin
			result_we     <= 1'b1;
			result_rd     <= {{(64-(AD_ADDR_WIDTH+1)){1'b0}}, ad_wr_cnt_out};
			state         <= 5'd31;
		end
		else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_AD_OPERATION && instr_funct3 == F3_AD_SET_LIM) begin
			ad_lim        <= instr_rs1_val[AD_ADDR_WIDTH:0];
			result_we     <= 1'b1;
			result_rd     <= 64'd1;
			state         <= 5'd31;
		end

		//UA
		else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_UA_OPERATION && instr_funct3 == F3_UA_START) begin
			ua_start      <= 1'b1;
			result_we     <= 1'b1;
			result_rd     <= 64'd1;
			state         <= 5'd31;
		end
		else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_UA_OPERATION && instr_funct3 == F3_UA_CLEAR) begin
			ua_clear      <= 1'b1;
			result_we     <= 1'b1;
			result_rd     <= 64'd1;
			state         <= 5'd31;
		end
		else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_UA_OPERATION && instr_funct3 == F3_UA_GET_STATS) begin
			result_we     <= 1'b1;
			result_rd     <= {63'd0, ua_empty};
			state         <= 5'd31;
		end
		else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_UA_OPERATION && instr_funct3 == F3_UA_GET_RD_CNT) begin
			result_we     <= 1'b1;
			result_rd     <= {{(64-(UA_ADDR_WIDTH+1)){1'b0}}, ua_rd_cnt_out};
			state         <= 5'd31;
		end
		else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_UA_OPERATION && instr_funct3 == F3_UA_SET_LIM) begin
			ua_lim        <= instr_rs1_val[UA_ADDR_WIDTH:0];
			result_we     <= 1'b1;
			result_rd     <= 64'd1;
			state         <= 5'd31;
		end

		//DA
		else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_DA_OPERATION && instr_funct3 == F3_DA_START) begin
			da_start      <= 1'b1;
			result_we     <= 1'b1;
			result_rd     <= 64'd1;
			state         <= 5'd31;
		end
		else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_DA_OPERATION && instr_funct3 == F3_DA_CLEAR) begin
			da_clear      <= 1'b1;
			result_we     <= 1'b1;
			result_rd     <= 64'd1;
			state         <= 5'd31;
		end
		else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_DA_OPERATION && instr_funct3 == F3_DA_GET_STATS) begin
			result_we     <= 1'b1;
			result_rd     <= {63'd0, da_empty};
			state         <= 5'd31;
		end
		else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_DA_OPERATION && instr_funct3 == F3_DA_GET_RD_CNT) begin
			result_we     <= 1'b1;
			result_rd     <= {{(64-(DA_ADDR_WIDTH+1)){1'b0}}, da_rd_cnt_out};
			state         <= 5'd31;
		end
		else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_DA_OPERATION && instr_funct3 == F3_DA_SET_LIM) begin
			da_lim        <= instr_rs1_val[DA_ADDR_WIDTH:0];
			result_we     <= 1'b1;
			result_rd     <= 64'd1;
			state         <= 5'd31;
		end

		//UR
		else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_UR_OPERATION && instr_funct3 == F3_UR_GET_STOP) begin
			result_we     <= 1'b1;
			result_rd     <= {63'd0, ur_stop};
			state         <= 5'd31;
		end
		else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_UR_OPERATION && instr_funct3 == F3_UR_GET_READY) begin
			result_we     <= 1'b1;
			result_rd     <= {63'd0, ur_ready};
			state         <= 5'd31;
		end
		else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_UR_OPERATION && instr_funct3 == F3_UR_CLR_STOP) begin
			ur_clear_stop <= 1'b1;
			result_we     <= 1'b1;
			result_rd     <= 64'd1;
			state         <= 5'd31;
		end
		else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_UR_OPERATION && instr_funct3 == F3_UR_CLR_READY) begin
			ur_clear_ready <= 1'b1;
			result_we      <= 1'b1;
			result_rd      <= 64'd1;
			state          <= 5'd31;
		end
		else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_UR_OPERATION && instr_funct3 == F3_UR_GET_QFACT) begin
			result_we     <= 1'b1;
			result_rd     <= {56'd0, ur_qf};
			state         <= 5'd31;
		end
		else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_UR_OPERATION && instr_funct3 == F3_UR_GET_PIXFLR) begin
			result_we     <= 1'b1;
			result_rd     <= {62'd0, ur_pf};
			state         <= 5'd31;
		end
		else if(state == 5'd0 && instr_commit == 1'b1 && instr_funct7 == F7_UR_OPERATION && instr_funct3 == F3_UR_GET_WSEL) begin
			result_we     <= 1'b1;
			result_rd     <= {63'd0, ur_ws};
			state         <= 5'd31;
		end

        //Clear Outputs
        else if(state == 5'd31) begin
            state                         <= 5'd0;

            result_we                     <= 1'd0;
            result_rd                     <= 64'd0;

            qm_we                         <= 1'b0;
            //rm_we                         <= 1'b0;

			stft_start_pulse              <= 1'b0;
			stft_soft_reset 			  <= 1'b0;
			stft_stat_read_ack            <= 1'b0;

			ad_aq_enable                  <= 1'd0;
			ad_aq_clear                   <= 1'd0;

			ua_start                      <= 1'd0;
			ua_clear                      <= 1'd0;

			da_start                      <= 1'd0;
			da_clear                      <= 1'd0;

			timeout_cnt_reset             <= 1'd0;

			ur_clear_stop                 <= 1'd0;
			ur_clear_ready                <= 1'd0;
        end
    end

	assign stft_status_w = {16'b0, stft_frame_count, 5'b0, stft_frame_full, stft_frame_done, stft_ctrl_busy};

    genvar i,j;
    generate
    for (i = 0; i < 64; i++) begin : gen_split_qm
        assign qm[i] = qm_chunk[i*8 +: 8];
        //assign qm[i] = qm_chunk[(63-i)*8 +: 8];
    end
    endgenerate
	
	assign i0_write_enable = dma_selection == 2'd0 ? i_write_enable : 1'b0;
	assign i1_write_enable = dma_selection == 2'd1 ? i_write_enable : 1'b0;
	assign i2_write_enable = dma_selection == 2'd2 ? i_write_enable : 1'b0;
	assign i3_write_enable = dma_selection == 2'd3 ? i_write_enable : 1'b0;
	
	assign i0_write_address = dma_selection == 2'd0 ? i_write_address : '0;
	assign i1_write_address = dma_selection == 2'd1 ? i_write_address : '0;
	assign i2_write_address = dma_selection == 2'd2 ? i_write_address : '0;
	assign i3_write_address = dma_selection == 2'd3 ? i_write_address : '0;
	
	assign i0_write_data = dma_selection == 2'd0 ? i_write_data : '0;
	assign i1_write_data = dma_selection == 2'd1 ? i_write_data : '0;
	assign i2_write_data = dma_selection == 2'd2 ? i_write_data : '0;
	assign i3_write_data = dma_selection == 2'd3 ? i_write_data : '0;
	
	assign i0_read_enable = dma_selection == 2'd0 ? i_read_enable : 1'b0;
	assign i1_read_enable = dma_selection == 2'd1 ? i_read_enable : 1'b0;
	assign i2_read_enable = dma_selection == 2'd2 ? i_read_enable : 1'b0;
	assign i3_read_enable = dma_selection == 2'd3 ? i_read_enable : 1'b0;
	
	assign i0_read_address = dma_selection == 2'd0 ? i_read_address : '0;
	assign i1_read_address = dma_selection == 2'd1 ? i_read_address : '0;
	assign i2_read_address = dma_selection == 2'd2 ? i_read_address : '0;
	assign i3_read_address = dma_selection == 2'd3 ? i_read_address : '0;
	

	assign o_write_finished = (dma_selection == 2'd0) ? o0_write_finished :
                              (dma_selection == 2'd1) ? o1_write_finished :
                              (dma_selection == 2'd2) ? o2_write_finished :
                                                        o3_write_finished;

	assign o_read_finished  = (dma_selection == 2'd0) ? o0_read_finished :
							  (dma_selection == 2'd1) ? o1_read_finished :
							  (dma_selection == 2'd2) ? o2_read_finished :
														o3_read_finished;

	assign o_read_data      = (dma_selection == 2'd0) ? o0_read_data :
							  (dma_selection == 2'd1) ? o1_read_data :
							  (dma_selection == 2'd2) ? o2_read_data :
														o3_read_data;
	
	axi4_lite_controller i0_axi4_lite_controller(
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
	
	axi4_lite_controller i1_axi4_lite_controller(
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


	axi4_lite_controller i2_axi4_lite_controller(
		.clock(clock),
		.reset_n(reset_n),
		
		.i_write_enable(i2_write_enable),
		.i_write_address(i2_write_address),
		.i_write_data(i2_write_data),
		.o_write_finished(o2_write_finished),
		
		.i_read_enable(i2_read_enable),
		.i_read_address(i2_read_address),
		.o_read_finished(o2_read_finished),
		.o_read_data(o2_read_data),
		
		.m_axi_awaddr(m2_axi_awaddr),
		.m_axi_awprot(m2_axi_awprot),
		.m_axi_awvalid(m2_axi_awvalid),
		.m_axi_awready(m2_axi_awready),
		.m_axi_wdata(m2_axi_wdata),
		.m_axi_wstrb(m2_axi_wstrb),
		.m_axi_wvalid(m2_axi_wvalid),
		.m_axi_wready(m2_axi_wready),
		.m_axi_bresp(m2_axi_bresp),
		.m_axi_bvalid(m2_axi_bvalid),
		.m_axi_bready(m2_axi_bready),
		.m_axi_araddr(m2_axi_araddr),
		.m_axi_arprot(m2_axi_arprot),
		.m_axi_arvalid(m2_axi_arvalid),
		.m_axi_arready(m2_axi_arready),
		.m_axi_rdata(m2_axi_rdata),
		.m_axi_rresp(m2_axi_rresp),
		.m_axi_rvalid(m2_axi_rvalid),
		.m_axi_rready(m2_axi_rready)
	);
	
	axi4_lite_controller i3_axi4_lite_controller(
		.clock(clock),
		.reset_n(reset_n),
		
		.i_write_enable(i3_write_enable),
		.i_write_address(i3_write_address),
		.i_write_data(i3_write_data),
		.o_write_finished(o3_write_finished),
		
		.i_read_enable(i3_read_enable),
		.i_read_address(i3_read_address),
		.o_read_finished(o3_read_finished),
		.o_read_data(o3_read_data),
		
		.m_axi_awaddr(m3_axi_awaddr),
		.m_axi_awprot(m3_axi_awprot),
		.m_axi_awvalid(m3_axi_awvalid),
		.m_axi_awready(m3_axi_awready),
		.m_axi_wdata(m3_axi_wdata),
		.m_axi_wstrb(m3_axi_wstrb),
		.m_axi_wvalid(m3_axi_wvalid),
		.m_axi_wready(m3_axi_wready),
		.m_axi_bresp(m3_axi_bresp),
		.m_axi_bvalid(m3_axi_bvalid),
		.m_axi_bready(m3_axi_bready),
		.m_axi_araddr(m3_axi_araddr),
		.m_axi_arprot(m3_axi_arprot),
		.m_axi_arvalid(m3_axi_arvalid),
		.m_axi_arready(m3_axi_arready),
		.m_axi_rdata(m3_axi_rdata),
		.m_axi_rresp(m3_axi_rresp),
		.m_axi_rvalid(m3_axi_rvalid),
		.m_axi_rready(m3_axi_rready)
	);

	pram_controller #(
		.AD_DATA_WIDTH(AD_DATA_WIDTH),
		.AD_MEM_DEPTH(AD_MEM_DEPTH),
		.UA_DATA_WIDTH(UA_DATA_WIDTH),
		.UA_MEM_DEPTH(UA_MEM_DEPTH)
	) i_pram_controller(
		.clock(clock),
		.reset_n(reset_n),

		.i_write_enable(ib_write_enable),
		.i_write_address(ib_write_address),
		.i_write_data(ib_write_data),
		.o_write_finished(ob_write_finished),

		.i_read_enable(ib_read_enable),
		.i_read_address(ib_read_address),
		.o_read_finished(ob_read_finished),
		.o_read_data(ob_read_data),

		.pram_selection(pram_selection),

		.ad_en_b(ad_en_b),
		.ad_we_b(ad_we_b),
		.ad_addr_b(ad_addr_b),
		.ad_din_b(ad_din_b),
		.ad_dout_b(ad_dout_b),

		.ua_en_b(ua_en_b),
		.ua_we_b(ua_we_b),
		.ua_addr_b(ua_addr_b),
		.ua_din_b(ua_din_b),
		.ua_dout_b(ua_dout_b),

		.da_en_b(da_en_b),
		.da_we_b(da_we_b),
		.da_addr_b(da_addr_b),
		.da_din_b(da_din_b),
		.da_dout_b(da_dout_b)
	);


endmodule

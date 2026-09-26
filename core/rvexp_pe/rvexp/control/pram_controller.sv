`timescale 1ns / 1ps

module pram_controller #(
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
	input  logic 						clock,
	input  logic 						reset_n,

	input  logic        				i_write_enable,
	input  logic [63:0] 				i_write_address,
	input  logic [63:0] 				i_write_data,
	output logic        				o_write_finished,

	input  logic        				i_read_enable,
	input  logic [63:0] 				i_read_address,
	output logic        				o_read_finished,
	output logic [63:0] 				o_read_data,

	input  logic [1:0] 		     		pram_selection,

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
    output logic [UA_ADDR_WIDTH-1:0]   	da_addr_b,
    output logic [UA_DATA_WIDTH-1:0]   	da_din_b,
    input  logic [UA_DATA_WIDTH-1:0]   	da_dout_b
);

	logic           en_b;
    logic           we_b;
    logic [63:0] 	addr_b;
    logic [63:0]  	din_b;
    logic [63:0]	dout_b;

	logic [2:0] state;

	always_ff @(posedge clock) begin
		if(reset_n == 1'b0) begin
			state  <= 3'd0;
			en_b   <= 1'd0;
			we_b   <= 1'd0;
			o_write_finished <= 1'd0;
			o_read_finished  <= 1'd0;
		end

		else if(state == 3'd0 && i_write_enable == 1'b1) begin
			en_b   <= 1'b1;
			we_b   <= 1'b1;
			addr_b <= i_write_address;
			din_b  <= i_write_data;
			state  <= 3'd1;
		end
		else if(state == 3'd1) begin
			en_b   <= 1'b0;
			we_b   <= 1'b0;
			o_write_finished <= 1'b1;
			state            <= 3'd7;
		end

		else if(state == 3'd0 && i_read_enable == 1'b1) begin
			en_b   <= 1'b1;
			addr_b <= i_read_address;
			state  <= 3'd2;
		end
		else if(state == 3'd2) begin
			en_b   <= 1'b0;
			state  <= 3'd3;
		end
		else if(state == 3'd3) begin
			o_read_finished <= 1'b1;
			o_read_data     <= dout_b;
			state  <= 3'd7;
		end

		else if(state == 3'd7) begin
			o_write_finished <= 1'd0;
			o_read_finished  <= 1'd0;
			state            <= 2'd0;
		end

	end

	assign ad_en_b = pram_selection == 2'd0 ? en_b : 1'b0;
	assign ua_en_b = pram_selection == 2'd1 ? en_b : 1'b0;
	assign da_en_b = pram_selection == 2'd2 ? en_b : 1'b0;

	assign ad_we_b = pram_selection == 2'd0 ? we_b : 1'b0;
	assign ua_we_b = pram_selection == 2'd1 ? we_b : 1'b0;
	assign da_we_b = pram_selection == 2'd2 ? we_b : 1'b0;


	assign ad_addr_b = pram_selection == 2'd0 ? addr_b[AD_ADDR_WIDTH-1:0] : {AD_ADDR_WIDTH{1'b0}};
	assign ua_addr_b = pram_selection == 2'd1 ? addr_b[UA_ADDR_WIDTH-1:0] : {UA_ADDR_WIDTH{1'b0}};
	assign da_addr_b = pram_selection == 2'd2 ? addr_b[DA_ADDR_WIDTH-1:0] : {DA_ADDR_WIDTH{1'b0}};

	assign ad_din_b = pram_selection == 2'd0 ? din_b : {AD_DATA_WIDTH{1'b0}};
	assign ua_din_b = pram_selection == 2'd1 ? din_b : {UA_DATA_WIDTH{1'b0}};
	assign da_din_b = pram_selection == 2'd2 ? din_b : {DA_DATA_WIDTH{1'b0}};


	assign dout_b = (pram_selection == 2'd0) ? ad_dout_b :
                    (pram_selection == 2'd1) ? ua_dout_b :
                                               da_dout_b;


endmodule

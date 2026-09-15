//-----------------------------------------------------------------------------
// axi4_lite_controller
//
// Simple AXI4-Lite master wrapper with a pulse-based user interface.
//
// Usage:
//   - Pulse i_write_enable for exactly one cycle with i_write_address /
//     i_write_data valid in that same cycle. The request is latched
//     internally, so the AXI side does not need to be ready.
//     o_write_finished pulses for one cycle when the write response (B
//     channel) has been received.
//
//   - Pulse i_read_enable for exactly one cycle with i_read_address valid.
//     o_read_finished pulses for one cycle when the read data is available
//     on o_read_data. o_read_data holds its value until the next read
//     completes.
//
//   - Read and write channels are fully independent; a read and a write
//     can be in flight at the same time.
//
//   - One outstanding transaction per direction: wait for the corresponding
//     *_finished pulse before issuing the next request in that direction.
//     A new request may be issued in the same cycle *_finished is asserted.
//-----------------------------------------------------------------------------

module axi4_lite_controller(
	input  logic clock,
	input  logic reset_n,

	//user interface
	input  logic        i_write_enable,
	input  logic [31:0] i_write_address,
	input  logic [31:0] i_write_data,
	output logic        o_write_finished,

	input  logic        i_read_enable,
	input  logic [31:0] i_read_address,
	output logic        o_read_finished,
	output logic [31:0] o_read_data,

	//AXI4 Lite Interface
	output logic [31 : 0] m_axi_awaddr,
	output logic [ 2 : 0] m_axi_awprot,
	output logic          m_axi_awvalid,
	input  logic          m_axi_awready,
	output logic [31 : 0] m_axi_wdata,
	output logic [ 3 : 0] m_axi_wstrb,
	output logic          m_axi_wvalid,
	input  logic          m_axi_wready,
	input  logic [ 1 : 0] m_axi_bresp,
	input  logic          m_axi_bvalid,
	output logic          m_axi_bready,
	output logic [31 : 0] m_axi_araddr,
	output logic [ 2 : 0] m_axi_arprot,
	output logic          m_axi_arvalid,
	input  logic          m_axi_arready,
	input  logic [31 : 0] m_axi_rdata,
	input  logic [ 1 : 0] m_axi_rresp,
	input  logic          m_axi_rvalid,
	output logic          m_axi_rready
);

	// Fixed attributes
	assign m_axi_awprot = 3'b000;   // unprivileged, secure, data access
	assign m_axi_arprot = 3'b000;
	assign m_axi_wstrb  = 4'b1111;  // full 32-bit writes

	//-------------------------------------------------------------------------
	// Write channel FSM
	//
	// AW and W handshakes are independent and may complete in any order
	// (or in the same cycle), so each has its own valid flag.
	//-------------------------------------------------------------------------
	typedef enum logic [1:0] {
		WR_IDLE,   // waiting for a user request
		WR_ADDR,   // AW and/or W handshakes pending
		WR_RESP    // waiting for the write response (B channel)
	} wr_state_t;

	wr_state_t wr_state;

	always_ff @(posedge clock) begin
		if (!reset_n) begin
			wr_state         <= WR_IDLE;
			m_axi_awaddr     <= '0;
			m_axi_awvalid    <= 1'b0;
			m_axi_wdata      <= '0;
			m_axi_wvalid     <= 1'b0;
			m_axi_bready     <= 1'b0;
			o_write_finished <= 1'b0;
		end else begin
			o_write_finished <= 1'b0;  // single-cycle pulse

			unique case (wr_state)
				WR_IDLE: begin
					if (i_write_enable) begin
						m_axi_awaddr  <= i_write_address;
						m_axi_wdata   <= i_write_data;
						m_axi_awvalid <= 1'b1;
						m_axi_wvalid  <= 1'b1;
						wr_state      <= WR_ADDR;
					end
				end

				WR_ADDR: begin
					// Drop each valid as its handshake completes
					if (m_axi_awvalid && m_axi_awready)
						m_axi_awvalid <= 1'b0;
					if (m_axi_wvalid && m_axi_wready)
						m_axi_wvalid <= 1'b0;

					// Both handshakes done (possibly in this same cycle)
					if ((!m_axi_awvalid || m_axi_awready) &&
					    (!m_axi_wvalid  || m_axi_wready)) begin
						m_axi_bready <= 1'b1;
						wr_state     <= WR_RESP;
					end
				end

				WR_RESP: begin
					if (m_axi_bvalid) begin
						m_axi_bready     <= 1'b0;
						o_write_finished <= 1'b1;
						wr_state         <= WR_IDLE;
					end
				end

				default: wr_state <= WR_IDLE;
			endcase
		end
	end

	//-------------------------------------------------------------------------
	// Read channel FSM
	//-------------------------------------------------------------------------
	typedef enum logic [1:0] {
		RD_IDLE,   // waiting for a user request
		RD_ADDR,   // AR handshake pending
		RD_DATA    // waiting for read data (R channel)
	} rd_state_t;

	rd_state_t rd_state;

	always_ff @(posedge clock) begin
		if (!reset_n) begin
			rd_state        <= RD_IDLE;
			m_axi_araddr    <= '0;
			m_axi_arvalid   <= 1'b0;
			m_axi_rready    <= 1'b0;
			o_read_finished <= 1'b0;
			o_read_data     <= '0;
		end else begin
			o_read_finished <= 1'b0;  // single-cycle pulse

			unique case (rd_state)
				RD_IDLE: begin
					if (i_read_enable) begin
						m_axi_araddr  <= i_read_address;
						m_axi_arvalid <= 1'b1;
						rd_state      <= RD_ADDR;
					end
				end

				RD_ADDR: begin
					if (m_axi_arready) begin
						m_axi_arvalid <= 1'b0;
						m_axi_rready  <= 1'b1;
						rd_state      <= RD_DATA;
					end
				end

				RD_DATA: begin
					if (m_axi_rvalid) begin
						m_axi_rready    <= 1'b0;
						o_read_data     <= m_axi_rdata;
						o_read_finished <= 1'b1;
						rd_state        <= RD_IDLE;
					end
				end

				default: rd_state <= RD_IDLE;
			endcase
		end
	end

endmodule

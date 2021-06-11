`timescale 1 ns / 1 ps

///////////////////////////////////////////////
//                                           //
//       WARNING THIS CODE IS UNTESTED       //
//       USE AT YOUR OWN RISK                // 
//                                           //
///////////////////////////////////////////////

///////////////////////////////////////////////

// Demo SDRAM controller for MT48LC1M16A1 legacy SDRAM
// (C) fpga4fun.com & KNJN LLC 2014

// Changes made for MT41K256M16 and the Nexys Video from Digilent Inc.
// by Gregory S. Callen 2021

// The MT48LC1M16A1 is a 16Mb SDRAM arranged in 1M x 16bits (using 2 banks)
// The MT41K256M16 is a 4Gb SDRAM arranged in 256M x 16bits (using 8 banks)

// This controller feature set has been reduced to make it easy to understand
// It is based on a more complete controller targeted for Xylo-EM and Xylo-LM boards

// Assumptions:
// 1. the SDRAM has been initialized with CAS latency=2, and any valid burst mode
// 2. the read agent is active enough to refresh the RAM (if not, add a refresh timer)

// For more info, check
// http://www.fpga4fun.com/SDRAM.html

///////////////////////////////////////////////

module DDR3(
	input clk,

	// read agent
	input RdReq,
	output RdGnt,
	input [27:0] RdAddr,
	output reg [15:0] RdData,
	output RdDataValid,

	// write agent
	input WrReq,
	output WrGnt,
	input [27:0] WrAddr,
	input [15:0] WrData,

	// SDRAM
	output ddr3_cke, ddr3_we_n, ddr3_cas_n, ddr3_ras_n, ddr3_dq_oe,
	output reg [14:0] ddr3_addr,
	output reg [2:0] ddr3_ba,
	output reg [1:0] ddr3_dm = 2'b11,
	inout [15:0] ddr3_dq
);

assign ddr3_cke = 1'b1;

localparam [2:0] SDRAM_CMD_LOADMODE  = 3'b000;
localparam [2:0] SDRAM_CMD_REFRESH   = 3'b001;
localparam [2:0] SDRAM_CMD_PRECHARGE = 3'b010;
localparam [2:0] SDRAM_CMD_ACTIVE    = 3'b011;
localparam [2:0] SDRAM_CMD_WRITE     = 3'b100;
localparam [2:0] SDRAM_CMD_READ      = 3'b101;
localparam [2:0] SDRAM_CMD_NOP       = 3'b111;

reg [2:0] SDRAM_CMD = SDRAM_CMD_NOP;
assign {ddr3_ras_n, ddr3_cas_n, ddr3_we_n} = SDRAM_CMD;

// here we decide which of reads or writes have priority
wire read_now  =  RdReq;  // give priority to read requests
wire write_now = ~RdReq & WrReq;  // and if a read is not requested, give writes a chance...

reg [2:0] state=3'h4;
reg ReadSelected=0;  always @(posedge clk) if(state==3'h0) ReadSelected <= read_now;
wire WriteSelected = ~ReadSelected;

wire ReadCycle = (state==3'h0) ? read_now : ReadSelected;
wire [27:0] Addr = ReadCycle ? RdAddr : WrAddr;
reg [27:0] AddrR=0;  always @(posedge clk) AddrR <= Addr;

wire SameRowAndBank = (Addr[27:10]==AddrR[27:10]);
assign RdGnt = (state==3'h0 &  read_now) | (state==3'h1 &  ReadSelected & RdReq & SameRowAndBank);
assign WrGnt = (state==3'h0 & write_now) | (state==3'h1 & WriteSelected & WrReq & SameRowAndBank);

reg cke_flag <= 1'b0;
reg rstn_flag <= 1'b0;
reg [31:0] ticks <= 0;

wire ddr3_reset_n = rstn_flag ? 1'b1 : 1'b0;
wire ddr3_cke = cke_flag ? 1'd1 : 1'b0;
wire sys_reset = resetn and mem_ready and clk_locked;

always @(posedge clk) begin
	ticks <= ticks + 1;
	if ( sys_reset == 0 ) begin
		cke_flag <= 1'b0;
		rstn_flag <= 1'b0;
		ticks <= 0;
		state <= 3'h4;
	end
	case(state)
		3'h0: begin
			if(RdReq | WrReq) begin  // is there a read or write request?
				SDRAM_CMD <= SDRAM_CMD_ACTIVE;  // if so activate
				ddr3_ba <= Addr[27:25];  // this bank
				ddr3_addr <= Addr[24:10];  // this row
				ddr3_dm <= 2'b11;
				state <= 3'h1;
			end else begin
				SDRAM_CMD <= SDRAM_CMD_NOP;  // otherwise stay idle
				ddr3_ba <= 0;
				ddr3_addr <= 0;
				ddr3_dm <= 2'b11;
				state <= 3'h0;
			end
		end
		3'h1: begin
			SDRAM_CMD <= ReadSelected ? SDRAM_CMD_READ : SDRAM_CMD_WRITE;
			ddr3_ba <= AddrR[27:25];
			ddr3_addr <= {5'b00000, AddrR[9:0]};  // column
			ddr3_addr[10] <= 1'b0;  // no auto-precharge
			ddr3_dm <= 2'b00;
			state <= (ReadSelected ? RdReq : WrReq) & SameRowAndBank ? 3'h1 : 3'h2;
		end
		3'h2: begin
			$time;
			$display("precharge\n");
			SDRAM_CMD <= SDRAM_CMD_PRECHARGE;  // close the row when we're done with it
			ddr3_ba <= 0;
			ddr3_addr <= 11'b100_0000_0000;  // all banks precharge
			ddr3_dm <= 2'b11;
			ticks <= 0;
			state <= 3'h0;
		end
		3'h3: begin
			if ( ticks > 6000000 ) begin  // precharge after 60 ms @ 100MHz
				state <= 3'h2;
			end else begin
				SDRAM_CMD <= SDRAM_CMD_NOP;
				ddr3_ba <= 0;
				ddr3_addr <= 0;
				ddr3_dm <= 2'b11;
				state <= 3'h0;
			end
		end
		3'h4: begin
			if ( ticks > 22000 ) begin   // 220 µs @ 100MHz
				rstn_flag <= 1'b1;
				$time;
				$display("rstn ready\n");
			end
			if ( ticks > 75000 ) begin   // 750 µs @ 100MHz
				cke_flag <= 1'b1;
				$time;
				$display("cke ready\n");
			end
			if ( ticks > 75300 ) begin   // 753 µs @ 100MHz
				state <= 3'h0;
				$time;
				$display("all clear\n");
			end
		end
	endcase
end

localparam trl = 4;  // total read latency is the SDRAM CAS-latency (two) plus the SDRAM controller induced latency (two)
reg [trl-1:0] RdDataValidPipe;
always @(posedge clk) RdDataValidPipe <= {RdDataValidPipe[trl-2:0], state==2'h1 & ReadSelected};
assign RdDataValid = RdDataValidPipe[trl-1];
always @(posedge clk) RdData <= ddr3_dq;

reg ddr3_dq_oe = 1'b0;  always @(posedge clk) ddr3_dq_oe <= (state==2'h1) & WriteSelected;
reg [15:0] WrData1=0;  always @(posedge clk) WrData1 <= WrData;
reg [15:0] WrData2=0;  always @(posedge clk) WrData2 <= WrData1;

assign ddr3_dq = ddr3_dq_oe ? WrData2 : 16'hZZZZ;
endmodule
///////////////////////////////////////////////

`timescale 1ns / 1ps

// Copyright (c) 2021 by Gregory S. Callen
// All Rights Reserved.

module VID720 (
	input         MHz74_25,
	input         MHz371_25,
  input  [23:0] pixel,
  output [11:0] xpos,
  output [11:0] ypos,
	output reg    DrawArea,
	output        TMDSp_clock,
	output        TMDSn_clock,
	output [ 2:0] TMDSp,
	output [ 2:0] TMDSn
);

	OBUFDS #(
		.IOSTANDARD("DEFAULT"),
		.SLEW("SLOW")
	) OBUFDS_red (
		.O(TMDSp[2]),
		.OB(TMDSn[2]),
		.I(redo[~MHz371_25])
	);

	OBUFDS #(
		.IOSTANDARD("DEFAULT"),
		.SLEW("SLOW")
	) OBUFDS_grn (
		.O(TMDSp[1]),
		.OB(TMDSn[1]),
		.I(grno[~MHz371_25])
	);

	OBUFDS #(
		.IOSTANDARD("DEFAULT"),
		.SLEW("SLOW")
	) OBUFDS_blu (
		.O(TMDSp[0]),
		.OB(TMDSn[0]),
		.I(bluo[~MHz371_25])
	);

	OBUFDS #(
		.IOSTANDARD("DEFAULT"),
		.SLEW("SLOW")
	) OBUFDS_clock (
		.O(TMDSp_clock),
		.OB(TMDSn_clock),
		.I(MHz74_25)
	);

	// End of BUFG_inst instantiation

  parameter hsp = 1;
  parameter hfp = 110;
  parameter hbp = 150;
  parameter htb = 370;
  parameter hva = 1280;
  parameter htp = 1650;

  parameter vsp = 1;
  parameter vfp = 5;
  parameter vbp = 10;
  parameter vtb = 30;
  parameter vva = 720;
  parameter vtl = 750;

  reg hSync = ~hsp;
	reg vSync = ~vsp;

	initial begin
		DrawArea = 0;
	end

	reg [11:0] CounterX = 0;
  reg [11:0] CounterY = 0;

  reg [ 3:0] bits = 4'b1111;
  reg [ 7:0] redi = 0, grni = 0, blui = 0;
	reg [19:0] redo = 0, grno = 0, bluo = 0;

  wire [9:0] TMDS_red, TMDS_grn, TMDS_blu;

	assign xpos = CounterX - htb;
	assign ypos = CounterY - vtb;

	TMDS_encoder encode_R(.clock(MHz74_25),.Video(DrawArea),.Cntrl(2'b00),.Color(redi),.TMDS(TMDS_red));
	TMDS_encoder encode_G(.clock(MHz74_25),.Video(DrawArea),.Cntrl(2'b00),.Color(grni),.TMDS(TMDS_grn));
	TMDS_encoder encode_B(.clock(MHz74_25),.Video(DrawArea),.Cntrl({vSync,hSync}),.Color(blui),.TMDS(TMDS_blu));

	always @ ( posedge MHz371_25 ) begin
		redo <= redo >> 2;
		grno <= grno >> 2;
		bluo <= bluo >> 2;
		if ( ~bits[0] ) begin
			redo[19:10] <= TMDS_red;
			grno[19:10] <= TMDS_grn;
			bluo[19:10] <= TMDS_blu;
		end
		bits <= bits[0] ? bits >> 1 : 4'b1111;
	end

	always @ ( posedge MHz74_25 ) begin
		DrawArea <= ( CounterX > htb ) && ( CounterY > vtb );
		if ( CounterX == htp ) CounterY <= CounterY == vtl ? 1 : CounterY + 1;
		CounterX <= ( CounterX == htp ) ? 1 : CounterX + 1;
		hSync <= ( CounterX >= hfp ) && ( CounterX < hbp );
		vSync <= ( CounterY >= vfp ) && ( CounterY < vbp );
		redi <= pixel [23:16];
		grni <= pixel [15: 8];
		blui <= pixel [ 7: 0];
	end

endmodule  // end P720

// Copyright (c) 2021 by Gregory S. Callen
// All Rights Reserved.

module TMDS_encoder(
	input  wire       clock,
	input  wire       Video,
	input  wire [1:0] Cntrl,
	input  wire [7:0] Color,
	output reg  [9:0] TMDS
);

	reg [3:0] balance_acc = 0;
	reg [9:0] TEMP = 10'd0;

	wire [3:0] Nb1s = Color[0] + Color[1] + Color[2] + Color[3] + Color[4] + Color[5] + Color[6] + Color[7];
	wire XNOR = (Nb1s>4'd4) || (Nb1s==4'd4 && Color[0]==1'b0);
	wire [8:0] q_m = {~XNOR, q_m[6:0] ^ Color[7:1] ^ {7{XNOR}}, Color[0]};

	wire [3:0] balance = q_m[0] + q_m[1] + q_m[2] + q_m[3] + q_m[4] + q_m[5] + q_m[6] + q_m[7] - 4'd4;
	wire balance_sign_eq = (balance[3] == balance_acc[3]);
	wire invert_q_m = (balance==0 || balance_acc==0) ? ~q_m[8] : balance_sign_eq;
	wire [3:0] balance_acc_inc = balance - ({q_m[8] ^ ~balance_sign_eq} & ~(balance==0 || balance_acc==0));
	wire [3:0] balance_acc_new = invert_q_m ? balance_acc-balance_acc_inc : balance_acc+balance_acc_inc;
	wire [9:0] TMDS_data = {invert_q_m, q_m[8], q_m[7:0] ^ {8{invert_q_m}}};
	wire [9:0] TMDS_code = Cntrl[1] ? (Cntrl[0] ? 10'b1010101011 : 10'b0101010100) : (Cntrl[0] ? 10'b0010101011 : 10'b1101010100);

	always @ ( posedge clock ) TMDS <= TEMP;
	always @ ( posedge clock ) TEMP <= Video ? TMDS_data : TMDS_code;
	always @ ( posedge clock ) balance_acc <= Video ? balance_acc_new : 4'h0;

endmodule // end TMDS

// Copyright (c) 2021 by Gregory S. Callen
// All Rights Reserved.

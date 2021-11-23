`timescale 1ns / 1ps

`define polVESA 1'd1
`define hfpVESA 11'd48
`define hbpVESA 11'd160
`define hvaVESA 11'd408
`define hwlVESA 11'd1688
`define vfpVESA 11'd1
`define vbpVESA 11'd4
`define vvaVESA 11'd42
`define vwfVESA 11'd1066

`define polXGA 1'd0
`define hfpXGA 11'd24
`define hbpXGA 11'd160
`define hvaXGA 11'd320
`define hwlXGA 11'd1344
`define vfpXGA 11'd3
`define vbpXGA 11'd9
`define vvaXGA 11'd38
`define vwfXGA 11'd806

`define polSVGA 1'd0
`define hfpSVGA 11'd40
`define hbpSVGA 11'd168
`define hvaSVGA 11'd256
`define hwlSVGA 11'd1056
`define vfpSVGA 11'd1
`define vbpSVGA 11'd5
`define vvaSVGA 11'd28
`define vwfSVGA 11'd628

`define polVGA 1'd1
`define hfpVGA 11'd16
`define hbpVGA 11'd112
`define hvaVGA 11'd160
`define hwlVGA 11'd800
`define vfpVGA 11'd10
`define vbpVGA 11'd12
`define vvaVGA 11'd45
`define vwfVGA 11'd525

module ALL(
	input  wire       clk,
	input  wire [1:0] sw,
	output wire [3:0] vgaRed,
	output wire [3:0] vgaGreen,
	output wire [3:0] vgaBlue,
	output wire       Hsync,
	output wire       Vsync
);

	reg  [ 1:0] rez;

	wire        hsync [3:0];
	wire        vsync [3:0];
	wire [ 3:0] red   [3:0];
	wire [ 3:0] green [3:0];
	wire [ 3:0] blue  [3:0];
	wire [11:0] vcount[3:0];
	wire [11:0] hcount[3:0];

	assign vgaRed   =   red[rez];
	assign vgaGreen = green[rez];
	assign vgaBlue  =  blue[rez];
	assign Hsync    = hsync[rez];
	assign Vsync    = vsync[rez];

	always@(*)begin
		if((hcount[rez]==1)&&(vcount[rez]==1))begin
			rez=sw;
		end
	end

	CW vc(MHz108,MHz65,MHz40,MHz25,clk);

	Display vga(MHz25,red[0],green[0],blue[0],
		hsync[0],vsync[0],hcount[0],vcount[0],
		`polVGA,`hfpVGA,`hbpVGA,`hvaVGA,`hwlVGA,
		`vfpVGA,`vbpVGA,`vvaVGA,`vwfVGA
	);

	Display svga(MHz40,red[1],green[1],blue[1],
		hsync[1],vsync[1],hcount[1],vcount[1],
		`polSVGA,`hfpSVGA,`hbpSVGA,`hvaSVGA,`hwlSVGA,
		`vfpSVGA,`vbpSVGA,`vvaSVGA,`vwfSVGA
	);

	Display xga(MHz65,red[2],green[2],blue[2],
		hsync[2],vsync[2],hcount[2],vcount[2],
		`polXGA,`hfpXGA,`hbpXGA,`hvaXGA,`hwlXGA,
		`vfpXGA,`vbpXGA,`vvaXGA,`vwfXGA
	);

	Display vesa(MHz108,red[3],green[3],blue[3],
		hsync[3],vsync[3],hcount[3],vcount[3],
		`polVESA,`hfpVESA,`hbpVESA,`hvaVESA,`hwlVESA,
		`vfpVESA,`vbpVESA,`vvaVESA,`vwfVESA
	);

endmodule

module Display(
	input  wire        clk,
	output wire [ 3:0] vgaRed,
	output wire [ 3:0] vgaGreen,
	output wire [ 3:0] vgaBlue,
	output reg         Hsync,
	output reg         Vsync,
	output reg  [11:0] hCount,
	output reg  [11:0] vCount,
	input  wire        POL,
	input  wire [10:0] HFP,
	input  wire [10:0] HBP,
	input  wire [10:0] HVA,
	input  wire [10:0] HWL,
	input  wire [10:0] VFP,
	input  wire [10:0] VBP,
	input  wire [10:0] VVA,
	input  wire [10:0] VWF
);

	reg         flip;
	reg	[ 6:0]	chr;
	reg	[ 7:0]	pix;
	reg	[11:0]	color;
	reg	[11:0]	off;
	reg	[11:0]	on;

	wire	[ 2:0]	col;
	wire	[ 2:0]	row;
	wire	[ 3:0]	hex;
	wire	[ 7:0]	nxt;
	wire	[11:0]	ypos;
	wire	[11:0]	xpos;
	wire	[14:0]	address;

	assign xpos     = hCount - HVA + 12'd8;
	assign ypos     = vCount - VVA;
	assign col      = xpos[2:0];
	assign row      = ypos[2:0];
	assign address  = ( ypos[9:3] << 8 ) + xpos[11:3] + 13'd1;
	assign vgaRed   = color[11:8];
	assign vgaGreen = color[7:4];
	assign vgaBlue  = color[3:0];

	CharSet cs ( clk, chr, row, nxt );

	initial begin
		Hsync  = ~POL;
		Vsync  = ~POL;
		hCount = 11'd0;
		vCount = 10'd0;
		chr    =  7'd0;
		pix    =  8'd0;
		color  = 12'd0;
		on     = 12'd0;
		off    = 12'd0;
	end

	always @ (posedge clk) begin
		if (( vCount < VVA ) || ( hCount < HVA )) begin
			color <= 12'd0;
		end else begin
			if ( flip ) begin
				color <= pix[~col] ? off : on;
			end else begin
				color <= pix[~col] ? on : off;
			end
		end
		if (( hCount >= HFP ) && ( hCount < HBP )) begin
			Hsync <= POL;
		end else begin
			Hsync <= ~POL;
		end
		if (( vCount >= VFP ) && ( vCount < VBP )) begin
			Vsync <= POL;
		end else begin
			Vsync <= ~POL;
		end
		if ( hCount < HWL ) begin
			hCount <= hCount + 10'd1;
		end else begin
			hCount <= 10'd0;
			if ( vCount < VWF ) begin
				vCount <= vCount + 10'd1;
			end else begin
				vCount <= 10'd0;
			end
		end
		if ( xpos[2:0] == 3'd6 ) begin
			chr <= address[6:0];
		end else if ( xpos[2:0] == 3'd7 ) begin
			pix	 <= nxt;
			flip <= address[7];
			off  <= address[11:0];
			on   <=~address[11:0];
		end
	end

endmodule

module CharSet(
	input wire       clk,
	input wire [6:0] chr,
	input wire [2:0] row,
	output reg [7:0] pix
);

	wire [7:0] char [127:0][7:0];

	initial begin
		pix = 8'd0;
	end

	always @ (posedge clk) begin
		pix <= char[chr][row];
	end

assign char[0][0]=8'b00000000;
assign char[0][1]=8'b00110110;
assign char[0][2]=8'b01111111;
assign char[0][3]=8'b01111111;
assign char[0][4]=8'b00111110;
assign char[0][5]=8'b00011100;
assign char[0][6]=8'b00001000;
assign char[0][7]=8'b00000000;

assign char[1][0]=8'b00011000;
assign char[1][1]=8'b00011000;
assign char[1][2]=8'b00011000;
assign char[1][3]=8'b00011111;
assign char[1][4]=8'b00011111;
assign char[1][5]=8'b00011000;
assign char[1][6]=8'b00011000;
assign char[1][7]=8'b00011000;

assign char[2][0]=8'b00000011;
assign char[2][1]=8'b00000011;
assign char[2][2]=8'b00000011;
assign char[2][3]=8'b00000011;
assign char[2][4]=8'b00000011;
assign char[2][5]=8'b00000011;
assign char[2][6]=8'b00000011;
assign char[2][7]=8'b00000011;

assign char[3][0]=8'b00011000;
assign char[3][1]=8'b00011000;
assign char[3][2]=8'b00011000;
assign char[3][3]=8'b11111000;
assign char[3][4]=8'b11111000;
assign char[3][5]=8'b00000000;
assign char[3][6]=8'b00000000;
assign char[3][7]=8'b00000000;

assign char[4][0]=8'b00011000;
assign char[4][1]=8'b00011000;
assign char[4][2]=8'b00011000;
assign char[4][3]=8'b11111000;
assign char[4][4]=8'b11111000;
assign char[4][5]=8'b00011000;
assign char[4][6]=8'b00011000;
assign char[4][7]=8'b00011000;

assign char[5][0]=8'b00000000;
assign char[5][1]=8'b00000000;
assign char[5][2]=8'b00000000;
assign char[5][3]=8'b11111000;
assign char[5][4]=8'b11111000;
assign char[5][5]=8'b00011000;
assign char[5][6]=8'b00011000;
assign char[5][7]=8'b00011000;

assign char[6][0]=8'b00000011;
assign char[6][1]=8'b00000111;
assign char[6][2]=8'b00001110;
assign char[6][3]=8'b00011100;
assign char[6][4]=8'b00111000;
assign char[6][5]=8'b01110000;
assign char[6][6]=8'b11100000;
assign char[6][7]=8'b11000000;

assign char[7][0]=8'b11000000;
assign char[7][1]=8'b11100000;
assign char[7][2]=8'b01110000;
assign char[7][3]=8'b00111000;
assign char[7][4]=8'b00011100;
assign char[7][5]=8'b00001110;
assign char[7][6]=8'b00000111;
assign char[7][7]=8'b00000011;

assign char[8][0]=8'b00000001;
assign char[8][1]=8'b00000011;
assign char[8][2]=8'b00000111;
assign char[8][3]=8'b00001111;
assign char[8][4]=8'b00011111;
assign char[8][5]=8'b00111111;
assign char[8][6]=8'b01111111;
assign char[8][7]=8'b11111111;

assign char[9][0]=8'b00000000;
assign char[9][1]=8'b00000000;
assign char[9][2]=8'b00000000;
assign char[9][3]=8'b00000000;
assign char[9][4]=8'b00001111;
assign char[9][5]=8'b00001111;
assign char[9][6]=8'b00001111;
assign char[9][7]=8'b00001111;

assign char[10][0]=8'b10000000;
assign char[10][1]=8'b11000000;
assign char[10][2]=8'b11100000;
assign char[10][3]=8'b11110000;
assign char[10][4]=8'b11111000;
assign char[10][5]=8'b11111100;
assign char[10][6]=8'b11111110;
assign char[10][7]=8'b11111111;

assign char[11][0]=8'b00001111;
assign char[11][1]=8'b00001111;
assign char[11][2]=8'b00001111;
assign char[11][3]=8'b00001111;
assign char[11][4]=8'b00000000;
assign char[11][5]=8'b00000000;
assign char[11][6]=8'b00000000;
assign char[11][7]=8'b00000000;

assign char[12][0]=8'b11110000;
assign char[12][1]=8'b11110000;
assign char[12][2]=8'b11110000;
assign char[12][3]=8'b11110000;
assign char[12][4]=8'b00000000;
assign char[12][5]=8'b00000000;
assign char[12][6]=8'b00000000;
assign char[12][7]=8'b00000000;

assign char[13][0]=8'b11111111;
assign char[13][1]=8'b11111111;
assign char[13][2]=8'b00000000;
assign char[13][3]=8'b00000000;
assign char[13][4]=8'b00000000;
assign char[13][5]=8'b00000000;
assign char[13][6]=8'b00000000;
assign char[13][7]=8'b00000000;

assign char[14][0]=8'b00000000;
assign char[14][1]=8'b00000000;
assign char[14][2]=8'b00000000;
assign char[14][3]=8'b00000000;
assign char[14][4]=8'b00000000;
assign char[14][5]=8'b00000000;
assign char[14][6]=8'b11111111;
assign char[14][7]=8'b11111111;

assign char[15][0]=8'b00000000;
assign char[15][1]=8'b00000000;
assign char[15][2]=8'b00000000;
assign char[15][3]=8'b00000000;
assign char[15][4]=8'b11110000;
assign char[15][5]=8'b11110000;
assign char[15][6]=8'b11110000;
assign char[15][7]=8'b11110000;

assign char[16][0]=8'b00000000;
assign char[16][1]=8'b00011100;
assign char[16][2]=8'b00011100;
assign char[16][3]=8'b01110111;
assign char[16][4]=8'b01110111;
assign char[16][5]=8'b00001000;
assign char[16][6]=8'b00011100;
assign char[16][7]=8'b00000000;

assign char[17][0]=8'b00000000;
assign char[17][1]=8'b00000000;
assign char[17][2]=8'b00000000;
assign char[17][3]=8'b00011111;
assign char[17][4]=8'b00011111;
assign char[17][5]=8'b00011000;
assign char[17][6]=8'b00011000;
assign char[17][7]=8'b00011000;

assign char[18][0]=8'b00000000;
assign char[18][1]=8'b00000000;
assign char[18][2]=8'b00000000;
assign char[18][3]=8'b11111111;
assign char[18][4]=8'b11111111;
assign char[18][5]=8'b00000000;
assign char[18][6]=8'b00000000;
assign char[18][7]=8'b00000000;

assign char[19][0]=8'b00011000;
assign char[19][1]=8'b00011000;
assign char[19][2]=8'b00011000;
assign char[19][3]=8'b11111111;
assign char[19][4]=8'b11111111;
assign char[19][5]=8'b00011000;
assign char[19][6]=8'b00011000;
assign char[19][7]=8'b00011000;

assign char[20][0]=8'b00000000;
assign char[20][1]=8'b00000000;
assign char[20][2]=8'b00111100;
assign char[20][3]=8'b01111110;
assign char[20][4]=8'b01111110;
assign char[20][5]=8'b01111110;
assign char[20][6]=8'b00111100;
assign char[20][7]=8'b00000000;

assign char[21][0]=8'b00000000;
assign char[21][1]=8'b00000000;
assign char[21][2]=8'b00000000;
assign char[21][3]=8'b00000000;
assign char[21][4]=8'b11111111;
assign char[21][5]=8'b11111111;
assign char[21][6]=8'b11111111;
assign char[21][7]=8'b11111111;

assign char[22][0]=8'b11000000;
assign char[22][1]=8'b11000000;
assign char[22][2]=8'b11000000;
assign char[22][3]=8'b11000000;
assign char[22][4]=8'b11000000;
assign char[22][5]=8'b11000000;
assign char[22][6]=8'b11000000;
assign char[22][7]=8'b11000000;

assign char[23][0]=8'b00000000;
assign char[23][1]=8'b00000000;
assign char[23][2]=8'b00000000;
assign char[23][3]=8'b11111111;
assign char[23][4]=8'b11111111;
assign char[23][5]=8'b00011000;
assign char[23][6]=8'b00011000;
assign char[23][7]=8'b00011000;

assign char[24][0]=8'b00011000;
assign char[24][1]=8'b00011000;
assign char[24][2]=8'b00011000;
assign char[24][3]=8'b11111111;
assign char[24][4]=8'b11111111;
assign char[24][5]=8'b00000000;
assign char[24][6]=8'b00000000;
assign char[24][7]=8'b00000000;

assign char[25][0]=8'b11110000;
assign char[25][1]=8'b11110000;
assign char[25][2]=8'b11110000;
assign char[25][3]=8'b11110000;
assign char[25][4]=8'b11110000;
assign char[25][5]=8'b11110000;
assign char[25][6]=8'b11110000;
assign char[25][7]=8'b11110000;

assign char[26][0]=8'b00011000;
assign char[26][1]=8'b00011000;
assign char[26][2]=8'b00011000;
assign char[26][3]=8'b00011111;
assign char[26][4]=8'b00011111;
assign char[26][5]=8'b00000000;
assign char[26][6]=8'b00000000;
assign char[26][7]=8'b00000000;

assign char[27][0]=8'b01111000;
assign char[27][1]=8'b01100000;
assign char[27][2]=8'b01111000;
assign char[27][3]=8'b01100000;
assign char[27][4]=8'b01111110;
assign char[27][5]=8'b00011000;
assign char[27][6]=8'b00011110;
assign char[27][7]=8'b00000000;

assign char[28][0]=8'b00000000;
assign char[28][1]=8'b00011000;
assign char[28][2]=8'b00111100;
assign char[28][3]=8'b01111110;
assign char[28][4]=8'b00011000;
assign char[28][5]=8'b00011000;
assign char[28][6]=8'b00011000;
assign char[28][7]=8'b00000000;

assign char[29][0]=8'b00000000;
assign char[29][1]=8'b00011000;
assign char[29][2]=8'b00011000;
assign char[29][3]=8'b00011000;
assign char[29][4]=8'b01111110;
assign char[29][5]=8'b00111100;
assign char[29][6]=8'b00011000;
assign char[29][7]=8'b00000000;

assign char[30][0]=8'b00000000;
assign char[30][1]=8'b00011000;
assign char[30][2]=8'b00110000;
assign char[30][3]=8'b01111110;
assign char[30][4]=8'b00110000;
assign char[30][5]=8'b00011000;
assign char[30][6]=8'b00000000;
assign char[30][7]=8'b00000000;

assign char[31][0]=8'b00000000;
assign char[31][1]=8'b00011000;
assign char[31][2]=8'b00001100;
assign char[31][3]=8'b01111110;
assign char[31][4]=8'b00001100;
assign char[31][5]=8'b00011000;
assign char[31][6]=8'b00000000;
assign char[31][7]=8'b00000000;

assign char[32][0]=8'b00000000;
assign char[32][1]=8'b00000000;
assign char[32][2]=8'b00000000;
assign char[32][3]=8'b00000000;
assign char[32][4]=8'b00000000;
assign char[32][5]=8'b00000000;
assign char[32][6]=8'b00000000;
assign char[32][7]=8'b00000000;

assign char[33][0]=8'b00000000;
assign char[33][1]=8'b00011000;
assign char[33][2]=8'b00011000;
assign char[33][3]=8'b00011000;
assign char[33][4]=8'b00011000;
assign char[33][5]=8'b00000000;
assign char[33][6]=8'b00011000;
assign char[33][7]=8'b00000000;

assign char[34][0]=8'b00000000;
assign char[34][1]=8'b01100110;
assign char[34][2]=8'b01100110;
assign char[34][3]=8'b01100110;
assign char[34][4]=8'b00000000;
assign char[34][5]=8'b00000000;
assign char[34][6]=8'b00000000;
assign char[34][7]=8'b00000000;

assign char[35][0]=8'b00000000;
assign char[35][1]=8'b01100110;
assign char[35][2]=8'b11111111;
assign char[35][3]=8'b01100110;
assign char[35][4]=8'b01100110;
assign char[35][5]=8'b11111111;
assign char[35][6]=8'b01100110;
assign char[35][7]=8'b00000000;

assign char[36][0]=8'b00011000;
assign char[36][1]=8'b00111110;
assign char[36][2]=8'b01100000;
assign char[36][3]=8'b00111100;
assign char[36][4]=8'b00000110;
assign char[36][5]=8'b01111100;
assign char[36][6]=8'b00011000;
assign char[36][7]=8'b00000000;

assign char[37][0]=8'b00000000;
assign char[37][1]=8'b01100110;
assign char[37][2]=8'b01101100;
assign char[37][3]=8'b00011000;
assign char[37][4]=8'b00110000;
assign char[37][5]=8'b01100110;
assign char[37][6]=8'b01000110;
assign char[37][7]=8'b00000000;

assign char[38][0]=8'b00011100;
assign char[38][1]=8'b00110110;
assign char[38][2]=8'b00011100;
assign char[38][3]=8'b00111000;
assign char[38][4]=8'b01101111;
assign char[38][5]=8'b01100110;
assign char[38][6]=8'b00111011;
assign char[38][7]=8'b00000000;

assign char[39][0]=8'b00000000;
assign char[39][1]=8'b00011000;
assign char[39][2]=8'b00011000;
assign char[39][3]=8'b00011000;
assign char[39][4]=8'b00000000;
assign char[39][5]=8'b00000000;
assign char[39][6]=8'b00000000;
assign char[39][7]=8'b00000000;

assign char[40][0]=8'b00000000;
assign char[40][1]=8'b00001110;
assign char[40][2]=8'b00011100;
assign char[40][3]=8'b00011000;
assign char[40][4]=8'b00011000;
assign char[40][5]=8'b00011100;
assign char[40][6]=8'b00001110;
assign char[40][7]=8'b00000000;

assign char[41][0]=8'b00000000;
assign char[41][1]=8'b01110000;
assign char[41][2]=8'b00111000;
assign char[41][3]=8'b00011000;
assign char[41][4]=8'b00011000;
assign char[41][5]=8'b00111000;
assign char[41][6]=8'b01110000;
assign char[41][7]=8'b00000000;

assign char[42][0]=8'b00000000;
assign char[42][1]=8'b01100110;
assign char[42][2]=8'b00111100;
assign char[42][3]=8'b11111111;
assign char[42][4]=8'b00111100;
assign char[42][5]=8'b01100110;
assign char[42][6]=8'b00000000;
assign char[42][7]=8'b00000000;

assign char[43][0]=8'b00000000;
assign char[43][1]=8'b00011000;
assign char[43][2]=8'b00011000;
assign char[43][3]=8'b01111110;
assign char[43][4]=8'b00011000;
assign char[43][5]=8'b00011000;
assign char[43][6]=8'b00000000;
assign char[43][7]=8'b00000000;

assign char[44][0]=8'b00000000;
assign char[44][1]=8'b00000000;
assign char[44][2]=8'b00000000;
assign char[44][3]=8'b00000000;
assign char[44][4]=8'b00000000;
assign char[44][5]=8'b00011000;
assign char[44][6]=8'b00011000;
assign char[44][7]=8'b00110000;

assign char[45][0]=8'b00000000;
assign char[45][1]=8'b00000000;
assign char[45][2]=8'b00000000;
assign char[45][3]=8'b01111110;
assign char[45][4]=8'b00000000;
assign char[45][5]=8'b00000000;
assign char[45][6]=8'b00000000;
assign char[45][7]=8'b00000000;

assign char[46][0]=8'b00000000;
assign char[46][1]=8'b00000000;
assign char[46][2]=8'b00000000;
assign char[46][3]=8'b00000000;
assign char[46][4]=8'b00000000;
assign char[46][5]=8'b00011000;
assign char[46][6]=8'b00011000;
assign char[46][7]=8'b00000000;

assign char[47][0]=8'b00000000;
assign char[47][1]=8'b00000110;
assign char[47][2]=8'b00001100;
assign char[47][3]=8'b00011000;
assign char[47][4]=8'b00110000;
assign char[47][5]=8'b01100000;
assign char[47][6]=8'b01000000;
assign char[47][7]=8'b00000000;

assign char[48][0]=8'b00000000;
assign char[48][1]=8'b00111100;
assign char[48][2]=8'b01100110;
assign char[48][3]=8'b01101110;
assign char[48][4]=8'b01110110;
assign char[48][5]=8'b01100110;
assign char[48][6]=8'b00111100;
assign char[48][7]=8'b00000000;

assign char[49][0]=8'b00000000;
assign char[49][1]=8'b00011000;
assign char[49][2]=8'b00111000;
assign char[49][3]=8'b00011000;
assign char[49][4]=8'b00011000;
assign char[49][5]=8'b00011000;
assign char[49][6]=8'b01111110;
assign char[49][7]=8'b00000000;

assign char[50][0]=8'b00000000;
assign char[50][1]=8'b00111100;
assign char[50][2]=8'b01100110;
assign char[50][3]=8'b00001100;
assign char[50][4]=8'b00011000;
assign char[50][5]=8'b00110000;
assign char[50][6]=8'b01111110;
assign char[50][7]=8'b00000000;

assign char[51][0]=8'b00000000;
assign char[51][1]=8'b01111110;
assign char[51][2]=8'b00001100;
assign char[51][3]=8'b00011000;
assign char[51][4]=8'b00001100;
assign char[51][5]=8'b01100110;
assign char[51][6]=8'b00111100;
assign char[51][7]=8'b00000000;

assign char[52][0]=8'b00000000;
assign char[52][1]=8'b00001100;
assign char[52][2]=8'b00011100;
assign char[52][3]=8'b00111100;
assign char[52][4]=8'b01101100;
assign char[52][5]=8'b01111110;
assign char[52][6]=8'b00001100;
assign char[52][7]=8'b00000000;

assign char[53][0]=8'b00000000;
assign char[53][1]=8'b01111110;
assign char[53][2]=8'b01100000;
assign char[53][3]=8'b01111100;
assign char[53][4]=8'b00000110;
assign char[53][5]=8'b01100110;
assign char[53][6]=8'b00111100;
assign char[53][7]=8'b00000000;

assign char[54][0]=8'b00000000;
assign char[54][1]=8'b00111100;
assign char[54][2]=8'b01100000;
assign char[54][3]=8'b01111100;
assign char[54][4]=8'b01100110;
assign char[54][5]=8'b01100110;
assign char[54][6]=8'b00111100;
assign char[54][7]=8'b00000000;

assign char[55][0]=8'b00000000;
assign char[55][1]=8'b01111110;
assign char[55][2]=8'b00000110;
assign char[55][3]=8'b00001100;
assign char[55][4]=8'b00011000;
assign char[55][5]=8'b00110000;
assign char[55][6]=8'b00110000;
assign char[55][7]=8'b00000000;

assign char[56][0]=8'b00000000;
assign char[56][1]=8'b00111100;
assign char[56][2]=8'b01100110;
assign char[56][3]=8'b00111100;
assign char[56][4]=8'b01100110;
assign char[56][5]=8'b01100110;
assign char[56][6]=8'b00111100;
assign char[56][7]=8'b00000000;

assign char[57][0]=8'b00000000;
assign char[57][1]=8'b00111100;
assign char[57][2]=8'b01100110;
assign char[57][3]=8'b00111110;
assign char[57][4]=8'b00000110;
assign char[57][5]=8'b00001100;
assign char[57][6]=8'b00111000;
assign char[57][7]=8'b00000000;

assign char[58][0]=8'b00000000;
assign char[58][1]=8'b00000000;
assign char[58][2]=8'b00011000;
assign char[58][3]=8'b00011000;
assign char[58][4]=8'b00000000;
assign char[58][5]=8'b00011000;
assign char[58][6]=8'b00011000;
assign char[58][7]=8'b00000000;

assign char[59][0]=8'b00000000;
assign char[59][1]=8'b00000000;
assign char[59][2]=8'b00011000;
assign char[59][3]=8'b00011000;
assign char[59][4]=8'b00000000;
assign char[59][5]=8'b00011000;
assign char[59][6]=8'b00011000;
assign char[59][7]=8'b00110000;

assign char[60][0]=8'b00000110;
assign char[60][1]=8'b00001100;
assign char[60][2]=8'b00011000;
assign char[60][3]=8'b00110000;
assign char[60][4]=8'b00011000;
assign char[60][5]=8'b00001100;
assign char[60][6]=8'b00000110;
assign char[60][7]=8'b00000000;

assign char[61][0]=8'b00000000;
assign char[61][1]=8'b00000000;
assign char[61][2]=8'b01111110;
assign char[61][3]=8'b00000000;
assign char[61][4]=8'b00000000;
assign char[61][5]=8'b01111110;
assign char[61][6]=8'b00000000;
assign char[61][7]=8'b00000000;

assign char[62][0]=8'b01100000;
assign char[62][1]=8'b00110000;
assign char[62][2]=8'b00011000;
assign char[62][3]=8'b00001100;
assign char[62][4]=8'b00011000;
assign char[62][5]=8'b00110000;
assign char[62][6]=8'b01100000;
assign char[62][7]=8'b00000000;

assign char[63][0]=8'b00000000;
assign char[63][1]=8'b00111100;
assign char[63][2]=8'b01100110;
assign char[63][3]=8'b00001100;
assign char[63][4]=8'b00011000;
assign char[63][5]=8'b00000000;
assign char[63][6]=8'b00011000;
assign char[63][7]=8'b00000000;

assign char[64][0]=8'b00000000;
assign char[64][1]=8'b00111100;
assign char[64][2]=8'b01100110;
assign char[64][3]=8'b01101110;
assign char[64][4]=8'b01101110;
assign char[64][5]=8'b01100000;
assign char[64][6]=8'b00111110;
assign char[64][7]=8'b00000000;

assign char[65][0]=8'b00000000;
assign char[65][1]=8'b00011000;
assign char[65][2]=8'b00111100;
assign char[65][3]=8'b01100110;
assign char[65][4]=8'b01100110;
assign char[65][5]=8'b01111110;
assign char[65][6]=8'b01100110;
assign char[65][7]=8'b00000000;

assign char[66][0]=8'b00000000;
assign char[66][1]=8'b01111100;
assign char[66][2]=8'b01100110;
assign char[66][3]=8'b01111100;
assign char[66][4]=8'b01100110;
assign char[66][5]=8'b01100110;
assign char[66][6]=8'b01111100;
assign char[66][7]=8'b00000000;

assign char[67][0]=8'b00000000;
assign char[67][1]=8'b00111100;
assign char[67][2]=8'b01100110;
assign char[67][3]=8'b01100000;
assign char[67][4]=8'b01100000;
assign char[67][5]=8'b01100110;
assign char[67][6]=8'b00111100;
assign char[67][7]=8'b00000000;

assign char[68][0]=8'b00000000;
assign char[68][1]=8'b01111000;
assign char[68][2]=8'b01101100;
assign char[68][3]=8'b01100110;
assign char[68][4]=8'b01100110;
assign char[68][5]=8'b01101100;
assign char[68][6]=8'b01111000;
assign char[68][7]=8'b00000000;

assign char[69][0]=8'b00000000;
assign char[69][1]=8'b01111110;
assign char[69][2]=8'b01100000;
assign char[69][3]=8'b01111100;
assign char[69][4]=8'b01100000;
assign char[69][5]=8'b01100000;
assign char[69][6]=8'b01111110;
assign char[69][7]=8'b00000000;

assign char[70][0]=8'b00000000;
assign char[70][1]=8'b01111110;
assign char[70][2]=8'b01100000;
assign char[70][3]=8'b01111100;
assign char[70][4]=8'b01100000;
assign char[70][5]=8'b01100000;
assign char[70][6]=8'b01100000;
assign char[70][7]=8'b00000000;

assign char[71][0]=8'b00000000;
assign char[71][1]=8'b00111110;
assign char[71][2]=8'b01100000;
assign char[71][3]=8'b01100000;
assign char[71][4]=8'b01101110;
assign char[71][5]=8'b01100110;
assign char[71][6]=8'b00111110;
assign char[71][7]=8'b00000000;

assign char[72][0]=8'b00000000;
assign char[72][1]=8'b01100110;
assign char[72][2]=8'b01100110;
assign char[72][3]=8'b01111110;
assign char[72][4]=8'b01100110;
assign char[72][5]=8'b01100110;
assign char[72][6]=8'b01100110;
assign char[72][7]=8'b00000000;

assign char[73][0]=8'b00000000;
assign char[73][1]=8'b01111110;
assign char[73][2]=8'b00011000;
assign char[73][3]=8'b00011000;
assign char[73][4]=8'b00011000;
assign char[73][5]=8'b00011000;
assign char[73][6]=8'b01111110;
assign char[73][7]=8'b00000000;

assign char[74][0]=8'b00000000;
assign char[74][1]=8'b00000110;
assign char[74][2]=8'b00000110;
assign char[74][3]=8'b00000110;
assign char[74][4]=8'b00000110;
assign char[74][5]=8'b01100110;
assign char[74][6]=8'b00111100;
assign char[74][7]=8'b00000000;

assign char[75][0]=8'b00000000;
assign char[75][1]=8'b01100110;
assign char[75][2]=8'b01101100;
assign char[75][3]=8'b01111000;
assign char[75][4]=8'b01111000;
assign char[75][5]=8'b01101100;
assign char[75][6]=8'b01100110;
assign char[75][7]=8'b00000000;

assign char[76][0]=8'b00000000;
assign char[76][1]=8'b01100000;
assign char[76][2]=8'b01100000;
assign char[76][3]=8'b01100000;
assign char[76][4]=8'b01100000;
assign char[76][5]=8'b01100000;
assign char[76][6]=8'b01111110;
assign char[76][7]=8'b00000000;

assign char[77][0]=8'b00000000;
assign char[77][1]=8'b01100011;
assign char[77][2]=8'b01110111;
assign char[77][3]=8'b01111111;
assign char[77][4]=8'b01101011;
assign char[77][5]=8'b01100011;
assign char[77][6]=8'b01100011;
assign char[77][7]=8'b00000000;

assign char[78][0]=8'b00000000;
assign char[78][1]=8'b01100110;
assign char[78][2]=8'b01110110;
assign char[78][3]=8'b01111110;
assign char[78][4]=8'b01111110;
assign char[78][5]=8'b01101110;
assign char[78][6]=8'b01100110;
assign char[78][7]=8'b00000000;

assign char[79][0]=8'b00000000;
assign char[79][1]=8'b00111100;
assign char[79][2]=8'b01100110;
assign char[79][3]=8'b01100110;
assign char[79][4]=8'b01100110;
assign char[79][5]=8'b01100110;
assign char[79][6]=8'b00111100;
assign char[79][7]=8'b00000000;

assign char[80][0]=8'b00000000;
assign char[80][1]=8'b01111100;
assign char[80][2]=8'b01100110;
assign char[80][3]=8'b01100110;
assign char[80][4]=8'b01111100;
assign char[80][5]=8'b01100000;
assign char[80][6]=8'b01100000;
assign char[80][7]=8'b00000000;

assign char[81][0]=8'b00000000;
assign char[81][1]=8'b00111100;
assign char[81][2]=8'b01100110;
assign char[81][3]=8'b01100110;
assign char[81][4]=8'b01100110;
assign char[81][5]=8'b01101100;
assign char[81][6]=8'b00110110;
assign char[81][7]=8'b00000000;

assign char[82][0]=8'b00000000;
assign char[82][1]=8'b01111100;
assign char[82][2]=8'b01100110;
assign char[82][3]=8'b01100110;
assign char[82][4]=8'b01111100;
assign char[82][5]=8'b01101100;
assign char[82][6]=8'b01100110;
assign char[82][7]=8'b00000000;

assign char[83][0]=8'b00000000;
assign char[83][1]=8'b00111100;
assign char[83][2]=8'b01100000;
assign char[83][3]=8'b00111100;
assign char[83][4]=8'b00000110;
assign char[83][5]=8'b00000110;
assign char[83][6]=8'b00111100;
assign char[83][7]=8'b00000000;

assign char[84][0]=8'b00000000;
assign char[84][1]=8'b01111110;
assign char[84][2]=8'b00011000;
assign char[84][3]=8'b00011000;
assign char[84][4]=8'b00011000;
assign char[84][5]=8'b00011000;
assign char[84][6]=8'b00011000;
assign char[84][7]=8'b00000000;

assign char[85][0]=8'b00000000;
assign char[85][1]=8'b01100110;
assign char[85][2]=8'b01100110;
assign char[85][3]=8'b01100110;
assign char[85][4]=8'b01100110;
assign char[85][5]=8'b01100110;
assign char[85][6]=8'b01111110;
assign char[85][7]=8'b00000000;

assign char[86][0]=8'b00000000;
assign char[86][1]=8'b01100110;
assign char[86][2]=8'b01100110;
assign char[86][3]=8'b01100110;
assign char[86][4]=8'b01100110;
assign char[86][5]=8'b00111100;
assign char[86][6]=8'b00011000;
assign char[86][7]=8'b00000000;

assign char[87][0]=8'b00000000;
assign char[87][1]=8'b01100011;
assign char[87][2]=8'b01100011;
assign char[87][3]=8'b01101011;
assign char[87][4]=8'b01111111;
assign char[87][5]=8'b01110111;
assign char[87][6]=8'b01100011;
assign char[87][7]=8'b00000000;

assign char[88][0]=8'b00000000;
assign char[88][1]=8'b01100110;
assign char[88][2]=8'b01100110;
assign char[88][3]=8'b00111100;
assign char[88][4]=8'b00111100;
assign char[88][5]=8'b01100110;
assign char[88][6]=8'b01100110;
assign char[88][7]=8'b00000000;

assign char[89][0]=8'b00000000;
assign char[89][1]=8'b01100110;
assign char[89][2]=8'b01100110;
assign char[89][3]=8'b00111100;
assign char[89][4]=8'b00011000;
assign char[89][5]=8'b00011000;
assign char[89][6]=8'b00011000;
assign char[89][7]=8'b00000000;

assign char[90][0]=8'b00000000;
assign char[90][1]=8'b01111110;
assign char[90][2]=8'b00001100;
assign char[90][3]=8'b00011000;
assign char[90][4]=8'b00110000;
assign char[90][5]=8'b01100000;
assign char[90][6]=8'b01111110;
assign char[90][7]=8'b00000000;

assign char[91][0]=8'b00000000;
assign char[91][1]=8'b00011110;
assign char[91][2]=8'b00011000;
assign char[91][3]=8'b00011000;
assign char[91][4]=8'b00011000;
assign char[91][5]=8'b00011000;
assign char[91][6]=8'b00011110;
assign char[91][7]=8'b00000000;

assign char[92][0]=8'b00000000;
assign char[92][1]=8'b01000000;
assign char[92][2]=8'b01100000;
assign char[92][3]=8'b00110000;
assign char[92][4]=8'b00011000;
assign char[92][5]=8'b00001100;
assign char[92][6]=8'b00000110;
assign char[92][7]=8'b00000000;

assign char[93][0]=8'b00000000;
assign char[93][1]=8'b01111000;
assign char[93][2]=8'b00011000;
assign char[93][3]=8'b00011000;
assign char[93][4]=8'b00011000;
assign char[93][5]=8'b00011000;
assign char[93][6]=8'b01111000;
assign char[93][7]=8'b00000000;

assign char[94][0]=8'b00000000;
assign char[94][1]=8'b00001000;
assign char[94][2]=8'b00011100;
assign char[94][3]=8'b00110110;
assign char[94][4]=8'b01100011;
assign char[94][5]=8'b00000000;
assign char[94][6]=8'b00000000;
assign char[94][7]=8'b00000000;

assign char[95][0]=8'b00000000;
assign char[95][1]=8'b00000000;
assign char[95][2]=8'b00000000;
assign char[95][3]=8'b00000000;
assign char[95][4]=8'b00000000;
assign char[95][5]=8'b00000000;
assign char[95][6]=8'b11111111;
assign char[95][7]=8'b00000000;

assign char[96][0]=8'b00000000;
assign char[96][1]=8'b00011000;
assign char[96][2]=8'b00111100;
assign char[96][3]=8'b01111110;
assign char[96][4]=8'b01111110;
assign char[96][5]=8'b00111100;
assign char[96][6]=8'b00011000;
assign char[96][7]=8'b00000000;

assign char[97][0]=8'b00000000;
assign char[97][1]=8'b00000000;
assign char[97][2]=8'b00111100;
assign char[97][3]=8'b00000110;
assign char[97][4]=8'b00111110;
assign char[97][5]=8'b01100110;
assign char[97][6]=8'b00111110;
assign char[97][7]=8'b00000000;

assign char[98][0]=8'b00000000;
assign char[98][1]=8'b01100000;
assign char[98][2]=8'b01100000;
assign char[98][3]=8'b01111100;
assign char[98][4]=8'b01100110;
assign char[98][5]=8'b01100110;
assign char[98][6]=8'b01111100;
assign char[98][7]=8'b00000000;

assign char[99][0]=8'b00000000;
assign char[99][1]=8'b00000000;
assign char[99][2]=8'b00111100;
assign char[99][3]=8'b01100000;
assign char[99][4]=8'b01100000;
assign char[99][5]=8'b01100000;
assign char[99][6]=8'b00111100;
assign char[99][7]=8'b00000000;

assign char[100][0]=8'b00000000;
assign char[100][1]=8'b00000110;
assign char[100][2]=8'b00000110;
assign char[100][3]=8'b00111110;
assign char[100][4]=8'b01100110;
assign char[100][5]=8'b01100110;
assign char[100][6]=8'b00111110;
assign char[100][7]=8'b00000000;

assign char[101][0]=8'b00000000;
assign char[101][1]=8'b00000000;
assign char[101][2]=8'b00111100;
assign char[101][3]=8'b01100110;
assign char[101][4]=8'b01111110;
assign char[101][5]=8'b01100000;
assign char[101][6]=8'b00111100;
assign char[101][7]=8'b00000000;

assign char[102][0]=8'b00000000;
assign char[102][1]=8'b00001110;
assign char[102][2]=8'b00011000;
assign char[102][3]=8'b00111110;
assign char[102][4]=8'b00011000;
assign char[102][5]=8'b00011000;
assign char[102][6]=8'b00011000;
assign char[102][7]=8'b00000000;

assign char[103][0]=8'b00000000;
assign char[103][1]=8'b00000000;
assign char[103][2]=8'b00111110;
assign char[103][3]=8'b01100110;
assign char[103][4]=8'b01100110;
assign char[103][5]=8'b00111110;
assign char[103][6]=8'b00000110;
assign char[103][7]=8'b01111100;

assign char[104][0]=8'b00000000;
assign char[104][1]=8'b01100000;
assign char[104][2]=8'b01100000;
assign char[104][3]=8'b01111100;
assign char[104][4]=8'b01100110;
assign char[104][5]=8'b01100110;
assign char[104][6]=8'b01100110;
assign char[104][7]=8'b00000000;

assign char[105][0]=8'b00000000;
assign char[105][1]=8'b00011000;
assign char[105][2]=8'b00000000;
assign char[105][3]=8'b00111000;
assign char[105][4]=8'b00011000;
assign char[105][5]=8'b00011000;
assign char[105][6]=8'b00111100;
assign char[105][7]=8'b00000000;

assign char[106][0]=8'b00000000;
assign char[106][1]=8'b00000110;
assign char[106][2]=8'b00000000;
assign char[106][3]=8'b00000110;
assign char[106][4]=8'b00000110;
assign char[106][5]=8'b00000110;
assign char[106][6]=8'b00000110;
assign char[106][7]=8'b00111100;

assign char[107][0]=8'b00000000;
assign char[107][1]=8'b01100000;
assign char[107][2]=8'b01100000;
assign char[107][3]=8'b01101100;
assign char[107][4]=8'b01111000;
assign char[107][5]=8'b01101100;
assign char[107][6]=8'b01100110;
assign char[107][7]=8'b00000000;

assign char[108][0]=8'b00000000;
assign char[108][1]=8'b00111000;
assign char[108][2]=8'b00011000;
assign char[108][3]=8'b00011000;
assign char[108][4]=8'b00011000;
assign char[108][5]=8'b00011000;
assign char[108][6]=8'b00111100;
assign char[108][7]=8'b00000000;

assign char[109][0]=8'b00000000;
assign char[109][1]=8'b00000000;
assign char[109][2]=8'b01100110;
assign char[109][3]=8'b01111111;
assign char[109][4]=8'b01111111;
assign char[109][5]=8'b01101011;
assign char[109][6]=8'b01100011;
assign char[109][7]=8'b00000000;

assign char[110][0]=8'b00000000;
assign char[110][1]=8'b00000000;
assign char[110][2]=8'b01111100;
assign char[110][3]=8'b01100110;
assign char[110][4]=8'b01100110;
assign char[110][5]=8'b01100110;
assign char[110][6]=8'b01100110;
assign char[110][7]=8'b00000000;

assign char[111][0]=8'b00000000;
assign char[111][1]=8'b00000000;
assign char[111][2]=8'b00111100;
assign char[111][3]=8'b01100110;
assign char[111][4]=8'b01100110;
assign char[111][5]=8'b01100110;
assign char[111][6]=8'b00111100;
assign char[111][7]=8'b00000000;

assign char[112][0]=8'b00000000;
assign char[112][1]=8'b00000000;
assign char[112][2]=8'b01111100;
assign char[112][3]=8'b01100110;
assign char[112][4]=8'b01100110;
assign char[112][5]=8'b01111100;
assign char[112][6]=8'b01100000;
assign char[112][7]=8'b01100000;

assign char[113][0]=8'b00000000;
assign char[113][1]=8'b00000000;
assign char[113][2]=8'b00111110;
assign char[113][3]=8'b01100110;
assign char[113][4]=8'b01100110;
assign char[113][5]=8'b00111110;
assign char[113][6]=8'b00000110;
assign char[113][7]=8'b00000110;

assign char[114][0]=8'b00000000;
assign char[114][1]=8'b00000000;
assign char[114][2]=8'b01111100;
assign char[114][3]=8'b01100110;
assign char[114][4]=8'b01100000;
assign char[114][5]=8'b01100000;
assign char[114][6]=8'b01100000;
assign char[114][7]=8'b00000000;

assign char[115][0]=8'b00000000;
assign char[115][1]=8'b00000000;
assign char[115][2]=8'b00111110;
assign char[115][3]=8'b01100000;
assign char[115][4]=8'b00111100;
assign char[115][5]=8'b00000110;
assign char[115][6]=8'b01111100;
assign char[115][7]=8'b00000000;

assign char[116][0]=8'b00000000;
assign char[116][1]=8'b00011000;
assign char[116][2]=8'b01111110;
assign char[116][3]=8'b00011000;
assign char[116][4]=8'b00011000;
assign char[116][5]=8'b00011000;
assign char[116][6]=8'b00001110;
assign char[116][7]=8'b00000000;

assign char[117][0]=8'b00000000;
assign char[117][1]=8'b00000000;
assign char[117][2]=8'b01100110;
assign char[117][3]=8'b01100110;
assign char[117][4]=8'b01100110;
assign char[117][5]=8'b01100110;
assign char[117][6]=8'b00111110;
assign char[117][7]=8'b00000000;

assign char[118][0]=8'b00000000;
assign char[118][1]=8'b00000000;
assign char[118][2]=8'b01100110;
assign char[118][3]=8'b01100110;
assign char[118][4]=8'b01100110;
assign char[118][5]=8'b00111100;
assign char[118][6]=8'b00011000;
assign char[118][7]=8'b00000000;

assign char[119][0]=8'b00000000;
assign char[119][1]=8'b00000000;
assign char[119][2]=8'b01100011;
assign char[119][3]=8'b01101011;
assign char[119][4]=8'b01111111;
assign char[119][5]=8'b00111110;
assign char[119][6]=8'b00110110;
assign char[119][7]=8'b00000000;

assign char[120][0]=8'b00000000;
assign char[120][1]=8'b00000000;
assign char[120][2]=8'b01100110;
assign char[120][3]=8'b00111100;
assign char[120][4]=8'b00011000;
assign char[120][5]=8'b00111100;
assign char[120][6]=8'b01100110;
assign char[120][7]=8'b00000000;

assign char[121][0]=8'b00000000;
assign char[121][1]=8'b00000000;
assign char[121][2]=8'b01100110;
assign char[121][3]=8'b01100110;
assign char[121][4]=8'b01100110;
assign char[121][5]=8'b00111110;
assign char[121][6]=8'b00001100;
assign char[121][7]=8'b01111000;

assign char[122][0]=8'b00000000;
assign char[122][1]=8'b00000000;
assign char[122][2]=8'b01111110;
assign char[122][3]=8'b00001100;
assign char[122][4]=8'b00011000;
assign char[122][5]=8'b00110000;
assign char[122][6]=8'b01111110;
assign char[122][7]=8'b00000000;

assign char[123][0]=8'b00000000;
assign char[123][1]=8'b00011000;
assign char[123][2]=8'b00111100;
assign char[123][3]=8'b01111110;
assign char[123][4]=8'b01111110;
assign char[123][5]=8'b00011000;
assign char[123][6]=8'b00111100;
assign char[123][7]=8'b00000000;

assign char[124][0]=8'b00011000;
assign char[124][1]=8'b00011000;
assign char[124][2]=8'b00011000;
assign char[124][3]=8'b00011000;
assign char[124][4]=8'b00011000;
assign char[124][5]=8'b00011000;
assign char[124][6]=8'b00011000;
assign char[124][7]=8'b00011000;

assign char[125][0]=8'b00000000;
assign char[125][1]=8'b01111110;
assign char[125][2]=8'b01111000;
assign char[125][3]=8'b01111100;
assign char[125][4]=8'b01101110;
assign char[125][5]=8'b01100110;
assign char[125][6]=8'b00000110;
assign char[125][7]=8'b00000000;

assign char[126][0]=8'b00001000;
assign char[126][1]=8'b00011000;
assign char[126][2]=8'b00111000;
assign char[126][3]=8'b01111000;
assign char[126][4]=8'b00111000;
assign char[126][5]=8'b00011000;
assign char[126][6]=8'b00001000;
assign char[126][7]=8'b00000000;

assign char[127][0]=8'b00010000;
assign char[127][1]=8'b00011000;
assign char[127][2]=8'b00011100;
assign char[127][3]=8'b00011110;
assign char[127][4]=8'b00011100;
assign char[127][5]=8'b00011000;
assign char[127][6]=8'b00010000;
assign char[127][7]=8'b00000000;

endmodule

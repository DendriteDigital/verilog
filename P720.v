
`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
//       Company: Dendrite Digital
//      Engineer: Gregory Scott Callen
//
//   Create Date: 19:26:19 10/06/2020
//   Design Name: P720
//   Module Name: E:/private/P720/TestP720.v
//  Project Name: P720
// Target Device: Nexys 4 (Limited Edition) Artix 7 100T
// Tool versions: Vivado 2019.2
//
//  Dependencies: 100 MHz Clock Input and 12-bit VGA Output
//
//      Revision: 0.01 - File Created
//      Revision: 0.02 - Moved from ISE to Vivado
//
////////////////////////////////////////////////////////////////////////////////

//`define DEBUG

`ifdef DEBUG
module TestP720;

	// Inputs
	reg clk;

	// Outputs
	wire MHz74;
	wire [11:0] hCount;
	wire [11:0] vCount;
	wire [11:0] x;
	wire [11:0] y;
	wire memw;
	wire [14:0] mema;
	wire [31:0] memi;
	wire [31:0] memo;
	wire [3:0] vgaRed;
	wire [3:0] vgaGreen;
	wire [3:0] vgaBlue;
	wire Hsync;
	wire Vsync;

	// Instantiate the Unit Under Test (UUT)
	P720 uut (
		.clk(clk),
		.MHz74(MHz74),
		.hCount(hCount),
		.vCount(vCount),
		.x(x),
		.y(y),
		.memw(memw),
		.mema(mema),
		.memi(memi),
		.memo(memo),
		.vgaRed(vgaRed),
		.vgaGreen(vgaGreen),
		.vgaBlue(vgaBlue),
		.Hsync(Hsync),
		.Vsync(Vsync)
	);

	initial begin
		// Initialize Inputs
		clk = 0;

		// Wait 100 ns for global reset to finish
		#100;

		// Add stimulus here

	end

	always clk=#10~clk;

endmodule
`endif

`define hva 1280
`define hfp 110
`define hsw 40
`define hbp 220
`define htb 370
`define htp 1650
`define hsp 1'd1

`define vva 720
`define vfp 5
`define vsw 5
`define vbp 20
`define vtb 30
`define vtl 750
`define vsp 1'd1

module P720(
	input  wire        clk,
`ifdef DEBUG
	output wire        MHz74,
	output reg  [11:0] hCount,
	output reg  [11:0] vCount,
	output wire [11:0] x,
	output wire [11:0] y,
	output reg         memw,
	output reg  [14:0] mema,
	output reg  [31:0] memi,
	output wire [31:0] memo,
`endif
	output wire [ 3:0] vgaRed,
	output wire [ 3:0] vgaGreen,
	output wire [ 3:0] vgaBlue,
	output reg         Hsync,
	output reg         Vsync
);

`ifndef DEBUG
	wire        MHz74;
	reg  [10:0] hCount;
	reg  [ 9:0] vCount;
	wire [11:0] y;
	wire [11:0] x;
	reg         memw;
	reg  [14:0] mema;
	reg  [31:0] memi;
	wire [31:0] memo;
`endif

	reg [ 7:0] locb;
	reg [11:0] color;
	reg [11:0] off;
	reg [11:0] on;
	reg [23:0] temp;

	wire [ 3:0] hex;
	wire [ 3:0] i;

	assign x        = hCount-11'd`htb+11'd4;
	assign y        = vCount-10'd`vtb-10'd4;
	assign vgaRed   = color[11:8];
	assign vgaGreen = color[7:4];
	assign vgaBlue  = color[3:0];

	timer clock(MHz74,clk); // 74.25 MHz

	wire [31:0] chro;
	reg  [ 7:0] chra;
	ChrSet acs(~MHz74,chra,chro);

	wire [31:0] ramo;
	wire [31:0] rami; assign rami=memi;
	wire [13:0] rama; assign rama=mema[13:0];
	wire        ramw; assign ramw=(mema[14]==1'd0)?memw:1'd1;
	VRAM ram(~MHz74,ramw,rama,rami,ramo);

	assign memo=(mema[14]==1'd1)?chro:ramo;

	wire [ 2:0] col;assign col = x[2:0];
	wire [ 2:0] row;assign row = y[2:0];
	wire [ 7:0] pixels;
	reg  [31:0] data;
	locByte loc(data,row[1:0],pixels);

	wire [ 7:0] myByte;
	mySixBits msb(y[6:3]^x[6:3]|6'd0,myByte);

	initial begin
		memw  <=0;
		mema  <=~15'd0;
		memi  <=32'hFFF00800;
		data  <=32'd0;
		temp  <=32'd0;
		color <=12'd0;
		on    <=12'hFFF;
		off   <=12'h009;
		hCount<=10'd360;
		vCount<=9'd30;
		Hsync <=1'd0;
		Vsync <=1'd0;
	end

	always @ (posedge MHz74) begin
		if(memw==1)begin
			if((hCount>`hfp)&&(hCount<=`hfp+`hsw))begin
				Hsync<=`hsp;
			end else begin
				Hsync<=~`hsp;
			end
			if((vCount>`vfp)&&(vCount<=`vfp+`vsw))begin
				Vsync<=`vsp;
			end else begin
				Vsync<=~`vsp;
			end
			if(x==`hva-1)begin
				hCount<=11'd1;
				vCount<=vCount+10'd1;
			end else begin
				hCount<=hCount+11'd1;
			end
			if(y==`vva-1)begin
				vCount<=10'd1;
			end
			if((x>=`hva)||(y>=`vva))begin
				color<=12'd0;
			end else begin
				color<=pixels[~col]?on:off;
				`ifdef DEBUG
					$display("\npixel clock=%1d",col);
					$display("hCount=%4d    x=%4d",hCount,x);
					$display("vCount=%4d    y=%4d",vCount,y);
					$display("pixels=%8h",pixels);
					$display("    on=%3h",    on);
					$display("   off=%3h",   off);
				`endif
			end
			if(x[2:0]==5)begin
				mema<=(y[9:3]<<7)+(y[9:3]<<5)+x[11:3]+15'd1;
			end else if(x[2:0]==6)begin
				temp<=memo[31:8];
				chra<=(memo[6:0]<<1)|y[2];
				`ifdef DEBUG
					$display("\npixel clock = 6");
					$display("mema = %4h",mema);
					$display("memo = %8h",memo);
					$strobe ("chra = %2h",chra>>1);
				`endif
			end else if(x[2:0]==7)begin
				data<=chro;
				on  <=temp[23:12];
				off <=temp[11: 0];
				`ifdef DEBUG
					if(x[2:0]==0)begin
						$display("\npixel clock = 7");
						$display("mema = %4h",mema);
						$display("chro = %8h",chro);
						$display("  on = %3h",temp[23:12]);
						$display(" off = %3h",temp[11: 0]);
					end
				`endif
			end
			`ifdef DEBUG
				if((x==32)&&(y==0))begin
					$finish;
				end
			`endif
		end else begin
			mema<=mema+15'd1;
			chra<=(mema[6:0]<<1)+8'd2;
			if(mema!=15'h7FFF)begin
				if(mema<15'h3F00)begin
					memi<=((memi+32'h00700300)|mema[7:0])+32'd1;
				end else begin
					memi<=chro;
				end
			end
			if(mema==15'h4000)begin
				memw<=1'd1;
				mema<=0;
				`ifdef DEBUG
					$strobe("\n");
					$strobe("initialize memw=%1b mema=%5h memi=%8h memo=%8h",memw,mema,memi,memo);
				`endif
			end
		end
	end
endmodule

module mySixBits(
	input  wire [5:0] chra,
	output wire [7:0] chro
);

	wire [7:0] myByte [63:0];

	assign chro = myByte[chra];

	assign myByte[ 0]=8'd48 ;    // 0
	assign myByte[ 1]=8'd49 ;    // 1
	assign myByte[ 2]=8'd50 ;    // 2
	assign myByte[ 3]=8'd51 ;    // 3
	assign myByte[ 4]=8'd52 ;    // 4
	assign myByte[ 5]=8'd53 ;    // 5
	assign myByte[ 6]=8'd54 ;    // 6
	assign myByte[ 7]=8'd55 ;    // 7
	assign myByte[ 8]=8'd56 ;    // 8
	assign myByte[ 9]=8'd57 ;    // 9
	assign myByte[10]=8'd65 ;    // A
	assign myByte[11]=8'd66 ;    // B
	assign myByte[12]=8'd67 ;    // C
	assign myByte[13]=8'd68 ;    // D
	assign myByte[14]=8'd69 ;    // E
	assign myByte[15]=8'd70 ;    // F
	assign myByte[16]=8'd71 ;    // G
	assign myByte[17]=8'd72 ;    // H
	assign myByte[18]=8'd73 ;    // I
	assign myByte[19]=8'd74 ;    // J
	assign myByte[20]=8'd75 ;    // K
	assign myByte[21]=8'd76 ;    // L
	assign myByte[22]=8'd77 ;    // M
	assign myByte[23]=8'd78 ;    // N
	assign myByte[24]=8'd79 ;    // O
	assign myByte[25]=8'd80 ;    // P
	assign myByte[26]=8'd81 ;    // Q
	assign myByte[27]=8'd82 ;    // R
	assign myByte[28]=8'd83 ;    // S
	assign myByte[29]=8'd84 ;    // T
	assign myByte[30]=8'd85 ;    // U
	assign myByte[31]=8'd86 ;    // V
	assign myByte[32]=8'd87 ;    // W
	assign myByte[33]=8'd88 ;    // X
	assign myByte[34]=8'd89 ;    // Y
	assign myByte[35]=8'd90 ;    // Z
	assign myByte[36]=8'd97 ;    // a
	assign myByte[37]=8'd98 ;    // b
	assign myByte[38]=8'd99 ;    // c
	assign myByte[39]=8'd100;    // d
	assign myByte[40]=8'd101;    // e
	assign myByte[41]=8'd102;    // f
	assign myByte[42]=8'd103;    // g
	assign myByte[43]=8'd104;    // h
	assign myByte[44]=8'd105;    // i
	assign myByte[45]=8'd106;    // j
	assign myByte[46]=8'd107;    // k
	assign myByte[47]=8'd108;    // l
	assign myByte[48]=8'd109;    // m
	assign myByte[49]=8'd110;    // n
	assign myByte[50]=8'd111;    // o
	assign myByte[51]=8'd112;    // p
	assign myByte[52]=8'd113;    // q
	assign myByte[53]=8'd114;    // r
	assign myByte[54]=8'd115;    // s
	assign myByte[55]=8'd116;    // t
	assign myByte[56]=8'd117;    // u
	assign myByte[57]=8'd118;    // v
	assign myByte[58]=8'd119;    // w
	assign myByte[59]=8'd120;    // x
	assign myByte[60]=8'd121;    // y
	assign myByte[61]=8'd122;    // z
	assign myByte[62]=8'd46 ;    // .
	assign myByte[63]=8'd32 ;    // space

endmodule

module locByte(
	input		wire [31:0]	l,
	input 	wire [ 1:0] s,
	output	wire [ 7:0] b
);
	wire[7:0]lbytes[3:0];

	assign lbytes[0]=l[31:24];
	assign lbytes[1]=l[23:16];
	assign lbytes[2]=l[15: 8];
	assign lbytes[3]=l[ 7: 0];

	assign b=lbytes[s];

endmodule

module VRAM(
    input  wire        memc,
    input  wire        memw,
    input  wire [13:0] mema,
    input  wire [31:0] memi,
    output reg  [31:0] memo
);

	reg  [31:0] ram [16383:0];

	initial begin
		memo<=32'd0;
	end

	always @ (posedge memc) begin
		if(memw==1'd0)begin
			ram[mema]<=memi;
		end else begin
			memo<=ram[mema];
		end
	end

endmodule

module ChrSet(
	input  wire        chrc,
	input  wire [ 7:0] chra,
	output reg  [31:0] chro
);

	wire[31:0]rom[255:0];

	initial begin
		chro<=32'd0;
	end

	always@(posedge chrc)begin
		chro<=rom[chra];
	end

assign rom[  0]={8'b00000000,
                 8'b00110110,
                 8'b01111111,
                 8'b01111111};
assign rom[  1]={8'b00111110,
                 8'b00011100,
                 8'b00001000,
                 8'b00000000};

assign rom[  2]={8'b00011000,
                 8'b00011000,
                 8'b00011000,
                 8'b00011111};
assign rom[  3]={8'b00011111,
                 8'b00011000,
                 8'b00011000,
                 8'b00011000};

assign rom[  4]={8'b00000011,
                 8'b00000011,
                 8'b00000011,
                 8'b00000011};
assign rom[  5]={8'b00000011,
                 8'b00000011,
                 8'b00000011,
                 8'b00000011};

assign rom[  6]={8'b00011000,
                 8'b00011000,
                 8'b00011000,
                 8'b11111000};
assign rom[  7]={8'b11111000,
                 8'b00000000,
                 8'b00000000,
                 8'b00000000};

assign rom[  8]={8'b00011000,
                 8'b00011000,
                 8'b00011000,
                 8'b11111000};
assign rom[  9]={8'b11111000,
                 8'b00011000,
                 8'b00011000,
                 8'b00011000};

assign rom[ 10]={8'b00000000,
                 8'b00000000,
                 8'b00000000,
                 8'b11111000};
assign rom[ 11]={8'b11111000,
                 8'b00011000,
                 8'b00011000,
                 8'b00011000};

assign rom[ 12]={8'b00000011,
                 8'b00000111,
                 8'b00001110,
                 8'b00011100};
assign rom[ 13]={8'b00111000,
                 8'b01110000,
                 8'b11100000,
                 8'b11000000};

assign rom[ 14]={8'b11000000,
                 8'b11100000,
                 8'b01110000,
                 8'b00111000};
assign rom[ 15]={8'b00011100,
                 8'b00001110,
                 8'b00000111,
                 8'b00000011};

assign rom[ 16]={8'b00000001,
                 8'b00000011,
                 8'b00000111,
                 8'b00001111};
assign rom[ 17]={8'b00011111,
                 8'b00111111,
                 8'b01111111,
                 8'b11111111};

assign rom[ 18]={8'b00000000,
                 8'b00000000,
                 8'b00000000,
                 8'b00000000};
assign rom[ 19]={8'b00001111,
                 8'b00001111,
                 8'b00001111,
                 8'b00001111};

assign rom[ 20]={8'b10000000,
                 8'b11000000,
                 8'b11100000,
                 8'b11110000};
assign rom[ 21]={8'b11111000,
                 8'b11111100,
                 8'b11111110,
                 8'b11111111};

assign rom[ 22]={8'b00001111,
                 8'b00001111,
                 8'b00001111,
                 8'b00001111};
assign rom[ 23]={8'b00000000,
                 8'b00000000,
                 8'b00000000,
                 8'b00000000};

assign rom[ 24]={8'b11110000,
                 8'b11110000,
                 8'b11110000,
                 8'b11110000};
assign rom[ 25]={8'b00000000,
                 8'b00000000,
                 8'b00000000,
                 8'b00000000};

assign rom[ 26]={8'b11111111,
                 8'b11111111,
                 8'b00000000,
                 8'b00000000};
assign rom[ 27]={8'b00000000,
                 8'b00000000,
                 8'b00000000,
                 8'b00000000};

assign rom[ 28]={8'b00000000,
                 8'b00000000,
                 8'b00000000,
                 8'b00000000};
assign rom[ 29]={8'b00000000,
                 8'b00000000,
                 8'b11111111,
                 8'b11111111};

assign rom[ 30]={8'b00000000,
                 8'b00000000,
                 8'b00000000,
                 8'b00000000};
assign rom[ 31]={8'b11110000,
                 8'b11110000,
                 8'b11110000,
                 8'b11110000};

assign rom[ 32]={8'b00000000,
                 8'b00011100,
                 8'b00011100,
                 8'b01110111};
assign rom[ 33]={8'b01110111,
                 8'b00001000,
                 8'b00011100,
                 8'b00000000};

assign rom[ 34]={8'b00000000,
                 8'b00000000,
                 8'b00000000,
                 8'b00011111};
assign rom[ 35]={8'b00011111,
                 8'b00011000,
                 8'b00011000,
                 8'b00011000};

assign rom[ 36]={8'b00000000,
                 8'b00000000,
                 8'b00000000,
                 8'b11111111};
assign rom[ 37]={8'b11111111,
                 8'b00000000,
                 8'b00000000,
                 8'b00000000};

assign rom[ 38]={8'b00011000,
                 8'b00011000,
                 8'b00011000,
                 8'b11111111};
assign rom[ 39]={8'b11111111,
                 8'b00011000,
                 8'b00011000,
                 8'b00011000};

assign rom[ 40]={8'b00000000,
                 8'b00000000,
                 8'b00111100,
                 8'b01111110};
assign rom[ 41]={8'b01111110,
                 8'b01111110,
                 8'b00111100,
                 8'b00000000};

assign rom[ 42]={8'b00000000,
                 8'b00000000,
                 8'b00000000,
                 8'b00000000};
assign rom[ 43]={8'b11111111,
                 8'b11111111,
                 8'b11111111,
                 8'b11111111};

assign rom[ 44]={8'b11000000,
                 8'b11000000,
                 8'b11000000,
                 8'b11000000};
assign rom[ 45]={8'b11000000,
                 8'b11000000,
                 8'b11000000,
                 8'b11000000};

assign rom[ 46]={8'b00000000,
                 8'b00000000,
                 8'b00000000,
                 8'b11111111};
assign rom[ 47]={8'b11111111,
                 8'b00011000,
                 8'b00011000,
                 8'b00011000};

assign rom[ 48]={8'b00011000,
                 8'b00011000,
                 8'b00011000,
                 8'b11111111};
assign rom[ 49]={8'b11111111,
                 8'b00000000,
                 8'b00000000,
                 8'b00000000};

assign rom[ 50]={8'b11110000,
                 8'b11110000,
                 8'b11110000,
                 8'b11110000};
assign rom[ 51]={8'b11110000,
                 8'b11110000,
                 8'b11110000,
                 8'b11110000};

assign rom[ 52]={8'b00011000,
                 8'b00011000,
                 8'b00011000,
                 8'b00011111};
assign rom[ 53]={8'b00011111,
                 8'b00000000,
                 8'b00000000,
                 8'b00000000};

assign rom[ 54]={8'b01111000,
                 8'b01100000,
                 8'b01111000,
                 8'b01100000};
assign rom[ 55]={8'b01111110,
                 8'b00011000,
                 8'b00011110,
                 8'b00000000};

assign rom[ 56]={8'b00000000,
                 8'b00011000,
                 8'b00111100,
                 8'b01111110};
assign rom[ 57]={8'b00011000,
                 8'b00011000,
                 8'b00011000,
                 8'b00000000};

assign rom[ 58]={8'b00000000,
                 8'b00011000,
                 8'b00011000,
                 8'b00011000};
assign rom[ 59]={8'b01111110,
                 8'b00111100,
                 8'b00011000,
                 8'b00000000};

assign rom[ 60]={8'b00000000,
                 8'b00011000,
                 8'b00110000,
                 8'b01111110};
assign rom[ 61]={8'b00110000,
                 8'b00011000,
                 8'b00000000,
                 8'b00000000};

assign rom[ 62]={8'b00000000,
                 8'b00011000,
                 8'b00001100,
                 8'b01111110};
assign rom[ 63]={8'b00001100,
                 8'b00011000,
                 8'b00000000,
                 8'b00000000};

assign rom[ 64]={8'b00000000,
                 8'b00000000,
                 8'b00000000,
                 8'b00000000};
assign rom[ 65]={8'b00000000,
                 8'b00000000,
                 8'b00000000,
                 8'b00000000};

assign rom[ 66]={8'b00000000,
                 8'b00011000,
                 8'b00011000,
                 8'b00011000};
assign rom[ 67]={8'b00011000,
                 8'b00000000,
                 8'b00011000,
                 8'b00000000};

assign rom[ 68]={8'b00000000,
                 8'b01100110,
                 8'b01100110,
                 8'b01100110};
assign rom[ 69]={8'b00000000,
                 8'b00000000,
                 8'b00000000,
                 8'b00000000};

assign rom[ 70]={8'b00000000,
                 8'b01100110,
                 8'b11111111,
                 8'b01100110};
assign rom[ 71]={8'b01100110,
                 8'b11111111,
                 8'b01100110,
                 8'b00000000};

assign rom[ 72]={8'b00011000,
                 8'b00111110,
                 8'b01100000,
                 8'b00111100};
assign rom[ 73]={8'b00000110,
                 8'b01111100,
                 8'b00011000,
                 8'b00000000};

assign rom[ 74]={8'b00000000,
                 8'b01100110,
                 8'b01101100,
                 8'b00011000};
assign rom[ 75]={8'b00110000,
                 8'b01100110,
                 8'b01000110,
                 8'b00000000};

assign rom[ 76]={8'b00011100,
                 8'b00110110,
                 8'b00011100,
                 8'b00111000};
assign rom[ 77]={8'b01101111,
                 8'b01100110,
                 8'b00111011,
                 8'b00000000};

assign rom[ 78]={8'b00000000,
                 8'b00011000,
                 8'b00011000,
                 8'b00011000};
assign rom[ 79]={8'b00000000,
                 8'b00000000,
                 8'b00000000,
                 8'b00000000};

assign rom[ 80]={8'b00000000,
                 8'b00001110,
                 8'b00011100,
                 8'b00011000};
assign rom[ 81]={8'b00011000,
                 8'b00011100,
                 8'b00001110,
                 8'b00000000};

assign rom[ 82]={8'b00000000,
                 8'b01110000,
                 8'b00111000,
                 8'b00011000};
assign rom[ 83]={8'b00011000,
                 8'b00111000,
                 8'b01110000,
                 8'b00000000};

assign rom[ 84]={8'b00000000,
                 8'b01100110,
                 8'b00111100,
                 8'b11111111};
assign rom[ 85]={8'b00111100,
                 8'b01100110,
                 8'b00000000,
                 8'b00000000};

assign rom[ 86]={8'b00000000,
                 8'b00011000,
                 8'b00011000,
                 8'b01111110};
assign rom[ 87]={8'b00011000,
                 8'b00011000,
                 8'b00000000,
                 8'b00000000};

assign rom[ 88]={8'b00000000,
                 8'b00000000,
                 8'b00000000,
                 8'b00000000};
assign rom[ 89]={8'b00000000,
                 8'b00011000,
                 8'b00011000,
                 8'b00110000};

assign rom[ 90]={8'b00000000,
                 8'b00000000,
                 8'b00000000,
                 8'b01111110};
assign rom[ 91]={8'b00000000,
                 8'b00000000,
                 8'b00000000,
                 8'b00000000};

assign rom[ 92]={8'b00000000,
                 8'b00000000,
                 8'b00000000,
                 8'b00000000};
assign rom[ 93]={8'b00000000,
                 8'b00011000,
                 8'b00011000,
                 8'b00000000};

assign rom[ 94]={8'b00000000,
                 8'b00000110,
                 8'b00001100,
                 8'b00011000};
assign rom[ 95]={8'b00110000,
                 8'b01100000,
                 8'b01000000,
                 8'b00000000};

assign rom[ 96]={8'b00000000,
                 8'b00111100,
                 8'b01100110,
                 8'b01101110};
assign rom[ 97]={8'b01110110,
                 8'b01100110,
                 8'b00111100,
                 8'b00000000};

assign rom[ 98]={8'b00000000,
                 8'b00011000,
                 8'b00111000,
                 8'b00011000};
assign rom[ 99]={8'b00011000,
                 8'b00011000,
                 8'b01111110,
                 8'b00000000};

assign rom[100]={8'b00000000,
                 8'b00111100,
                 8'b01100110,
                 8'b00001100};
assign rom[101]={8'b00011000,
                 8'b00110000,
                 8'b01111110,
                 8'b00000000};

assign rom[102]={8'b00000000,
                 8'b01111110,
                 8'b00001100,
                 8'b00011000};
assign rom[103]={8'b00001100,
                 8'b01100110,
                 8'b00111100,
                 8'b00000000};

assign rom[104]={8'b00000000,
                 8'b00001100,
                 8'b00011100,
                 8'b00111100};
assign rom[105]={8'b01101100,
                 8'b01111110,
                 8'b00001100,
                 8'b00000000};

assign rom[106]={8'b00000000,
                 8'b01111110,
                 8'b01100000,
                 8'b01111100};
assign rom[107]={8'b00000110,
                 8'b01100110,
                 8'b00111100,
                 8'b00000000};

assign rom[108]={8'b00000000,
                 8'b00111100,
                 8'b01100000,
                 8'b01111100};
assign rom[109]={8'b01100110,
                 8'b01100110,
                 8'b00111100,
                 8'b00000000};

assign rom[110]={8'b00000000,
                 8'b01111110,
                 8'b00000110,
                 8'b00001100};
assign rom[111]={8'b00011000,
                 8'b00110000,
                 8'b00110000,
                 8'b00000000};

assign rom[112]={8'b00000000,
                 8'b00111100,
                 8'b01100110,
                 8'b00111100};
assign rom[113]={8'b01100110,
                 8'b01100110,
                 8'b00111100,
                 8'b00000000};

assign rom[114]={8'b00000000,
                 8'b00111100,
                 8'b01100110,
                 8'b00111110};
assign rom[115]={8'b00000110,
                 8'b00001100,
                 8'b00111000,
                 8'b00000000};

assign rom[116]={8'b00000000,
                 8'b00000000,
                 8'b00011000,
                 8'b00011000};
assign rom[117]={8'b00000000,
                 8'b00011000,
                 8'b00011000,
                 8'b00000000};

assign rom[118]={8'b00000000,
                 8'b00000000,
                 8'b00011000,
                 8'b00011000};
assign rom[119]={8'b00000000,
                 8'b00011000,
                 8'b00011000,
                 8'b00110000};

assign rom[120]={8'b00000110,
                 8'b00001100,
                 8'b00011000,
                 8'b00110000};
assign rom[121]={8'b00011000,
                 8'b00001100,
                 8'b00000110,
                 8'b00000000};

assign rom[122]={8'b00000000,
                 8'b00000000,
                 8'b01111110,
                 8'b00000000};
assign rom[123]={8'b00000000,
                 8'b01111110,
                 8'b00000000,
                 8'b00000000};

assign rom[124]={8'b01100000,
                 8'b00110000,
                 8'b00011000,
                 8'b00001100};
assign rom[125]={8'b00011000,
                 8'b00110000,
                 8'b01100000,
                 8'b00000000};

assign rom[126]={8'b00000000,
                 8'b00111100,
                 8'b01100110,
                 8'b00001100};
assign rom[127]={8'b00011000,
                 8'b00000000,
                 8'b00011000,
                 8'b00000000};

assign rom[128]={8'b00000000,
                 8'b00111100,
                 8'b01100110,
                 8'b01101110};
assign rom[129]={8'b01101110,
                 8'b01100000,
                 8'b00111110,
                 8'b00000000};

assign rom[130]={8'b00000000,
                 8'b00011000,
                 8'b00111100,
                 8'b01100110};
assign rom[131]={8'b01100110,
                 8'b01111110,
                 8'b01100110,
                 8'b00000000};

assign rom[132]={8'b00000000,
                 8'b01111100,
                 8'b01100110,
                 8'b01111100};
assign rom[133]={8'b01100110,
                 8'b01100110,
                 8'b01111100,
                 8'b00000000};

assign rom[134]={8'b00000000,
                 8'b00111100,
                 8'b01100110,
                 8'b01100000};
assign rom[135]={8'b01100000,
                 8'b01100110,
                 8'b00111100,
                 8'b00000000};

assign rom[136]={8'b00000000,
                 8'b01111000,
                 8'b01101100,
                 8'b01100110};
assign rom[137]={8'b01100110,
                 8'b01101100,
                 8'b01111000,
                 8'b00000000};

assign rom[138]={8'b00000000,
                 8'b01111110,
                 8'b01100000,
                 8'b01111100};
assign rom[139]={8'b01100000,
                 8'b01100000,
                 8'b01111110,
                 8'b00000000};

assign rom[140]={8'b00000000,
                 8'b01111110,
                 8'b01100000,
                 8'b01111100};
assign rom[141]={8'b01100000,
                 8'b01100000,
                 8'b01100000,
                 8'b00000000};

assign rom[142]={8'b00000000,
                 8'b00111110,
                 8'b01100000,
                 8'b01100000};
assign rom[143]={8'b01101110,
                 8'b01100110,
                 8'b00111110,
                 8'b00000000};

assign rom[144]={8'b00000000,
                 8'b01100110,
                 8'b01100110,
                 8'b01111110};
assign rom[145]={8'b01100110,
                 8'b01100110,
                 8'b01100110,
                 8'b00000000};

assign rom[146]={8'b00000000,
                 8'b01111110,
                 8'b00011000,
                 8'b00011000};
assign rom[147]={8'b00011000,
                 8'b00011000,
                 8'b01111110,
                 8'b00000000};

assign rom[148]={8'b00000000,
                 8'b00000110,
                 8'b00000110,
                 8'b00000110};
assign rom[149]={8'b00000110,
                 8'b01100110,
                 8'b00111100,
                 8'b00000000};

assign rom[150]={8'b00000000,
                 8'b01100110,
                 8'b01101100,
                 8'b01111000};
assign rom[151]={8'b01111000,
                 8'b01101100,
                 8'b01100110,
                 8'b00000000};

assign rom[152]={8'b00000000,
                 8'b01100000,
                 8'b01100000,
                 8'b01100000};
assign rom[153]={8'b01100000,
                 8'b01100000,
                 8'b01111110,
                 8'b00000000};

assign rom[154]={8'b00000000,
                 8'b01100011,
                 8'b01110111,
                 8'b01111111};
assign rom[155]={8'b01101011,
                 8'b01100011,
                 8'b01100011,
                 8'b00000000};

assign rom[156]={8'b00000000,
                 8'b01100110,
                 8'b01110110,
                 8'b01111110};
assign rom[157]={8'b01111110,
                 8'b01101110,
                 8'b01100110,
                 8'b00000000};

assign rom[158]={8'b00000000,
                 8'b00111100,
                 8'b01100110,
                 8'b01100110};
assign rom[159]={8'b01100110,
                 8'b01100110,
                 8'b00111100,
                 8'b00000000};

assign rom[160]={8'b00000000,
                 8'b01111100,
                 8'b01100110,
                 8'b01100110};
assign rom[161]={8'b01111100,
                 8'b01100000,
                 8'b01100000,
                 8'b00000000};

assign rom[162]={8'b00000000,
                 8'b00111100,
                 8'b01100110,
                 8'b01100110};
assign rom[163]={8'b01100110,
                 8'b01101100,
                 8'b00110110,
                 8'b00000000};

assign rom[164]={8'b00000000,
                 8'b01111100,
                 8'b01100110,
                 8'b01100110};
assign rom[165]={8'b01111100,
                 8'b01101100,
                 8'b01100110,
                 8'b00000000};

assign rom[166]={8'b00000000,
                 8'b00111100,
                 8'b01100000,
                 8'b00111100};
assign rom[167]={8'b00000110,
                 8'b00000110,
                 8'b00111100,
                 8'b00000000};

assign rom[168]={8'b00000000,
                 8'b01111110,
                 8'b00011000,
                 8'b00011000};
assign rom[169]={8'b00011000,
                 8'b00011000,
                 8'b00011000,
                 8'b00000000};

assign rom[170]={8'b00000000,
                 8'b01100110,
                 8'b01100110,
                 8'b01100110};
assign rom[171]={8'b01100110,
                 8'b01100110,
                 8'b01111110,
                 8'b00000000};

assign rom[172]={8'b00000000,
                 8'b01100110,
                 8'b01100110,
                 8'b01100110};
assign rom[173]={8'b01100110,
                 8'b00111100,
                 8'b00011000,
                 8'b00000000};

assign rom[174]={8'b00000000,
                 8'b01100011,
                 8'b01100011,
                 8'b01101011};
assign rom[175]={8'b01111111,
                 8'b01110111,
                 8'b01100011,
                 8'b00000000};

assign rom[176]={8'b00000000,
                 8'b01100110,
                 8'b01100110,
                 8'b00111100};
assign rom[177]={8'b00111100,
                 8'b01100110,
                 8'b01100110,
                 8'b00000000};

assign rom[178]={8'b00000000,
                 8'b01100110,
                 8'b01100110,
                 8'b00111100};
assign rom[179]={8'b00011000,
                 8'b00011000,
                 8'b00011000,
                 8'b00000000};

assign rom[180]={8'b00000000,
                 8'b01111110,
                 8'b00001100,
                 8'b00011000};
assign rom[181]={8'b00110000,
                 8'b01100000,
                 8'b01111110,
                 8'b00000000};

assign rom[182]={8'b00000000,
                 8'b00011110,
                 8'b00011000,
                 8'b00011000};
assign rom[183]={8'b00011000,
                 8'b00011000,
                 8'b00011110,
                 8'b00000000};

assign rom[184]={8'b00000000,
                 8'b01000000,
                 8'b01100000,
                 8'b00110000};
assign rom[185]={8'b00011000,
                 8'b00001100,
                 8'b00000110,
                 8'b00000000};

assign rom[186]={8'b00000000,
                 8'b01111000,
                 8'b00011000,
                 8'b00011000};
assign rom[187]={8'b00011000,
                 8'b00011000,
                 8'b01111000,
                 8'b00000000};

assign rom[188]={8'b00000000,
                 8'b00001000,
                 8'b00011100,
                 8'b00110110};
assign rom[189]={8'b01100011,
                 8'b00000000,
                 8'b00000000,
                 8'b00000000};

assign rom[190]={8'b00000000,
                 8'b00000000,
                 8'b00000000,
                 8'b00000000};
assign rom[191]={8'b00000000,
                 8'b00000000,
                 8'b11111111,
                 8'b00000000};

assign rom[192]={8'b00000000,
                 8'b00011000,
                 8'b00111100,
                 8'b01111110};
assign rom[193]={8'b01111110,
                 8'b00111100,
                 8'b00011000,
                 8'b00000000};

assign rom[194]={8'b00000000,
                 8'b00000000,
                 8'b00111100,
                 8'b00000110};
assign rom[195]={8'b00111110,
                 8'b01100110,
                 8'b00111110,
                 8'b00000000};

assign rom[196]={8'b00000000,
                 8'b01100000,
                 8'b01100000,
                 8'b01111100};
assign rom[197]={8'b01100110,
                 8'b01100110,
                 8'b01111100,
                 8'b00000000};

assign rom[198]={8'b00000000,
                 8'b00000000,
                 8'b00111100,
                 8'b01100000};
assign rom[199]={8'b01100000,
                 8'b01100000,
                 8'b00111100,
                 8'b00000000};

assign rom[200]={8'b00000000,
                 8'b00000110,
                 8'b00000110,
                 8'b00111110};
assign rom[201]={8'b01100110,
                 8'b01100110,
                 8'b00111110,
                 8'b00000000};

assign rom[202]={8'b00000000,
                 8'b00000000,
                 8'b00111100,
                 8'b01100110};
assign rom[203]={8'b01111110,
                 8'b01100000,
                 8'b00111100,
                 8'b00000000};

assign rom[204]={8'b00000000,
                 8'b00001110,
                 8'b00011000,
                 8'b00111110};
assign rom[205]={8'b00011000,
                 8'b00011000,
                 8'b00011000,
                 8'b00000000};

assign rom[206]={8'b00000000,
                 8'b00000000,
                 8'b00111110,
                 8'b01100110};
assign rom[207]={8'b01100110,
                 8'b00111110,
                 8'b00000110,
                 8'b01111100};

assign rom[208]={8'b00000000,
                 8'b01100000,
                 8'b01100000,
                 8'b01111100};
assign rom[209]={8'b01100110,
                 8'b01100110,
                 8'b01100110,
                 8'b00000000};

assign rom[210]={8'b00000000,
                 8'b00011000,
                 8'b00000000,
                 8'b00111000};
assign rom[211]={8'b00011000,
                 8'b00011000,
                 8'b00111100,
                 8'b00000000};

assign rom[212]={8'b00000000,
                 8'b00000110,
                 8'b00000000,
                 8'b00000110};
assign rom[213]={8'b00000110,
                 8'b00000110,
                 8'b00000110,
                 8'b00111100};

assign rom[214]={8'b00000000,
                 8'b01100000,
                 8'b01100000,
                 8'b01101100};
assign rom[215]={8'b01111000,
                 8'b01101100,
                 8'b01100110,
                 8'b00000000};

assign rom[216]={8'b00000000,
                 8'b00111000,
                 8'b00011000,
                 8'b00011000};
assign rom[217]={8'b00011000,
                 8'b00011000,
                 8'b00111100,
                 8'b00000000};

assign rom[218]={8'b00000000,
                 8'b00000000,
                 8'b01100110,
                 8'b01111111};
assign rom[219]={8'b01111111,
                 8'b01101011,
                 8'b01100011,
                 8'b00000000};

assign rom[220]={8'b00000000,
                 8'b00000000,
                 8'b01111100,
                 8'b01100110};
assign rom[221]={8'b01100110,
                 8'b01100110,
                 8'b01100110,
                 8'b00000000};

assign rom[222]={8'b00000000,
                 8'b00000000,
                 8'b00111100,
                 8'b01100110};
assign rom[223]={8'b01100110,
                 8'b01100110,
                 8'b00111100,
                 8'b00000000};

assign rom[224]={8'b00000000,
                 8'b00000000,
                 8'b01111100,
                 8'b01100110};
assign rom[225]={8'b01100110,
                 8'b01111100,
                 8'b01100000,
                 8'b01100000};

assign rom[226]={8'b00000000,
                 8'b00000000,
                 8'b00111110,
                 8'b01100110};
assign rom[227]={8'b01100110,
                 8'b00111110,
                 8'b00000110,
                 8'b00000110};

assign rom[228]={8'b00000000,
                 8'b00000000,
                 8'b01111100,
                 8'b01100110};
assign rom[229]={8'b01100000,
                 8'b01100000,
                 8'b01100000,
                 8'b00000000};

assign rom[230]={8'b00000000,
                 8'b00000000,
                 8'b00111110,
                 8'b01100000};
assign rom[231]={8'b00111100,
                 8'b00000110,
                 8'b01111100,
                 8'b00000000};

assign rom[232]={8'b00000000,
                 8'b00011000,
                 8'b01111110,
                 8'b00011000};
assign rom[233]={8'b00011000,
                 8'b00011000,
                 8'b00001110,
                 8'b00000000};

assign rom[234]={8'b00000000,
                 8'b00000000,
                 8'b01100110,
                 8'b01100110};
assign rom[235]={8'b01100110,
                 8'b01100110,
                 8'b00111110,
                 8'b00000000};

assign rom[236]={8'b00000000,
                 8'b00000000,
                 8'b01100110,
                 8'b01100110};
assign rom[237]={8'b01100110,
                 8'b00111100,
                 8'b00011000,
                 8'b00000000};

assign rom[238]={8'b00000000,
                 8'b00000000,
                 8'b01100011,
                 8'b01101011};
assign rom[239]={8'b01111111,
                 8'b00111110,
                 8'b00110110,
                 8'b00000000};

assign rom[240]={8'b00000000,
                 8'b00000000,
                 8'b01100110,
                 8'b00111100};
assign rom[241]={8'b00011000,
                 8'b00111100,
                 8'b01100110,
                 8'b00000000};

assign rom[242]={8'b00000000,
                 8'b00000000,
                 8'b01100110,
                 8'b01100110};
assign rom[243]={8'b01100110,
                 8'b00111110,
                 8'b00001100,
                 8'b01111000};

assign rom[244]={8'b00000000,
                 8'b00000000,
                 8'b01111110,
                 8'b00001100};
assign rom[245]={8'b00011000,
                 8'b00110000,
                 8'b01111110,
                 8'b00000000};

assign rom[246]={8'b00000000,
                 8'b00011000,
                 8'b00111100,
                 8'b01111110};
assign rom[247]={8'b01111110,
                 8'b00011000,
                 8'b00111100,
                 8'b00000000};

assign rom[248]={8'b00011000,
                 8'b00011000,
                 8'b00011000,
                 8'b00011000};
assign rom[249]={8'b00011000,
                 8'b00011000,
                 8'b00011000,
                 8'b00011000};

assign rom[250]={8'b00000000,
                 8'b01111110,
                 8'b01111000,
                 8'b01111100};
assign rom[251]={8'b01101110,
                 8'b01100110,
                 8'b00000110,
                 8'b00000000};

assign rom[252]={8'b00001000,
                 8'b00011000,
                 8'b00111000,
                 8'b01111000};
assign rom[253]={8'b00111000,
                 8'b00011000,
                 8'b00001000,
                 8'b00000000};

assign rom[254]={8'b00010000,
                 8'b00011000,
                 8'b00011100,
                 8'b00011110};
assign rom[255]={8'b00011100,
                 8'b00011000,
                 8'b00010000,
                 8'b00000000};
endmodule

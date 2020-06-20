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
	wire [10:0] vcount[3:0];
	wire [10:0] hcount[3:0];

	assign vgaRed   =   red[rez];
	assign vgaGreen = green[rez];
	assign vgaBlue  =  blue[rez];
	assign Hsync    = hsync[rez];
	assign Vsync    = vsync[rez];

	always@(*)begin
		if((hcount[rez]==0)&&(vcount[rez]==0))begin
			rez=sw;
		end
	end
	
	vgaClock vc(clk,MHz25,MHz40,MHz65,MHz108);
	
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
	input  wire        clock,
	output wire [ 3:0] vgaRed,
	output wire [ 3:0] vgaGreen,
	output wire [ 3:0] vgaBlue,
	output reg         Hsync,
	output reg         Vsync,
	output reg  [10:0] hCount,
	output reg  [10:0] vCount,
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

	reg	[ 6:0]	char;
	reg	[11:0]	color;
	reg	[31:0]	data;
	reg		flip;
	reg	[ 7:0]	locb;
	reg	[11:0]	off;
	reg	[11:0]	on;
	reg	[ 7:0]	temp;

	wire	[14:0]	address;
	wire	[ 2:0]	col;
	wire	[31:0]	early;
	wire	[ 3:0]	hex;
	wire	[ 3:0]	i;
	wire	[ 7:0]	pixels;
	wire	[ 2:0]	row;
	wire	[12:0]	x;
	wire	[10:0]	y;

	assign x 	= hCount-HVA+12'd8;
	assign y	= vCount-VVA;
	assign col 	= x[2:0];
	assign row	= y[2:0];
	assign address	= (y[9:3]<<8)+x[12:3]+13'd1;
	assign vgaRed	= color[11:8];
	assign vgaGreen = color[7:4];
	assign vgaBlue  = color[3:0];

	CharSet acs(clock,temp,early);
	locByte loc(data,row[1:0],pixels);

	initial begin
		Hsync	<= ~POL;
		Vsync	<= ~POL;
		char	<= 7'd0;
		color	<=12'd0;
		data	<=32'd0;
		hCount	<=11'd0;
		on	<=12'd0;
		off	<=12'd0;
		temp	<= 8'd0;
		vCount	<=10'd0;
	end
	
	always @ (posedge clock) begin
		if((vCount<VVA)||(hCount<HVA))begin
			color<=12'd0;
		end else begin
			if(flip)begin
				color<=pixels[~col]?off:on;
			end else begin
				color<=pixels[~col]?on:off;
			end
		end
		if((hCount>=HFP)&&(hCount<HBP))begin
			Hsync<=POL;
		end else begin
			Hsync<=~POL;
		end
		if((vCount>=VFP)&&(vCount<VBP))begin
			Vsync<=POL;
		end else begin
			Vsync<=~POL;
		end
		if(hCount<HWL)
			hCount<=hCount+10'd1;
		else begin
			hCount<=10'd0;
			if(vCount<VWF)begin
				vCount<=vCount+10'd1;
			end else begin
				vCount<=10'd0;
			end
		end
		if(x[2:0]==3'd6)begin
			temp	<=(address[6:0]<<1)|row[2];;
		end else if(x[2:0]==3'd7)begin
			data	<= early;
			flip	<= address[7];
			off	<= address[11:0];
			on	<=~address[11:0];
		end
	end
endmodule

module locByte(
	input	wire [31:0] l,
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

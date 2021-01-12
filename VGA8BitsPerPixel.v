`timescale 1ns / 1ps

//`define DEBUG

`ifdef DEBUG

module TestVGA;

	// Inputs
	reg clk;

	// Outputs
	wire        MHz75;
	wire [ 2:0] timer;
	wire        write;
	wire [16:0] pixadr;
	wire [31:0] pixout;
	wire [31:0] pixdat;
	wire [ 9:0] vCount;
	wire [ 9:0] hCount;
	wire [ 3:0] vgaR;
	wire [ 3:0] vgaG;
	wire [ 3:0] vgaB;
	wire        hsync;
	wire        vsync;

	// Instantiate the Unit Under Test (UUT)
	VGA uut (
		.clk(clk),
		.MHz75(MHz75),
		.timer(timer),
		.write(write),
		.pixadr(pixadr),
		.pixout(pixout),
		.pixdat(pixdat),
		.hCount(hCount),
		.vCount(vCount),
		.vgaR(vgaR),
		.vgaG(vgaG),
		.vgaB(vgaB),
		.hsync(hsync),
		.vsync(vsync)
	);

	initial begin
		clk = 0;
		#100;
	end

	always clk=#10~clk;

endmodule

`endif

// clocks per pixel
`define cpp	3'd3
// horz sync polarity
`define hsp 1'd0
// horz front pourch
`define hfp 10'd16
// horz back pourch
`define hbp 10'd112
// horz total blank
`define htb 10'd160
// horz visible area
`define hva 10'd640
// horz total width
`define htw 10'd800
// vert sync polarity
`define vsp 1'd0
// vert front pourch
`define vfp 10'd10
// vert back pourch
`define vbp 10'd12
// vert total blank
`define vtb 10'd45
// vert visible area
`define vva 10'd480
// vert total height
`define vth 10'd525

module VGA(
	input  wire        clk,
`ifdef DEBUG
	output wire        MHz75,
	output reg  [ 2:0] timer,
	output reg         write,
	output reg  [16:0] pixadr,
	output wire [31:0] pixdat,
	output reg  [31:0] pixout,
	output reg  [ 9:0] hCount,
	output reg  [ 9:0] vCount,
`endif
	output wire [ 3:0] vgaR,
	output wire [ 3:0] vgaG,
	output wire [ 3:0] vgaB,
	output reg         hsync,
	output reg         vsync
);

`ifndef DEBUG
	wire        MHz75;
	reg  [ 2:0] timer;
	reg         write;
	reg  [16:0] pixadr;
	wire [31:0] pixdat;
	reg  [31:0] pixout;
	reg  [ 9:0] hCount;
	reg  [ 9:0] vCount;
`endif

	reg [11:0] color;
	reg [31:0] pixels;

	wire [ 1:0] col;
	wire [ 3:0] i;
	wire [ 3:0] hex;
	wire [ 7:0] pixel;
	wire [11:0] palette [255:0];
	wire [ 9:0] x;
	wire [ 9:0] y;

	assign col  = x[1:0];
	assign vgaR = color[11:8];
	assign vgaG = color[7:4];
	assign vgaB = color[3:0];
	assign x    = hCount-`htb;
	assign y    = vCount-`vtb;

	vgaClock tick(MHz75,clk);
	RAM ram(MHz75,write,pixadr,pixout,pixdat);
	quad qp(pixels,col,pixel);

	initial begin
		timer   = 3'd0;
		write   = 1'd0;
		pixadr  = ~17'd0;
		pixout  = 32'h00010203;
		pixels  = 32'h0;
		color   = 12'd0;
		hCount  = 10'd0;
		vCount  = 10'd0;
		hsync   = 1'd1;
		vsync   = 1'd1;
	end

	always @ (posedge MHz75) begin
		if(write==1'd1)begin
			if((hCount>=`hfp)&&(hCount<`hbp))begin
				hsync = `hsp;
			end else begin
				hsync = ~`hsp;
			end
			if((vCount>=`vfp)&&(vCount<`vbp))begin
				vsync = `vsp;
			end else begin
				vsync = ~`vsp;
			end
			if(timer<`cpp)begin
				timer = timer + 3'd1;
			end else begin
				timer = 3'd1;
				if(hCount<`htw)begin
					hCount = hCount + 10'd1;
					`ifdef DEBUG
						if((y==10'd3)&&(x==10'd8))$finish;
					`endif
				end else begin
					hCount = 10'd1;
					if(vCount<`vth)begin
						vCount = vCount + 10'd1;
					end else begin
						vCount = 10'd1;
						pixadr =~17'd0;
					end
				end
			end
			`ifdef DEBUG
				if((vCount>=`vtb)&&(x<`hva))begin
					if(timer==3'd1)begin
						if(x[1:0]==2'd0)begin
							$display("pixels=%8h pixadr=%6d",pixdat,pixadr);
						end
					end
				end
			`endif
			if((vCount<`vtb)||(hCount<`htb))begin
				color = 12'd0;
			end else begin
				color = palette[pixel];
				`ifdef DEBUG
					if((timer==3'd1)&&(x<`hva))$display("x=%3d y=%3d c=%3h p=%2h",x,y,color,pixel);
				`endif
			end
			if((vCount>=`vtb)&&(x<`hva))begin
				if(timer==3'd3)begin
					if(x[1:0]==2'd3)begin
						pixels = pixdat;
						pixadr = pixadr + 17'd1;
					end
				end
			end
		end else begin
			pixadr = pixadr + 17'd1;
			if(pixout[7:0]==8'hFF)begin
				pixout = 32'h00010203;
			end else begin
				pixout = pixout + 32'h04040404;
			end
			if(pixadr==~17'd0)begin
				write = 1'd1;
				pixadr = 17'd0;
			end
		end
	end

	assign palette[  0]=12'hFFF;
	assign palette[  1]=12'hFFE;
	assign palette[  2]=12'hFFD;
	assign palette[  3]=12'hFFC;
	assign palette[  4]=12'hFFB;
	assign palette[  5]=12'hFFA;
	assign palette[  6]=12'hFF9;
	assign palette[  7]=12'hFF8;
	assign palette[  8]=12'hFF7;
	assign palette[  9]=12'hFF6;
	assign palette[ 10]=12'hFF5;
	assign palette[ 11]=12'hFF4;
	assign palette[ 12]=12'hFF3;
	assign palette[ 13]=12'hFF2;
	assign palette[ 14]=12'hFF1;
	assign palette[ 15]=12'hFF0;
	assign palette[ 16]=12'hFE0;
	assign palette[ 17]=12'hFD0;
	assign palette[ 18]=12'hFC0;
	assign palette[ 19]=12'hFB0;
	assign palette[ 20]=12'hFA0;
	assign palette[ 21]=12'hF90;
	assign palette[ 22]=12'hF80;
	assign palette[ 23]=12'hF70;
	assign palette[ 24]=12'hF60;
	assign palette[ 25]=12'hF50;
	assign palette[ 26]=12'hF40;
	assign palette[ 27]=12'hF30;
	assign palette[ 28]=12'hF20;
	assign palette[ 29]=12'hF10;
	assign palette[ 30]=12'hF00;
	assign palette[ 31]=12'hE00;
	assign palette[ 32]=12'hD00;
	assign palette[ 33]=12'hC00;
	assign palette[ 34]=12'hB00;
	assign palette[ 35]=12'hA00;
	assign palette[ 36]=12'h900;
	assign palette[ 37]=12'h800;
	assign palette[ 38]=12'h700;
	assign palette[ 39]=12'h600;
	assign palette[ 40]=12'h500;
	assign palette[ 41]=12'h400;
	assign palette[ 42]=12'h300;
	assign palette[ 43]=12'h200;
	assign palette[ 44]=12'h100;
	assign palette[ 45]=12'h000;
	assign palette[ 46]=12'h001;
	assign palette[ 47]=12'h002;
	assign palette[ 48]=12'h003;
	assign palette[ 49]=12'h004;
	assign palette[ 50]=12'h005;
	assign palette[ 51]=12'h006;
	assign palette[ 52]=12'h007;
	assign palette[ 53]=12'h008;
	assign palette[ 54]=12'h009;
	assign palette[ 55]=12'h00A;
	assign palette[ 56]=12'h00B;
	assign palette[ 57]=12'h00C;
	assign palette[ 58]=12'h00D;
	assign palette[ 59]=12'h00E;
	assign palette[ 60]=12'h00F;
	assign palette[ 61]=12'h01F;
	assign palette[ 62]=12'h02F;
	assign palette[ 63]=12'h03F;
	assign palette[ 64]=12'h04F;
	assign palette[ 65]=12'h05F;
	assign palette[ 66]=12'h06F;
	assign palette[ 67]=12'h07F;
	assign palette[ 68]=12'h08F;
	assign palette[ 69]=12'h09F;
	assign palette[ 70]=12'h0AF;
	assign palette[ 71]=12'h0BF;
	assign palette[ 72]=12'h0CF;
	assign palette[ 73]=12'h0DF;
	assign palette[ 74]=12'h0EF;
	assign palette[ 75]=12'h0FF;
	assign palette[ 76]=12'h1FF;
	assign palette[ 77]=12'h2FF;
	assign palette[ 78]=12'h3FF;
	assign palette[ 79]=12'h4FF;
	assign palette[ 80]=12'h5FF;
	assign palette[ 81]=12'h6FF;
	assign palette[ 82]=12'h7FF;
	assign palette[ 83]=12'h8FF;
	assign palette[ 84]=12'h9FF;
	assign palette[ 85]=12'hAFF;
	assign palette[ 86]=12'hBFF;
	assign palette[ 87]=12'hCFF;
	assign palette[ 88]=12'hDFF;
	assign palette[ 89]=12'hEFF;
	assign palette[ 90]=12'hFFF;
	assign palette[ 91]=12'hFEF;
	assign palette[ 92]=12'hFDF;
	assign palette[ 93]=12'hFCF;
	assign palette[ 94]=12'hFBF;
	assign palette[ 95]=12'hFAF;
	assign palette[ 96]=12'hF9F;
	assign palette[ 97]=12'hF8F;
	assign palette[ 98]=12'hF7F;
	assign palette[ 99]=12'hF6F;
	assign palette[100]=12'hF5F;
	assign palette[101]=12'hF4F;
	assign palette[102]=12'hF3F;
	assign palette[103]=12'hF2F;
	assign palette[104]=12'hF1F;
	assign palette[105]=12'hF0F;
	assign palette[106]=12'hF0E;
	assign palette[107]=12'hF0D;
	assign palette[108]=12'hF0C;
	assign palette[109]=12'hF0B;
	assign palette[110]=12'hF0A;
	assign palette[111]=12'hF09;
	assign palette[112]=12'hF08;
	assign palette[113]=12'hF07;
	assign palette[114]=12'hF06;
	assign palette[115]=12'hF05;
	assign palette[116]=12'hF04;
	assign palette[117]=12'hF03;
	assign palette[118]=12'hF02;
	assign palette[119]=12'hF01;
	assign palette[120]=12'hF00;
	assign palette[121]=12'hF11;
	assign palette[122]=12'hF22;
	assign palette[123]=12'hF33;
	assign palette[124]=12'hF44;
	assign palette[125]=12'hF55;
	assign palette[126]=12'hF66;
	assign palette[127]=12'hF77;
	assign palette[128]=12'hF88;
	assign palette[129]=12'hF99;
	assign palette[130]=12'hFAA;
	assign palette[131]=12'hFBB;
	assign palette[132]=12'hFCC;
	assign palette[133]=12'hFDD;
	assign palette[134]=12'hFEE;
	assign palette[135]=12'hFFF;
	assign palette[136]=12'hEFE;
	assign palette[137]=12'hDFD;
	assign palette[138]=12'hCFC;
	assign palette[139]=12'hBFB;
	assign palette[140]=12'hAFA;
	assign palette[141]=12'h9F9;
	assign palette[142]=12'h8F8;
	assign palette[143]=12'h7F7;
	assign palette[144]=12'h6F6;
	assign palette[145]=12'h5F5;
	assign palette[146]=12'h4F4;
	assign palette[147]=12'h3F3;
	assign palette[148]=12'h2F2;
	assign palette[149]=12'h1F1;
	assign palette[150]=12'h0F0;
	assign palette[151]=12'h0E0;
	assign palette[152]=12'h0D0;
	assign palette[153]=12'h0C0;
	assign palette[154]=12'h0B0;
	assign palette[155]=12'h0A0;
	assign palette[156]=12'h090;
	assign palette[157]=12'h080;
	assign palette[158]=12'h070;
	assign palette[159]=12'h060;
	assign palette[160]=12'h050;
	assign palette[161]=12'h040;
	assign palette[162]=12'h030;
	assign palette[163]=12'h020;
	assign palette[164]=12'h010;
	assign palette[165]=12'h000;
	assign palette[166]=12'h100;
	assign palette[167]=12'h200;
	assign palette[168]=12'h300;
	assign palette[169]=12'h400;
	assign palette[170]=12'h500;
	assign palette[171]=12'h600;
	assign palette[172]=12'h700;
	assign palette[173]=12'h800;
	assign palette[174]=12'h900;
	assign palette[175]=12'hA00;
	assign palette[176]=12'hB00;
	assign palette[177]=12'hC00;
	assign palette[178]=12'hD00;
	assign palette[179]=12'hE00;
	assign palette[180]=12'hF00;
	assign palette[181]=12'hF11;
	assign palette[182]=12'hF22;
	assign palette[183]=12'hF33;
	assign palette[184]=12'hF44;
	assign palette[185]=12'hF55;
	assign palette[186]=12'hF66;
	assign palette[187]=12'hF77;
	assign palette[188]=12'hF88;
	assign palette[189]=12'hF99;
	assign palette[190]=12'hFAA;
	assign palette[191]=12'hFBB;
	assign palette[192]=12'hFCC;
	assign palette[193]=12'hFDD;
	assign palette[194]=12'hFEE;
	assign palette[195]=12'hFFF;
	assign palette[196]=12'hEFE;
	assign palette[197]=12'hDFD;
	assign palette[198]=12'hCFC;
	assign palette[199]=12'hBFB;
	assign palette[200]=12'hAFA;
	assign palette[201]=12'h9F9;
	assign palette[202]=12'h8F8;
	assign palette[203]=12'h7F7;
	assign palette[204]=12'h6F6;
	assign palette[205]=12'h5F5;
	assign palette[206]=12'h4F4;
	assign palette[207]=12'h3F3;
	assign palette[208]=12'h2F2;
	assign palette[209]=12'h1F1;
	assign palette[210]=12'h0F0;
	assign palette[211]=12'h00C;
	assign palette[212]=12'h009;
	assign palette[213]=12'h006;
	assign palette[214]=12'h003;
	assign palette[215]=12'h000;
	assign palette[216]=12'hE00;
	assign palette[217]=12'hD00;
	assign palette[218]=12'hB00;
	assign palette[219]=12'hA00;
	assign palette[220]=12'h800;
	assign palette[221]=12'h700;
	assign palette[222]=12'h500;
	assign palette[223]=12'h400;
	assign palette[224]=12'h200;
	assign palette[225]=12'h100;
	assign palette[226]=12'h0E0;
	assign palette[227]=12'h0D0;
	assign palette[228]=12'h0B0;
	assign palette[229]=12'h0A0;
	assign palette[230]=12'h080;
	assign palette[231]=12'h070;
	assign palette[232]=12'h050;
	assign palette[233]=12'h040;
	assign palette[234]=12'h020;
	assign palette[235]=12'h010;
	assign palette[236]=12'h000;
	assign palette[237]=12'h111;
	assign palette[238]=12'h222;
	assign palette[239]=12'h333;
	assign palette[240]=12'h444;
	assign palette[241]=12'h555;
	assign palette[242]=12'h666;
	assign palette[243]=12'h777;
	assign palette[244]=12'h888;
	assign palette[245]=12'h999;
	assign palette[246]=12'hAAA;
	assign palette[247]=12'hBBB;
	assign palette[248]=12'hCCC;
	assign palette[249]=12'hDDD;
	assign palette[250]=12'hEEE;
	assign palette[251]=12'hFFF;
	assign palette[252]=12'hC09;
	assign palette[253]=12'hC90;
	assign palette[254]=12'h0C9;
	assign palette[255]=12'h90C;

endmodule

module RAM(
   input wire        ramC,
	 input wire        ramW,
	 input wire [16:0] ramA,
   input wire [31:0] ramI,
   output reg [31:0] ramO
);

	reg [31:0] ram [131071:0];

	initial begin
		ramO={5'd31,5'd31,5'd31,1'd1,15'hF0AA};
	end

	always @ (posedge ramC) begin
		if(ramW==1'd1)begin
			ramO=ram[ramA];
		end else begin
			ram[ramA]=ramI;
		end
	end

endmodule

module quad(
	input  wire [31:0] pixels,
	input  wire [ 1:0] column,
	output wire [ 7:0] pixel
);

	wire[7:0]p[3:0];

	assign pixel=p[column];

	assign p[0]=pixels[31:24];
	assign p[1]=pixels[23:16];
	assign p[2]=pixels[15: 8];
	assign p[3]=pixels[ 7: 0];

endmodule

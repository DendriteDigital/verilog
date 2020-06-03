`timescale 1ns / 1ps

module VGA(
	input	wire	    clk,	// 100 MHz
	output 	wire [ 3:0] vgaRed,
	output 	wire [ 3:0] vgaGreen,
	output 	wire [ 3:0] vgaBlue,
	output 	reg	    Hsync,
	output 	reg	    Vsync
);

	reg		flip;
	reg	[ 1:0]	timer;
	reg	[ 6:0]	char;
	reg	[ 7:0]	locb;
	reg	[ 7:0]	temp;
	reg	[ 9:0]	vCount;
	reg	[11:0]	hCount;
	reg	[11:0]	color;
	reg	[11:0]	on;
	reg	[11:0]	off;
	reg	[31:0]	data;

	wire	[ 2:0]	col;
	wire	[ 2:0]	row;
	wire	[ 3:0]	i;
	wire	[ 3:0]	hex;
	wire	[ 7:0]	pixels;
	wire	[ 9:0]	y;
	wire	[11:0]	x;
	wire	[12:0]	address;
	wire	[31:0]	early;

	assign x 	= hCount-12'd568;
	assign y	= vCount-10'd46;
	assign col 	= x[4:2];
	assign row	= y[2:0];
	assign address  = (((y[9:3]<<2)+y[9:3])<<4)+x[11:5];
	assign vgaRed	= color[11:8];
	assign vgaGreen = color[7:4];
	assign vgaBlue 	= color[3:0];

	CharSet acs(clk,temp,early);		// CharSet32.v
//	Random rnd(clk,address,data);
	locByte loc(data,row[1:0],pixels);

	initial begin
		timer<=2'd0;
		char<=7'd0;
		hCount<=12'd0;
		vCount<=10'd0;
		color<=12'd0;
		on<=12'd0;
		off<=12'd0;
	end
		
	always @ (posedge clk) begin
		if((hCount<632)||(hCount>=3160)||(vCount<46)) begin
			color<=12'd0;
		end else begin
//			color<=pixels[~col]?12'hFFF:12'h009;
			if(flip)begin
				color<=pixels[~col]?off:on;
			end else begin
				color<=pixels[~col]?on:off;
			end
		end
		if((hCount>=568)&&(vCount>=45))begin
			if(x[4:0]==5'd30)begin
				temp	<=(address[ 6:0]<<1)|row[2];;
			end else if(x[4:0]==5'd31)begin
				data	<= early;
				flip	<= address[   7];
				off	<= address[11:0];
				on	<=~address[12:1];
			end
		end
		if(hCount>=3177)begin
			hCount<=10'd0;
			vCount<=vCount+10'd1;
		end else begin
			hCount<=hCount+10'd1;
		end
		if(vCount>=525)begin
			vCount<=10'd0;
		end
		if((hCount>=63)&&(hCount<444))begin
			Hsync<=1'b0;
		end else begin
			Hsync<=1'b1;
		end
		if((vCount>=11)&&(vCount<13))begin
			Vsync<=1'b0;
		end else begin
			Vsync<=1'b1;
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

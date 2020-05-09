module VGA(
	input	wire		clock,
	output 	wire [ 3:0] red,
	output 	wire [ 3:0] green,
	output 	wire [ 3:0] blue,
	output 	reg			hsync,
	output 	reg			vsync
);

	reg				flip;
	reg	[ 1:0]	timer;
	reg	[ 6:0]	char;
	reg	[ 9:0]	hCount;
	reg	[ 9:0]	vCount;
	reg	[11:0]	color;
	reg	[11:0]	on;
	reg	[11:0]	off;

	wire	[ 2:0]	col;
	wire	[ 2:0]	row;
	wire	[ 3:0]	i;
	wire	[ 3:0]	hex;
	wire	[ 7:0]	pixels;
	wire	[ 9:0]	x;
	wire	[ 9:0]	y;
	wire	[12:0]	address;

	assign x 		= hCount-10'd160;
	assign col 		= x[2:0];
	assign y		= vCount-10'd45;
	assign row		= y[2:0];
	assign address	= y[9:3]*13'd80+x[9:3];
	assign red		= color[11:8];
	assign green 	= color[7:4];
	assign blue 	= color[3:0];

	CharSet acs(char,row,pixels);
	
	initial begin
		timer<=2'd0;
		char<=7'd0;
		hCount<=10'd0;
		vCount<=10'd0;
		color<=12'd0;
		on<=12'd0;
		off<=12'd0;
	end
	
	always @ (posedge clock) begin
		if(timer==2'd0)begin
			if((hCount<160)||(vCount<45)) begin
				color<=12'd0;
			end else begin
				if(flip)color<=pixels[~col]?on:off;
				else color<=pixels[col]?on:off;
			end
		end
		if(timer==2'd1)begin
			if(hCount>=799)begin
				hCount<=10'd0;
				vCount<=vCount+10'd1;
			end else begin
				hCount<=hCount+10'd1;
			end
			if(vCount>=524)begin
				vCount<=10'd0;
			end
			if((hCount>=16)&&(hCount<112))begin
				hsync<=1'b0;
			end else begin
				hsync<=1'b1;
			end
			if((vCount>=11)&&(vCount<13))begin
				vsync<=1'b0;
			end else begin
				vsync<=1'b1;
			end
		end
		if(timer==2'd3)begin
			if((hCount>=160)&&(vCount>=45)&&(x[2:0]==3'd0))begin
				char<=address[6:0];
				flip<=address[7];
				off<=address[11:0];
				on<=~address[12:1];
			end
		end
		timer<=timer+2'd1;
	end
endmodule

module VGA(
	input	wire		clock,
	input	wire [ 1:0] timer,
	input	wire [31:0] temp,
	output	reg  [17:0] address,
	output	wire [ 3:0] red,
	output	wire [ 3:0] green,
	output	wire [ 3:0] blue,
	output	reg			hsync,
	output	reg			vsync
);
	reg	[11:0]	vCount;
	reg	[11:0]	hCount;
	reg	[11:0]	color;
	reg	[31:0]	data;

	wire	[ 2:0]	sel;
	wire	[ 3:0]	i;
	wire	[ 3:0]	hex;
	wire	[11:0]	x;
	wire	[11:0]	index;

	assign x 		= hCount-10'd160;
	assign sel 		= x[4:2];

	assign red		= color[11:8];
	assign green 	= color[7:4];
	assign blue 	= color[3:0];

	Pixel4 p(data,sel,hex);
	Pallette c(hex,index);

	always @ (posedge clock) begin
		if((hCount>=63)&&(hCount<445))begin
			hsync<=1'b0;
		end else begin
			hsync<=1'b1;
		end
		if((vCount>=11)&&(vCount<13))begin
			vsync<=1'b0;
		end else begin
			vsync<=1'b1;
		end
		if((hCount<635)||(vCount<45)) begin
			color<=12'd0;
		end else begin
			color<=index;
		end
		if(hCount>=3177)begin
			hCount<=12'd0;
			vCount<=vCount+12'd1;
		end else begin
			hCount<=hCount+12'd1;
		end
		if((hCount>=635)&&(vCount>=45)&&(sel==3'd7))begin
			address<=address+12'd1;
		end
		if((hCount>=635)&&(vCount>=45)&&(sel==3'd0))begin
			data<=temp;
		end
		if(vCount>=524)begin
			vCount<=10'd0;
			address<=17'd0;
		end
	end
endmodule

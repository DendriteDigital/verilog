`timescale 1 ns/10 ps

module Keyboard(
	input		wire				clock,
	input		wire				PS2C,
	input		wire				PS2D,
	output	wire	[ 6:0]	seg,
	output	wire	[ 7:0]	an
);

	reg	[31:0]	data;
	wire	[ 7:0]	key;

	initial begin
		data<=32'd0;
	end

	ps2 keyboard(clock,PS2C,PS2D,key);
	Eight7Segments e7s(clock,data,seg,an);

	always@(posedge clock)begin
		if(key!=data[7:0])begin
			data[31:24]=data[23:16];
			data[23:16]=data[15: 8];
			data[15: 8]=data[ 7: 0];
			data[ 7: 0]=key;
		end
	end

endmodule

module ps2(
	input		wire 			clock,
	input 	wire 			PS2C,
	input 	wire			PS2D,
	output	reg 	[7:0] key
);

	reg			error;
	reg 			flag;
	reg			pre_clk;
	reg			parity;
	reg [ 3:0]	counter;
	reg [ 7:0]	data_curr;
	reg [11:0]	ticks;

	initial begin
		counter = 4'h1;
		data_curr = 8'hF0;
		flag = 1'b0;
		pre_clk = 1'b0;
		parity = 1'b1;
		key = 8'hF0;
		error = 1'd0;
		ticks = 12'd0;
	end

	// FSM
	always @(posedge clock)begin
		ticks = ticks + 12'd1;
		if(ticks>=4000)begin
			ticks = 12'd0;
			if((~PS2C)&&pre_clk)begin
				case (counter)
					 1:;
					 2:begin data_curr[0]<=PS2D;parity<=parity^PS2D;end
					 3:begin data_curr[1]<=PS2D;parity<=parity^PS2D;end
					 4:begin data_curr[2]<=PS2D;parity<=parity^PS2D;end
					 5:begin data_curr[3]<=PS2D;parity<=parity^PS2D;end
					 6:begin data_curr[4]<=PS2D;parity<=parity^PS2D;end
					 7:begin data_curr[5]<=PS2D;parity<=parity^PS2D;end
					 8:begin data_curr[6]<=PS2D;parity<=parity^PS2D;end
					 9:begin data_curr[7]<=PS2D;parity<=parity^PS2D;end
					10:begin flag=1'b1;if(parity!=PS2D)error<=1;end
					11:if(~error)flag=1'b0;
				endcase
				if((counter==1)&&(~PS2D))begin
					counter<=4'd2;
					parity<=1;
					error<=0;
				end else if((counter>=2)&&(counter<11))
					counter<=counter+4'h1;
				else counter<=4'h1;
			end
			pre_clk<=PS2C;
		end
	end

	always @(negedge flag)begin
		key<=data_curr;
	end

endmodule

module Eight7Segments(
	input		wire				clock,
	input		wire	[31:0]	data,
	output	wire	[ 6:0]	seg,
	output	reg	[ 7:0]	an
);
	reg		[ 3:0]	display;
	reg		[20:0]	counter;

	HEXdecoder hd(display,seg);

	always@(*)begin
		an=255;
		an[counter[20:18]]=0;
		case(counter[20:18])
			0:display=data[27:24];
			1:display=data[31:28];
			2:display=data[19:16];
			3:display=data[23:20];
			4:display=data[11: 8];
			5:display=data[15:12];
			6:display=data[ 3: 0];
			7:display=data[ 7: 4];
		endcase
	end

	always@(posedge clock)begin
		counter<=counter+21'd1;
	end

endmodule

module HEXdecoder(data,segment);
	input	[3:0]	data;
	output	[6:0]	segment;
	wire	[6:0]	segment;

	wire [6:0] hex [15:0];

	assign segment=hex[data];

	assign hex[ 0]=7'b1000000;		//0000001;
	assign hex[ 1]=7'b1111001;		//1001111;
	assign hex[ 2]=7'b0100100;		//0010010;
	assign hex[ 3]=7'b0110000;		//0000110;
	assign hex[ 4]=7'b0011001;		//1001100;
	assign hex[ 5]=7'b0010010;		//0100100;
	assign hex[ 6]=7'b0000010;		//0100000;
	assign hex[ 7]=7'b1111000;		//0001111;
	assign hex[ 8]=7'b0000000;
	assign hex[ 9]=7'b0010000;		//0000100;
	assign hex[10]=7'b0001000;
	assign hex[11]=7'b0000011;		//1100000;
	assign hex[12]=7'b1000110;		//0110001;
	assign hex[13]=7'b0100001;		//1000010;
	assign hex[14]=7'b0110000;		//0000110;
	assign hex[15]=7'b0001110;		//0111000;

endmodule

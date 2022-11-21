


// Bit by Bit Multiply & Divide + Modulus
// Copyright © 2022 by Gregory Scott Callen
// All Rights Reserved.

// Migration from JavaScript to Verilog.

module mul (
   input wire       t,
   input wire [9:0] a,
   input wire [9:0] b,
   output reg [9:0] p
);

   // p = a * b
   initial begin
      p = ~20'h0;
   end

   always @ ( posedge t ) begin

      p = 20'h0;

      p = a [ 0 ] & b [ 0 ] ? p + ( 20'h1 << 0 ) : p ;
      p = a [ 0 ] & b [ 1 ] ? p + ( 20'h1 << 1 ) : p ;
      p = a [ 0 ] & b [ 2 ] ? p + ( 20'h1 << 2 ) : p ;
      p = a [ 0 ] & b [ 3 ] ? p + ( 20'h1 << 3 ) : p ;
      p = a [ 0 ] & b [ 4 ] ? p + ( 20'h1 << 4 ) : p ;
      p = a [ 0 ] & b [ 5 ] ? p + ( 20'h1 << 5 ) : p ;
      p = a [ 0 ] & b [ 6 ] ? p + ( 20'h1 << 6 ) : p ;
      p = a [ 0 ] & b [ 7 ] ? p + ( 20'h1 << 7 ) : p ;
      p = a [ 0 ] & b [ 8 ] ? p + ( 20'h1 << 8 ) : p ;
      p = a [ 0 ] & b [ 9 ] ? p + ( 20'h1 << 9 ) : p ;

// Bit by Bit Multiply & Divide + Modulus
// Copyright © 2022 by Gregory Scott Callen
// All Rights Reserved.

      p = a [ 1 ] & b [ 0 ] ? p + ( 20'h1 << 1 ) : p ;
      p = a [ 1 ] & b [ 1 ] ? p + ( 20'h1 << 2 ) : p ;
      p = a [ 1 ] & b [ 2 ] ? p + ( 20'h1 << 3 ) : p ;
      p = a [ 1 ] & b [ 3 ] ? p + ( 20'h1 << 4 ) : p ;
      p = a [ 1 ] & b [ 4 ] ? p + ( 20'h1 << 5 ) : p ;
      p = a [ 1 ] & b [ 5 ] ? p + ( 20'h1 << 6 ) : p ;
      p = a [ 1 ] & b [ 6 ] ? p + ( 20'h1 << 7 ) : p ;
      p = a [ 1 ] & b [ 7 ] ? p + ( 20'h1 << 8 ) : p ;
      p = a [ 1 ] & b [ 8 ] ? p + ( 20'h1 << 9 ) : p ;
      p = a [ 1 ] & b [ 9 ] ? p + ( 20'h1 << 10 ) : p ;

// Bit by Bit Multiply & Divide + Modulus
// Copyright © 2022 by Gregory Scott Callen
// All Rights Reserved.

      p = a [ 2 ] & b [ 0 ] ? p + ( 20'h1 << 2 ) : p ;
      p = a [ 2 ] & b [ 1 ] ? p + ( 20'h1 << 3 ) : p ;
      p = a [ 2 ] & b [ 2 ] ? p + ( 20'h1 << 4 ) : p ;
      p = a [ 2 ] & b [ 3 ] ? p + ( 20'h1 << 5 ) : p ;
      p = a [ 2 ] & b [ 4 ] ? p + ( 20'h1 << 6 ) : p ;
      p = a [ 2 ] & b [ 5 ] ? p + ( 20'h1 << 7 ) : p ;
      p = a [ 2 ] & b [ 6 ] ? p + ( 20'h1 << 8 ) : p ;
      p = a [ 2 ] & b [ 7 ] ? p + ( 20'h1 << 9 ) : p ;
      p = a [ 2 ] & b [ 8 ] ? p + ( 20'h1 << 10 ) : p ;
      p = a [ 2 ] & b [ 9 ] ? p + ( 20'h1 << 11 ) : p ;

// Bit by Bit Multiply & Divide + Modulus
// Copyright © 2022 by Gregory Scott Callen
// All Rights Reserved.

      p = a [ 3 ] & b [ 0 ] ? p + ( 20'h1 << 3 ) : p ;
      p = a [ 3 ] & b [ 1 ] ? p + ( 20'h1 << 4 ) : p ;
      p = a [ 3 ] & b [ 2 ] ? p + ( 20'h1 << 5 ) : p ;
      p = a [ 3 ] & b [ 3 ] ? p + ( 20'h1 << 6 ) : p ;
      p = a [ 3 ] & b [ 4 ] ? p + ( 20'h1 << 7 ) : p ;
      p = a [ 3 ] & b [ 5 ] ? p + ( 20'h1 << 8 ) : p ;
      p = a [ 3 ] & b [ 6 ] ? p + ( 20'h1 << 9 ) : p ;
      p = a [ 3 ] & b [ 7 ] ? p + ( 20'h1 << 10 ) : p ;
      p = a [ 3 ] & b [ 8 ] ? p + ( 20'h1 << 11 ) : p ;
      p = a [ 3 ] & b [ 9 ] ? p + ( 20'h1 << 12 ) : p ;

// Bit by Bit Multiply & Divide + Modulus
// Copyright © 2022 by Gregory Scott Callen
// All Rights Reserved.

      p = a [ 4 ] & b [ 0 ] ? p + ( 20'h1 << 4 ) : p ;
      p = a [ 4 ] & b [ 1 ] ? p + ( 20'h1 << 5 ) : p ;
      p = a [ 4 ] & b [ 2 ] ? p + ( 20'h1 << 6 ) : p ;
      p = a [ 4 ] & b [ 3 ] ? p + ( 20'h1 << 7 ) : p ;
      p = a [ 4 ] & b [ 4 ] ? p + ( 20'h1 << 8 ) : p ;
      p = a [ 4 ] & b [ 5 ] ? p + ( 20'h1 << 9 ) : p ;
      p = a [ 4 ] & b [ 6 ] ? p + ( 20'h1 << 10 ) : p ;
      p = a [ 4 ] & b [ 7 ] ? p + ( 20'h1 << 11 ) : p ;
      p = a [ 4 ] & b [ 8 ] ? p + ( 20'h1 << 12 ) : p ;
      p = a [ 4 ] & b [ 9 ] ? p + ( 20'h1 << 13 ) : p ;

// Bit by Bit Multiply & Divide + Modulus
// Copyright © 2022 by Gregory Scott Callen
// All Rights Reserved.

      p = a [ 5 ] & b [ 0 ] ? p + ( 20'h1 << 5 ) : p ;
      p = a [ 5 ] & b [ 1 ] ? p + ( 20'h1 << 6 ) : p ;
      p = a [ 5 ] & b [ 2 ] ? p + ( 20'h1 << 7 ) : p ;
      p = a [ 5 ] & b [ 3 ] ? p + ( 20'h1 << 8 ) : p ;
      p = a [ 5 ] & b [ 4 ] ? p + ( 20'h1 << 9 ) : p ;
      p = a [ 5 ] & b [ 5 ] ? p + ( 20'h1 << 10 ) : p ;
      p = a [ 5 ] & b [ 6 ] ? p + ( 20'h1 << 11 ) : p ;
      p = a [ 5 ] & b [ 7 ] ? p + ( 20'h1 << 12 ) : p ;
      p = a [ 5 ] & b [ 8 ] ? p + ( 20'h1 << 13 ) : p ;
      p = a [ 5 ] & b [ 9 ] ? p + ( 20'h1 << 14 ) : p ;

// Bit by Bit Multiply & Divide + Modulus
// Copyright © 2022 by Gregory Scott Callen
// All Rights Reserved.

      p = a [ 6 ] & b [ 0 ] ? p + ( 20'h1 << 6 ) : p ;
      p = a [ 6 ] & b [ 1 ] ? p + ( 20'h1 << 7 ) : p ;
      p = a [ 6 ] & b [ 2 ] ? p + ( 20'h1 << 8 ) : p ;
      p = a [ 6 ] & b [ 3 ] ? p + ( 20'h1 << 9 ) : p ;
      p = a [ 6 ] & b [ 4 ] ? p + ( 20'h1 << 10 ) : p ;
      p = a [ 6 ] & b [ 5 ] ? p + ( 20'h1 << 11 ) : p ;
      p = a [ 6 ] & b [ 6 ] ? p + ( 20'h1 << 12 ) : p ;
      p = a [ 6 ] & b [ 7 ] ? p + ( 20'h1 << 13 ) : p ;
      p = a [ 6 ] & b [ 8 ] ? p + ( 20'h1 << 14 ) : p ;
      p = a [ 6 ] & b [ 9 ] ? p + ( 20'h1 << 15 ) : p ;

// Bit by Bit Multiply & Divide + Modulus
// Copyright © 2022 by Gregory Scott Callen
// All Rights Reserved.

      p = a [ 7 ] & b [ 0 ] ? p + ( 20'h1 << 7 ) : p ;
      p = a [ 7 ] & b [ 1 ] ? p + ( 20'h1 << 8 ) : p ;
      p = a [ 7 ] & b [ 2 ] ? p + ( 20'h1 << 9 ) : p ;
      p = a [ 7 ] & b [ 3 ] ? p + ( 20'h1 << 10 ) : p ;
      p = a [ 7 ] & b [ 4 ] ? p + ( 20'h1 << 11 ) : p ;
      p = a [ 7 ] & b [ 5 ] ? p + ( 20'h1 << 12 ) : p ;
      p = a [ 7 ] & b [ 6 ] ? p + ( 20'h1 << 13 ) : p ;
      p = a [ 7 ] & b [ 7 ] ? p + ( 20'h1 << 14 ) : p ;
      p = a [ 7 ] & b [ 8 ] ? p + ( 20'h1 << 15 ) : p ;
      p = a [ 7 ] & b [ 9 ] ? p + ( 20'h1 << 16 ) : p ;

// Bit by Bit Multiply & Divide + Modulus
// Copyright © 2022 by Gregory Scott Callen
// All Rights Reserved.

      p = a [ 8 ] & b [ 0 ] ? p + ( 20'h1 << 8 ) : p ;
      p = a [ 8 ] & b [ 1 ] ? p + ( 20'h1 << 9 ) : p ;
      p = a [ 8 ] & b [ 2 ] ? p + ( 20'h1 << 10 ) : p ;
      p = a [ 8 ] & b [ 3 ] ? p + ( 20'h1 << 11 ) : p ;
      p = a [ 8 ] & b [ 4 ] ? p + ( 20'h1 << 12 ) : p ;
      p = a [ 8 ] & b [ 5 ] ? p + ( 20'h1 << 13 ) : p ;
      p = a [ 8 ] & b [ 6 ] ? p + ( 20'h1 << 14 ) : p ;
      p = a [ 8 ] & b [ 7 ] ? p + ( 20'h1 << 15 ) : p ;
      p = a [ 8 ] & b [ 8 ] ? p + ( 20'h1 << 16 ) : p ;
      p = a [ 8 ] & b [ 9 ] ? p + ( 20'h1 << 17 ) : p ;

// Bit by Bit Multiply & Divide + Modulus
// Copyright © 2022 by Gregory Scott Callen
// All Rights Reserved.

      p = a [ 9 ] & b [ 0 ] ? p + ( 20'h1 << 9 ) : p ;
      p = a [ 9 ] & b [ 1 ] ? p + ( 20'h1 << 10 ) : p ;
      p = a [ 9 ] & b [ 2 ] ? p + ( 20'h1 << 11 ) : p ;
      p = a [ 9 ] & b [ 3 ] ? p + ( 20'h1 << 12 ) : p ;
      p = a [ 9 ] & b [ 4 ] ? p + ( 20'h1 << 13 ) : p ;
      p = a [ 9 ] & b [ 5 ] ? p + ( 20'h1 << 14 ) : p ;
      p = a [ 9 ] & b [ 6 ] ? p + ( 20'h1 << 15 ) : p ;
      p = a [ 9 ] & b [ 7 ] ? p + ( 20'h1 << 16 ) : p ;
      p = a [ 9 ] & b [ 8 ] ? p + ( 20'h1 << 17 ) : p ;
      p = a [ 9 ] & b [ 9 ] ? p + ( 20'h1 << 18 ) : p ;

// Bit by Bit Multiply & Divide + Modulus
// Copyright © 2022 by Gregory Scott Callen
// All Rights Reserved.

   end 

endmodule    // 72897 = 517 * 141

// Bit by Bit Multiply & Divide + Modulus
// Copyright © 2022 by Gregory Scott Callen
// All Rights Reserved.

module div (
   input wire       t,
   input wire [9:0] a,
   input wire [9:0] b,
   output reg [9:0] n,
   output reg [9:0] r
);

   initial begin
      n = ~20'h0;
      r = ~20'h0;
   end

   always @ ( posedge t ) begin

      r = a; n = 20'd0; 

      if (( b << 9n ) <= r ) begin
         n = n | 20'd512;
         r = b [ 9 ] ? r - ( 20'd1 << 18 ) : r ;
         r = b [ 8 ] ? r - ( 20'd1 << 17 ) : r ;
         r = b [ 7 ] ? r - ( 20'd1 << 16 ) : r ;
         r = b [ 6 ] ? r - ( 20'd1 << 15 ) : r ;
         r = b [ 5 ] ? r - ( 20'd1 << 14 ) : r ;
         r = b [ 4 ] ? r - ( 20'd1 << 13 ) : r ;
         r = b [ 3 ] ? r - ( 20'd1 << 12 ) : r ;
         r = b [ 2 ] ? r - ( 20'd1 << 11 ) : r ;
         r = b [ 1 ] ? r - ( 20'd1 << 10 ) : r ;
         r = b [ 0 ] ? r - ( 20'd1 << 9 ) : r ;
      end

// Bit by Bit Multiply & Divide + Modulus
// Copyright © 2022 by Gregory Scott Callen
// All Rights Reserved.

      if (( b << 8n ) <= r ) begin
         n = n | 20'd256;
         r = b [ 9 ] ? r - ( 20'd1 << 17 ) : r ;
         r = b [ 8 ] ? r - ( 20'd1 << 16 ) : r ;
         r = b [ 7 ] ? r - ( 20'd1 << 15 ) : r ;
         r = b [ 6 ] ? r - ( 20'd1 << 14 ) : r ;
         r = b [ 5 ] ? r - ( 20'd1 << 13 ) : r ;
         r = b [ 4 ] ? r - ( 20'd1 << 12 ) : r ;
         r = b [ 3 ] ? r - ( 20'd1 << 11 ) : r ;
         r = b [ 2 ] ? r - ( 20'd1 << 10 ) : r ;
         r = b [ 1 ] ? r - ( 20'd1 << 9 ) : r ;
         r = b [ 0 ] ? r - ( 20'd1 << 8 ) : r ;
      end

// Bit by Bit Multiply & Divide + Modulus
// Copyright © 2022 by Gregory Scott Callen
// All Rights Reserved.

      if (( b << 7n ) <= r ) begin
         n = n | 20'd128;
         r = b [ 9 ] ? r - ( 20'd1 << 16 ) : r ;
         r = b [ 8 ] ? r - ( 20'd1 << 15 ) : r ;
         r = b [ 7 ] ? r - ( 20'd1 << 14 ) : r ;
         r = b [ 6 ] ? r - ( 20'd1 << 13 ) : r ;
         r = b [ 5 ] ? r - ( 20'd1 << 12 ) : r ;
         r = b [ 4 ] ? r - ( 20'd1 << 11 ) : r ;
         r = b [ 3 ] ? r - ( 20'd1 << 10 ) : r ;
         r = b [ 2 ] ? r - ( 20'd1 << 9 ) : r ;
         r = b [ 1 ] ? r - ( 20'd1 << 8 ) : r ;
         r = b [ 0 ] ? r - ( 20'd1 << 7 ) : r ;
      end

// Bit by Bit Multiply & Divide + Modulus
// Copyright © 2022 by Gregory Scott Callen
// All Rights Reserved.

      if (( b << 6n ) <= r ) begin
         n = n | 20'd64;
         r = b [ 9 ] ? r - ( 20'd1 << 15 ) : r ;
         r = b [ 8 ] ? r - ( 20'd1 << 14 ) : r ;
         r = b [ 7 ] ? r - ( 20'd1 << 13 ) : r ;
         r = b [ 6 ] ? r - ( 20'd1 << 12 ) : r ;
         r = b [ 5 ] ? r - ( 20'd1 << 11 ) : r ;
         r = b [ 4 ] ? r - ( 20'd1 << 10 ) : r ;
         r = b [ 3 ] ? r - ( 20'd1 << 9 ) : r ;
         r = b [ 2 ] ? r - ( 20'd1 << 8 ) : r ;
         r = b [ 1 ] ? r - ( 20'd1 << 7 ) : r ;
         r = b [ 0 ] ? r - ( 20'd1 << 6 ) : r ;
      end

// Bit by Bit Multiply & Divide + Modulus
// Copyright © 2022 by Gregory Scott Callen
// All Rights Reserved.

      if (( b << 5n ) <= r ) begin
         n = n | 20'd32;
         r = b [ 9 ] ? r - ( 20'd1 << 14 ) : r ;
         r = b [ 8 ] ? r - ( 20'd1 << 13 ) : r ;
         r = b [ 7 ] ? r - ( 20'd1 << 12 ) : r ;
         r = b [ 6 ] ? r - ( 20'd1 << 11 ) : r ;
         r = b [ 5 ] ? r - ( 20'd1 << 10 ) : r ;
         r = b [ 4 ] ? r - ( 20'd1 << 9 ) : r ;
         r = b [ 3 ] ? r - ( 20'd1 << 8 ) : r ;
         r = b [ 2 ] ? r - ( 20'd1 << 7 ) : r ;
         r = b [ 1 ] ? r - ( 20'd1 << 6 ) : r ;
         r = b [ 0 ] ? r - ( 20'd1 << 5 ) : r ;
      end

// Bit by Bit Multiply & Divide + Modulus
// Copyright © 2022 by Gregory Scott Callen
// All Rights Reserved.

      if (( b << 4n ) <= r ) begin
         n = n | 20'd16;
         r = b [ 9 ] ? r - ( 20'd1 << 13 ) : r ;
         r = b [ 8 ] ? r - ( 20'd1 << 12 ) : r ;
         r = b [ 7 ] ? r - ( 20'd1 << 11 ) : r ;
         r = b [ 6 ] ? r - ( 20'd1 << 10 ) : r ;
         r = b [ 5 ] ? r - ( 20'd1 << 9 ) : r ;
         r = b [ 4 ] ? r - ( 20'd1 << 8 ) : r ;
         r = b [ 3 ] ? r - ( 20'd1 << 7 ) : r ;
         r = b [ 2 ] ? r - ( 20'd1 << 6 ) : r ;
         r = b [ 1 ] ? r - ( 20'd1 << 5 ) : r ;
         r = b [ 0 ] ? r - ( 20'd1 << 4 ) : r ;
      end

// Bit by Bit Multiply & Divide + Modulus
// Copyright © 2022 by Gregory Scott Callen
// All Rights Reserved.

      if (( b << 3n ) <= r ) begin
         n = n | 20'd8;
         r = b [ 9 ] ? r - ( 20'd1 << 12 ) : r ;
         r = b [ 8 ] ? r - ( 20'd1 << 11 ) : r ;
         r = b [ 7 ] ? r - ( 20'd1 << 10 ) : r ;
         r = b [ 6 ] ? r - ( 20'd1 << 9 ) : r ;
         r = b [ 5 ] ? r - ( 20'd1 << 8 ) : r ;
         r = b [ 4 ] ? r - ( 20'd1 << 7 ) : r ;
         r = b [ 3 ] ? r - ( 20'd1 << 6 ) : r ;
         r = b [ 2 ] ? r - ( 20'd1 << 5 ) : r ;
         r = b [ 1 ] ? r - ( 20'd1 << 4 ) : r ;
         r = b [ 0 ] ? r - ( 20'd1 << 3 ) : r ;
      end

// Bit by Bit Multiply & Divide + Modulus
// Copyright © 2022 by Gregory Scott Callen
// All Rights Reserved.

      if (( b << 2n ) <= r ) begin
         n = n | 20'd4;
         r = b [ 9 ] ? r - ( 20'd1 << 11 ) : r ;
         r = b [ 8 ] ? r - ( 20'd1 << 10 ) : r ;
         r = b [ 7 ] ? r - ( 20'd1 << 9 ) : r ;
         r = b [ 6 ] ? r - ( 20'd1 << 8 ) : r ;
         r = b [ 5 ] ? r - ( 20'd1 << 7 ) : r ;
         r = b [ 4 ] ? r - ( 20'd1 << 6 ) : r ;
         r = b [ 3 ] ? r - ( 20'd1 << 5 ) : r ;
         r = b [ 2 ] ? r - ( 20'd1 << 4 ) : r ;
         r = b [ 1 ] ? r - ( 20'd1 << 3 ) : r ;
         r = b [ 0 ] ? r - ( 20'd1 << 2 ) : r ;
      end

// Bit by Bit Multiply & Divide + Modulus
// Copyright © 2022 by Gregory Scott Callen
// All Rights Reserved.

      if (( b << 1n ) <= r ) begin
         n = n | 20'd2;
         r = b [ 9 ] ? r - ( 20'd1 << 10 ) : r ;
         r = b [ 8 ] ? r - ( 20'd1 << 9 ) : r ;
         r = b [ 7 ] ? r - ( 20'd1 << 8 ) : r ;
         r = b [ 6 ] ? r - ( 20'd1 << 7 ) : r ;
         r = b [ 5 ] ? r - ( 20'd1 << 6 ) : r ;
         r = b [ 4 ] ? r - ( 20'd1 << 5 ) : r ;
         r = b [ 3 ] ? r - ( 20'd1 << 4 ) : r ;
         r = b [ 2 ] ? r - ( 20'd1 << 3 ) : r ;
         r = b [ 1 ] ? r - ( 20'd1 << 2 ) : r ;
         r = b [ 0 ] ? r - ( 20'd1 << 1 ) : r ;
      end

// Bit by Bit Multiply & Divide + Modulus
// Copyright © 2022 by Gregory Scott Callen
// All Rights Reserved.

      if (( b << 0n ) <= r ) begin
         n = n | 20'd1;
         r = b [ 9 ] ? r - ( 20'd1 << 9 ) : r ;
         r = b [ 8 ] ? r - ( 20'd1 << 8 ) : r ;
         r = b [ 7 ] ? r - ( 20'd1 << 7 ) : r ;
         r = b [ 6 ] ? r - ( 20'd1 << 6 ) : r ;
         r = b [ 5 ] ? r - ( 20'd1 << 5 ) : r ;
         r = b [ 4 ] ? r - ( 20'd1 << 4 ) : r ;
         r = b [ 3 ] ? r - ( 20'd1 << 3 ) : r ;
         r = b [ 2 ] ? r - ( 20'd1 << 2 ) : r ;
         r = b [ 1 ] ? r - ( 20'd1 << 1 ) : r ;
         r = b [ 0 ] ? r - ( 20'd1 << 0 ) : r ;
      end

// Bit by Bit Multiply & Divide + Modulus
// Copyright © 2022 by Gregory Scott Callen
// All Rights Reserved.

   end

   // 524 = 72897 / 139 r 61

endmodule

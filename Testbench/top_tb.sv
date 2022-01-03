module top_tb();
//////////// CLOCK //////////
reg                       CLOCK_50;

//////////// LED //////////
wire           [9:0]      LEDR;

//////////// KEY //////////
reg           [3:0]      KEY;

//////////// SW //////////
reg            [9:0]      SW;

//////////// SEG7 //////////
wire           [6:0]      HEX0;
wire          [6:0]      HEX1;
wire           [6:0]      HEX2;
wire           [6:0]      HEX3;
wire          [6:0]      HEX4;
wire          [6:0]      HEX5;


top  DUT(CLOCK_50, KEY, SW, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);

initial begin
     CLOCK_50 = 0; #5;
     forever begin
      CLOCK_50 = 1; #5;
      CLOCK_50 = 0; #5;
     end
end

initial begin
SW [9:0] = 10'b1001001001;
KEY [3] = 1'b0;
#20;
KEY[3] = 1'b1;


end

endmodule

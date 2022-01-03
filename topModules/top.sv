module top(CLOCK_50, KEY, SW, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
//////////// CLOCK //////////
input                       CLOCK_50;

//////////// LED //////////
output           [9:0]      LEDR;

//////////// KEY //////////
input            [3:0]      KEY;

//////////// SW //////////
input            [9:0]      SW;

//////////// SEG7 //////////
output           [6:0]      HEX0;
output           [6:0]      HEX1;
output           [6:0]      HEX2;
output           [6:0]      HEX3;
output           [6:0]      HEX4;
output           [6:0]      HEX5;



logic CLK_50M;
logic reset_n;
assign CLK_50M =  CLOCK_50;
assign reset_n = ~KEY[3];

wire finished, write, finished_shuffle, write_shuffle, a_sel, data_sel, write_sel;
wire [7:0] address, data, read_data, shuffle_address;
reg start;

initial begin
start =1'b1;
#20;
start = 1'b0;
end


initialize_mem initialize(.clk(CLK_50M), .start(start), .finished(finished), .write(write), .address(address), 
							     .finished_shuffle(finished_shuffle) );

M10K_256_32 mem(.clk(CLK_50M), .read_address(a_sel ? shuffle_address : address), .write_address(a_sel ? shuffle_address : address), 
		.d(data_sel ? data : address), .we(write_sel ? write_shuffle : write), .q(read_data));

shuffle   shuffle_module(.clk(CLK_50M), .start(finished), .finished(finished_shuffle), 
							    .secret_key({14'b0, SW[9:0]}), .read_data(read_data), .write_en(write_shuffle), .data(data), 
							    .address_out(shuffle_address));
	
SevenSegmentDisplayDecoder ssdd(.ssOut(), .nIn());

flopr_en reg_a_sel(.clk(CLK_50M), .clr(start), .d(1'b1), .q(a_sel), .en(finished));
flopr_en reg_data_sel(.clk(CLK_50M), .clr(start), .d(1'b1), .q(data_sel), .en(finished));
flopr_en reg_write_sel(.clk(CLK_50M), .clr(start), .d(1'b1), .q(write_sel), .en(finished));

endmodule 

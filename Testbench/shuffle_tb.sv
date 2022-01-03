module shuffle_tb();

reg clk, start;
reg [23:0] secret_key;
reg [7:0] read_data;
wire finished, write_en;
wire [7:0] data, address_out;

shuffle DUT(.clk(clk), .start(start), .secret_key(secret_key), .read_data(read_data), .finished(finished), 
	    .write_en(write_en), .data(data), .address_out(address_out));


initial begin
     clk = 0; #5;
     forever begin
      clk = 1; #5;
      clk = 0; #5;
     end
end

initial begin
start = 1'b0;
secret_key = 24'h000249;
read_data = 8'b0000_1000;
#10;
start = 1'b1;
#10;
start = 1'b0;
#140;
read_data = 8'b1111_0000;
#150; 
read_data = 8'b0001_0000;



end

endmodule 

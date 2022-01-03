module decrypt_tb();
reg clk, start;
reg  [7:0] read_data, read_encrypt_data;
wire finished, write_en_d, write_en_s;
wire [7:0] data, address_s;
wire [7:0] address_e;


decrypt  DUT(clk, start, finished, read_data, write_en_s, data, address_s, address_e, write_en_d, read_encrypt_data);


initial begin
     clk = 0; #5;
     forever begin
      clk = 1; #5;
      clk = 0; #5;
     end
end

initial begin
#10
start = 1'b1;
read_data = 8'b1010_0000;
read_encrypt_data = 8'b1010_0000;
#10;
start = 1'b0;
#185;
read_data = 8'b1010_1111;
read_encrypt_data = 8'b1010_1111;
#7700;
$stop;
end

endmodule

module check_message_tb();
reg clk, start;
wire finished, LED;
reg [7:0] decrypt_data;
wire [7:0] address_for_check;



check_message DUT(clk, start, finished, decrypt_data, address_for_check, LED);

initial begin
     clk = 0; #5;
     forever begin
      clk = 1; #5;
      clk = 0; #5;
     end
end

initial begin
start = 1'b1;
decrypt_data = 8'd100;
#1500;
decrypt_data = 8'd200;
#200;
decrypt_data = 8'd100;

end

endmodule

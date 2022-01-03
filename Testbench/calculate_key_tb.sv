module calculate_key_tb();
reg clk, start;
wire finished;
reg [23:0] secret_key_in;
wire [23:0] secret_key_out;

calculate_key DUT(clk, start, finished, secret_key_out, secret_key_out, LED1);


initial begin
     clk = 0; #5;
     forever begin
      clk = 1; #5;
      clk = 0; #5;
     end
end

initial begin
     forever begin
       secret_key_in = secret_key_out; #65;
     end
end


initial begin
start = 1'b1;
end


endmodule

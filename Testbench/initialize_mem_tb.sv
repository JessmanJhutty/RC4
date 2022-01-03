module initialize_mem_tb();
reg clk, start, finished_shuffle;
wire write, finished;
wire [7:0] address;

initialize_mem  DUT(.clk(clk), .start(start), .write(write), .finished(finished), .address(address), .finished_shuffle(finished_shuffle));

initial begin
     clk = 0; #5;
     forever begin
      clk = 1; #5;
      clk = 0; #5;
     end
end

initial begin
start = 1'b1;
finished_shuffle = 1'b0;
#30;
start = 1'b0;
#4000;
finished_shuffle = 1'b1;

end 


endmodule

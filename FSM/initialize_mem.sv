module initialize_mem(clk, start, write, finished, address, finished_shuffle);

input clk, start, finished_shuffle;
output write, finished;
output [7:0] address;

wire update_data, reset, add;

reg [7:0] count;
reg [8:0] state;

parameter idle            = 9'b0000_00000;
parameter reset_count     = 9'b0001_00001;
parameter check_counter   = 9'b0010_00000;
parameter update_mem      = 9'b0011_00010;
parameter write_mem       = 9'b0100_00100;
parameter increment_count = 9'b0101_10000;
parameter reset_counter   = 9'b0110_00001;
parameter finish          = 9'b0111_01000;
parameter finish1         = 9'b1000_01000;
parameter wait_for_finish = 9'b1001_00000;

parameter update_mem1      = 9'b1011_00010;
parameter write_mem1       = 9'b1100_00100;

assign reset        = state[0];
assign update_data  = state[1];
assign write        = state[2];
assign finished     = state[3];
assign add          = state[4];


always_ff @(posedge clk) begin
case(state)
  idle: begin
	 if (start) begin
		state <= reset_count; // reset count
	  end
	end
  reset_count: state <= check_counter;
  check_counter: begin 
		  if (count == 8'd255) // if i is 255 then run protocol once more and finish
	            state <= update_mem1; 
		  else
		    state <= update_mem; // otherwise update dat
		 end 
  update_mem: state <= write_mem; // go to write the data
  write_mem: state <= increment_count; // once data is written increment the count
  increment_count: state <= check_counter; // go back to check what value the counter is
  update_mem1: state <= write_mem1;
  write_mem1: state <= reset_counter;
  reset_counter: state <= finish;
  finish: state <= finish1;
  finish1: state <= wait_for_finish;
  wait_for_finish: begin 
	            if (finished_shuffle == 1'b1) // wait for a finish signal 
	             state <= idle;
	            else
	             state <= wait_for_finish;
	           end 
  default: state <= idle;
endcase  
end


flopr_en #(8)    address_update(.clk(clk), .clr(reset), .d(count), .q(address), .en(update_data)); // updates the address to be count
flopr_en #(8)   counter_add (.clk(clk), .clr(reset), .d(count+1'b1), .q(count), .en(add)); //updates the count

endmodule

module flopr_en(clk, clr, d, q, en); // flip flop module with asynchronous clear and enable
 parameter n = 1;
 input clk, clr, en;
 input [n-1:0] d;
 output reg [n-1:0] q;
 wire [n-1:0] next_out;
 
 assign next_out = en ? d : q;

 always @(posedge clk or posedge clr) begin
   if(clr) q <= {n{1'b0}};
   else q <= next_out;
 end 

endmodule

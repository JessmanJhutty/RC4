module check_message(clk, start, finished, decrypt_data, address_for_check, LED);
input clk, start;
output finished, LED;
input [7:0] decrypt_data;
output [7:0] address_for_check;

wire reset, add_k, update_addr;

parameter idle 			= 9'b0000_00000;
parameter reset_all		= 9'b0001_00001;
parameter check_k 		= 9'b0010_00000;
parameter light_LED		= 9'b0011_01000;
parameter wait_clock1 		= 9'b0100_00000;
parameter wait_clock2 		= 9'b0101_00000;
parameter check_data 		= 9'b0110_00000;
parameter increment_k 		= 9'b0111_00010;
parameter update_address 	= 9'b1000_00100;
parameter finish 		= 9'b1001_10000;
parameter finish1 		= 9'b1010_10000;

reg [7:0] k;
reg [8:0] state;

assign reset = state[0];
assign add_k = state[1];
assign update_addr = state[2];
assign LED = state[3];
assign finished = state[4];

always_ff @(posedge clk) begin
case(state)
  idle: begin
	 if (start) begin
		state <= reset_all; // goes to reset 
	  end
	end
   reset_all: state <= check_k; // checks the k counter
   check_k: begin 
	     if (k == 8'd32)
	       state <= light_LED; // if k is 32 that means code is broken and go to light led
	     else
	       state <= wait_clock1; //go to read
	     end
   light_LED: state <= light_LED; // infinite loop in which it lights up the LED
   wait_clock1: state <= wait_clock2; // wait states to wait for read data
   wait_clock2: state <= check_data;
   check_data: begin 
	   	 if ((decrypt_data >= 8'd97 & decrypt_data <=8'd122) | decrypt_data == 8'd32) // if data is a letter or a space check the next address
	          state <= increment_k;
	         else
	          state <= finish; // otherwise send a finish
	       end
   increment_k: state <= update_address; // update address
   update_address: state <= check_k; // go back to the loop
   finish: state <= finish1;
   finish1: state <= idle;
default: state <= idle; 
endcase
end


flopr_en #(8)   update_k(.clk(clk), .clr(reset), .d(k+1'b1), .q(k), .en(add_k)); // flip flop for reg k

flopr_en #(8)   update_a (.clk(clk), .clr(reset), .d(k), .q(address_for_check), .en(update_addr)); // flip flop for address 

endmodule

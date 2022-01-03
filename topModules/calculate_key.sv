module calculate_key(clk, start, finish, secret_key_in, secret_key_out, LED1);
input clk, start;
output finish, LED1;
input [23:0] secret_key_in;
output [23:0] secret_key_out;
wire reset, update;

parameter idle      		= 8'b0000_0000;
parameter finished  		= 8'b0001_0001;
parameter finished1 		= 8'b0010_0001;
parameter update_key      	= 8'b0011_0010;
parameter check      		= 8'b0100_0000;
parameter light_led1      	= 8'b0101_0100;
parameter check_reset 		= 8'b0111_0000;
parameter reset_key       	= 8'b0110_1000;

reg [7:0] state;


assign finish = state[0];
assign update = state[1];
assign LED1   = state[2];
assign reset  = state[3];

always_ff @(posedge clk) begin
case(state)
  idle: begin
	 if (start) begin
		state <= update_key; // when given start signal update the key
	  end
	end
  update_key: state <= check_reset; // gives +1 to secret key and goes to reset
  check_reset:  begin 
	   	  if (secret_key_out) // if key is 1 then check if key is max otherwise reset the key and finish
	           state <= check;
	          else
	           state <= reset_key;
	        end
  reset_key: state <= finished;
  check:  begin 
	   if (secret_key_in == 24'b0100_0000_0000_0000_0000_0000) // check if key is max, the 2 most significant bits are 0 
	    state <= light_led1;
	   else
	    state <= finished; // if it is not max then finish the state machine.
	  end
  light_led1: state <= light_led1;
  finished: state <= finished1;
  finished1: state <= idle;
  default: state <= idle;
endcase
end


flopr_en #(24)   update_secret_key (.clk(clk), .clr(reset), .d(secret_key_in+1'b1), .q(secret_key_out), .en(update)); 


endmodule



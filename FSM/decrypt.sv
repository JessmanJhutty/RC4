module decrypt(clk, start, finished, read_data, write_en_s, data, address_s, address_e, write_en_d, read_encrypt_data);
input clk, start;
input [7:0] read_data, read_encrypt_data;
output finished, write_en_d, write_en_s;
output [7:0] data, address_s;
output [7:0] address_e;

wire reset, add, update_addr_i, update_j, update_addr_j, store_data_i, store_data_j, update_data_i, update_data_j,
     update_addr_i_j, update_addr_k, update_f, store_encrypt, update_data_f, increment_k;

wire [7:0] mem_i, mem_j, mem_e, f;

parameter idle 					= 24'b000000_000_000_000_000_000_000;
parameter reset_all                		= 24'b000001_000_000_000_000_000_001;
parameter check_k                     		= 24'b000010_000_000_000_000_000_000;
parameter increment_i                   	= 24'b000011_000_000_000_000_000_010;
parameter update_address_i  		   	= 24'b000100_000_000_000_000_000_100;
parameter wait_clock1 			   	= 24'b000101_000_000_000_000_000_000;
parameter wait_clock2 				= 24'b000110_000_000_000_000_000_000;
parameter update_j_store_i 			= 24'b000111_000_000_000_000_101_000;
parameter update_address_j 			= 24'b001000_000_000_000_000_010_000;
parameter wait_clock3 				= 24'b001001_000_000_000_000_000_000;
parameter wait_clock4 				= 24'b001010_000_000_000_000_000_000;
parameter store_j_update_data_i 		= 24'b001011_000_000_000_011_000_000;
parameter write_j_i 				= 24'b001100_001_000_000_000_000_000;
parameter update_address_i_update_data_j 	= 24'b001101_000_000_000_100_000_100;
parameter write_i_j 				= 24'b001110_001_000_000_000_000_000;
parameter update_address_i_j 			= 24'b001111_000_000_001_000_000_000;
parameter wait_clock5 				= 24'b010000_000_000_000_000_000_000;
parameter wait_clock6 				= 24'b010001_000_000_000_000_000_000;
parameter update_f_address_k 			= 24'b010010_000_000_110_000_000_000;
parameter wait_clock7 				= 24'b010011_000_000_000_000_000_000;
parameter wait_clock8 				= 24'b010100_000_000_000_000_000_000;
parameter store_encr 				= 24'b010101_000_001_000_000_000_000;
parameter up_data_f 				= 24'b010110_000_010_000_000_000_000;
parameter write_f 				= 24'b010111_010_000_000_000_000_000;
parameter k_adder 				= 24'b011000_000_100_000_000_000_000;
parameter reset_k				= 24'b011001_000_000_000_000_000_001;
parameter finish 				= 24'b011010_100_000_000_000_000_000;
parameter finish1 				= 24'b011011_100_000_000_000_000_000;



reg [7:0] k;
reg [7:0] i;
reg [7:0] j;
wire [7:0] xor_f = {f[7] ^ mem_e[7], f[6] ^ mem_e[6], f[5] ^ mem_e[5], f[4] ^ mem_e[4], f[3] ^ mem_e[3], f[2] ^ mem_e[2], f[1] ^ mem_e[1], f[0] ^ mem_e[0]}; // xor_f to represent the xor 8 bit wide gate
reg [23:0] state;


assign reset          = state[0];
assign add            = state[1];
assign update_addr_i  = state[2];
assign update_j       = state[3];
assign update_addr_j  = state[4];
assign store_data_i   = state[5];
assign store_data_j   = state[6];
assign update_data_i  = state[7];
assign update_data_j  = state[8];
assign update_addr_i_j= state[9];
assign update_addr_k  = state[10];
assign update_f       = state[11];
assign store_encrypt  = state[12];
assign update_data_f  = state[13];
assign increment_k    = state[14];
assign write_en_s     = state[15];
assign write_en_d     = state[16];
assign finished       = state[17];


always_ff @(posedge clk) begin
case(state)
  idle: begin
	 if (start) begin
		state <= reset_all; // resets state
	  end
	end
   reset_all: state <= check_k; 
   check_k: begin 
	     if (k == 8'd32) // if k is 32 then reset k and finish
	       state <= reset_k;
	     else
	       state <= increment_i; // add i
	    end
   increment_i: state <= update_address_i; // update the address to i

   update_address_i: state <= wait_clock1; // wait states
   wait_clock1: state <= wait_clock2;
   wait_clock2: state <= update_j_store_i; //update j and store the data read from address i

   update_j_store_i: state <= update_address_j; // update the address to be j=
   update_address_j: state <= wait_clock3;
   wait_clock3: state <= wait_clock4;
   wait_clock4: state <= store_j_update_data_i; // store the data read from address j and store the data from address i to be data_out

   store_j_update_data_i: state <= write_j_i; // write s[j] to s[i]
   write_j_i: state <= update_address_i_update_data_j; // update the address to i and update data to s[j]
   update_address_i_update_data_j: state <= write_i_j; // write s[i] = s[j]
   write_i_j: state <= update_address_i_j; // update the addres to be s[i] + s[j]
   update_address_i_j: state <= wait_clock5;
   wait_clock5: state <= wait_clock6;
   wait_clock6: state <= update_f_address_k; // wait for the read deada and update f and set the address to k
   
   update_f_address_k: state <= wait_clock7;
   wait_clock7: state <= wait_clock8;
   wait_clock8: state <= store_encr; // wait for the encrypt data and store it

   store_encr: state <= up_data_f; // f becomes data_out
   up_data_f: state <= write_f; // write f to decrypt ram
   write_f: state <= k_adder; // add k
   k_adder: state <= check_k; // go back to loop

   reset_k: state <= finish;
   finish: state <= finish1;
   finish1: state <= idle; 
default state <= idle;
endcase
end



flopr_en #(8)   counter_add (.clk(clk), .clr(reset), .d(i+1'b1), .q(i), .en(add)); 

flopr_en #(8)   addr_i (.clk(clk), .clr(reset), .d(update_addr_i_j ? (mem_i + mem_j) : (update_addr_i ? i : j) ), 
			.q(address_s), .en(update_addr_i | update_addr_j | update_addr_i_j)); // selects which address to apply to address_s

flopr_en #(8)   j_update (.clk(clk), .clr(reset), .d(j+read_data), .q(j), .en(update_j));

//flopr_en #(8)   addr_j (.clk(clk), .clr(reset), .d(j), .q(address_s), .en(update_addr_j));

flopr_en #(8)   store_i (.clk(clk), .clr(reset), .d(read_data), .q(mem_i), .en(store_data_i));

flopr_en #(8)   store_j (.clk(clk), .clr(reset), .d(read_data), .q(mem_j), .en(store_data_j));

flopr_en #(8)   data_i (.clk(clk), .clr(reset), .d(update_data_f ? xor_f : (update_data_i ? mem_i : mem_j) ), 
			.q(data), .en(update_data_i | update_data_f | update_data_j) ); // selects which data to apply to data_out

//flopr_en #(8)   data_j (.clk(clk), .clr(reset), .d(mem_j), .q(data), .en(update_data_j));

//flopr_en #(8)   addr_i_j (.clk(clk), .clr(reset), .d(mem_i+mem_j), .q(address_s), .en(update_addr_i_j));

flopr_en #(8)   addr_k (.clk(clk), .clr(reset), .d(k), .q(address_e), .en(update_addr_k));

flopr_en #(8)   f_update (.clk(clk), .clr(reset), .d(read_data), .q(f), .en(update_f));

flopr_en #(8)   encrypt_mem_store (.clk(clk), .clr(reset), .d(read_encrypt_data), .q(mem_e), .en(store_encrypt));

//flopr_en #(8)   data_f (.clk(clk), .clr(reset), .d(xor_f), .q(data), .en(update_data_f));

flopr_en #(8)   add_k (.clk(clk), .clr(reset), .d(k+1'b1), .q(k), .en(increment_k));



endmodule

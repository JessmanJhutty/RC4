module ksa(CLOCK_50, KEY, SW, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
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

wire finished, write, finished_shuffle, write_shuffle, a_sel, data_sel, write_sel, finished_rest, write_en_d, write_en_s;
wire [7:0] address, data, read_data, shuffle_address, address_e, address_s, encrypt_data, write_data, 
			  decrypt_data, address_for_check;
reg start, start_shuffle;
wire a_select, data_select, write_select, finished_all, finished_check_message, address_decrypt;

wire [23:0] secret_key;
//assign secret_key = {14'b0, SW[9:0]};

initialize_mem initialize(.clk(CLK_50M), .start(finished_all), .finished(finished), .write(write), .address(address), 
							     .finished_shuffle(finished_rest) ); //initializes the memory, task 1

s_memory mem(.clock(CLK_50M), .address(a_select ? address_s : (a_sel ? shuffle_address : address)), 
				 .data(data_select ? write_data : (data_sel ? data : address) ), 
				 .wren(write_select ? write_en_s : (write_sel ? write_shuffle : write) ), .q(read_data)); // s memory instantiation

shuffle   shuffle_module(.clk(CLK_50M), .start(finished), .finished(finished_shuffle), 
							    .secret_key(secret_key), .read_data(read_data), .write_en(write_shuffle), .data(data), 
							    .address_out(shuffle_address), .finish_rest(finished_rest)); // shuffles the memory task 2a

decrypt  decrypt1(.clk(CLK_50M), .start(finished_shuffle), 
						.finished(finished_rest), .read_data(read_data), .read_encrypt_data(encrypt_data), .write_en_s(write_en_s), 
						.data(write_data), .address_s(address_s), .address_e(address_e), 
						.write_en_d(write_en_d)); // decrypts the memory using xor task 2b
						
check_message    c_m(.clk(CLK_50M), .start(finished_rest), .finished(finished_check_message), 
							.decrypt_data(decrypt_data), .address_for_check(address_for_check), .LED(LEDR[0])); // checks the message in decrypted memory and if it produces a readable message task3
						
calculate_key   key(.clk(CLK_50M), .start(~start | finished_check_message), .finish(finished_all),
						  .secret_key_in(secret_key), .secret_key_out(secret_key), .LED1(LEDR[1])); //if message is not readable increase key and try again, task3 						
								 
encrypted_message enc(.address(address_e [4:0]), .clock(CLK_50M), .q(encrypt_data)); // read only memory made for storing the encrypted message

decrypt_message  decr(.clock(CLK_50M), .address(address_decrypt ? address_for_check[4:0] : address_e[4:0]), 
							 .data(write_data), .wren(write_en_d), .q(decrypt_data)); // decrypted memoery made for storing the decrypted message
								 
SevenSegmentDisplayDecoder ssdd0(.ssOut(HEX0), .nIn(secret_key[3:0]));
SevenSegmentDisplayDecoder ssdd1(.ssOut(HEX1), .nIn(secret_key[7:4]));
SevenSegmentDisplayDecoder ssdd2(.ssOut(HEX2), .nIn(secret_key[11:8]));
SevenSegmentDisplayDecoder ssdd3(.ssOut(HEX3), .nIn(secret_key[15:12]));
SevenSegmentDisplayDecoder ssdd4(.ssOut(HEX4), .nIn(secret_key[19:16]));
SevenSegmentDisplayDecoder ssdd5(.ssOut(HEX5), .nIn(secret_key[23:20]));


flopr_en reg_a_sel(.clk(CLK_50M), .clr(finished_all), .d(1'b1), .q(a_sel), .en(finished));
flopr_en reg_data_sel(.clk(CLK_50M), .clr(finished_all), .d(1'b1), .q(data_sel), .en(finished));
flopr_en reg_write_sel(.clk(CLK_50M), .clr(finished_all), .d(1'b1), .q(write_sel), .en(finished));
flopr_en reg_start(.clk(CLK_50M), .clr(reset_n), .d(1'b1), .q(start), .en(finished));

//flopr_en reg_start_shuffle(.clk(CLK_50M), .clr(reset_n), .d(1'b1), .q(start_shuffle), .en(finished_shuffle));

flopr_en reg_a_select(.clk(CLK_50M), .clr(finished_all), .d(1'b1), .q(a_select), .en(finished_shuffle));
flopr_en reg_data_select(.clk(CLK_50M), .clr(finished_all), .d(1'b1), .q(data_select), .en(finished_shuffle));
flopr_en reg_write_select(.clk(CLK_50M), .clr(finished_all), .d(1'b1), .q(write_select), .en(finished_shuffle));

flopr_en reg_dec_select(.clk(CLK_50M), .clr(finished_all), .d(1'b1), .q(address_decrypt), .en(finished_rest));





endmodule 

module shuffle(clk, start, finished, secret_key, read_data, write_en, data, address_out, finish_rest);

input clk, start, finish_rest;
input [23:0] secret_key;
input [7:0] read_data;
output finished, write_en;
output [7:0] data, address_out;
wire [7:0] secret_key_output, secret_key_output_reg, mem_i, mem_j, address_in, data_in;
wire addr_sel, reset, update_address_in, update_address_out, update_j, update_mem_i, update_mem_j;
wire update_data_i, update_data_j, add, reg_enable_output, update_data, mem_sel;

parameter keylength = 8'd3;
parameter idle                           = 20'b000000_00000000000000;
parameter reset_all                      = 20'b000001_00000000000001;
parameter check_counter                  = 20'b000010_00000000000000;
parameter update_address_i               = 20'b000011_01000000000110;
parameter read_mem_i                     = 20'b000100_00000000001000;
parameter wait_clock_1                   = 20'b000101_00000000000000;
parameter wait_clock_2                   = 20'b000110_00000000000000;
parameter update_j_counter_update_mem_i  = 20'b000111_00000000110000;
parameter update_address_j               = 20'b001000_00000000000100;
parameter read_mem_j                     = 20'b001001_00000000001000;
parameter wait_clock_3                   = 20'b001010_00000000000000;
parameter wait_clock_4                   = 20'b001011_00000000000000;
parameter update_data_i_mem_j            = 20'b001100_00000011000000;
parameter write_j_to_i                   = 20'b001101_00000100000000;
parameter addr_i                         = 20'b001110_00000000000110;
parameter addr_out_update_data_j         = 20'b001111_00001010001000;
parameter write_i_to_j                   = 20'b010000_00000100000000;
parameter increment_count                = 20'b010001_00010000000000;
parameter reset_counter                  = 20'b010010_00000000000001;
parameter finish                         = 20'b010011_00100000000000;
parameter update_data_first              = 20'b010100_10000000000000;
parameter update_data_second             = 20'b010101_10000000000000;

parameter update_address_i1               = 20'b100011_01000000000110;
parameter read_mem_i1                     = 20'b100100_00000000001000;
parameter wait_clock_11                   = 20'b100101_00000000000000;
parameter wait_clock_21                   = 20'b100110_00000000000000;
parameter update_j_counter_update_mem_i1  = 20'b100111_00000000110000;
parameter update_address_j1               = 20'b101000_00000000000100;
parameter read_mem_j1                     = 20'b101001_00000000001000;
parameter wait_clock_31                   = 20'b101010_00000000000000;
parameter wait_clock_41                   = 20'b101011_00000000000000;
parameter update_data_i_mem_j1            = 20'b101100_00000011000000;
parameter write_j_to_i1                   = 20'b101101_00000100000000;
parameter addr_i1                         = 20'b101110_00000000000110;
parameter addr_out_update_data_j1         = 20'b101111_00001010001000;
parameter write_i_to_j1                   = 20'b110000_00000100000000;
parameter update_data_first1              = 20'b110100_10000000000000;
parameter update_data_second1             = 20'b110101_10000000000000;
parameter finish1                         = 20'b110011_00100000000000;
parameter wait_for_finish                 = 20'b110100_00000000000000;

reg [7:0] count; // i
reg [7:0] j;
reg [19:0] state;


assign reset                    = state[0];
assign addr_sel                 = state[1];
assign update_address_in        = state[2];
assign update_address_out       = state[3];
assign update_j                 = state[4];
assign update_mem_i             = state[5];
assign update_mem_j             = state[6];
assign update_data_i            = state[7];
assign write_en                 = state[8];
//assign update_data_j            = state[9];
assign mem_sel                  = state[9];
assign add                      = state[10];
assign finished                 = state[11];
assign reg_enable_output        = state[12];
assign update_data              = state[13];

always_ff @(posedge clk) begin
case(state)
  idle: begin
	 if (start) begin
		state <= reset_all; 
	  end
	end
  reset_all: state <= check_counter;

  check_counter: begin 
		  if (count == 8'd255)
	            state <= update_address_i1; //updates the address once more and then goes to finish
		  else
		    state <= update_address_i;
		 end 
  update_address_i: state <= read_mem_i; //updates the address to i

  read_mem_i: state <= wait_clock_1;
  wait_clock_1: state <= wait_clock_2;
  wait_clock_2: state <= update_j_counter_update_mem_i; //read the data from address i and then update j and s[i]

  update_j_counter_update_mem_i: state <= update_address_j; // update address j

  update_address_j: state <= read_mem_j; // read from address j 	
  read_mem_j: state <= wait_clock_3;
  wait_clock_3: state <= wait_clock_4;

  wait_clock_4: state <= update_data_i_mem_j; // store s[j] and update data_out to s[i]
  update_data_i_mem_j: state <= update_data_first; // update data
  update_data_first: state <= write_j_to_i; // s[j] to s[i]
  write_j_to_i: state <= addr_i; // address becomes i
  addr_i: state <= addr_out_update_data_j; // update address to be i and data out to be s[j]

  addr_out_update_data_j: state <= update_data_second; //update data_out
  update_data_second: state <= write_i_to_j; // s[i] = s[j]
  write_i_to_j: state <= increment_count; // increment count
  increment_count: state <= check_counter; // check counter 

  update_address_i1: state <= read_mem_i1;

  read_mem_i1: state <= wait_clock_11;
  wait_clock_11: state <= wait_clock_21;
  wait_clock_21: state <= update_j_counter_update_mem_i1;

  update_j_counter_update_mem_i1: state <= update_address_j1;

  update_address_j1: state <= read_mem_j1;	
  read_mem_j1: state <= wait_clock_31;
  wait_clock_31: state <= wait_clock_41;

  wait_clock_41: state <= update_data_i_mem_j1;
  update_data_i_mem_j1: state <= update_data_first1;
  update_data_first1: state <= write_j_to_i1;
  write_j_to_i1: state <= addr_i1;
  addr_i1: state <= addr_out_update_data_j1;

  addr_out_update_data_j1: state <= update_data_second1;
  update_data_second1: state <= write_i_to_j1;
  write_i_to_j1: state <= reset_counter;

  reset_counter: state <= finish;
  finish: state <= finish1;
  finish1: state <= wait_for_finish;
  wait_for_finish: begin 
		  if (finish_rest == 1'b1)
	            state <= idle;
		  else
		    state <= wait_for_finish;
		 end 
			
  default: state <= idle;
endcase  
end

flopr_en #(8)   counter_add (.clk(clk), .clr(reset), .d(count+1'b1), .q(count), .en(add));

Mux3a #(8)      modselect(.a2(secret_key[7:0]), .a1(secret_key[15:8]), .a0(secret_key[23:16]), .s(count % keylength), .b(secret_key_output));

flopr_en #(8)   reg_secret_key(.clk(clk), .en(reg_enable_output), .d(secret_key_output), .clr(reset), .q(secret_key_output_reg));

//flopr_en #(8)   address_update_i(.clk(clk), .clr(reset), .d(count), .q(address_i), .en(update_address_i));

flopr_en #(8)   j_add (.clk(clk), .clr(reset), .d(j + read_data + secret_key_output_reg), .q(j), .en(update_j));

flopr_en #(8)   data_i(.clk(clk), .clr(reset), .d(read_data), .q(mem_i), .en(update_mem_i));

flopr_en #(8)   data_j(.clk(clk), .clr(reset), .d(read_data), .q(mem_j), .en(update_mem_j));

flopr_en #(8)   address_in_reg(.clk(clk), .clr(reset), .d(addr_sel ? count : j), .q(address_in), .en(update_address_in));

flopr_en #(8)   address_out_reg(.clk(clk), .clr(reset), .d(address_in), .q(address_out), .en(update_address_out));

flopr_en #(8)   data_i_out(.clk(clk), .clr(reset), .d(mem_sel ? mem_j : mem_i), .q(data_in), .en(update_data_i));

//flopr_en #(8)   data_j_out(.clk(clk), .clr(reset), .d(mem_j), .q(data_in), .en(update_data_j));

flopr_en #(8)   data_out(.clk(clk), .clr(reset), .d(data_in), .q(data), .en(update_data));

endmodule


module Mux3a(a2, a1, a0, s, b) ;
  parameter k = 1 ;
  input [k-1:0] a0, a1, a2 ;  // inputs
  input [7:0]   s ; // one-hot selecst
  output[k-1:0] b ;
  reg [k-1:0] b ;

  always @(*) begin
    case(s) 
      8'b000: b = a0 ;
      8'b001: b = a1 ;
      8'b010: b = a2 ;
      default: b =  {k{1'bx}} ;
    endcase
  end
endmodule

module vDFFE(clk, en, in, out) ; // Flip flop with enable
  parameter n = 1;  // width
  input clk, en ;
  input  [n-1:0] in ;
  output [n-1:0] out ;
  reg    [n-1:0] out ;
  wire   [n-1:0] next_out ;

  assign next_out = en ? in : out;

  always @(posedge clk)
    out <= next_out;  

endmodule 

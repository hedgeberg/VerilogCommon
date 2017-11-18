//uart_out just needs "received/not received" ACK/NAK
//uart_in  reading intel hex for programming

//`include "common/up_counter.v"
//`include "common/sr_latch.v"

module uart_out(data_in, ready, rst, tx, tx_done, clk);
	parameter BIT_SIZE = 10415; //approximately 100E6/9600  (100 MHz/baud rate); 
	parameter WORDSIZE = 8;

	input ready, clk, rst;
	input [WORDSIZE - 1:0] data_in;

	output reg tx, tx_done;

	//input translation
	wire [7:0] packet, packet_l;
	wire [10:0] final_packet;
	
	assign packet = data_in;
	assign final_packet = {1'b1, packet_l, 1'b0};
	reg latch_set, latch_reset;
	sr_latch #(8) latch_packet(packet, packet_l, clk, latch_set, latch_reset);
	
	
	//baud control counter
	wire [31:0] cycles;
	wire [3:0]  packet_pos; 
	reg baud_ctl_en, baud_ctl_clr, packet_cnt_en, packet_cnt_clr; 
	
	up_counter #(32, ((1<<32)-1)) baud_control(baud_ctl_en, baud_ctl_clr, cycles, clk);
	up_counter #(4,  ((1<< 4)-1)) packet_cnt(packet_cnt_en, packet_cnt_clr, packet_pos, clk);

	//state definitions
	reg [2:0] state;
	parameter init = 0, wait_for_ready = 1, translate_input = 2, push = 3,
			 clock_wait = 4, done = 5;

	initial begin 
		state = init;
	end

	//state machine input logic
	reg byte_done, bit_done;
	always @* begin
		if(packet_pos >= 10) byte_done = 1;
		else byte_done = 0;

		if(cycles >= BIT_SIZE) bit_done = 1;
		else bit_done = 0;
	end

	//state transition logic
	always @(posedge clk) begin 
		if(rst) state <= init;
		else begin 
		case(state)
			init: state <= wait_for_ready;
			wait_for_ready: begin 
				if(ready) state <= translate_input;
				else state <= wait_for_ready;
			end
			translate_input: state <= clock_wait;
			push: state <= clock_wait;
			clock_wait: begin 
				if(bit_done) begin 
					if(byte_done) state <= done;
					else state <= push;
				end
				else state <= clock_wait;
			end
			done: state <= wait_for_ready;
		endcase // state
		end 
	end

	//output logic
	always @* begin 
		if(state == init) latch_reset = 1;
		else latch_reset = 0;

		if(state == translate_input) latch_set = 1;
		else latch_set = 0;

		if(state == push) packet_cnt_en = 1;
		else packet_cnt_en = 0;

		if((state == done) || (state == init)) packet_cnt_clr = 1;
		else packet_cnt_clr = 0; 

		if(state == clock_wait) baud_ctl_en = 1;
		else baud_ctl_en = 0;

		if(state == clock_wait) baud_ctl_clr = 0;
		else baud_ctl_clr = 1;

		if(state == done) tx_done = 1;
		else tx_done = 0;

		if(packet_pos >= 10) tx = 1;
		else if((state == push) || (state == clock_wait)) 
			tx = final_packet[packet_pos];
		else tx = 1;
	end

endmodule



/*
	wire d0, d1, d2, d3, d4, d5, d6, d7;
	wire p0, p1, p2, p3;

	assign d0 = data_in[0];
	assign d1 = data_in[1];
	assign d2 = data_in[2];
	assign d3 = data_in[3];
	assign d4 = data_in[4];
	assign d5 = data_in[5];
	assign d6 = data_in[6];
	assign d7 = data_in[7];
	
	// p0 p1 d0 p2 d1 d2 d3 p3 d4 d5 d6 d7
//	p0 x     x     x     x     x     x
//	p1    x  x        x  x        x  x
//	p2          x  x  x  x              x
//  p3                      x  x  x  x  x


	assign p0 = d0 ^ d1 ^ d3 ^ d4 ^ d6;
	assign p1 = d0 ^

*/

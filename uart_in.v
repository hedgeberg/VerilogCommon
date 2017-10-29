
//uart_in is a uart listening module, that parallelizes a 8bit+1parity uart input. 
//initialize transmission via xmit_init. 
//xmit_done is high for 1 cycle after xmit done, parity_err is high on parity error
//when parametrizing your div_size, subtract 2 to account for the 2 cycles of 
//latency caused by transition in and out of the sampling state


module uart_in(srl_in, data_out, clk, rst, new_byte_ready);
	parameter DIV_SIZE = 9600;

	input srl_in, clk, rst;
	output [7:0] data_out;
	output reg new_byte_ready;

	reg delay_en, delay_clr;
	reg bit_count_en, bit_count_clr; 
	reg shift_en, shift_clr;

	wire [31:0] delay_count;
	wire [7:0]  bit_count;



	up_counter #(32,((1<<32)-1)) delay_events(delay_en, delay_clr, delay_count, clk);
	up_counter bit_number(bit_count_en, bit_count_clr, bit_count, clk);
	right_shiftreg #(8) deserializer(srl_in, data_out, clk, shift_en, shift_clr);


	parameter init = 0, idle = 1, half_samp_delay = 2, samp_delay = 3;
	parameter sample = 4, set_status = 6, quick_clr = 7; 


	reg [4:0] state;

	initial begin 
		state = init;
	end 

	//state transition logic
	always @(posedge clk) begin 
		if(rst) state <= init;
		else case(state)
			init: state <= idle;
			idle: begin 
				if(srl_in == 1'b0) state <= half_samp_delay;
				else state <= idle;
			end 
			half_samp_delay: begin 
				if(delay_count >= (DIV_SIZE>>1) - 1) state <= quick_clr;
				else state <= half_samp_delay;
			end 
			quick_clr: state <= samp_delay;
			samp_delay: begin 
				if(delay_count >= DIV_SIZE) begin 
					if (bit_count == 8) state <= set_status;
					else state <= sample;
				end 
				else state <= samp_delay;
			end 
			sample: state <= samp_delay;
			set_status: state <= idle;
			default: state <= init; 
		endcase
	end

	//output logic

	always @* begin 
		if((state == half_samp_delay) || (state == samp_delay)) delay_en = 1;
		else delay_en = 0;

		if((state == half_samp_delay) || (state == samp_delay)) delay_clr = 0;
		else delay_clr = 1;

		if((state == sample)) bit_count_en = 1;
		else bit_count_en = 0;

		if((state == sample) || (state == samp_delay)) 
			bit_count_clr = 0;
		else bit_count_clr = 1;

		if(state == sample)	shift_en = 1;
		else shift_en = 0;

		if(state == half_samp_delay) shift_clr = 1;
		else shift_clr = 0;

		if(state == set_status) new_byte_ready = 1;
		else new_byte_ready = 0;
	end 


endmodule 
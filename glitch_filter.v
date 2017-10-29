`include "common/up_counter.v"


//assists in filtering glitches from noisy external IO
//number of cycles for wait is parametrized

module glitch_filter(in, out, clk);
	parameter filter_cycles = 5;

	input in, clk;
	output reg out;

	reg [filter_cycles - 1 : 0] filter;

	initial begin 
		filter = 0;
		out = 0;
	end 

	always @(posedge clk) begin 
		filter <= (filter << 1) | in;
		if((& filter) == 1) out <= 1;
		else if((| filter) == 0) out <= 0;
	end

	
endmodule // glitch_filter
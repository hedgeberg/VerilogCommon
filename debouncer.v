//`include "common/up_counter.v"

module debouncer(in, out, clk);
	//simple debouncer to regulate output of switches on FPGA dev board
	//WAIT is number of cycles
	//WIDTH is bitwidth of counter instantiated within the debouncer 
	parameter WIDTH=16;
	parameter WAIT =10000;
	input in, clk;
	output reg out;

	wire [WIDTH-1:0] count;
	wire count_en; 
	reg clr;

	up_counter #(WIDTH, WAIT) counter(count_en, clr, count, clk);

	assign count_en = 1;

	always @(posedge clk) begin
		if(count == WAIT) begin 
			clr <= 1;
			out <= in;
		end else begin
			clr <= 0;
		end
	end
endmodule

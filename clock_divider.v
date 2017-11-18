//`include "common/up_counter.v"

module clock_divider(clk, out);
	//generalized clock divider, uses up_counter to count divs
	//by default, 8 bits wide, div-by-16
	parameter BITS = 8;
	parameter DIV  = 16;

	input clk;
	output reg out;

	reg [BITS-1:0] count;
	reg clr;

	

	initial begin
		out = 0;
		count = 0;
	end

	always @(posedge clk) begin
		if(count == (DIV - 1)) begin
			count <= 0;
			out <= ~out;
		end else begin
			count <= count + 1;
		end
	end

endmodule // clock_divider

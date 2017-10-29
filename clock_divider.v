//`include "common/up_counter.v"

module clock_divider(clk, out);
	//generalized clock divider, uses up_counter to count divs
	//by default, 8 bits wide, div-by-16
	parameter BITS = 8;
	parameter DIV  = 16;

	input clk;
	output reg out;

	wire [BITS-1:0] count;
	reg clr;

	

	initial begin
		clr = 0;
		out = 0;
	end

	up_counter #(BITS, DIV - 1) up(1'b1, clr, count, clk);

	always @(posedge clk) begin
		if(count == (DIV - 1)) begin
			clr <= 1;
			out <= ~out;
		end else begin
			clr <= 0;
		end
	end

endmodule // clock_divider

//mux2x
//two-input to one-output paramterized-width multiplexer


module mux2x(in_a, in_b, select, out);
	parameter WIDTH = 8;

	input [WIDTH - 1:0] in_a, in_b;
	output reg [WIDTH - 1:0] out;
	input select;

	always @* begin
		if(select == 1) out = in_b;
		else out = in_a;
	end 

endmodule 
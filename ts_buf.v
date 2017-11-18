module ts_buf(in, out, en);
	//standard parametrized width tristate buffer
	parameter WIDTH = 1;

	input [WIDTH-1:0] in;
	input en;
	output [WIDTH-1:0] out;
	tri [WIDTH-1:0] out;

	assign out = (en) ? in:{(WIDTH){1'bz}};

endmodule // ts_buf
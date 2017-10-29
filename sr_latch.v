//SR latch
//on clk posedge, if set is enabled, out <= in;
//				, if reset is enabled, out <= 0;
// 				, if set == reset, out <= out;


module sr_latch(in, out, clk, set, reset);
	parameter WIDTH = 8;

	
	//data lines
	input [WIDTH-1:0] in;
	output reg [WIDTH-1:0] out;

	//control signals
	input clk, set, reset;

	initial begin 
		out = 0;
	end

	always @(posedge clk) begin
		if(reset == 1'b1) out <= 0;
		else if(set == 1'b1) out <= in;
		else out <= out;
	end // always @(posedge clk)

endmodule
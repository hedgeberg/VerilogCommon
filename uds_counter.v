module uds_counter(up, down, set, in, out, clk);
	//up-down-set counter
	//parametrized counter with up, down, and set controls
	//let uds = {up, down, set}
	//when uds = 100 counts up by 1
	//when uds = 010 coutns down by 1
	//when uds = 001 sets internal register = in 
	//all other cases, timer holds current state.
	//overflow and underflow are preveneted

	parameter WIDTH = 8;
	parameter MAX   = (1 << 8) - 1;

	input [WIDTH-1:0] in;
	input up, down, set, clk;
	output reg [WIDTH-1:0] out;
	wire [2:0] uds;

	assign uds = {up, down, set};

	initial begin
		out = 0;
	end

	//control logic
	always @(posedge clk) begin
		if(uds[0] == 1'b1)
			out <= in;
		else if((uds[2] == 1'b1) && (out < MAX))
			out <= out + 1;
		else if((uds[1] == 1'b1) && (out > 0))
			out <= out - 1;
		else
			out <= out;
	end 


endmodule // uds_counter
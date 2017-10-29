module right_shiftreg(in, out, clk, en, clr); 
	parameter DEPTH = 9; //for I2C with ACK/NAK as final bit


	//data signals
	input in;
	output reg [DEPTH-1:0] out;


	//control signals
	input clk, en, clr;


	//initial as cleared
	initial begin
		out = 0;
	end


	//control block
	always @(posedge clk) begin
		if(clr == 1'b1) begin
			out <= 0;
		end 
		else if(en == 1'b1) begin
			out <= (out >> 1);
			out[DEPTH-1] <= in;
		end
	end
endmodule 
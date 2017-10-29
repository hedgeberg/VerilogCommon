//single-bit shift register
//intended for use in listening to  serial communications
//can be parallelized to enable parallel topologies

//only shifts when enable is held high
//synchrounous clr sets out = DEPTH'b00..00;

module shift_register(in, out, clk, en, clr); 
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
			out <= (out << 1);
			out[0] <= in;
		end
	end


endmodule
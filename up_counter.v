module up_counter(en, clr, count, clk);
	//up_counter with no rollover, halts increasing at MAX
	//synchronous clr
	parameter WIDTH = 8;
	parameter MAX = (1 << WIDTH) - 1;
	input en, clr, clk;
	(* KEEP = "TRUE"*) 
	output reg [WIDTH-1:0] count;


	initial begin 
		count = 0;
	end

	always @(posedge clk) begin
		if(clr) begin
			count <= 0;
		end
		else if(en && (count < MAX)) begin
 			count <= count + 1;
		end
	end

endmodule
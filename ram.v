//`include "common/ts_buf.v"

module simple_ram(mem_bus_in, mem_bus_out, address, r_e, w_e, clk);
	//simple robust (i think?) parametrized RAM
	//all values are parametrizable
	parameter BYTE_W = 8;
	parameter ADDR_W = 8;
	parameter NUM_ADDR = 1 << ADDR_W;

	input [BYTE_W - 1:0] mem_bus_in;
	output reg [BYTE_W - 1:0] mem_bus_out;
	input [ADDR_W - 1:0] address;
	input r_e, w_e;//read_enable + write_enable
	input clk;
	tri [BYTE_W - 1: 0] mem_bus;
	reg [BYTE_W - 1:0] mem_storage [0:NUM_ADDR - 1];

/*	
	reg [7:0] i;


	initial begin 
		i = 0;
		while(i < NUM_ADDR) begin
			mem_storage[i] = 8'b00000000;
			i = i + 1;
		end
	end
*/


	//in/out buffering
	/*
	reg [BYTE_W-1:0] read_line;
	wire  [BYTE_W-1:0] write_line;
	ts_buf #(BYTE_W) buf_writes(mem_bus, write_line, w_e),
				buf_reads(read_line, mem_bus, (r_e & ~w_e));
	*/

	//read/write logic
	always @(posedge clk) begin
		if(w_e) mem_storage[address] <= mem_bus_in;
		else if(r_e) mem_bus_out <= mem_storage[address];
		else mem_bus_out <= 0;
	end
	
endmodule // simple_memory
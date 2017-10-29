`include "common/shift_register.v" 
`include "common/glitch_filter.v"  //up counter is instantiated in glitch filter

//i2c circuit, meant just for listening to an i2c bus.
//THIS IS NOT MASTER NOR SLAVE. It cannot write to the bus, nor ack/nak
//it just reads and makes the formatted data available to its instantiating module

//uses sda and scl to collect packet
//transmits out on sda_out as {SDA:(ACK/NAK)}
//byte_ready is high when a full sda_out byte (with ack/nak) is ready for read 
//sop and eot are both made available to instantiating modules to allow for sampling
//and reading in to a buffer

//NOTE: this assumes that this state-machine will be listening to the line
//as it goes live, meaning it gets an initial posedge to init off of
//if this is not the case, initial state must be changed

module i2c_listen(sda_glitched, sda_out, scl_glitched, sysclk, byte_ready, sop, eot, 
				   scl_posedge, sda_posedge, sda_negedge);
	parameter I2C_WIDTH = 8 + 1; 
	

	//data signals
	input sda_glitched, scl_glitched, sysclk;
	output reg [I2C_WIDTH-1:0] sda_out;

	wire sda_in, scl;

	//glitch_filter #(2) sda_filt(sda_glitched, sda_in, sysclk);
	//glitch_filter #(2) scl_filt(scl_glitched, scl, sysclk);

	assign scl = scl_glitched;
	assign sda_in = sda_glitched;

	initial begin
		sda_out = 0;
	end

	//control signals
	output reg byte_ready, sop, eot;

	//internal control signals
	reg cnt_clr, cnt_en;
	reg shift_en;
	wire [7:0] count;
	wire [8:0] shift_out;

	//debugging signals
	
	

	
	//child modules
	up_counter counter(cnt_en, cnt_clr, count, sysclk);
	shift_register shift(sda_in, shift_out, sysclk,
						 shift_en, 1'b0);

	//state setup
	reg [2:0] state;



	parameter bus_init_wait = 0, wait_for_SOP = 1, SOP_caught = 2, sample_wait = 3, 
			  sampling = 4, end_of_byte = 5, EOT_caught = 6;





	//edge detection logic
	reg prev_sda_0, prev_scl_0;
	output reg scl_posedge, sda_negedge, sda_posedge;
	initial begin
		prev_sda_0 = 0; //prev_sda_1 = 0; 
		prev_scl_0 = 0; //prev_scl_1 = 0;
	end
	
	always @(posedge sysclk) begin

		sda_posedge <= sda_in & ~(prev_sda_0);
		sda_negedge <= ~(sda_in) & ( prev_sda_0);


		scl_posedge <= scl & ~(prev_scl_0);
		prev_scl_0 <= scl;
		prev_sda_0 <= sda_in;

	end

	//initialization block
	reg prev_sda_old, prev_scl_old;
	initial begin
		state = bus_init_wait;
		prev_sda_old = 0; prev_scl_old = 0;
		scl_posedge = 0; sda_posedge = 0; sda_negedge = 0;
	end


	//next state/rt logic

	
	always @(posedge sysclk) begin
		case(state)
			bus_init_wait: begin
				if((sda_in == 1'b1) && (scl == 1'b1)) state <= wait_for_SOP;
				else state <= bus_init_wait;
			end
			wait_for_SOP: begin
				if((sda_in == 1'b0) && (scl == 1'b1)) state <= SOP_caught;
				else state <= wait_for_SOP;
			end
			SOP_caught: state <= sample_wait;
			sample_wait: begin
				if ((scl == 1'b1) && sda_posedge) state <= EOT_caught;
				else if((scl == 1'b1) && sda_negedge) state <= SOP_caught;
				else if(scl_posedge) state <= sampling;
				else state <= sample_wait;
			end
			sampling: begin
				if(count == (I2C_WIDTH-1)) state <= end_of_byte;
				else state <= sample_wait;
			end
			end_of_byte: begin 
				sda_out <= shift_out;
				state <= sample_wait;
			end
			EOT_caught: state <= wait_for_SOP;
		endcase 
		prev_scl_old <= scl;
		prev_sda_old <= sda_in;
	end


	//output/control logic

/*	sda_out, byte_ready, sop,
				  eot
*/
	always @* begin
		//if(state == end_of_byte) sda_out <= shift_out;
		//else sda_out <= sda_out;

		if(state == end_of_byte) byte_ready = 1'b1;
		else byte_ready = 1'b0;

		if(state == sampling) cnt_en = 1'b1;
		else cnt_en = 1'b0;

		if(state == sampling) shift_en = 1'b1;
		else shift_en = 1'b0;

		if((state == SOP_caught) || (state == end_of_byte)) cnt_clr = 1'b1;
		else cnt_clr = 1'b0;

		if(state == SOP_caught) sop = 1'b1;
		else sop = 1'b0;

		if(state == EOT_caught) eot = 1'b1;
		else eot = 1'b0;	
	end

endmodule


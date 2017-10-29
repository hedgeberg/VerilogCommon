`include "common/up_counter.v"
`define EOF 32'hFFFF_FFFF
`define NULL 0
`define MAX_LINE_LENGTH 1000

//bitbangs out a single-channel single-bit stimulus file, to allow for using
//saelae logic outputs for bitbanging in testing/simulation

//WARNING: probably needs heavy modification per system, right now is specifically 
//designed for use with my saelae logic 16 and my virtex 4 FPGA

//timing constants are, in effect, hardcoded 

module file_to_stim(out, clk);
    parameter filepath = "input.csv";

    input clk;
    output reg out;

    wire [63:0] curr_cycle;
    reg [63:0] next_change;

    reg next_out;

    up_counter #(64,(2<<64)-1) up(1'b1, 1'b0, curr_cycle, clk);

    integer file, return_code, char;

    //open file

    initial begin
        out = 0;
        file = $fopen(filepath, "r");
        return_code = $fscanf(file,"%d, %b\n", next_change, next_out);
    end



    always @(posedge clk) begin
        if(curr_cycle >= next_change) begin
            out <= next_out;
            char = $fgetc(file);
            if(char == `EOF) begin
                $finish;
            end
            else begin
                return_code = $ungetc(char, file);
                return_code = $fscanf(file, "%d, %b\n", next_change, next_out);
            end
        end
    end


endmodule
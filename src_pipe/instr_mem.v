`timescale 1ns / 1ps

module instr_mem #(parameter w = 32, d = 2000) (
    input [31:0] addr_instr,
    output [31:0] data_out_instr
    );
    
    reg [w-1:0] instr_mem [0:d];
    
    initial begin
        $readmemh("C:\\Users\\rabia.demiray\\Downloads\\bubble_sort.s.hex", instr_mem);
    end
    
    wire [31:0] address = {3'b000,addr_instr[30:2]};
     
    assign data_out_instr =  instr_mem[address];
 
endmodule

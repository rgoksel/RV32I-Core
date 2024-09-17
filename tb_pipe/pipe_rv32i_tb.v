`timescale 1ns / 1ps


module pipe_rv32i_tb();

    reg clk=0;
    reg reset;
    
    pipe_risc32i rvi_1(
    .clk(clk),
    .reset(reset)
    );
    
    always #5 clk = ~clk;
    
    initial begin
        reset = 1;
        #10;
        reset = 0;
    end



endmodule


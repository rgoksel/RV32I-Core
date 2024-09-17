`timescale 1ns / 1ps

module pipe_1(
    input clk,
    input reset,
    input en,
    input clr,
    input [31:0] in_1,
    input [31:0] in_2,
    input [31:0] in_3,
    output reg [31:0] out_1,
    output reg [31:0] out_2,
    output reg [31:0] out_3
    );
    
    always @(posedge clk) begin
        if (reset) begin 
            out_1 <= 0;
            out_2 <= 0;
            out_3 <= 0;
        end else if (clr) begin
            out_1 <= 32'h00000013;
            out_2 <= out_2;
            out_3 <= out_3; //bunları silcez
        end else begin
            if (!en) begin
                out_1 <= in_1;
                out_2 <= in_2;
                out_3 <= in_3;
            end
        end
    end
endmodule


module pipe_2(
    input clk,
    input reset,
    input en,
    input clr,
    input [31:0] in_1,
    input [31:0] in_2,
    input [31:0] in_3,
    input [4:0]  in_4,
    input [4:0]  in_7,
    input [4:0]  in_8,
    input [31:0] in_5,
    input [31:0] in_6,
    output reg [31:0] out_1,
    output reg [31:0] out_2,
    output reg [31:0] out_3,
    output reg [4:0]  out_4,
    output reg [4:0]  out_7,
    output reg [4:0]  out_8,
    output reg [31:0] out_5,
    output reg [31:0] out_6
    );
    
    
    always @(posedge clk) begin
        if (reset || clr) begin
            out_1 <= 0;
            out_2 <= 0;
            out_3 <= 0;
            out_4 <= 0;
            out_5 <= 0;
            out_6 <= 0;
            out_7 <= 0;
            out_8 <= 0;
        end else begin
            out_1 <= in_1;
            out_2 <= in_2;
            out_3 <= in_3;
            out_4 <= in_4;
            out_5 <= in_5;
            out_6 <= in_6;
            out_7 <= in_7;
            out_8 <= in_8;
        end
        
    end
endmodule

module pipe_control_1(
    input clk,
    input en,
    input reset,
    input clr,
    input             in_1,
    input      [1:0]  in_2,
    input             in_3,
    input             in_4,
    input             in_5,
    input      [3:0]  in_6,
    input             in_7,
    input             in_8,
    input  [3:0]      in_9,
    input  [3:0]      in_10,
    output reg       out_1,
    output reg [1:0] out_2,
    output reg       out_3,
    output reg       out_4,
    output reg       out_5,
    output reg [3:0] out_6,
    output reg       out_7,
    output reg       out_8,
    output reg [3:0] out_9,
    output reg [3:0] out_10
    );
    
    always @(posedge clk) begin
        if (reset || clr) begin
            out_1 <= 0;
            out_2 <= 0;
            out_3 <= 0;
            out_4 <= 0;
            out_5 <= 0;
            out_6 <= 0;
            out_7 <= 0;
            out_8 <= 0;
            out_9 <= 0;
            out_10 <=0;
//        end else if (clr) begin
//            out_1   <= 0;
//            out_2   <= 2'b01;
//            out_3   <= 0;
//            out_6   <= 4'b0000;
//            out_7   <= 0;
//            out_8   <= 0;
//            out_9   <= 4'b0000;
//            out_10  <= 4'b0000;
        end else begin
            out_1 <= in_1;
            out_2 <= in_2;
            out_3 <= in_3;
            out_4 <= in_4;
            out_5 <= in_5;
            out_6 <= in_6;
            out_7 <= in_7;
            out_8 <= in_8;
            out_9 <= in_9;
            out_10 <= in_10;
        end
        
    end
endmodule


module pipe_3_4(
    input clk,
    input reset,
    input en,
    input clr,
    input [31:0] in_1,
    input [31:0] in_2,
    input [4:0] in_3,
    input [31:0] in_4,
    input [31:0] in_5,
    output reg [31:0] out_1,
    output reg [31:0] out_2,
    output reg [4:0]  out_3,
    output reg [31:0] out_4,
    output reg [31:0] out_5
    );
    
    always @(posedge clk) begin
        if (reset) begin
            out_1 <= 0;
            out_2 <= 0;
            out_3 <= 0;
            out_4 <= 0;
            out_5 <= 0;
        end else begin
            out_1 <= in_1;
            out_2 <= in_2;
            out_3 <= in_3;
            out_4 <= in_4;
            out_5 <= in_5;
        end
        
    end
endmodule


module pipe_control_2(
    input clk,
    input en,
    input reset,
    input clr,
    input  in_1,
    input [1:0] in_2,
    input in_3,
    input [3:0] in_4,
    input [3:0] in_5,
    output reg  out_1,
    output reg [1:0] out_2,
    output reg out_3,
    output reg [3:0] out_4,
    output reg [3:0] out_5
    );
    
    always @(posedge clk) begin
        if (reset) begin
            out_1 <= 0;
            out_2 <= 0;
            out_3 <= 0;
            out_4 <= 0;
            out_5 <= 0;
        end else begin
            out_1 <= in_1;
            out_2 <= in_2;
            out_3 <= in_3;
            out_4 <= in_4;
            out_5 <= in_5;
        end
    end
endmodule


module pipe_control_3(
    input clk,
    input en,
    input reset,
    input clr,
    input  in_1,
    input [1:0] in_2,
    output reg  out_1,
    output reg [1:0] out_2
    );
    
    always @(posedge clk) begin
        if (reset) begin
            out_1 <= in_1;
            out_2 <= in_2;
        end else begin
            out_1 <= in_1;
            out_2 <= in_2;
        end
        
    end
endmodule
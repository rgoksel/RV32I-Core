`timescale 1ns / 1ps

module ALU(
    input [31:0] A, B,
    input reset,
    input [3:0] op,
    input u_s,
    output reg [31:0] FU,
    output reg  zero
    );
    
    
    wire [3:0] arith_op;
    wire [3:0] logic_op;
    wire [3:0] shifter_op;
    
    wire [3:0] unit_select;
    
    wire [31:0] au_out, logic_out, shifter_out;
    
    assign unit_select = op;
    assign arith_op = op;
    assign logic_op = op;
    assign shifter_op = op;
    
    wire zero_au;
    
    Arithmetic_Unit au(
    .A_i(A),
    .B_i(B),
    .C_i(0),
    .arith_op(arith_op),
    .Sum_o(au_out),
    .C_o(),
    .Overflow_o(),
    .zero_au(zero_au),
    .u_s(u_s)
    );
    
    Logic_Unit lu(
    .A_i(A), 
    .B_i(B),
    .logic_op(logic_op),
    .logic_out(logic_out)
    );
    
    Shifter_Unit su(
    .A_i(A), 
    .B_i(B),
    .shifter_op(shifter_op),
    .shifter_out(shifter_out)
    );
    
    always @(*) begin
        if (reset) begin
            FU <= 32'd0;
            zero <= 0;
        end else begin
            if (unit_select == 4'b0000 /*top*/ || unit_select == 4'b0001 /*çýkar*/ || unit_select == 4'b1110 /*top for lui*/) begin
                FU <= au_out;
            end else if (unit_select == 4'b0010 /*sll , slli*/ || unit_select == 4'b0100 /*srli , srl*/ || unit_select == 4'b0110/*srai*/) begin
                FU <= shifter_out;
            end else if (unit_select == 4'b1000 /*and*/|| unit_select == 4'b1010 /*xor*/|| unit_select == 4'b1100/*or*/) begin
                FU <= logic_out;
            end else if ((unit_select == 4'b0011 /*slt, sltu*/) && zero == 1) begin
                FU <= 32'd1;
            end else begin
                FU <= 32'd0;
            end
            
            if ( (unit_select == 4'b0011 || unit_select == 4'b0101 || unit_select == 4'b0111 || unit_select == 4'b1001 || unit_select == 4'b1011)) begin
                zero <= zero_au;
            end else begin 
                zero <= 1'b0;
            end
//  zero <= (unit_select == 4'b0011 || unit_select == 4'b0101 || unit_select == 4'b0111 || unit_select == 4'b1001 || unit_select == 4'b1011) ? zero_au : 1'd0; //01  
        end
    end
    
endmodule


module Arithmetic_Unit(
    input [31:0] A_i,
    input [31:0] B_i,
    input C_i,
    input [3:0] arith_op,
    input u_s,
    output [31:0] Sum_o,
    output C_o,
    output Overflow_o,
    output zero_au
    );
    
    genvar i;
    genvar j;
    wire [31:0] C;
    wire  [31:0] B_has;
    wire [31:0] B_xor;
    wire [31:0] B_oc;
    wire [31:0] A_sel;
    
    assign B_oc = ~B_i;
    assign B_xor = B_oc + 32'd1;
    assign B_has = arith_op[0] ? B_xor : B_i;
    
    assign A_sel = (arith_op == 4'b1110) ? 32'd0 : A_i;
    
    generate 
        for (i = 0; i < 32 ; i = i +1) begin
            if ( i == 0) begin
                full_adder fa_1(.A_i(A_sel[i]), .B_i(B_has[i]), .Cin(C_i), .Sum(Sum_o[i]), .Cout(C[i]));
            end
            else  if ( i > 0) begin
                full_adder fa_1(.A_i(A_sel[i]), .B_i(B_has[i]), .Cin(C[i-1]), .Sum(Sum_o[i]), .Cout(C[i]));
            end
        end
    endgenerate
    
    //zero flag olayý buraya eklenecek
    assign zero_au = (arith_op == 4'b0011 && u_s == 1) ? ((C_o == 1) ? 1 : 0) : //sltu
                     (arith_op == 4'b0101) ? ((Sum_o == 32'd0) ? 1 : 0) : //eq
                     (arith_op == 4'b0111) ? ((Sum_o != 32'd0) ? 1 : 0) : //not eq
                     (arith_op == 4'b1001 && u_s == 1) ? ((C_o == 1) ? 1 : 0) : // less
                     (arith_op == 4'b1011 && u_s == 1) ? ((C_o == 0) ? 1 : 0) : //grater
                     (arith_op == 4'b0011 && u_s == 0) ? (((Overflow_o == 0 && Sum_o[31] == 1) || (Overflow_o == 1 && Sum_o[31] == 0)) ? 1 :0 ): //slt
                     (arith_op == 4'b1001 && u_s == 0) ? (((Overflow_o == 0 && Sum_o[31] == 1) || (Overflow_o == 1 && Sum_o[31] == 0)) ? 1 :0 ): // less
                     (arith_op == 4'b1011 && u_s == 0) ? (((Overflow_o == 0 && Sum_o[31] == 0) || (Overflow_o == 1 && Sum_o[31] == 1)) ? 1 :0 ): //grater
                     0; 
    
    assign C_o = C[31];
    assign Overflow_o = C[31] ^ C[30];
    
endmodule

module full_adder (
    input A_i,
    input B_i,
    input Cin,
    output Sum,
    output Cout
);

assign Sum = A_i ^ B_i ^ Cin;
assign Cout = (A_i & B_i) | (B_i & Cin) | (Cin & A_i);

endmodule

module Logic_Unit(
    input [31:0] A_i, B_i,
    input [3:0] logic_op,
    output [31:0] logic_out
    );
    
    assign logic_out= (logic_op == 4'b1000) ? A_i & B_i :
                        (logic_op == 4'b1010) ? A_i ^ B_i :
                        (logic_op == 4'b1100) ? A_i | B_i :
                        A_i;
endmodule

module Shifter_Unit(
    input [31:0] A_i, B_i,
    input [3:0] shifter_op,
    output [31:0] shifter_out
    );
    
    reg [31:0] shifter_res;
    
    localparam [1:0] SLL = 4'b0010, 
                     SRL = 4'b0100,
                     SRA = 4'b0110;
                     
    reg [31:0] A1, A2, A3, A4;
                     
    always @(*) begin
        case (shifter_op)
            SLL: begin
                if( B_i[0])
                    A1 = A_i << 1;
                else 
                    A1 = A_i;
                if( B_i[1])
                    A2 = A1 << 2;
                else 
                    A2 = A1;
                if( B_i[2])
                    A3 = A2 << 4;
                else 
                    A3 = A2; 
                if( B_i[3])
                    A4 = A3 << 8;
                else 
                    A4 = A3; 
                if( B_i[4])
                    shifter_res = A4 << 16;
                else 
                    shifter_res = A4;    
            end
            SRL : begin
                if(B_i[0])
                    A1 = A_i >> 1;
                else 
                    A1 = A_i;
                if(B_i[1])
                    A2 = A1 >> 2;
                else        
                    A2 = A1;
                if(B_i[2])  
                    A3 = A2 >> 4;
                else        
                    A3 = A2;
                if(B_i[3])  
                    A4 = A3 >> 8;
                else 
                    A4 = A3; 
                if(B_i[4])
                    shifter_res = A4 >> 16;
                else 
                    shifter_res = A4;
            end
            SRA : begin
                if(B_i[0]) begin
                    A1[30:0] = A_i[30:0] >> 1;
                    A1[31] = A_i[31];
                end else 
                    A1 = A_i;
                if(B_i[1]) begin
                    A2[30:0] = A1[30:0] >> 2;
                    A2[31] = A1[31];
                end else        
                    A2 = A1;
                if(B_i[2])  begin
                    A3[30:0] = A2[30:0] >> 4;
                    A3[31] = A2[31];
                end else        
                    A3 = A2;
                if(B_i[3]) begin 
                    A4[30:0] = A3[30:0] >> 8;
                    A4[31] = A3[31];
                end else 
                    A4 = A3; 
                if(B_i[4]) begin
                    shifter_res[30:0] = A4[30:0] >> 16;
                    shifter_res[31] = A4[31];
                end else 
                    shifter_res = A4;
            end
            default : shifter_res = A_i; 
        endcase
    end
    
    assign shifter_out = shifter_res;
endmodule







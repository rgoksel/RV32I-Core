`timescale 1ns / 1ps

module PC(
    input clk,
    input en,
    input reset,
    input [31:0] pc_next,
    output reg [31:0] PC
    );
    
//    initial begin
//        PC <= 32'h80000000;
//    end 
    
    always @(posedge clk) begin
        if ( !en) begin
            if(reset)
                PC <= 32'h80000000;
            else
                PC <= pc_next;
       end
    end
endmodule

module plus_four (
    input reset,
    input [31:0] PC,
    output reg [31:0] PC_plus4
);

always @(*) begin
    if (reset)
        PC_plus4 = 32'h80000004;
    else
        PC_plus4 <= PC + 32'd4;
end

endmodule

module plus_imm_ext1 (
    input reset,
    input [31:0] PC,
    input [31:0] Imm_Ext,
    output reg [31:0] PC_Target
);

wire [31:0] C;

wire [31:0] PC_Target_wire;

always @(*) begin
    if (reset)
        PC_Target <= 32'h80000004;
    else
        PC_Target <= PC_Target_wire; 
end
//assign PC_Taget = PC + Imm_Ext;

    genvar i;
    
    generate 
        for (i = 0; i < 32 ; i = i +1) begin
            if ( i == 0) begin
                full_adder fa_1(.A_i(PC[i]), .B_i(Imm_Ext[i]), .Cin(0), .Sum(PC_Target_wire[i]), .Cout(C[i]));
            end
            else  if ( i > 0) begin
                full_adder fa_1(.A_i(PC[i]), .B_i(Imm_Ext[i]), .Cin(C[i-1]), .Sum(PC_Target_wire[i]), .Cout(C[i]));
            end
        end
    endgenerate

endmodule

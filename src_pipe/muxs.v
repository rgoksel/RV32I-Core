`timescale 1ns / 1ps


module mux_pcnext(
    input PC_Src,
    input reset,
    input [31:0] PC_plus4,
    input [31:0] PC_target,
    output reg [31:0] PC_next
    );
    
    always @(*) begin
        if (reset) begin
            PC_next <= 32'h80000004;
        end else begin
            if ( PC_Src)
                PC_next <=  PC_target;
            else 
                PC_next <= PC_plus4;
        end
    end
endmodule


module mux_Bin(
    input ALU_Src,
    input reset,
    input [31:0] RD_2,
    input [31:0] Imm_Ext,
    output reg [31:0] Src_B
    );
    
    always @(*) begin
        if (reset) begin
            Src_B <= 32'd0;
        end else begin
            if (ALU_Src)
                Src_B <= Imm_Ext;
            else
                Src_B <= RD_2;
        end
    end
    
    
endmodule


module mux_result(
    input reset,
    input [1:0] Res_Src,
    input [31:0] ALU_res,
    input [31:0] read_data,
    input [31:0] PC_plus4,
    input [31:0] PC_target,
    output reg [31:0] Result
    );
    
    always @(*) begin
        if (reset) begin
            Result <= 32'd0;
        end else begin
            if ((Res_Src == 2'b00)) 
                 Result <= ALU_res;
            else if ((Res_Src == 2'b01)) 
                 Result <= read_data;
            else if ((Res_Src == 2'b10)) 
                 Result <= PC_plus4 ;
            else if (Res_Src == 2'b11)
                 Result <= PC_target; 
            else 
                Result <= 32'd0;        
        end
    end
    
                 
endmodule


module mux_jalr (
    input reset,
    input [31:0] rs1, 
    input [31:0] pc,
    input pc_in_sel,
    output reg [31:0] PC_in
);

    always @(*) begin
        if (reset) begin
            PC_in <= 32'h80000000;
        end else begin
            if (pc_in_sel)
                PC_in <= rs1;
            else 
                PC_in <= pc;
        end
    end

endmodule

module mux_srcA(
    input [1:0]  forwardAE,
    input reset,
    input [31:0] rd1E,
    input [31:0] result,
    input [31:0] Alu_Result,
    output reg [31:0] srcA
    );
    
    always @(*) begin
        if (reset) begin
            srcA <= 32'h80000000;
        end else begin
            if (forwardAE == 2'b00) begin
                srcA <=  rd1E;
            end else if (forwardAE == 2'b01) begin
                srcA <= result;
            end else if (forwardAE == 2'b10) begin
                srcA <= Alu_Result;
            end else begin
                srcA <= 32'd0;
            end
        end
    end
endmodule

module mux_srcB(
    input [1:0]  forwardBE,
    input reset,
    input [31:0] rd2E,
    input [31:0] result,
    input [31:0] Alu_Result,
    output reg [31:0] srcB
    );
    
    always @(*) begin
        if (reset) begin
            srcB <= 32'h80000000;
        end else begin
            if (forwardBE == 2'b00) begin
                srcB <=  rd2E;
            end else if (forwardBE == 2'b01) begin
                srcB <= result;
            end else if (forwardBE == 2'b10) begin
                srcB <= Alu_Result;
            end else begin
                srcB <= 32'd0;
            end
        end
    end
endmodule
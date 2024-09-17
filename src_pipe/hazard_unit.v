`timescale 1ns / 1ps

module hazard_unit1 (
    input reset,
    input [4:0] rs1D,
    input [4:0] rs2D,
    input [4:0] rdE,
    input [4:0] rs1E,
    input [4:0] rs2E,
    input       PC_srcE,
    input       res_srcE,
    input [4:0] rdM,
    input       reg_writeM,
    input [4:0] rdW,
    input       reg_writeW,
    
    output reg  stallF,
    output reg  stallD, 
    output reg  flushD,
    output reg  flushE,
    output reg  [1:0] forwardAE,
    output reg  [1:0] forwardBE
    );
    
    reg lw_stall;
    
    always @(*) begin
        if (reset) begin
            stallF <= 0;  
            stallD <= 0;  
            flushD <= 0;  
            flushE <= 0;
            lw_stall <=  0; 
            forwardAE <= 0;
            forwardBE <= 0;
        end
        else begin
            if (((rs1E == rdM) & reg_writeM) & (rs1E != 5'd0)) begin
                forwardAE <= 2'b10;
            end else if (((rs1E == rdW) & reg_writeW) & (rs1E != 5'd0)) begin
                forwardAE <= 2'b01;
            end else begin 
                forwardAE <= 2'b00;
            end
            if (((rs2E == rdM) & reg_writeM) & (rs2E != 5'd0)) begin
                forwardBE <= 2'b10;
            end else if (((rs2E == rdW) & reg_writeW) & (rs2E != 5'd0)) begin
                forwardBE <= 2'b01;
            end else begin
                forwardBE <= 2'b00;
            end
            
            if (res_srcE & ((rs1D == rdE) | (rs2D == rdE))) begin
                lw_stall <= 1;
                stallF <= 1;
                stallD <= 1;
            end else begin 
                lw_stall <= 0;
                stallF <= 0;
                stallD <= 0;
           end
        end
        flushD <= PC_srcE;
        flushE <= lw_stall | PC_srcE;
   end
endmodule

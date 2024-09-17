`timescale 1ns / 1ps

module pipe_risc32i(
    input clk,
    input reset
    //output [31:0] Result
    );
    
    wire [31:0] data_out_instr;
    wire  [6:0] op_code = data_out_instr[6:0];
    wire  [2:0] func3 = data_out_instr[14:12];
    wire  [6:0] func7 = data_out_instr[31:25];
    
    wire [31:0] PC;
    wire [31:0] pc_next;
    
    wire [31:0] Result;
    wire [4:0] addr1_r = data_out_instr[19:15];
    wire [4:0] addr2_r = data_out_instr[24:20];
    wire [4:0] addr3_w = data_out_instr[11:7];
    wire [31:0] rd1, rd2, Src_B;
    
    wire zero, PC_src, we, u_s, reg_write;
    wire [1:0] Res_src;
    wire [3:0] ALU_Control;
    wire ALU_src;
    wire [3:0] wstrb, wstrb_load;
    wire [2:0] Imm_src;
    
    wire [31:0] ALU_res;
    
    wire [31:0] Read_Data;
    
    wire [31:0] PC_plus4, PC_target;
    
    wire [31:0] Imm_Ext;
    
    wire [31:0] PC_in;
    wire pc_in_sel;
    
    wire branch, jump;
    
    
    
    /*pipe wiressss*/
    //
    wire [31:0] data_out_instr_p1;
    wire [31:0] PC_p1;          
    wire [31:0] PC_plus4_p1;    
    
    
    //2
    wire [31:0] rd1_p2;                 
    wire [31:0] rd2_p2;                 
    wire [31:0] pc_p2;                
    wire [4:0]  addr3_p2;
    wire [31:0] Imm_Ext_p2;             
    wire [31:0] PC_plus4_p2;  
    wire [4:0] rs1D = data_out_instr_p1[19:15];
    wire [4:0] rs2D = data_out_instr_p1[24:20];
    wire [4:0] rs1E;     
    wire [4:0] rs2E;
    
    //2 control pl1
    wire reg_write_p2;  
    wire [1:0] Res_src_p2;   
    wire we_p2;       
    wire jump_p2;       
    wire branch_p2;     
    wire [3:0] ALU_Control_p2;
    wire ALU_src_p2;
    wire u_s_p2;  
    wire [3:0] wstrb_p2;        
    wire [3:0] wstrb_load_p2;
    
    //// 3
    wire [31:0] ALU_res_p3;  
    wire [31:0] rd2_p3;    
    wire [4:0]  addr3_p3;    
    wire [31:0] PC_plus4_p3;
    wire [31:0] PC_target_p3;
    
    //3 control 
    wire reg_write_p3;
    wire [1:0 ]Res_src_p3;  
    wire we_p3;  
    wire [3:0] wstrb_p3;        
    wire [3:0] wstrb_load_p3;     
    ///////////////////
    //4
    wire [31:0] Read_Data_p4;
    wire [31:0] ALU_res_p4;
    wire [4:0]  addr3_p4;  
    wire [31:0] PC_plus4_p4;
    wire [31:0] PC_target_p4;
    
    
    ///4 cntrl
    wire reg_write_p4;
    wire [1:0] Res_src_p4;
    
    //////
    wire stallF;
    wire stallD;
    wire flushD;
    wire flushE;
    wire [1:0] forwardAE;
    wire [1:0] forwardBE;
    
    hazard_unit1 hazard_unit1(
    .reset(reset),
    .rs1D(rs1D),
    .rs2D(rs2D),
    .rdE(addr3_p2),
    .rs1E(rs1E),
    .rs2E(rs2E),
    .PC_srcE(PC_src),
    .res_srcE(Res_src_p2[0]),
    .rdM(addr3_p3),
    .reg_writeM(reg_write_p3),
    .rdW(addr3_p4),
    .reg_writeW(reg_write_p4),
   
    .stallF(stallF),
    .stallD(stallD), 
    .flushD(flushD),
    .flushE(flushE),
    .forwardAE(forwardAE),
    .forwardBE(forwardBE)
    );
    
    mux_pcnext mux_pcnexttt(
        .reset(reset),
        .PC_Src(PC_src),
        .PC_plus4(PC_plus4), 
        .PC_target(PC_target),
        .PC_next(pc_next)
    ); 
        
    PC pc(
        .clk(clk),
        .en(stallF),
        .reset(reset),
        .pc_next(pc_next),
        .PC(PC)
    );
    
    instr_mem #(.w(32), .d(64)) i_mem(
        .addr_instr(PC),
        .data_out_instr(data_out_instr)
    );
    
    plus_four plusfour(
        .reset(reset),
        .PC(PC),
        .PC_plus4(PC_plus4)
    );
    
    /* ------ first stage ----*/
    
    //pipe
    pipe_1 pl_1(
    .clk(clk),
    .en(stallD),
    .clr(flushD),
    .reset(reset),
    .in_1(data_out_instr),
    .in_2(PC),
    .in_3(PC_plus4),
    .out_1(data_out_instr_p1),
    .out_2(PC_p1            ),
    .out_3(PC_plus4_p1      )
    );
    
    //ok
    ///pipe sonu
    
    RF rf(
        .clk(clk), 
        .rst(reset),
        .we(reg_write_p4), //boxuk
        .data_in(Result), 
        .addr1_r(data_out_instr_p1[19:15]), 
        .addr2_r(data_out_instr_p1[24:20]), 
        .addr3_w(addr3_p4), //bozuk
        .data_out_1(rd1), 
        .data_out_2(rd2)
    );
    
    control_unit cont_unit(
        .op_code(data_out_instr_p1[6:0]),
        .func3(data_out_instr_p1[14:12]),
        .func7(data_out_instr_p1[31:25]),
        .reset(reset),
        //.zero(zero),
        //.PC_src(PC_src),
        .Res_src(Res_src),
        .mem_write(we),
        .ALU_Control(ALU_Control),
        .u_s(u_s),
        .ALU_src(ALU_src),
        .wstrb(wstrb), //bu yok pipe
        .wstrb_load(wstrb_load), //bu yok pipe
        .Imm_src(Imm_src),
        .reg_write(reg_write),
        .pc_in_sel(pc_in_sel),
        .jump(jump),
        .branch(branch)
    );
    
    extend extenddd(
        .reset(reset),
        .Instr(data_out_instr_p1),
        .imm_src(Imm_src),
        .Imm_Ext(Imm_Ext)
    );
    
    mux_jalr mux_j(
    .reset(reset),
    .rs1(rd1), 
    .pc(PC_p1),
    .pc_in_sel(pc_in_sel),
    .PC_in(PC_in)
    );
    
    ///second stage
    ////pipe 2 
    
    pipe_2 pl2(
    .clk(clk),
    .en(0),
    .clr(flushE),
    .reset(reset),
    .in_1(rd1),
    .in_2(rd2),
    .in_3(PC_in),
    .in_4(data_out_instr_p1[11:7]),
    .in_5(Imm_Ext),
    .in_6(PC_plus4_p1),
    .in_7(rs1D),
    .in_8(rs2D),
    .out_1(rd1_p2      ),
    .out_2(rd2_p2      ),
    .out_3(pc_p2       ),
    .out_4(addr3_p2    ),
    .out_5(Imm_Ext_p2  ),
    .out_6(PC_plus4_p2 ),
    .out_7(rs1E ),
    .out_8(rs2E )
    );
    
    
    pipe_control_1 pl_c_1(
    .clk(clk),
    .en(0),
    .clr(flushE),
    .reset(reset),
    .in_1(reg_write),
    .in_2(Res_src),
    .in_3(we),
    .in_4(jump),
    .in_5(branch),
    .in_6(ALU_Control),
    .in_7(ALU_src),
    .in_8(u_s),
    .in_9(wstrb),
    .in_10(wstrb_load),
    .out_1(reg_write_p2       ),
    .out_2(Res_src_p2         ),
    .out_3(we_p2              ),
    .out_4(jump_p2            ),
    .out_5(branch_p2          ),
    .out_6(ALU_Control_p2     ),
    .out_7(ALU_src_p2         ),
    .out_8(u_s_p2             ),
    .out_9(wstrb_p2          ),
    .out_10(wstrb_load_p2    )
    );
    
    ///pipeline2 sonu
   
    wire [31:0] srcAE ; 
    wire [31:0] srcBE ;
    
    mux_srcA muxA(
    .forwardAE(forwardAE),
    .reset(reset),
    .rd1E(rd1_p2),
    .result(Result),
    .Alu_Result(ALU_res_p3),
    .srcA(srcAE)
    );
    
    mux_srcB mux_B(
    .forwardBE(forwardBE),
    .reset(reset),
    .rd2E(rd2_p2),
    .result(Result),
    .Alu_Result(ALU_res_p3),
    .srcB(srcBE)
    );
    
     mux_Bin mux_b_in(
        .reset(reset),
        .ALU_Src(ALU_src_p2),
        .RD_2(srcBE),
        .Imm_Ext(Imm_Ext_p2),
        .Src_B(Src_B)
    );
    
    ALU alu(
        .A(srcAE),
        .reset(reset), 
        .B(Src_B),
        .op(ALU_Control_p2),
        .u_s(u_s_p2),
        .FU(ALU_res),
        .zero(zero)
    );
 
    plus_imm_ext1 plus_imm_nextt(
        .reset(reset),
        .PC(pc_p2),
        .Imm_Ext(Imm_Ext_p2),
        .PC_Target(PC_target)
    );
    
    assign PC_src = ((zero &  branch_p2) | jump_p2) ;
        
    ///pl3
    pipe_3_4 pl_3(
    .clk(clk),
    .en(0),
    .clr(0),
    .reset(reset),
    .in_1(ALU_res),
    .in_2(srcBE),
    .in_3(addr3_p2),
    .in_4(PC_plus4_p2),
    .in_5(PC_target),
    .out_1(ALU_res_p3),
    .out_2(rd2_p3    ),
    .out_3(addr3_p3    ),
    .out_4(PC_plus4_p3),
    .out_5(PC_target_p3)
    );
    
    pipe_control_2 pl_c_2(
    .clk(clk),
    .en(0),
    .clr(0),
    .reset(reset),
    .in_1(reg_write_p2  ),
    .in_2(Res_src_p2    ),
    .in_3(we_p2         ),
    .in_4(wstrb_p2      ),
    .in_5(wstrb_load_p2    ),
    .out_1(reg_write_p3    ),
    .out_2(Res_src_p3      ),
    .out_3(we_p3           ),
    .out_4(wstrb_p3        ),
    .out_5(wstrb_load_p3   )
    );
    
    
     /////////////////////////////////////////////
    
    data_mem  #(.w(32), .d(256)) d_mem(
        .clk(clk),
        .data_in(rd2_p3),
        .addr_in(ALU_res_p3),
        .we(we_p3),
        .wstrb(wstrb_p3),
        .wstrb_load(wstrb_load_p3),
        .data_out(Read_Data)
    );  
    
    ////////// 
    
    //pp4
    pipe_3_4 pl_4(
    .clk(clk),
    .en(0),
    .clr(0),
    .reset(reset),
    .in_1(Read_Data     ),
    .in_2(ALU_res_p3    ),
    .in_3(addr3_p3      ),
    .in_4(PC_plus4_p3   ),
    .in_5(PC_target_p3  ),
    .out_1(Read_Data_p4 ),
    .out_2(ALU_res_p4   ),
    .out_3(addr3_p4     ),
    .out_4(PC_plus4_p4  ),
    .out_5(PC_target_p4 )
    );
    
    pipe_control_3 pl_c_3(
    .clk(clk),
    .reset(reset),
    .en(0),
    .clr(0),
    .in_1(reg_write_p3),
    .in_2(Res_src_p3),
    .out_1(reg_write_p4),
    .out_2(Res_src_p4)
    );
    
    //// 
    
    mux_result mux_res(
        .reset(reset),
        .Res_Src(Res_src_p4         ),
        .ALU_res(ALU_res_p4         ),
        .read_data(Read_Data_p4     ),
        .PC_plus4(PC_plus4_p4       ),
        .PC_target(PC_target_p4     ),
        .Result(Result              )
    );  
    
    
    
    integer f;
    initial begin
        f = $fopen("spike_rtl.log");
    end
    
    integer i = 0;
    
    always @(posedge clk) begin
        i = i + 1;
        $display("%d   0x%x (0x%x) x%d 0x%x", i , PC, data_out_instr, addr3_w, Result);
        $fwrite(f, "0x%x (0x%x) x%d 0x%x\n", PC, data_out_instr, addr3_w, Result);
    end
    
endmodule

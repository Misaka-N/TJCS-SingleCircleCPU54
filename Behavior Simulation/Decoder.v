`timescale 1ns / 1ps
module Decoder(                 //所有接口如果当前译码出的指令不需要，置为高阻抗
    input  [31:0] instr_in,     //需要译码的指令，也就是当前要执行的指令
    output [53:0] op_flags,     //54条指令对应的标志位
    output [4:0]  RsC,          //Rs对应的寄存器的地址
    output [4:0]  RtC,          //Rt对应的寄存器的地址
    output [4:0]  RdC,          //Rd对应的寄存器的地址
    output [4:0]  shamt,        //位移偏移量
    output [15:0] immediate,    //立即数
    output [25:0] address       //跳转地址（J型指令用）
    );
/* 定义各指令在原指令中对应的编码 */
parameter ADD_OPE   = 6'b100000;
parameter ADDU_OPE  = 6'b100001;
parameter SUB_OPE   = 6'b100010;
parameter SUBU_OPE  = 6'b100011;
parameter AND_OPE   = 6'b100100;
parameter OR_OPE    = 6'b100101;
parameter XOR_OPE   = 6'b100110;
parameter NOR_OPE   = 6'b100111;
parameter SLT_OPE   = 6'b101010;
parameter SLTU_OPE  = 6'b101011;
parameter SLL_OPE   = 6'b000000;
parameter SRL_OPE   = 6'b000010;
parameter SRA_OPE   = 6'b000011;
parameter SLLV_OPE  = 6'b000100;
parameter SRLV_OPE  = 6'b000110;
parameter SRAV_OPE  = 6'b000111;
parameter JR_OPE    = 6'b001000;
parameter ADDI_OPE  = 6'b001000;
parameter ADDIU_OPE = 6'b001001;
parameter ANDI_OPE  = 6'b001100;
parameter ORI_OPE   = 6'b001101;
parameter XORI_OPE  = 6'b001110;
parameter LW_OPE    = 6'b100011;
parameter SW_OPE    = 6'b101011;
parameter BEQ_OPE   = 6'b000100;
parameter BNE_OPE   = 6'b000101;
parameter SLTI_OPE  = 6'b001010;
parameter SLTIU_OPE = 6'b001011;
parameter LUI_OPE   = 6'b001111;
parameter J_OPE     = 6'b000010;
parameter JAL_OPE   = 6'b000011;

/* 54条指令添加部分 */
parameter CLZ_OPE     = 6'b100000;
parameter JALR_OPE    = 6'b001001;
parameter MTHI_OPE    = 6'b010001;
parameter MFHI_OPE    = 6'b010000;
parameter MTLO_OPE    = 6'b010011;
parameter MFLO_OPE    = 6'b010010;
parameter SB_OPE      = 6'b101000;
parameter SH_OPE      = 6'b101001;
parameter LB_OPE      = 6'b100000;
parameter LH_OPE      = 6'b100001;
parameter LBU_OPE     = 6'b100100;
parameter LHU_OPE     = 6'b100101;
parameter ERET_OPE    = 6'b011000;
parameter BREAK_OPE   = 6'b001101;
parameter SYSCALL_OPE = 6'b001100;
parameter TEQ_OPE     = 6'b110100;
parameter MFC0_OPE    = 5'b00000;
parameter MTC0_OPE    = 5'b00100; //注意这两个指令是靠另外五位order区分的，op和func都一样
parameter MUL_OPE     = 6'b000010;
parameter MULTU_OPE   = 6'b011001;
parameter DIV_OPE     = 6'b011010;
parameter DIVU_OPE    = 6'b011011;
parameter BGEZ_OPE    = 6'b000001;

/* 54条指令对应的标志位 */
parameter ADD   = 6'd0;
parameter ADDU  = 6'd1;
parameter SUB   = 6'd2;
parameter SUBU  = 6'd3;
parameter AND   = 6'd4;
parameter OR    = 6'd5;
parameter XOR   = 6'd6;
parameter NOR   = 6'd7;
parameter SLT   = 6'd8;
parameter SLTU  = 6'd9;
parameter SLL   = 6'd10;
parameter SRL   = 6'd11;
parameter SRA   = 6'd12;
parameter SLLV  = 6'd13;
parameter SRLV  = 6'd14;
parameter SRAV  = 6'd15;
parameter JR    = 6'd16;
parameter ADDI  = 6'd17;
parameter ADDIU = 6'd18;
parameter ANDI  = 6'd19;
parameter ORI   = 6'd20;
parameter XORI  = 6'd21;
parameter LW    = 6'd22;
parameter SW    = 6'd23;
parameter BEQ   = 6'd24;
parameter BNE   = 6'd25;
parameter SLTI  = 6'd26;
parameter SLTIU = 6'd27;
parameter LUI   = 6'd28;
parameter J     = 6'd29;
parameter JAL   = 6'd30;

parameter CLZ     = 6'd31;
parameter JALR    = 6'd32;
parameter MTHI    = 6'd33;
parameter MTLO    = 6'd34;
parameter MFHI    = 6'd35;
parameter MFLO    = 6'd36;
parameter SB      = 6'd37;
parameter SH      = 6'd38;
parameter LB      = 6'd39;
parameter LH      = 6'd40;
parameter LBU     = 6'd41;
parameter LHU     = 6'd42;
parameter ERET    = 6'd43;
parameter BREAK   = 6'd44;
parameter SYSCALL = 6'd45;
parameter TEQ     = 6'd46;
parameter MFC0    = 6'd47;
parameter MTC0    = 6'd48;
parameter MUL     = 6'd49;
parameter MULTU   = 6'd50;
parameter DIV     = 6'd51;
parameter DIVU    = 6'd52;
parameter BGEZ    = 6'd53;

/* 下面是赋值 */
/* 对指令进行译码，判断是哪个指令 */
assign op_flags[ADD]   = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == ADD_OPE )) ? 1'b1 : 1'b0;
assign op_flags[ADDU]  = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == ADDU_OPE)) ? 1'b1 : 1'b0;
assign op_flags[SUB]   = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == SUB_OPE )) ? 1'b1 : 1'b0;
assign op_flags[SUBU]  = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == SUBU_OPE)) ? 1'b1 : 1'b0;
assign op_flags[AND]   = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == AND_OPE )) ? 1'b1 : 1'b0;
assign op_flags[OR]    = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == OR_OPE  )) ? 1'b1 : 1'b0;
assign op_flags[XOR]   = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == XOR_OPE )) ? 1'b1 : 1'b0;
assign op_flags[NOR]   = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == NOR_OPE )) ? 1'b1 : 1'b0;
assign op_flags[SLT]   = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == SLT_OPE )) ? 1'b1 : 1'b0;
assign op_flags[SLTU]  = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == SLTU_OPE)) ? 1'b1 : 1'b0;
assign op_flags[SLL]   = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == SLL_OPE )) ? 1'b1 : 1'b0;
assign op_flags[SRL]   = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == SRL_OPE )) ? 1'b1 : 1'b0;
assign op_flags[SRA]   = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == SRA_OPE )) ? 1'b1 : 1'b0;
assign op_flags[SLLV]  = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == SLLV_OPE)) ? 1'b1 : 1'b0;
assign op_flags[SRLV]  = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == SRLV_OPE)) ? 1'b1 : 1'b0;
assign op_flags[SRAV]  = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == SRAV_OPE)) ? 1'b1 : 1'b0;
assign op_flags[JR]    = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == JR_OPE  )) ? 1'b1 : 1'b0;
assign op_flags[ADDI]  = (instr_in[31:26] == ADDI_OPE ) ? 1'b1 : 1'b0;
assign op_flags[ADDIU] = (instr_in[31:26] == ADDIU_OPE) ? 1'b1 : 1'b0;
assign op_flags[ANDI]  = (instr_in[31:26] == ANDI_OPE ) ? 1'b1 : 1'b0;
assign op_flags[ORI]   = (instr_in[31:26] == ORI_OPE  ) ? 1'b1 : 1'b0;
assign op_flags[XORI]  = (instr_in[31:26] == XORI_OPE ) ? 1'b1 : 1'b0;
assign op_flags[LW]    = (instr_in[31:26] == LW_OPE   ) ? 1'b1 : 1'b0;
assign op_flags[SW]    = (instr_in[31:26] == SW_OPE   ) ? 1'b1 : 1'b0;
assign op_flags[BEQ]   = (instr_in[31:26] == BEQ_OPE  ) ? 1'b1 : 1'b0;
assign op_flags[BNE]   = (instr_in[31:26] == BNE_OPE  ) ? 1'b1 : 1'b0;
assign op_flags[SLTI]  = (instr_in[31:26] == SLTI_OPE ) ? 1'b1 : 1'b0;
assign op_flags[SLTIU] = (instr_in[31:26] == SLTIU_OPE) ? 1'b1 : 1'b0;
assign op_flags[LUI]   = (instr_in[31:26] == LUI_OPE  ) ? 1'b1 : 1'b0;
assign op_flags[J]     = (instr_in[31:26] == J_OPE    ) ? 1'b1 : 1'b0;
assign op_flags[JAL]   = (instr_in[31:26] == JAL_OPE  ) ? 1'b1 : 1'b0;

assign op_flags[CLZ]     = ((instr_in[31:26] == 6'b011100) && (instr_in[5:0] == CLZ_OPE )) ? 1'b1 : 1'b0;
assign op_flags[JALR]    = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == JALR_OPE )) ? 1'b1 : 1'b0;
assign op_flags[MTHI]    = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == MTHI_OPE )) ? 1'b1 : 1'b0;
assign op_flags[MTLO]    = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == MTLO_OPE )) ? 1'b1 : 1'b0;
assign op_flags[MFHI]    = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == MFHI_OPE )) ? 1'b1 : 1'b0;
assign op_flags[MFLO]    = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == MFLO_OPE )) ? 1'b1 : 1'b0;
assign op_flags[SB]      = (instr_in[31:26] == SB_OPE  ) ? 1'b1 : 1'b0;
assign op_flags[SH]      = (instr_in[31:26] == SH_OPE  ) ? 1'b1 : 1'b0;
assign op_flags[LB]      = (instr_in[31:26] == LB_OPE  ) ? 1'b1 : 1'b0;
assign op_flags[LH]      = (instr_in[31:26] == LH_OPE  ) ? 1'b1 : 1'b0;
assign op_flags[LBU]     = (instr_in[31:26] == LBU_OPE ) ? 1'b1 : 1'b0;
assign op_flags[LHU]     = (instr_in[31:26] == LHU_OPE ) ? 1'b1 : 1'b0;
assign op_flags[ERET]    = ((instr_in[31:26] == 6'b010000) && (instr_in[5:0] == ERET_OPE    )) ? 1'b1 : 1'b0;
assign op_flags[BREAK]   = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == BREAK_OPE   )) ? 1'b1 : 1'b0;
assign op_flags[SYSCALL] = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == SYSCALL_OPE )) ? 1'b1 : 1'b0;
assign op_flags[TEQ]     = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == TEQ_OPE     )) ? 1'b1 : 1'b0;
assign op_flags[MFC0]    = ((instr_in[31:26] == 6'b010000) && (instr_in[5:0] == 6'h0) && (instr_in[25:21] == MFC0_OPE)) ? 1'b1 : 1'b0;
assign op_flags[MTC0]    = ((instr_in[31:26] == 6'b010000) && (instr_in[5:0] == 6'h0) && (instr_in[25:21] == MTC0_OPE)) ? 1'b1 : 1'b0;
assign op_flags[MUL]     = ((instr_in[31:26] == 6'b011100) && (instr_in[5:0] == MUL_OPE     )) ? 1'b1 : 1'b0;
assign op_flags[MULTU]   = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == MULTU_OPE   )) ? 1'b1 : 1'b0;
assign op_flags[DIV]     = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == DIV_OPE     )) ? 1'b1 : 1'b0;
assign op_flags[DIVU]    = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == DIVU_OPE    )) ? 1'b1 : 1'b0;
assign op_flags[BGEZ]    = ((instr_in[31:26] == BGEZ_OPE) && (instr_in[20:16] == 5'b00001) ) ? 1'b1 : 1'b0;


/* 取出指令中各部分的值 */
assign RsC = (op_flags[ADD]  || op_flags[ADDU] || op_flags[SUB]  || op_flags[SUBU]  ||
              op_flags[AND]  || op_flags[OR]   || op_flags[XOR]  || op_flags[NOR]   ||
              op_flags[SLT]  || op_flags[SLTU] || op_flags[SLLV] || op_flags[SRLV]  ||
              op_flags[SRAV] || op_flags[JR]   || op_flags[ADDI] || op_flags[ADDIU] ||
              op_flags[ANDI] || op_flags[ORI]  || op_flags[XORI] || op_flags[LW]    ||
              op_flags[SW]   || op_flags[BEQ]  || op_flags[BNE]  || op_flags[SLTI]  ||
              op_flags[SLTIU]|| op_flags[CLZ]  || op_flags[JALR] || op_flags[MTHI]  ||
              op_flags[MTLO] || op_flags[SB]   || op_flags[SH]   || op_flags[LB]    ||
              op_flags[LH]   || op_flags[LBU]  || op_flags[LHU]  || op_flags[TEQ]   ||
              op_flags[MUL]  || op_flags[MULTU]|| op_flags[DIV]  || op_flags[DIVU]  || 
              op_flags[BGEZ]) ? instr_in[25:21] : 
              (op_flags[MTC0] ? instr_in[15:11] : 5'hz);

assign RtC = (op_flags[ADD]  || op_flags[ADDU]  || op_flags[SUB]   || op_flags[SUBU] ||
              op_flags[AND]  || op_flags[OR]    || op_flags[XOR]   || op_flags[NOR]  ||
              op_flags[SLT]  || op_flags[SLTU]  || op_flags[SLL]   || op_flags[SRL]  ||
              op_flags[SRA]  || op_flags[SLLV]  || op_flags[SRLV]  || op_flags[SRAV] ||
              op_flags[SW]   || op_flags[BEQ]   || op_flags[BNE]   || op_flags[SB]   ||
              op_flags[SH]   || op_flags[TEQ]   || op_flags[MTC0]  || op_flags[MUL]  ||
              op_flags[MULTU]|| op_flags[DIV]   || op_flags[DIVU]) ? instr_in[20:16] : 
              (op_flags[MFC0] ? instr_in[15:11] : 5'hz);

assign RdC = (op_flags[ADD]  || op_flags[ADDU]  || op_flags[SUB]  || op_flags[SUBU]  ||
              op_flags[AND]  || op_flags[OR]    || op_flags[XOR]  || op_flags[NOR]   ||
              op_flags[SLT]  || op_flags[SLTU]  || op_flags[SLL]  || op_flags[SRL]   ||
              op_flags[SRA]  || op_flags[SLLV]  || op_flags[SRLV] || op_flags[SRAV]  ||
              op_flags[CLZ]  || op_flags[JALR]  || op_flags[MFHI] || op_flags[MFLO]  ||
              op_flags[MUL]) ? instr_in[15:11] : ((
              op_flags[ADDI] || op_flags[ADDIU] || op_flags[ANDI] || op_flags[ORI]   || 
              op_flags[XORI] || op_flags[LW]    || op_flags[SLTI] || op_flags[SLTIU] ||
              op_flags[LUI]  || op_flags[MFC0]  || op_flags[LB]   || op_flags[LH]    || 
              op_flags[LBU]  || op_flags[LHU]   ) ? instr_in[20:16] : (op_flags[JAL] ? 5'd31 : 5'hz));

assign shamt = (op_flags[SLL] || op_flags[SRL] || op_flags[SRA]) ? instr_in[10:6] : 5'hz;        

assign immediate = (op_flags[ADDI] || op_flags[ADDIU] || op_flags[ANDI]  || op_flags[ORI] || 
                    op_flags[XORI] || op_flags[LW]    || op_flags[SW]    || op_flags[BEQ] || 
                    op_flags[BNE]  || op_flags[SLTI]  || op_flags[SLTIU] || op_flags[LUI] ||
                    op_flags[SB]   || op_flags[SH]    || op_flags[LB]    || op_flags[LH]  ||
                    op_flags[LBU]  || op_flags[LHU]   || op_flags[BGEZ]) ? instr_in[15:0] : 16'hz;

assign address = (op_flags[J] || op_flags[JAL]) ? instr_in[25:0] : 26'hz;     

endmodule

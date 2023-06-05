`timescale 1ns / 1ps
module Controler(              //控制器，根据当前要执行的指令输出各个元器件的状态
    input [53:0] op_flags,     //54条指令对应的编码
    input zero_flag,           //比较指令用，0标志位
    input sign_flag,           //BGEZ指令用，是否为负数
    output reg_w,              //RegFile寄存器堆是否可写入
    output [3:0] aluc,         //ALUC的指令，决定ALUC执行何种操作
    output dm_r,               //DMEM是否可写入
    output dm_w,               //是否从DMEM中读取数据
    output HI_w,               //HI是否可写入
    output LO_w,               //LO是否可写入
    output [4:0] cause,        //中断类型编码
    output [4:0] ext_ena,      //EXT扩展是否开启，5个状态分别对应EXT1、EXT5、EXT16、EXT16(S)、EXT18(S),其中EXT[0]对应EXT1
    output cat_ena,            //是否需要拼接
    output [10:0] mux,         //10个多路选择器的状态（选择0还是选择1）(0没用到，为了使MUX编号和数组下标对应所以多一个)
    output [2:0]  mux6_1,      //6路选择器
    output [2:0]  mux7_1       //7路选择器
    );

/* 54条指令的状态编码 */
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

/* 下面是赋值，也就是根据要执行的操作决定各元器件的状态 */
assign reg_w = (!op_flags[JR]    && !op_flags[SW]      && !op_flags[BEQ] && !op_flags[BNE]  && !op_flags[J]     &&
                !op_flags[MTHI]  && !op_flags[MTLO]    && !op_flags[SB]  && !op_flags[SH]   && !op_flags[ERET]  &&
                !op_flags[BREAK] && !op_flags[SYSCALL] && !op_flags[TEQ] && !op_flags[MTC0] && !op_flags[MULTU] &&
                !op_flags[DIV]   && !op_flags[DIVU]    && !op_flags[BGEZ]) ? 1'b1 : 1'b0;

assign aluc[3] = (op_flags[SLT]  || op_flags[SLTU]  || op_flags[SLLV] || op_flags[SRLV] ||
                  op_flags[SRAV] || op_flags[SLL]   || op_flags[SRL]  || op_flags[SRA]  || 
                  op_flags[SLTI] || op_flags[SLTIU] || op_flags[LUI]) ? 1'b1 : 1'b0;
assign aluc[2] = (op_flags[AND]  || op_flags[OR]    || op_flags[XOR]  || op_flags[NOR]  ||
                  op_flags[SLLV] || op_flags[SRLV]  || op_flags[SRAV] || op_flags[SLL]  ||
                  op_flags[SRL]  || op_flags[SRA]   || op_flags[ANDI] || op_flags[ORI]  ||
                  op_flags[XORI]) ? 1'b1 : 1'b0;
assign aluc[1] = (op_flags[ADD]  || op_flags[SUB]   || op_flags[XOR]  || op_flags[NOR]  ||
                  op_flags[SLT]  || op_flags[SLTU]  || op_flags[SLLV] || op_flags[SLL]  ||
                  op_flags[ADDI] || op_flags[XORI]  || op_flags[SLTI] || op_flags[SLTIU]||
                  op_flags[SB]   || op_flags[SH]    || op_flags[LB]   || op_flags[LH]   ||
                  op_flags[LBU]  || op_flags[LHU]   || op_flags[TEQ]  || op_flags[BGEZ]) ? 1'b1 : 1'b0;
assign aluc[0] = (op_flags[SUB]  || op_flags[SUBU]  || op_flags[OR]   || op_flags[NOR]  ||
                  op_flags[SLT]  || op_flags[SLLV]  || op_flags[SRLV] || op_flags[SLL]  ||
                  op_flags[SRL]  || op_flags[ORI]   || op_flags[SLTI] || op_flags[LUI]  ||
                  op_flags[BEQ]  || op_flags[BNE]   || op_flags[MFC0] || op_flags[BGEZ]) ? 1'b1 : 1'b0;
//aluc[0]中SLLV、SLL、LUI加不加均可

assign dm_r = op_flags[LW] || op_flags[LB] || op_flags[LH] || op_flags[LBU] || op_flags[LHU] ? 1'b1 : 1'b0;
assign dm_w = op_flags[SW] || op_flags[SB] || op_flags[SH] ? 1'b1 : 1'b0;

assign HI_w = (op_flags[MTHI] || op_flags[MULTU] || op_flags[DIV] || op_flags[DIVU]) ? 1'b1 : 1'b0;
assign LO_w = (op_flags[MTLO] || op_flags[MULTU] || op_flags[DIV] || op_flags[DIVU]) ? 1'b1 : 1'b0;

assign cause = op_flags[SYSCALL] ? 5'b01000 : (op_flags[BREAK] ? 5'b01001 : (op_flags[TEQ] ? 5'b01101 : 5'bz));

assign ext_ena[4] = (op_flags[BEQ]  || op_flags[BNE]   || op_flags[BGEZ]) ? 1'b1 : 1'b0;                   //EXT18(S)
assign ext_ena[3] = (op_flags[ADDI] || op_flags[ADDIU] || op_flags[LW]   || op_flags[SW] ||
                     op_flags[SLTI] || op_flags[SLTIU] || op_flags[SB]   || op_flags[SH] ||
                     op_flags[LB]   || op_flags[LH]    || op_flags[LBU]  || op_flags[LHU]) ? 1'b1 : 1'b0;   //EXT16(S)
assign ext_ena[2] = (op_flags[ANDI] || op_flags[ORI]   || op_flags[XORI] || op_flags[LUI]) ? 1'b1 : 1'b0;   //EXT16
assign ext_ena[1] = (op_flags[SLL]  || op_flags[SRL]   || op_flags[SRA]) ? 1'b1 : 1'b0;                    //EXT5
assign ext_ena[0] = (op_flags[SLT]  || op_flags[SLTU]  || op_flags[SLTI] || op_flags[SLTIU]) ? 1'b1 : 1'b0; //EXT1

assign cat_ena = (op_flags[J] || op_flags[JAL]) ? 1'b1 : 1'b0;

assign mux[1]  = op_flags[MFC0] ? 1'b1 : 1'b0;
assign mux[2]  = (op_flags[ANDI] || op_flags[ORI]   || op_flags[XORI] || op_flags[LUI]) ? 1'b0 : 1'b1;   //注意这里是选0
assign mux[3]  = (op_flags[SLL]  || op_flags[SRL]   || op_flags[SRA]) ? 1'b1 : 1'b0;
assign mux[4]  = (op_flags[ADDI] || op_flags[ADDIU] || op_flags[ANDI] || op_flags[ORI]  ||
                 op_flags[XORI] || op_flags[LW]    || op_flags[SW]   || op_flags[SLTI] ||
                 op_flags[SLTIU]|| op_flags[LUI]   || op_flags[SB]   || op_flags[SH]   ||
                 op_flags[LB]   || op_flags[LH]    || op_flags[LBU]  || op_flags[LHU]) ? 1'b1 : 1'b0; 
assign mux[5]  = op_flags[MTHI] ? 1'b0 : 1'b1;        //注意这里是选0
assign mux[6]  = op_flags[MTLO] ? 1'b0 : 1'b1;        //注意这里是选0
assign mux[7]  = op_flags[MFHI] ? 1'b0 : 1'b1;        //注意这里是选0
assign mux[8]  = (op_flags[SLT]  || op_flags[SLTU]  || op_flags[SLTI] || op_flags[SLTIU]) ? 1'b0 : 1'b1; //注意这里是选0
assign mux[9]  = op_flags[MULTU] ? 1'b0 : 1'b1;       //注意这里是选0
assign mux[10] = op_flags[MULTU] ? 1'b0 : 1'b1;       //注意这里是选0
assign mux6_1  = (op_flags[JR]    || op_flags[JALR])                                                  ? 3'b000 : 
                 ((op_flags[BEQ] && zero_flag) || (op_flags[BNE] && !zero_flag) || (op_flags[BGEZ] && !sign_flag) ? 3'b010 : 
                 (op_flags[BREAK] || op_flags[SYSCALL] || (op_flags[TEQ] && zero_flag)                ? 3'b011 :
                 (op_flags[ERET]                                                                      ? 3'b100 :
                 (op_flags[J]     || op_flags[JAL]                                                    ? 3'b101 : 3'b001))));
assign mux7_1  = (op_flags[LW]    || op_flags[LB]  || op_flags[LH] || op_flags[LBU] || op_flags[LHU]) ? 3'b000 :
                 (op_flags[MFHI]  || op_flags[MFLO]                                                   ? 3'b001 :
                 (op_flags[CLZ]                                                                       ? 3'b010 :
                 (op_flags[MUL]                                                                       ? 3'b100 :
                 (op_flags[JALR]  || op_flags[JAL]                                                    ? 3'b101 :
                 (op_flags[MFC0]                                                                      ? 3'b110 : 3'b011)))));
endmodule

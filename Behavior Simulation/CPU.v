`timescale 1ns / 1ps
module cpu(
    input clk,                  //CPU执行时钟
    input ena,                  //使能信号端
    input rst,                  //复位信号
    input [31:0] instr_in,      //当前要执行的指令
    input [31:0] dm_data,       //读取到的DMEM的具体内容
    output dm_ena,              //是否需要启用DMEM
    output dm_w,                //如果启用DMEM，是否为写入
    output dm_r,                //如果启用DMEM，是否为读取
    output [31:0] pc_out,       //输出指令地址，告诉IMEM要取哪条
    output [31:0] dm_addr,      //启用DMEM的地址
    output [31:0] dm_data_w,    //要写入DMEM的内容 
    output sb_flag,             //当前写入指令是否是SB发出
    output sh_flag,             //当前写入指令是否是SH发出
    output sw_flag,             //当前写入指令是否是SW发出
    output lb_flag,             //当前读取指令是否是LB发出
    output lh_flag,             //当前读取指令是否是LH发出
    output lbu_flag,            //当前读取指令是否是LBU发出
    output lhu_flag,            //当前读取指令是否是LHU发出
    output lw_flag              //当前读取指令是否是LW发出
    );

/* 54条指令对应的序号 */
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

/* 定义一些内部变量 */
/* Decoder用 */ 
wire [53:0] op_flags;            //各个指令的标志信息
wire [4:0] RsC;                 //Rs对应的寄存器的地址
wire [4:0] RtC;                 //Rt对应的寄存器的地址
wire [4:0] RdC;                 //Rd对应的寄存器的地址
wire [4:0] shamt;               //位移偏移量（SLL，SRL，SRA用）
wire [15:0] immediate;          //立即数（I型指令用）
wire [25:0] address;            //跳转地址（J型指令用）

/* Control用 */
wire reg_w;                     //RegFile寄存器堆是否可写入
wire [4:0] cause;               //中断情况
wire [10:0] mux;                //10个多路选择器的状态
wire [2:0]  mux6_1;             //6路选择器的选择信号
wire [2:0]  mux7_1;             //7路选择器的选择信号
wire [4:0] ext_ena;             //EXT扩展是否开启，5个状态分别对应EXT1、EXT5、EXT16、EXT16(S)、EXT18(S),其中EXT[0]对应EXT1
wire cat_ena;                   //是否需要拼接

/* ALU用 */
wire [31:0] a, b;                       //ALU的A、B运算输入端
wire [3:0]  aluc;                       //ALUC四位运算指令
wire [31:0] alu_data_out;               //ALU输出的数据
wire zero, carry, negative, overflow;   //四个标志位

/* 寄存器堆RegFile用 */
wire [31:0] Rd_data_in;     //要向寄存器中写入的值
wire [31:0] Rs_data_out;    //Rs对应的寄存器的输出值
wire [31:0] Rt_data_out;    //Rt对应的寄存器的输出值

/* PC寄存器用 */
wire [31:0] pc_addr_in;     //本次输入PC寄存器的指令地址，也就是下一次要执行的指令
wire [31:0] pc_addr_out;    //本次从PC寄存器中传出的指令地址，也就是当前需要执行的指令

/* HI_LO寄存器堆用 */
wire HI_w;                  //使能信号，是否是向HI中写入数
wire LO_w;                  //使能信号，是否是向LO中写入数
wire [31:0] HI_out;         //从HI传出的数
wire [31:0] LO_out;         //从LO传出的数

/* DIV模块用 */
wire sign_flag;             //是否是有符号乘除法
wire [31:0] DIV_A;          //输入的被除数
wire [31:0] DIV_B;          //输入的除数
wire [31:0] DIV_R;          //余数
wire [31:0] DIV_Q;          //商

/* MUL模块用 */
wire [31:0] MUL_A;          //输入的乘数A
wire [31:0] MUL_B;          //输入的乘数B
wire [31:0] MUL_HI;         //高32位结果
wire [31:0] MUL_LO;         //低32位结果

/* CP0模块用 */
wire [31:0] cp0_out;        //CP0输出的数据
wire [31:0] epc_out;        //CP0送出的PC地址，用于更新PC

/* CLZ模块用 */
wire [31:0] CLZ_out;        //CLZ最终输出内容

/* 连接各模块 */
/* 符号、数据扩展器线路 */
wire [31:0] ext1_out;
wire [31:0] ext5_out;
wire [31:0] ext16_out;
wire signed [31:0] ext16_out_signed;
wire signed [31:0] ext18_out_signed;

assign ext1_out         = (op_flags[SLT]  || op_flags[SLTU]) ? negative : 
                          (op_flags[SLTI] || op_flags[SLTIU]) ? carry : 32'hz;
assign ext5_out         = (op_flags[SLL]  || op_flags[SRL]   || op_flags[SRA]) ? shamt : 32'hz;
assign ext16_out        = (op_flags[ANDI] || op_flags[ORI]   || op_flags[XORI] || op_flags[LUI]) ? { 16'h0 , immediate[15:0] } : 32'hz;
assign ext16_out_signed = (op_flags[ADDI] || op_flags[ADDIU] || op_flags[LW]   || op_flags[SW] || 
                           op_flags[SLTI] || op_flags[SLTIU] || op_flags[SB]   || op_flags[SH] ||
                           op_flags[LB]   || op_flags[LH]    || op_flags[LBU]  || op_flags[LHU]) ?  { {16{immediate[15]}} , immediate[15:0] } : 32'hz;
assign ext18_out_signed = (op_flags[BEQ]  || op_flags[BNE]   || op_flags[BGEZ]) ? {{14{immediate[15]}}, immediate[15:0], 2'b0} : 32'hz;
//注意：Verilog不会显式地将无符号数变为有符号数，只有在运算时才会进行操作。因此我们不能通过赋值的方法完成从无符号数到有符号数的扩展，必须将符号位复制到高位

/* ||拼接器线路 */
wire [31:0] cat_out;

assign cat_out = cat_ena ? {pc_out[31:28], address[25:0], 2'h0} : 32'hz;

/* NPC线路 */
wire [31:0] npc;
wire [31:0] add_out_61;    //加法器，对应6选1通路
wire [31:0] add_out_71;    //加法器，对应7选1通路
assign npc = pc_addr_out + 4;

/* 多路选择器线路 */
wire [31:0] mux1_out;
wire [31:0] mux2_out;
wire [31:0] mux3_out;
wire [31:0] mux4_out;
wire [31:0] mux5_out;
wire [31:0] mux6_out;
wire [31:0] mux7_out;
wire [31:0] mux8_out;
wire [31:0] mux9_out;
wire [31:0] mux10_out;
wire [31:0] mux6_1_out;
wire [31:0] mux7_1_out;

assign mux1_out  = mux[1]  ? Rt_data_out : Rs_data_out;
assign mux2_out  = mux[2]  ? ext16_out_signed : ext16_out;
assign mux3_out  = mux[3]  ? ext5_out : Rs_data_out;
assign mux4_out  = mux[4]  ? mux2_out : Rt_data_out;
assign mux5_out  = mux[5]  ? mux9_out : Rs_data_out;
assign mux6_out  = mux[6]  ? mux10_out: Rs_data_out;
assign mux7_out  = mux[7]  ? LO_out   : HI_out;
assign mux8_out  = mux[8]  ? alu_data_out : ext1_out;
assign mux9_out  = mux[9]  ? DIV_R : MUL_HI;
assign mux10_out = mux[10] ? DIV_Q : MUL_LO;

/* PC线路 */
assign pc_addr_in = mux6_1_out;
assign add_out_61 = ext18_out_signed + npc;
assign add_out_71 = pc_addr_out + 4;

/* ALU 接线口 */
assign a = mux3_out;
assign b = op_flags[BGEZ] ? 32'd0 : mux4_out;

/* IMEM接口 */
assign pc_out = pc_addr_out;

/* DMEM接口 */
assign dm_ena    = (dm_r || dm_w) ? 1'b1 : 1'b0;
assign dm_addr   = alu_data_out;
assign dm_data_w = Rt_data_out;
assign sb_flag   = op_flags[SB];
assign sh_flag   = op_flags[SH];
assign sw_flag   = op_flags[SW];
assign lb_flag   = op_flags[LB];
assign lh_flag   = op_flags[LH];
assign lbu_flag  = op_flags[LBU];
assign lhu_flag  = op_flags[LHU];
assign lw_flag   = op_flags[LW];

/* 寄存器堆线路 */
assign Rd_data_in = mux7_1_out;

/* DIV MUL用 */
assign sign_flag = op_flags[MUL] || op_flags[DIV] ? 1'b1 : 1'b0;
assign MUL_A = op_flags[MUL] || op_flags[MULTU] ? Rs_data_out : 32'hz;
assign MUL_B = op_flags[MUL] || op_flags[MULTU] ? Rt_data_out : 32'hz;
assign DIV_A = op_flags[DIV] || op_flags[DIVU]  ? Rs_data_out : 32'hz;
assign DIV_B = op_flags[DIV] || op_flags[DIVU] ? Rt_data_out : 32'hz;

/* 实例化译码器 */
Decoder Decoder_inst(
    .instr_in(instr_in),        //需要译码的指令，也就是当前要执行的指令
    .op_flags(op_flags),        //54条指令对应的标记位
    .RsC(RsC),                  //Rs对应的寄存器的地址
    .RtC(RtC),                  //Rt对应的寄存器的地址
    .RdC(RdC),                  //Rd对应的寄存器的地址
    .shamt(shamt),              //位移偏移量
    .immediate(immediate),      //立即数
    .address(address)           //跳转地址
    );

/* 实例化控制器 */
Controler Controler_inst(              
    .op_flags(op_flags),       //54条指令对应的标记
    .zero_flag(zero),          //ALU ZF标志位
    .sign_flag(negative),      //ALU SF标志位
    .reg_w(reg_w),             //RegFile寄存器堆是否可写入
    .aluc(aluc),               //ALUC的指令，决定ALUC执行何种操作
    .dm_r(dm_r),               //DMEM是否可写入
    .dm_w(dm_w),               //是否从DMEM中读取数据
    .HI_w(HI_w),               //HI是否写入
    .LO_w(LO_w),               //LO是否写入
    .cause(cause),             //中断情况
    .ext_ena(ext_ena),         //EXT扩展是否开启，5个状态分别对应EXT1、EXT5、EXT16、EXT16(S)、EXT18(S),其中EXT[0]对应EXT1
    .cat_ena(cat_ena),         //是否需要拼接
    .mux(mux),                 //10个多路选择器的状态（选择0还是选择1)(0没用到，为了使MUX编号和数组下标对应所以多开了一个)）
    .mux6_1(mux6_1),           //6路选择器的选择信号
    .mux7_1(mux7_1)            //7路选择器的选择信号
    );

/* 实例化ALU */
ALU ALU_inst(                      
    .A(a),                      //对应A接口
    .B(b),                      //对应B接口
    .ALUC(aluc),                //ALUC四位操作指令
    .alu_data_out(alu_data_out),//输出数据
    .zero(zero),                //ZF标志位，BEQ/BNE使用
    .carry(carry),              //CF标志位，SLTI/SLTIU使用
    .negative(negative),        //NF(SF)标志位，SLT/SLTU使用
    .overflow(overflow)         //OF标志位，其实没有用到
    );

/* 实例化寄存器堆 */
regfile cpu_ref(                //寄存器堆RegFile，写入为同步，读取为异步
    .reg_clk(clk),              //时钟信号，下降沿有效
    .reg_ena(ena),              //使能信号端，上升沿有效
    .rst(rst),                  //复位信号，高电平有效（检测上升沿）
    .reg_w(reg_w),              //写信号，高电平时寄存器可写入，低电平不可写入
    .RdC(RdC),                  //Rd对应的寄存器的地址（写入端）
    .RtC(RtC),                  //Rt对应的寄存器的地址（输出端）
    .RsC(RsC),                  //Rs对应的寄存器的地址（输出端）
    .Rd_data_in(Rd_data_in),    //要向寄存器中写入的值（需拉高reg_w）
    .Rs_data_out(Rs_data_out),  //Rs对应的寄存器的输出值
    .Rt_data_out(Rt_data_out)   //Rt对应的寄存器的输出值
    );

/* 实例化PC寄存器 */
PC PC_inst(                     //指令地址寄存器
    .pc_clk(clk),               //PC寄存器的时钟信号，写入为同步（时钟下降沿有效），读取为异步
    .pc_ena(ena),               //使能端信号，高电平有效
    .rst(rst),                  //复位信号，高电平有效
    .pc_addr_in(pc_addr_in),    //本次输入PC寄存器的指令地址，也就是下一次要执行的指令
    .pc_addr_out(pc_addr_out)   //本次从PC寄存器中传出的指令地址，也就是当前需要执行的指令
    );

/* 实例化HI_LO寄存器 */
HI_LO HI_LO_inst(
    .HI_LO_clk(clk),            //时钟信号
    .HI_LO_ena(ena),            //使能信号
    .HI_LO_rst(rst),            //复位信号
    .HI_in(mux5_out),              //向HI输入的数
    .LO_in(mux6_out),              //向LO输入的数
    .HI_w(HI_w),                //使能信号，是否是向HI中写入数
    .LO_w(LO_w),                //使能信号，是否是向LO中写入数
    .HI_out(HI_out),            //从HI传出的数
    .LO_out(LO_out)             //从LO传出的数
    );

MUX MUX6_1(
    .chosen(mux6_1),        //8选1，用三位
    .line0(Rs_data_out),    //第一根线
    .line1(npc),            //第二根线
    .line2(add_out_61),     //第三根线
    .line3(32'h00000004),   //第四根线
    .line4(epc_out),        //第五根线
    .line5(cat_out),        //第六根线
    .line6(32'bz),          //第七根线
    .line7(32'bz),          //第八根线
    .MUX_out(mux6_1_out)    //选择的线
    );

MUX MUX7_1(
    .chosen(mux7_1),        //8选1，用三位
    .line0(dm_data),        //第一根线
    .line1(mux7_out),       //第二根线
    .line2(CLZ_out),        //第三根线
    .line3(mux8_out),       //第四根线
    .line4(MUL_LO),         //第五根线
    .line5(add_out_71),     //第六根线
    .line6(cp0_out),          //第七根线
    .line7(32'bz),          //第八根线
    .MUX_out(mux7_1_out)    //选择的线
    );

DIV DIV_inst(
    .sign_flag(sign_flag),  //是否是有符号除法
    .A(DIV_A),              //输入的被除数
    .B(DIV_B),              //输入的除数
    .R(DIV_R),              //余数
    .Q(DIV_Q)               //商
    );

MUL MUL_inst(
    .sign_flag(sign_flag),  //是否是有符号乘法
    .A(MUL_A),              //输入的乘数A
    .B(MUL_B),              //输入的乘数B
    .HI(MUL_HI),            //高32位结果
    .LO(MUL_LO)             //低32位结果
    );

CP0 CP0_inst(
    .cp0_clk(clk),          //CP0的时钟信号
    .cp0_rst(rst),          //CP0寄存器复位信号
    .cp0_ena(ena),          //CP0的使能信号
    .MFC0(op_flags[MFC0]),   //此时CP0要执行的指令是否为MFC0
    .MTC0(op_flags[MTC0]),   //此时CP0要执行的指令是否为MTC0
    .ERET(op_flags[ERET]),   //此时CP0要执行的指令是否为ERET
    .PC(pc_addr_out),       //要写入CP0的PC地址
    .addr(mux1_out),        //要写入的寄存器地址
    .cause(cause),          //当前中断类型
    .data_in(Rt_data_out),  //从GR中传入的数据，用于写入CP0
    .CP0_out(cp0_out),      //CP0输出的数据
    .EPC_out(epc_out)       //CP0送出的PC地址，用于更新PC
    );

CLZ CLZ_inst(
    .CLZ_in(Rs_data_out),    //要计算前导0的数值
    .CLZ_out(CLZ_out)        //输出前导0的个数
    );

endmodule

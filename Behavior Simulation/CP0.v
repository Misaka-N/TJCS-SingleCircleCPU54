`timescale 1ns / 1ps

module CP0(
    input cp0_clk,          //CP0的时钟信号
    input cp0_rst,          //CP0寄存器复位信号
    input cp0_ena,          //CP0的使能信号
    input MFC0,             //此时CP0要执行的指令是否为MFC0
    input MTC0,             //此时CP0要执行的指令是否为MTC0
    input ERET,             //此时CP0要执行的指令是否为ERET
    input [31:0] PC,        //要写入CP0的PC地址
    input [31:0] addr,      //要写入的寄存器地址
    input [4:0] cause,      //当前中断类型
    input [31:0] data_in,   //从GR中传入的数据，用于写入CP0
    output [31:0] CP0_out,  //CP0输出的数据
    output [31:0] EPC_out   //CP0送出的PC地址，用于更新PC
    );
       
/* 用到的三种CAUSE的编码 */
parameter SYSCALL = 5'b01000,   //SYSCALL
          BREAK   = 5'b01001,   //BREAK
          TEQ     = 5'b01101;   //TEQ
    
/* 三个用到的寄存器 */
parameter STATUS = 4'd12,       //STATUS寄存器，存储全局状态
          CAUSE  = 4'd13,       //CAUSE寄存器，存储中断类型
          EPC    = 4'd14;       //EPC寄存器，存储中断时PC指令

reg [31:0] cp0_reg [31:0];      //声明CP0处理器的内部寄存器堆
          
/* 读取所需的内容都是异步读，不用时钟沿 */
assign EPC_out = ERET && cp0_ena? cp0_reg [EPC] : 32'hz;
assign CP0_out = MFC0 && cp0_ena? cp0_reg [addr[4:0]] : 32'hz; 

always @(negedge cp0_clk or posedge cp0_rst)
begin
    if(cp0_rst && cp0_ena)
    begin 
        cp0_reg [0] <=0 ;
        cp0_reg [1] <=0 ;
        cp0_reg [2] <=0 ;
        cp0_reg [3] <=0 ;
        cp0_reg [4] <=0 ;
        cp0_reg [5] <=0 ;
        cp0_reg [6] <=0 ;
        cp0_reg [7] <=0 ;
        cp0_reg [8] <=0 ;
        cp0_reg [9] <=0 ;
        cp0_reg [10] <=0 ;
        cp0_reg [11] <=0 ;
        cp0_reg [12] <=0 ;
        cp0_reg [13] <=0 ;
        cp0_reg [14] <=0 ;
        cp0_reg [15] <=0 ;
        cp0_reg [16] <=0 ;
        cp0_reg [17] <=0 ;
        cp0_reg [18] <=0 ;
        cp0_reg [19] <=0 ;
        cp0_reg [20] <=0 ;
        cp0_reg [21] <=0 ;
        cp0_reg [22] <=0 ;
        cp0_reg [23] <=0 ;
        cp0_reg [24] <=0 ;
        cp0_reg [25] <=0 ;
        cp0_reg [26] <=0 ;
        cp0_reg [27] <=0 ;
        cp0_reg [28] <=0 ;
        cp0_reg [29] <=0 ;
        cp0_reg [30] <=0 ;
        cp0_reg [31] <=0 ;        
    end
    else if(cp0_ena)
    begin
        if(MTC0)    //当前指令时MTC0，直接将对应的数据写入指定寄存器中
            cp0_reg [addr[4:0]] <= data_in;
        else if (cause == SYSCALL || cause == BREAK || cause == TEQ)   //三种进入中断的指令
        begin
            cp0_reg [STATUS] <= cp0_reg [STATUS] << 5;  //更新STATUS寄存器内容
            cp0_reg [CAUSE]  <= {24'b0 , cause , 2'b0}; //我们只用到了CAUSE中的[6:2]位，只更新这些就可以，其他不用管（置0）
            cp0_reg [EPC]    <= PC;                     //存储中断时的PC地址
        end
        else if(ERET) //出中断指令
            cp0_reg [STATUS] <= cp0_reg [STATUS] >> 5;  //更新STATUS寄存器内容
    end
end 
endmodule
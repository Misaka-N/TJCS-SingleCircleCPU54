`timescale 1ns / 1ps
module CLZ(
    input [31:0] CLZ_in,    //要计算前导0的数值
    output [31:0] CLZ_out   //输出前导0的个数
    );

reg [31:0] cnt = 32'd0;     //前导0的数量

always @(*) begin           //一种朴素的方法，讨论1第一次出现的位置来判断前导0的数量
    if (CLZ_in[31] == 1'b1)                          cnt<=0;
    else if(CLZ_in[30] == 1'b1 && CLZ_in[31] == 0)   cnt<=1;
    else if(CLZ_in[29] == 1'b1 && CLZ_in[31:30] == 0)cnt<=2;
    else if(CLZ_in[28] == 1'b1 && CLZ_in[31:29] == 0)cnt<=3;
    else if(CLZ_in[27] == 1'b1 && CLZ_in[31:28] == 0)cnt<=4;
    else if(CLZ_in[26] == 1'b1 && CLZ_in[31:27] == 0)cnt<=5;
    else if(CLZ_in[25] == 1'b1 && CLZ_in[31:26] == 0)cnt<=6;
    else if(CLZ_in[24] == 1'b1 && CLZ_in[31:25] == 0)cnt<=7;
    else if(CLZ_in[23] == 1'b1 && CLZ_in[31:24] == 0)cnt<=8;
    else if(CLZ_in[22] == 1'b1 && CLZ_in[31:23] == 0)cnt<=9;
    else if(CLZ_in[21] == 1'b1 && CLZ_in[31:22] == 0)cnt<=10;
    else if(CLZ_in[20] == 1'b1 && CLZ_in[31:21] == 0)cnt<=11;
    else if(CLZ_in[19] == 1'b1 && CLZ_in[31:20] == 0)cnt<=12;
    else if(CLZ_in[18] == 1'b1 && CLZ_in[31:19] == 0)cnt<=13;
    else if(CLZ_in[17] == 1'b1 && CLZ_in[31:18] == 0)cnt<=14;
    else if(CLZ_in[16] == 1'b1 && CLZ_in[31:17] == 0)cnt<=15;
    else if(CLZ_in[15] == 1'b1 && CLZ_in[31:16] == 0)cnt<=16;
    else if(CLZ_in[14] == 1'b1 && CLZ_in[31:15] == 0)cnt<=17;
    else if(CLZ_in[13] == 1'b1 && CLZ_in[31:14] == 0)cnt<=18;
    else if(CLZ_in[12] == 1'b1 && CLZ_in[31:13] == 0)cnt<=19;
    else if(CLZ_in[11] == 1'b1 && CLZ_in[31:12] == 0)cnt<=20;
    else if(CLZ_in[10] == 1'b1 && CLZ_in[31:11] == 0)cnt<=21;
    else if(CLZ_in[ 9] == 1'b1 && CLZ_in[31:10] == 0)cnt<=22;
    else if(CLZ_in[ 8] == 1'b1 && CLZ_in[31: 9] == 0)cnt<=23;
    else if(CLZ_in[ 7] == 1'b1 && CLZ_in[31: 8] == 0)cnt<=24;
    else if(CLZ_in[ 6] == 1'b1 && CLZ_in[31: 7] == 0)cnt<=25;
    else if(CLZ_in[ 5] == 1'b1 && CLZ_in[31: 6] == 0)cnt<=26;
    else if(CLZ_in[ 4] == 1'b1 && CLZ_in[31: 5] == 0)cnt<=27;
    else if(CLZ_in[ 3] == 1'b1 && CLZ_in[31: 4] == 0)cnt<=28;
    else if(CLZ_in[ 2] == 1'b1 && CLZ_in[31: 3] == 0)cnt<=29;
    else if(CLZ_in[ 1] == 1'b1 && CLZ_in[31: 2] == 0)cnt<=30;
    else if(CLZ_in[ 0] == 1'b1 && CLZ_in[31: 1] == 0)cnt<=31;
    else if(CLZ_in == 0)                             cnt<=32;
end

assign CLZ_out = cnt;

endmodule

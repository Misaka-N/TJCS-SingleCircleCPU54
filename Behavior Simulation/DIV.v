`timescale 1ns / 1ps
module DIV(
    input sign_flag,    //是否是有符号除法
    input [31:0] A,     //输入的被除数
    input [31:0] B,     //输入的除数
    output [31:0] R,    //余数
    output [31:0] Q     //商
    );

/* 内部用变量 */
wire signed [31:0] signed_A;  //有符号被除数
wire signed [31:0] signed_B;  //有符号除数

assign signed_A = A;
assign signed_B = B;

assign R =  (B == 32'd0) ? 32'd0 : (sign_flag ? (signed_A % signed_B) : (A % B));
assign Q =  (B == 32'd0) ? 32'd0 : (sign_flag ? (signed_A / signed_B) : (A / B));
endmodule

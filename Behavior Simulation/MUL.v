`timescale 1ns / 1ps
module MUL(
    input sign_flag,    //是否是有符号乘法
    input [31:0] A,     //输入的乘数A
    input [31:0] B,     //输入的乘数B
    output [31:0] HI,   //高32位结果
    output [31:0] LO    //低32位结果
    );

/* 内部用变量 */
wire [63:0] result;                 //结果统一存储在result中
wire [63:0] unsigned_result;        //保存无符号乘法结果
wire signed [63:0] signed_result;   //保存有符号乘法结果
wire [63:0] unsigned_A;             //扩展的无符号A
wire [63:0] unsigned_B;             //扩展的无符号B
wire signed [63:0] signed_A;        //扩展的有符号A
wire signed [63:0] signed_B;        //扩展的有符号B

assign unsigned_A = { 32'd0, A };
assign unsigned_B = { 32'd0, B };
assign unsigned_result = unsigned_A * unsigned_B;

assign signed_A = { {32{A[31]}} , A };
assign signed_B = { {32{B[31]}} , B };
assign signed_result = signed_A * signed_B;

assign result = sign_flag ? signed_result : unsigned_result;

assign HI = result[63:32];
assign LO = result[31:0];
endmodule

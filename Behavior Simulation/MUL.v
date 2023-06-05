`timescale 1ns / 1ps
module MUL(
    input sign_flag,    //�Ƿ����з��ų˷�
    input [31:0] A,     //����ĳ���A
    input [31:0] B,     //����ĳ���B
    output [31:0] HI,   //��32λ���
    output [31:0] LO    //��32λ���
    );

/* �ڲ��ñ��� */
wire [63:0] unsigned_result;        //�����޷��ų˷����
wire signed [63:0] signed_result;   //�����з��ų˷����
wire [63:0] unsigned_A;             //��չ���޷���A
wire [63:0] unsigned_B;             //��չ���޷���B
wire signed [63:0] signed_A;        //��չ���з���A
wire signed [63:0] signed_B;        //��չ���з���B

assign unsigned_A = { 32'd0, A };
assign unsigned_B = { 32'd0, B };
assign signed_A = { {32{A[31]}} , A };
assign signed_B = { {32{B[31]}} , B };

assign unsigned_result = unsigned_A * unsigned_B;
assign signed_result = signed_A * signed_B;

assign HI = sign_flag ? signed_result[63:32] : unsigned_result[63:32];
assign LO = sign_flag ? signed_result[31:0] : unsigned_result[31:0];
endmodule

`timescale 1ns / 1ps
module IMEM(
    input [10:0] im_addr_in,     //11λָ�����ַ����IMEM�ж�ָ��
    output [31:0] im_instr_out   //32λָ����
    ); 

dist_mem_gen_0 imem(    //ʵ����IP�ˣ�����ָ�����ַ���ض�Ӧ��ָ��
    .a(im_addr_in),     //�ӿں�IMEMģ���Ӧ
    .spo(im_instr_out)
    );
endmodule

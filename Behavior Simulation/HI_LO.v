`timescale 1ns / 1ps
module HI_LO(
    input HI_LO_clk,        //ʱ���ź�
    input HI_LO_ena,        //ʹ���ź�
    input HI_LO_rst,        //��λ�ź�
    input [31:0] HI_in,     //��HI�������
    input [31:0] LO_in,     //��LO�������
    input HI_w,             //ʹ���źţ��Ƿ�����HI��д����
    input LO_w,             //ʹ���źţ��Ƿ�����LO��д����
    output [31:0] HI_out,   //��HI��������
    output [31:0] LO_out    //��LO��������
    );

reg [31:0] HI = 32'd0;      //�洢��32λ��
reg [31:0] LO = 32'd0;      //�洢��32λ��

assign HI_out = HI_LO_ena ? HI : 32'bz;
assign LO_out = HI_LO_ena ? LO : 32'bz;

always @(posedge HI_LO_rst or negedge HI_LO_clk) begin 
    if (HI_LO_ena && HI_LO_rst) begin
        HI <= 32'd0;
        LO <= 32'd0;
    end
    else if(HI_LO_ena)
    begin
        if(HI_w)
            HI <= HI_in;
        if(LO_w)
            LO <= LO_in;
    end
end

endmodule

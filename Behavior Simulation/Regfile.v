`timescale 1ns / 1ps
module regfile(                 //�Ĵ�����RegFile��д��Ϊͬ������ȡΪ�첽
    input  reg_clk,             //ʱ���źţ��½�����Ч
    input  reg_ena,             //ʹ���źŶˣ���������Ч
    input  rst,                 //��λ�źţ��ߵ�ƽ��Ч����������أ�
    input  reg_w,               //д�źţ��ߵ�ƽʱ�Ĵ�����д�룬�͵�ƽ����д��
    input  [4:0] RdC,           //Rd��Ӧ�ļĴ����ĵ�ַ��д��ˣ�
    input  [4:0] RtC,           //Rt��Ӧ�ļĴ����ĵ�ַ������ˣ�
    input  [4:0] RsC,           //Rs��Ӧ�ļĴ����ĵ�ַ������ˣ�
    input  [31:0] Rd_data_in,   //Ҫ��Ĵ�����д���ֵ��������reg_w��
    output [31:0] Rs_data_out,  //Rs��Ӧ�ļĴ��������ֵ
    output [31:0] Rt_data_out   //Rt��Ӧ�ļĴ��������ֵ
    );
/* �ڲ��ñ��� */
reg [31:0] array_reg [31:0];    //����Ĵ�����

/* ��ֵ���첽��ȡ */
assign Rs_data_out = reg_ena ? array_reg[RsC] : 32'bz;
assign Rt_data_out = reg_ena ? array_reg[RtC] : 32'bz;  //ֻҪʹ�ܶ�Ϊ�ߵ�ƽ�����üĴ����ѣ�����ʱ���Զ�ȡ����

/* �����������첽д������� */
always @(negedge reg_clk or posedge rst)  //��λ�ź������ػ�ʱ���½�����Ч
begin
    if(rst && reg_ena)    //��λ�źŸߵ�ƽ����λ��ȫ����0������������д������ena����ֻ�����üĴ����Ѻ������գ����Ӵ�����ʱ���ԣ�Ϊ�����ݰ�ȫ���ǣ��������ǰ�ߣ���ֹ�Ĵ������ݱ���������գ�
    begin
        array_reg[0]  <= 32'h0;
        array_reg[1]  <= 32'h0;
        array_reg[2]  <= 32'h0;
        array_reg[3]  <= 32'h0;
        array_reg[4]  <= 32'h0;
        array_reg[5]  <= 32'h0;
        array_reg[6]  <= 32'h0;
        array_reg[7]  <= 32'h0;
        array_reg[8]  <= 32'h0;
        array_reg[9]  <= 32'h0;
        array_reg[10] <= 32'h0;
        array_reg[11] <= 32'h0;
        array_reg[12] <= 32'h0;
        array_reg[13] <= 32'h0;
        array_reg[14] <= 32'h0;
        array_reg[15] <= 32'h0;
        array_reg[16] <= 32'h0;
        array_reg[17] <= 32'h0;
        array_reg[18] <= 32'h0;
        array_reg[19] <= 32'h0;
        array_reg[20] <= 32'h0;
        array_reg[21] <= 32'h0;
        array_reg[22] <= 32'h0;
        array_reg[23] <= 32'h0;
        array_reg[24] <= 32'h0;
        array_reg[25] <= 32'h0;
        array_reg[26] <= 32'h0;
        array_reg[27] <= 32'h0;
        array_reg[28] <= 32'h0;
        array_reg[29] <= 32'h0;
        array_reg[30] <= 32'h0;
        array_reg[31] <= 32'h0;
    end
    else if(reg_ena && reg_w && (RdC != 5'h0)) //reg_ena��reg_w��Ϊ�ߵ�ƽ�����üĴ���������Ҫд���ݣ�����д���ر�ע�⣺0�żĴ�����0���������޸ģ�����д�뷶Χ֮�ڣ�
        array_reg[RdC] <= Rd_data_in;
end

endmodule

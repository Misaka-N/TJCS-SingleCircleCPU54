`timescale 1ns / 1ps
module DMEM(                    //DMEM�������ܿ�������Ƴ��첽��ȡ���ݣ�ͬ��д�����ݵ���ʽ
    input dm_clk,               //DMEMʱ���źţ�ֻ��д����ʱʹ��
    input dm_ena,               //ʹ���źŶˣ��ߵ�ƽ��Ч����Чʱ���ܶ�ȡ/д������
    input dm_r,                 //read���źţ���ȡʱ����
    input dm_w,                 //writeд�źţ�д��ʱ����
    input sb_flag,              //��ǰд��ָ���Ƿ���SB����
    input sh_flag,              //��ǰд��ָ���Ƿ���SH����
    input sw_flag,              //��ǰд��ָ���Ƿ���SW����
    input lb_flag,              //��ǰ��ȡָ���Ƿ���LB����
    input lh_flag,              //��ǰ��ȡָ���Ƿ���LH����
    input lbu_flag,             //��ǰ��ȡָ���Ƿ���LBU����
    input lhu_flag,             //��ǰ��ȡָ���Ƿ���LHU����
    input lw_flag,              //��ǰ��ȡָ���Ƿ���LW����
    input [6:0] dm_addr,        //7λ��ַ��Ҫ��ȡ/д��ĵ�ַ
    input [31:0] dm_data_in,    //д��ʱҪд�������
    output [31:0] dm_data_out   //��ȡʱ��ȡ��������
    );

reg [31:0] dmem [31:0];//DMEM����

assign dm_data_out = (dm_ena && dm_r && !dm_w) ? 
                     (lb_flag ? { {24{dmem[dm_addr][7]}} , dmem[dm_addr][7:0] } : 
                     (lbu_flag ? { 24'h0 , dmem[dm_addr][7:0] } :
                     (lh_flag ? { {16{dmem[dm_addr >> 1][15]}} , dmem[dm_addr >> 1][15:0] } :
                     (lhu_flag ? { 16'h0 , dmem[dm_addr >> 1][15:0] } :
                     (lw_flag ? dmem[dm_addr >> 2]: 32'bz))))) : 32'bz;//������ʹ�ܶ˿�������ָ����Ч��дָ����Чʱ���Ž���Ӧ��ַ�������ͳ���������Ϊ���迹

always @(negedge dm_clk)//ʱ��������д������
begin
    if(dm_ena && dm_w &&!dm_r)//������ʹ�ܶ˿�����дָ����Ч�Ҷ�ָ����Чʱ������Ĵ�����д������
    begin
        if(sb_flag)         //�����SBָ�����Ҫ�Ե�ַ��������
            dmem[dm_addr][7:0] <= dm_data_in[7:0];
        else if(sh_flag)    //�����SHָ���Ҫ�Ե�ַ���Զ�
            dmem[dm_addr >> 1][15:0] <= dm_data_in[15:0];
        else if(sw_flag)    //ʣ�µľ���SWָ���Ҫ�Ե�ַ������
            dmem[dm_addr >> 2] <= dm_data_in;
    end
end
//������߶�û����/ͬʱ���ߣ�������ʲô����������ֹ������д�ֶ��ĳ�ͻ���
endmodule

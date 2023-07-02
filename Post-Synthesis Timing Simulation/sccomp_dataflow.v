`timescale 1ns / 1ps
module sccomp_dataflow(
    input clk_in,       //ʱ���ź�
    input reset,        //��λ�ź�
    output [7:0]  o_seg,//�������
    output [7:0]  o_sel //Ƭѡ�ź�
    );

/* CPU�� */
wire [31:0] pc_out;          //���ָ���ַ������IMEMҪȡ����
wire [31:0] dm_addr_temp;    //DMEM��ʱ��ַ����Ҫת��


/* IMEM�� */
wire [31:0] im_addr_in;     //11λָ�����ַ����IMEM�ж�ָ��
wire [31:0] im_instr_out;   //32λָ����

assign im_addr_in = pc_out - 32'h00400000;

/* DMEM�� */
wire dm_ena;                //�Ƿ���Ҫ����DMEM
wire dm_r, dm_w;            //��дָ��
wire [31:0] dm_addr;        //��Ҫ�õ���DMEM��ַ
wire [31:0] dm_data_out;    //DMEM��ȡʱ��ȡ��������
wire [31:0] dm_data_w;      //Ҫд��DMEM������ 
wire sb_flag;               //��ǰд��ָ���Ƿ���SB����
wire sh_flag;               //��ǰд��ָ���Ƿ���SH����
wire sw_flag;               //��ǰд��ָ���Ƿ���SW����
wire lb_flag;               //��ǰ��ȡָ���Ƿ���LB����
wire lh_flag;               //��ǰ��ȡָ���Ƿ���LH����
wire lbu_flag;              //��ǰ��ȡָ���Ƿ���LBU����
wire lhu_flag;              //��ǰ��ȡָ���Ƿ���LHU����
wire lw_flag;               //��ǰ��ȡָ���Ƿ���LW����

assign dm_addr = (dm_addr_temp -  32'h10010000)/4;

/* ����� */
assign pc = pc_out;
assign inst = im_instr_out;


/* IMEMָ��洢������ */
IMEM imem(
    .im_addr_in(im_addr_in[12:2]),  //11λָ�����ַ����IMEM�ж�ָ��
    .im_instr_out(im_instr_out)     //32λָ����
    );

/* DMEM���ݴ洢������ */
DMEM dmem(                          //DMEM�������ܿ�������Ƴ��첽��ȡ���ݣ�ͬ��д�����ݵ���ʽ
    .dm_clk(clk_cpu),                //DMEMʱ���źţ�ֻ��д����ʱʹ��
    .dm_ena(dm_ena),                //ʹ���źŶˣ��ߵ�ƽ��Ч����Чʱ���ܶ�ȡ/д������
    .dm_r(dm_r),                    //read���źţ���ȡʱ����
    .dm_w(dm_w),                    //writeд�źţ�д��ʱ����
    .sb_flag(sb_flag),              //��ǰд��ָ���Ƿ���SB����
    .sh_flag(sh_flag),              //��ǰд��ָ���Ƿ���SH����
    .sw_flag(sw_flag),              //��ǰд��ָ���Ƿ���SW����
    .lb_flag(lb_flag),              //��ǰ��ȡָ���Ƿ���LB����
    .lh_flag(lh_flag),              //��ǰ��ȡָ���Ƿ���LH����
    .lbu_flag(lbu_flag),            //��ǰ��ȡָ���Ƿ���LBU����
    .lhu_flag(lhu_flag),            //��ǰ��ȡָ���Ƿ���LHU����
    .lw_flag(lw_flag),              //��ǰ��ȡָ���Ƿ���LW����
    .dm_addr(dm_addr[6:0]),         //7λ��ַ��Ҫ��ȡ/д��ĵ�ַ
    .dm_data_in(dm_data_w),         //д��ʱҪд�������
    .dm_data_out(dm_data_out)       //��ȡʱ��ȡ��������
    );

/* CPU���� */
cpu sccpu(
    .clk(clk_cpu),                   //CPUִ��ʱ��
    .ena(1'b1),                     //ʹ���źŶ�
    .rst(reset),                    //��λ�ź�
    .instr_in(im_instr_out),        //��ǰҪִ�е�ָ��
    .dm_data(dm_data_out),          //��ȡ����DMEM�ľ�������
    .dm_ena(dm_ena),                //�Ƿ���Ҫ����DMEM
    .dm_w(dm_w),                    //�������DMEM���Ƿ�Ϊд��
    .dm_r(dm_r),                    //�������DMEM���Ƿ�Ϊ��ȡ
    .pc_out(pc_out),                //���ָ���ַ������IMEMҪȡ����
    .dm_addr(dm_addr_temp),         //��Ҫ�õ���DMEM��ַ
    .dm_data_w(dm_data_w),          //Ҫд��DMEM������ 
    .sb_flag(sb_flag),              //��ǰд��ָ���Ƿ���SB����
    .sh_flag(sh_flag),              //��ǰд��ָ���Ƿ���SH����
    .sw_flag(sw_flag),              //��ǰд��ָ���Ƿ���SW����
    .lb_flag(lb_flag),              //��ǰ��ȡָ���Ƿ���LB����
    .lh_flag(lh_flag),              //��ǰ��ȡָ���Ƿ���LH����
    .lbu_flag(lbu_flag),            //��ǰ��ȡָ���Ƿ���LBU����
    .lhu_flag(lhu_flag),            //��ǰ��ȡָ���Ƿ���LHU����
    .lw_flag(lw_flag)               //��ǰ��ȡָ���Ƿ���LW����
    );

seg7x16 seg7x16_inst(
    .clk(clk_in),
	.reset(reset),
	.cs(1'b1),
	.i_data(im_instr_out),
	.o_seg(o_seg),
	.o_sel(o_sel)
    );

Divider Divider_inst(
    .clk(clk_in),                   //ϵͳʱ��
    .rst_n(~reset),                 //��λ�ź�
    .clk_out(clk_cpu)               //�������CPU��ʱ��
    );

endmodule
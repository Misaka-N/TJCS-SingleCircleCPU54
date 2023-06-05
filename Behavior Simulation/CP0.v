`timescale 1ns / 1ps

module CP0(
    input cp0_clk,          //CP0��ʱ���ź�
    input cp0_rst,          //CP0�Ĵ�����λ�ź�
    input cp0_ena,          //CP0��ʹ���ź�
    input MFC0,             //��ʱCP0Ҫִ�е�ָ���Ƿ�ΪMFC0
    input MTC0,             //��ʱCP0Ҫִ�е�ָ���Ƿ�ΪMTC0
    input ERET,             //��ʱCP0Ҫִ�е�ָ���Ƿ�ΪERET
    input [31:0] PC,        //Ҫд��CP0��PC��ַ
    input [31:0] addr,      //Ҫд��ļĴ�����ַ
    input [4:0] cause,      //��ǰ�ж�����
    input [31:0] data_in,   //��GR�д�������ݣ�����д��CP0
    output [31:0] CP0_out,  //CP0���������
    output [31:0] EPC_out   //CP0�ͳ���PC��ַ�����ڸ���PC
    );
       
/* �õ�������CAUSE�ı��� */
parameter SYSCALL = 5'b01000,   //SYSCALL
          BREAK   = 5'b01001,   //BREAK
          TEQ     = 5'b01101;   //TEQ
    
/* �����õ��ļĴ��� */
parameter STATUS = 4'd12,       //STATUS�Ĵ������洢ȫ��״̬
          CAUSE  = 4'd13,       //CAUSE�Ĵ������洢�ж�����
          EPC    = 4'd14;       //EPC�Ĵ������洢�ж�ʱPCָ��

reg [31:0] cp0_reg [31:0];      //����CP0���������ڲ��Ĵ�����
          
/* ��ȡ��������ݶ����첽��������ʱ���� */
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
        if(MTC0)    //��ǰָ��ʱMTC0��ֱ�ӽ���Ӧ������д��ָ���Ĵ�����
            cp0_reg [addr[4:0]] <= data_in;
        else if (cause == SYSCALL || cause == BREAK || cause == TEQ)   //���ֽ����жϵ�ָ��
        begin
            cp0_reg [STATUS] <= cp0_reg [STATUS] << 5;  //����STATUS�Ĵ�������
            cp0_reg [CAUSE]  <= {24'b0 , cause , 2'b0}; //����ֻ�õ���CAUSE�е�[6:2]λ��ֻ������Щ�Ϳ��ԣ��������ùܣ���0��
            cp0_reg [EPC]    <= PC;                     //�洢�ж�ʱ��PC��ַ
        end
        else if(ERET) //���ж�ָ��
            cp0_reg [STATUS] <= cp0_reg [STATUS] >> 5;  //����STATUS�Ĵ�������
    end
end 
endmodule
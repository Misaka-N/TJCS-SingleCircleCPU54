`timescale 1ns / 1ps
module MUX(
    input [2:0] chosen,     //8选1，用三位
    input [31:0] line0,     //第一根线
    input [31:0] line1,     //第二根线
    input [31:0] line2,     //第三根线
    input [31:0] line3,     //第四根线
    input [31:0] line4,     //第五根线
    input [31:0] line5,     //第六根线
    input [31:0] line6,     //第七根线
    input [31:0] line7,     //第八根线
    output [31:0] MUX_out   //选择的线
    );

assign MUX_out = (chosen == 3'b000 ? line0 :
                 (chosen == 3'b001 ? line1 :
                 (chosen == 3'b010 ? line2 : 
                 (chosen == 3'b011 ? line3 : 
                 (chosen == 3'b100 ? line4 : 
                 (chosen == 3'b101 ? line5 :
                 (chosen == 3'b110 ? line6 :
                 (chosen == 3'b111 ? line7 : 32'bz))))))));

endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/07 15:22:20
// Design Name: 
// Module Name: hazard
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module hazard(
    //Fetch stage
    output stallF,
    
    //decode stage
    input [4:0] rsD, rtD,
    input branchD,
    output forwardAD, forwardBD,
    output stallD,

    //excute stage
    input [4:0] rsE, rtE,
    input [4:0] writeRegE,
    input regWriteE,
    input memToRegE,
    input stall_divE,
    output [1:0] forwardAE, forwardBE, forwardHiloE,
    output flushE, stallE,

    //mem stage
    input [4:0] writeRegM,
    input regWriteM,
    input memToRegM,
    input hilo_weM,

    //write back stage
    input [4:0] writeRegW,
    input regWriteW,
    input hilo_weW
    );
    
    //����ð�� R��ָ�ǰ��
    assign forwardAE = ((rsE!=0) && (rsE==writeRegM) && regWriteM) ? 2'b10 : 
                        ((rsE!=0) && (rsE==writeRegW) && regWriteW) ? 2'b01:
                        2'b00;
                    
    assign forwardBE = ((rtE!=0) && (rtE==writeRegM) && regWriteM) ? 2'b10 : 
                        ((rtE!=0) && (rtE==writeRegW) && regWriteW) ? 2'b01:
                        2'b00;
    
    // hilo�Ĵ������µ�����ð��
    assign forwardHiloE = hilo_weM ? 2'b10 : (hilo_weW ? 2'b01 : 2'b00);

    //����ð�� loadָ��ģ�ǰ�Ʋ�������һ����
    wire lwStall;
    assign lwStall = ((rsD==rtE) || (rtD==rtE)) && memToRegE;
    
    //�ṹð�� beqָ��, ǰ������һ���ڲ���ˢ��
    assign forwardAD = (rsD!=0) && (rsD==writeRegM) && regWriteM;
    assign forwardBD = (rtD!=0) && (rtD==writeRegM) && regWriteM;

    //beqǰһ��ָ��ΪALUָ�������loadָ��
    wire branchStall;
    assign branchStall = (branchD && regWriteE && (writeRegE==rsD || writeRegE==rtD))
                        | (branchD && memToRegM && (writeRegM==rsD || writeRegM==rtD));
    
    // control output
    assign stallD = (lwStall | branchStall) | stall_divE;
    assign stallF = stallD;
    assign stallE = stall_divE;
    assign flushE = (lwStall | branchStall);
endmodule


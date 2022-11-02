/*
   CS/ECE 552 Spring '20
  
   Filename        : decode.v
   Description     : This is the module for the overall decode stage of the processor.
*/
module decode(instr, writeData, regDst, regWrite, pc, zeroExt, memWrite, i1Fmt, clk, rst,
                    jumpAddr, readData1, readData2, immVal, err);
   
    // TODO: Your code here
    input [15:0] instr; 
    input regWrite;           
    input regDst;             
    input [15:0] writeData;   
    input [15:0] pc;
    input zeroExt;
    input memWrite;
    input i1Fmt;
    input clk, rst;

    output err;
    output [15:0] jumpAddr;  
    output [15:0] readData1;
    output [15:0] readData2;
    output [15:0] immVal;

    wire [15:0] immI2, immI1, temp_immediate, zero_imm1, zero_imm2, temp_zero_imm;
    wire [2:0] write_reg, write_reg_temp;
    wire [2:0] readReg1, readReg2, write1_reg;                       
    wire [15:0] readData1_temp, readData2_temp;
    wire [2:0] stuReg, write_regtemp, write_regtemp2;
    wire [4:0] opcode;
    wire isStu;
    wire jalInstr, jalrInstr, jmpLnk;
    wire [15:0]writeDataFinal;

    /*
    Formats:
    J-format: 
        15..11. 10..0.
        5 bits [opc]. 11 bits [displc]
    I-format 1: 
        15..11. 10..8.  7..5.  4..0.
        5 [opc]. 3 [Rs]. 3 [Rd]. 5 [Imm]
    I-format 2: 
        15..11. 10..8.  7..0.
        5 [opc]. 3 [Rs]. 8 [Imm]
    R-format: 
        15..11. 10..8.  7..5.   4..2.    1..0.
        5 [opc]. 3 [Rs]. 3 [Rt]. 3 [Rd]. 2 [Ext]
    */

    assign opcode = instr[15:11];
    assign readReg1 = instr[10:8];
    assign readReg2 = instr[7:5];
    assign write1_reg = instr[4:2];
    
    assign stuReg = readReg1;
    equal #(.INPUT_WIDTH(5)) EQ1(.in1(opcode), .in2(5'b10011), .eq(isStu));
    

    equal #(.INPUT_WIDTH(5)) EQ2(.in1(opcode), .in2(5'b00110), .eq(jalInstr));
    equal #(.INPUT_WIDTH(5)) EQ3(.in1(opcode), .in2(5'b00111), .eq(jalrInstr));
    assign jmpLnk = jalInstr | jalrInstr;
    
    assign write_reg_temp = (regDst == 1'b0) ? readReg1 : write1_reg;  // I-format2 or R-format writeReg
    assign write_regtemp = (i1Fmt) ? readReg2 : write_reg_temp;         // If I-format1 writeReg
    assign write_regtemp2 = (isStu) ? stuReg : write_regtemp;          // If STU writeReg
    assign write_reg = (jmpLnk) ? 3'b111 : write_regtemp2; 
    assign writeDataFinal = (jmpLnk) ? pc : writeData;
    
    regFile regFile0(.read1Data(readData1_temp), .read2Data(readData2_temp), .err(err),
            .clk(clk), .rst(rst), .read1RegSel(readReg2), .read2RegSel(readReg1), 
            .writeRegSel(write_reg), .writedata(writeDataFinal), .writeEn(regWrite));
    
    mux2_1_16b MEM1(.InB(readData2_temp), .InA(readData1_temp), .S(memWrite), .Out(readData1));
    mux2_1_16b MEM2(.InB(readData1_temp), .InA(readData2_temp), .S(memWrite), .Out(readData2));
    
    wire jr;
    wire [15:0] jumpAddr1, jumpAddr2;
    
    sign_ext_11b SJUMP(.in(instr[10:0]), .out(jumpAddr1));
    sign_ext_8b SJUMP8(.in(instr[7:0]), .out(jumpAddr2));
    
    assign jr = (~instr[15]) & (~instr[14]) & instr[13] & (~instr[12]) & instr[11];
    mux2_1_16b JADDR(.InB(jumpAddr2), .InA(jumpAddr1), .S(jr|jalrInstr), .Out(jumpAddr));
    
    sign_ext_8b EXT8 (.in(instr[7:0]), .out(immI2));
    sign_ext_5b EXT5   (.in(instr[4:0]), .out(immI1));
    zero_extend8bit Z8EXT(.in(instr[7:0]), .out(zero_imm1));
    zero_extend5bit Z5EXT(.in(instr[4:0]), .out(zero_imm2));

    mux2_1_16b  IMM(.InA(immI2), .InB(immI1), .S(i1Fmt), .Out(temp_immediate));
    mux2_1_16b Z5IM(.InA(zero_imm1), .InB(zero_imm2), .S(i1Fmt), .Out(temp_zero_imm));
    mux2_1_16b ZIMM(.InA(temp_immediate), .InB(temp_zero_imm), .S(zeroExt), .Out(immVal));
endmodule


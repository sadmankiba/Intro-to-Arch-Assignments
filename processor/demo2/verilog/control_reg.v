module control_reg(instruction, Rs, Rt, Rd, RsValid, RtValid, writeRegValid);
  
  input [15:0] instruction;
   
  //Register Identifiers for data hazards
  output reg [2:0] Rs, Rt, Rd;
  output reg RsValid, RtValid, writeRegValid;
  
  always @(instruction)
  begin
    //Defaults
    Rs = 3'b000;
    RsValid = 1'b0;
    Rt = 3'b000;
    RtValid = 1'b0;
    writeRegValid = 1'b0;
    casex(instruction[15:11])
      5'b0_00xx: //HALT, NOP, SIIC, NOP/RTI
        begin
        end
      
      5'b0_10xx: //ADDI, SUBI, XORI, ANDNI
        begin
          Rs = instruction[10:8];
          RsValid = 1'b1;
           
          writeRegValid = 1'b1;
        end

      5'b1_01xx: //ROLI, SLLI, RORI, SRLI
        begin
          Rs = instruction[10:8];
          RsValid = 1'b1;
          
          writeRegValid = 1'b1;
        end

      5'b1_101x: //ADD, SUB, XOR, ANDN, ROL, SLL, ROR, SRL
        begin
          Rs = instruction[10:8];
          RsValid = 1'b1;
          Rt = instruction[7:5];
          RtValid = 1'b1;
          Rd = instruction[4:2];
          writeRegValid = 1'b1;
        end
  
      5'b1_11xx: //SEQ, SLT, SLE, SCO
        begin
          Rs = instruction[10:8];
          RsValid = 1'b1;
          Rt = instruction[7:5];
          RtValid = 1'b1;
          Rd = instruction[4:2];
          writeRegValid = 1'b1;
        end

      5'b1_1001: // BTR
        begin
          Rs = instruction[10:8];
          Rd = instruction[4:2];
          RsValid = 1'b1;
          writeRegValid = 1'b1;
        end

      5'b0_1100: //BEQZ, BNEZ, BLTZ, BGEZ
        begin
          Rs = instruction[10:8];
          RsValid = 1'b1;
        end
      
      5'b1_1000: //LBI
        begin
          //Rs = instruction[10:8];
          //RsValid = 1'b1;
          Rd = instruction[10:8];
          writeRegValid = 1'b1;
        end
  
      5'b1_0010: //SLBI
        begin
          Rs = instruction[10:8];
          RsValid = 1'b1;
          Rd = instruction[10:8];
          writeRegValid = 1'b1;
        end

      5'b1_0000: //ST, LD
        begin
          Rs = instruction[10:8];
          RsValid = 1'b1;
          Rt = instruction[7:5];
          RtValid = 1'b1;
          
          writeRegValid = 1'b1;
        end
      5'b1_0001: //ST, LD
        begin
          Rs = instruction[10:8];
          RsValid = 1'b1;
          Rt = instruction[7:5];
          RtValid = 1'b1;
          
          writeRegValid = 1'b1;
        end
      
      5'b1_0011: //STU
        begin
          Rs = instruction[10:8];
          RsValid = 1'b1;
          Rt = instruction[7:5];
          RtValid = 1'b1;
          Rd = instruction[10:8];
          writeRegValid = 1'b1;
        end

      5'b0_0100: //J
        begin
        end
      5'b0_0101: //JR
        begin
          Rs = instruction[10:8];
          RsValid = 1'b1;
        end
      5'b0_0110: //JAL
        begin
          Rd = 3'b111;
          writeRegValid = 1'b1;
          Rt = 3'b111;
          RtValid = 1'b1;
        end
      5'b0_0111: //JALR
        begin
          Rs = instruction[10:8];
          RsValid = 1'b1;
          Rd = 3'b111;
          writeRegValid = 1'b1;
          Rt = 3'b111;
          RtValid = 1'b1;
        end
      default:
        begin
          //do nothing? throw err?
        end
    endcase
  end
endmodule

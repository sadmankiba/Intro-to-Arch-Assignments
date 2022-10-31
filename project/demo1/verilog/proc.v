/* $Author: sinclair $ */
/* $LastChangedDate: 2020-02-09 17:03:45 -0600 (Sun, 09 Feb 2020) $ */
/* $Rev: 46 $ */
module proc (/*AUTOARG*/
    // Outputs
        err, 
    // Inputs
    clk, rst
    );

    input clk;
    input rst;

    output err;

    // None of the above lines can be modified

    // OR all the err ouputs for every sub-module and assign it as this
    // err output
    
    // As desribed in the homeworks, use the err signal to trap corner
    // cases that you think are illegal in your statemachines
    
    
    /* your code here -- should include instantiations of fetch, decode, execute, mem and wb modules */
    
    wire RegDst, Jump, Branch, MemRead, MemToReg, memWrite, ALU_Src, RegWrite; 
    wire [4:0] ALU_op;
    wire control_err, halt, i1Fmt, ZeroExtend, alu_ofl;
    
    control control0(.opcode(instruction[15:11]), .regDst(RegDst), .jump(Jump), 
                .branch(Branch), .memRead(MemRead), .memToReg(MemToReg), .halt(halt),
                .aluOp(ALU_op), .memWrite(memWrite), .aluSrc(ALU_Src), .regWrite(RegWrite), .err(control_err),
                    .i1Fmt(i1Fmt), .zeroExtend(ZeroExtend));

    wire [15:0] next_pc;
    wire [15:0] instruction;
    wire fetch_err;
    
    fetch fetch0(.pc(wb_pc), .clk(clk), .rst(rst), .next_pc(next_pc), .instr(instruction), .err(fetch_err));
    
    wire [15:0] jumpAddr;
    wire [15:0] read1data;
    wire [15:0] read2data;
    wire [15:0] immediate;
    wire decode_err;

    decode decode0(
                        .instruction(instruction), .RegWrite(RegWrite), .RegDst(RegDst), .writeData(wb_out),
                        .clk(clk), .rst(rst), .pc(next_pc[15:0]), .i1Fmt(i1Fmt), .ZeroExtend(ZeroExtend),
                        .memWrite(memWrite),
                        .jumpAddr(jumpAddr), .read1data(read1data), .read2data(read2data), .immediate(immediate),
                        .err(decode_err));  
    
    wire [15:0] ALU_result;
    wire zero, alu_err, ltz;
    wire [15:0] branch_result;
    wire [15:0] jump_out;

    alu_control actl0(//Inputs
                        .ALU_op(ALU_op), .ALU_funct(instruction[1:0]), 
                        //Outputs
                        .invA(invA), .invB(invB), .op_to_alu(op_to_alu), .cin(cin), .sign(sign), .passA(passA), .passB(passB));
    
    wire [2:0] op_to_alu;
    wire invA, invB, sign, cin, passA, passB;

    execute exec0 ( //Inputs
                        .alu_op(op_to_alu), .ALUSrc(ALU_Src), .read1data(read1data), .read2data(read2data), 
                        .immediate(immediate), .pc(next_pc), .invA(invA), .invB(invB), .cin(cin), .sign(sign),  
                        .passThroughA(passA), .passThroughB(passB), .instr_op(ALU_op), .memWrite(memWrite),
                        .jump_in(jumpAddr),
                        //Outputs
                        .ALU_result(ALU_result), .branch_result(branch_result), .zero(zero), .err(alu_err),
                        .ltz(ltz), .jump_out(jump_out));  
    
    wire [15:0] branch_or_pc;
    wire [15:0] data_mem_out;

    data_mem memory0(.memWrite(memWrite), .memRead(MemRead), .ALU_result(ALU_result), .writedata(read2data), 
                    .readData(data_mem_out), .zero(zero), .Branch(Branch), .branchAddr(branch_result), .pc(next_pc), 
                    .halt(halt), .ltz(ltz), .branch_op(ALU_op[1:0]), .branch_or_pc(branch_or_pc), .clk(clk), .rst(rst));  
    
    wire [15:0] wb_out; 
    wire [15:0] wb_pc;

    wb wb0 (.aluRes(ALU_result), .memData(data_mem_out), .memToReg(MemToReg), .brPcAddr(branch_or_pc), 
                    .jumpAddr(jump_out), .jump(Jump), .writeData(wb_out), .pc(wb_pc)); 
    
endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:

//Author --  Ashutosh Dwivedi (200214)

`timescale 1ns / 1ps
module iitk_mini_mips (
    input clk,
    input reset,

    // Instruction Memory Loader Interface
    input init_mode,
    input write_enable,
    input [11:0] init_address,
    input [31:0] init_instruction,

    output [31:0] pc_out,
    output [31:0] instruction_out,
    output [31:0] debug_result
);
    wire [31:0] pc, instruction;
    wire [5:0] opcode, funct;
    wire [4:0] rs, rt, rd, shamt;
    wire [15:0] imm;
    wire [25:0] addr;
    wire [4:0] alu_control;
    wire [31:0] reg_rs_val, reg_rt_val, alu_result;
    wire [63:0] hi_lo;
    wire [31:0] next_pc;
    wire take_branch;
    wire branch_taken;

    wire regDst, aluSrc, memToReg, regWrite;
    wire memRead, memWrite;
    wire branch, jump, is_jal, is_jr;
    wire [2:0] branchType;
    wire [31:0] mem_out;

    // Branch signal
    assign branch_taken = branch && take_branch;

    // Instruction Fetch
    instruction_fetch IF (
        .clk(clk),
        .reset(reset),
        .init_mode(init_mode),
        .write_enable(write_enable),
        .init_address(init_address),
        .init_instruction(init_instruction),
        .next_pc(next_pc),
        .branch_taken(branch_taken),
        .pc(pc),
        .instruction(instruction)
    );

    // Instruction Decode
    instruction_decode ID (
        .instruction(instruction),
        .opcode(opcode), .rs(rs), .rt(rt), .rd(rd),
        .shamt(shamt), .funct(funct),
        .immediate(imm), .address(addr)
    );

    // Control Unit
    control_unit CU (
        .opcode(opcode), .funct(funct),
        .regDst(regDst), .aluSrc(aluSrc), .memToReg(memToReg),
        .regWrite(regWrite), .memRead(memRead), .memWrite(memWrite),
        .branch(branch), .jump(jump), .is_jal(is_jal), .is_jr(is_jr),
        .branchType(branchType), .aluOp(alu_control)
    );

    // Register File
    regfile RF (
        .clk(clk), .rs(rs), .rt(rt), .rd(rd), .regWrite(regWrite),
        .write_data(memToReg ? mem_out : alu_result),
        .regDst(regDst),
        .rs_val(reg_rs_val), .rt_val(reg_rt_val)
    );

    // ALU
    alu ALU (
        .A(reg_rs_val),
        .B(aluSrc ? {{16{imm[15]}}, imm} : reg_rt_val),
        .shamt(shamt),
        .alu_control(alu_control),
        .hi_lo_in(64'd0),
        .hi_lo(hi_lo),
        .result(alu_result)
    );

    // Data Memory
    data_memory DMEM (
        .clk(clk),
        .memRead(memRead),
        .memWrite(memWrite),
        .address(alu_result),
        .writeData(reg_rt_val),
        .readData(mem_out)
    );

    // Branch Unit
    branch_unit BR (
        .pc_current(pc),
        .rs_val(reg_rs_val),
        .rt_val(reg_rt_val),
        .immediate(imm),
        .jump_address(addr),
        .branch_control(branchType),
        .is_jump(jump),
        .is_jal(is_jal),
        .is_jr(is_jr),
        .next_pc(next_pc),
        .take_branch(take_branch)
    );

    assign pc_out = pc;
    assign instruction_out = instruction;
    assign debug_result = alu_result;
endmodule
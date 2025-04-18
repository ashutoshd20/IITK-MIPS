`timescale 1ns / 1ps
module instruction_memory (
    input clk,
    input init_mode,                         // 1 = load via interface, 0 = run mode
    input [11:0] init_address,               // Address for writing during init
    input [31:0] init_instruction,           // Instruction to write
    input write_enable,                      
    input [31:0] address,                    // Address during execution
    output [31:0] instruction
);
    reg [31:0] memory [0:4095];
    always @(posedge clk) begin
        if (init_mode && write_enable)
            memory[init_address] <= init_instruction;
    end

    assign instruction = memory[(address - 32'h00400000) >> 2];
endmodule







`timescale 1ns / 1ps
module instruction_fetch (
    input clk,
    input reset,
    input init_mode,
    input write_enable,
    input [11:0] init_address,
    input [31:0] init_instruction,

    input [31:0] next_pc,
    input branch_taken,

    output reg [31:0] pc,
    output [31:0] instruction
);
    instruction_memory imem (
        .clk(clk),
        .init_mode(init_mode),
        .init_address(init_address),
        .init_instruction(init_instruction),
        .write_enable(write_enable),
        .address(pc),
        .instruction(instruction)
    );

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 32'h00400000;
        else if (!init_mode) begin
            if (branch_taken)
                pc <= next_pc;
            else
                pc <= pc + 4;
        end
    end
endmodule








`timescale 1ns / 1ps
module instruction_decode (
    input [31:0] instruction,
    output [5:0] opcode,
    output [4:0] rs,
    output [4:0] rt,
    output [4:0] rd,
    output [4:0] shamt,
    output [5:0] funct,
    output [15:0] immediate,
    output [25:0] address
);
    assign opcode    = instruction[31:26];
    assign rs        = instruction[25:21];
    assign rt        = instruction[20:16];
    assign rd        = instruction[15:11];
    assign shamt     = instruction[10:6];
    assign funct     = instruction[5:0];
    assign immediate = instruction[15:0];
    assign address   = instruction[25:0];
endmodule






`timescale 1ns / 1ps
module data_memory (
    input clk,
    input memRead,
    input memWrite,
    input [31:0] address,
    input [31:0] writeData,
    output reg [31:0] readData
);
    reg [31:0] memory [0:4095];  // 16 KB

    wire [11:0] word_addr = (address - 32'h10010000) >> 2;

    always @(posedge clk) begin
        if (memWrite)
            memory[word_addr] <= writeData;
    end

    always @(*) begin
        readData = memRead ? memory[word_addr] : 32'b0;
    end
endmodule







`timescale 1ns / 1ps
module control_unit (
    input [5:0] opcode,
    input [5:0] funct,
    output reg regDst, aluSrc, memToReg, regWrite,
    output reg memRead, memWrite, branch, jump,
    output reg is_jal, is_jr,
    output reg [2:0] branchType,
    output reg [4:0] aluOp
);

    always @(*) begin
        // Default values
        regDst = 0; aluSrc = 0; memToReg = 0; regWrite = 0;
        memRead = 0; memWrite = 0; branch = 0; jump = 0;
        is_jal = 0; is_jr = 0; aluOp = 0; branchType = 3'b000;

        case (opcode)
            6'b000000: begin // R-type
                regDst = 1;
                regWrite = 1;
                case (funct)
                    6'b100000: aluOp = 5'b00000; // add
                    6'b100010: aluOp = 5'b00001; // sub
                    6'b100001: aluOp = 5'b00010; // addu
                    6'b100011: aluOp = 5'b00011; // subu
                    6'b100100: aluOp = 5'b01000; // and
                    6'b100101: aluOp = 5'b01001; // or
                    6'b100110: aluOp = 5'b01010; // xor
                    6'b000000: aluOp = 5'b01100; // sll
                    6'b000010: aluOp = 5'b01101; // srl
                    6'b000011: aluOp = 5'b01110; // sra
                    6'b101010: aluOp = 5'b10000; // slt
                    6'b001000: begin              // jr
                        regWrite = 0;
                        is_jr = 1;
                    end
                endcase
            end

            // I-type
            6'b001000: begin aluOp = 5'b00000; aluSrc = 1; regWrite = 1; end // addi
            6'b001001: begin aluOp = 5'b00010; aluSrc = 1; regWrite = 1; end // addiu
            6'b001100: begin aluOp = 5'b01000; aluSrc = 1; regWrite = 1; end // andi
            6'b001101: begin aluOp = 5'b01001; aluSrc = 1; regWrite = 1; end // ori
            6'b001110: begin aluOp = 5'b01010; aluSrc = 1; regWrite = 1; end // xori
            6'b001111: begin aluOp = 5'b01111; aluSrc = 1; regWrite = 1; end // lui
            6'b100011: begin aluOp = 5'b00000; aluSrc = 1; memRead = 1; memToReg = 1; regWrite = 1; end // lw
            6'b101011: begin aluOp = 5'b00000; aluSrc = 1; memWrite = 1; end // sw
            6'b000100: begin branch = 1; branchType = 3'b000; aluOp = 5'b00001; end // beq
            6'b000101: begin branch = 1; branchType = 3'b001; aluOp = 5'b00001; end // bne

            // J-type
            6'b000010: begin jump = 1; end // j
            6'b000011: begin jump = 1; is_jal = 1; regWrite = 1; end // jal

            // Custom branch types — opcode = 6'b011111
            6'b011111: begin
                branch = 1;
                case (funct)
                    6'b010001: branchType = 3'b010; // bgt
                    6'b010010: branchType = 3'b011; // bgte
                    6'b010011: branchType = 3'b100; // ble
                    6'b010100: branchType = 3'b101; // bleq
                    6'b010101: branchType = 3'b110; // bleu
                    6'b010110: branchType = 3'b111; // bgtu
                    6'b011000: begin aluOp = 5'b10001; regWrite = 1; end // seq
                endcase
            end
        endcase
    end
endmodule








`timescale 1ns / 1ps
module branch_unit (
    input [31:0] pc_current,
    input [31:0] rs_val,
    input [31:0] rt_val,
    input [15:0] immediate,
    input [25:0] jump_address,
    input [2:0] branch_control,  // Encoded control signal
    input is_jump,
    input is_jal,
    input is_jr,
    output reg [31:0] next_pc,
    output reg take_branch
);
    wire signed [31:0] rs_signed = rs_val;
    wire signed [31:0] rt_signed = rt_val;
    wire [31:0] offset = {{14{immediate[15]}}, immediate, 2'b00}; // sign-extend + shift

    always @(*) begin
        take_branch = 0;
        next_pc = pc_current + 4;

        case (branch_control)
            3'b000: take_branch = (rs_val == rt_val);     // beq
            3'b001: take_branch = (rs_val != rt_val);     // bne
            3'b010: take_branch = (rs_signed > rt_signed);// bgt
            3'b011: take_branch = (rs_signed >= rt_signed);// bgte
            3'b100: take_branch = (rs_signed < rt_signed);// ble
            3'b101: take_branch = (rs_signed <= rt_signed);// bleq
            3'b110: take_branch = (rs_val < rt_val);      // bleu
            3'b111: take_branch = (rs_val > rt_val);      // bgtu
        endcase

        if (take_branch) begin
            next_pc = pc_current + 4 + offset;
        end else if (is_jump) begin
            next_pc = {pc_current[31:28], jump_address, 2'b00}; // j / jal
        end else if (is_jr) begin
            next_pc = rs_val;                                   // jr
        end
    end
endmodule








`timescale 1ns / 1ps
module alu (
    input  [31:0] A,         // First operand (e.g., rs)
    input  [31:0] B,         // Second operand (e.g., rt or immediate)
    input  [4:0] shamt,      // Shift amount
    input  [4:0] alu_control, // Operation selector
    input  [63:0] hi_lo_in,  // For madd/maddu: current hi_lo value
    output reg [31:0] result,
    output reg [63:0] hi_lo, // Output for mul/madd/maddu
    output reg zero,
    output reg sign,
    output reg overflow
);

    reg signed [31:0] A_signed, B_signed;
    reg [63:0] mult_result;

    always @(*) begin
        A_signed = A;
        B_signed = B;
        zero = 0;
        sign = 0;
        overflow = 0;
        hi_lo = 0;
        result = 0;

        case (alu_control)
            // Arithmetic
            5'b00000: result = A + B;                             // add/addi
            5'b00001: result = A - B;                             // sub
            5'b00010: result = A + B;                             // addu/addiu (unsigned)
            5'b00011: result = A - B;                             // subu (unsigned)
            5'b00100: begin                                       // mul
                mult_result = A * B;
                hi_lo = mult_result;
                result = mult_result[31:0];                       // lo part
            end
            5'b00101: begin                                       // madd
                mult_result = A * B;
                hi_lo = hi_lo_in + mult_result;
                result = hi_lo[31:0];                             // lo part
            end
            5'b00110: begin                                       // maddu
                mult_result = A * B;
                hi_lo = hi_lo_in + mult_result;
                result = hi_lo[31:0];
            end

            // Logical
            5'b01000: result = A & B;                             // and/andi
            5'b01001: result = A | B;                             // or/ori
            5'b01010: result = A ^ B;                             // xor/xori
            5'b01011: result = ~A;                                // not

            // Shifts
            5'b01100: result = B << shamt;                        // sll
            5'b01101: result = B >> shamt;                        // srl (logical)
            5'b01110: result = $signed(B) >>> shamt;             // sra (arithmetic)
            5'b01111: result = $signed(B) <<< shamt;             // sla (same as sll for signed)

            // Comparison
            5'b10000: result = ($signed(A) < $signed(B)) ? 1 : 0; // slt/slti
            5'b10001: result = (A == B) ? 1 : 0;                  // seq
            5'b10010: result = ($signed(A) > $signed(B)) ? 1 : 0; // bgt
            5'b10011: result = ($signed(A) >= $signed(B)) ? 1 : 0;// bgte
            5'b10100: result = ($signed(A) < $signed(B)) ? 1 : 0; // ble
            5'b10101: result = ($signed(A) <= $signed(B)) ? 1 : 0;// bleq
            5'b10110: result = (A < B) ? 1 : 0;                   // bleu (unsigned)
            5'b10111: result = (A > B) ? 1 : 0;                   // bgtu (unsigned)

            default: result = 0;
        endcase

        zero = (result == 0);
        sign = result[31];
    end
endmodule







`timescale 1ns / 1ps
module regfile (
    input clk,
    input [4:0] rs,
    input [4:0] rt,
    input [4:0] rd,
    input [31:0] write_data,
    input regWrite,
    input regDst,
    output [31:0] rs_val,
    output [31:0] rt_val
);
    reg [31:0] registers [0:31];
  
  	integer i;
    initial begin
      for (i = 0; i < 32; i = i + 1)
        registers[i] = 32'b0;
    end

    assign rs_val = registers[rs];
    assign rt_val = registers[rt];

    wire [4:0] write_reg = regDst ? rd : rt;

    always @(posedge clk) begin
      if (regWrite && write_reg != 0) begin
          registers[write_reg] <= write_data;
//           $display("Register Write: R[%0d] <= %h", write_reg, write_data);
      end
	end
endmodule







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
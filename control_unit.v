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

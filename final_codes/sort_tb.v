`timescale 1ns / 1ps

module testbench;
    reg clk = 0;
    reg reset = 1;
    reg init_mode = 1;
    reg write_enable = 0;
    reg [11:0] init_address = 0;
    reg [31:0] init_instruction = 0;

    wire [31:0] pc_out;
    wire [31:0] instruction_out;
    wire [31:0] debug_result;

    iitk_mini_mips uut (
        .clk(clk),
        .reset(reset),
        .init_mode(init_mode),
        .write_enable(write_enable),
        .init_address(init_address),
        .init_instruction(init_instruction),
        .pc_out(pc_out),
        .instruction_out(instruction_out),
        .debug_result(debug_result)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Bubble sort instructions will be loaded here
    initial begin
        $display("Starting Bubble Sort Testbench...");

        reset = 1;
        init_mode = 1;
        write_enable = 1;

      	integer i = 0;
      	reg [31:0] prog [0:63];

        prog[0]  = 32'h2012000A; // addi $s2, $zero, 10    ; limit = 10
        prog[1]  = 32'h20100000; // addi $s0, $zero, 0     ; i = 0
        // outer_loop:
        prog[2]  = 32'h0212102A; // slt $s2, $s0, $s2      ; if i < 10
        prog[3]  = 32'h10400011; // beq $v0, $zero, done
        prog[4]  = 32'h20110000; // addi $s1, $zero, 0     ; j = 0
        prog[5]  = 32'h02521023; // sub $s3, $s2, $s0      ; s3 = limit - i
        prog[6]  = 32'h2273FFFF; // addi $s3, $s3, -1      ; s3 = limit - i - 1
        // inner_loop:
        prog[7]  = 32'h0233102A; // slt $v0, $s1, $s3
        prog[8]  = 32'h1040000C; // beq $v0, $zero, next_i
        prog[9]  = 32'h00111880; // sll $s4, $s1, 2        ; s4 = j*4
        prog[10] = 32'h22141000; // addi $s4, $s4, 0x1000  ; s4 = addr of A[j]
        prog[11] = 32'h22141000; // addi $s4, $s4, 0x1000  ; s4 = 0x10010000
        prog[12] = 32'h8E800000; // lw $t0, 0($s4)         ; t0 = A[j]
        prog[13] = 32'h22950004; // addi $s5, $s4, 4       ; s5 = addr A[j+1]
        prog[14] = 32'h8EA10000; // lw $t1, 0($s5)         ; t1 = A[j+1]
        prog[15] = 32'h0109502A; // slt $t2, $t1, $t0      ; if A[j+1] < A[j]
        prog[16] = 32'h11400003; // beq $t2, $zero, skip_swap
        prog[17] = 32'hAE810000; // sw $t1, 0($s4)         ; A[j] = A[j+1]
        prog[18] = 32'hAEA00000; // sw $t0, 0($s5)         ; A[j+1] = A[j]
        // skip_swap:
        prog[19] = 32'h22310001; // addi $s1, $s1, 1       ; j++
        prog[20] = 32'h08100007; // j inner_loop
        // next_i:
        prog[21] = 32'h22300001; // addi $s0, $s0, 1       ; i++
        prog[22] = 32'h08100002; // j outer_loop
        // done:
        prog[23] = 32'h00000000; // nop (or could be halt)

        // Load program into instruction memory
        for (i = 0; i < 24; i = i + 1) begin
            init_address = i;
            init_instruction = prog[i];
            #10;
        end

        // End init
        write_enable = 0;
        init_mode = 0;
        #5;
        reset = 0;
    end

    // Preload data memory (unsorted array) in simulation
    initial begin
        // preload directly into data memory
        uut.DMEM.memory[0] = 32'd7;
        uut.DMEM.memory[1] = 32'd3;
        uut.DMEM.memory[2] = 32'd5;
        uut.DMEM.memory[3] = 32'd1;
        uut.DMEM.memory[4] = 32'd9;
        uut.DMEM.memory[5] = 32'd2;
        uut.DMEM.memory[6] = 32'd6;
        uut.DMEM.memory[7] = 32'd8;
        uut.DMEM.memory[8] = 32'd4;
        uut.DMEM.memory[9] = 32'd0;
    end

    // End simulation when PC reaches last instruction
    always @(posedge clk) begin
        if (pc_out >= 32'h00400060) begin
            $display("Sorted Array in Memory:");
            integer i;
            for (i = 0; i < 10; i = i + 1)
                $display("A[%0d] = %0d", i, uut.DMEM.memory[i]);
            $finish;
        end
    end
endmodule
`timescale 1ns / 1ps

module iitk_mini_mips_tb;

    reg clk = 0;
    reg reset = 1;

    // Instruction memory interface
    reg init_mode;
    reg write_enable;
    reg [11:0] init_address;
    reg [31:0] init_instruction;

    wire [31:0] pc_out, instruction_out, debug_result;

    // Instantiate the processor
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

    // Clock generator
    always #5 clk = ~clk;

    // Data memory preload (simulated)
    initial begin
        // Access data memory directly via hierarchical reference
        uut.DMEM.memory[0] = 11; // at address 0x10010000
        uut.DMEM.memory[1] = 22; // at address 0x10010004
    end

    initial begin
        $display("=== Test: ADD Two Numbers and Store Result ===");
        $dumpfile("test.vcd");
        $dumpvars(0, iitk_mini_mips_tb);

        #2 reset = 1;
        #10 reset = 0;

        // === Begin init phase ===
        init_mode = 1;
        write_enable = 1;

        // Instruction 0: lw $t0, 0($gp)
        init_address = 0;
        init_instruction = 32'h8C080000; #10;

        // Instruction 1: lw $t1, 4($gp)
        init_address = 1;
        init_instruction = 32'h8C290004; #10;

        // Instruction 2: add $t2, $t0, $t1
        init_address = 2;
        init_instruction = 32'h01095020; #10;

        // Instruction 3: sw $t2, 8($gp)
        init_address = 3;
        init_instruction = 32'hAC4A0008; #10;

        // Instruction 4: j done (infinite loop)
        init_address = 4;
        init_instruction = 32'h08000004; #10;

        // === End init phase ===
        init_mode = 0;
        write_enable = 0;

        // Let the processor run
        #100;

        // Check result in memory[2] (0x10010008)
        $display("✅ Final Result at data[2] (memory[2]) = %0d", uut.DMEM.memory[2]);

        $finish;
    end

endmodule

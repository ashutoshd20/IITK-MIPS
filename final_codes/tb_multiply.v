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

    initial begin
        $display("🔬 Starting Multiply Testbench...");
        $monitor("⏱ Time=%0t | PC=%h | Inst=%h | ALU Result=%d", $time, pc_out, instruction_out, debug_result);

        // Phase 1: Initialization
        #5 reset = 1;
        init_mode = 1;
        write_enable = 0;
        #10;

        // Load: addi $t0, $zero, 6   # $t0 = 6
        init_address = 12'd0;
        init_instruction = 32'b001000_00000_01000_0000000000000110;
        write_enable = 1; #10;

        // Load: addi $t1, $zero, 7   # $t1 = 7
        init_address = 12'd1;
        init_instruction = 32'b001000_00000_01001_0000000000000111;
        #10;

        // Load: mul $t2, $t0, $t1    # $t2 = $t0 * $t1
        // Encoding: opcode=000000, rs=01000, rt=01001, rd=01010, shamt=00000, funct=000010
        init_address = 12'd2;
        // new (fixed, funct=011000)
		init_instruction = 32'b000000_01000_01001_01010_00000_011000;
        #10;

        // Phase 2: Execution
        write_enable = 0;
        init_mode = 0;
        #5 reset = 0;
    end

    // Stop simulation after final instruction
    always @(posedge clk) begin
        if (pc_out == 32'h0040000C) begin
            $display("✅ Multiply test completed. Result: %0d", debug_result);
            $finish;
        end
    end
endmodule

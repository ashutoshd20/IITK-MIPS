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

    // Instantiate the IITK module (your MIPS processor)
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

    // Clock generation (clock period of 10 ns)
    always #5 clk = ~clk;

    initial begin
        // Start the testbench
        $display("Starting Testbench...");
        $monitor("Time=%0t PC=%h Inst=%h ALU Result=%h", $time, pc_out, instruction_out, debug_result);

        // Reset the processor and initialize instruction memory
        reset = 1;
        write_enable = 0;
        init_mode = 1;

        #10;

        // Load the first instruction (addi $t0, $zero, 5) at address 0
        init_address = 12'd0;
        init_instruction = 32'b001000_00000_01000_0000000000000101; // addi $t0, $zero, 5
        write_enable = 1;
        #10;

        // Load the second instruction (addi $t1, $zero, 10) at address 1
        init_address = 12'd1;
        init_instruction = 32'b001000_00000_01001_0000000000001010; // addi $t1, $zero, 10
        #10;

        // Load the third instruction (add $t2, $t0, $t1) at address 2
        init_address = 12'd2;
        init_instruction = 32'b000000_01000_01001_01010_00000_100000; // add $t2, $t0, $t1
        #10;

        // Load the fourth instruction (addi $t3, $zero, 0) at address 3 (initialize $t3 to 0)
        init_address = 12'd3;
        init_instruction = 32'b001000_00000_01011_0000000000000000; // addi $t3, $zero, 0
        #10;

        // Load the fifth instruction (slt $t4, $t0, $t1) at address 4 (set $t4 to 1 if $t0 < $t1)
        init_address = 12'd4;
        init_instruction = 32'b000000_01000_01001_01100_00000_101010; // slt $t4, $t0, $t1
        #10;

        // End loading instructions
        write_enable = 0;
        init_mode = 0;
        #10;
        $display("We are here...");

        // Release reset
        reset = 0;
    end

    // Check if all instructions have been executed (when PC reaches 0x00400014)
    always @(posedge clk) begin
        if (pc_out == 32'h00400014) begin
            $display("✅ All instructions executed. Halting simulation.");
            $finish;
        end
    end
endmodule

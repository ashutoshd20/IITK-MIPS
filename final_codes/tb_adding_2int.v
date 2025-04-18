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
        $display("Starting Testbench...");
        $monitor("Time=%0t PC=%h Inst=%h ALU Result=%h", $time, pc_out, instruction_out, debug_result);

        // Initial values and reset
        reset = 1;
        write_enable = 0;
        init_mode = 1;

        #10;

        // Load addi $t0, $zero, 5
        init_address = 12'd0;
        init_instruction = 32'b001000_00000_01000_0000000000000101;
        write_enable = 1;
        #10;

        // Load addi $t1, $zero, 10
        init_address = 12'd1;
        init_instruction = 32'b001000_00000_01001_0000000000001010;
        #10;

        // Load add $t2, $t0, $t1
        init_address = 12'd2;
        init_instruction = 32'b000000_01000_01001_01010_00000_100000;
        #10;

        // End loading
        write_enable = 0;
        init_mode = 0;
        #5;

        // Release reset
        reset = 0;
    end

    // Automatic termination after final instruction at PC=0x00400008
    always @(posedge clk) begin
        if (pc_out == 32'h0040000C) begin
            $display("✅ All instructions executed. Halting simulation.");
            $finish;
        end
    end
endmodule

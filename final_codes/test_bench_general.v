`timescale 1ns / 1ps

module testbench;
    reg clk = 0;
    reg reset = 1;
    reg init_mode = 1;
    reg write_enable = 0;
    reg [11:0] init_address = 0;
    reg [31:0] init_instruction = 0;
    wire [31:0] pc_out, instruction_out, debug_result;

    // Instantiate your processor
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

    task init_inst(input [11:0] addr, input [31:0] inst);
        begin
            @(negedge clk);
            init_address = addr;
            init_instruction = inst;
            write_enable = 1;
            @(negedge clk);
            write_enable = 0;
        end
    endtask

    always #5 clk = ~clk;

    initial begin
        $display("Starting Processor...");

        // Reset
        #10 reset = 1;
        #20 reset = 0;

        // Instruction Loading
        init_mode = 1;
        write_enable = 0;

        init_inst(0, 32'b00100000000010000000000000001101);
        init_inst(1, 32'b00100000000010010000000000000111);
        init_inst(2, 32'b00100000000010100000000000011001);
        init_inst(3, 32'b01111101001010000000000000010001);
        init_inst(4, 32'b00100001000010110000000000000000);
        init_inst(5, 32'b00100001001010000000000000000000);
        init_inst(6, 32'b00100001011010010000000000000000);
        init_inst(7, 32'b00100001000010000000000000000000);
        init_inst(8, 32'b00100001001010010000000000000000);
        init_inst(9, 32'b00100001010010100000000000000000);

        @(negedge clk);
        init_mode = 0;

        // Run for some time
        repeat (25) begin
            @(posedge clk);
            $display("Time=%0t | PC=%h | Inst=%h | Result=%10d", $time, pc_out, instruction_out, debug_result);
        end

        $finish;
    end
endmodule
//Author --  Ashutosh Dwivedi (200214)

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
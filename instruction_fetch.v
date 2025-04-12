//Author --  Ashutosh Dwivedi (200214)

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
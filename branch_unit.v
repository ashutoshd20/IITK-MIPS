//Author --  Ashutosh Dwivedi (200214)

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

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/09/2025 02:32:01 PM
// Design Name: 
// Module Name: alu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module alu(
    input [5:0] alu_operation,
    input [31:0] input1,
    input [31:0] input2,
    output [31:0] output1,
    output [31:0] output2,
    output is_zero
);
    wire [63:0]mult=input1*input2;
    assign output1 = (alu_operation == 6'd1) ? (input1 + input2) :
                     (alu_operation == 6'd2) ? (input1 - input2) :
                     (alu_operation == 6'b000011) ? (input1 & input2) :
                     (alu_operation == 6'b000100) ? (input1 | input2) :
                     (alu_operation == 6'b000101) ? (~input1) :
                     (alu_operation == 6'b000110) ? (input1 ^ input2) :
                     (alu_operation == 6'b000111) ? (input1 << input2) :
                     (alu_operation == 6'b001000) ? (input1 >> input2) :
                     (alu_operation == 6'b001001) ? (($signed(input1) - $signed(input2) )< 0)? 32'd1:32'd0 ://slt
                     (alu_operation == 6'b001010) ? ((input1 - input2 )== 0)? 32'd1:32'd0 ://seq
                     
                     (alu_operation == 6'b001011) ? mult[63:32] ://mul
                     32'h00000000;
    
    assign output2 = (alu_operation == 6'b001011) ? mult[31:0] ://mul
                     32'h00000000;
    assign is_zero = (output1 == 32'h00000000) ? 1'b1 : 1'b0;
endmodule

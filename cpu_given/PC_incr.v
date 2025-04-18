`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/09/2025 02:34:13 PM
// Design Name: 
// Module Name: PC_incr
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


module PC_incr(
    input        PC_control,
    input [14:0] j_instr_addr,
    input [14:0] PC,
    output [14:0] PC_out
);

    assign PC_out = (PC_control !== 1'bx) ? 
                    (PC_control ? j_instr_addr : PC + 1) : 
                    PC; // retain PC if undefined

endmodule


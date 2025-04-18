`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/09/2025 02:32:52 PM
// Design Name: 
// Module Name: inst_file
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


module instr_fetch(input [14:0] addr, output [31:0] instr);
    reg [31:0] instr_mem[31:0];

    initial begin
        instr_mem[0] <= 32'b001111_00000_00001_0000000000000001;
        //instr_mem[1] <= 32'b100001_00010_00001_01000_00000000011;
	//instr_mem[2] <= 32'b011010_00010_00001_00000_00011000111;
        //instr_mem[0] <= 32'b010010_00000_00001_0000000000000011;
        //instr_mem[1] <= 32'h0bc12345;
    end

    assign instr = instr_mem[addr];
endmodule

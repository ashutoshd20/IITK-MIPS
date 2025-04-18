`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/09/2025 02:33:27 PM
// Design Name: 
// Module Name: reg_file
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


module register_file(
    input [4:0] read_addr1, input [4:0] read_addr2,
    input [31:0] data,input [31:0] data2, input WE,input WE2, input clk,
    input [4:0] write_addr,input [4:0] write_addr2,
    output [31:0] read1, output [31:0] read2
);
    reg [31:0] reg_file [31:0];

    assign read1 = reg_file[read_addr1];
    assign read2 = reg_file[read_addr2];

    initial begin
        reg_file[0] <= 32'h00000001;
        reg_file[1] <= 32'h000000fa;
	reg_file[2] <= 32'h0000000b;
	reg_file[3] <= 32'h0000000c;
    end
    always @(posedge clk) begin
        if (WE) begin
            reg_file[write_addr] <= data;
        end
        if (WE2) begin
            reg_file[write_addr2] <= data2;
        end
    end
endmodule

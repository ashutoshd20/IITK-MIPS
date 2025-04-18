`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/09/2025 02:42:20 PM
// Design Name: 
// Module Name: data_mem
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



module data_mem(
    input [14:0] read_addr,
    input [31:0] data, input WE, input clk,
    input [14:0] write_addr,
    output [31:0] read
);
    reg [31:0] data_mem [31:0];

    assign read = data_mem[read_addr];
  

    initial begin
        data_mem[0] <= 32'h00000abc;
        data_mem[1] <= 32'h00000bcd;
	    data_mem[2] <= 32'h0000000b;
	    data_mem[3] <= 32'h0000000c;
    end
    always @(posedge clk) begin
        if (WE) begin
            data_mem[write_addr] <= data;
        end
    end
endmodule

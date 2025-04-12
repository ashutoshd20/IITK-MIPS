//Author --  Ashutosh Dwivedi (200214)

`timescale 1ns / 1ps
module regfile (
    input clk,
    input [4:0] rs,
    input [4:0] rt,
    input [4:0] rd,
    input [31:0] write_data,
    input regWrite,
    input regDst,
    output [31:0] rs_val,
    output [31:0] rt_val
);
    reg [31:0] registers [0:31];
  
  	integer i;
    initial begin
      for (i = 0; i < 32; i = i + 1)
        registers[i] = 32'b0;
    end

    assign rs_val = registers[rs];
    assign rt_val = registers[rt];

    wire [4:0] write_reg = regDst ? rd : rt;

    always @(posedge clk) begin
      if (regWrite && write_reg != 0) begin
          registers[write_reg] <= write_data;
//           $display("Register Write: R[%0d] <= %h", write_reg, write_data);
      end
	end
endmodule
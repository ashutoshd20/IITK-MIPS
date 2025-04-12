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

    assign rs_val = registers[rs];
    assign rt_val = registers[rt];

    wire [4:0] write_reg = regDst ? rd : rt;

    always @(posedge clk) begin
        if (regWrite && write_reg != 0)
            registers[write_reg] <= write_data;
    end
endmodule

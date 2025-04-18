module data_memory (
    input clk,
    input memRead,
    input memWrite,
    input [31:0] address,
    input [31:0] writeData,
    output reg [31:0] readData
);
    reg [31:0] memory [0:4095];  // 16 KB

    wire [11:0] word_addr = (address - 32'h10010000) >> 2;

    always @(posedge clk) begin
        if (memWrite)
            memory[word_addr] <= writeData;
    end

    always @(*) begin
        if (memRead)
            readData = memory[word_addr];
        else
            readData = 32'b0;
    end
endmodule

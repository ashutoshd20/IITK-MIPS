module instruction_fetch(
    input clk,
    input reset,
    output reg [31:0] pc,
    output reg [31:0] instruction
);
    reg [31:0] instruction_memory [0:4095];  // 16 KB = 4K words

    initial begin
        $readmemh("instructions.mem", instruction_memory); 
    end

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 32'h00400000;
        else begin
            instruction <= instruction_memory[(pc - 32'h00400000) >> 2];
            pc <= pc + 4;
        end
    end
endmodule

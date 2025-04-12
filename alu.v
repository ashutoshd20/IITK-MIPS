module alu (
    input  [31:0] A,         // First operand (e.g., rs)
    input  [31:0] B,         // Second operand (e.g., rt or immediate)
    input  [4:0] shamt,      // Shift amount
    input  [4:0] alu_control, // Operation selector
    input  [63:0] hi_lo_in,  // For madd/maddu: current hi_lo value
    output reg [31:0] result,
    output reg [63:0] hi_lo, // Output for mul/madd/maddu
    output reg zero,
    output reg sign,
    output reg overflow
);

    reg signed [31:0] A_signed, B_signed;
    reg [63:0] mult_result;

    always @(*) begin
        A_signed = A;
        B_signed = B;
        zero = 0;
        sign = 0;
        overflow = 0;
        hi_lo = 0;
        result = 0;

        case (alu_control)
            // Arithmetic
            5'b00000: result = A + B;                             // add/addi
            5'b00001: result = A - B;                             // sub
            5'b00010: result = A + B;                             // addu/addiu (unsigned)
            5'b00011: result = A - B;                             // subu (unsigned)
            5'b00100: begin                                       // mul
                mult_result = A * B;
                hi_lo = mult_result;
                result = mult_result[31:0];                       // lo part
            end
            5'b00101: begin                                       // madd
                mult_result = A * B;
                hi_lo = hi_lo_in + mult_result;
                result = hi_lo[31:0];                             // lo part
            end
            5'b00110: begin                                       // maddu
                mult_result = A * B;
                hi_lo = hi_lo_in + mult_result;
                result = hi_lo[31:0];
            end

            // Logical
            5'b01000: result = A & B;                             // and/andi
            5'b01001: result = A | B;                             // or/ori
            5'b01010: result = A ^ B;                             // xor/xori
            5'b01011: result = ~A;                                // not

            // Shifts
            5'b01100: result = B << shamt;                        // sll
            5'b01101: result = B >> shamt;                        // srl (logical)
            5'b01110: result = $signed(B) >>> shamt;             // sra (arithmetic)
            5'b01111: result = $signed(B) <<< shamt;             // sla (same as sll for signed)

            // Comparison
            5'b10000: result = ($signed(A) < $signed(B)) ? 1 : 0; // slt/slti
            5'b10001: result = (A == B) ? 1 : 0;                  // seq
            5'b10010: result = ($signed(A) > $signed(B)) ? 1 : 0; // bgt
            5'b10011: result = ($signed(A) >= $signed(B)) ? 1 : 0;// bgte
            5'b10100: result = ($signed(A) < $signed(B)) ? 1 : 0; // ble
            5'b10101: result = ($signed(A) <= $signed(B)) ? 1 : 0;// bleq
            5'b10110: result = (A < B) ? 1 : 0;                   // bleu (unsigned)
            5'b10111: result = (A > B) ? 1 : 0;                   // bgtu (unsigned)

            default: result = 0;
        endcase

        zero = (result == 0);
        sign = result[31];
    end
endmodule

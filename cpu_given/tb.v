`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/09/2025 02:35:38 PM
// Design Name: 
// Module Name: tb
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

module cu_tb;

    reg clk;
    reg [14:0] PC;  // Corrected: 15-bit PC
    wire [14:0] PC_out; 
    reg reset;
 
    

     wire PC_control;
     
     wire [14:0]j_instr_addr;
    // Clock generation: toggles every 30 time units
    always #30 clk = ~clk;

    // Instantiate the control unit
    control_unit cu(.clk(clk), .PC(PC),.PC_control(PC_control),.j_instr_addr(j_instr_addr));
    PC_incr pci(.PC_control(PC_control),.j_instr_addr(j_instr_addr),.PC(PC),.PC_out(PC_out));

    
    initial begin
        // Initialize signals
        clk <= 0;
        reset <= 0;
        PC <= 15'd0;

        
        

        #5000 $finish;
    end
	always@(posedge clk) begin
	PC<=PC_out;
	end


endmodule
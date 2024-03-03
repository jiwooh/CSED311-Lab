`include "alu_func.v"

module alu #(parameter data_width = 16) (
	input signed [data_width - 1 : 0] A, 
	input signed [data_width - 1 : 0] B, 
	input [3 : 0] FuncCode,
       	output reg signed [data_width - 1: 0] C,
       	output reg OverflowFlag);
// Do not use delay in your implementation.

// You can declare any variables as needed.
/*
	YOUR VARIABLE DECLARATION...
*/

initial begin
	C = 0;
	OverflowFlag = 0;
end   	

// TODO: You should implement the functionality of ALU!
// (HINT: Use 'always @(...) begin ... end')
/*
	YOUR ALU FUNCTIONALITY IMPLEMENTATION...
*/
always @(*) begin
    case (FuncCode)
    `FUNC_ADD: begin
        C = A + B; // ADD
        OverflowFlag = ((A > 0 && B > 0 && C < 0) || (A < 0 && B < 0 && C > 0)); // handle overflow
    end
    `FUNC_SUB: begin
        C = A - B; // SUB
        OverflowFlag = ((A > 0 && B < 0 && C < 0) || (A < 0 && B > 0 && C > 0)); // handle overflow
    end
    `FUNC_ID: begin
        C = A; // ID
        OverflowFlag = 0;
    end
    `FUNC_NOT: begin
        C = ~A; // NOT
        OverflowFlag = 0;
    end
    `FUNC_AND: begin
        C = A & B; // AND
        OverflowFlag = 0;
    end
    `FUNC_OR: begin
        C = A | B; // OR
        OverflowFlag = 0;
    end
    `FUNC_NAND: begin
        C = ~(A & B); // NAND
        OverflowFlag = 0;
    end
    `FUNC_NOR: begin
        C = ~(A | B); // NOR
        OverflowFlag = 0;
    end
    `FUNC_XOR: begin
        C = A ^ B; // XOR
        OverflowFlag = 0;
    end
    `FUNC_XNOR: begin
        C = ~(A ^ B); // XNOR
        OverflowFlag = 0;
    end
    `FUNC_LLS: begin
        C = A << 1; // LLS
        OverflowFlag = 0;
    end
    `FUNC_LRS: begin
        C = A >> 1; // LRS
        C[data_width - 1] = 0; // MSB 0
        OverflowFlag = 0;
    end
    `FUNC_ALS: begin
        C = A << 1; // ALS
        OverflowFlag = 0;
    end
    `FUNC_ARS: begin
        C = A >> 1; // ARS
        C[data_width - 1] = C[data_width - 2]; // MSB = 2nd MSB
        OverflowFlag = 0;
    end
    `FUNC_TCP: begin
        C = ~A + 1'b1; // TCP
        OverflowFlag = 0;
    end
    `FUNC_ZERO: begin
        C = 0; // ZERO
        OverflowFlag = 0;
    end
    default: begin
        C = C; // Default
        OverflowFlag = 0;
    end
    endcase
end

endmodule


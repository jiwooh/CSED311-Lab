`include "alu_func.v"

module OverflowDetector #(parameter data_width = 16)(
	input wire [data_width - 1 : 0] A, 
	input wire [data_width - 1 : 0] B, 
    wire [data_width-1:0] C,
	output OverflowFlag);
	assign C = A+B;
	assign OverflowFlag = (A[data_width - 1] != B[data_width - 1]) && (A[data_width - 1] != C[data_width - 1]);

endmodule

module alu #(parameter data_width = 16) (
	input [data_width - 1 : 0] A, 
	input [data_width - 1 : 0] B, 
	input [3 : 0] FuncCode,
       	output reg [data_width - 1: 0] C,
       	output reg OverflowFlag);
// Do not use delay in your implementation.

// You can declare any variables as needed.
wire AddOverflowDetector;
wire SubOverflowDetector;
OverflowDetector AddOverflow (A,B,AddOverflowDetector);
OverflowDetector SubOverflow (A,~B,SubOverflowDetector);


initial begin
	C = 0;
	OverflowFlag = 0;
end   	

// TODO: You should implement the functionality of ALU!
// (HINT: Use 'always @(...) begin ... end')

always @(*) begin
	case(FuncCode)
		FUNC_ADD: begin
			C=A+B;
			OverflowFlag = AddOverflowDetector;
		end
		FUNC_SUB: begin
			C=A-B;
			OverflowFlag = SubOverflowDetector;
		end
		FUNC_ID: C = A; // ID
		FUNC_NOT: C = ~A; // NOT
		FUNC_AND: C = A & B; // AND
		FUNC_OR: C = A | B; // OR
		FUNC_NAND: C = ~(A & B); // NAND
		FUNC_NOR: C = ~(A | B); // NOR
		FUNC_XOR: C = A ^ B; // XOR
		FUNC_XNOR: C = ~(A ^ B); // XNOR
		FUNC_LLS: C = A << 1; // LLS
		FUNC_LRS: C = A >> 1; // LRS
		FUNC_ALS: C = A << 1; // ALS
		FUNC_ARS: C = A >> 1; // ARS
		FUNC_TCP: C = ~A + 1'b1; // TCP
		FUNC_ZERO: C = 0; // ZERO
	endcase
end

endmodule


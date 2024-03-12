`include "alu_func.v"

module alu (
	input [2:0] alu_op,
	input [31:0] alu_in_1, 
	input [31:0] alu_in_2, 
    output wire [31:0] alu_res,
    output wire alu_bcond);


initial begin
	alu_res = 0;
	alu_bcond = 0;
end   	

always @(*) begin
	alu_bcond = 0;
	case (alu_op)
		`FUNC_ADD: begin
			alu_res = alu_in_1 + alu_in_2;
		end
		`FUNC_SUB: begin
			alu_res = alu_in_1 - alu_in_2;
		end
		`FUNC_AND: alu_res = alu_in_1 & alu_in_2; // AND
		`FUNC_OR: alu_res = alu_in_1 | alu_in_2; // OR
		`FUNC_XOR: alu_res = alu_in_1 ^ alu_in_2; // XOR
		`FUNC_SLL: alu_res = alu_in_1 << 1; // SLL
		`FUNC_SRL: begin // SRL
        	alu_res = alu_in_1 >> 1;
        	alu_res[data_width - 1] = 0; // MSB 0
		end
	endcase
end

endmodule


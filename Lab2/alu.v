`include "alucodes.v"

module alu (
	input [2:0] alu_op,
	input [2:0] btype,
	input signed [31:0] alu_in_1, 
	input signed [31:0] alu_in_2, 
    output reg signed [31:0] alu_res,
    output reg alu_bcond);


initial begin
	alu_res = 0;
	alu_bcond = 0;
end   	

always @(*) begin
	alu_res = 0;
	alu_bcond = 0;
	case (alu_op)
		`OP_ADD: begin
			alu_res = alu_in_1 + alu_in_2;
		end
		`OP_SUB: begin
			alu_res = alu_in_1 - alu_in_2;
            case (btype)
                `BTYPE_EQ: alu_bcond = (alu_res == 0);
                `BTYPE_NE: alu_bcond = (alu_res != 0);
                `BTYPE_GE: alu_bcond = (alu_res >= 0);
                `BTYPE_LT: alu_bcond = (alu_res < 0);
                default: alu_bcond = 0;
            endcase
		end
		`OP_AND: alu_res = alu_in_1 & alu_in_2; // AND
		`OP_OR: alu_res = alu_in_1 | alu_in_2; // OR
		`OP_XOR: alu_res = alu_in_1 ^ alu_in_2; // XOR
		`OP_SLL: alu_res = alu_in_1 << alu_in_2; // SLL
		`OP_SRL: alu_res = alu_in_1 >> alu_in_2;  // SRL
        default: begin
            alu_res = 0;
            alu_bcond = 0;
        end
	endcase
end

endmodule


`include "alu_func.v"

module alu (
    input [2:0] alu_op,
    input [2:0] btype,
    input signed [31:0] alu_in_1,
    input signed [31:0] alu_in_2,
    output reg signed [31:0] alu_res,
    output reg alu_bcond
);

    // init
    initial begin
        alu_res   = 0;
        alu_bcond = 0;
    end
    // calculate
    always @(*) begin
        alu_res   = 0;
        alu_bcond = 0;
        case (alu_op)
            `FUNC_ADD: begin
                alu_res = alu_in_1 + alu_in_2;
            end
            `FUNC_SUB: begin
                alu_res = alu_in_1 - alu_in_2;
                // branch calculation
                case (btype)
                    `BRANCH_EQ: alu_bcond = ((alu_res) == 0);
                    `BRANCH_NE: alu_bcond = ((alu_res) != 0);
                    `BRANCH_GE: alu_bcond = ((alu_res) >= 0);
                    `BRANCH_LT: alu_bcond = ((alu_res) < 0);
                    default: alu_bcond = 0;
                endcase
            end
            `FUNC_AND: alu_res = alu_in_1 & alu_in_2;  // AND
            `FUNC_OR:  alu_res = alu_in_1 | alu_in_2;  // OR
            `FUNC_XOR: alu_res = alu_in_1 ^ alu_in_2;  // XOR
            `FUNC_SLL: alu_res = alu_in_1 << alu_in_2;  // SLL
            `FUNC_SRL: alu_res = alu_in_1 >> alu_in_2;  // SRL
            default: begin
                alu_res   = 0;
                alu_bcond = 0;
            end
        endcase
    end
endmodule

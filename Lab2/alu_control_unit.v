//   alu_control_unit alu_ctrl_unit (
//     .opcode(imemOutput[6:0]),  // input
//     .funct3(imemOutput[14:12]),  // input
//     .funct7_5(imemOutput[30]),  // input
//     .alu_op(alu_op),         // output
//     .btype(btype)          // output
//   );
`include "opcodes.v"
`include "alucodes.v"

module alu_control_unit (
    input [6:0] opcode,
    input [2:0] funct3,
    input funct7_5,
    output reg [2:0] alu_op,
    output reg [2:0] btype
);

always @(*) begin
    alu_op = `OP_NONE;
    btype = `BTYPE_NONE;

    case (opcode)
        `ARITHMETIC: begin
            if (funct7_5) begin
                alu_op = `OP_SUB;
            end else begin
                case (funct3)
                    `FUNCT3_ADD: alu_op = `OP_ADD;
                    `FUNCT3_SLL: alu_op = `OP_SLL;
                    `FUNCT3_XOR: alu_op = `OP_XOR;
                    `FUNCT3_OR:  alu_op = `OP_OR;
                    `FUNCT3_AND: alu_op = `OP_AND;
                    `FUNCT3_SRL: alu_op = `OP_SRL;
                    default:     alu_op = `OP_NONE;
                endcase
            end
        end
        `ARITHMETIC_IMM: begin
            case (funct3)
                `FUNCT3_ADD: alu_op = `OP_ADD;
                `FUNCT3_SLL: alu_op = `OP_SLL;
                `FUNCT3_XOR: alu_op = `OP_XOR;
                `FUNCT3_OR:  alu_op = `OP_OR;
                `FUNCT3_AND: alu_op = `OP_AND;
                `FUNCT3_SRL: alu_op = `OP_SRL;
                default:     alu_op = `OP_NONE;
            endcase
        end
        `LOAD, `STORE, `JALR: begin
            alu_op = `OP_ADD;
        end
        `BRANCH: begin
            alu_op = `OP_SUB;
            case (funct3)
                `FUNCT3_BEQ: btype = `BTYPE_EQ;
                `FUNCT3_BNE: btype = `BTYPE_NE;
                `FUNCT3_BLT: btype = `BTYPE_LT;
                `FUNCT3_BGE: btype = `BTYPE_GE;
                default:     btype = `BTYPE_NONE;
            endcase
        end
        default: begin
            alu_op = `OP_NONE;
            btype = `BTYPE_NONE;
        end
    endcase
end

endmodule

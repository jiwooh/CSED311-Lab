`include "alu_func.v"
`include "opcodes.v"
module alu_control_unit (
    input [6:0] opcode,  // input
    input [2:0] funct3,  // input
    input funct7_5,  // input
    output reg [2:0] alu_op,           // output
    output reg [2:0] btype          // output
  );
  initial begin
    alu_op = `NOT_FUNC;
    btype=`NOT_BRANCH;
  end

  always@(*) begin
    alu_op = `NOT_FUNC;
    btype=`NOT_BRANCH;
    case(opcode)
        `ARITHMETIC: begin
            if(funct7_5==1) begin
                alu_op = `FUNC_SUB;
            end 
            else begin
                case (funct3) 
                    `FUNCT3_ADD: alu_op = `FUNC_ADD;
                    `FUNCT3_SLL: alu_op = `FUNC_SLL;
                    `FUNCT3_XOR: alu_op = `FUNC_XOR;
                    `FUNCT3_OR: alu_op = `FUNC_OR;
                    `FUNCT3_AND: alu_op = `FUNC_AND;
                    `FUNCT3_SRL: alu_op = `FUNC_SRL;
                    default: alu_op = `NOT_FUNC;
                endcase
            end
        end
        `ARITHMETIC_IMM: begin
            case (funct3) 
                `FUNCT3_ADD: alu_op = `FUNC_ADD;
                `FUNCT3_SLL: alu_op = `FUNC_SLL;
                `FUNCT3_XOR: alu_op = `FUNC_XOR;
                `FUNCT3_OR: alu_op = `FUNC_OR;
                `FUNCT3_AND: alu_op = `FUNC_AND;
                `FUNCT3_SRL: alu_op = `FUNC_SRL;
                default: alu_op = `NOT_FUNC;
            endcase
        end
        `LOAD, `STORE, `JALR: begin
            alu_op=`FUNC_ADD;
        end
        `BRANCH: begin
            alu_op = `FUNC_SUB;
            case (funct3) 
                `FUNCT3_BEQ: btype = `BRANCH_EQ;
                `FUNCT3_BNE: btype = `BRANCH_NE;
                `FUNCT3_BLT: btype = `BRANCH_LT;
                `FUNCT3_BGE: btype = `BRANCH_GE;
                default: btype = `NOT_BRANCH;
            endcase
        end
        default: begin
            alu_op = `NOT_FUNC;
            btype=`NOT_BRANCH;
        end
    endcase
  end

endmodule

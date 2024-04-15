`include "alu_func.v"
`include "opcodes.v"

module ALUControlUnit (
    input [1:0] alu_control,
    input [6:0] opcode,  
    input [2:0] funct3, 
    input funct7_5, 
    output reg [2:0] alu_op,       
    output reg [2:0] btype
);

    // initialize
    initial begin
        alu_op = `NOT_FUNC;
        btype=`NOT_BRANCH;
    end

    // change control values
    always@(*) begin
        alu_op = `NOT_FUNC;
        btype=`NOT_BRANCH;
        case (alu_control)
            `ALU_ADD:
                alu_op = `FUNC_ADD;
            `ALU_SUB: begin
                alu_op = `FUNC_SUB;
                if(opcode==`BRANCH) begin
                    case (funct3) 
                        `FUNCT3_BEQ: btype = `BRANCH_EQ;
                        `FUNCT3_BNE: btype = `BRANCH_NE;
                        `FUNCT3_BLT: btype = `BRANCH_LT;
                        `FUNCT3_BGE: btype = `BRANCH_GE;
                        default: btype = `NOT_BRANCH;
                    endcase
                end
            end
            `ALU: begin
                case(opcode)
                    //based on funct3, funct7
                    `ARITHMETIC: begin
                        // sub
                        if(funct7_5==1) begin
                            alu_op = `FUNC_SUB;
                        end 
                        // not sub
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
                    // based on funct3
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
                    // branch setting
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
            `ALU_NOP: begin
                alu_op = `NOT_FUNC;
                btype=`NOT_BRANCH;
            end

        endcase
        
    end
endmodule

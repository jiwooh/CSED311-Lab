// ALU Control
`define ALU_ADD 2'b00
`define ALU_SUB 2'b01
`define ALU     2'b10
`define ALU_NOP 2'b11

// FuncCodes
`define FUNC_ADD 3'b000
`define FUNC_SUB 3'b001
`define FUNC_AND 3'b010
`define FUNC_OR 3'b011
`define FUNC_XOR 3'b100
`define FUNC_SLL 3'b101
`define FUNC_SRL 3'b110
`define NOT_FUNC 3'b111

// Branch Codes
`define BRANCH_EQ 3'b000
`define BRANCH_NE 3'b001
`define BRANCH_GE 3'b010
`define BRANCH_LT 3'b011
`define NOT_BRANCH 3'b111

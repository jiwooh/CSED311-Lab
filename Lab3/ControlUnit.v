`include "opcodes.v"
`include "states.v"
`include "alu_func.v"
module ControlUnit (
    input reset,
    input clk,
    input [6:0] op,
    input isTaken,
    output reg is_jal,
    output reg is_jalr,
    output reg mem_read,
    output reg mem_to_reg,
    output reg mem_write,
    output reg alu_srcA,
    output reg [1:0] alu_srcB,
    output reg [1:0] alu_control,
    output reg write_enable,
    output reg pc_to_reg,
    output reg pc_source,
    output reg pc_write,
    output reg pc_write_cond,
    output reg i_or_d,
    output reg ir_write,
    output reg is_ecall
);

  reg [3:0] State;
  reg [3:0] NextState;

  // state transition
  always @(*) begin
    NextState=`IF_1;
    case (State)
      `IF_1: begin
        NextState=`IF_2;
      end

      `IF_2: begin
        if(op==`JAL)
          NextState=`EX_1;
        else if (op==`ECALL)
          NextState=`IF_1;
        else
          NextState=`ID;
      end

      `ID: begin
        NextState=`EX_1;
      end

      `EX_1: begin
        case (op)
          `ARITHMETIC,
          `ARITHMETIC_IMM:
            NextState=`WB;
          `LOAD, `STORE:
            NextState=`MEM;
          `BRANCH: begin
            if(isTaken)
              NextState=`EX_2;
            else
              NextState=`IF_1;
          end
          `JALR, `JAL:
            NextState=`WB;
          default: 
            NextState=`IF_1;
        endcase
      end

      `EX_2: begin
        NextState=`IF_1;
      end

      `MEM: begin
        if(op==`LOAD)
          NextState=`WB;
        else
          NextState=`IF_1;
      end

      `WB: begin
          NextState=`IF_1;
      end

      default: begin
          NextState=`IF_1;
      end
    endcase
  end

  // change state synchronously
  always @(posedge clk) begin
        if (reset) begin
            State <= `IF_1;
        end
        else begin
            State <= NextState;
        end
  end

  // setting control values
  always @(*) begin
    mem_read=0; 
    mem_to_reg=0; 
    mem_write=0;
    pc_to_reg=0; 
    pc_source=0; 
    pc_write =0; 
    pc_write_cond=1;
    alu_srcA=0; 
    alu_srcB=0; 
    alu_control = `ALU;
    i_or_d=0; 
    ir_write=0; 
    write_enable=0; 
    is_ecall=0; 
    
    case (State)
      `IF_1: begin
        // IR = MEM[PC]
        mem_read=1;
        ir_write=1;
        i_or_d=1;
        alu_control = `ALU_NOP;
      end
      `IF_2: begin
        mem_read=1;
        ir_write=1;
        alu_control = `ALU_NOP;
        if(op==`JAL) begin
          // ALUOut = PC+4
          alu_srcA=0;   alu_srcB=1;
          alu_control = `ALU_ADD;
        end
        if(op==`ECALL) begin
          // PC=PC+4
          alu_srcA = 0; alu_srcB = 1;
          alu_control = `ALU_ADD;
          pc_source = 0;
          pc_write = 1;
        end
      end
      `ID: begin
        // ALUOut = PC+4
        alu_srcA=0;   alu_srcB=1;
        alu_control = `ALU_ADD;
      end
      `EX_1: begin
        case (op)
          `ARITHMETIC: begin
            // ALUOut = A+B
            alu_srcA=1;   alu_srcB=0;
            alu_control = `ALU;
          end
          `ARITHMETIC_IMM: begin
            // ALUOut = A+Imm
            alu_srcA=1;   alu_srcB=2;
            alu_control = `ALU;
          end
          `LOAD, `STORE: begin
            //ALUOut = A+Imm
            alu_srcA=1;   alu_srcB=2;
            alu_control = `ALU_ADD;
          end
          `BRANCH: begin
            // calculate cond: A-B
            alu_srcA=1;   alu_srcB=0;
            alu_control = `ALU_SUB;

            pc_source=1;
            pc_write_cond=0;
            if(isTaken==0) begin
              // PC=ALUOut
              pc_write=1;
            end
          end
          `JAL: begin 
            // rd = ALUOut
            write_enable = 1;
            mem_to_reg = 0;
          end
          `JALR: begin
            // rd = ALUOut
            write_enable = 1;
            mem_to_reg = 0;
          end
          default: begin
            alu_control = `ALU_NOP;
          end
        endcase
      end
      `EX_2: begin
        if(op==`BRANCH) begin
          // PC = PC+Imm
          alu_srcA=0;   alu_srcB=2;
          alu_control = `ALU_ADD;
          pc_source=0;
          pc_write=1;
        end
      end

      `MEM: begin
        i_or_d=1;
        if(op==`LOAD) begin
          // MDR = MEM[ALUOut]
          mem_read=1;
        end
        if(op==`STORE) begin
          // MEM[ALUOut] = B
          mem_write=1;

          // PC=PC+4
          alu_srcA = 0; alu_srcB = 1;
          alu_control = `ALU_ADD;
          pc_source = 0;
          pc_write = 1;
        end
      end
      `WB: begin
        case (op)
          `ARITHMETIC,`ARITHMETIC_IMM: begin
            // rd = ALUOut
            write_enable = 1;
            mem_to_reg = 0;

            // PC=PC+4
            alu_srcA = 0; alu_srcB = 1;
            alu_control = `ALU_ADD;
            pc_source = 0;
            pc_write = 1;
          end
          `LOAD: begin
            // rd = MDR
            write_enable = 1;
            mem_to_reg = 1;

            // PC=PC+4
            alu_srcA = 0; alu_srcB = 1;
            alu_control = `ALU_ADD;
            pc_source = 0;
            pc_write = 1;
          end
          `JAL: begin
            // PC = PC+Imm
            alu_srcA=0;   alu_srcB=2;
            alu_control = `ALU_ADD;
            pc_source=0;
            pc_write=1;
          end
          `JALR: begin
            // PC = A+Imm
            alu_srcA=1;   alu_srcB=2;
            alu_control = `ALU_ADD;
            pc_source=0;
            pc_write=1;
          end
          default: begin
            alu_srcA=0;   alu_srcB=0;
          end
          
          // store, branch does not requrie WB
        endcase
      end
      default: begin
        alu_srcA=0;   alu_srcB=0;
      end
    endcase

    is_jal = (op == `JAL);
    is_jalr = (op == `JALR);
    is_ecall = (op == `ECALL);    
  end
endmodule

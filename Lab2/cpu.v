// Submit this file with other files you created.
// Do not touch port declarations of the module 'cpu'.

// Guidelines
// 1. It is highly recommened to `define opcodes and something useful.
// 2. You can modify the module.
// (e.g., port declarations, remove modules, define new modules, ...)
// 3. You might need to describe combinational logics to drive them into the module (e.g., mux, and, or, ...)
// 4. `include files if required

module cpu(input reset,                     // positive reset signal
           input clk,                       // clock signal
           output is_halted,                // Whehther to finish simulation
           output [31:0] print_reg [0:31]); // TO PRINT REGISTER VALUES IN TESTBENCH (YOU SHOULD NOT USE THIS)
    /***** declarations *****/
    // 1. pc
    wire [31:0] pcOutput; 

    // 2. instruction_memory
    wire [31:0] imemOutput;

    // 3. register_file
    wire [31:0] regfileOutputData1, regfileOutputData2;

    // 4. control_unit
    wire is_jalr;
    wire is_jal;
    wire branch;
    wire mem_read;
    wire mem_to_reg;
    wire mem_write;
    wire alu_src;
    wire write_enable;
    wire pc_to_reg;
    wire is_ecall;

    // 5. imm gen
    wire [31:0] immgenOutput;

    // 6. alu_control_unit
    wire [2:0] alu_op;
    wire [2:0] btype;

    // 7. alu
    wire [31:0] aluOutput;
    wire alu_bcond;

    // 8. data memory
    wire [31:0] dmemOutput;
    
    // etc.
    wire [31:0] adder1Output;
    wire [31:0] adder2Output;
    wire [31:0] twomux1Output;
    wire [31:0] twomux2Output;
    wire [31:0] twomux3Output;
    wire [31:0] twomux4Output;
    wire [31:0] twomux5Output;
    wire andGateOutput, orGateOutput;


  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  pc pc(
    .reset(reset),       // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),         // input
    .next_pc(twomux2Output),     // input
    .current_pc(pcOutput)   // output
  );

  
  // ---------- Instruction Memory ----------
  instruction_memory imem(
    .reset(reset),   // input
    .clk(clk),     // input
    .addr(pcOutput),    // input
    .dout(imemOutput)     // output
  );

  // ---------- Register File ----------
  register_file reg_file (
    .reset(reset),        // input
    .clk(clk),          // input
    .rs1(imemOutput[19:15]),          // input
    .rs2(imemOutput[24:20]),          // input
    .rd(imemOutput[11:7]),           // input
    .rd_din(twomux4Output),       // input
    .write_enable(write_enable), // input
    .is_ecall(is_ecall), //input
    .rs1_dout(regfileOutputData1),     // output
    .rs2_dout(regfileOutputData2),     // output
    .print_reg(print_reg),  //DO NOT TOUCH THIS
    .is_halted(is_halted)        // output
  );


  // ---------- Control Unit ----------
  control_unit ctrl_unit (
    .part_of_inst(imemOutput[6:0]),  // input
    .is_jal(is_jal),        // output
    .is_jalr(is_jalr),       // output
    .branch(branch),        // output
    .mem_read(mem_read),      // output
    .mem_to_reg(mem_to_reg),    // output
    .mem_write(mem_write),     // output
    .alu_src(alu_src),       // output
    .write_enable(write_enable),  // output
    .pc_to_reg(pc_to_reg),     // output
    .is_ecall(is_ecall)       // output (ecall inst)
  );

  // ---------- Immediate Generator ----------
  immediate_generator imm_gen(
    .inst(imemOutput),  // input
    .imm_gen_out(immgenOutput)    // output
  );

  // ---------- ALU Control Unit ----------
  alu_control_unit alu_ctrl_unit (
    .opcode(imemOutput[6:0]),  // input
    .funct3(imemOutput[14:12]),  // input
    .funct7_5(imemOutput[30]),  // input
    .alu_op(alu_op),         // output
    .btype(btype)         // output
  );

  // ---------- ALU ----------
  alu alu (
    .alu_op(alu_op),      // input
    .btype(btype),      // input
    .alu_in_1(regfileOutputData1),    // input  
    .alu_in_2(twomux3Output),    // input
    .alu_res(aluOutput),  // output
    .alu_bcond(alu_bcond)    // output
  );

  // ---------- Data Memory ----------
  data_memory dmem(
    .reset(reset),      // input
    .clk(clk),        // input
    .addr(aluOutput),       // input
    .din(regfileOutputData2),        // input
    .mem_read(mem_read),   // input
    .mem_write(mem_write),  // input
    .dout(dmemOutput)        // output
  );
  // ---------- Other Modules ----------
  adder adder1(
    .x1(pcOutput),
    .x2(32'b100),
    .y(adder1Output)
  );
  adder adder2(
    .x1(pcOutput),
    .x2(immgenOutput),
    .y(adder2Output)
  );

  twomux twomux1(
    .x0(adder1Output),
    .x1(adder2Output),
    .sel(orGateOutput),
    .y(twomux1Output)
  );
  twomux twomux2(
    .x0(twomux1Output),
    .x1(aluOutput),
    .sel(is_jalr),
    .y(twomux2Output)
  );
  twomux twomux3(
    .x0(regfileOutputData2),
    .x1(immgenOutput),
    .sel(alu_src),
    .y(twomux3Output)
  );
  twomux twomux4(
    .x0(twomux5Output),
    .x1(adder1Output),
    .sel(pc_to_reg),
    .y(twomux4Output)
  );
  twomux twomux5(
    .x0(aluOutput),
    .x1(dmemOutput),
    .sel(mem_to_reg),
    .y(twomux5Output)
  );
  
  andGate andGate(
    .x1(branch),
    .x2(alu_bcond),
    .y(andGateOutput)
  );
  orGate orGate(
    .x1(is_jal),
    .x2(andGateOutput),
    .y(orGateOutput)
  );
endmodule

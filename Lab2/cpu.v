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
    wire [31:0] pcOutput; //use this

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
    wire reg_write;
    wire pc_to_reg;
    wire is_ecall;

    // 5. imm gen
    wire [31:0] immGenOutput;

    // 6. alu_control_unit

    // 7. alu
    wire [2:0] alu_op;
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
    .write_enable(reg_write), // input
    .is_ecall(is_ecall),      // input
    .rs1_dout(regfileOutputData1),     // output
    .rs2_dout(regfileOutputData2),     // output
    .print_reg(print_reg),  //DO NOT TOUCH THIS
    .is_halted(is_halted)     // output
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
    .write_enable(reg_write),  // output
    .pc_to_reg(pc_to_reg),     // output
    .is_ecall(is_ecall)       // output (ecall inst)
  );

  // ---------- Immediate Generator ----------
  immediate_generator imm_gen(
    .part_of_inst(imemOutput[31:0]),  // input
    .imm_gen_out(immGenOutput)    // output
  );

  // ---------- ALU Control Unit ----------
  alu_control_unit alu_ctrl_unit (
    .part_of_inst(),  // input
    .alu_op(alu_op)         // output
  );

  // ---------- ALU ----------
  alu alu (
    .alu_op(alu_op),      // input
    .alu_in_1(regfileOutputData1),    // input  
    .alu_in_2(twomux3Output),    // input
    .alu_result(aluOutput),  // output
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

  // ---------- Other ----------
    adder adder1(
        .a(pcOutput),  // input
        .b(32b'100),  // input
        .result(adder1Output)  // output
    );
    adder adder2(
        .a(pcOutput),  // input
        .b(immGenOutput),  // input
        .result(adder2Output)  // output
    );
    twomux twomux1(
        .a(adder1Output),  // input
        .b(adder2Output),  // input
        .sel(orGateOuput),  // input
        .y(twomux1Output)  // output
    );
    twomux twomux2(
        .a(twomux1Output),  // input
        .b(aluOutput),  // input
        .sel(is_jalr),  // input
        .y(twomux2Output)  // output
    );
    twomux twomux3(
        .a(regfileOutputData2),  // input
        .b(immGenOutput),  // input
        .sel(alu_src),  // input
        .y(twomux3Output)  // output
    );
    twomux twomux4(
        .a(adder1Output),  // input
        .b(twomux5Output),  // input
        .sel(pc_to_reg),  // input
        .y(twomux4Output)  // output
    );
    twomux twomux5(
        .a(dmemOutput),  // input
        .b(aluOutput),  // input
        .sel(mem_to_reg),  // input
        .y(twomux5Output)  // output
    );

    andGate andGate(
        .a(branch),  // input
        .b(alu_bcond),  // input
        .y(andGateOutput)  // output
    );
    orGate orGate(
        .a(is_jal),  // input
        .b(andGateOutput),  // input
        .y(orGateOutput)  // output
    );
endmodule

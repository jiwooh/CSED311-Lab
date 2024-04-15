// Submit this file with other files you created.
// Do not touch port declarations of the module 'CPU'.

// Guidelines
// 1. It is highly recommened to `define opcodes and something useful.
// 2. You can modify the module.
// (e.g., port declarations, remove modules, define new modules, ...)
// 3. You might need to describe combinational logics to drive them into the module (e.g., mux, and, or, ...)
// 4. `include files if required

module cpu(input reset,       // positive reset signal
           input clk,         // clock signal
           output is_halted,
           output [31:0]print_reg[0:31]
           ); // Whehther to finish simulation
  /***** Wire declarations *****/
  // Control Values
  wire isJAL;
  wire isJALR;
  wire MemRead;
  wire MemtoReg;
  wire MemWrite;
  wire ALUSrcA;
  wire [1:0] ALUSrcB;
  wire WriteEnable;
  wire PCtoReg;
  wire PCSource;
  wire PCWrite;
  wire PCWriteCond;
  wire IorD;
  wire IRWrite;
  wire IsEcall;

  //PC
  wire [31:0] PCOut;
  wire [31:0] PCMuxOut;
  wire [31:0] PCMemMuxOut;
  wire  OrGateOutput;
  wire  AndGateOutput;

  // ALU
  wire  ALUBcond;
  wire [1:0] ALUControl;
  wire [2:0] ALUOp;
  wire [2:0] btype;
  wire [31:0] ALUResult;
  wire [31:0] ALUInputOneMuxOut;
  wire [31:0] ALUInputTwoMuxOut;

  // Memory
  wire [31:0] MemDataOut;

  // Register File
  wire [31:0] RegWriteDataMuxOut;

  // Imm gen
  wire [31:0] ImmGenOut;



  /***** Register declarations *****/
  reg [31:0] IR; // instruction registere
  reg [31:0] MDR; // memory data register
  reg [31:0] A; // Read 1 data register
  reg [31:0] B; // Read 2 data register
  reg [31:0] ALUOut; // ALU output register
  // Do not modify and use registers declared above.

  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  PC pc(
    .reset(reset),       // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),         // input
    .next_pc(PCMuxOut),     // input
    .pc_write(OrGateOutput),    // input
    .current_pc(PCOut)   // output
  );

  // ---------- Register File ----------
  RegisterFile reg_file(
    .reset(reset),        // input
    .clk(clk),          // input
    .rs1(IR[19:15]),          // input
    .rs2(IR[24:20]),          // input
    .rd(IR[11:7]),           // input
    .rd_din(RegWriteDataMuxOut),       // input
    .write_enable(WriteEnable),    // input
    .is_ecall(IsEcall), //input
    .rs1_dout(A),     // output
    .rs2_dout(B),      // output
    .print_reg(print_reg),     // output (TO PRINT REGISTER VALUES IN TESTBENCH)
    .is_halted(is_halted)        // output
  );

  // ---------- Memory ----------
  Memory memory(
    .reset(reset),        // input
    .clk(clk),          // input
    .addr(PCMemMuxOut),         // input
    .din(B),          // input
    .mem_read(MemRead),     // input
    .mem_write(MemWrite),    // input
    .dout(MemDataOut)          // output
  );

  always @(posedge clk) begin
    if(IRWrite)
      IR<=MemDataOut;
    ALUOut<=ALUResult;
    MDR<=MemDataOut;
  end

  // ---------- Control Unit ----------
  ControlUnit ctrl_unit(
    .reset(reset),        // input
    .clk(clk),          // input
    .op(IR[6:0]),  // input
    .isTaken(ALUBcond),  // input
    .is_jal(isJAL),        // output
    .is_jalr(isJALR),       // output
    .mem_read(MemRead),      // output
    .mem_to_reg(MemtoReg),    // output
    .mem_write(MemWrite),     // output
    .alu_srcA(ALUSrcA),       // output
    .alu_srcB(ALUSrcB),       // output
    .alu_control(ALUControl),       // output
    .write_enable(WriteEnable),     // output
    .pc_to_reg(PCtoReg),     // output
    .pc_source(PCSource),     // output
    .pc_write(PCWrite),     // output
    .pc_write_cond(PCWriteCond),     // output
    .i_or_d(IorD),     // output
    .ir_write(IRWrite),     // output
    .is_ecall(IsEcall)       // output (ecall inst)
  );

  // ---------- Immediate Generator ----------
  ImmediateGenerator imm_gen(
    .inst(IR),  // input
    .imm_gen_out(ImmGenOut)    // output
  );

  // ---------- ALU Control Unit ----------
  ALUControlUnit alu_ctrl_unit(
    .alu_control(ALUControl),  // input
    .opcode(IR[6:0]),  // input
    .funct3(IR[14:12]),  // input
    .funct7_5(IR[30]),  // input
    .alu_op(ALUOp),         // output
    .btype(btype)         // output
  );

  // ---------- ALU ----------
  ALU alu(
    .alu_op(ALUOp),      // input
    .btype(btype),      // input
    .alu_in_1(ALUInputOneMuxOut),    // input  
    .alu_in_2(ALUInputTwoMuxOut),    // input
    .alu_res(ALUResult),  // output
    .alu_bcond(ALUBcond)     // output
  );

  // modules
  twomux PC_mux(
    .x0(ALUResult),
    .x1(ALUOut),
    .sel(PCSource),
    .y(PCMuxOut)
  );
  twomux PC_mem_mux(
    .x0(PCOut),
    .x1(ALUOut),
    .sel(IorD),
    .y(PCMemMuxOut)
  );

  twomux ALU_input_mux_1(
    .x0(PCOut),
    .x1(A),
    .sel(ALUSrcA),
    .y(ALUInputOneMuxOut)
  );
  fourmux ALU_input_mux_2(
    .x0(B),
    .x1(32'b100),
    .x2(ImmGenOut),
    .x3(32'b0),
    .sel(ALUSrcB),
    .y(ALUInputTwoMuxOut)
  );
  twomux Reg_write_data_mux(
    .x0(ALUOut),
    .x1(MDR),
    .sel(MemtoReg),
    .y(RegWriteDataMuxOut)
  );
  andGate andGate(
    .x1(ALUBcond),
    .x2(PCWriteCond),
    .y(AndGateOutput)
  );
  orGate orGate(
    .x1(AndGateOutput),
    .x2(PCWrite),
    .y(OrGateOutput)
  );

endmodule

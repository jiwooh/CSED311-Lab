// Submit this file with other files you created.
// Do not touch port declarations of the module 'CPU'.

// Guidelines
// 1. It is highly recommened to `define opcodes and something useful.
// 2. You can modify modules (except InstMemory, DataMemory, and RegisterFile)
// (e.g., port declarations, remove modules, define new modules, ...)
// 3. You might need to describe combinational logics to drive them into the module (e.g., mux, and, or, ...)
// 4. `include files if required

module cpu(input reset,       // positive reset signal
           input clk,         // clock signal
           output is_halted, // Whehther to finish simulation
           output [31:0] print_reg [0:31]); // Whehther to finish simulation
    /***** Wire declarations *****/
    // 1. pc
    wire [31:0] pcOutput;

    // 2. InstMemory
    wire [31:0] imemOutput;

    // 3. RegisterFile
    wire [31:0] regfileOutputData1, regfileOutputData2;

    // 4. ControlUnit
    // wire is_jalr;
    // wire is_jal;
    // wire branch;
    wire mem_read;
    wire mem_to_reg;
    wire mem_write;
    wire ALU_src;
    wire reg_write; // = write_enable
    wire pc_to_reg;
    wire is_ecall;

    // 5. ImmediateGenerator
    wire [31:0] immgenOutput;

    // 6. ALUControlUnit
    wire [2:0] ALU_op;
    // wire [2:0] btype;

    // 7. ALU
    wire [31:0] ALUOutput;
    // wire ALU_bcond;

    // 8. DataMemory
    wire [31:0] dmemOutput;

    // etc.
    wire [31:0] adder1Output;
    // wire [31:0] adder2Output;
    // wire [31:0] twomux1Output;
    // wire [31:0] twomux2Output;
    wire [31:0] twomux3Output;
    // wire [31:0] twomux4Output;
    wire [31:0] twomux5Output;
    wire [4:0] twomux6Output; // 4bit mux
    // wire andGateOutput, orGateOutput;
    wire _is_halted;
    wire is_x17_10;
    wire is_hazard;

    // forwarding?

    /***** Register declarations *****/
    // TODO You need to modify the width of registers
    // In addition, 
    // 1. TODO You might need other pipeline registers that are not described below
    // 2. You might not need registers described below
    /***** IF/ID pipeline registers *****/
    reg [31:0] IF_ID_inst;           // will be used in ID stage

    /***** ID/EX pipeline registers *****/
    // From the control unit
    reg [2:0] ID_EX_alu_op;         // will be used in EX stage
    reg ID_EX_alu_src;        // will be used in EX stage
    reg ID_EX_mem_write;      // will be used in MEM stage
    reg ID_EX_mem_read;       // will be used in MEM stage
    reg ID_EX_mem_to_reg;     // will be used in WB stage
    reg ID_EX_reg_write;      // will be used in WB stage
    // From others
    reg [31:0] ID_EX_rs1_data;
    reg [31:0] ID_EX_rs2_data;
    reg [31:0] ID_EX_imm;
    reg [31:0] ID_EX_inst;
    reg [4:0] ID_EX_rd;
    reg ID_EX_is_halted;

    /***** EX/MEM pipeline registers *****/
    // From the control unit
    reg EX_MEM_mem_write;     // will be used in MEM stage
    reg EX_MEM_mem_read;      // will be used in MEM stage
    // reg EX_MEM_is_branch;     // will be used in MEM stage
    reg EX_MEM_mem_to_reg;    // will be used in WB stage
    reg EX_MEM_reg_write;     // will be used in WB stage
    // From others
    reg [31:0] EX_MEM_alu_out;
    reg [31:0] EX_MEM_dmem_data;
    reg [4:0] EX_MEM_rd;
    reg EX_MEM_is_halted;

    /***** MEM/WB pipeline registers *****/
    // From the control unit
    reg MEM_WB_mem_to_reg;    // will be used in WB stage
    reg MEM_WB_reg_write;     // will be used in WB stage
    // From others
    reg [31:0] MEM_WB_mem_to_reg_src_1;
    reg [31:0] MEM_WB_mem_to_reg_src_2;
    reg [4:0] MEM_WB_rd;
    reg MEM_WB_is_halted;

    // assign
    assign is_x17_10 = (regfileOutputData1 == 10) & (twomux6Output == 17);
    assign _is_halted = is_ecall & is_x17_10;
    assign is_halted = MEM_WB_is_halted;


    // ---------- Update program counter ----------
    // PC must be updated on the rising edge (positive edge) of the clock.
    PC pc(
        .reset(reset),       // input (Use reset to initialize PC. Initial value must be 0)
        .clk(clk),         // input
        .next_pc(adder1Output),     // input // twomux2Output
        .current_pc(pcOutput)   // output
    );

    // pc (& JAL/JALR) mux
    adder adder1(
        .x1(pcOutput),
        .x2(32'b100),
        .y(adder1Output)
    );

    // ---------- Instruction Memory ----------
    InstMemory imem(
        .reset(reset),   // input
        .clk(clk),     // input
        .addr(pcOutput),    // input
        .dout(imemOutput)     // output
    );

    // Update IF/ID pipeline registers here
    always @(posedge clk) begin
        if (reset) begin
            IF_ID_inst <= 0;
        end
        else if (!is_hazard) begin
            IF_ID_inst <= imemOutput;
        end
    end

    // ecall mux
    twomux4bit twomux6(
        .x0(IF_ID_inst[19:15]),
        .x1(17),
        .sel(is_ecall),
        .y(twomux6Output)
    );

    // ---------- Register File ----------
    RegisterFile reg_file (
        .reset (reset),        // input
        .clk (clk),          // input
        .rs1 (twomux6Output),          // input
        .rs2 (IF_ID_inst[24:20]),          // input
        .rd (IF_ID_inst[11:7]),           // input
        .rd_din (twomux5Output),       // input // twomux4Output
        .write_enable (reg_write),    // input
        .rs1_dout (regfileOutputData1),     // output
        .rs2_dout (regfileOutputData2),      // output
        .print_reg(print_reg)
    );


    // ---------- Control Unit ----------
    ControlUnit ctrl_unit (
        .part_of_inst(IF_ID_inst[6:0]),  // input
        .mem_read(mem_read),      // output
        .mem_to_reg(mem_to_reg),    // output
        .mem_write(mem_write),     // output
        .alu_src(ALU_src),       // output
        .write_enable(reg_write),  // output
        .pc_to_reg(pc_to_reg),     // output
        .is_ecall(is_ecall)       // output (ecall inst)
    );

    // ---------- Immediate Generator ----------
    ImmediateGenerator imm_gen(
        .inst(IF_ID_inst),  // input
        .imm_gen_out(immgenOutput)    // output
    );

    // Update ID/EX pipeline registers here
    always @(posedge clk) begin
        if (reset | is_hazard) begin
            ID_EX_alu_op <= 0;
            ID_EX_alu_src <= 0;
            ID_EX_mem_write <= 0;
            ID_EX_mem_read <= 0;
            ID_EX_mem_to_reg <= 0;
            ID_EX_reg_write <= 0;

            ID_EX_rs1_data <= 0;
            ID_EX_rs2_data <= 0;
            ID_EX_imm <= 0;
            ID_EX_inst <= 0;
            ID_EX_rd <= 0;
            ID_EX_is_halted <= 0;
        end
        else begin
            ID_EX_alu_op <= ALU_op;
            ID_EX_alu_src <= ALU_src;
            ID_EX_mem_write <= mem_write;
            ID_EX_mem_read <= mem_read;
            ID_EX_mem_to_reg <= mem_to_reg;
            ID_EX_reg_write <= reg_write;

            ID_EX_rs1_data <= regfileOutputData1;
            ID_EX_rs2_data <= regfileOutputData2;
            ID_EX_imm <= immgenOutput;
            ID_EX_inst <= IF_ID_inst;
            ID_EX_rd <= IF_ID_inst[11:7];
            ID_EX_is_halted <= _is_halted;
        end
    end
    
    // alu_in_2 mux
    twomux twomux3(
        .x0(regfileOutputData2),
        .x1(immgenOutput),
        .sel(ALU_src),
        .y(twomux3Output)
    );

    // ---------- ALU Control Unit ----------
    ALUControlUnit alu_ctrl_unit (
        .opcode(ID_EX_inst[6:0]),  // input
        .funct3(ID_EX_inst[14:12]),  // input
        .funct7_5(ID_EX_inst[30]),  // input
        .alu_op(ALU_op)// ,         // output
        // .btype(btype)         // output
    );

    // ---------- ALU ----------
    ALU alu (
        .alu_op(ALU_op),      // input
        .alu_in_1(ID_EX_rs1_data),    // input  // regfileOutputData1
        .alu_in_2(twomux3Output),    // input
        .alu_res(ALUOutput)//,  // output
        //.alu_zero()     // output
    );

    // Update EX/MEM pipeline registers here
    always @(posedge clk) begin
        if (reset) begin
            EX_MEM_mem_write <= 0;
            EX_MEM_mem_read <= 0;
            EX_MEM_mem_to_reg <= 0;
            EX_MEM_reg_write <= 0;

            EX_MEM_alu_out <= 0;
            EX_MEM_dmem_data <= 0;
            EX_MEM_rd <= 0;
            EX_MEM_is_halted <= 0;
        end
        else begin
            EX_MEM_mem_write <= ID_EX_mem_write;
            EX_MEM_mem_read <= ID_EX_mem_read;
            EX_MEM_mem_to_reg <= ID_EX_mem_to_reg;
            EX_MEM_reg_write <= ID_EX_reg_write;

            EX_MEM_alu_out <= ALUOutput;
            EX_MEM_dmem_data <= regfileOutputData2;
            EX_MEM_rd <= ID_EX_rd;
            EX_MEM_is_halted <= ID_EX_is_halted;
        end
    end

    // ---------- Data Memory ----------
    DataMemory dmem(
        .reset (reset),      // input
        .clk (clk),        // input
        .addr (EX_MEM_alu_out),       // input
        .din (EX_MEM_dmem_data),        // input
        .mem_read (EX_MEM_mem_read),   // input
        .mem_write (EX_MEM_mem_write),  // input
        .dout (dmemOutput)        // output
    );

    // Update MEM/WB pipeline registers here
    always @(posedge clk) begin
        if (reset) begin
            MEM_WB_mem_to_reg <= 0;
            MEM_WB_reg_write <= 0;
            MEM_WB_mem_to_reg_src_1 <= 0;
            MEM_WB_mem_to_reg_src_2 <= 0;
            MEM_WB_is_halted <= 0;
            MEM_WB_rd <= 0;
        end
        else begin
            MEM_WB_mem_to_reg <= EX_MEM_mem_to_reg;
            MEM_WB_reg_write <= EX_MEM_reg_write;
            MEM_WB_mem_to_reg_src_1 <= EX_MEM_alu_out;
            MEM_WB_mem_to_reg_src_2 <= dmemOutput;
            MEM_WB_is_halted <= EX_MEM_is_halted;
            MEM_WB_rd <= EX_MEM_rd;
        end
    end
    
    // register write mux
    twomux twomux5(
        .x0(ALUOutput),
        .x1(dmemOutput),
        .sel(mem_to_reg),
        .y(twomux5Output)
    );
    // does this belong here?

    // ---------- Other UNUSED Modules ----------
    
    // adder adder2(
    //     .x1(pcOutput),
    //     .x2(immgenOutput),
    //     .y(adder2Output)
    // );

    // twomux twomux1(
    //     .x0(adder1Output),
    //     .x1(adder2Output),
    //     .sel(orGateOutput),
    //     .y(twomux1Output)
    // );
    // twomux twomux2(
    //     .x0(twomux1Output),
    //     .x1(aluOutput),
    //     .sel(is_jalr),
    //     .y(twomux2Output)
    // );
    // twomux twomux4(
    //     .x0(twomux5Output),
    //     .x1(adder1Output),
    //     .sel(pc_to_reg),
    //     .y(twomux4Output)
    // );
    
    // andGate andGate(
    //     .x1(branch),
    //     .x2(alu_bcond),
    //     .y(andGateOutput)
    // );
    // orGate orGate(
    //     .x1(is_jal),
    //     .x2(andGateOutput),
    //     .y(orGateOutput)
    // );
    
endmodule

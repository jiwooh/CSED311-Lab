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
           output reg is_halted, // Whehther to finish simulation
           output [31:0] print_reg [0:31]); // Whehther to finish simulation
    /***** Wire declarations *****/
    // 1. pc
    wire [31:0] current_pc;

    // 2. InstMemory
    wire [31:0] imm;

    // 3. RegisterFile
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [31:0] regfileOutputData1;
    wire [31:0] regfileOutputData2;

    // 4. ControlUnit
    wire is_jalr;
    wire is_jal;
    wire branch;
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
    wire [2:0] btype;

    // 7. ALU
    wire [31:0] ALUOutput;
    wire ALU_bcond;

    // 8. DataMemory
    wire [31:0] dmemOutput;

    // etc.
    wire [31:0] adder1Output;
    wire [31:0] twomux3Output;
    wire [31:0] twomux5Output;
    wire [31:0] twomux7Output;
    wire [31:0] twomux8Output;
    wire _is_halted;
    wire is_x17_10;
    wire detection_is_hazard;
    wire is_hazard;

    // forwarding unit
    reg [31:0] alu_in_1_forwarded;
    reg [31:0] alu_in_2_forwarded;
    wire [1:0] forwardA;
    wire [1:0] forwardB;
    reg [31:0] rs1_dout_forwarded;
    reg [31:0] rs2_dout_forwarded;

    // 4-2
    // control flow
    wire is_flush;
    wire [31:0] write_data;
    // BTB
    reg is_miss;
    wire [31:0] pred_pc;
    reg [31:0] ID_EX_pred_pc;
    wire [4:0] BHSR;
    reg [31:0] correct_pc;

    // 5
    // Cache
    reg cache_is_output_valid;
    reg cache_is_ready;
    reg cache_is_hit;

    /***** Register declarations *****/
    // TODO You need to modify the width of registers
    // In addition, 
    // 1. TODO You might need other pipeline registers that are not described below
    // 2. You might not need registers described below
    /***** IF/ID pipeline registers *****/
    reg [31:0] IF_ID_inst;           // will be used in ID stage
    reg [31:0] IF_ID_pred_pc;
    reg [31:0] IF_ID_current_pc;
    reg [4:0] IF_ID_BHSR;

    /***** ID/EX pipeline registers *****/
    reg ID_EX_alu_src;        // will be used in EX stage
    reg ID_EX_mem_write;      // will be used in MEM stage
    reg ID_EX_mem_read;       // will be used in MEM stage
    reg ID_EX_mem_to_reg;     // will be used in WB stage
    reg ID_EX_reg_write;      // will be used in WB stage
    reg [31:0] ID_EX_rs1_data;
    reg [31:0] ID_EX_rs2_data;
    reg [31:0] ID_EX_imm;
    reg [31:0] ID_EX_inst;
    reg [4:0] ID_EX_rd;
    reg [4:0] ID_EX_rs1;
    reg [4:0] ID_EX_rs2;
    reg ID_EX_is_halted;
    reg ID_EX_is_jal;
    reg ID_EX_is_jalr;
    reg ID_EX_branch;
    reg ID_EX_pc_to_reg;
    reg [31:0] ID_EX_current_pc;
    reg [4:0] ID_EX_BHSR;

    /***** EX/MEM pipeline registers *****/
    // From the control unit
    reg EX_MEM_mem_write;     // will be used in MEM stage
    reg EX_MEM_mem_read;      // will be used in MEM stage
    reg EX_MEM_mem_to_reg;    // will be used in WB stage
    reg EX_MEM_reg_write;     // will be used in WB stage
    reg EX_MEM_alu_bcond;
    reg EX_MEM_branch;
    reg EX_MEM_is_jal;
    reg EX_MEM_is_jalr;
    reg EX_MEM_is_halted;
    reg EX_MEM_pc_to_reg;
    reg [31:0] EX_MEM_alu_out;
    reg [31:0] EX_MEM_dmem_data;
    reg [31:0] EX_MEM_current_pc;
    reg [31:0] EX_MEM_pred_pc;
    reg [31:0] EX_MEM_imm;
    reg [4:0] EX_MEM_rd;

    /***** MEM/WB pipeline registers *****/
    reg MEM_WB_mem_to_reg;    // will be used in WB stage
    reg MEM_WB_reg_write;     // will be used in WB stage
    reg [31:0] MEM_WB_mem_to_reg_src_1;
    reg [31:0] MEM_WB_mem_to_reg_src_2;
    reg [4:0] MEM_WB_rd;
    reg MEM_WB_is_halted;
    reg MEM_WB_pc_to_reg;
    reg [31:0] MEM_WB_current_pc;

    // assign
    assign rs2 = IF_ID_inst[24:20];
    assign is_x17_10 = (rs1_dout_forwarded == 10) & (rs1 == 17);
    assign _is_halted = is_ecall & is_x17_10;
    assign is_halted = MEM_WB_is_halted;
    assign is_flush = is_miss;
    assign is_hazard = detection_is_hazard | !cache_is_ready;

    // ---------- Update program counter ----------
    // PC must be updated on the rising edge (positive edge) of the clock.
    PC pc(
        .reset(reset),       // input (Use reset to initialize PC. Initial value must be 0)
        .clk(clk),         // input
        .pc_write((!(is_hazard&&!is_flush))), // do not write pc if hazard
        .next_pc(twomux8Output),     // input
        .current_pc(current_pc)   // output
    );

    // ---------- Instruction Memory ----------
    InstMemory imem(
        .reset(reset),   // input
        .clk(clk),     // input
        .addr(current_pc),    // input
        .dout(imm)     // output
    );

    // ---------- Hazard Detection ----------
    HazardDetection hazarddetection(
        .IF_ID_inst(IF_ID_inst),
        .ID_EX_rd(ID_EX_rd),
        .ID_EX_reg_write(ID_EX_reg_write),
        .ID_EX_mem_read(ID_EX_mem_read),
        .EX_MEM_rd(EX_MEM_rd),
        .EX_MEM_reg_write(EX_MEM_reg_write),
        .is_ecall(is_ecall),
        .is_hazard(detection_is_hazard)
    );

    // ecall mux
    twomux5bit twomux6(
        .x0(IF_ID_inst[19:15]),
        .x1(5'd17),
        .sel(is_ecall),
        .y(rs1)
    );

    // write data mux
    twomux twomux7(
        .x0(twomux5Output), // rd_din
        .x1(MEM_WB_current_pc + 4), // pc+4
        .sel(MEM_WB_pc_to_reg),
        .y(write_data) // twomux7Output
    );

    // ---------- Register File ----------
    RegisterFile reg_file (
        .reset (reset),        // input
        .clk (clk),          // input
        .rs1 (rs1),          // input
        .rs2 (rs2),          // input
        .rd (MEM_WB_rd),           // input
        .rd_din (write_data),       // input
        .write_enable (MEM_WB_reg_write),    // input
        .rs1_dout (regfileOutputData1),     // output
        .rs2_dout (regfileOutputData2),      // output
        .print_reg(print_reg)
    );

    // ---------- ecall Forwarding ----------
    ForwardingEcall ecall_forwarding(
        .rs1(rs1),
        .rs2(rs2),
        .rd(MEM_WB_rd),
        .EX_MEM_rd(EX_MEM_rd),
        .is_ecall(is_ecall),
        .rd_din(twomux5Output),
        .rs1_dout(regfileOutputData1),
        .rs2_dout(regfileOutputData2),
        .EX_MEM_alu_out(EX_MEM_alu_out),
        .rs1_dout_forwarded(rs1_dout_forwarded),
        .rs2_dout_forwarded(rs2_dout_forwarded)
    );

    // ---------- Control Unit ----------
    ControlUnit ctrl_unit (
        .part_of_inst(IF_ID_inst[6:0]),  // input
        .is_jal(is_jal),        // output
        .is_jalr(is_jalr),       // output
        .branch(branch),       // output
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

    // ---------- Forawrding Unit ----------
    ForwardingUnit forwarding_unit(
        .opcode(ID_EX_inst[6:0]),
        .rs1(ID_EX_rs1),
        .rs2(ID_EX_rs2),
        .dist1_rd(EX_MEM_rd),
        .dist1_reg_write(EX_MEM_reg_write),
        .dist2_rd(MEM_WB_rd),
        .dist2_reg_write(MEM_WB_reg_write),
        .forwardA(forwardA),
        .forwardB(forwardB)
    );
    
    // register write mux
    twomux twomux5(
        .x0(MEM_WB_mem_to_reg_src_1),
        .x1(MEM_WB_mem_to_reg_src_2),
        .sel(MEM_WB_mem_to_reg),
        .y(twomux5Output)
    );
    
    // rs1 forwarding mux
    threemux threemux1(
        .x0(ID_EX_rs1_data),
        .x1(EX_MEM_pc_to_reg ? EX_MEM_current_pc + 4 : 
            (EX_MEM_mem_to_reg? dmemOutput: EX_MEM_alu_out)),
        .x2(write_data),
        .sel(forwardA),
        .y(alu_in_1_forwarded)
    );

    // rs2 forwarding mux
    threemux threemux2(
        .x0(ID_EX_rs2_data),
        .x1(EX_MEM_pc_to_reg ? EX_MEM_current_pc + 4 : 
            (EX_MEM_mem_to_reg? dmemOutput: EX_MEM_alu_out)),
        .x2(write_data),
        .sel(forwardB),
        .y(alu_in_2_forwarded)
    );

    // alu_in_2 mux
    twomux twomux3(
        .x0(alu_in_2_forwarded),
        .x1(ID_EX_imm),
        .sel(ID_EX_alu_src),
        .y(twomux3Output)
    );

    // ---------- ALU Control Unit ----------
    ALUControlUnit alu_ctrl_unit (
        .opcode(ID_EX_inst[6:0]),  // input
        .funct3(ID_EX_inst[14:12]),  // input
        .funct7_5(ID_EX_inst[30]),  // input
        .alu_op(ALU_op),         // output
        .btype(btype)         // output
    );

    // ---------- ALU ----------
    ALU alu (
        .alu_op(ALU_op),      // input
        .btype(btype),      // input
        .alu_in_1(alu_in_1_forwarded),    // input  // regfileOutputData1
        .alu_in_2(twomux3Output),    // input // regfileOutputData2
        .alu_res(ALUOutput),  // output
        .alu_bcond(ALU_bcond)//,  // output
    );

    //---------- Data Memory ----------
    // DataMemory_old dmem(
    //     .reset (reset),      // input
    //     .clk (clk),        // input
    //     .addr (EX_MEM_alu_out),       // input
    //     .din (EX_MEM_dmem_data),        // input
    //     .mem_read (EX_MEM_mem_read),   // input
    //     .mem_write (EX_MEM_mem_write),  // input
    //     .dout (dmemOutput)        // output
    // );
    
    Cache cache(
        //input
        .reset (reset),
        .clk (clk), 
        .is_input_valid (EX_MEM_mem_read | EX_MEM_mem_write),
        .addr(EX_MEM_alu_out),
        .mem_rw(EX_MEM_mem_read && !EX_MEM_mem_write ? 0:
                (!EX_MEM_mem_read && EX_MEM_mem_write ? 1:0)),
        .din(EX_MEM_dmem_data),
        //output
        .is_ready(cache_is_ready),
        .is_output_valid(cache_is_output_valid),
        .dout(dmemOutput),
        .is_hit(cache_is_hit)
    );

    
    // ---------- BTB ----------
    BTB btb_(
        .pc(current_pc),
        .reset(reset),
        .clk(clk),
        .real_pc(ID_EX_current_pc),
        .pc_plus_imm(ID_EX_current_pc + ID_EX_imm),
        .reg_plus_imm(ALUOutput),
        .real_pc_BHSR(ID_EX_BHSR),
        .alu_bcond(ALU_bcond),
        .branch(ID_EX_branch),
        .is_jal(ID_EX_is_jal),
        .is_jalr(ID_EX_is_jalr),
        .pred_pc(pred_pc),
        .BHSR(BHSR)
    );

    twomux twomux8(
        .x0(pred_pc),
        .x1(correct_pc),
        .sel(is_miss),
        .y(twomux8Output)
    );

    //calc correct pc
    always @(*) begin
        is_miss=0;
        if ((EX_MEM_branch && EX_MEM_alu_bcond) || EX_MEM_is_jal) begin
            correct_pc = EX_MEM_current_pc + EX_MEM_imm; // pc + imm
            is_miss = pred_pc != correct_pc;
        end
        else if (EX_MEM_is_jalr) begin
            correct_pc = EX_MEM_alu_out; // reg + imm
            is_miss = pred_pc != correct_pc;
        end
        else begin
            correct_pc = EX_MEM_current_pc + 4;
        end
    end

    // Update IF/ID pipeline registers here
    always @(posedge clk) begin
        if (reset || is_flush) begin
            IF_ID_inst <= 0;
            IF_ID_current_pc <= 0;
            IF_ID_BHSR <= 0;
            IF_ID_pred_pc <= 0; 
        end
        else if (!is_hazard) begin
            IF_ID_inst <= imm;
            IF_ID_current_pc <= current_pc;
            IF_ID_BHSR <= BHSR;
            IF_ID_pred_pc <= pred_pc;
            
        end
    end

    // Update ID/EX pipeline registers here
    always @(posedge clk) begin
        if (reset | is_flush) begin
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
            ID_EX_rs1 <= 0;
            ID_EX_rs2 <= 0;
            ID_EX_is_jal <= 0;
            ID_EX_is_jalr <= 0;
            ID_EX_branch <= 0;
            ID_EX_pc_to_reg <= 0;
            ID_EX_current_pc <= 0;
            ID_EX_pred_pc <= 0;
            ID_EX_BHSR <= 0;
        end
        else begin
            ID_EX_alu_src <= ALU_src;
            ID_EX_mem_write <= mem_write;
            ID_EX_mem_read <= mem_read;
            ID_EX_mem_to_reg <= mem_to_reg;
            ID_EX_reg_write <= reg_write;
            ID_EX_rs1_data <= rs1_dout_forwarded;
            ID_EX_rs2_data <= rs2_dout_forwarded;
            ID_EX_imm <= immgenOutput;
            ID_EX_inst <= IF_ID_inst;
            ID_EX_rd <= IF_ID_inst[11:7];
            ID_EX_is_halted <= _is_halted;
            ID_EX_rs1 <= rs1;
            ID_EX_rs2 <= rs2;
            ID_EX_is_jal <= is_jal;
            ID_EX_is_jalr <= is_jalr;
            ID_EX_branch <= branch;
            ID_EX_pc_to_reg <= pc_to_reg;
            ID_EX_current_pc <= IF_ID_current_pc;
            ID_EX_pred_pc <= IF_ID_pred_pc;
            ID_EX_BHSR <= IF_ID_BHSR;
        end
        if (is_hazard) begin
            ID_EX_reg_write <= 0;
            ID_EX_mem_write <= 0;
            ID_EX_mem_read <= 0;
            ID_EX_rd <= 5'b0;
        end
    end

    // Update EX/MEM pipeline registers here
    always @(posedge clk) begin
        if (reset | is_flush) begin
            EX_MEM_mem_write <= 0;
            EX_MEM_mem_read <= 0;
            EX_MEM_mem_to_reg <= 0;
            EX_MEM_reg_write <= 0;
            EX_MEM_alu_out <= 0;
            EX_MEM_alu_bcond <= 0;
            EX_MEM_branch <= 0;
            EX_MEM_dmem_data <= 0;
            EX_MEM_rd <= 0;
            EX_MEM_is_halted <= 0;
            EX_MEM_is_jal <= 0;
            EX_MEM_is_jalr <= 0;
            EX_MEM_pc_to_reg <= 0;
            EX_MEM_current_pc <= 0;
        end
        else begin
            EX_MEM_mem_write <= ID_EX_mem_write;
            EX_MEM_mem_read <= ID_EX_mem_read;
            EX_MEM_mem_to_reg <= ID_EX_mem_to_reg;
            EX_MEM_reg_write <= ID_EX_reg_write;
            EX_MEM_alu_out <= ALUOutput;
            EX_MEM_alu_bcond <= ALU_bcond;
            EX_MEM_branch <= ID_EX_branch;
            EX_MEM_dmem_data <= alu_in_2_forwarded;
            EX_MEM_rd <= ID_EX_rd;
            EX_MEM_is_halted <= ID_EX_is_halted;
            EX_MEM_is_jal <= ID_EX_is_jal;
            EX_MEM_is_jalr <= ID_EX_is_jalr;
            EX_MEM_pc_to_reg <= ID_EX_pc_to_reg;
            EX_MEM_current_pc <= ID_EX_current_pc;
            EX_MEM_pred_pc <= ID_EX_pred_pc;
            EX_MEM_imm <= ID_EX_imm;
        end
        if (!cache_is_ready) begin
            EX_MEM_reg_write <= 0;
            EX_MEM_mem_write <= 0;
            EX_MEM_mem_read <= 0;
            EX_MEM_rd <= 5'b0;
        end
    end

    // Update MEM/WB pipeline registers here
    always @(posedge clk) begin
        if (reset) begin
            MEM_WB_mem_to_reg <= 0;
            MEM_WB_reg_write <= 0;
            MEM_WB_mem_to_reg_src_1 <= 0;
            MEM_WB_mem_to_reg_src_2 <= 0;
            MEM_WB_is_halted <= 0;
            MEM_WB_rd <= 0;
            MEM_WB_pc_to_reg <= 0;
            MEM_WB_current_pc <= 0;
        end
        else begin
            MEM_WB_mem_to_reg <= EX_MEM_mem_to_reg;
            MEM_WB_reg_write <= EX_MEM_reg_write;
            MEM_WB_mem_to_reg_src_1 <= EX_MEM_alu_out;
            MEM_WB_mem_to_reg_src_2 <= dmemOutput;
            MEM_WB_is_halted <= EX_MEM_is_halted;
            MEM_WB_rd <= EX_MEM_rd;

            MEM_WB_pc_to_reg <= EX_MEM_pc_to_reg;
            MEM_WB_current_pc <= EX_MEM_current_pc;
        end
    end


endmodule

`include "opcodes.v"

module HazardDetection(input [31:0] IF_ID_inst,
                        input [4:0] ID_EX_rd,
                        input ID_EX_reg_write,
                        input ID_EX_mem_read,
                        input [4:0] EX_MEM_rd,
                        input EX_MEM_reg_write,
                        input is_ecall,
                        output reg is_hazard);

    wire [4:0] IF_ID_rs1 = IF_ID_inst[19:15];
    wire [4:0] IF_ID_rs2 = IF_ID_inst[24:20];
    wire [6:0] IF_ID_opcode = IF_ID_inst[6:0];

    always @(*) begin
        is_hazard = 0;

        // ecall hazard check
        if (is_ecall) begin // (IF_ID_opcode == `ECALL) begin
            if (ID_EX_rd == 17 && ID_EX_reg_write || EX_MEM_rd == 17 && EX_MEM_reg_write) begin
                is_hazard = 1;
            end else begin
                is_hazard = 0;
            end
        end

        // rs1 hazard check
        if (IF_ID_opcode == `ARITHMETIC || IF_ID_opcode == `ARITHMETIC_IMM || IF_ID_opcode == `LOAD || IF_ID_opcode == `STORE) begin
            if (IF_ID_rs1 == ID_EX_rd && ID_EX_rd != 0 && ID_EX_mem_read) begin
                is_hazard = 1;
            end else begin
                is_hazard = 0;
            end
        end

        // rs2 hazard check
        if (is_hazard == 1) begin
            // skip rs2 hazard check if rs1 hazard is detected
        end else if (IF_ID_opcode == `ARITHMETIC || IF_ID_opcode == `LOAD || IF_ID_opcode == `STORE) begin
            if (IF_ID_rs2 == ID_EX_rd && ID_EX_rd != 0 && ID_EX_mem_read) begin
                is_hazard = 1;
            end else begin
                is_hazard = 0;
            end
        end
    end

endmodule

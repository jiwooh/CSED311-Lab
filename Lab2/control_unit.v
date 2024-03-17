`include "opcodes.v"

module control_unit(
    input [6:0] part_of_inst,
    output is_jal,
    output is_jalr,
    output branch,
    output mem_read,
    output mem_to_reg,
    output mem_write,
    output alu_src,
    output write_enable,
    output pc_to_reg,
    output is_ecall
);

always @(*) begin
    is_jal = (part_of_inst == `JAL);
    is_jalr = (part_of_inst == `JALR);
    branch = (part_of_inst == `BRANCH);
    mem_read = (part_of_inst == `LOAD);
    mem_to_reg = (part_of_inst == `LOAD);
    mem_write = (part_of_inst == `STORE);
    alu_src = (part_of_inst != `ARITHMETIC && part_of_inst != `BRANCH);
    write_enable = (part_of_inst != `STORE && part_of_inst != `BRANCH);
    pc_to_reg = (part_of_inst == `JAL || part_of_inst == `JALR);
    is_ecall = (part_of_inst == `ECALL);
end

endmodule

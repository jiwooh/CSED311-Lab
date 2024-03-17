`include "opcode.v"
module immediate_generator(
    input [31:0] part_of_inst,
    output reg signed [31:0] imm_gen_out
);


always @(*) begin
    imm_gen_out = 0;
    case (part_of_inst[6:0]) // opcode
        `ARITHMETIC_IMM, `LOAD, `JALR: begin
            imm_gen_out = {{20{part_of_inst[31]}}, part_of_inst[31:20]};
        end
        `STORE: begin
            imm_gen_out = {{20{part_of_inst[31]}}, part_of_inst[31:25], part_of_inst[11:7]};
        end
        `JAL: begin
            imm_gen_out = {{12{part_of_inst[31]}}, part_of_inst[19:12], part_of_inst[20], part_of_inst[30:21], 1'b0};
        end
        `BRANCH: begin
            imm_gen_out = {{20{part_of_inst[31]}}, part_of_inst[7], part_of_inst[30:25], part_of_inst[11:8], 1'b0};
        end
    endcase
end

endmodule

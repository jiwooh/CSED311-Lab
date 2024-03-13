`include "opcodes.v"

module immediate_generator(
    input [31:0] inst,  // input
    output reg signed [31:0] imm_gen_out    // output
  );
integer i;
initial begin
	imm_gen_out = 0;
end   	

always @(*) begin
    imm_gen_out=0;
    case(inst[6:0])
        `ARITHMETIC_IMM, `LOAD, `JALR: begin
            imm_gen_out[11:0] = inst[31:20];
            for (i = 12; i<32; i=i+1) begin
                imm_gen_out[i] = inst[31];
            end
        end
        `STORE: begin
            imm_gen_out[11:5] = inst[31:25];
            imm_gen_out[4:0] = inst[11:7];
            for (i = 12; i<32; i=i+1) begin
                imm_gen_out[i] = inst[31];
            end
        end
        `BRANCH: begin
            imm_gen_out[12] = inst[31];
            imm_gen_out[10:5] = inst[30:25];
            imm_gen_out[4:1] = inst[11:8];
            imm_gen_out[11] = inst[7];
            imm_gen_out[0] = 0;
            for (i = 13; i<32; i=i+1) begin
                imm_gen_out[i] = inst[31];
            end
        end
        `JAL: begin
            imm_gen_out[20] = inst[31];
            imm_gen_out[10:1] = inst[30:21];
            imm_gen_out[11] = inst[20];
            imm_gen_out[19:12] = inst[19:12];
            imm_gen_out[0] = 0;
            for (i = 21; i<32; i=i+1) begin
                imm_gen_out[i] = inst[31];
            end
        end
        default: imm_gen_out = 0;
    endcase
  end

endmodule

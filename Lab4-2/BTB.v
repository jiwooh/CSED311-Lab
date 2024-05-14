module BTB (
    input [31:0] pc,
    input reset,
    input clk,
    input [31:0] real_pc,
    input [31:0] pc_plus_imm,  // for branch & jal
    input [31:0] reg_plus_imm, // for jalr
    input [4:0] real_pc_BHSR,
    input alu_bcond,
    input branch,
    input is_jal,
    input is_jalr,
    output reg [31:0] pred_pc,
    output reg [4:0] BHSR
);

    // tag table + btb + pht
    integer idx;
    reg [31:0] tag_table [0:31];
    reg [31:0] btb       [0:31]; // 32 entry btb
    reg [1:0]  pht       [0:31]; // 2-bit prediction

    // input query
    wire [31:0] query_tag;
    wire [4:0]  query_idx;
    // real pc
    wire [4:0]  real_pc_idx;
    wire [31:0] real_pc_tag;
    wire taken;

    assign query_tag = pc[31:0];
    assign query_idx = pc[6:2] ^ BHSR;

    assign real_pc_tag = real_pc[31:0];
    assign real_pc_idx = real_pc[6:2] ^ real_pc_BHSR;

    assign taken = (branch & alu_bcond) | is_jal | is_jalr;

    // to fix UNOPTFLAT error
    reg [4:0] BHSR_tmp;
    assign BHSR = (BHSR_tmp << 1) + {4'b0, taken};

    reg [31:0] dest; // temporary wire for convenience

    // 1. initialization
    initial begin 
        BHSR_tmp = BHSR;
    end
    always @(posedge clk) begin
        if (reset) begin
            for (idx = 0; idx <= 31; idx = idx + 1) begin
                btb[idx] <= 0; // empty btb
                tag_table[idx] <= -1; // invalid tag
                pht[idx] <= 2'b00;
            end
        end
        // TODO ERROR FIXED? : Blocked and non-blocking assignments to same variable [BHSR]
        BHSR_tmp <= 0;
    end

    // 2. real pc calculation
    always @(*) begin
        tag_table[real_pc_idx] = 0;
        btb[real_pc_idx] = 0;
        dest = 0;
        if (is_jal | branch) begin // destination = pc + imm
            dest = pc_plus_imm;
        end else if (is_jalr) begin // destination = reg + imm
            dest = reg_plus_imm;
        end

        if (real_pc_tag != tag_table[real_pc_idx] | dest != btb[real_pc_idx]) begin
            tag_table[real_pc_idx] = real_pc_tag;
            btb[real_pc_idx] = dest;
        end
    end

    // 3. pht : 2-bit prediction
    always @(*) begin
        pht[real_pc_idx] = 0;
        if (branch | is_jal | is_jalr) begin 
            if (taken) begin
                case (pht[real_pc_idx])
                    2'b00: pht[real_pc_idx] = 2'b01;
                    2'b01: pht[real_pc_idx] = 2'b10;
                    2'b10: pht[real_pc_idx] = 2'b11;
                    2'b11: pht[real_pc_idx] = 2'b11;
                endcase
            end else begin // not taken
                case (pht[real_pc_idx])
                    2'b00: pht[real_pc_idx] = 2'b00;
                    2'b01: pht[real_pc_idx] = 2'b00;
                    2'b10: pht[real_pc_idx] = 2'b01;
                    2'b11: pht[real_pc_idx] = 2'b10;
                endcase
            end
        end
    end

    // 4. finally check "taken?"
    always @(*) begin
        // if ((query_tag == tag_table[query_idx]) & (pht[query_idx] >= 2'b10)) begin
        //     pred_pc = btb[query_idx];
        // end else begin
            pred_pc = pc + 4;
        // end
    end
endmodule

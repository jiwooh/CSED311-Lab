module pc(  input reset,
            input clk,
            input [31:0] next_pc,
            output [31:0] current_pc);
            
  
  always @(posedge clk) begin
    // Reset register file
    if (reset) begin
      for (i = 0; i < 32; i = i + 1)
        // DO NOT TOUCH COMMENT BELOW
        /* verilator lint_off BLKSEQ */
        current_pc[i] = 32'b0;
        /* verilator lint_on BLKSEQ */
        // DO NOT TOUCH COMMENT ABOVE
    end
    else begin
        current_pc <= next_pc;
    end
  end
endmodule

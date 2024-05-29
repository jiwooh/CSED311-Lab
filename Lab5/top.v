// Do not submit this file.
`include "cpu.v"

module top(input reset,
           input clk,
           output is_halted,
           output integer total_count,
           output integer miss_count,
           output [31:0] print_reg [0:31]);

  cpu cpu(
    .reset(reset), 
    .clk(clk),
    .is_halted(is_halted),
    .total_count(total_count),
    .miss_count(miss_count),
    .print_reg(print_reg)
  );

endmodule

module CacheBank #(parameter LINE_SIZE = 16,
               parameter NUM_SETS = /* Your choice */
               parameter NUM_WAYS = 2) (
    input reset,
    input clk,

    input [31:0] addr,

    output tag,
    output valid,
    output [1:0]data,
    output is_hit);
  // Wire declarations
  wire is_data_mem_ready;
  // Reg declarations
  // You might need registers to keep the status.
  
  // C = 256 -> logC = 10
  // a = 2 
  // B = 16 -> block offset = log(B/G) = 2 bit
  // G = 4 -> 2 bit [1:0]
  // C/a/B = 8 -> set index= 3 bit
  wire set_index;
  wire block_offset;
  assign set_index = addr[6:4];
  assign block_offset = addr[3:2];
  // byte offset : [1:0]
  // Instantiate data memory
  DataMemory #(.BLOCK_SIZE(LINE_SIZE)) data_mem(
    .reset(reset),
    .clk(clk),

    .is_input_valid(),
    .addr((addr>>(CLOG2(LINE_SIZE))),        // NOTE: address must be shifted by CLOG2(LINE_SIZE)
    .mem_read(mem_rw == 0),
    .mem_write(mem_rw == 1)),
    .din(din),

    // is output from the data memory valid?
    .is_output_valid(is_output_valid),
    .dout(dout),
    // is data memory ready to accept request?
    .mem_ready(is_data_mem_ready)
  );
endmodule

`include "CLOG2.v"

module Cache #(parameter LINE_SIZE = 16//,
               //parameter NUM_SETS = 8,
               ) ( //parameter NUM_WAYS = 2) (
    input reset,
    input clk,

    input is_input_valid,
    input [31:0] addr,
    input mem_rw,
    input [31:0] din,

    output is_ready,
    output is_output_valid,
    output [31:0] dout,
    output is_hit);
  // Wire declarations
  wire is_data_mem_ready;
  wire bank_index;

  reg [7:0] bank_older_one;

  wire [127:0] dmem_output_set;
  wire [127:0] bank_output_set;
  wire [127:0] bank_output_set_1;
  wire [127:0] bank_output_set_2;
  wire [31:0] bank_output_line;
  wire [31:0] bank_output_line_1;
  wire [31:0] bank_output_line_2;
  wire bank_is_hit_1;
  wire bank_is_hit_2;
  wire bank_data_replaced_1;
  wire bank_data_replaced_2;
  wire bank_data_is_dirty_1;
  wire bank_data_is_dirty_2;
  wire bank_dmem_read_1;
  wire bank_dmem_read_2;
  wire bank_dmem_write_1;
  wire bank_dmem_write_2;
  wire bank_select_1;
  wire bank_select_2;
  // Reg declarations
  // You might need registers to keep the status.
  assign is_ready = is_data_mem_ready;
  assign is_hit = bank_is_hit_1 || bank_is_hit_2;
  assign dout = bank_select_1? bank_output_line_1:
                (bank_select_2? bank_output_line_2:0);

  CacheBank bank1 (
    .reset(reset),
    .clk(clk),
    .mem_rw(mem_rw),
    .addr(addr),
    .data_ready(is_output_valid),
    .bank_is_old(~bank_older_one), //older one == 0 -> old
    .input_set(dmem_output_set), //128 bit
    .input_line(din), //32 bit
    .output_set(bank_output_set_1), //128 bit
    .output_line(bank_output_line_1), // 32 bit
    .data_replaced(bank_data_replaced_1),
    .data_is_dirty(bank_data_is_dirty_1),
    .dmem_read(bank_dmem_read_1),
    .dmem_write(bank_dmem_write_1),
    .is_selected(bank_select_1),
    .is_hit(bank_is_hit_1)
  );
  CacheBank bank2 (
    .reset(reset),
    .clk(clk),
    .mem_rw(mem_rw),
    .addr(addr),
    .data_ready(is_output_valid),
    .bank_is_old(bank_older_one),//younger one == 0 -> not old
    .input_set(dmem_output_set), //128 bit
    .input_line(din), //32 bit
    .output_set(bank_output_set_2), //128 bit
    .output_line(bank_output_line_2), // 32 bit
    .data_replaced(bank_data_replaced_2),
    .data_is_dirty(bank_data_is_dirty_2),
    .dmem_read(bank_dmem_read_2),
    .dmem_write(bank_dmem_write_2),
    .is_selected(bank_select_2),
    .is_hit(bank_is_hit_2)
  );


  //bank control
  assign bank_output_set = 
    bank_data_is_dirty_1 ?
     (bank_data_is_dirty_2? 0:bank_output_set_1):(bank_data_is_dirty_2? bank_output_set_2:0);
  integer i;
  always @(posedge clk) begin
    // Initialize data memory
    if (reset) begin
      for (i = 0; i < 8; i = i + 1) begin
        /* verilator lint_off BLKSEQ */
        bank_older_one[i] <= 0;
        /* verilator lint_on BLKSEQ */
      end
    end
    if(bank_data_replaced_1 && !bank_data_replaced_2) begin
      bank_older_one[addr[6:4]] <= 1;
    end
    else if(!bank_data_replaced_1 && bank_data_replaced_2) begin
      bank_older_one[addr[6:4]] <= 0;
    end
  end

  // Instantiate data memory
  DataMemory #(.BLOCK_SIZE(LINE_SIZE)) data_mem(
    .reset(reset),
    .clk(clk),

    .is_input_valid((!bank_is_hit_1 || !bank_is_hit_2) && is_input_valid),
    .addr((addr>>(`CLOG2(LINE_SIZE)))),        // NOTE: address must be shifted by CLOG2(LINE_SIZE)
    .mem_read(bank_dmem_read_1 ^ bank_dmem_read_2),
    .mem_write(bank_dmem_write_1 ^ bank_dmem_write_2),
    .din(bank_output_set),

    // is output from the data memory valid?
    .is_output_valid(is_output_valid),
    .dout(dmem_output_set), //128 bit
    // is data memory ready to accept request?
    .mem_ready(is_data_mem_ready)
  );
endmodule

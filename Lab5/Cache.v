`include "CLOG2.v"
`include "cachestates.v"
module Cache #(parameter LINE_SIZE = 16//,
               //parameter NUM_SETS = 8,
               //parameter NUM_WAYS = 2
              ) (
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


  wire [127:0] dmem_output_set;
  wire [127:0] bank_output_set;
  wire [127:0] bank_output_set_1;
  wire [31:0] bank_output_line;
  wire [31:0] bank_output_line_1;
  wire [31:0] bank_write_back_addr_1;
  wire [31:0] dmem_addr;
  wire bank_is_hit_1;
  wire bank_data_replaced_1;
  wire bank_data_is_dirty_1;
  wire bank_dmem_read_1;
  wire bank_dmem_write_1;
  wire bank_select_1;
  wire data_write_back_complete;
  reg [1:0] bank_state_1;
  // Reg declarations
  // You might need registers to keep the status.
  assign is_ready = (bank_state_1==`CACHE_IDLE);//is_data_mem_ready && (!is_input_valid || (is_input_valid && is_hit));
  assign is_hit = bank_is_hit_1;
  assign dout = bank_output_line_1;

  CacheBank bank1 (
    .reset(reset),
    .clk(clk),
    .mem_rw(mem_rw),
    .addr(addr),
    .data_ready(is_output_valid),
    .is_input_valid(is_input_valid),
    .data_write_back_complete(data_write_back_complete),
    .input_set(dmem_output_set), //128 bit
    .input_line(din), //32 bit
    .output_set(bank_output_set_1), //128 bit
    .output_line(bank_output_line_1), // 32 bit
    .output_addr(bank_write_back_addr_1), // 32 bit
    .data_replaced(bank_data_replaced_1),
    .data_is_dirty(bank_data_is_dirty_1),
    .dmem_read(bank_dmem_read_1),
    .dmem_write(bank_dmem_write_1),
    .is_selected(bank_select_1),
    .cache_state(bank_state_1),
    .is_hit(bank_is_hit_1)
  );

  // bank control
  integer counter;
  integer request_counter;
  assign bank_output_set = bank_output_set_1;
  assign dmem_addr = (bank_state_1==`CACHE_WRITE_BACK_REQUEST)?
                     bank_write_back_addr_1:addr;
  assign data_write_back_complete = 
    (bank_state_1==`CACHE_WRITE_BACK_REQUEST) && is_data_mem_ready&&counter>5;

  // Instantiate data memory
  DataMemory #(.BLOCK_SIZE(LINE_SIZE)) data_mem(
    .reset(reset),
    .clk(clk),

    .is_input_valid(
      ((bank_state_1==`CACHE_WRITE_BACK_REQUEST)||(bank_state_1==`CACHE_WRITE_ALLOCATE_REQUEST)) 
      && is_input_valid
      && !bank_is_hit_1
      && !is_output_valid
      && request_counter<5),
    .addr((dmem_addr>>(`CLOG2(LINE_SIZE)))),        // NOTE: address must be shifted by CLOG2(LINE_SIZE)
    .mem_read(bank_dmem_read_1),
    .mem_write(bank_dmem_write_1),
    .din(bank_output_set),

    // is output from the data memory valid?
    .is_output_valid(is_output_valid),
    .dout(dmem_output_set), //128 bit
    // is data memory ready to accept request?
    .mem_ready(is_data_mem_ready)
  );

  always @(posedge clk) begin
    // Initialize data memory
    if (reset) begin
      counter <= 0;
      request_counter <= 0;
    end
    if(bank_state_1==`CACHE_WRITE_BACK_REQUEST&& is_input_valid) begin
      counter <= counter + 1;
      request_counter <= request_counter+1;
    end 
    else if(bank_state_1==`CACHE_WRITE_ALLOCATE_REQUEST&& is_input_valid) begin
      counter <=0;
      request_counter <= request_counter+1;
    end
    else begin
      counter <=0;
      request_counter <= 0;
    end
  end
endmodule

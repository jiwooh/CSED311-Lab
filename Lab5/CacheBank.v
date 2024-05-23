module CacheBank (
  // #(parameter LINE_SIZE = 16,
  //   parameter NUM_SETS = 8,
  //   parameter NUM_WAYS = 2) (
    input reset,
    input clk,
    input mem_rw,
    input [31:0] addr,
    input data_ready,
    input [7:0] bank_is_old,
    input [127:0] input_set,
    input [31:0] input_line,
    output reg [127:0] output_set,
    output [31:0] output_line,
    output reg data_replaced,
    output reg data_is_dirty,
    output reg dmem_read,
    output reg dmem_write,
    output reg is_selected,
    output is_hit);
  // Wire declarations
  // C = 256 bytes -> logC = 10
  // a = 2 
  // B = 16 byte (128 bit) -> block offset = log(B/G) = 2 bit
  // G = 4 byte-> byte offset = 2 bit [1:0]
  // C/a/B = 8 -> set index= 3 bit
  // t = 25 bit
  integer i;

  wire [24:0] inst_tag;
  wire [2:0] set_index;
  wire [1:0] block_offset;
  assign inst_tag = addr[31:7];
  assign set_index = addr[6:4];
  assign block_offset = addr[3:2];
  // byte offset : [1:0]

  reg [24:0] tag_bank [7:0];
  reg valid_bank [7:0];
  reg dirty_bank [7:0];
  reg [127:0] data_bank [7:0];

  wire [24:0] tag_out;
  wire valid_out;
  wire dirty_out;
  wire [127:0] data_out;
  assign tag_out = tag_bank[set_index];
  assign valid_out = valid_bank[set_index];
  assign dirty_out = dirty_bank[set_index];
  assign data_out = data_bank[set_index];

  DataMux datamux(
    .x0(data_out[31:0]),
    .x1(data_out[63:32]),
    .x2(data_out[95:64]),
    .x3(data_out[127:96]),
    .sel(block_offset),
    .y(output_line)
  );
  assign is_hit = (inst_tag == tag_out) && valid_out;
  
  always @(posedge clk) begin
    // Initialize data memory
    if (reset) begin
      data_replaced <= 0;
      data_is_dirty <= 0;
      for (i = 0; i < 8; i = i + 1) begin
        /* verilator lint_off BLKSEQ */
        tag_bank[i] <= 0;
        valid_bank[i] <= 0;
        dirty_bank[i] <= 0;
        data_bank[i] <= 0;
        /* verilator lint_on BLKSEQ */
      end
    end

    if (mem_rw == 1) begin // write
      if (is_hit) begin // write hit -> write-allocate
        dmem_read <= 0;
      end
      else begin // write miss -> write-back
        if (bank_is_old[set_index]) begin
          dmem_read <= 1;
          // request data
          // data_replaced <=1; 
          if (dirty_bank[set_index] == 1) begin //replace
            output_set <= data_bank[set_index];
            data_is_dirty <= 1;
            dmem_write <= 1;
          end
          else data_is_dirty <= 0;
          if (data_ready) begin
            // get data from mem
            data_bank[set_index] <= input_set;
            tag_bank[set_index] <= inst_tag;
            valid_bank[set_index] <= 1;
            dirty_bank[set_index] <= 0;
            data_replaced <= 1;
            dmem_write <= 0;
          end
        end
      end
      // write-allocate
      dirty_bank[set_index] <= 1;
      case (block_offset)
        0: begin
          data_bank[set_index][31:0] <= input_line;
        end
        1: begin
          data_bank[set_index][63:32] <= input_line;
        end
        2: begin
          data_bank[set_index][95:64] <= input_line;
        end
        3: begin
          data_bank[set_index][127:96] <= input_line;
        end
      endcase
    end else begin // read
      if (is_hit) begin // read hit 
        dmem_read <= 0;
      end
      else begin // read miss
        if (bank_is_old[set_index]) begin
          dmem_read <= 1;
          // request data
          // data_replaced <=1;
          if (data_ready) begin
            if (dirty_bank[set_index] == 1) begin //replace
              output_set <= data_bank[set_index];
              data_is_dirty <= 1;
              dmem_write <= 1;
            end
            else data_is_dirty <= 0;
            // get data from mem
            data_bank[set_index] <= input_set;
            tag_bank[set_index] <= inst_tag;
            valid_bank[set_index] <= 1;
            dirty_bank[set_index] <= 0;
            data_replaced <= 1;
            dmem_write <= 0;
          end
        end
      end
    end   
  end
endmodule

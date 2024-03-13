module data_memory #(parameter MEM_DEPTH = 16384) 
  (
    input reset,
    input clk,
    input is_ecall,
    input [31:0] addr,    // address of the data memory
    input [31:0] din,     // data to be written
    input mem_read,       // is read signal driven?
    input mem_write,      // is write signal driven?
    output reg [31:0] dout, // output of the data memory at addr
    output reg is_halted
    ); 
  
  integer i;
  // Data memory
  reg [31:0] mem[0: MEM_DEPTH - 1];
  // Do not touch dmem_addr
  wire [13:0] dmem_addr;
  assign dmem_addr = addr[15:2];
  // Do not touch or use _unused_ok
  wire _unused_ok = &{1'b0,
                  addr[31:16],
                  addr[1:0],
                  1'b0};

  // TODO
  // (use dmem_addr to access memory)
  // Asynchrnously read data from the memory
  always @(*) begin
      if(mem_read==1 && mem_write==0) begin
        dout = mem[dmem_addr];
      end
      else begin
        dout = 0;
      end
      if(is_ecall) begin
        is_halted = (mem[17]==10);
      end
      else begin
        is_halted = 0;
      end
  end

  // Synchronously write data to the memory
  always @(posedge clk) begin
        if (mem_write==1 && mem_read==0) begin
            mem[dmem_addr] <= din;
        end
  end


  // Initialize data memory (do not touch)
  always @(posedge clk) begin
    if (reset) begin
      for (i = 0; i < MEM_DEPTH; i = i + 1)
        // DO NOT TOUCH COMMENT BELOW
        /* verilator lint_off BLKSEQ */
        mem[i] = 32'b0;
        /* verilator lint_on BLKSEQ */
        // DO NOT TOUCH COMMENT ABOVE
    end
  end
endmodule



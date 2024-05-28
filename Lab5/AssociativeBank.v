`include "cachestates.v"
module AssociativeBank (
    input reset,
    input stall,
    input clk,
    input mem_rw,
    input [31:0] addr,
    input data_ready,
    input is_input_valid,
    input data_write_back_complete,
    input [127:0] input_set,
    input [31:0] input_line,
    output reg [127:0] output_set,
    output [31:0] output_line,
    output [31:0] output_addr,
    output reg dmem_read,
    output reg dmem_write,
    output reg [1:0] cache_state,
    output is_hit);

    integer i;


    wire [127:0] output_set_1;
    wire [31:0] output_line_1;
    wire [31:0] output_addr_1;
    wire is_hit_1;
    wire dmem_read_1;
    wire dmem_write_1;
    wire [1:0] cache_state_1;

    wire [127:0] output_set_2;
    wire [31:0] output_line_2;
    wire [31:0] output_addr_2;
    wire is_hit_2;
    wire dmem_read_2;
    wire dmem_write_2;
    wire [1:0] cache_state_2;

    reg active_bank;
    
    assign output_set = active_bank==0? output_set_1:output_set_2;
    assign output_line = active_bank==0? output_line_1:output_line_2;
    assign output_addr = active_bank==0? output_addr_1:output_addr_2;
    assign dmem_read = active_bank==0? dmem_read_1:dmem_read_2;
    assign dmem_write = active_bank==0? dmem_write_1:dmem_write_2;
    assign cache_state = active_bank==0? cache_state_1:cache_state_2;
    assign is_hit = is_hit_1 || is_hit_2; //active_bank==0? is_hit_1:is_hit_2;

    CacheBank bank1 (
        .bank_active(active_bank==0),
        .reset(reset),
        .clk(clk),
        .mem_rw(mem_rw),
        .addr(addr),
        .data_ready(data_ready),
        .is_input_valid(is_input_valid),
        .data_write_back_complete(data_write_back_complete),
        .input_set(input_set), //128 bit
        .input_line(input_line), //32 bit
        .output_set(output_set_1), //128 bit
        .output_line(output_line_1), // 32 bit
        .output_addr(output_addr_1), // 32 bit
        .dmem_read(dmem_read_1),
        .dmem_write(dmem_write_1),
        .cache_state(cache_state_1),
        .is_hit(is_hit_1)
    );
    CacheBank bank2 (
        .bank_active(active_bank==1),
        .reset(reset),
        .clk(clk),
        .mem_rw(mem_rw),
        .addr(addr),
        .data_ready(data_ready),
        .is_input_valid(is_input_valid),
        .data_write_back_complete(data_write_back_complete),
        .input_set(input_set), //128 bit
        .input_line(input_line), //32 bit
        .output_set(output_set_2), //128 bit
        .output_line(output_line_2), // 32 bit
        .output_addr(output_addr_2), // 32 bit
        .dmem_read(dmem_read_2),
        .dmem_write(dmem_write_2),
        .cache_state(cache_state_2),
        .is_hit(is_hit_2)
    );

    always @(posedge clk) begin
    // Initialize data memory
        if (reset) begin
            active_bank<=0;
        end
        else if(stall==0 && !is_hit) begin
            active_bank<=($urandom%2==0);
        end
    end

endmodule

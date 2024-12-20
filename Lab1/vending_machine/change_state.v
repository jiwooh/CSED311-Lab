`include "vending_machine_def.v"


module change_state(clk,reset_n,current_total_nxt,current_total,input_total, output_total, return_total);

	input clk;
	input reset_n;
	input [`kTotalBits-1:0] current_total_nxt;
	output reg [`kTotalBits-1:0] current_total;
	input reg  [`kTotalBits-1:0] input_total, output_total, return_total;
	
	// Sequential circuit to reset or update the states
	always @(posedge clk ) begin
		if (!reset_n) begin
			// TODO: reset all states.
			current_total <= 0;
		end
		else begin
			// TODO: update all states.
			// calculate from output of calculate_current_state module
			current_total <= current_total_nxt + input_total - return_total - output_total;
		end
	end
endmodule 

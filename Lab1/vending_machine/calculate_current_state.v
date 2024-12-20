
`include "vending_machine_def.v"
	

module calculate_current_state(i_input_coin,i_select_item,item_price,coin_value,current_total,
input_total, output_total, return_total,current_total_nxt,o_return_coin,o_available_item,o_output_item);


	
	input [`kNumCoins-1:0] i_input_coin,o_return_coin;
	input [`kNumItems-1:0]	i_select_item;			
	input [31:0] item_price [`kNumItems-1:0];
	input [31:0] coin_value [`kNumCoins-1:0];	
	input [`kTotalBits-1:0] current_total;
	output reg [`kNumItems-1:0] o_available_item,o_output_item;
	output reg  [`kTotalBits-1:0] input_total, output_total, return_total,current_total_nxt;
	integer i;	

	// Init
	initial begin
		input_total = 0;
		output_total = 0;
		return_total = 0;
	end

	// Combinational logic for the next states
	always @(*) begin
		// send calculated values to the output
		// those values will be integrated in change_state.v
		input_total = 0;
		output_total = 0;
		return_total = 0;
		for(i=0; i < `kNumCoins; i = i + 1) begin
				if(i_input_coin[i] == 1) begin
					input_total = input_total + coin_value[i];
				end
		end
		for(i=0; i < `kNumCoins; i = i + 1) begin
				if(o_return_coin[i] == 1) begin
					return_total = return_total + coin_value[i];
				end
		end
		for(i = 0; i < `kNumItems; i = i + 1) begin
				if(i_select_item[i] == 1 && item_price[i] <= current_total) begin
					output_total = output_total + item_price[i];
				end
		end

		current_total_nxt = current_total;
	end

	
	
	// Combinational logic for the outputs
	always @(*) begin
		// TODO: o_available_item
		o_available_item = 0;
		for(i=0; i < `kNumItems; i = i + 1) begin
			if(item_price[i] <= current_total) begin
				o_available_item[i] = 1;
			end
		end

		// TODO: o_output_item
		o_output_item = 0;
		for(i = 0; i < `kNumItems; i = i + 1) begin
			if(i_select_item[i] == 1 && item_price[i] <= current_total) begin
				o_output_item[i] = 1;
			end
		end
	end
 
endmodule 

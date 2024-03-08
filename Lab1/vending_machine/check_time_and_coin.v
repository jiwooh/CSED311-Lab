`include "vending_machine_def.v"

	

module check_time_and_coin(i_input_coin,i_select_item,clk,reset_n,o_return_coin, current_total, item_price ,i_trigger_return, coin_value);
	input clk;
	input reset_n;
	input [`kNumCoins-1:0] i_input_coin;
	input [`kNumItems-1:0]	i_select_item;
	input [`kTotalBits-1:0] current_total;
	input [31:0] item_price [`kNumItems-1:0];
	input [31:0] coin_value [`kNumCoins-1:0];
	input i_trigger_return;
	output reg  [`kNumCoins-1:0] o_return_coin;
	reg signed [31:0] wait_time;
	integer i;
	integer temp_return_total;
	integer threeCycleCounter;
	// initiate values
	initial begin
		// TODO: initiate values
		wait_time = `kWaitTime;
	end


	// update coin return time
	always @(*) begin
		temp_return_total=0;

		o_return_coin=0;
		if(wait_time <0 || threeCycleCounter ==3) begin
			for(i=`kNumCoins-1; i>=0; i=i-1) begin
				if(coin_value[i] <= current_total - temp_return_total) begin
					o_return_coin[i] = 1;
					temp_return_total = temp_return_total + coin_value[i];
				end
			end
		end
	end

	always @(posedge clk ) begin
		if(i_trigger_return==1) begin
			threeCycleCounter<=threeCycleCounter+1;
		end
		else begin
			threeCycleCounter<=0;
		end
		if (!reset_n) begin
			wait_time <= `kWaitTime;
		end
		else begin
			wait_time <= wait_time - 1;
		end

		for(i=0; i < `kNumCoins; i = i + 1) begin
				if(i_input_coin[i] == 1) begin
					wait_time <= `kWaitTime;
				end
		end
		for(i=0; i < `kNumItems; i = i + 1) begin
			if(i_select_item[i] == 1 && item_price[i] <= current_total) begin
				wait_time <= `kWaitTime;
			end
		end
	end
endmodule 

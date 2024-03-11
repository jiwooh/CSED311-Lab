`include "vending_machine_def.v"

	

module check_time_and_coin(i_input_coin,i_select_item,clk,reset_n,o_return_coin, current_total, i_trigger_return, item_price, coin_value);
	input clk;
	input reset_n;
	input [`kNumCoins-1:0] i_input_coin;
	input [`kNumItems-1:0]	i_select_item;
    input [`kTotalBits-1:0] current_total; //
    input i_trigger_return; //
	input [31:0] item_price [`kNumItems-1:0]; //
	input [31:0] coin_value [`kNumCoins-1:0]; //
	output reg [`kNumCoins-1:0] o_return_coin;
	reg signed [31:0] wait_time;
    integer i;
	integer temp_return_total;
    integer waitForThreeCycles = 0;

	// initiate values
	initial begin
		// TODO: initiate values
        wait_time = `kWaitTime;
	end

    // TODO: o_return_coin
    always @(*) begin
		temp_return_total = 0;
        o_return_coin = 0;
        if (waitForThreeCycles == 3 || wait_time < 0) begin // calculate return coin by coin when time = 0 or return triggered
            // if (current_total / coin_value[2] > 0) begin
            //     o_return_coin[2] = 1;
            // end
            // else if ((current_total % coin_value[2]) / coin_value[1] > 0) begin
            //     o_return_coin[1] = 1;
            // end
            // else if ((current_total % coin_value[1]) / coin_value[0] > 0) begin
            //     o_return_coin[0] = 1;
            // end
            for (i = `kNumCoins - 1; i >= 0; i = i - 1) begin
				if(coin_value[i] <= current_total - temp_return_total) begin
					o_return_coin[i] = 1;
					temp_return_total = temp_return_total + coin_value[i];
				end
			end
        end
    end

	always @(posedge clk) begin
        if (i_trigger_return) begin
            waitForThreeCycles <= waitForThreeCycles + 1;
        end
        else begin
            waitForThreeCycles <= 0;
        end
            
		if (!reset_n) begin
            // TODO: reset all states.
            wait_time <= `kWaitTime;
		end
		else begin
            wait_time <= wait_time - 1;
		end
        
        // TODO: update coin return time
        if (i_input_coin != 0) begin
            wait_time <= `kWaitTime;
        end
        for (i = 0; i < `kNumCoins; i = i + 1) begin
            if (i_input_coin[i]) begin
                wait_time <= `kWaitTime;
            end
        end
        for (i = 0; i < `kNumItems; i = i + 1) begin
            if (i_select_item[i] && item_price[i] <= current_total) begin
                wait_time <= `kWaitTime;
            end
        end
	end
endmodule 

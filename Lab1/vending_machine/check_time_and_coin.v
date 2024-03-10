`include "vending_machine_def.v"

	

module check_time_and_coin(i_input_coin,i_select_item,clk,reset_n,wait_time,o_return_coin, current_total, i_trigger_return, item_price, coin_value);
	input clk;
	input reset_n;
	input [`kNumCoins-1:0] i_input_coin;
	input [`kNumItems-1:0]	i_select_item;
    input [`kTotalBits-1:0] current_total; //
    input i_trigger_return; //
	input [31:0] item_price [`kNumItems-1:0]; //
	input [31:0] coin_value [`kNumCoins-1:0]; //
	output reg [`kNumCoins-1:0] o_return_coin;
	output reg [31:0] wait_time;
    integer i;

	// initiate values
	initial begin
		// TODO: initiate values
        wait_time = `kWaitTime;
	end


	// update coin return time
	always @(i_input_coin or i_select_item) begin
		// TODO: update coin return time
        if (i_input_coin != 0) begin
            wait_time <= `kWaitTime;
        end
        for (i = 0; i < `kNumItems; i = i + 1) begin
            if (i_select_item[i] && item_price[i] <= current_total) begin
                wait_time <= `kWaitTime;
            end
        end
	end

	always @(i_trigger_return or wait_time) begin
		// TODO: o_return_coin
        o_return_coin <= 0;
		if (i_trigger_return || wait_time == 0) begin // calculate return coin by coin when time = 0 or return triggered
			if (current_total / coin_value[2] > 0) begin
				o_return_coin[2] <= 1;
			end
			else if ((current_total % coin_value[2]) / coin_value[1] > 0) begin
				o_return_coin[1] <= 1;
			end
			else if ((current_total % coin_value[1]) / coin_value[0] > 0) begin
				o_return_coin[0] <= 1;
			end
		end
	end

	always @(posedge clk) begin
		if (!reset_n) begin
            // TODO: reset all states.
            o_return_coin <= 0;
            wait_time <= 0;//`kWaitTime;
		end
		else begin
            // TODO: update all states.
                if (wait_time > 0) begin
                    wait_time <= wait_time - 1;
                end
		end
	end
endmodule 

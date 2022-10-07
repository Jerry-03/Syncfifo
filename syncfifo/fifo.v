module fifo (clk, rst, rq, wq, w_data, r_data, full, empty);
    parameter mem_depth = 6;
    parameter data_depth = 7;
    input clk;
    input rst;
    input rq;
    input wq;
    input [data_depth:0] w_data;
    output reg [data_depth:0] r_data;
    output full;
    output empty;

    reg [data_depth:0] mem [mem_depth:0];//7个 8位的mem
    reg [2:0] w_point;
    reg [2:0] r_point;
    reg [3:0] counter;

always @(posedge clk or posedge rst) begin
	if (rst == 0) begin
		// reset
		w_point <= 3'd0;	
		mem_clear;
	end
	else if ((wq == 1) && (full==0)) begin
		mem[w_point] <= w_data;
		if(w_point==(mem_depth)) w_point<=0;
		else w_point <= w_point + 1;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst == 0) begin
		// reset
		r_point <= 3'd0;
		r_data <= 0;
	end
	else if ((rq == 1) &&(empty ==0)) begin
		r_data <= mem[r_point];
		r_point <= r_point + 1;
		if(r_point == mem_depth) r_point<=0;
	end
end

//只关注counter的数值，具体wq或者相对rq位置变化不关心
always @(posedge clk or posedge rst) begin
	if (!rst) begin
		// reset
		counter <= 0;
	end
	else if((wq && !full)&&(rq && !empty)) // read and write meanwhile,counter keep no change
		counter <= counter;
	else  if(rq&&!empty)
		counter <= counter - 1;
	else  if(wq&&!full)
		counter <= counter + 1;
	else
		counter <= counter;   //no read, no write, keep no change
end

assign   full=(counter==mem_depth);
assign   empty=(counter==0);

//读写标志三种情况
// wire flag_and;
// assign flag_and = flag_wraped_w^flag_wraped_r;//只有1&&0一种情况

// always @(posedge clk or posedge rst) begin
// 	if (!rst) begin
// 		// reset
// 		empty <= 0;
// 		full <= 0;
// 	end
// 	else if(flag_and == 1) begin
// 		if(r_point-w_point == 0) full <= 1;
// 	end
// 	else if (flag_and == 0 && counter == 0) begin
// 		empty <= 1;
// 	end
// 	else if (flag_and == 0 && counter == 7) begin
// 	    full <= 1;
// 	end
// 	else begin
// 		empty <= 0;
// 		full <= 0;
// 	end
// end

task mem_clear;
	//mem[mem_depth -:7] = 0;
	for (integer i = 0; i <= mem_depth; i = i + 1)
	    begin
	        mem[i] = 0;
	    end
endtask

endmodule
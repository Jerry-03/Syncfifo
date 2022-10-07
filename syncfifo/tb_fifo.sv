module tb_fifo;
    reg clk,rst_n;
    reg wq,rq;
    reg [7:0] wr_data;             // data input to be pushed to buffer
    wire [7:0] rd_data;       // port to output the data using pop.
    wire empty,full;  // buffer empty and full indication

    fifo  #(.data_depth(7), .mem_depth(6)) 
    fifo_inst(.clk(clk),.rst(rst_n),.w_data(wr_data),.rq(rq),.wq(wq),
        .r_data(rd_data),.full(full),.empty(empty));

    always #10 clk = ~clk;

    reg [7:0] tempdata = 0;
    initial begin
        clk = 0;
        rst_n = 0;
        wq = 0;
        rq = 0;
        wr_data =0;
        #30;
        rst_n = 1;
        
        push(1);
        //fork
           push(2);
           pop(tempdata);
           pop(tempdata);
           pop(tempdata);
        //join              //push and pop together
        push(10);
        push(20);
        push(30);
        push(40);
        push(50);
        push(60);
        push(70);
        push(80);
        push(90);
        push(100);
        push(110);
        push(120);
        push(130);
        pop(tempdata);
        push(tempdata);
        pop(tempdata);
        pop(tempdata);
        pop(tempdata);
        pop(tempdata);
        push(140);
        pop(tempdata);
        push(tempdata);
        pop(tempdata);
        pop(tempdata);
        pop(tempdata);
        pop(tempdata);
        pop(tempdata);
        pop(tempdata);
        pop(tempdata);
        pop(tempdata);
        pop(tempdata);
        pop(tempdata);
        pop(tempdata);
        push(5);
        pop(tempdata);
        #1000 $finish;
    end

    initial
    begin            
        $dumpfile("wave.vcd");        //生成的vcd文件名称
        $dumpvars(0, tb_fifo);    //tb模块名称
    end

    task push (input [7:0] data);
	    if(full)
		    $display("---Cannot push %d: Buffer Full---",data);
	    else begin
		    $display("Push",,data);

            wr_data = data;
            wq = 1;
            @(posedge clk);
            #5 wq = 0;
        end
    endtask

    task pop(output[7:0] data);
        if(empty)
            $display("---Cannot Pop: Buffer Empty---");
        else begin
            rq = 1;
            @(posedge clk);
            #3 rq = 0;
            data = rd_data;
            $display("------Poped:",,data);
        end
    endtask

endmodule
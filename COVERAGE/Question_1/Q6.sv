module sample;
  bit ack;
  bit clk;
  always #5 clk=~clk;
  property ack_p;
    @(posedge clk) $rose(ack) |-> ##1 !$past(ack) ;
  endproperty
  assert property(ack_p);
  
    initial begin
      clk=0;
      ack=0;
      @(posedge clk) ack=1;
    end
    always@(posedge clk) begin
      ack=$random;
      $display("[%0t] ack=%0b",$time,ack);
    end
    initial begin 
      #50 $finish;
    end
    initial begin 
      $dumpfile("dump.vcd");
      $dumpvars();
    end
    endmodule
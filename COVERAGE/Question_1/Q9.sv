module tb;
  bit req,ack;
  bit clk;
  always #5 clk=~clk;
  property name;
    @(posedge clk) $rose(req)|-> ##[0:3] $rose(ack) ;
  endproperty
  assert property(name) else $error("[%0t]ASSERTION DID'NT PASS",$time);


    initial begin
      clk=0;
      req=0;
      @(posedge clk) req=1;
    end
    always@(posedge clk) begin
      req=$random;
      ack=$random;
      $display("[%0t] ack=%0b req=%0b",$time,ack,req);
    end
    initial begin
      $dumpfile("dump.vcd");
      $dumpvars;
      #50 $finish;
    end
    endmodule
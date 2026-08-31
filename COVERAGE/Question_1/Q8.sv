module tb;
  bit ready;
  bit reset;
  bit clk;
  always #5 clk=~clk;
  property name;
    @(posedge clk) $fell(reset)|=> ##[1:5] $rose(ready) ;
  endproperty
  assert property (name) else $error("ASSERTION DIDN'T PASS");


    initial begin 
      clk=0;
      reset=0;
      @(posedge clk) reset=1;
    end
    always@(posedge clk) begin
      reset=$random;
      ready=$random;
      $display("[%0t] reset=%0d ready=%0d",$time,reset,ready);
    end
    initial begin
      #50 $finish;
    end
    initial begin
      $dumpfile("dump.vcd");
      $dumpvars();
    end
    endmodule
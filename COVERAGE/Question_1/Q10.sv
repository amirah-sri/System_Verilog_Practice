`timescale 1ps/1ps
module tb;
  bit valid;
  bit clk;
  always #5 clk=~clk;
  
  property name;
    @(posedge clk) $rose(valid) |-> $stable(valid)[*3];
  endproperty
  assert property(name) else $error("[%0t] ASSERTION DIDINT PASS",$time);
    initial begin
      clk=0;
      valid=0;
      @(posedge clk) valid=1;
    end
    always@(posedge clk) begin
      //valid=$random;
      #10 valid=1;
      #10 valid=0;
      #10 valid=0;
      #10 valid=0;
      $display("[%0t] valid=%0b",$time,valid);
    end
    initial begin
      $dumpfile("dump.vcd");
      $dumpvars;
      #50 $finish;
    end
    endmodule
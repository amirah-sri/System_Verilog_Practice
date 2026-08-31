module sample;
  bit data_ready;
  bit data_valid;
  bit clk;
  always #5 clk = ~clk;
  property valid;
    @(posedge clk) data_valid==1 |-> ##[1:3] $rose(data_ready);
  endproperty
  assert property(valid) else $error("Property isnt satisfied");

    initial begin
      clk=0;
      data_valid=0;
      @(posedge clk )data_valid =1;
    end
    always@(posedge clk) begin
      data_ready =$random;
      $display("%0t data_valid =%0b data_ready=%0b",$time,data_valid,data_ready);
    end
    initial begin
      $dumpfile("sample.vcd");
      $dumpvars;
      #100 $finish;
    end
    endmodule
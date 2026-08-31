class cov;
  rand bit[2:0] data;

  constraint c{
    data inside {[0:15]};
  }


  covergroup cg;
    coverpoint data;
  endgroup
  function new();
    cg=new;
  endfunction
endclass


module tb;
  cov c;
  initial begin
    c=new;
    repeat(100) begin
    c.randomize();
    c.cg.sample();
    end
  end
endmodule
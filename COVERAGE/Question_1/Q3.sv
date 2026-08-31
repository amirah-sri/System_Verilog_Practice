class cov;
  randc int data;

  covergroup cg;
    coverpoint data{
      bins even_i[]={[0:100]} with ((data%10==0) && (data%2==0));
      bins odd_i[]={[0:100]} with ((data%10==0) && (data%2!=0));
    }
  endgroup
  function new;
    cg=new;
  endfunction
endclass
module tb;
  cov c;
  initial begin
    c=new;
    repeat(100) begin
      c.randomize with {c.data inside {[0:100]}; unique{data};};
      c.cg.sample();
    end
  end
endmodule
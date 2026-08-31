class sample;
  rand bit[3:0] bus;
  
  covergroup cg;
    coverpoint bus[0]{
      bins b={0,1};
    }
    coverpoint bus[1]{
      bins b={0,1};
    }
    coverpoint bus[2]{
      bins b={0,1};
    }
    coverpoint bus[3]{
      bins b={0,1};
    }
  endgroup
  function new;
    cg=new;
  endfunction
endclass

module tb;
  sample s;
  initial begin
    s=new;
    s.randomize();
    s.cg.sample();
  end
endmodule
typedef enum {P1,P2,P3} p_type;
typedef enum {high,med,low} p_priority;

class cov;
  rand p_type p_t;
  rand p_priority p_p;
  rand bit[9:0] len;

  covergroup cg;
    coverpoint p_t;
    coverpoint p_p;
    coverpoint len{
      bins short_length={[0:15]};
      bins mid_length={[16:127]};
      bins long_length={[128:1023]};
    }
    p_t_X_p_p_X_len:cross p_t,p_p,len;
  endgroup
  
  function new;
    cg=new;
  endfunction
  
endclass
module tb;
  cov c;
  initial begin
    c=new;
    repeat(50) begin
    c.randomize();
    c.cg.sample();
    end
  end
endmodule
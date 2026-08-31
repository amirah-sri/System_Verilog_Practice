module tb;
  bit  req,ack;
  bit clk;
  always #5 clk=~clk;
  sequence seq_req_ack;
    @(posedge clk) req ##1 ack;
  endsequence
  sequence seq_ack_req;
    @(posedge clk) ack ##1 req;
  endsequence
  covergroup cg;
    coverpoint req_ack_seq{
      bins req_then_ack={seq_req_ack};
      bins ack_then_req ={seq_ack_req};
    }
  endgroup
  initial begin
      @(posedge clk) begin
      s.cg.sample();
    end
  end
endmodule
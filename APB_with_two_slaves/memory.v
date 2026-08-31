module memory#(parameter DEPTH=1024,parameter DATA_WIDTH=32,parameter ADDR_WIDTH=32)(
  input clk,
  input write_en,
  input [DATA_WIDTH-1:0]write_data,
  input [ADDR_WIDTH-1:0] addr,
  output reg [DATA_WIDTH-1:0] read_data
);
  reg[DATA_WIDTH-1:0] mem [0:DEPTH-1];
  always @(posedge clk) begin
    if(write_en) begin
      mem[addr]<=write_data;
    end
    else read_data<=mem[addr];
  end
endmodule
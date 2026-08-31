`include "memory.v"
`include "slave_apb.v"
module apb_top#(parameter ADDR_WIDTH = 32,parameter DATA_WIDTH = 32,
                parameter DEPTH = 1024)

  (
  input  pclk,
  input preset,
  input [ADDR_WIDTH-1:0] paddr,
  input [2:0] pprot,
  input psel,
  input penable,
  input pwrite,
  input[DATA_WIDTH-1:0] pwdata,
  input[DATA_WIDTH/8-1:0] pstrb,
  output[DATA_WIDTH-1:0] prdata,
  output pready,
  output pslverr
);

  wire [DATA_WIDTH-1:0] rdata_s0, rdata_s1;
  wire [DATA_WIDTH-1:0] wdata_s0, wdata_s1;
  wire [ADDR_WIDTH-1:0] addr_s0, addr_s1;
  wire we_s0, we_s1;
  wire sel_s0=(paddr < 32'h0000_4000); // o to 3fff
  wire sel_s1=(paddr >= 32'h0000_4000 && paddr < 32'h0000_8000);//3fff to 7fff
  wire pselx_s0 = sel_s0 && psel;
  wire pselx_s1 = sel_s1 && psel;
  wire pready_s0, pready_s1;
  wire pslverr_s0, pslverr_s1;
  wire [DATA_WIDTH-1:0] prdata_s0, prdata_s1;

 
  slave_apb #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .DEPTH(DEPTH),
    .BASE_ADDR(32'h0000_0000)
  ) slave0 (
    .pclk_i(pclk),
    .preset_i(preset),
    .paddr_i(paddr),
    .pprot_i(pprot),
    .pselx_i(pselx_s0),
    .penable_i(penable),
    .pwrite_i(pwrite),
    .pwdata_i(pwdata),
    .pstrb_i(pstrb),
    .pready_o(pready_s0),
    .prdata_o(prdata_s0),
    .pslverr_o(pslverr_s0),
    .mem_write(we_s0),
    .mem_addr(addr_s0),
    .mem_wdata(wdata_s0),
    .mem_rdata(rdata_s0)
  );
  slave_apb #(.ADDR_WIDTH(ADDR_WIDTH),.DATA_WIDTH(DATA_WIDTH),.DEPTH(DEPTH),.BASE_ADDR(32'h0000_4000)
  ) slave1 (
    .pclk_i(pclk),
    .preset_i(preset),
    .paddr_i(paddr),
    .pprot_i(pprot),
    .pselx_i(pselx_s1),
    .penable_i(penable),
    .pwrite_i(pwrite),
    .pwdata_i(pwdata),
    .pstrb_i(pstrb),
    .pready_o(pready_s1),
    .prdata_o(prdata_s1),
    .pslverr_o(pslverr_s1),
    .mem_write(we_s1),
    .mem_addr(addr_s1),
    .mem_wdata(wdata_s1),
    .mem_rdata(rdata_s1)
  );
  
    memory #(.DEPTH(DEPTH),.DATA_WIDTH(DATA_WIDTH),.ADDR_WIDTH(ADDR_WIDTH)) mem0 (.clk(pclk),
                                                                                .write_en(we_s0),
                                                                                .write_data(wdata_s0),
                                                                                .addr(addr_s0),
                                                                                .read_data(rdata_s0)
  );

  memory #(.DEPTH(DEPTH),.DATA_WIDTH(DATA_WIDTH),.ADDR_WIDTH(ADDR_WIDTH)) mem1 (.clk(pclk),
                                                                               .write_en(we_s1),
                                                                               .write_data(wdata_s1),
                                                                               .addr(addr_s1),
                                                                               .read_data(rdata_s1)
  );
           
  assign prdata=sel_s0?prdata_s0:(sel_s1?prdata_s1:0);
  assign pready=sel_s0?pready_s0:(sel_s1?pready_s1:1);
  assign pslverr=sel_s0?pslverr_s0:(sel_s1?pslverr_s1:1'b1);
//   always(*) begin
//   if (sel_s0) begin
//     prdata  = prdata_s0;
//     pready  = pready_s0;
//     pslverr = pslverr_s0;
//   end else if (sel_s1) begin
//     prdata  = prdata_s1;
//     pready  = pready_s1;
//     pslverr = pslverr_s1;
//   end else begin
//     prdata  = 32'h0;       
//     pready  = 1'b1;     
//     pslverr = 1'b1;     
//   end
// end
  //psel0|sel1|
  // 0     0
  // 0     1
  // 1     0
  //1      1

endmodule

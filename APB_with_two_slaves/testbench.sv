`timescale 1ns/1ps

module apb_top_tb;

  parameter ADDR_WIDTH = 32;
  parameter DATA_WIDTH = 32;
  parameter DEPTH = 1024;

  reg                   pclk;
  reg                   preset;
  reg  [ADDR_WIDTH-1:0] paddr;
  reg  [2:0]            pprot;
  reg                   psel;
  reg                   penable;
  reg                   pwrite;
  reg  [DATA_WIDTH-1:0] pwdata;
  reg  [DATA_WIDTH/8-1:0] pstrb;

  wire [DATA_WIDTH-1:0] prdata;
  wire                  pready;
  wire                  pslverr;

  apb_top dut (
    .pclk(pclk),
    .preset(preset),
    .paddr(paddr),
    .pprot(pprot),
    .psel(psel),
    .penable(penable),
    .pwrite(pwrite),
    .pwdata(pwdata),
    .pstrb(pstrb),
    .prdata(prdata),
    .pready(pready),
    .pslverr(pslverr)
  );

  always #5 pclk = ~pclk;


  task apb_write(input[ADDR_WIDTH-1:0] addr,input [DATA_WIDTH-1:0] data,input [2:0] prot);
    begin
      @(posedge pclk);
      paddr   = addr;
      pwdata  = data;
      pprot   = prot;
      pstrb   = 4'b1111;
      pwrite  = 1;
      psel    = 1;
      penable = 0;
      @(posedge pclk);
      penable = 1;
      wait(pready == 1);
      @(posedge pclk);
      psel    = 0;
      penable = 0;
      $display("WRITE: addr = %h, data = %h, pslverr = %b", addr, data, pslverr);
    end
  endtask


  task apb_read(input[ADDR_WIDTH-1:0] addr,input [2:0] prot);
    begin
      @(posedge pclk);
      paddr   = addr;
      pprot   = prot;
      pstrb   = 4'b0000;
      pwrite  = 0;
      psel    = 1;
      penable = 0;
      @(posedge pclk);
      penable = 1;
      wait(pready == 1);
      @(posedge pclk);
      psel    = 0;
      penable = 0;
      $display("READ: addr = %h, data = %h, pslverr = %b", addr, prdata, pslverr);
    end
  endtask

  initial begin

    pclk = 0;
    preset = 0;
    psel = 0;
    penable = 0;
    paddr = 0;
    pwdata = 0;
    pwrite = 0;
    pstrb = 0;
    pprot = 3'b000;

    #15;
    @(posedge pclk);
    preset = 1;

//slave 0 base 32'h0000_0000
    apb_write(32'h0000_0004, 32'hDADADADA, 3'b000);
    apb_read( 32'h0000_0004, 3'b000);

    apb_write(32'h0000_1004, 32'hCCCC5555, 3'b001); // secure-privileged
    apb_read( 32'h0000_1004, 3'b001);
   //slave 1 base 32'h0000_4000
    apb_write(32'h0000_4008, 32'h12345678, 3'b100); // instruction-secure-normal
    apb_read( 32'h0000_4008, 3'b100);

    apb_write(32'h0000_7000, 32'hA5A5A5A5, 3'b111); // instruction-nonsecure-privileged
    apb_read( 32'h0000_7000, 3'b111);

    apb_read(32'h0000_9000, 3'b000); // invalid addr
    apb_write(32'h8000_0000, 32'h111888811, 3'b001); // invalid addr

    #20;
    $finish;
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end

endmodule

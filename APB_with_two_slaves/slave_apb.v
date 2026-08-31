module slave_apb#( parameter ADDR_WIDTH=32,
                  parameter DATA_WIDTH=32,                  
                  parameter DEPTH=1024,
                  parameter BASE_ADDR=32'b0000_0000)
  (pclk_i,preset_i,paddr_i,pprot_i,pselx_i,penable_i,pwrite_i,pwdata_i,pstrb_i,mem_write,mem_addr,mem_wdata,mem_rdata,pready_o,prdata_o,pslverr_o);
  parameter IDLE=3'b001;
  parameter SETUP=3'b010;
  parameter ACCESS=3'b100;
  //input signals
  input pclk_i;
  input preset_i;
  input [ADDR_WIDTH-1:0] paddr_i;
  input [2:0] pprot_i;
  input pselx_i;
  input penable_i;
  input pwrite_i;
  input [DATA_WIDTH-1:0]pwdata_i;
  input [DATA_WIDTH/8-1:0]pstrb_i;
  //input memory module
  input [DATA_WIDTH-1:0] mem_rdata;

  //output signals
  output reg pready_o;
  output reg[DATA_WIDTH-1:0] prdata_o;
  output reg pslverr_o;
  //output memory module
  output reg mem_write;
  output reg [ADDR_WIDTH-1:0] mem_addr;
  output reg [DATA_WIDTH-1:0] mem_wdata;

  //internals
  int count=0;
  int i;
  reg [3:0] state,next_state;
  reg [2:0] wait_count=0;
  reg [DATA_WIDTH-1:0] temp_wdata;//for pstrb
  //for mrmoery module
  wire range=(paddr_i>BASE_ADDR) && (paddr_i<BASE_ADDR+DEPTH);
  wire [ADDR_WIDTH-1:0] reset_addr=paddr_i-BASE_ADDR;


  //memory
  //reg [DATA_WIDTH-1:0] mem [0:DEPTH-1]; 

  always@(posedge pclk_i or negedge preset_i) begin
    if(!preset_i)begin
      state<=IDLE;
      pready_o=0;
      prdata_o=0;
      pslverr_o=0;
      //pruser_o=0;
      //pbuser_o=0;
      //       for(i=0;i<DEPTH;i=i+1) begin
      //         mem[i]=0;
      //       end
    end
    else begin
      pready_o <= 0;
      //       pslverr_o<= 0;
      prdata_o <= 0;
      case(state)
        //IDLE STATE
        IDLE:begin

          if(pselx_i==0)begin
            next_state<=IDLE;
          end
          else begin
            next_state<=SETUP;
          end
        end
        //SETUP STATE
        SETUP:begin
          //pslverr_o<=0;
          //         pready_o<=0;
          if(pselx_i==1) begin
            pready_o<=0;

            next_state<=ACCESS;
          end
          else begin
            next_state<=SETUP;
          end
        end
        //ACCESS STATE
        ACCESS:begin
          $display("*************");
          if(pselx_i==1 && penable_i==1)begin           
            wait_count = wait_count + 1;
            $display("*************");

            if(wait_count==2) begin

              pready_o <= 1;
              //               wait_count<=0;
              //if(paddr_i[31]!=0) pslverr_o<=1;
              if(!range || paddr_i[31]!=0) pslverr_o<=1;
              else begin
                mem_addr=reset_addr;
                if(pwrite_i)begin
                 // mem_write<=1;
                  //mem_wdata<=pwdata_i;
                  temp_wdata<=mem_rdata;
                  if(pstrb_i[0])temp_wdata[7:0]=pwdata_i[7:0];
                  if(pstrb_i[1])temp_wdata[15:8]=pwdata_i[15:8];
                  if(pstrb_i[2])temp_wdata[23:16]=pwdata_i[23:16];
                  if(pstrb_i[3])temp_wdata[31:24]=pwdata_i[31:24];

                  mem_wdata<=temp_wdata;
                  mem_write<=1;
                  //                 if(paddr_i>DEPTH) pslverr_o<=1;
                  //                 else begin
                  //mem[paddr_i]<=pwdata_i; 
                  //                   pslverr_o<=0;
                  //                 end
                end
                else begin                
                  //prdata_o<=mem[paddr_i];
                  prdata_o<=mem_rdata;
                  mem_write<=0;
                  //                 pslverr_o<=0;
                end
              end
              if(!penable_i) next_state<=SETUP;
            end 
          end else 
            begin
              wait_count<=0;
            end


          if(!pselx_i)begin
            pready_o<=0;
            next_state<=IDLE;
          end
          else next_state<=ACCESS;
        end
        default:next_state=IDLE;
      endcase

    end
  end
  always @(next_state) state<=next_state;



  //     always @(posedge pclk_i or negedge preset_i) begin
  //     if (state == ACCESS) begin
  //       casex (pprot_i)
  //         // DATA
  //         3'b0xx: begin
  //           if (paddr_i >= 0 && paddr_i < (DEPTH/2)) begin
  //             $display("DATA ACCESS");
  //             pslverr_o <= 0;

  //             casex (pprot_i)
  //               // SECURE
  //               3'b00x: begin
  //                 if (paddr_i >= 0 && paddr_i < (DEPTH/4)) begin
  //                   $display("SECURE DATA TRANSFER");
  //                   pslverr_o <= 0;

  //                   casex (pprot_i)
  //                     // NORMAL
  //                     3'b000: begin
  //                       if (paddr_i >= 0 && paddr_i < (DEPTH/8)) begin
  //                         $display("NORMAL SECURE DATA ACCESS");
  //                         pslverr_o <= 0;
  //                       end else pslverr_o <= 1;
  //                     end

  //                     // PRIVILEGED
  //                     3'b001: begin
  //                       if (paddr_i >= (DEPTH/8) && paddr_i < (DEPTH/4)) begin
  //                         $display("PRIVILEGED SECURE DATA ACCESS");
  //                         pslverr_o <= 0;
  //                       end else pslverr_o <= 1;
  //                     end
  //                   endcase
  //                 end else pslverr_o <= 1;
  //               end

  //               // NON-SECURE
  //               3'b01x: begin
  //                 if (paddr_i >= (DEPTH/4) && paddr_i < (DEPTH/2)) begin
  //                   $display("UNSECURE DATA TRANSFER");
  //                   pslverr_o <= 0;

  //                   casex (pprot_i)
  //                     // NORMAL
  //                     3'b010: begin
  //                       if (paddr_i >= (DEPTH/4) && paddr_i < (3*DEPTH/8)) begin
  //                         $display("NORMAL UNSECURE DATA ACCESS");
  //                         pslverr_o <= 0;
  //                       end else pslverr_o <= 1;
  //                     end

  //                     // PRIVILEGED
  //                     3'b011: begin
  //                       if (paddr_i >= (3*DEPTH/8) && paddr_i < (DEPTH/2)) begin
  //                         $display("PRIVILEGED UNSECURE DATA ACCESS");
  //                         pslverr_o <= 0;
  //                       end else pslverr_o <= 1;
  //                     end
  //                   endcase
  //                 end else pslverr_o <= 0;
  //               end
  //             endcase
  //           end else pslverr_o <= 1;
  //         end

  //         // INSTRUCTION
  //         3'b1xx: begin
  //           if (paddr_i >= (DEPTH/2) && paddr_i < DEPTH) begin
  //             $display("INSTRUCTION ACCESS");
  //             pslverr_o <= 0;

  //             casex (pprot_i)
  //               // SECURE
  //               3'b10x: begin
  //                 if (paddr_i >= (DEPTH/2) && paddr_i < (3*DEPTH/4)) begin
  //                   $display("SECURE INSTRUCTION TRANSFER");
  //                   pslverr_o <= 0;

  //                   casex (pprot_i)
  //                     // NORMAL
  //                     3'b100: begin
  //                       if (paddr_i >= (DEPTH/2) && paddr_i < (5*DEPTH/8)) begin
  //                         $display("NORMAL SECURE INSTRUCTION ACCESS");
  //                         pslverr_o <= 0;
  //                       end else pslverr_o <= 1;
  //                     end

  //                     // PRIVILEGED
  //                     3'b101: begin
  //                       if (paddr_i >= (5*DEPTH/8) && paddr_i < (3*DEPTH/4)) begin
  //                         $display("PRIVILEGED SECURE INSTRUCTION ACCESS");
  //                         pslverr_o <= 0;
  //                       end else pslverr_o <= 1;
  //                     end
  //                   endcase
  //                 end else pslverr_o <= 1;
  //               end

  //               // NON-SECURE
  //               3'b11x: begin
  //                 if (paddr_i >= (3*DEPTH/4) && paddr_i < DEPTH) begin
  //                   $display("UNSECURE INSTRUCTION TRANSFER");
  //                   pslverr_o <= 0;

  //                   casex (pprot_i)
  //                     // NORMAL
  //                     3'b110: begin
  //                       if (paddr_i >= (3*DEPTH/4) && paddr_i < (7*DEPTH/8)) begin
  //                         $display("NORMAL UNSECURE INSTRUCTION ACCESS");
  //                         pslverr_o <= 0;
  //                       end else pslverr_o <= 1;
  //                     end

  //                     // PRIVILEGED
  //                     3'b111: begin
  //                       if (paddr_i >= (7*DEPTH/8) && paddr_i < DEPTH) begin
  //                         $display("PRIVILEGED UNSECURE INSTRUCTION ACCESS");
  //                         pslverr_o <= 0;
  //                       end else pslverr_o <= 1;
  //                     end
  //                   endcase
  //                 end else pslverr_o <= 0;
  //               end
  //             endcase
  //           end else pslverr_o <= 0;
  //         end
  //       endcase
  //     end
  //   end

  // endmodule

  //   always @(next_state) state<=next_state;
  //   always @(posedge pclk_i) begin
  //     if(preset_i) begin
  //       if(penable_i && pselx_i) begin
  //         if(state==ACCESS) begin
  //           pslverr_o=((pprot_i==3'b000) && (!(paddr_i<32'h1000 && paddr_i>=0)))? 1:0;
  //           pslverr_o=((pprot_i==3'b001) && ((paddr_i<32'h2000 && paddr_i>=32'h1000)))? 0:1;
  //           pslverr_o=((pprot_i==3'b010) && (!(paddr_i<32'h3000 && paddr_i>=32'h2000)))? 1:0;
  //           pslverr_o=((pprot_i==3'b011) && (!(paddr_i<32'h4000 && paddr_i>=32'h3000)))? 1:0;
  //           pslverr_o=((pprot_i==3'b100) && (!(paddr_i<32'h5000 && paddr_i>=32'h4000)))? 1:0;
  //           pslverr_o=((pprot_i==3'b101) && (!(paddr_i<32'h6000 && paddr_i>=32'h5000)))? 1:0;
  //           pslverr_o=((pprot_i==3'b110) && (!(paddr_i<32'h7000 && paddr_i>=32'h6000)))? 1:0;
  //           pslverr_o=((pprot_i==3'b111) && ((paddr_i<32'h8000 && paddr_i>=32'h7000)))? 0:1;
  //         end
  //       end
  //     end
  //   end
  always @(posedge pclk_i) begin
    if(preset_i) begin
      $display("COMING HERE");
      if(state==ACCESS) begin
        casex(pprot_i)
          3'b0xx:begin
            if(!(paddr_i<32'h0000_4000 && 32'h0000_0000<=paddr_i)) begin
              $display("Data acess is  not being done");
              pslverr_o<=1;
            end
            if(paddr_i<32'h0000_4000 && 32'h0000_0000<=paddr_i) begin
              $display("Data acess is being done");
              pslverr_o<=0;
            end
            casex(pprot_i)
              3'b00x: begin
                if(!(paddr_i<32'h0000_2000 && paddr_i>=32'h0000_0000)) begin
                  $display("Data & Secure acess is  not being done");
                  pslverr_o<=1;
                end
                if(paddr_i<32'h0000_2000 && paddr_i>=32'h0000_0000)begin
                  $display("Secure acess is being done");
                  pslverr_o<=0;
                end

                casex(pprot_i)
                  3'b000:begin
                    if(!(paddr_i<32'h0000_1000 && paddr_i>=32'h0000_0000)) begin
                      $display("Normal data & Secure acess is  not being done");
                      pslverr_o<=1;
                    end
                    if(paddr_i<32'h0000_1000 && paddr_i>=32'h0000_0000)begin
                      $display("Normal acess is being done");
                      pslverr_o<=0;
                    end
                  end
                  3'b001:begin
                    if(!(paddr_i<32'h0000_2000 && paddr_i>=32'h0000_1000)) begin
                      $display("Privilege & Data & Secure acess is  not being done");
                      pslverr_o<=1;
                    end
                    if(paddr_i<32'h0000_2000 && paddr_i>=32'h0000_1000)begin
                      $display("Privileged acess is being done");
                      pslverr_o<=0;
                    end
                  end
                endcase
              end
              3'b01x: begin
                if(!(paddr_i<32'h0000_4000 && paddr_i>=32'h0000_2000)) begin
                  pslverr_o<=1;
                  $display("Data & Non- Secure acess is  not being done");
                end
                if(paddr_i<32'h0000_4000 && paddr_i>=32'h0000_2000)begin
                  $display("Non-Secure acess is being done");
                  pslverr_o<=0;
                end
                casex(pprot_i)
                  3'b000:begin
                    if(!(paddr_i<32'h0000_3000 && paddr_i>=32'h0000_2000)) begin
                      pslverr_o<=1;
                      $display("Mormal & Data & Non-Secure acess is  not being done");
                    end
                    if(paddr_i<32'h0000_3000 && paddr_i>=32'h0000_2000)begin
                      $display("Normal acess is being done");
                      pslverr_o<=0;
                    end
                  end
                  3'b001:begin
                    if(!(paddr_i<32'h0000_4000 && paddr_i>=32'h0000_3000)) begin
                      pslverr_o<=1;
                      $display("Privileged & Data & Non-Secure acess is  not being done");
                    end
                    if(paddr_i<32'h0000_4000 && paddr_i>=32'h0000_3000)begin
                      $display("Privileged acess is being done");
                      pslverr_o<=0;
                    end
                  end
                endcase//done with 3'b001
              end//done with 3'b01x
            endcase//done with 3'b01x

          end

          3'b1xx:begin
            if(!(paddr_i<32'h0000_8000 && 32'h0000_4000<=paddr_i)) begin
              $display("Instruction acess is not being done");
              pslverr_o<=1;
            end
            if(paddr_i<32'h0000_8000 && 32'h0000_4000<=paddr_i) begin
              $display("Instruction acess is being done");
              pslverr_o<=0;
            end
            casex(pprot_i)
              3'b10x: begin
                if(!(paddr_i<32'h0000_6000 && paddr_i>=32'h0000_4000)) begin
                  pslverr_o<=1;
                  $display("Instruction &  Secure acess is  not being done");
                end
                if(paddr_i<32'h0000_6000 && paddr_i>=32'h0000_4000)begin
                  $display("Secure acess is being done");
                  pslverr_o<=0;
                end
                casex(pprot_i)
                  3'b100:begin
                    if(!(paddr_i<32'h0000_5000 && paddr_i>=32'h0000_4000)) begin
                      pslverr_o<=1;
                      $display("Instruction &  Secure& Normal acess is  not being done");
                    end
                    if(paddr_i<32'h0000_5000 && paddr_i>=32'h0000_4000)begin
                      $display("Normal acess is being done");
                      pslverr_o<=0;
                    end
                  end
                  3'b101:begin
                    if(!(paddr_i<32'h0000_6000 && paddr_i>=32'h0000_5000)) begin
                      pslverr_o<=1;
                      $display("Instruction &  Secure & Privileged acess is  not being done");
                    end
                    if(paddr_i<32'h0000_6000 && paddr_i>=32'h0000_5000)begin
                      $display("Normal acess is being done");
                      pslverr_o<=0;
                    end
                  end
                endcase
              end
              3'b11x: begin
                if(!(paddr_i<32'h0000_8000 && paddr_i>=32'h0000_6000)) begin
                  $display("Instruction & Non- Secure acess is  not being done");
                  pslverr_o<=1;
                end
                if(paddr_i<32'h0000_8000 && paddr_i>=32'h0000_6000)begin
                  $display("Non- Secure acess is being done");
                  pslverr_o<=0;
                end
                casex(pprot_i)
                  3'b110:begin
                    if(!(paddr_i<32'h0000_7000 && paddr_i>=32'h0000_6000)) begin
                      pslverr_o<=1;
                      $display("Normal & Instruction & Non-Secure acess is  not being done");
                    end
                    if(paddr_i<32'h0000_7000 && paddr_i>=32'h0000_6000)begin
                      $display("Normal acess is being done");
                      pslverr_o<=0;
                    end
                  end
                  3'b111:begin
                    if(!(paddr_i<32'h0000_8000 && paddr_i>=32'h0000_7000)) begin
                      $display("Privileged & Instruction & Non-Secure acess is  not being done");
                      pslverr_o<=1;
                    end
                    if(paddr_i<32'h0000_8000 && paddr_i>=32'h0000_7000)begin
                      $display("Privileged acess is being done");
                      pslverr_o<=0;
                    end
                  end
                endcase//done with 3'b111
              end//done with 3'b11x
            endcase//done with 3'b11x
          end
        endcase  
      end
    end
  end
  // end

endmodule
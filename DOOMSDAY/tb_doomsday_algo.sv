`timescale 1ns / 1ps

module tb_doomsday_algo;

    logic [15:0] year;
    logic [4:0]  month;
    logic [5:0]  date;

    string doomsday_ch;
    string doomsday_date;

    // DUT
    doomsday_algo dut (
        .year          (year),
        .month         (month),
        .date          (date),
        .doomsday_ch   (doomsday_ch),
        .doomsday_date (doomsday_date)
    );

    initial begin

    year  = 1977;
    month = 3;
    date  = 23;
    #10;
    $display("Year Doomsday= %s",doomsday_ch);
    $display("Date Day= %s",doomsday_date);
    $dumpfile("dump.vcd"); 
    $dumpvars;
    $finish;
end
endmodule

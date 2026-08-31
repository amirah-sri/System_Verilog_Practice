
`timescale 1ns / 1ps
module doomsday_algo(
    input [15:0]year,
    input [4:0]month,
    input [5:0]date,
    output string doomsday_ch,
    output string doomsday_date
    );

reg [4:0] month_date;
reg [7:0] last_two;
int unsigned  reminder;
int  div_4;
int add_results;
int doomsday_num;
bit  year_type;
typedef enum logic[3:0] {SUNDAY,MONDAY,TUESDAY,WEDNESDAY,THURSDAY,FRIDAY,SATURDAY}weekdays;
weekdays doomsday_enum,century_dooms,doomsday_enum_date;

typedef enum logic[4:0] {JAN=1,FEB=2,MARCH=3,APRIL=4,MAY=5,JUNE=6,JULY=7,AUGUST=8,SEPT=9,OCT=10,NOV=11,DEC=12}month_name;

//always@(*)dooms_month<=month.name();
//dooms_month = month_name'(month);
task is_leap_year(input [15:0] year_in,output bit leap_yr);
//if leap_yr=1 :leap yr else normal year
    begin
       if(year_in%400==0)leap_yr=1'b1;
       else begin
            if(year_in%100==0) leap_yr=1'b0;
            else begin
              if(year_in%4==0) leap_yr=1'b1;
              else leap_yr=1'b0;     
            end
        end
    end
endtask
always_comb begin 
 is_leap_year(year,year_type);
 month_doomsdate(year_type,month,month_date);
 doomsday_of_the_year(year,century_dooms);
 
 end
task doomsday_of_the_year(input [15:0] year_t,output weekdays days);
    begin
         if (year_t inside {[1600:1699]}) days=TUESDAY;
         else if(year_t inside {[1700:1799]}) days=SUNDAY;
         else if (year_t inside {[1800:1899]}) days=FRIDAY;
         else if(year_t inside {[1900:1999]})days=WEDNESDAY;
         else if(year_t inside {[2000:2099]})days=TUESDAY;
         else if(year_t inside {[2100:2199]})days=SUNDAY;
         //else days=UNKNOWN;
     end
  endtask
  task month_doomsdate(input bit is_leap,input int month_t,output int unsigned months_doomsday_date);
        case(is_leap)
            1'b0:begin
                case(month_t)
                    'd1:months_doomsday_date='d3;
                    'd2:months_doomsday_date='d28;
                    'd3:months_doomsday_date='d14;
                    'd4:months_doomsday_date='d4;
                    'd5:months_doomsday_date='d9;
                    'd6:months_doomsday_date='d6;
                    'd7:months_doomsday_date='d11;
                    'd8:months_doomsday_date='d8;
                    'd9:months_doomsday_date='d5;
                    'd10:months_doomsday_date='d10;
                    'd11:months_doomsday_date='d7;
                    'd12:months_doomsday_date='d12;
                endcase
            end
            1'b1: begin
                 case(month_t)
                    'd1:months_doomsday_date='d4;
                    'd2:months_doomsday_date='d29;
                    'd3:months_doomsday_date='d14;
                    'd4:months_doomsday_date='d4;
                    'd5:months_doomsday_date='d9;
                    'd6:months_doomsday_date='d6;
                    'd7:months_doomsday_date='d11;
                    'd8:months_doomsday_date='d8;
                    'd9:months_doomsday_date='d5;
                    'd10:months_doomsday_date='d10;
                    'd11:months_doomsday_date='d7;
                    'd12:months_doomsday_date='d12;
                endcase
            end
         endcase
  endtask
  
  //always_comb month_doomsdate(year_type,month,month_date);
  
 // always_comb doomsday_of_the_year(year,century_dooms);
  assign last_two=(year%100 +100)%100; //last two digits of the year
  assign reminder=last_two % 12; //
  assign div_4=reminder/4;
  //int anchor_number = century_dooms;//.num();
  
  assign add_results=(last_two/12)+reminder+div_4+century_dooms;
  assign doomsday_num=add_results%7;
  assign doomsday_enum=weekdays'(doomsday_num);
  assign doomsday_ch=doomsday_enum.name();
  
  //Difference of doomsdate and the input date
  int date_diff;
  assign date_diff=date-month_date;
  int mod7;
int final_date;
int move_num;

assign mod7 = date_diff % 7;

always_comb begin
    if (mod7 < 0)
        move_num = mod7 + 7;
    else
        move_num = mod7;
end
  
  assign final_date=(doomsday_num+move_num)%7;
  assign doomsday_enum_date=weekdays'(final_date);
  assign doomsday_date=doomsday_enum_date.name();
  
endmodule

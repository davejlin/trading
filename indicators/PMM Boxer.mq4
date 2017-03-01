//+----------------------------------------------------------------------+
//|                                                        PMM Boxer.mq4 |
//|                                                         David J. Lin |
//| Draws PMM Boxes                                                      |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|dave.j.lin@sbcglobal.net                                              |
//|Evanston, IL, November 21, 2007                                       |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2007 David J. Lin"

#property indicator_chart_window

extern   int      Order_Start_Hour=7;   // server time hour at which to perform analysis & begin window of opportunity to submit order
extern   int      Order_Start_Minute=15;// server time minute at which to perform analysis & begin window of opportunity to submit order
extern   int      Order_End_Time=16;    // server time hour at which to end window of opportunity to submit order
extern   int      Analysis_LookBack=36; // bars to look back for swing high/swing low determination
extern   double   Upper_Buffer = 3;     // pips above swing-high at which to submit long order
extern   double   Lower_Buffer = 3;     // pips below swing-low at which to submit short order
extern   int      Entry_Buffer = 1;     // pips in entry trigger stripe (within which to allow trade entries)
extern   double   BoxHeightMAX=90;      // no trades if box height exceeds this number of pips
extern   double   BoxHeightMIN=30;      // no trades if box height is less than this number of pips
extern   int      LookBackDays=-1;      // days in the past to draw boxes (use zero or negative number for all bars)

//---- buffers
int thistime,lastD1,lbbars;
int info_font_size=8;
string info_font="Times New Roman";
color info_color=Aqua;
//----
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+  
int init()
{
 if(lbbars<=0) lbbars=Bars;
 else
 {
  lbbars=LookBackDays*24*60/Period();
  if(lbbars>Bars) lbbars=Bars;
 }
 return(0);
}
//+------------------------------------------------------------------+
int deinit()
{
 return(0);
}  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
{ 
 if(thistime==iTime(NULL,0,0)) return(0);
 thistime=iTime(NULL,0,0);

 int start,shift,shiftD,shiftHi,shiftLo;
 datetime time,timeD,timeE,timeE1,timeE2,timeE3;
 double high,low,diff,triggerUpL,triggerUpH,triggerDnH,triggerDnL;
 bool trade;
 string name,info;

 int countedBars=IndicatorCounted();
 if(countedBars==0) shift=lbbars-1;
 else shift=0; 

 for(int i=shift;i>=0;i--)
 {
  time=iTime(NULL,0,i); 
  shiftD=iBarShift(NULL,PERIOD_D1,time,false); 
  if(lastD1==iTime(NULL,PERIOD_D1,shiftD)) continue;
  if(TimeDayOfWeek(time)==0) continue;

  timeD=iTime(NULL,PERIOD_D1,shiftD);

  start=timeD+Order_Start_Hour*3600+Order_Start_Minute*60;

  if(time>=start)
  {  
   lastD1  = iTime(NULL,PERIOD_D1,shiftD);
   shiftHi = iHighest(NULL,0,MODE_HIGH,Analysis_LookBack,i); 
   high    = iHigh(NULL,0,shiftHi);
   shiftLo = iLowest(NULL,0,MODE_LOW,Analysis_LookBack,i);   
   low     = iLow(NULL,0,shiftLo);
   diff    = (high-low) / Point;
   triggerUpL = NormDigits(high       + NormPoints(Upper_Buffer));
   triggerUpH = NormDigits(triggerUpL + NormPoints(Entry_Buffer));
   triggerDnH = NormDigits(low        - NormPoints(Lower_Buffer));
   triggerDnL = NormDigits(triggerDnH - NormPoints(Entry_Buffer));
   
   trade=false;
   if(diff>=BoxHeightMIN && diff<=BoxHeightMAX) trade=true;

   timeE1=iTime(NULL,PERIOD_D1,shiftD)+Order_End_Time*3600;
   timeE2=time - (Analysis_LookBack - 1)   * Period() * 60.0;
   timeE3=time - (Analysis_LookBack/2 - 1) * Period() * 60.0;
   name = StringConcatenate("pmm_Box_",TimeYear(time),".",TimeMonth(time),".",TimeDay(time));
   if (!ObjectCreate(name,OBJ_RECTANGLE,0,time,low,timeE2,high,0,0))
   {
    Print("MT4 error: cannot draw the rectangle. Error ",GetLastError());
   }
   else
   {
    ObjectSet(name,OBJPROP_COLOR,NavajoWhite);
   }
   
   name = StringConcatenate("pmm_Text_",TimeYear(time),".",TimeMonth(time),".",TimeDay(time));   
   ObjectCreate(name,OBJ_TEXT,0,timeE3,high+NormPoints(10));
   info=StringConcatenate(Symbol()," H",DoubleToStr(high,Digits)," L",DoubleToStr(low,Digits),"=",DoubleToStr(diff,0));
   ObjectSetText(name,info,info_font_size,info_font,info_color);
   if(!trade) 
   {
    name = StringConcatenate("pmm_Text_NoTrade_",TimeYear(time),".",TimeMonth(time),".",TimeDay(time));   
    ObjectCreate(name,OBJ_TEXT,0,timeE3,low-NormPoints(10));
    info="EXCEEDS MAX/MIN: NO TRADE!!";
    ObjectSetText(name,info,info_font_size,info_font,info_color);     
   }

   if(!trade) continue;

   name = StringConcatenate("pmm_Stripe_A_",TimeYear(time),".",TimeMonth(time),".",TimeDay(time));
   if(!ObjectCreate(name,OBJ_RECTANGLE,0,time,triggerUpL,timeE1,triggerUpH,0,0))
   {
    Print("MT4 error: cannot draw stripe A. Error ",GetLastError());
   }
   else
   {
    ObjectSet(name,OBJPROP_COLOR,DarkGreen);
   }

   name = StringConcatenate("pmm_Stripe_C_",TimeYear(time),".",TimeMonth(time),".",TimeDay(time));
   if(!ObjectCreate(name,OBJ_RECTANGLE,0,time,triggerDnH,timeE1,triggerDnL,0,0))
   {
    Print("MT4 error: cannot draw stripe C. Error ",GetLastError());
   }
   else
   {
    ObjectSet(name,OBJPROP_COLOR,Maroon);           
   }
  }
 }
return(0);
}
//+------------------------------------------------------------------+
double NormDigits(double price)
{
 return(NormalizeDouble(price,Digits));
}
//+------------------------------------------------------------------+
double NormPoints(double price)
{
 return(NormalizeDouble(price*Point,Digits));
}
//+------------------------------------------------------------------+


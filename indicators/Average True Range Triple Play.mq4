//+----------------------------------------------------------------------+
//|                                   Average True Range Triple Play.mq4 |
//|                                                         David J. Lin |
//|Average True Range Triple Play                                        |
//|for Mike Skeffington (mike@skeff.com)                                 |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|(dave.j.lin@gmail.com)                                                |
//|Evanston, IL, March 18, 2012                                          |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2012, Mike Skeffington & David J. Lin"
#property link      ""

#property indicator_chart_window // use when ChartDisplay is false 
//#property indicator_separate_window // use when ChartDisplay is true 
#property indicator_buffers 3

extern int ATR1_Period=6;      // period for first ATR
extern int ATR2_Period=12;     // period for second ATR
extern int ATR3_Period=24;     // period for third ATR

double a1[],a2[],a3[];
int BarWidth=1;
bool ChartDisplay=false; // false: use indicator_chart_window, true: use indicator_separate_window 
color ATR1_Color=Blue;  // color for the first ATR
color ATR2_Color=Red;  // color for the second ATR
color ATR3_Color=Lime;  // color for the third ATR
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
 IndicatorShortName("Average True Range Triple Play");
 int type;
 if(ChartDisplay) type=DRAW_LINE;
 else             type=DRAW_NONE;

 SetIndexBuffer(0,a1);
 SetIndexBuffer(1,a2);
 SetIndexBuffer(2,a3);
 
 SetIndexLabel(0,StringConcatenate("ATR1 (",DoubleToStr(ATR1_Period,0),")"));
 SetIndexLabel(1,StringConcatenate("ATR2 (",DoubleToStr(ATR2_Period,0),")"));
 SetIndexLabel(2,StringConcatenate("ATR3 (",DoubleToStr(ATR3_Period,0),")")); 
  
 if(ChartDisplay)
 { 
  SetIndexStyle(0,type,EMPTY,BarWidth,ATR1_Color);
  SetIndexStyle(1,type,EMPTY,BarWidth,ATR2_Color);
  SetIndexStyle(2,type,EMPTY,BarWidth,ATR3_Color);
 }

 ResetBuffers();
 
 string timename;
 switch(Period())
 {
  case 1: timename=" M1";
  break;
  case 5: timename=" M5";
  break;
  case 15: timename=" M15";
  break;  
  case 30: timename=" M30";
  break;  
  case 60: timename=" H1";
  break;
  case 240: timename=" H4";
  break;  
  case 1440: timename=" D1";
  break;  
  case 10080: timename=" W1";
  break;  
  default: timename=" MN";
  break;  
 }
 
//----
 return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
//----
 ResetBuffers();
//----
 return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{   
 int i,bias,imax,counted_bars=IndicatorCounted();
 if(counted_bars>0) imax=Bars-counted_bars;
 else imax=Bars-1;    

//----
 for(i=imax;i>=0;i--) 
 {
  FillATR(i);
 } 
//----
 return(0);
}
//+------------------------------------------------------------------+
void ResetBuffers() 
{
 SetIndexEmptyValue(0,0.0);
 SetIndexEmptyValue(1,0.0);
 SetIndexEmptyValue(2,0.0);
 return;
}
//+------------------------------------------------------------------+
void FillATR(int shift)
{
 a1[shift]=iATR(NULL,0,ATR1_Period,shift);
 a2[shift]=iATR(NULL,0,ATR2_Period,shift);
 a3[shift]=iATR(NULL,0,ATR3_Period,shift);  
 return;
}
//+------------------------------------------------------------------+


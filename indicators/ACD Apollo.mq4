//+----------------------------------------------------------------------+
//|                                                       ACD Apollo.mq4 |
//|                                                         David J. Lin |
//| Pivot Range and Previous High/Low                                    |
//| adapted for use with Apollo                                          |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|dave.j.lin@sbcglobal.net                                              |
//|Evanston, IL, January 20, 2008                                        |
//+----------------------------------------------------------------------+
#property copyright "2008 David J. Lin"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Red
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_color4 White
#property indicator_color5 White
//Input Params
int UpdateTime=1;
//----
double Buffer1[];
double Buffer2[];
double Buffer3[];
double Buffer4[];
double Buffer5[];

//----
double pivotRangeHigh;
double pivotRangeLow;
double pivotRangeClose;
double pivotPoint;
double pivotDiff;
//----
double pivotTop=0;
double pivotBottom=0;
datetime lasttime;
int lookback,Updatetime1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
{
 SetIndexStyle(0,DRAW_LINE, STYLE_DOT, 1);
 SetIndexBuffer(0,Buffer1);
 SetIndexLabel(0,"Pivot Point");
 SetIndexStyle(1,DRAW_LINE, STYLE_DASH, 1);
 SetIndexBuffer(1,Buffer2);
 SetIndexLabel(1,"Pivot Range Top");
 SetIndexStyle(2,DRAW_LINE, STYLE_DASH, 1);
 SetIndexBuffer(2,Buffer3);
 SetIndexLabel(2,"Pivot Range Bottom");
 SetIndexStyle(3,DRAW_LINE, STYLE_SOLID, 1);
 SetIndexBuffer(3,Buffer4);
 SetIndexLabel(3,"Previous Day High");
 SetIndexStyle(4,DRAW_LINE, STYLE_SOLID, 1);
 SetIndexBuffer(4,Buffer5);
 SetIndexLabel(4,"Previous Day Low");
 
 Updatetime1=3600; // seconds per hour 

 if(Period()>=1440) lookback=0;
 else               lookback=1440/Period(); 
 return(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
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
 if(lookback==0) return(-1);
 if(lasttime==iTime(NULL,0,0)) return(-1);
 lasttime=iTime(NULL,0,0);
   
 int barTime,barD1Time,barD1plus1HTime,index,shift,day,hour;

 int counted_bars = IndicatorCounted();
 if(counted_bars==0) index=Bars-1;
 else                index=1;
   
 for(int i=index; i>=0; i--)
 {
  barTime=iTime(NULL,0,i);
  shift=iBarShift(NULL,PERIOD_D1,barTime,false);
  
  day = TimeDayOfWeek(barTime);
  hour= TimeHour(barTime);
       if(day==0) shift+=1; // Sunday: use Friday
  else if(day==1&&hour==0) shift+=2; // Monday 0:00: use Friday
  else if(hour==0)  shift+=1; // don't update until 1:00 ... go to previous day's 1:00 if on 0:00 bar
  
  barD1Time=iTime(NULL,PERIOD_D1,shift);
  
  barD1plus1HTime=barD1Time+Updatetime1;

  shift=iBarShift(NULL,0,barD1plus1HTime,false);
  
  calculatePivotRangeValues(shift);
  drawIndicators(i);   
 }
 return(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculatePivotRangeValues(int i)
{
 int shift=iHighest(NULL, 0, MODE_HIGH, lookback, i+1);
 pivotRangeHigh=iHigh(NULL,0,shift);
 shift=iLowest(NULL, 0, MODE_LOW, lookback, i+1);
 pivotRangeLow=iLow(NULL,0,shift);
 pivotRangeClose=iClose(NULL,0,i+1);
 pivotPoint=(pivotRangeHigh + pivotRangeLow + pivotRangeClose)/3.;
 pivotDiff=MathAbs(((pivotRangeHigh + pivotRangeLow)/2.) - pivotPoint);
 pivotTop=pivotPoint + pivotDiff;
 pivotBottom=pivotPoint - pivotDiff;
 return;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawIndicators(int curBar)
{
 Buffer1[curBar]=pivotPoint;

 Buffer2[curBar]=pivotTop;
 Buffer3[curBar]=pivotBottom;

 Buffer4[curBar]=pivotRangeHigh;
 Buffer5[curBar]=pivotRangeLow;
 
 return;
}
//+------------------------------------------------------------------+
 
 
 


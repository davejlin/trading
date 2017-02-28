//+----------------------------------------------------------------------+
//|                                                              M$M.mq4 |
//|                                                         David J. Lin |
//|M$M indicator: price vs 3 MA of different timeframes                  |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|dave.j.lin@sbcglobal.net                                              |
//|Evanston, IL, September 3, 2008                                       |
//+----------------------------------------------------------------------+
#property copyright "2008 David J. Lin"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 Blue
#property indicator_color2 Blue
#property indicator_color3 Gold
#property indicator_color4 Gold
#property indicator_color5 Red
#property indicator_color6 Red
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 1
#property indicator_width5 1
#property indicator_width6 1

//---- input parameters
extern bool Alarm=true;
extern int Period1=21;
extern int Period2=21;
extern int Period3=21;
extern int Shift1=0;
extern int Shift2=0;
extern int Shift3=0;
extern int Method1=MODE_EMA;
extern int Method2=MODE_EMA;
extern int Method3=MODE_EMA;
extern int Price1=PRICE_CLOSE;
extern int Price2=PRICE_CLOSE;
extern int Price3=PRICE_CLOSE;
extern int TF2=PERIOD_M5;
extern int TF3=PERIOD_M15;
//---- buffers
double aboveH[],aboveL[],middleH[],middleL[],belowH[],belowL[];
datetime time;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
 SetIndexBuffer(0,aboveH);  
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexLabel(0, "above_H");

 SetIndexBuffer(1,aboveL);  
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexLabel(1, "above_L"); 

 SetIndexBuffer(2,middleH);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexLabel(2, "middle_H");

 SetIndexBuffer(3,middleL);
 SetIndexStyle(3,DRAW_HISTOGRAM);
 SetIndexLabel(3, "middle_L");

 SetIndexBuffer(4,belowH);
 SetIndexStyle(4,DRAW_HISTOGRAM);
 SetIndexLabel(4, "below_H");

 SetIndexBuffer(5,belowL);
 SetIndexStyle(5,DRAW_HISTOGRAM);
 SetIndexLabel(5, "below_L"); 
  
 string myName=StringConcatenate("M$M (",Period(),",",TF2,",",TF3,")");
 IndicatorShortName(myName);  
 Comment(myName);
//----
return(0);
}
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function |
//+------------------------------------------------------------------+
int deinit()
{
//----
return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function |
//+------------------------------------------------------------------+
int start()
{ 
 int shift,i,imax,counted_bars=IndicatorCounted();
 double close1,ma1,ma2,ma3;
 if(counted_bars>0) imax=Bars-counted_bars;
 else imax=Bars-1; 
 for(i=imax;i>=0;i--) 
 {
  ma1=iMA(NULL,0,Period1,Shift1,Method1,Price1,i);
  shift=iBarShift(NULL,TF2,iTime(NULL,0,i));
  ma2=iMA(NULL,TF2,Period2,Shift2,Method2,Price2,shift);
  shift=iBarShift(NULL,TF3,iTime(NULL,0,i));  
  ma3=iMA(NULL,TF3,Period3,Shift3,Method3,Price3,shift);    
  
  close1=iClose(NULL,0,i);
  
  clear(i);
  
  if(close1>ma1&&close1>ma2&&close1>ma3) 
  { 
   aboveH[i]=iHigh(NULL,0,i);
   aboveL[i]=iLow(NULL,0,i);
  }
  else if(close1<ma1&&close1<ma2&&close1<ma3) 
  { 
   belowH[i]=iHigh(NULL,0,i);
   belowL[i]=iLow(NULL,0,i);
  }  
  else
  {
   middleH[i]=iHigh(NULL,0,i);
   middleL[i]=iLow(NULL,0,i);  
  }
  
  if(i>0) continue;
  
  if(!Alarm) continue;
  
  if(aboveH[i+1]==EMPTY_VALUE && aboveH[i]!=EMPTY_VALUE) Alert("BUY!!");
  else if(belowH[i+1]==EMPTY_VALUE && belowH[i]!=EMPTY_VALUE) Alert("SELL!!");
  
 } 
}
//+------------------------------------------------------------------+
void clear(int i)
{
 aboveH[i]=EMPTY_VALUE;
 aboveL[i]=EMPTY_VALUE;
 belowH[i]=EMPTY_VALUE;
 belowL[i]=EMPTY_VALUE; 
 middleH[i]=EMPTY_VALUE;
 middleL[i]=EMPTY_VALUE; 
 return;     
}
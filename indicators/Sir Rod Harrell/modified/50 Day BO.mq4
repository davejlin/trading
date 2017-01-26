//+------------------------------------------------------------------+
//|                                                    50 Day BO.mq4 |
//|                                                     David J. Lin |
//|                                                                  |
//|Coded by David J. Lin                                             |
//|dave.j.lin@sbcglobal.net                                          |
//|Evanston, IL, June 26, 2007                                       |
//+------------------------------------------------------------------+
//
#property copyright "Copyright © 2007 David J. Lin"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 LimeGreen
#property indicator_color2 Red
//---- input parameters
extern int D1_Period=50;
int tf=PERIOD_D1;
double v1[],v2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int init()
  {
//---- indicators

IndicatorBuffers(2);
SetIndexStyle(0,DRAW_LINE,0,2,LimeGreen);
SetIndexBuffer(0,v1);
SetIndexStyle(1,DRAW_LINE,0,2,Red);
SetIndexBuffer(1,v2);
SetIndexLabel(0, "High ("+D1_Period+")");
SetIndexLabel(1, "Low ("+D1_Period+")");

//---- indicators

//----
   return(0);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
 if(iBars(NULL,tf)<D1_Period) return(0);

 int i,shift1,shift2; double phigh,plow;
 int counted_bars = IndicatorCounted();
 //---- last counted bar will be recounted
 if(counted_bars>0) counted_bars--;
 else counted_bars=1;
 
 int limit = Bars - counted_bars;
 
 //---- computations for D1 high/low
 for(i=limit;i>=0;i--)
 {
  shift1=iBarShift(NULL,tf,Time[i],false);
  if(i==0) shift1+=1;
  shift2=iHighest(NULL,tf,MODE_HIGH,D1_Period,shift1);
  phigh=iHigh(NULL,tf,shift2);
  shift2=iLowest(NULL,tf,MODE_LOW,D1_Period,shift1);
  plow=iLow(NULL,tf,shift2);

  v1[i]=phigh;
  v2[i]=plow;
 }
 return(0);
}
//+------------------------------------------------------------------
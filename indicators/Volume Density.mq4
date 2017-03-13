//+----------------------------------------------------------------------+
//|                                                   Volume Density.mq4 |
//|                                                         David J. Lin |
//| Displays Volume per Price spread (Volume Density)                    |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|dave.j.lin@sbcglobal.net                                              |
//|Evanston, IL, May 26, 2007                                            |
//+----------------------------------------------------------------------+
#property copyright "2007 David J. Lin"
#property link      ""

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 White
#property indicator_minimum 0
#property indicator_level1 1
#property indicator_level2 5
#property indicator_level3 10
#property indicator_level4 15
#property indicator_level5 20

//---- input parameters

//---- buffers
double VD[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
IndicatorBuffers(1);
SetIndexStyle(0,DRAW_LINE);
SetIndexBuffer(0,VD);
SetIndexLabel(0, "Volume Density");
IndicatorShortName("Volume Density");
//----
return(0);
}
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function |
//+------------------------------------------------------------------+
int deinit()
{
//----

//----
return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function |
//+------------------------------------------------------------------+
int start()
{
 int i,limit; double spread;
 int counted_bars = IndicatorCounted();
 //---- last counted bar will be recounted
 if(counted_bars>0) counted_bars--;
 else counted_bars=1;
 
 limit = Bars - counted_bars;
 
 //---- computations for volume density
 for(i=limit;i>=0;i--)
 {
  spread=(High[i]-Low[i])/Point;
  VD[i]=Volume[i]/MathMax(spread,1);
 }
 return(0);
}
//+------------------------------------------------------------------+ 
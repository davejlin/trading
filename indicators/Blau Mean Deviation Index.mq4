//+----------------------------------------------------------------------+
//|                                             Mean Deviation Index.mq4 |
//|                                                         David J. Lin |
//| Displays William Blau's Mean Deviation Index                         |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|dave.j.lin@sbcglobal.net                                              |
//|Evanston, IL, August 19, 2008                                         |
//+----------------------------------------------------------------------+
#property copyright "2008 David J. Lin"
#property link      ""

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 White
#property indicator_color2 Red
//#property indicator_maximum 100
//#property indicator_minimum -100

//---- input parameters
extern int r=32;
extern int s=5;

//---- buffers
double MDI[],Sig[],Detrend[],EMA[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
IndicatorBuffers(3);
SetIndexStyle(0,DRAW_LINE);
SetIndexBuffer(0,MDI);
SetIndexLabel(0, "MDI");
SetIndexStyle(1,DRAW_LINE);
SetIndexBuffer(1,Sig);
SetIndexLabel(1, "Signal");
SetIndexStyle(2,DRAW_NONE);
SetIndexBuffer(2,Detrend);
SetIndexLabel(2, "Detrend");

IndicatorShortName("Mean Deviation Index ("+r+","+s+")");
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
 int i,limit;
 int counted_bars = IndicatorCounted();
 //---- last counted bar will be recounted
 if(counted_bars>0) counted_bars--;
 else counted_bars=1;
 
 limit = Bars - counted_bars;
 
 for(i=limit;i>=0;i--)
 {
  Detrend[i]=Close[i]-iMA(NULL,0,r,0,MODE_EMA,PRICE_CLOSE,i);
 }
 
 for(i=limit;i>=0;i--)
 {   
  MDI[i]=iMAOnArray(Detrend,0,s,0,MODE_EMA,i);
 }

 for(i=limit;i>=0;i--)
 { 
  Sig[i]=iMAOnArray(MDI,0,s,0,MODE_EMA,i);
 }
 
 return(0);
}
//+------------------------------------------------------------------+ 
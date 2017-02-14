//+----------------------------------------------------------------------+
//|                                                    Cross Overlay.mq4 |
//|                                                         David J. Lin |
//| Plots one cross' line plot over another cross' price chart           |
//| Written in collaboration with Rocko (13rocko@gmail.com)              |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|dave.j.lin@sbcglobal.net                                              |
//|Evanston, IL, February 14, 2007                                       |
//+----------------------------------------------------------------------+
#property copyright "2007 David J. Lin"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow

//---- input parameters
extern string Pair="USDJPYm";

//---- buffers
double close[];
int prev_bars,prev_pair_bars;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
IndicatorBuffers(1);
SetIndexStyle(0,DRAW_LINE);
SetIndexBuffer(0,close);
SetIndexLabel(0, "Close");
IndicatorShortName("Close: "+Pair);
prev_bars=0;prev_pair_bars=0;
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
 int counted_bars=IndicatorCounted();
 int pair_bars=iBars(Pair,0);
 if(prev_bars==counted_bars && prev_pair_bars==pair_bars) return;
 prev_bars=counted_bars; prev_pair_bars=pair_bars;
 
 double NBars=WindowBarsPerChart();
 double High1=iHigh(Pair,Period(),iHighest(Pair,Period(),MODE_HIGH,NBars,0));
 double Low1 =iLow(Pair,Period(),iLowest(Pair,Period(),MODE_LOW,NBars,0));
 double Diff1=High1-Low1;
 double High2=iHigh(NULL,Period(),iHighest(NULL,Period(),MODE_HIGH,NBars,0));
 double Low2=iLow(NULL,Period(),iLowest(NULL,Period(),MODE_LOW,NBars,0)); 
 double Diff2=High2-Low2;
 double Ratio=Diff2/Diff1;
  
 for(int i=Bars;i>=0;i--)
 {
//  double price=0.5*(iHigh(Pair,Period(),i)+iLow(Pair,Period(),i));
  double price=iClose(Pair,Period(),i);
  close[i]=Low2+(price-Low1)*Ratio;
 }
 return(0);
}
//+------------------------------------------------------------------+ 


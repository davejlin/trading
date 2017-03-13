//+----------------------------------------------------------------------+
//|                                                Volume UpDownTick.mq4 |
//|                                                         David J. Lin |
//| Displays Volume UpTicks & DownTicks                                  |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|dave.j.lin@sbcglobal.net                                              |
//|Evanston, IL, August 18, 2008                                         |
//+----------------------------------------------------------------------+
#property copyright "2008 David J. Lin"
#property link      ""

#property indicator_separate_window
#property indicator_color1 White
#property indicator_color2 Green
#property indicator_color3 Red

//---- input parameters

//---- buffers
double Vd[],VU[],VD[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
IndicatorBuffers(3);
SetIndexStyle(0,DRAW_LINE);
SetIndexBuffer(0,Vd);
SetIndexLabel(0, "Volume Diff");
SetIndexStyle(1,DRAW_NONE);
SetIndexBuffer(1,VU);
SetIndexLabel(1, "Volume Up");
SetIndexStyle(2,DRAW_NONE);
SetIndexBuffer(2,VD);
SetIndexLabel(2, "Volume Down");

IndicatorShortName("Volume UpDownTick");
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
 int i,limit,v;double p;
 int counted_bars = IndicatorCounted();
 //---- last counted bar will be recounted
 if(counted_bars>0) counted_bars--;
 else counted_bars=1;
 
 limit = Bars - counted_bars;
 
 //---- computations for volume density
 for(i=limit;i>=0;i--)
 {
  v=Volume[i];
  p=(Close[i]-Open[i])/Point;
  VU[i]=(v+p)/2;
  VD[i]=(v-p)/2;  
  Vd[i]=VU[i]-VD[i];
 }
 return(0);
}
//+------------------------------------------------------------------+ 
//+----------------------------------------------------------------------+
//|                                            Candlestick Indicator.mq4 |
//|                                                         David J. Lin |
//| Displays William Blau's Candlestick Indicator                        |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|dave.j.lin@sbcglobal.net                                              |
//|Evanston, IL, August 20, 2008                                         |
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
double CSI[],Sig[],CO[],HL[],EMA1[],EMA2[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
IndicatorBuffers(6);
SetIndexStyle(0,DRAW_LINE);
SetIndexBuffer(0,CSI);
SetIndexLabel(0, "CSI");
SetIndexStyle(1,DRAW_LINE);
SetIndexBuffer(1,Sig);
SetIndexLabel(1, "Signal");
SetIndexStyle(2,DRAW_NONE);
SetIndexBuffer(2,CO);
SetIndexLabel(2, "Close-Open");
SetIndexStyle(3,DRAW_NONE);
SetIndexBuffer(3,HL);
SetIndexLabel(3, "High-Low");
SetIndexStyle(4,DRAW_NONE);
SetIndexBuffer(4,EMA1);
SetIndexLabel(4, "EMA 1");
SetIndexStyle(5,DRAW_NONE);
SetIndexBuffer(5,EMA2);
SetIndexLabel(5, "EMA 2");

IndicatorShortName("Candlestick Indicator ("+r+","+s+")");
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
 int i,limit,v;double dema1,dema2;
 int counted_bars = IndicatorCounted();
 //---- last counted bar will be recounted
 if(counted_bars>0) counted_bars--;
 else counted_bars=1;
 
 limit = Bars - counted_bars;
 
 for(i=limit;i>=0;i--)
 {
  CO[i]=Close[i]-Open[i];
  HL[i]=High[i]-Low[i]; 
 }
 
 for(i=limit;i>=0;i--)
 {   
  EMA1[i]=iMAOnArray(CO,0,r,0,MODE_EMA,i);
  EMA2[i]=iMAOnArray(HL,0,r,0,MODE_EMA,i);  
 }

 for(i=limit;i>=0;i--)
 {   
  dema1=iMAOnArray(EMA1,0,s,0,MODE_EMA,i);
  dema2=iMAOnArray(EMA2,0,s,0,MODE_EMA,i);  
  CSI[i]=100*dema1/dema2;  
 } 

 for(i=limit;i>=0;i--)
 { 
  Sig[i]=iMAOnArray(CSI,0,s,0,MODE_EMA,i);
 }
 
 return(0);
}
//+------------------------------------------------------------------+ 
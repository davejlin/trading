//+----------------------------------------------------------------------+
//|                                        Stochastic Momentum Index.mq4 |
//|                                                         David J. Lin |
//| Displays William Blau's Stochastic Momentum Index                    |
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
extern int q=1;
extern int r=32;
extern int s=5;

//---- buffers
double SMI[],Sig[],SM[],R[],EMA1[],EMA2[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
IndicatorBuffers(6);
SetIndexStyle(0,DRAW_LINE);
SetIndexBuffer(0,SMI);
SetIndexLabel(0, "SMI");
SetIndexStyle(1,DRAW_LINE);
SetIndexBuffer(1,Sig);
SetIndexLabel(1, "Signal");
SetIndexStyle(2,DRAW_NONE);
SetIndexBuffer(2,SM);
SetIndexLabel(2, "Stoch Momentum");
SetIndexStyle(3,DRAW_NONE);
SetIndexBuffer(3,R);
SetIndexLabel(3, "Range");
SetIndexStyle(4,DRAW_NONE);
SetIndexBuffer(4,EMA1);
SetIndexLabel(4, "EMA Momentum 1");
SetIndexStyle(5,DRAW_NONE);
SetIndexBuffer(5,EMA2);
SetIndexLabel(5, "EMA Momentum 2");

IndicatorShortName("Stochastic Momentum Index ("+q+","+r+","+s+")");
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
 int i,limit,v;double highest,lowest,dema1,dema2;
 int counted_bars = IndicatorCounted();
 //---- last counted bar will be recounted
 if(counted_bars>0) counted_bars--;
 else counted_bars=1;
 
 limit = Bars - counted_bars;
 
 for(i=limit;i>=0;i--)
 {
  highest=iHigh(NULL,0,iHighest(NULL,0,MODE_HIGH,q,i));
  lowest=iLow(NULL,0,iLowest(NULL,0,MODE_LOW,q,i));
  SM[i]=Close[i]-0.5*(highest+lowest);
  R[i]=highest-lowest; 
 }
 
 for(i=limit;i>=0;i--)
 {   
  EMA1[i]=iMAOnArray(SM,0,r,0,MODE_EMA,i);
  EMA2[i]=iMAOnArray(R,0,r,0,MODE_EMA,i);  
 }

 for(i=limit;i>=0;i--)
 {   
  dema1=iMAOnArray(EMA1,0,s,0,MODE_EMA,i);
  dema2=0.5*iMAOnArray(EMA2,0,s,0,MODE_EMA,i);  
  SMI[i]=100*dema1/dema2;  
 } 

 for(i=limit;i>=0;i--)
 { 
  Sig[i]=iMAOnArray(SMI,0,s,0,MODE_EMA,i);
 }
 
 return(0);
}
//+------------------------------------------------------------------+ 
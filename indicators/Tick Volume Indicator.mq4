//+----------------------------------------------------------------------+
//|                                            Tick Volume Indicator.mq4 |
//|                                                         David J. Lin |
//| Displays William Blau's Tick Volume Indicator                        |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|dave.j.lin@sbcglobal.net                                              |
//|Evanston, IL, August 18, 2008                                         |
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
int r=32;
int s=5;

//---- buffers
double TVI[],VU[],VD[],EMAU[],EMAD[],Sig[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
IndicatorBuffers(6);
SetIndexStyle(0,DRAW_LINE);
SetIndexBuffer(0,TVI);
SetIndexLabel(0, "TVI");
SetIndexStyle(1,DRAW_LINE);
SetIndexBuffer(1,Sig);
SetIndexLabel(1, "Signal");
SetIndexStyle(2,DRAW_NONE);
SetIndexBuffer(2,VU);
SetIndexLabel(2, "Volume Up");
SetIndexStyle(3,DRAW_NONE);
SetIndexBuffer(3,VD);
SetIndexLabel(3, "Volume Down");
SetIndexStyle(4,DRAW_NONE);
SetIndexBuffer(4,EMAU);
SetIndexLabel(4, "EMA Up");
SetIndexStyle(5,DRAW_NONE);
SetIndexBuffer(5,EMAD);
SetIndexLabel(5, "EMA Down");

IndicatorShortName("Tick Volume Indicator ("+r+","+s+")");
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
 int i,limit,v;double p,demaup,demadn;
 int counted_bars = IndicatorCounted();
 //---- last counted bar will be recounted
 if(counted_bars>0) counted_bars--;
 else counted_bars=1;
 
 limit = Bars - counted_bars;
 
 for(i=limit;i>=0;i--)
 {
  v=Volume[i];
  p=(Close[i]-Open[i])/Point;
  VU[i]=(v+p)/2;
  VD[i]=(v-p)/2;   
 }
 
 for(i=limit;i>=0;i--)
 {   
  EMAU[i]=iMAOnArray(VU,0,r,0,MODE_EMA,i);
  EMAD[i]=iMAOnArray(VD,0,r,0,MODE_EMA,i);  
 }

 for(i=limit;i>=0;i--)
 {   
  demaup=iMAOnArray(EMAU,0,s,0,MODE_EMA,i);
  demadn=iMAOnArray(EMAD,0,s,0,MODE_EMA,i);  
  TVI[i]=100*(demaup-demadn)/(demaup+demadn);  
 } 

 for(i=limit;i>=0;i--)
 { 
  Sig[i]=iMAOnArray(TVI,0,s,0,MODE_EMA,i);
 }
 
 return(0);
}
//+------------------------------------------------------------------+ 
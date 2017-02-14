//+----------------------------------------------------------------------+
//|                                                  Composite Index.mq4 |
//|                                                         David J. Lin |
//| Composite Index for Paul Dean (pdean123@embarqmail.com)              |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|dave.j.lin@sbcglobal.net                                              |
//|Evanston, IL, September 30, 2008                                      |
//+----------------------------------------------------------------------+
#property copyright "2008 David J. Lin"
#property link      ""

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Green

//---- input parameters
extern int RSIPeriod1=14;
extern int RSIPeriod2=3;
extern int RSIMomentum=9;
extern int RSIsmPeriod=3;
extern int RSIAve1=13;
extern int RSIAve2=33;

//---- buffers
double P1[],P2[],P3[],RSIdelta[],RSIsma[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
IndicatorBuffers(5);
SetIndexStyle(0,DRAW_LINE);
SetIndexBuffer(0,P1);
SetIndexStyle(1,DRAW_LINE);
SetIndexBuffer(1,P2);
SetIndexStyle(2,DRAW_LINE);
SetIndexBuffer(2,P3);
SetIndexStyle(3,DRAW_NONE);
SetIndexBuffer(3,RSIdelta);
SetIndexStyle(4,DRAW_NONE);
SetIndexBuffer(4,RSIsma);
IndicatorShortName("Composite Index");
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
 int i,j,limit; double ave;
 int counted_bars = IndicatorCounted();
 //---- last counted bar will be recounted
 if(counted_bars>0) counted_bars--;
 else counted_bars=1;
 
 limit = Bars - counted_bars;
 
 //---- computations for PMI
 for(i=limit;i>=0;i--)
 {
  RSIdelta[i]=iRSI(NULL,0,RSIPeriod1,PRICE_CLOSE,i)-iRSI(NULL,0,RSIPeriod1,PRICE_CLOSE,i+RSIMomentum);
  ave=0;
  for(j=0;j<RSIsmPeriod;j++)
  {
   ave+=iRSI(NULL,0,RSIPeriod1,PRICE_CLOSE,i+j);
  }
  ave/=RSIsmPeriod;
  RSIsma[i]=ave;
 }

 for(i=limit;i>=0;i--)
 { 
  P1[i]=RSIdelta[i]+RSIsma[i];
 }
 
 for(i=limit;i>=0;i--)
 { 
  ave=0; 
  for(j=0;j<RSIAve1;j++)
  {
   ave+=P1[i+j];
  }
  ave/=RSIAve1;
 
  P2[i]=ave;

  ave=0; 
  for(j=0;j<RSIAve2;j++)
  {
   ave+=P1[i+j];
  }
  ave/=RSIAve2;
 
  P3[i]=ave;  
  
 }
 
 return(0);
}
//+------------------------------------------------------------------+ 
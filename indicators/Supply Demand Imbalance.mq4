//+----------------------------------------------------------------------+
//|                                          Supply Demand Imbalance.mq4 |
//|                                                         David J. Lin |
//| Quantitatively determines Supply & Demand imbalances as defined by   |
//| Sam Seiden <njstrader@yahoo.com>,                                    |
//| identifying relatively large range bars by plotting                  |
//| pips range on close-open basis                                       | 
//| multiplied by distance to last mid-point                             |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|dave.j.lin@sbcglobal.net                                              |
//|Evanston, IL, July 12, 2008                                           |
//|                                                                      |
//|made MTF July 20, 2008                                                |
//+----------------------------------------------------------------------+
#property copyright "2008 David J. Lin"
#property link      ""

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue

//#property indicator_minimum 0
#property indicator_level1 10
#property indicator_level2 -10
#property indicator_level3 25
#property indicator_level4 -25
#property indicator_level5 50
#property indicator_level6 -50
#property indicator_level7 100
#property indicator_level8 -100

//---- input parameters
extern int TimeFrame=0;
extern int BarMin=4;    // number of bars to calculate midpoint/average
//---- buffers
double SDI[],Ave[];
bool norun;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
norun=false;
if(BarMin==0) 
{
 norun=true;
 return;
}

//---- indicators
IndicatorBuffers(2);

SetIndexBuffer(0,SDI);
SetIndexStyle(0,DRAW_LINE);
SetIndexDrawBegin(0,BarMin);
SetIndexLabel(0, "SDI");

SetIndexBuffer(1,Ave);
SetIndexStyle(1,DRAW_LINE);
SetIndexDrawBegin(1,BarMin);
SetIndexLabel(1, "Ave");

//SetIndexDrawBegin(0,BarMin);
SetIndexDrawBegin(1,BarMin);
IndicatorShortName("Supply Demand Imbalance ("+BarMin+")");

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
 if(norun) return(-1);
 int i,j,shift,limit;
 double average,range1,range2,range3,range4,mid1,mid2,log,close0,close1,open0,open1,high0,high1,low0,low1;
 int counted_bars = IndicatorCounted();
 //---- last counted bar will be recounted
 if(counted_bars>0) counted_bars--;
 else counted_bars=1;
 
 limit = Bars - counted_bars;
 
 //---- computations for supply demand imblance
 for(i=limit;i>=0;i--)
 {
  shift=iBarShift(NULL,TimeFrame,iTime(NULL,0,i),false);

  close0=iClose(NULL,TimeFrame,shift);
  close1=iClose(NULL,TimeFrame,shift+1);
  
  open0=iOpen(NULL,TimeFrame,shift);
  open1=iOpen(NULL,TimeFrame,shift+1);

  mid1=MathAbs(close0+open0);
  mid2=MathAbs(close1+open1);
  
  range1=0.5*MathAbs(mid1-mid2)/Point; // midpoint distance (midpoint of 1 minus midpoint of 2)

  mid1=MathAbs(close0-open0);
  mid2=MathAbs(close1-open1);
  
  range2=MathAbs(mid1-mid2)/Point; // difference of open/close range
  
  high0=iHigh(NULL,TimeFrame,shift);
  high1=iHigh(NULL,TimeFrame,shift+1);
  
  low0=iLow(NULL,TimeFrame,shift);
  low1=iLow(NULL,TimeFrame,shift+1);
   
  range3=MathAbs(high0-high1)/Point; // compare high distance 
  range4=MathAbs(low0-low1)/Point; // compare low distance
  
  SDI[i]=range1*range2*range3*range4;
  
//  if(mid==0) SDI[i]=0;
//  else
//  {
//   log=MathLog(range1*mid);
//   if(log<0) SD[i]=0;
//   else SD[i]=log;
//  }

  average=0;
  for(j=i;j<i+BarMin;j++)
  {
   average+=SDI[j];
  }
  
  Ave[i]=average/BarMin;  
 
 }
 return(0);
}
//+------------------------------------------------------------------+ 
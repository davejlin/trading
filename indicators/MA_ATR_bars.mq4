//+----------------------------------------------------------------------+
//|                                                      MA_ATR_bars.mq4 |
//|                                                         David J. Lin |
//|Create a blue bar when close is below the short-MA, above the long-MA |
//|and a red bar when close is above the short-MA, below the short-MA    |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|(dave.j.lin@sbcglobal.net)                                            |
//|Evanston, IL, December 23, 2008                                       |
//+----------------------------------------------------------------------+
#property copyright "David J. Lin"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 8

#property indicator_color1 Blue
#property indicator_color2 Blue
#property indicator_color3 Blue
#property indicator_color4 Blue
#property indicator_color5 Red
#property indicator_color6 Red
#property indicator_color7 Red
#property indicator_color8 Red
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 3
#property indicator_width4 3
#property indicator_width5 1
#property indicator_width6 1
#property indicator_width7 3
#property indicator_width8 3

extern int MA_Period1=8;
extern int MA_Period2=50;

int MA_Shift=0;
int MA_Method=0;
int MA_Price=PRICE_CLOSE;

double b1[],b2[],b3[],b4[],b5[],b6[],b7[],b8[];

int bull=1;
int bear=-1;
int pig=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,b1);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,b2);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,b3);
 SetIndexStyle(3,DRAW_HISTOGRAM);
 SetIndexBuffer(3,b4);
 SetIndexStyle(4,DRAW_HISTOGRAM);
 SetIndexBuffer(4,b5);
 SetIndexStyle(5,DRAW_HISTOGRAM);
 SetIndexBuffer(5,b6);
 SetIndexStyle(6,DRAW_HISTOGRAM);
 SetIndexBuffer(6,b7);
 SetIndexStyle(7,DRAW_HISTOGRAM);
 SetIndexBuffer(7,b8);
//----
 return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
//----
   
//----
 return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{   
 int i,bias,imax,counted_bars=IndicatorCounted();
 if(counted_bars>0) imax=Bars-IndicatorCounted();
 else imax=Bars-1;    
//----
 for(i=imax;i>=0;i--) 
 {
  ResetBuffers(i);
  bias=PaintBar(i);
  if(bias>0)
  {
   b1[i] = iHigh(NULL,0,i);
   b2[i] = iLow(NULL,0,i);  
   b3[i] = iOpen(NULL,0,i);
   b4[i] = iClose(NULL,0,i);  
  }
  else if(bias<0)
  {
   b5[i] = iHigh(NULL,0,i);
   b6[i] = iLow(NULL,0,i);  
   b7[i] = iOpen(NULL,0,i);
   b8[i] = iClose(NULL,0,i);
  }
 } 
//----
 return(0);
}

void ResetBuffers(int shift) 
{
 b1[shift] = EMPTY_VALUE;
 b2[shift] = EMPTY_VALUE;
 b3[shift] = EMPTY_VALUE;
 b4[shift] = EMPTY_VALUE;
 b5[shift] = EMPTY_VALUE;
 b6[shift] = EMPTY_VALUE;
 b7[shift] = EMPTY_VALUE;
 b8[shift] = EMPTY_VALUE;
 return;
}
//+------------------------------------------------------------------+
int PaintBar(int shift) 
{
 double close=iClose(NULL,0,shift);
 double MA1=iMA(NULL,0,MA_Period1,MA_Shift,MA_Method,MA_Price,shift);
 double MA2=iMA(NULL,0,MA_Period2,MA_Shift,MA_Method,MA_Price,shift);
      
 if (close<MA1)
 {
  if(close>MA2) return(bull);
 }
 else if (close>MA1) 
 {
  if(close<MA2) return(bear);  
 }
   
 return (pig);
}
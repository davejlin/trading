//+----------------------------------------------------------------------+
//|                                                   Bull Bear Bars.mq4 |
//|                                                         David J. Lin |
//|Create a blue bar when open in bottom 33% and close in top 33% of bar,|
//|and a red bar when open in top 33% and close is bottom 33%.           |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|(dave.j.lin@sbcglobal.net)                                            |
//|Evanston, IL, June 26, 2008                                           |
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

extern double percentage=33.33;

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
 double open=iOpen(NULL,0,shift);
 double close=iClose(NULL,0,shift);
 double high=iHigh(NULL,0,shift);
 double low=iLow(NULL,0,shift);
   
 double range=high-low;
 if(range==0) return(pig);
 
 double OLrange=(open-low)*100/range;
 double OHrange=(high-open)*100/range;
 double CLrange=(close-low)*100/range;
 double CHrange=(high-close)*100/range;
      
 if (OLrange<percentage && CHrange<percentage) return (bull);
 if (OHrange<percentage && CLrange<percentage) return (bear); 
   
 return (pig);
}
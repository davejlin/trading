//+----------------------------------------------------------------------+
//|                                                  Twin Top Bottom.mq4 |
//|                                                         David J. Lin |
//| Marks twin top/bottom formations                                     |
//|(two adjacent bars with the same highs or the same lows            |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|(dave.j.lin@sbcglobal.net)                                            |
//|Evanston, IL, June 30, 2008                                           |
//+----------------------------------------------------------------------+

#property copyright "David J. Lin"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 2

extern int offset=2; // pips above/below bars to paint signal arrow

double SignalH[],SignalL[];

//===========================================================================================
//===========================================================================================
int init() 
{
 SetIndexBuffer(0,SignalH);
 SetIndexStyle(0, DRAW_ARROW,DRAW_ARROW,1,Blue);
 SetIndexArrow(0,SYMBOL_ARROWDOWN);
 SetIndexBuffer(1,SignalL);
 SetIndexStyle(1, DRAW_ARROW,DRAW_ARROW,1,Red); 
 SetIndexArrow(1,SYMBOL_ARROWUP);
 
 return(0);
}
//===========================================================================================
//===========================================================================================
int deinit()
{
 return(0);
}
//===========================================================================================
//===========================================================================================

int start() 
{
 int i,imax,counted_bars=IndicatorCounted();
 double high1,high2,low1,low2;
 if(counted_bars>0) imax=Bars-counted_bars;
 else imax=Bars-1; 
 
 for(i=imax;i>=0;i--) 
 {
  SignalH[i]=EMPTY_VALUE;
  SignalL[i]=EMPTY_VALUE;
  
  high1=iHigh(NULL,0,i);
  high2=iHigh(NULL,0,i+1);
  
  low1=iLow(NULL,0,i);
  low2=iLow(NULL,0,i+1);
  
  if(high1==high2) SignalH[i]=high1+offset*Point;
  if(low1==low2)   SignalL[i]=low1-offset*Point;
  
 }

 return(0);
}
//===========================================================================================
//===========================================================================================


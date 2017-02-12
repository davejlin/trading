//+----------------------------------------------------------------------+
//|                                                      AO_AC_Stoch.mq4 |
//|                                                         David J. Lin |
//| Buy Signal : Positive AO + Stochastic cross up OR                    |
//| Negative Green AO + green AC + Stochastic cross up                   |
//|                                                                      |
//| Sell Signal: Negative AO + Stochastic cross down OR                  |
//| Positive Red AO + Red AC + Stochastic Cross down                     |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|(dave.j.lin@sbcglobal.net)                                            |
//|Evanston, IL, June 26, 2008                                           |
//+----------------------------------------------------------------------+

#property copyright "David J. Lin"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 2

extern int offset=10;               // pips above/below high/low to paint arrows

extern int StochK=5;                // Stochastic %K
extern int StochD=3;                // Stochastic %D 
extern int StochSlowing=3;          // Stochastic Slowing
extern int StochMethod=MODE_SMA;    // Stochastic Method
extern int StochPrice=0;            // Stochastic Price (0=low/high, 1=close/close)

double SignalL[],SignalS[];


//===========================================================================================
//===========================================================================================
int init() 
{
 SetIndexBuffer(0,SignalL);
 SetIndexStyle(0, DRAW_ARROW,DRAW_ARROW,1,Blue);
 SetIndexArrow(0,SYMBOL_ARROWUP);
 SetIndexBuffer(1,SignalS);
 SetIndexStyle(1, DRAW_ARROW,DRAW_ARROW,1,Red); 
 SetIndexArrow(1,SYMBOL_ARROWDOWN);
 
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
 double ao1,ac1,ao2,ac2,sm1,ss1,sm2,ss2;
 if(counted_bars>0) imax=Bars-IndicatorCounted();
 else imax=Bars-1; 
 
 for(i=imax;i>=0;i--) 
 {
  SignalL[i]=EMPTY_VALUE;
  SignalS[i]=EMPTY_VALUE;
  
  ao1=iAO(NULL,0,i);
  ao2=iAO(NULL,0,i+1);
  ac1=iAC(NULL,0,i);
  ac2=iAC(NULL,0,i+1);
  sm1=iStochastic(NULL,0,StochK,StochD,StochSlowing,StochMethod,StochPrice,MODE_MAIN,i);
  sm2=iStochastic(NULL,0,StochK,StochD,StochSlowing,StochMethod,StochPrice,MODE_MAIN,i+1);  
  ss1=iStochastic(NULL,0,StochK,StochD,StochSlowing,StochMethod,StochPrice,MODE_SIGNAL,i);
  ss2=iStochastic(NULL,0,StochK,StochD,StochSlowing,StochMethod,StochPrice,MODE_SIGNAL,i+1);  
  
  if(sm1>ss1) 
  {
   if(ao1>0 || (ao1<0 && ao1>ao2 && ac1>ac2)) SignalL[i]=iLow(NULL,0,i)-offset*Point;
  }
  else if(sm1<ss1) 
  {
   if(ao1<0 || (ao1>0 && ao1<ao2 && ac1<ac2))SignalS[i]=iHigh(NULL,0,i)+offset*Point;
  }
 }

 return(0);
}
//===========================================================================================
//===========================================================================================


//+----------------------------------------------------------------------+
//|                                                        RSI Color.mq4 |
//|                                                         David J. Lin |
//| RSI as a colored histogram, green > 60, red <40, blue inbetween      |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|(dave.j.lin@sbcglobal.net)                                            |
//|Evanston, IL, July 3, 2008                                            |
//+----------------------------------------------------------------------+

#property copyright "David J. Lin"
#property link      ""

#property indicator_separate_window
#property indicator_buffers 3

#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue

#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1

#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_level1 40
#property indicator_level2 50
#property indicator_level3 60

extern int RSIPeriod=14;
extern int RSIPrice=PRICE_CLOSE;
extern double GreenLimit=60;
extern double RedLimit=40;

double RSIG[],RSIR[],RSIB[];
bool norun;
//===========================================================================================
//===========================================================================================
int init() 
{
 norun=false;
 if(GreenLimit<RedLimit) 
 {
  Alert("GreenLimit needs to be greater than RedLimit!");
  norun=true;
 }
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,RSIG);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,RSIR);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,RSIB); 

 string short_name="RSI Color("+RSIPeriod+")";
 IndicatorShortName(short_name);
 SetIndexDrawBegin(0,RSIPeriod);
 SetIndexDrawBegin(1,RSIPeriod);
 SetIndexDrawBegin(2,RSIPeriod);  
 
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
 if(norun) return;
 int i,imax,counted_bars=IndicatorCounted();
 double rsi;
 if(counted_bars>0) imax=Bars-counted_bars;
 else imax=Bars-1; 
 
 for(i=imax;i>=0;i--) 
 {
  RSIG[i]=EMPTY_VALUE;RSIR[i]=EMPTY_VALUE;RSIB[i]=EMPTY_VALUE;
  
  rsi=iRSI(NULL,0,RSIPeriod,RSIPrice,i);
  
  if(rsi>GreenLimit)    RSIG[i]=rsi;
  else if(rsi<RedLimit) RSIR[i]=rsi;
  else                  RSIB[i]=rsi;
 }

 return(0);
}
//===========================================================================================
//===========================================================================================


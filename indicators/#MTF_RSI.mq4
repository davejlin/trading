//+------------------------------------------------------------------+
//|                                                     #MTF_RSI.mq4 |
//|                                                     David J. Lin |
//|                                                                  |
//|Coded by David J. Lin                                             |
//|dave.j.lin@gmail.com                                              |
//|Evanston, IL, April 29, 2012                                      |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012 David J. Lin"

#property indicator_chart_window
#property indicator_buffers 8

extern int timeframe1=1; //timeframe in minutes
extern int timeframe2=1; //timeframe in minutes
extern int timeframe3=1; //timeframe in minutes
extern int timeframe4=1; //timeframe in minutes
extern int timeframe5=5; //timeframe in minutes
extern int timeframe6=5; //timeframe in minutes
extern int timeframe7=5; //timeframe in minutes
extern int timeframe8=5; //timeframe in minutes

extern int period1=10; //period in minutes
extern int period2=20; //period in minutes
extern int period3=30; //period in minutes
extern int period4=40; //period in minutes
extern int period5=10; //period in minutes
extern int period6=20; //period in minutes
extern int period7=30; //period in minutes
extern int period8=40; //period in minutes

extern int applied_price=0;

/*
Applied price constants. It can be any of the following values:

Constant       Value Description
PRICE_CLOSE    0     Close price.
PRICE_OPEN     1     Open price.
PRICE_HIGH     2     High price.
PRICE_LOW      3     Low price.
PRICE_MEDIAN   4     Median price, (high+low)/2.
PRICE_TYPICAL  5     Typical price, (high+low+close)/3.
PRICE_WEIGHTED 6     Weighted close price, (high+low+close+close)/4.*/

double v1[],v2[],v3[],v4[],v5[],v6[],v7[],v8[];

int init()  
{  
 IndicatorBuffers(8);
 SetIndexStyle(0,DRAW_NONE);
 SetIndexBuffer(0,v1);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,v2);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,v3);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,v4);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,v5);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,v6);
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,v7);
 SetIndexStyle(7,DRAW_NONE);
 SetIndexBuffer(7,v8);
 SetIndexLabel(0, StringConcatenate("1:(",timeframe1,",",period1,")"));
 SetIndexLabel(1, StringConcatenate("2:(",timeframe2,",",period2,")"));
 SetIndexLabel(2, StringConcatenate("3:(",timeframe3,",",period3,")"));
 SetIndexLabel(3, StringConcatenate("4:(",timeframe4,",",period4,")"));
 SetIndexLabel(4, StringConcatenate("5:(",timeframe5,",",period5,")"));
 SetIndexLabel(5, StringConcatenate("6:(",timeframe6,",",period6,")"));
 SetIndexLabel(6, StringConcatenate("7:(",timeframe7,",",period7,")"));
 SetIndexLabel(7, StringConcatenate("8:(",timeframe8,",",period8,")"));
 IndicatorDigits(Digits);   
 return(0);  
}
int deinit()
{
 return(0);  
}

int start()
{
 int shift1,shift2,shift3,shift4,shift5,shift6,shift7,shift8;
 int counted_bars = IndicatorCounted();
 //---- last counted bar will be recounted
 if(counted_bars>0) counted_bars--;
 else counted_bars=1;
 
 int limit = Bars - counted_bars;
 
 //---- computations for D1 high/low
 for(int i=limit;i>=0;i--)
 {
  shift1=iBarShift(NULL,timeframe1,Time[i],false);
  shift2=iBarShift(NULL,timeframe2,Time[i],false);
  shift3=iBarShift(NULL,timeframe3,Time[i],false);
  shift4=iBarShift(NULL,timeframe4,Time[i],false);
  shift5=iBarShift(NULL,timeframe5,Time[i],false);
  shift6=iBarShift(NULL,timeframe6,Time[i],false);
  shift7=iBarShift(NULL,timeframe7,Time[i],false);
  shift8=iBarShift(NULL,timeframe8,Time[i],false);

  v1[i]=NormDigits(iRSI(NULL,timeframe1,period1,applied_price,shift1));
  v2[i]=NormDigits(iRSI(NULL,timeframe2,period2,applied_price,shift2));
  v3[i]=NormDigits(iRSI(NULL,timeframe3,period3,applied_price,shift3));
  v4[i]=NormDigits(iRSI(NULL,timeframe4,period4,applied_price,shift4));
  v5[i]=NormDigits(iRSI(NULL,timeframe5,period5,applied_price,shift5));
  v6[i]=NormDigits(iRSI(NULL,timeframe6,period6,applied_price,shift6));
  v7[i]=NormDigits(iRSI(NULL,timeframe7,period7,applied_price,shift7));
  v8[i]=NormDigits(iRSI(NULL,timeframe8,period8,applied_price,shift8));  
 }
 return(0);
}
//+------------------------------------------------------------------+
double NormDigits(double price) // normalize digits 
{
 return(NormalizeDouble(price,Digits));
}
//+------------------------------------------------------------------+



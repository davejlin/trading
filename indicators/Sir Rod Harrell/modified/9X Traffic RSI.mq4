//+------------------------------------------------------------------+
//|                                               9X Traffic RSI.mq4 |
//|                                                     David J. Lin |
//|                                                                  |
//|Coded by David J. Lin                                             |
//|dave.j.lin@sbcglobal.net                                          |
//|Evanston, IL, June 26, 2007                                       |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007 David J. Lin"
//+--------------------------------------------------------------------------+
//| 4XTraffic_RSI_v1a.mq4                                                    |
//| transport_david thanks friends @                                         |
//| http://finance.groups.yahoo.com/group/MetaTrader_Experts_and_Indicators/ |
//+--------------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                4XTRAFFIC-RSI     |
//|                 Copyright © 2006, tageiger aka fxid10t@yahoo.com |
//|                                        http://www.metatrader.org |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2006, tageiger aka fxid10t@yahoo.com"
#property link      "mailto:fxid10t@yahoo.com"
#property indicator_chart_window
#property indicator_buffers 8

extern int p1.ma=1;//Period() in minutes
extern int p2.ma=5;//Period() in minutes
extern int p3.ma=15;//Period() in minutes
extern int p4.ma=30;//Period() in minutes
extern int p5.ma=60;//Period() in minutes
extern int p6.ma=240;//Period() in minutes
extern int p7.ma=1440;//Period() in minutes
extern int p8.ma=10080;//Period() in minutes
extern int p9.ma=43200;//Period() in minutes

extern int STD.Rgres.length=56;
extern double STD.width=0.809;

extern int first_columnRSIperiods=60;
extern int second_columnRSIperiods=9;
extern int third_columnRSIperiods=9;
extern int fourth_columnRSIperiods=9;
extern int fifth_columnRSIperiods=5;
extern int sixth_columnRSIperiods=5;
extern int seventh_columnRSIperiods=5;
extern int eigth_columnRSIperiods=3;
extern int ninth_columnRSIperiods=3;
extern int rsi.applied.price=0;
extern int rsiUpperTrigger=53;
extern int rsiLowerTrigger=48;
extern int ma.applied.price=0;/*
Applied price constants. It can be any of the following values:

Constant       Value Description
PRICE_CLOSE    0     Close price.
PRICE_OPEN     1     Open price.
PRICE_HIGH     2     High price.
PRICE_LOW      3     Low price.
PRICE_MEDIAN   4     Median price, (high+low)/2.
PRICE_TYPICAL  5     Typical price, (high+low+close)/3.
PRICE_WEIGHTED 6     Weighted close price, (high+low+close+close)/4.*/
extern int ma.Method=0;/*
Moving Average Method
Constant    Value Description
MODE_SMA    0     Simple moving average,
MODE_EMA    1     Exponential moving average,
MODE_SMMA   2     Smoothed moving average,
MODE_LWMA   3     Linear weighted moving average.   */

extern int ma1.Length=13;
extern int ma2.Length=21;
extern int ma3.Length=34;
extern int ma4.Length=55;
extern int ma5.Length=89;
extern int ma6.Length=144;
extern int ma7.Length=233;

double ma1.p1, ma2.p1, ma3.p1, ma4.p1, ma5.p1, ma6.p1, ma7.p1;
double ma1.p2, ma2.p2, ma3.p2, ma4.p2, ma5.p2, ma6.p2, ma7.p2;
double ma1.p3, ma2.p3, ma3.p3, ma4.p3, ma5.p3, ma6.p3, ma7.p3;
double ma1.p4, ma2.p4, ma3.p4, ma4.p4, ma5.p4, ma6.p4, ma7.p4;
double ma1.p5, ma2.p5, ma3.p5, ma4.p5, ma5.p5, ma6.p5, ma7.p5;
double ma1.p6, ma2.p6, ma3.p6, ma4.p6, ma5.p6, ma6.p6, ma7.p6;
double ma1.p7, ma2.p7, ma3.p7, ma4.p7, ma5.p7, ma6.p7, ma7.p7;
double ma1.p8, ma2.p8, ma3.p8, ma4.p8, ma5.p8, ma6.p8, ma7.p8;
double ma1.p9, ma2.p9, ma3.p9, ma4.p9, ma5.p9, ma6.p9, ma7.p9;
double bb1, bb2, bb3, bb4, bb5, bb6, bb7, bb8, bb9;
double tmb1,tmb2,tmb3,tmb4,tmb5,tmb6,tmb7,tmb8,tmb9, 
tmr1,tmr2,tmr3,tmr4,tmr5,tmr6,tmr7,tmr8,tmr9;
datetime t1.p1, t2.p1, t1.p2, t2.p2, t1.p3, t2.p3,
t1.p4, t2.p4, t1.p5, t2.p5, t1.p6, t2.p6, t1.p7, 
t2.p7, t1.p8, t2.p8, t1.p9, t2.p9;

double v1[],v2[],v3[],v4[],v5[],v6[],v7[],v8[];

int init()  
{  
 IndicatorBuffers(8);
 SetIndexStyle(0,DRAW_NONE);
 SetIndexBuffer(0,v1);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,v2);
 SetIndexStyle(0,DRAW_NONE);
 SetIndexBuffer(2,v3);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(3,v4);
 SetIndexStyle(0,DRAW_NONE);
 SetIndexBuffer(4,v5);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(5,v6);
 SetIndexStyle(0,DRAW_NONE);
 SetIndexBuffer(6,v7);
 SetIndexStyle(0,DRAW_NONE);
 SetIndexBuffer(7,v8);
 SetIndexLabel(0, "RSI M5");
 SetIndexLabel(1, "RSI M15");
 SetIndexLabel(2, "RSI M30");
 SetIndexLabel(3, "RSI H1");
 SetIndexLabel(4, "RSI H4");
 SetIndexLabel(5, "RSI D1");
 SetIndexLabel(6, "RSI W1");
 SetIndexLabel(7, "RSI MN");
 return(0);  
}
int deinit()
{
 return(0);  
}

int start()
{
 int shift1,shift2,shift3,shift4,shift5,shift6,shift7,shift8,shift9,ipo;
 int counted_bars = IndicatorCounted();
 //---- last counted bar will be recounted
 if(counted_bars>0) counted_bars--;
 else counted_bars=1;
 
 int limit = Bars - counted_bars;
 
 //---- computations for D1 high/low
 for(int i=limit;i>=0;i--)
 {
//p1 ma settings
  shift1=iBarShift(NULL,p1.ma,Time[i],false);

  ma1.p1=iMA(Symbol(),p1.ma,ma1.Length,0,ma.Method,ma.applied.price,shift1);
  ma2.p1=iMA(Symbol(),p1.ma,ma2.Length,0,ma.Method,ma.applied.price,shift1);
  ma3.p1=iMA(Symbol(),p1.ma,ma3.Length,0,ma.Method,ma.applied.price,shift1);
  ma4.p1=iMA(Symbol(),p1.ma,ma4.Length,0,ma.Method,ma.applied.price,shift1);
  ma5.p1=iMA(Symbol(),p1.ma,ma5.Length,0,ma.Method,ma.applied.price,shift1);
  ma6.p1=iMA(Symbol(),p1.ma,ma6.Length,0,ma.Method,ma.applied.price,shift1);
  ma7.p1=iMA(Symbol(),p1.ma,ma7.Length,0,ma.Method,ma.applied.price,shift1);
//--------------
//p2 ma settings
  shift2=iBarShift(NULL,p2.ma,Time[i],false);

  ma1.p2=iMA(Symbol(),p2.ma,ma1.Length,0,ma.Method,ma.applied.price,shift2);
  ma2.p2=iMA(Symbol(),p2.ma,ma2.Length,0,ma.Method,ma.applied.price,shift2);
  ma3.p2=iMA(Symbol(),p2.ma,ma3.Length,0,ma.Method,ma.applied.price,shift2);
  ma4.p2=iMA(Symbol(),p2.ma,ma4.Length,0,ma.Method,ma.applied.price,shift2);
  ma5.p2=iMA(Symbol(),p2.ma,ma5.Length,0,ma.Method,ma.applied.price,shift2);
  ma6.p2=iMA(Symbol(),p2.ma,ma6.Length,0,ma.Method,ma.applied.price,shift2);
  ma7.p2=iMA(Symbol(),p2.ma,ma7.Length,0,ma.Method,ma.applied.price,shift2);
//--------------
//p3 ma settings
  shift3=iBarShift(NULL,p3.ma,Time[i],false);

  ma1.p3=iMA(Symbol(),p3.ma,ma1.Length,0,ma.Method,ma.applied.price,shift3);
  ma2.p3=iMA(Symbol(),p3.ma,ma2.Length,0,ma.Method,ma.applied.price,shift3);
  ma3.p3=iMA(Symbol(),p3.ma,ma3.Length,0,ma.Method,ma.applied.price,shift3);
  ma4.p3=iMA(Symbol(),p3.ma,ma4.Length,0,ma.Method,ma.applied.price,shift3);
  ma5.p3=iMA(Symbol(),p3.ma,ma5.Length,0,ma.Method,ma.applied.price,shift3);
  ma6.p3=iMA(Symbol(),p3.ma,ma6.Length,0,ma.Method,ma.applied.price,shift3);
  ma7.p3=iMA(Symbol(),p3.ma,ma7.Length,0,ma.Method,ma.applied.price,shift3);
//--------------
//p4 ma settings
  shift4=iBarShift(NULL,p4.ma,Time[i],false);

  ma1.p4=iMA(Symbol(),p4.ma,ma1.Length,0,ma.Method,ma.applied.price,shift4);
  ma2.p4=iMA(Symbol(),p4.ma,ma2.Length,0,ma.Method,ma.applied.price,shift4);
  ma3.p4=iMA(Symbol(),p4.ma,ma3.Length,0,ma.Method,ma.applied.price,shift4);
  ma4.p4=iMA(Symbol(),p4.ma,ma4.Length,0,ma.Method,ma.applied.price,shift4);
  ma5.p4=iMA(Symbol(),p4.ma,ma5.Length,0,ma.Method,ma.applied.price,shift4);
  ma6.p4=iMA(Symbol(),p4.ma,ma6.Length,0,ma.Method,ma.applied.price,shift4);
  ma7.p4=iMA(Symbol(),p4.ma,ma7.Length,0,ma.Method,ma.applied.price,shift4);
//--------------
//p5 ma settings
  shift5=iBarShift(NULL,p5.ma,Time[i],false);

  ma1.p5=iMA(Symbol(),p5.ma,ma1.Length,0,ma.Method,ma.applied.price,shift5);
  ma2.p5=iMA(Symbol(),p5.ma,ma2.Length,0,ma.Method,ma.applied.price,shift5);
  ma3.p5=iMA(Symbol(),p5.ma,ma3.Length,0,ma.Method,ma.applied.price,shift5);
  ma4.p5=iMA(Symbol(),p5.ma,ma4.Length,0,ma.Method,ma.applied.price,shift5);
  ma5.p5=iMA(Symbol(),p5.ma,ma5.Length,0,ma.Method,ma.applied.price,shift5);
  ma6.p5=iMA(Symbol(),p5.ma,ma6.Length,0,ma.Method,ma.applied.price,shift5);
  ma7.p5=iMA(Symbol(),p5.ma,ma7.Length,0,ma.Method,ma.applied.price,shift5);
//--------------
//p6 ma settings
  shift6=iBarShift(NULL,p6.ma,Time[i],false);
 
  ma1.p6=iMA(Symbol(),p6.ma,ma1.Length,0,ma.Method,ma.applied.price,shift6);
  ma2.p6=iMA(Symbol(),p6.ma,ma2.Length,0,ma.Method,ma.applied.price,shift6);
  ma3.p6=iMA(Symbol(),p6.ma,ma3.Length,0,ma.Method,ma.applied.price,shift6);
  ma4.p6=iMA(Symbol(),p6.ma,ma4.Length,0,ma.Method,ma.applied.price,shift6);
  ma5.p6=iMA(Symbol(),p6.ma,ma5.Length,0,ma.Method,ma.applied.price,shift6);
  ma6.p6=iMA(Symbol(),p6.ma,ma6.Length,0,ma.Method,ma.applied.price,shift6);
  ma7.p6=iMA(Symbol(),p6.ma,ma7.Length,0,ma.Method,ma.applied.price,shift6);
//--------------
//p7 ma settings
  shift7=iBarShift(NULL,p7.ma,Time[i],false);
 
  ma1.p7=iMA(Symbol(),p7.ma,ma1.Length,0,ma.Method,ma.applied.price,shift7);
  ma2.p7=iMA(Symbol(),p7.ma,ma2.Length,0,ma.Method,ma.applied.price,shift7);
  ma3.p7=iMA(Symbol(),p7.ma,ma3.Length,0,ma.Method,ma.applied.price,shift7);
  ma4.p7=iMA(Symbol(),p7.ma,ma4.Length,0,ma.Method,ma.applied.price,shift7);
  ma5.p7=iMA(Symbol(),p7.ma,ma5.Length,0,ma.Method,ma.applied.price,shift7);
  ma6.p7=iMA(Symbol(),p7.ma,ma6.Length,0,ma.Method,ma.applied.price,shift7);
  ma7.p7=iMA(Symbol(),p7.ma,ma7.Length,0,ma.Method,ma.applied.price,shift7);
//-------------
//p8 ma settings
  shift8=iBarShift(NULL,p8.ma,Time[i],false);
 
  ma1.p8=iMA(Symbol(),p8.ma,ma1.Length,0,ma.Method,ma.applied.price,shift8);
  ma2.p8=iMA(Symbol(),p8.ma,ma2.Length,0,ma.Method,ma.applied.price,shift8);
  ma3.p8=iMA(Symbol(),p8.ma,ma3.Length,0,ma.Method,ma.applied.price,shift8);
  ma4.p8=iMA(Symbol(),p8.ma,ma4.Length,0,ma.Method,ma.applied.price,shift8);
  ma5.p8=iMA(Symbol(),p8.ma,ma5.Length,0,ma.Method,ma.applied.price,shift8);
  ma6.p8=iMA(Symbol(),p8.ma,ma6.Length,0,ma.Method,ma.applied.price,shift8);
  ma7.p8=iMA(Symbol(),p8.ma,ma7.Length,0,ma.Method,ma.applied.price,shift8);
//---------------
//p9 ma settings
  shift9=iBarShift(NULL,p9.ma,Time[i],false);

  ma1.p9=iMA(Symbol(),p9.ma,ma1.Length,0,ma.Method,ma.applied.price,shift9);
  ma2.p9=iMA(Symbol(),p9.ma,ma2.Length,0,ma.Method,ma.applied.price,shift9);
  ma3.p9=iMA(Symbol(),p9.ma,ma3.Length,0,ma.Method,ma.applied.price,shift9);
  ma4.p9=iMA(Symbol(),p9.ma,ma4.Length,0,ma.Method,ma.applied.price,shift9);
  ma5.p9=iMA(Symbol(),p9.ma,ma5.Length,0,ma.Method,ma.applied.price,shift9);
  ma6.p9=iMA(Symbol(),p9.ma,ma6.Length,0,ma.Method,ma.applied.price,shift9);
  ma7.p9=iMA(Symbol(),p9.ma,ma7.Length,0,ma.Method,ma.applied.price,shift9);
//---------------

  tmb1=iRSI(NULL,p1.ma,first_columnRSIperiods,rsi.applied.price,shift1);
  tmb2=iRSI(NULL,p2.ma,second_columnRSIperiods,rsi.applied.price,shift2);
  tmb3=iRSI(NULL,p3.ma,third_columnRSIperiods,rsi.applied.price,shift3);
  tmb4=iRSI(NULL,p4.ma,fourth_columnRSIperiods,rsi.applied.price,shift4);
  tmb5=iRSI(NULL,p5.ma,fifth_columnRSIperiods,rsi.applied.price,shift5);
  tmb6=iRSI(NULL,p6.ma,sixth_columnRSIperiods,rsi.applied.price,shift6);
  tmb7=iRSI(NULL,p7.ma,seventh_columnRSIperiods,rsi.applied.price,shift7);
  tmb8=iRSI(NULL,p8.ma,eigth_columnRSIperiods,rsi.applied.price,shift8);
  tmb9=iRSI(NULL,p9.ma,ninth_columnRSIperiods,rsi.applied.price,shift9);

  tmr1=iRSI(NULL,p1.ma,first_columnRSIperiods,rsi.applied.price,shift1);
  tmr2=iRSI(NULL,p2.ma,second_columnRSIperiods,rsi.applied.price,shift2);
  tmr3=iRSI(NULL,p3.ma,third_columnRSIperiods,rsi.applied.price,shift3);
  tmr4=iRSI(NULL,p4.ma,fourth_columnRSIperiods,rsi.applied.price,shift4);
  tmr5=iRSI(NULL,p5.ma,fifth_columnRSIperiods,rsi.applied.price,shift5);
  tmr6=iRSI(NULL,p6.ma,sixth_columnRSIperiods,rsi.applied.price,shift6);
  tmr7=iRSI(NULL,p7.ma,seventh_columnRSIperiods,rsi.applied.price,shift7);
  tmr8=iRSI(NULL,p8.ma,eigth_columnRSIperiods,rsi.applied.price,shift8);
  tmr9=iRSI(NULL,p9.ma,ninth_columnRSIperiods,rsi.applied.price,shift9);

  Comment(p1.ma ,"Minutes RSI Level ",tmb1,"\n",p2.ma ,"Minutes RSI Level ",tmb2,"\n",
  p3.ma ,"Minutes Minutes RSI Level ",tmb3,"\n",p4.ma ,"Minutes Minutes RSI Level ",tmb4,"\n",
  p5.ma ,"Minutes RSI Level ",tmb5,"\n",p6.ma ,"Minutes Minutes RSI Level ",tmb6,"\n",
  p7.ma ,"Minutes Minutes RSI Level ",tmb7,"\n",p8.ma ,"Minutes Minutes RSI Level ",tmb8,"\n",
  p9.ma ,"Minutes Minutes RSI Level ",tmb9,"\n");

  v1[i]=tmb2;v2[i]=tmb3;v3[i]=tmb4;v4[i]=tmb5;
  v5[i]=tmb6;v6[i]=tmb7;v7[i]=tmb8;v8[i]=tmb9;
 }
 return(0);
}


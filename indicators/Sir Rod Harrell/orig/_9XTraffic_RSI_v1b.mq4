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

extern int fib.SR.shadow.1=8;
extern int fib.SR.shadow.2=13;
extern int fib.SR.shadow.3=21;
extern int fib.SR.shadow.4=34;
extern int fib.SR.shadow.5=55;
extern int fib.SR.shadow.6=89;
extern int fib.SR.shadow.7=144;

extern color fib.SR.shadow.1.c=AliceBlue;
extern color fib.SR.shadow.2.c=LightBlue;
extern color fib.SR.shadow.3.c=DodgerBlue;
extern color fib.SR.shadow.4.c=RoyalBlue;
extern color fib.SR.shadow.5.c=Blue;
extern color fib.SR.shadow.6.c=MediumBlue;
extern color fib.SR.shadow.7.c=DarkBlue;

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

int init()  {  return(0);  }
int deinit()   {
  ObjectsDeleteAll(0,OBJ_TEXT);ObjectsDeleteAll(0,OBJ_RECTANGLE);
  ObjectsDeleteAll(0,OBJ_ARROW);ObjectsDeleteAll(0,OBJ_TREND);
return(0);  }
int start() {
  ObjectsDeleteAll();
//   ObjectCreate("regression channel",OBJ_REGRESSION,0,Time[STD.Rgres.length],Bid,Time[0],Ask);
//   ObjectSet("regression channel",OBJPROP_RAY,true);
//   ObjectCreate("std channel",OBJ_STDDEVCHANNEL,0,Time[STD.Rgres.length],Bid,Time[0],Ask);
//   ObjectSet("std channel",OBJPROP_DEVIATION,STD.width);
//   ObjectSet("std channel",OBJPROP_COLOR,Olive);
//   ObjectSet("std channel",OBJPROP_RAY,true);
//p1 ma settings
  ma1.p1=iMA(Symbol(),p1.ma,ma1.Length,0,ma.Method,ma.applied.price,0);
  ma2.p1=iMA(Symbol(),p1.ma,ma2.Length,0,ma.Method,ma.applied.price,0);
  ma3.p1=iMA(Symbol(),p1.ma,ma3.Length,0,ma.Method,ma.applied.price,0);
  ma4.p1=iMA(Symbol(),p1.ma,ma4.Length,0,ma.Method,ma.applied.price,0);
  ma5.p1=iMA(Symbol(),p1.ma,ma5.Length,0,ma.Method,ma.applied.price,0);
  ma6.p1=iMA(Symbol(),p1.ma,ma6.Length,0,ma.Method,ma.applied.price,0);
  ma7.p1=iMA(Symbol(),p1.ma,ma7.Length,0,ma.Method,ma.applied.price,0);
//--------------
//p2 ma settings
  ma1.p2=iMA(Symbol(),p2.ma,ma1.Length,0,ma.Method,ma.applied.price,0);
  ma2.p2=iMA(Symbol(),p2.ma,ma2.Length,0,ma.Method,ma.applied.price,0);
  ma3.p2=iMA(Symbol(),p2.ma,ma3.Length,0,ma.Method,ma.applied.price,0);
  ma4.p2=iMA(Symbol(),p2.ma,ma4.Length,0,ma.Method,ma.applied.price,0);
  ma5.p2=iMA(Symbol(),p2.ma,ma5.Length,0,ma.Method,ma.applied.price,0);
  ma6.p2=iMA(Symbol(),p2.ma,ma6.Length,0,ma.Method,ma.applied.price,0);
  ma7.p2=iMA(Symbol(),p2.ma,ma7.Length,0,ma.Method,ma.applied.price,0);
//--------------
//p3 ma settings
  ma1.p3=iMA(Symbol(),p3.ma,ma1.Length,0,ma.Method,ma.applied.price,0);
  ma2.p3=iMA(Symbol(),p3.ma,ma2.Length,0,ma.Method,ma.applied.price,0);
  ma3.p3=iMA(Symbol(),p3.ma,ma3.Length,0,ma.Method,ma.applied.price,0);
  ma4.p3=iMA(Symbol(),p3.ma,ma4.Length,0,ma.Method,ma.applied.price,0);
  ma5.p3=iMA(Symbol(),p3.ma,ma5.Length,0,ma.Method,ma.applied.price,0);
  ma6.p3=iMA(Symbol(),p3.ma,ma6.Length,0,ma.Method,ma.applied.price,0);
  ma7.p3=iMA(Symbol(),p3.ma,ma7.Length,0,ma.Method,ma.applied.price,0);
//--------------
//p4 ma settings
  ma1.p4=iMA(Symbol(),p4.ma,ma1.Length,0,ma.Method,ma.applied.price,0);
  ma2.p4=iMA(Symbol(),p4.ma,ma2.Length,0,ma.Method,ma.applied.price,0);
  ma3.p4=iMA(Symbol(),p4.ma,ma3.Length,0,ma.Method,ma.applied.price,0);
  ma4.p4=iMA(Symbol(),p4.ma,ma4.Length,0,ma.Method,ma.applied.price,0);
  ma5.p4=iMA(Symbol(),p4.ma,ma5.Length,0,ma.Method,ma.applied.price,0);
  ma6.p4=iMA(Symbol(),p4.ma,ma6.Length,0,ma.Method,ma.applied.price,0);
  ma7.p4=iMA(Symbol(),p4.ma,ma7.Length,0,ma.Method,ma.applied.price,0);
//--------------
//p5 ma settings
  ma1.p5=iMA(Symbol(),p5.ma,ma1.Length,0,ma.Method,ma.applied.price,0);
  ma2.p5=iMA(Symbol(),p5.ma,ma2.Length,0,ma.Method,ma.applied.price,0);
  ma3.p5=iMA(Symbol(),p5.ma,ma3.Length,0,ma.Method,ma.applied.price,0);
  ma4.p5=iMA(Symbol(),p5.ma,ma4.Length,0,ma.Method,ma.applied.price,0);
  ma5.p5=iMA(Symbol(),p5.ma,ma5.Length,0,ma.Method,ma.applied.price,0);
  ma6.p5=iMA(Symbol(),p5.ma,ma6.Length,0,ma.Method,ma.applied.price,0);
  ma7.p5=iMA(Symbol(),p5.ma,ma7.Length,0,ma.Method,ma.applied.price,0);
//--------------
//p2 ma settings
  ma1.p6=iMA(Symbol(),p6.ma,ma1.Length,0,ma.Method,ma.applied.price,0);
  ma2.p6=iMA(Symbol(),p6.ma,ma2.Length,0,ma.Method,ma.applied.price,0);
  ma3.p6=iMA(Symbol(),p6.ma,ma3.Length,0,ma.Method,ma.applied.price,0);
  ma4.p6=iMA(Symbol(),p6.ma,ma4.Length,0,ma.Method,ma.applied.price,0);
  ma5.p6=iMA(Symbol(),p6.ma,ma5.Length,0,ma.Method,ma.applied.price,0);
  ma6.p6=iMA(Symbol(),p6.ma,ma6.Length,0,ma.Method,ma.applied.price,0);
  ma7.p6=iMA(Symbol(),p6.ma,ma7.Length,0,ma.Method,ma.applied.price,0);
//--------------
//p7 ma settings
  ma1.p7=iMA(Symbol(),p7.ma,ma1.Length,0,ma.Method,ma.applied.price,0);
  ma2.p7=iMA(Symbol(),p7.ma,ma2.Length,0,ma.Method,ma.applied.price,0);
  ma3.p7=iMA(Symbol(),p7.ma,ma3.Length,0,ma.Method,ma.applied.price,0);
  ma4.p7=iMA(Symbol(),p7.ma,ma4.Length,0,ma.Method,ma.applied.price,0);
  ma5.p7=iMA(Symbol(),p7.ma,ma5.Length,0,ma.Method,ma.applied.price,0);
  ma6.p7=iMA(Symbol(),p7.ma,ma6.Length,0,ma.Method,ma.applied.price,0);
  ma7.p7=iMA(Symbol(),p7.ma,ma7.Length,0,ma.Method,ma.applied.price,0);
//-------------
//p8 ma settings
  ma1.p8=iMA(Symbol(),p8.ma,ma1.Length,0,ma.Method,ma.applied.price,0);
  ma2.p8=iMA(Symbol(),p8.ma,ma2.Length,0,ma.Method,ma.applied.price,0);
  ma3.p8=iMA(Symbol(),p8.ma,ma3.Length,0,ma.Method,ma.applied.price,0);
  ma4.p8=iMA(Symbol(),p8.ma,ma4.Length,0,ma.Method,ma.applied.price,0);
  ma5.p8=iMA(Symbol(),p8.ma,ma5.Length,0,ma.Method,ma.applied.price,0);
  ma6.p8=iMA(Symbol(),p8.ma,ma6.Length,0,ma.Method,ma.applied.price,0);
  ma7.p8=iMA(Symbol(),p8.ma,ma7.Length,0,ma.Method,ma.applied.price,0);
//---------------
//p9 ma settings
  ma1.p9=iMA(Symbol(),p9.ma,ma1.Length,0,ma.Method,ma.applied.price,0);
  ma2.p9=iMA(Symbol(),p9.ma,ma2.Length,0,ma.Method,ma.applied.price,0);
  ma3.p9=iMA(Symbol(),p9.ma,ma3.Length,0,ma.Method,ma.applied.price,0);
  ma4.p9=iMA(Symbol(),p9.ma,ma4.Length,0,ma.Method,ma.applied.price,0);
  ma5.p9=iMA(Symbol(),p9.ma,ma5.Length,0,ma.Method,ma.applied.price,0);
  ma6.p9=iMA(Symbol(),p9.ma,ma6.Length,0,ma.Method,ma.applied.price,0);
  ma7.p9=iMA(Symbol(),p9.ma,ma7.Length,0,ma.Method,ma.applied.price,0);
//---------------

tmb1=iRSI(NULL,p1.ma,first_columnRSIperiods,rsi.applied.price,0);
tmb2=iRSI(NULL,p2.ma,second_columnRSIperiods,rsi.applied.price,0);
tmb3=iRSI(NULL,p3.ma,third_columnRSIperiods,rsi.applied.price,0);
tmb4=iRSI(NULL,p4.ma,fourth_columnRSIperiods,rsi.applied.price,0);
tmb5=iRSI(NULL,p5.ma,fifth_columnRSIperiods,rsi.applied.price,0);
tmb6=iRSI(NULL,p6.ma,sixth_columnRSIperiods,rsi.applied.price,0);
tmb7=iRSI(NULL,p7.ma,seventh_columnRSIperiods,rsi.applied.price,0);
tmb8=iRSI(NULL,p8.ma,eigth_columnRSIperiods,rsi.applied.price,0);
tmb9=iRSI(NULL,p9.ma,ninth_columnRSIperiods,rsi.applied.price,0);

tmr1=iRSI(NULL,p1.ma,first_columnRSIperiods,rsi.applied.price,0);
tmr2=iRSI(NULL,p2.ma,second_columnRSIperiods,rsi.applied.price,0);
tmr3=iRSI(NULL,p3.ma,third_columnRSIperiods,rsi.applied.price,0);
tmr4=iRSI(NULL,p4.ma,fourth_columnRSIperiods,rsi.applied.price,0);
tmr5=iRSI(NULL,p5.ma,fifth_columnRSIperiods,rsi.applied.price,0);
tmr6=iRSI(NULL,p6.ma,sixth_columnRSIperiods,rsi.applied.price,0);
tmr7=iRSI(NULL,p7.ma,seventh_columnRSIperiods,rsi.applied.price,0);
tmr8=iRSI(NULL,p8.ma,eigth_columnRSIperiods,rsi.applied.price,0);
tmr9=iRSI(NULL,p9.ma,ninth_columnRSIperiods,rsi.applied.price,0);
Comment(p1.ma ,"Minutes RSI Level ",tmb1,"\n",p2.ma ,"Minutes RSI Level ",tmb2,"\n",
p3.ma ,"Minutes Minutes RSI Level ",tmb3,"\n",p4.ma ,"Minutes Minutes RSI Level ",tmb4,"\n",
p5.ma ,"Minutes RSI Level ",tmb5,"\n",p6.ma ,"Minutes Minutes RSI Level ",tmb6,"\n",
p7.ma ,"Minutes Minutes RSI Level ",tmb7,"\n",p8.ma ,"Minutes Minutes RSI Level ",tmb8,"\n",
p9.ma ,"Minutes Minutes RSI Level ",tmb9,"\n");

//--------------
Time.Coordinate.Set();
p1.Fib.Plot();
p2.Fib.Plot();
p3.Fib.Plot();
p4.Fib.Plot();
column();
//--------------



return(0);}
//+------------------------------------------------------------------+
void Time.Coordinate.Set()   {
//....Variable Settings for Object Spatial Placement.....
  double zoom.multiplier;int bpw=BarsPerWindow();
  if(bpw<25)              {zoom.multiplier=0.05;}
  if(bpw>25 && bpw<50)    {zoom.multiplier=0.07;}
  if(bpw>50 && bpw<175)   {zoom.multiplier=0.12;}
  if(bpw>175 && bpw<375)  {zoom.multiplier=0.25;}
  if(bpw>375 && bpw<750)  {zoom.multiplier=0.5;}
  if(bpw>750)             {zoom.multiplier=1;}
  double time.frame.multiplier;
  if(Period()==1)      {time.frame.multiplier=0.65;}
  if(Period()==5)      {time.frame.multiplier=3.25;}
  if(Period()==15)     {time.frame.multiplier=9.75;}
  if(Period()==30)     {time.frame.multiplier=19.5;}
  if(Period()==60)     {time.frame.multiplier=39;}
  if(Period()==240)    {time.frame.multiplier=156;}
  if(Period()==1440)   {time.frame.multiplier=936;}
  if(Period()==10080)  {time.frame.multiplier=6552;}
  if(Period()==43200)  {time.frame.multiplier=28043;}

  t1.p1=Time[0]+(1000*time.frame.multiplier*zoom.multiplier);
  t2.p1=Time[0]+(3000*time.frame.multiplier*zoom.multiplier);

  t1.p2=Time[0]+(5000*time.frame.multiplier*zoom.multiplier);
  t2.p2=Time[0]+(7000*time.frame.multiplier*zoom.multiplier);

  t1.p3=Time[0]+(9000*time.frame.multiplier*zoom.multiplier);
  t2.p3=Time[0]+(11000*time.frame.multiplier*zoom.multiplier);

  t1.p4=Time[0]+(13000*time.frame.multiplier*zoom.multiplier);
  t2.p4=Time[0]+(16000*time.frame.multiplier*zoom.multiplier);}//end Time.Coordinate.Set()

void p1.Fib.Plot()   {
//p1 dynamic fibo levels
  double lo.ma.p1,hi.ma.p1;
  lo.ma.p1=ma1.p1;
  if(ma2.p1<lo.ma.p1)  {lo.ma.p1=ma2.p1;}
  if(ma3.p1<lo.ma.p1)  {lo.ma.p1=ma3.p1;}
  if(ma4.p1<lo.ma.p1)  {lo.ma.p1=ma4.p1;}
  if(ma5.p1<lo.ma.p1)  {lo.ma.p1=ma5.p1;}
  if(ma6.p1<lo.ma.p1)  {lo.ma.p1=ma6.p1;}
  if(ma7.p1<lo.ma.p1)  {lo.ma.p1=ma7.p1;}
  lo.ma.p1=NormalizeDouble(lo.ma.p1+(fib.SR.shadow.1*Point),Digits);

  hi.ma.p1=ma7.p1;
  if(ma6.p1>hi.ma.p1)  {hi.ma.p1=ma6.p1;}
  if(ma5.p1>hi.ma.p1)  {hi.ma.p1=ma5.p1;}
  if(ma4.p1>hi.ma.p1)  {hi.ma.p1=ma4.p1;}
  if(ma3.p1>hi.ma.p1)  {hi.ma.p1=ma3.p1;}
  if(ma2.p1>hi.ma.p1)  {hi.ma.p1=ma2.p1;}
  if(ma1.p1>hi.ma.p1)  {hi.ma.p1=ma1.p1;}
  hi.ma.p1=NormalizeDouble(hi.ma.p1-(fib.SR.shadow.1*Point),Digits);

//p1 center dynamic fib placement
  if(lo.ma.p1-hi.ma.p1>Ask-Bid)   {
     ObjectCreate("lcf.p1",OBJ_TREND,0,t1.p1, lo.ma.p1, t2.p1, lo.ma.p1);
     ObjectSet("lcf.p1",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("lcf.p1",OBJPROP_WIDTH,2);
     ObjectSet("lcf.p1",OBJPROP_RAY,false);
     ObjectSet("lcf.p1",OBJPROP_COLOR,fib.SR.shadow.1.c);
     ObjectSetText("lcf.p1",DoubleToStr(lo.ma.p1,Digits),7,"Arial",fib.SR.shadow.1.c);

     ObjectCreate("hcf.p1",OBJ_TREND,0,t1.p1, hi.ma.p1, t2.p1, hi.ma.p1);
     ObjectSet("hcf.p1",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("hcf.p1",OBJPROP_WIDTH,2);
     ObjectSet("hcf.p1",OBJPROP_RAY,false);
     ObjectSet("hcf.p1",OBJPROP_COLOR,fib.SR.shadow.1.c);
     ObjectSetText("hcf.p1",DoubleToStr(hi.ma.p1,Digits),7,"Arial",fib.SR.shadow.1.c);   }

  double lo.ma.p1.1, lo.ma.p1.2, lo.ma.p1.3, lo.ma.p1.4, lo.ma.p1.5, lo.ma.p1.6;
  lo.ma.p1.1=lo.ma.p1+(fib.SR.shadow.2*Point);
  lo.ma.p1.2=lo.ma.p1.1+(fib.SR.shadow.3*Point);
  lo.ma.p1.3=lo.ma.p1.2+(fib.SR.shadow.4*Point);
  lo.ma.p1.4=lo.ma.p1.3+(fib.SR.shadow.5*Point);
  lo.ma.p1.5=lo.ma.p1.4+(fib.SR.shadow.6*Point);
  lo.ma.p1.6=lo.ma.p1.5+(fib.SR.shadow.7*Point);

  double hi.ma.p1.1, hi.ma.p1.2, hi.ma.p1.3, hi.ma.p1.4, hi.ma.p1.5, hi.ma.p1.6;
  hi.ma.p1.1=hi.ma.p1-(fib.SR.shadow.2*Point);
  hi.ma.p1.2=hi.ma.p1.1-(fib.SR.shadow.3*Point);
  hi.ma.p1.3=hi.ma.p1.2-(fib.SR.shadow.4*Point);
  hi.ma.p1.4=hi.ma.p1.3-(fib.SR.shadow.5*Point);
  hi.ma.p1.5=hi.ma.p1.4-(fib.SR.shadow.6*Point);
  hi.ma.p1.6=hi.ma.p1.5-(fib.SR.shadow.7*Point);

//p1 1st level (hi.1.p1, lo.1.p1)
  if(lo.ma.p1.1-hi.ma.p1.1>Ask-Bid)   {
     ObjectCreate("lo.1.p1",OBJ_TREND,0,t1.p1, lo.ma.p1.1, t2.p1, lo.ma.p1.1);
     ObjectSet("lo.1.p1",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("lo.1.p1",OBJPROP_WIDTH,2);
     ObjectSet("lo.1.p1",OBJPROP_RAY,false);
     ObjectSet("lo.1.p1",OBJPROP_COLOR,fib.SR.shadow.2.c);
     ObjectSetText("lo.1.p1",DoubleToStr(lo.ma.p1.1,Digits),7,"Arial",fib.SR.shadow.2.c);

     ObjectCreate("hi.1.p1",OBJ_TREND,0,t1.p1, hi.ma.p1.1, t2.p1, hi.ma.p1.1);
     ObjectSet("hi.1.p1",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("hi.1.p1",OBJPROP_WIDTH,2);
     ObjectSet("hi.1.p1",OBJPROP_RAY,false);
     ObjectSet("hi.1.p1",OBJPROP_COLOR,fib.SR.shadow.2.c);
     ObjectSetText("hi.1.p1",DoubleToStr(hi.ma.p1.1,Digits),7,"Arial",fib.SR.shadow.2.c);   }

// 2nd level (hi.2.p1, lo.2.p1)
  if(lo.ma.p1.2-hi.ma.p1.2>Ask-Bid)   {
     ObjectCreate("lo.2.p1",OBJ_TREND,0,t1.p1, lo.ma.p1.2, t2.p1, lo.ma.p1.2);
     ObjectSet("lo.2.p1",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("lo.2.p1",OBJPROP_WIDTH,2);
     ObjectSet("lo.2.p1",OBJPROP_RAY,false);
     ObjectSet("lo.2.p1",OBJPROP_COLOR,fib.SR.shadow.3.c);
     ObjectSetText("lo.2.p1",DoubleToStr(lo.ma.p1.2,Digits),7,"Arial",fib.SR.shadow.3.c);

     ObjectCreate("hi.2.p1",OBJ_TREND,0,t1.p1, hi.ma.p1.2, t2.p1, hi.ma.p1.2);
     ObjectSet("hi.2.p1",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("hi.2.p1",OBJPROP_WIDTH,2);
     ObjectSet("hi.2.p1",OBJPROP_RAY,false);
     ObjectSet("hi.2.p1",OBJPROP_COLOR,fib.SR.shadow.3.c);
     ObjectSetText("hi.2.p1",DoubleToStr(hi.ma.p1.2,Digits),7,"Arial",fib.SR.shadow.3.c);   }

// 3rd level (hi.3.p1, lo.3.p1)
  if(lo.ma.p1.3-hi.ma.p1.3>Ask-Bid)   {
     ObjectCreate("lo.3.p1",OBJ_TREND,0,t1.p1, lo.ma.p1.3, t2.p1, lo.ma.p1.3);
     ObjectSet("lo.3.p1",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("lo.3.p1",OBJPROP_WIDTH,2);
     ObjectSet("lo.3.p1",OBJPROP_RAY,false);
     ObjectSet("lo.3.p1",OBJPROP_COLOR,fib.SR.shadow.4.c);
     ObjectSetText("lo.3.p1",DoubleToStr(lo.ma.p1.3,Digits),7,"Arial",fib.SR.shadow.4.c);

     ObjectCreate("hi.3.p1",OBJ_TREND,0,t1.p1, hi.ma.p1.3, t2.p1, hi.ma.p1.3);
     ObjectSet("hi.3.p1",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("hi.3.p1",OBJPROP_WIDTH,2);
     ObjectSet("hi.3.p1",OBJPROP_RAY,false);
     ObjectSet("hi.3.p1",OBJPROP_COLOR,fib.SR.shadow.4.c);
     ObjectSetText("hi.3.p1",DoubleToStr(hi.ma.p1.3,Digits),7,"Arial",fib.SR.shadow.4.c);   }

// 4th level (hi.4.p1, lo.4.p1)
  if(lo.ma.p1.4-hi.ma.p1.4>Ask-Bid)   {
     ObjectCreate("lo.4.p1",OBJ_TREND,0,t1.p1, lo.ma.p1.4, t2.p1, lo.ma.p1.4);
     ObjectSet("lo.4.p1",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("lo.4.p1",OBJPROP_WIDTH,2);
     ObjectSet("lo.4.p1",OBJPROP_RAY,false);
     ObjectSet("lo.4.p1",OBJPROP_COLOR,fib.SR.shadow.5.c);
     ObjectSetText("lo.4.p1",DoubleToStr(lo.ma.p1.4,Digits),7,"Arial",fib.SR.shadow.5.c);

     ObjectCreate("hi.4.p1",OBJ_TREND,0,t1.p1, hi.ma.p1.4, t2.p1, hi.ma.p1.4);
     ObjectSet("hi.4.p1",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("hi.4.p1",OBJPROP_WIDTH,2);
     ObjectSet("hi.4.p1",OBJPROP_RAY,false);
     ObjectSet("hi.4.p1",OBJPROP_COLOR,fib.SR.shadow.5.c);
     ObjectSetText("hi.4.p1",DoubleToStr(hi.ma.p1.4,Digits),7,"Arial",fib.SR.shadow.5.c);   }

// 5th level (hi.5.p1, lo.5.p1)
  if(lo.ma.p1.5-hi.ma.p1.5>Ask-Bid)   {
     ObjectCreate("lo.5.p1",OBJ_TREND,0,t1.p1, lo.ma.p1.5, t2.p1, lo.ma.p1.5);
     ObjectSet("lo.5.p1",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("lo.5.p1",OBJPROP_WIDTH,2);
     ObjectSet("lo.5.p1",OBJPROP_RAY,false);
     ObjectSet("lo.5.p1",OBJPROP_COLOR,fib.SR.shadow.6.c);
     ObjectSetText("lo.5.p1",DoubleToStr(lo.ma.p1.5,Digits),7,"Arial",fib.SR.shadow.6.c);

     ObjectCreate("hi.5.p1",OBJ_TREND,0,t1.p1, hi.ma.p1.5, t2.p1, hi.ma.p1.5);
     ObjectSet("hi.5.p1",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("hi.5.p1",OBJPROP_WIDTH,2);
     ObjectSet("hi.5.p1",OBJPROP_RAY,false);
     ObjectSet("hi.5.p1",OBJPROP_COLOR,fib.SR.shadow.6.c);
     ObjectSetText("hi.5.p1",DoubleToStr(hi.ma.p1.5,Digits),7,"Arial",fib.SR.shadow.6.c);   }

// 6th level (hi.6.p1, lo.6.p1)
  if(lo.ma.p1.6-hi.ma.p1.6>Ask-Bid)   {
     ObjectCreate("lo.6.p1",OBJ_TREND,0,t1.p1, lo.ma.p1.6, t2.p1, lo.ma.p1.6);
     ObjectSet("lo.6.p1",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("lo.6.p1",OBJPROP_WIDTH,2);
     ObjectSet("lo.6.p1",OBJPROP_RAY,false);
     ObjectSet("lo.6.p1",OBJPROP_COLOR,fib.SR.shadow.7.c);
     ObjectSetText("lo.6.p1",DoubleToStr(lo.ma.p1.6,Digits),7,"Arial",fib.SR.shadow.7.c);

     ObjectCreate("hi.6.p1",OBJ_TREND,0,t1.p1, hi.ma.p1.6, t2.p1, hi.ma.p1.6);
     ObjectSet("hi.6.p1",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("hi.6.p1",OBJPROP_WIDTH,2);
     ObjectSet("hi.6.p1",OBJPROP_RAY,false);
     ObjectSet("hi.6.p1",OBJPROP_COLOR,fib.SR.shadow.7.c);
     ObjectSetText("hi.6.p1",DoubleToStr(hi.ma.p1.6,Digits),7,"Arial",fib.SR.shadow.7.c);   }
//...............Moving Average Support & Resistance Levels..............................
  string space="             ";
 //     ObjectCreate("ma1.p1",OBJ_TEXT,0,t1.p1,ma1.p1);//13 ma
     ObjectSetText("ma1.p1",space+DoubleToStr(ma1.p1,Digits),8,"Arial",White);

//      ObjectCreate("ma2.p1",OBJ_TEXT,0,t1.p1,ma2.p1);//21 ma
     ObjectSetText("ma2.p1",space+DoubleToStr(ma2.p1,Digits),8,"Arial",White);

//      ObjectCreate("ma3.p1",OBJ_TEXT,0,t1.p1,ma3.p1);//34 ma
     if(Bid>ma3.p1) {ObjectSetText("ma3.p1",space+DoubleToStr(ma3.p1,Digits),8,"Arial",LightGreen);}
     if(Ask<ma3.p1) {ObjectSetText("ma3.p1",space+DoubleToStr(ma3.p1,Digits),8,"Arial",Pink);}
     if(Bid<=ma3.p1 && Ask>=ma3.p1)  {
        ObjectSetText("ma3.p1",space+DoubleToStr(ma3.p1,Digits),8,"Arial",Yellow);}

//      ObjectCreate("ma4.p1",OBJ_TEXT,0,t1.p1,ma4.p1);//55 ma
     if(Bid>ma4.p1) {ObjectSetText("ma4.p1",space+DoubleToStr(ma4.p1,Digits),8,"Arial",LightGreen);}
     if(Ask<ma4.p1) {ObjectSetText("ma4.p1",space+DoubleToStr(ma4.p1,Digits),8,"Arial",Pink);}
     if(Bid<=ma4.p1 && Ask>=ma4.p1)  {
        ObjectSetText("ma4.p1",space+DoubleToStr(ma4.p1,Digits),8,"Arial",Yellow);}

//      ObjectCreate("ma5.p1",OBJ_TEXT,0,t1.p1,ma5.p1);//89 ma
     if(Bid>ma5.p1) {ObjectSetText("ma5.p1",space+DoubleToStr(ma5.p1,Digits),8,"Arial",Green);}
     if(Ask<ma5.p1) {ObjectSetText("ma5.p1",space+DoubleToStr(ma5.p1,Digits),8,"Arial",Red);}
     if(Bid<=ma5.p1 && Ask>=ma5.p1)  {
        ObjectSetText("ma5.p1",space+DoubleToStr(ma5.p1,Digits),8,"Arial",Yellow);}

//      ObjectCreate("ma6.p1",OBJ_TEXT,0,t1.p1,NormalizeDouble(ma6.p1,Digits));//144 ma
     if(Bid>ma6.p1) {ObjectSetText("ma6.p1",space+DoubleToStr(ma6.p1,Digits),8,"Arial",Green);}
     if(Ask<ma6.p1) {ObjectSetText("ma6.p1",space+DoubleToStr(ma6.p1,Digits),8,"Arial",Red);}
     if(Bid<=ma6.p1 && Ask>=ma6.p1)  {
        ObjectSetText("ma6.p1",space+DoubleToStr(ma6.p1,Digits),8,"Arial",Yellow);}

//      ObjectCreate("ma7.p1",OBJ_TEXT,0,t1.p1,NormalizeDouble(ma7.p1,Digits));//233 ma
     if(Bid>ma7.p1) {ObjectSetText("ma7.p1",space+DoubleToStr(ma7.p1,Digits),8,"Arial",Green);}
     if(Ask<ma7.p1) {ObjectSetText("ma7.p1",space+DoubleToStr(ma7.p1,Digits),8,"Arial",Red);}
     if(Bid<=ma7.p1 && Ask>=ma7.p1)  {
        ObjectSetText("ma7.p1",space+DoubleToStr(ma7.p1,Digits),8,"Arial",Yellow);}
}//end p1.Fib.Plot()

void p2.Fib.Plot()   {
//p2 dynamic fibo levels
  double lo.ma.p2,hi.ma.p2;
  lo.ma.p2=ma1.p2;
  if(ma2.p2<lo.ma.p2)  {lo.ma.p2=ma2.p2;}
  if(ma3.p2<lo.ma.p2)  {lo.ma.p2=ma3.p2;}
  if(ma4.p2<lo.ma.p2)  {lo.ma.p2=ma4.p2;}
  if(ma5.p2<lo.ma.p2)  {lo.ma.p2=ma5.p2;}
  if(ma6.p2<lo.ma.p2)  {lo.ma.p2=ma6.p2;}
  if(ma7.p2<lo.ma.p2)  {lo.ma.p2=ma7.p2;}
  lo.ma.p2=NormalizeDouble(lo.ma.p2+(fib.SR.shadow.1*Point),Digits);

  hi.ma.p2=ma7.p2;
  if(ma6.p2>hi.ma.p2)  {hi.ma.p2=ma6.p2;}
  if(ma5.p2>hi.ma.p2)  {hi.ma.p2=ma5.p2;}
  if(ma4.p2>hi.ma.p2)  {hi.ma.p2=ma4.p2;}
  if(ma3.p2>hi.ma.p2)  {hi.ma.p2=ma3.p2;}
  if(ma2.p2>hi.ma.p2)  {hi.ma.p2=ma2.p2;}
  if(ma1.p2>hi.ma.p2)  {hi.ma.p2=ma1.p2;}
  hi.ma.p2=NormalizeDouble(hi.ma.p2-(fib.SR.shadow.1*Point),Digits);

//p2 center dynamic fib placement
  if(lo.ma.p2-hi.ma.p2>Ask-Bid)   {
     ObjectCreate("lcf.p2",OBJ_TREND,0,t1.p2, lo.ma.p2, t2.p2, lo.ma.p2);
     ObjectSet("lcf.p2",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("lcf.p2",OBJPROP_WIDTH,2);
     ObjectSet("lcf.p2",OBJPROP_RAY,false);
     ObjectSet("lcf.p2",OBJPROP_COLOR,fib.SR.shadow.1.c);
     ObjectSetText("lcf.p2",DoubleToStr(lo.ma.p2,Digits),7,"Arial",fib.SR.shadow.1.c);

     ObjectCreate("hcf.p2",OBJ_TREND,0,t1.p2, hi.ma.p2, t2.p2, hi.ma.p2);
     ObjectSet("hcf.p2",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("hcf.p2",OBJPROP_WIDTH,2);
     ObjectSet("hcf.p2",OBJPROP_RAY,false);
     ObjectSet("hcf.p2",OBJPROP_COLOR,fib.SR.shadow.1.c);
     ObjectSetText("hcf.p2",DoubleToStr(hi.ma.p2,Digits),7,"Arial",fib.SR.shadow.1.c);   }

  double lo.ma.p2.1, lo.ma.p2.2, lo.ma.p2.3, lo.ma.p2.4, lo.ma.p2.5, lo.ma.p2.6;
  lo.ma.p2.1=lo.ma.p2+(fib.SR.shadow.2*Point);
  lo.ma.p2.2=lo.ma.p2.1+(fib.SR.shadow.3*Point);
  lo.ma.p2.3=lo.ma.p2.2+(fib.SR.shadow.4*Point);
  lo.ma.p2.4=lo.ma.p2.3+(fib.SR.shadow.5*Point);
  lo.ma.p2.5=lo.ma.p2.4+(fib.SR.shadow.6*Point);
  lo.ma.p2.6=lo.ma.p2.5+(fib.SR.shadow.7*Point);

  double hi.ma.p2.1, hi.ma.p2.2, hi.ma.p2.3, hi.ma.p2.4, hi.ma.p2.5, hi.ma.p2.6;
  hi.ma.p2.1=hi.ma.p2-(fib.SR.shadow.2*Point);
  hi.ma.p2.2=hi.ma.p2.1-(fib.SR.shadow.3*Point);
  hi.ma.p2.3=hi.ma.p2.2-(fib.SR.shadow.4*Point);
  hi.ma.p2.4=hi.ma.p2.3-(fib.SR.shadow.5*Point);
  hi.ma.p2.5=hi.ma.p2.4-(fib.SR.shadow.6*Point);
  hi.ma.p2.6=hi.ma.p2.5-(fib.SR.shadow.7*Point);

//p2 1st level (hi.1.p2, lo.1.p2)
  if(lo.ma.p2.1-hi.ma.p2.1>Ask-Bid)   {
     ObjectCreate("lo.1.p2",OBJ_TREND,0,t1.p2, lo.ma.p2.1, t2.p2, lo.ma.p2.1);
     ObjectSet("lo.1.p2",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("lo.1.p2",OBJPROP_WIDTH,2);
     ObjectSet("lo.1.p2",OBJPROP_RAY,false);
     ObjectSet("lo.1.p2",OBJPROP_COLOR,fib.SR.shadow.2.c);
     ObjectSetText("lo.1.p2",DoubleToStr(lo.ma.p2.1,Digits),7,"Arial",fib.SR.shadow.2.c);

     ObjectCreate("hi.1.p2",OBJ_TREND,0,t1.p2, hi.ma.p2.1, t2.p2, hi.ma.p2.1);
     ObjectSet("hi.1.p2",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("hi.1.p2",OBJPROP_WIDTH,2);
     ObjectSet("hi.1.p2",OBJPROP_RAY,false);
     ObjectSet("hi.1.p2",OBJPROP_COLOR,fib.SR.shadow.2.c);
     ObjectSetText("hi.1.p2",DoubleToStr(hi.ma.p2.1,Digits),7,"Arial",fib.SR.shadow.2.c);   }

// 2nd level (hi.2.p2, lo.2.p2)
  if(lo.ma.p2.2-hi.ma.p2.2>Ask-Bid)   {
     ObjectCreate("lo.2.p2",OBJ_TREND,0,t1.p2, lo.ma.p2.2, t2.p2, lo.ma.p2.2);
     ObjectSet("lo.2.p2",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("lo.2.p2",OBJPROP_WIDTH,2);
     ObjectSet("lo.2.p2",OBJPROP_RAY,false);
     ObjectSet("lo.2.p2",OBJPROP_COLOR,fib.SR.shadow.3.c);
     ObjectSetText("lo.2.p2",DoubleToStr(lo.ma.p2.2,Digits),7,"Arial",fib.SR.shadow.3.c);

     ObjectCreate("hi.2.p2",OBJ_TREND,0,t1.p2, hi.ma.p2.2, t2.p2, hi.ma.p2.2);
     ObjectSet("hi.2.p2",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("hi.2.p2",OBJPROP_WIDTH,2);
     ObjectSet("hi.2.p2",OBJPROP_RAY,false);
     ObjectSet("hi.2.p2",OBJPROP_COLOR,fib.SR.shadow.3.c);
     ObjectSetText("hi.2.p2",DoubleToStr(hi.ma.p2.2,Digits),7,"Arial",fib.SR.shadow.3.c);   }

// 3rd level (hi.3.p2, lo.3.p2)
  if(lo.ma.p2.3-hi.ma.p2.3>Ask-Bid)   {
     ObjectCreate("lo.3.p2",OBJ_TREND,0,t1.p2, lo.ma.p2.3, t2.p2, lo.ma.p2.3);
     ObjectSet("lo.3.p2",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("lo.3.p2",OBJPROP_WIDTH,2);
     ObjectSet("lo.3.p2",OBJPROP_RAY,false);
     ObjectSet("lo.3.p2",OBJPROP_COLOR,fib.SR.shadow.4.c);
     ObjectSetText("lo.3.p2",DoubleToStr(lo.ma.p2.3,Digits),7,"Arial",fib.SR.shadow.4.c);

     ObjectCreate("hi.3.p2",OBJ_TREND,0,t1.p2, hi.ma.p2.3, t2.p2, hi.ma.p2.3);
     ObjectSet("hi.3.p2",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("hi.3.p2",OBJPROP_WIDTH,2);
     ObjectSet("hi.3.p2",OBJPROP_RAY,false);
     ObjectSet("hi.3.p2",OBJPROP_COLOR,fib.SR.shadow.4.c);
     ObjectSetText("hi.3.p2",DoubleToStr(hi.ma.p2.3,Digits),7,"Arial",fib.SR.shadow.4.c);   }

// 4th level (hi.4.p2, lo.4.p2)
  if(lo.ma.p2.4-hi.ma.p2.4>Ask-Bid)   {
     ObjectCreate("lo.4.p2",OBJ_TREND,0,t1.p2, lo.ma.p2.4, t2.p2, lo.ma.p2.4);
     ObjectSet("lo.4.p2",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("lo.4.p2",OBJPROP_WIDTH,2);
     ObjectSet("lo.4.p2",OBJPROP_RAY,false);
     ObjectSet("lo.4.p2",OBJPROP_COLOR,fib.SR.shadow.5.c);
     ObjectSetText("lo.4.p2",DoubleToStr(lo.ma.p2.4,Digits),7,"Arial",fib.SR.shadow.5.c);

     ObjectCreate("hi.4.p2",OBJ_TREND,0,t1.p2, hi.ma.p2.4, t2.p2, hi.ma.p2.4);
     ObjectSet("hi.4.p2",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("hi.4.p2",OBJPROP_WIDTH,2);
     ObjectSet("hi.4.p2",OBJPROP_RAY,false);
     ObjectSet("hi.4.p2",OBJPROP_COLOR,fib.SR.shadow.5.c);
     ObjectSetText("hi.4.p2",DoubleToStr(hi.ma.p2.4,Digits),7,"Arial",fib.SR.shadow.5.c);   }

// 5th level (hi.5.p2, lo.5.p2)
  if(lo.ma.p2.5-hi.ma.p2.5>Ask-Bid)   {
     ObjectCreate("lo.5.p2",OBJ_TREND,0,t1.p2, lo.ma.p2.5, t2.p2, lo.ma.p2.5);
     ObjectSet("lo.5.p2",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("lo.5.p2",OBJPROP_WIDTH,2);
     ObjectSet("lo.5.p2",OBJPROP_RAY,false);
     ObjectSet("lo.5.p2",OBJPROP_COLOR,fib.SR.shadow.6.c);
     ObjectSetText("lo.5.p2",DoubleToStr(lo.ma.p2.5,Digits),7,"Arial",fib.SR.shadow.6.c);

     ObjectCreate("hi.5.p2",OBJ_TREND,0,t1.p2, hi.ma.p2.5, t2.p2, hi.ma.p2.5);
     ObjectSet("hi.5.p2",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("hi.5.p2",OBJPROP_WIDTH,2);
     ObjectSet("hi.5.p2",OBJPROP_RAY,false);
     ObjectSet("hi.5.p2",OBJPROP_COLOR,fib.SR.shadow.6.c);
     ObjectSetText("hi.5.p2",DoubleToStr(hi.ma.p2.5,Digits),7,"Arial",fib.SR.shadow.6.c);   }

// 6th level (hi.6.p2, lo.6.p2)
  if(lo.ma.p2.6-hi.ma.p2.6>Ask-Bid)   {
     ObjectCreate("lo.6.p2",OBJ_TREND,0,t1.p2, lo.ma.p2.6, t2.p2, lo.ma.p2.6);
     ObjectSet("lo.6.p2",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("lo.6.p2",OBJPROP_WIDTH,2);
     ObjectSet("lo.6.p2",OBJPROP_RAY,false);
     ObjectSet("lo.6.p2",OBJPROP_COLOR,fib.SR.shadow.7.c);
     ObjectSetText("lo.6.p2",DoubleToStr(lo.ma.p2.6,Digits),7,"Arial",fib.SR.shadow.7.c);

     ObjectCreate("hi.6.p2",OBJ_TREND,0,t1.p2, hi.ma.p2.6, t2.p2, hi.ma.p2.6);
     ObjectSet("hi.6.p2",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("hi.6.p2",OBJPROP_WIDTH,2);
     ObjectSet("hi.6.p2",OBJPROP_RAY,false);
     ObjectSet("hi.6.p2",OBJPROP_COLOR,fib.SR.shadow.7.c);
     ObjectSetText("hi.6.p2",DoubleToStr(hi.ma.p2.6,Digits),7,"Arial",fib.SR.shadow.7.c);   }
//...............Moving Average Support & Resistance Levels..............................
  string space="             ";
//      ObjectCreate("ma1.p2",OBJ_TEXT,0,t1.p2,ma1.p2);//13 ma
     ObjectSetText("ma1.p2",space+DoubleToStr(ma1.p2,Digits),8,"Arial",White);

//      ObjectCreate("ma2.p2",OBJ_TEXT,0,t1.p2,ma2.p2);//21 ma
     ObjectSetText("ma2.p2",space+DoubleToStr(ma2.p2,Digits),8,"Arial",White);

//      ObjectCreate("ma3.p2",OBJ_TEXT,0,t1.p2,ma3.p2);//34 ma
     if(Bid>ma3.p2) {ObjectSetText("ma3.p2",space+DoubleToStr(ma3.p2,Digits),8,"Arial",LightGreen);}
     if(Ask<ma3.p2) {ObjectSetText("ma3.p2",space+DoubleToStr(ma3.p2,Digits),8,"Arial",Pink);}
     if(Bid<=ma3.p2 && Ask>=ma3.p2)  {
        ObjectSetText("ma3.p2",space+DoubleToStr(ma3.p2,Digits),8,"Arial",Yellow);}

//      ObjectCreate("ma4.p2",OBJ_TEXT,0,t1.p2,ma4.p2);//55 ma
     if(Bid>ma4.p2) {ObjectSetText("ma4.p2",space+DoubleToStr(ma4.p2,Digits),8,"Arial",LightGreen);}
     if(Ask<ma4.p2) {ObjectSetText("ma4.p2",space+DoubleToStr(ma4.p2,Digits),8,"Arial",Pink);}
     if(Bid<=ma4.p2 && Ask>=ma4.p2)  {
        ObjectSetText("ma4.p2",space+DoubleToStr(ma4.p2,Digits),8,"Arial",Yellow);}

//      ObjectCreate("ma5.p2",OBJ_TEXT,0,t1.p2,ma5.p2);//89 ma
     if(Bid>ma5.p2) {ObjectSetText("ma5.p2",space+DoubleToStr(ma5.p2,Digits),8,"Arial",Green);}
     if(Ask<ma5.p2) {ObjectSetText("ma5.p2",space+DoubleToStr(ma5.p2,Digits),8,"Arial",Red);}
     if(Bid<=ma5.p2 && Ask>=ma5.p2)  {
        ObjectSetText("ma5.p2",space+DoubleToStr(ma5.p2,Digits),8,"Arial",Yellow);}

//      ObjectCreate("ma6.p2",OBJ_TEXT,0,t1.p2,NormalizeDouble(ma6.p2,Digits));//144 ma
     if(Bid>ma6.p2) {ObjectSetText("ma6.p2",space+DoubleToStr(ma6.p2,Digits),8,"Arial",Green);}
     if(Ask<ma6.p2) {ObjectSetText("ma6.p2",space+DoubleToStr(ma6.p2,Digits),8,"Arial",Red);}
     if(Bid<=ma6.p2 && Ask>=ma6.p2)  {
        ObjectSetText("ma6.p2",space+DoubleToStr(ma6.p2,Digits),8,"Arial",Yellow);}

//      ObjectCreate("ma7.p2",OBJ_TEXT,0,t1.p2,NormalizeDouble(ma7.p2,Digits));//233 ma
     if(Bid>ma7.p2) {ObjectSetText("ma7.p2",space+DoubleToStr(ma7.p2,Digits),8,"Arial",Green);}
     if(Ask<ma7.p2) {ObjectSetText("ma7.p2",space+DoubleToStr(ma7.p2,Digits),8,"Arial",Red);}
     if(Bid<=ma7.p2 && Ask>=ma7.p2)  {
        ObjectSetText("ma7.p2",space+DoubleToStr(ma7.p2,Digits),8,"Arial",Yellow);}
}//end p2.Fib.Plot()

void p3.Fib.Plot()   {
//p3 dynamic fibo levels
  double lo.ma.p3,hi.ma.p3;
  lo.ma.p3=ma1.p3;
  if(ma2.p3<lo.ma.p3)  {lo.ma.p3=ma2.p3;}
  if(ma3.p3<lo.ma.p3)  {lo.ma.p3=ma3.p3;}
  if(ma4.p3<lo.ma.p3)  {lo.ma.p3=ma4.p3;}
  if(ma5.p3<lo.ma.p3)  {lo.ma.p3=ma5.p3;}
  if(ma6.p3<lo.ma.p3)  {lo.ma.p3=ma6.p3;}
  if(ma7.p3<lo.ma.p3)  {lo.ma.p3=ma7.p3;}
  lo.ma.p3=NormalizeDouble(lo.ma.p3+(fib.SR.shadow.1*Point),Digits);

  hi.ma.p3=ma7.p3;
  if(ma6.p3>hi.ma.p3)  {hi.ma.p3=ma6.p3;}
  if(ma5.p3>hi.ma.p3)  {hi.ma.p3=ma5.p3;}
  if(ma4.p3>hi.ma.p3)  {hi.ma.p3=ma4.p3;}
  if(ma3.p3>hi.ma.p3)  {hi.ma.p3=ma3.p3;}
  if(ma2.p3>hi.ma.p3)  {hi.ma.p3=ma2.p3;}
  if(ma1.p3>hi.ma.p3)  {hi.ma.p3=ma1.p3;}
  hi.ma.p3=NormalizeDouble(hi.ma.p3-(fib.SR.shadow.1*Point),Digits);

//p3 center dynamic fib placement
  if(lo.ma.p3-hi.ma.p3>Ask-Bid)   {
     ObjectCreate("lcf.p3",OBJ_TREND,0,t1.p3, lo.ma.p3, t2.p3, lo.ma.p3);
     ObjectSet("lcf.p3",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("lcf.p3",OBJPROP_WIDTH,2);
     ObjectSet("lcf.p3",OBJPROP_RAY,false);
     ObjectSet("lcf.p3",OBJPROP_COLOR,fib.SR.shadow.1.c);
     ObjectSetText("lcf.p3",DoubleToStr(lo.ma.p3,Digits),7,"Arial",fib.SR.shadow.1.c);

     ObjectCreate("hcf.p3",OBJ_TREND,0,t1.p3, hi.ma.p3, t2.p3, hi.ma.p3);
     ObjectSet("hcf.p3",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("hcf.p3",OBJPROP_WIDTH,2);
     ObjectSet("hcf.p3",OBJPROP_RAY,false);
     ObjectSet("hcf.p3",OBJPROP_COLOR,fib.SR.shadow.1.c);
     ObjectSetText("hcf.p3",DoubleToStr(hi.ma.p3,Digits),7,"Arial",fib.SR.shadow.1.c);   }

  double lo.ma.p3.1, lo.ma.p3.2, lo.ma.p3.3, lo.ma.p3.4, lo.ma.p3.5, lo.ma.p3.6;
  lo.ma.p3.1=lo.ma.p3+(fib.SR.shadow.2*Point);
  lo.ma.p3.2=lo.ma.p3.1+(fib.SR.shadow.3*Point);
  lo.ma.p3.3=lo.ma.p3.2+(fib.SR.shadow.4*Point);
  lo.ma.p3.4=lo.ma.p3.3+(fib.SR.shadow.5*Point);
  lo.ma.p3.5=lo.ma.p3.4+(fib.SR.shadow.6*Point);
  lo.ma.p3.6=lo.ma.p3.5+(fib.SR.shadow.7*Point);

  double hi.ma.p3.1, hi.ma.p3.2, hi.ma.p3.3, hi.ma.p3.4, hi.ma.p3.5, hi.ma.p3.6;
  hi.ma.p3.1=hi.ma.p3-(fib.SR.shadow.2*Point);
  hi.ma.p3.2=hi.ma.p3.1-(fib.SR.shadow.3*Point);
  hi.ma.p3.3=hi.ma.p3.2-(fib.SR.shadow.4*Point);
  hi.ma.p3.4=hi.ma.p3.3-(fib.SR.shadow.5*Point);
  hi.ma.p3.5=hi.ma.p3.4-(fib.SR.shadow.6*Point);
  hi.ma.p3.6=hi.ma.p3.5-(fib.SR.shadow.7*Point);

//p3 1st level (hi.1.p3, lo.1.p3)
  if(lo.ma.p3.1-hi.ma.p3.1>Ask-Bid)   {
     ObjectCreate("lo.1.p3",OBJ_TREND,0,t1.p3, lo.ma.p3.1, t2.p3, lo.ma.p3.1);
     ObjectSet("lo.1.p3",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("lo.1.p3",OBJPROP_WIDTH,2);
     ObjectSet("lo.1.p3",OBJPROP_RAY,false);
     ObjectSet("lo.1.p3",OBJPROP_COLOR,fib.SR.shadow.2.c);
     ObjectSetText("lo.1.p3",DoubleToStr(lo.ma.p3.1,Digits),7,"Arial",fib.SR.shadow.2.c);

     ObjectCreate("hi.1.p3",OBJ_TREND,0,t1.p3, hi.ma.p3.1, t2.p3, hi.ma.p3.1);
     ObjectSet("hi.1.p3",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("hi.1.p3",OBJPROP_WIDTH,2);
     ObjectSet("hi.1.p3",OBJPROP_RAY,false);
     ObjectSet("hi.1.p3",OBJPROP_COLOR,fib.SR.shadow.2.c);
     ObjectSetText("hi.1.p3",DoubleToStr(hi.ma.p3.1,Digits),7,"Arial",fib.SR.shadow.2.c);   }

// 2nd level (hi.2.p3, lo.2.p3)
  if(lo.ma.p3.2-hi.ma.p3.2>Ask-Bid)   {
     ObjectCreate("lo.2.p3",OBJ_TREND,0,t1.p3, lo.ma.p3.2, t2.p3, lo.ma.p3.2);
     ObjectSet("lo.2.p3",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("lo.2.p3",OBJPROP_WIDTH,2);
     ObjectSet("lo.2.p3",OBJPROP_RAY,false);
     ObjectSet("lo.2.p3",OBJPROP_COLOR,fib.SR.shadow.3.c);
     ObjectSetText("lo.2.p3",DoubleToStr(lo.ma.p3.2,Digits),7,"Arial",fib.SR.shadow.3.c);

     ObjectCreate("hi.2.p3",OBJ_TREND,0,t1.p3, hi.ma.p3.2, t2.p3, hi.ma.p3.2);
     ObjectSet("hi.2.p3",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("hi.2.p3",OBJPROP_WIDTH,2);
     ObjectSet("hi.2.p3",OBJPROP_RAY,false);
     ObjectSet("hi.2.p3",OBJPROP_COLOR,fib.SR.shadow.3.c);
     ObjectSetText("hi.2.p3",DoubleToStr(hi.ma.p3.2,Digits),7,"Arial",fib.SR.shadow.3.c);   }

// 3rd level (hi.3.p3, lo.3.p3)
  if(lo.ma.p3.3-hi.ma.p3.3>Ask-Bid)   {
     ObjectCreate("lo.3.p3",OBJ_TREND,0,t1.p3, lo.ma.p3.3, t2.p3, lo.ma.p3.3);
     ObjectSet("lo.3.p3",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("lo.3.p3",OBJPROP_WIDTH,2);
     ObjectSet("lo.3.p3",OBJPROP_RAY,false);
     ObjectSet("lo.3.p3",OBJPROP_COLOR,fib.SR.shadow.4.c);
     ObjectSetText("lo.3.p3",DoubleToStr(lo.ma.p3.3,Digits),7,"Arial",fib.SR.shadow.4.c);

     ObjectCreate("hi.3.p3",OBJ_TREND,0,t1.p3, hi.ma.p3.3, t2.p3, hi.ma.p3.3);
     ObjectSet("hi.3.p3",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("hi.3.p3",OBJPROP_WIDTH,2);
     ObjectSet("hi.3.p3",OBJPROP_RAY,false);
     ObjectSet("hi.3.p3",OBJPROP_COLOR,fib.SR.shadow.4.c);
     ObjectSetText("hi.3.p3",DoubleToStr(hi.ma.p3.3,Digits),7,"Arial",fib.SR.shadow.4.c);   }

// 4th level (hi.4.p3, lo.4.p3)
  if(lo.ma.p3.4-hi.ma.p3.4>Ask-Bid)   {
     ObjectCreate("lo.4.p3",OBJ_TREND,0,t1.p3, lo.ma.p3.4, t2.p3, lo.ma.p3.4);
     ObjectSet("lo.4.p3",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("lo.4.p3",OBJPROP_WIDTH,2);
     ObjectSet("lo.4.p3",OBJPROP_RAY,false);
     ObjectSet("lo.4.p3",OBJPROP_COLOR,fib.SR.shadow.5.c);
     ObjectSetText("lo.4.p3",DoubleToStr(lo.ma.p3.4,Digits),7,"Arial",fib.SR.shadow.5.c);

     ObjectCreate("hi.4.p3",OBJ_TREND,0,t1.p3, hi.ma.p3.4, t2.p3, hi.ma.p3.4);
     ObjectSet("hi.4.p3",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("hi.4.p3",OBJPROP_WIDTH,2);
     ObjectSet("hi.4.p3",OBJPROP_RAY,false);
     ObjectSet("hi.4.p3",OBJPROP_COLOR,fib.SR.shadow.5.c);
     ObjectSetText("hi.4.p3",DoubleToStr(hi.ma.p3.4,Digits),7,"Arial",fib.SR.shadow.5.c);   }

// 5th level (hi.5.p3, lo.5.p3)
  if(lo.ma.p3.5-hi.ma.p3.5>Ask-Bid)   {
     ObjectCreate("lo.5.p3",OBJ_TREND,0,t1.p3, lo.ma.p3.5, t2.p3, lo.ma.p3.5);
     ObjectSet("lo.5.p3",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("lo.5.p3",OBJPROP_WIDTH,2);
     ObjectSet("lo.5.p3",OBJPROP_RAY,false);
     ObjectSet("lo.5.p3",OBJPROP_COLOR,fib.SR.shadow.6.c);
     ObjectSetText("lo.5.p3",DoubleToStr(lo.ma.p3.5,Digits),7,"Arial",fib.SR.shadow.6.c);

     ObjectCreate("hi.5.p3",OBJ_TREND,0,t1.p3, hi.ma.p3.5, t2.p3, hi.ma.p3.5);
     ObjectSet("hi.5.p3",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("hi.5.p3",OBJPROP_WIDTH,2);
     ObjectSet("hi.5.p3",OBJPROP_RAY,false);
     ObjectSet("hi.5.p3",OBJPROP_COLOR,fib.SR.shadow.6.c);
     ObjectSetText("hi.5.p3",DoubleToStr(hi.ma.p3.5,Digits),7,"Arial",fib.SR.shadow.6.c);   }

// 6th level (hi.6.p3, lo.6.p3)
  if(lo.ma.p3.6-hi.ma.p3.6>Ask-Bid)   {
     ObjectCreate("lo.6.p3",OBJ_TREND,0,t1.p3, lo.ma.p3.6, t2.p3, lo.ma.p3.6);
     ObjectSet("lo.6.p3",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("lo.6.p3",OBJPROP_WIDTH,2);
     ObjectSet("lo.6.p3",OBJPROP_RAY,false);
     ObjectSet("lo.6.p3",OBJPROP_COLOR,fib.SR.shadow.7.c);
     ObjectSetText("lo.6.p3",DoubleToStr(lo.ma.p3.6,Digits),7,"Arial",fib.SR.shadow.7.c);

     ObjectCreate("hi.6.p3",OBJ_TREND,0,t1.p3, hi.ma.p3.6, t2.p3, hi.ma.p3.6);
     ObjectSet("hi.6.p3",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("hi.6.p3",OBJPROP_WIDTH,2);
     ObjectSet("hi.6.p3",OBJPROP_RAY,false);
     ObjectSet("hi.6.p3",OBJPROP_COLOR,fib.SR.shadow.7.c);
     ObjectSetText("hi.6.p3",DoubleToStr(hi.ma.p3.6,Digits),7,"Arial",fib.SR.shadow.7.c);   }
//...............Moving Average Support & Resistance Levels..............................
  string space="             ";
//      ObjectCreate("ma1.p3",OBJ_TEXT,0,t1.p3,ma1.p3);//13 ma
     ObjectSetText("ma1.p3",space+DoubleToStr(ma1.p3,Digits),8,"Arial",White);

 //     ObjectCreate("ma2.p3",OBJ_TEXT,0,t1.p3,ma2.p3);//21 ma
     ObjectSetText("ma2.p3",space+DoubleToStr(ma2.p3,Digits),8,"Arial",White);

//      ObjectCreate("ma3.p3",OBJ_TEXT,0,t1.p3,ma3.p3);//34 ma
     if(Bid>ma3.p3) {ObjectSetText("ma3.p3",space+DoubleToStr(ma3.p3,Digits),8,"Arial",LightGreen);}
     if(Ask<ma3.p3) {ObjectSetText("ma3.p3",space+DoubleToStr(ma3.p3,Digits),8,"Arial",Pink);}
     if(Bid<=ma3.p3 && Ask>=ma3.p3)  {
        ObjectSetText("ma3.p3",space+DoubleToStr(ma3.p3,Digits),8,"Arial",Yellow);}

//      ObjectCreate("ma4.p3",OBJ_TEXT,0,t1.p3,ma4.p3);//55 ma
     if(Bid>ma4.p3) {ObjectSetText("ma4.p3",space+DoubleToStr(ma4.p3,Digits),8,"Arial",LightGreen);}
     if(Ask<ma4.p3) {ObjectSetText("ma4.p3",space+DoubleToStr(ma4.p3,Digits),8,"Arial",Pink);}
     if(Bid<=ma4.p3 && Ask>=ma4.p3)  {
        ObjectSetText("ma4.p3",space+DoubleToStr(ma4.p3,Digits),8,"Arial",Yellow);}

//      ObjectCreate("ma5.p3",OBJ_TEXT,0,t1.p3,ma5.p3);//89 ma
     if(Bid>ma5.p3) {ObjectSetText("ma5.p3",space+DoubleToStr(ma5.p3,Digits),8,"Arial",Green);}
     if(Ask<ma5.p3) {ObjectSetText("ma5.p3",space+DoubleToStr(ma5.p3,Digits),8,"Arial",Red);}
     if(Bid<=ma5.p3 && Ask>=ma5.p3)  {
        ObjectSetText("ma5.p3",space+DoubleToStr(ma5.p3,Digits),8,"Arial",Yellow);}

//      ObjectCreate("ma6.p3",OBJ_TEXT,0,t1.p3,NormalizeDouble(ma6.p3,Digits));//144 ma
     if(Bid>ma6.p3) {ObjectSetText("ma6.p3",space+DoubleToStr(ma6.p3,Digits),8,"Arial",Green);}
     if(Ask<ma6.p3) {ObjectSetText("ma6.p3",space+DoubleToStr(ma6.p3,Digits),8,"Arial",Red);}
     if(Bid<=ma6.p3 && Ask>=ma6.p3)  {
        ObjectSetText("ma6.p3",space+DoubleToStr(ma6.p3,Digits),8,"Arial",Yellow);}

//      ObjectCreate("ma7.p3",OBJ_TEXT,0,t1.p3,NormalizeDouble(ma7.p3,Digits));//233 ma
     if(Bid>ma7.p3) {ObjectSetText("ma7.p3",space+DoubleToStr(ma7.p3,Digits),8,"Arial",Green);}
     if(Ask<ma7.p3) {ObjectSetText("ma7.p3",space+DoubleToStr(ma7.p3,Digits),8,"Arial",Red);}
     if(Bid<=ma7.p3 && Ask>=ma7.p3)  {
        ObjectSetText("ma7.p3",space+DoubleToStr(ma7.p3,Digits),8,"Arial",Yellow);}
}//end p3.Fib.Plot()

void p4.Fib.Plot()   {
//p4 dynamic fibo levels
  double lo.ma.p4,hi.ma.p4;
  lo.ma.p4=ma1.p4;
  if(ma2.p4<lo.ma.p4)  {lo.ma.p4=ma2.p4;}
  if(ma3.p4<lo.ma.p4)  {lo.ma.p4=ma3.p4;}
  if(ma4.p4<lo.ma.p4)  {lo.ma.p4=ma4.p4;}
  if(ma5.p4<lo.ma.p4)  {lo.ma.p4=ma5.p4;}
  if(ma6.p4<lo.ma.p4)  {lo.ma.p4=ma6.p4;}
  if(ma7.p4<lo.ma.p4)  {lo.ma.p4=ma7.p4;}
  lo.ma.p4=NormalizeDouble(lo.ma.p4+(fib.SR.shadow.1*Point),Digits);

  hi.ma.p4=ma7.p4;
  if(ma6.p4>hi.ma.p4)  {hi.ma.p4=ma6.p4;}
  if(ma5.p4>hi.ma.p4)  {hi.ma.p4=ma5.p4;}
  if(ma4.p4>hi.ma.p4)  {hi.ma.p4=ma4.p4;}
  if(ma3.p4>hi.ma.p4)  {hi.ma.p4=ma3.p4;}
  if(ma2.p4>hi.ma.p4)  {hi.ma.p4=ma2.p4;}
  if(ma1.p4>hi.ma.p4)  {hi.ma.p4=ma1.p4;}
  hi.ma.p4=NormalizeDouble(hi.ma.p4-(fib.SR.shadow.1*Point),Digits);

//p4 center dynamic fib placement
  if(lo.ma.p4-hi.ma.p4>Ask-Bid)   {
     ObjectCreate("lcf.p4",OBJ_TREND,0,t1.p4, lo.ma.p4, t2.p4, lo.ma.p4);
     ObjectSet("lcf.p4",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("lcf.p4",OBJPROP_WIDTH,2);
     ObjectSet("lcf.p4",OBJPROP_RAY,false);
     ObjectSet("lcf.p4",OBJPROP_COLOR,fib.SR.shadow.1.c);
     ObjectSetText("lcf.p4",DoubleToStr(lo.ma.p4,Digits),7,"Arial",fib.SR.shadow.1.c);

     ObjectCreate("hcf.p4",OBJ_TREND,0,t1.p4, hi.ma.p4, t2.p4, hi.ma.p4);
     ObjectSet("hcf.p4",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("hcf.p4",OBJPROP_WIDTH,2);
     ObjectSet("hcf.p4",OBJPROP_RAY,false);
     ObjectSet("hcf.p4",OBJPROP_COLOR,fib.SR.shadow.1.c);
     ObjectSetText("hcf.p4",DoubleToStr(hi.ma.p4,Digits),7,"Arial",fib.SR.shadow.1.c);   }

  double lo.ma.p4.1, lo.ma.p4.2, lo.ma.p4.3, lo.ma.p4.4, lo.ma.p4.5, lo.ma.p4.6;
  lo.ma.p4.1=lo.ma.p4+(fib.SR.shadow.2*Point);
  lo.ma.p4.2=lo.ma.p4.1+(fib.SR.shadow.3*Point);
  lo.ma.p4.3=lo.ma.p4.2+(fib.SR.shadow.4*Point);
  lo.ma.p4.4=lo.ma.p4.3+(fib.SR.shadow.5*Point);
  lo.ma.p4.5=lo.ma.p4.4+(fib.SR.shadow.6*Point);
  lo.ma.p4.6=lo.ma.p4.5+(fib.SR.shadow.7*Point);

  double hi.ma.p4.1, hi.ma.p4.2, hi.ma.p4.3, hi.ma.p4.4, hi.ma.p4.5, hi.ma.p4.6;
  hi.ma.p4.1=hi.ma.p4-(fib.SR.shadow.2*Point);
  hi.ma.p4.2=hi.ma.p4.1-(fib.SR.shadow.3*Point);
  hi.ma.p4.3=hi.ma.p4.2-(fib.SR.shadow.4*Point);
  hi.ma.p4.4=hi.ma.p4.3-(fib.SR.shadow.5*Point);
  hi.ma.p4.5=hi.ma.p4.4-(fib.SR.shadow.6*Point);
  hi.ma.p4.6=hi.ma.p4.5-(fib.SR.shadow.7*Point);

//p4 1st level (hi.1.p4, lo.1.p4)
  if(lo.ma.p4.1-hi.ma.p4.1>Ask-Bid)   {
     ObjectCreate("lo.1.p4",OBJ_TREND,0,t1.p4, lo.ma.p4.1, t2.p4, lo.ma.p4.1);
     ObjectSet("lo.1.p4",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("lo.1.p4",OBJPROP_WIDTH,2);
     ObjectSet("lo.1.p4",OBJPROP_RAY,false);
     ObjectSet("lo.1.p4",OBJPROP_COLOR,fib.SR.shadow.2.c);
     ObjectSetText("lo.1.p4",DoubleToStr(lo.ma.p4.1,Digits),7,"Arial",fib.SR.shadow.2.c);

     ObjectCreate("hi.1.p4",OBJ_TREND,0,t1.p4, hi.ma.p4.1, t2.p4, hi.ma.p4.1);
     ObjectSet("hi.1.p4",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("hi.1.p4",OBJPROP_WIDTH,2);
     ObjectSet("hi.1.p4",OBJPROP_RAY,false);
     ObjectSet("hi.1.p4",OBJPROP_COLOR,fib.SR.shadow.2.c);
     ObjectSetText("hi.1.p4",DoubleToStr(hi.ma.p4.1,Digits),7,"Arial",fib.SR.shadow.2.c);   }

// 2nd level (hi.2.p4, lo.2.p4)
  if(lo.ma.p4.2-hi.ma.p4.2>Ask-Bid)   {
     ObjectCreate("lo.2.p4",OBJ_TREND,0,t1.p4, lo.ma.p4.2, t2.p4, lo.ma.p4.2);
     ObjectSet("lo.2.p4",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("lo.2.p4",OBJPROP_WIDTH,2);
     ObjectSet("lo.2.p4",OBJPROP_RAY,false);
     ObjectSet("lo.2.p4",OBJPROP_COLOR,fib.SR.shadow.3.c);
     ObjectSetText("lo.2.p4",DoubleToStr(lo.ma.p4.2,Digits),7,"Arial",fib.SR.shadow.3.c);

     ObjectCreate("hi.2.p4",OBJ_TREND,0,t1.p4, hi.ma.p4.2, t2.p4, hi.ma.p4.2);
     ObjectSet("hi.2.p4",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("hi.2.p4",OBJPROP_WIDTH,2);
     ObjectSet("hi.2.p4",OBJPROP_RAY,false);
     ObjectSet("hi.2.p4",OBJPROP_COLOR,fib.SR.shadow.3.c);
     ObjectSetText("hi.2.p4",DoubleToStr(hi.ma.p4.2,Digits),7,"Arial",fib.SR.shadow.3.c);   }

// 3rd level (hi.3.p4, lo.3.p4)
  if(lo.ma.p4.3-hi.ma.p4.3>Ask-Bid)   {
     ObjectCreate("lo.3.p4",OBJ_TREND,0,t1.p4, lo.ma.p4.3, t2.p4, lo.ma.p4.3);
     ObjectSet("lo.3.p4",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("lo.3.p4",OBJPROP_WIDTH,2);
     ObjectSet("lo.3.p4",OBJPROP_RAY,false);
     ObjectSet("lo.3.p4",OBJPROP_COLOR,fib.SR.shadow.4.c);
     ObjectSetText("lo.3.p4",DoubleToStr(lo.ma.p4.3,Digits),7,"Arial",fib.SR.shadow.4.c);

     ObjectCreate("hi.3.p4",OBJ_TREND,0,t1.p4, hi.ma.p4.3, t2.p4, hi.ma.p4.3);
     ObjectSet("hi.3.p4",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("hi.3.p4",OBJPROP_WIDTH,2);
     ObjectSet("hi.3.p4",OBJPROP_RAY,false);
     ObjectSet("hi.3.p4",OBJPROP_COLOR,fib.SR.shadow.4.c);
     ObjectSetText("hi.3.p4",DoubleToStr(hi.ma.p4.3,Digits),7,"Arial",fib.SR.shadow.4.c);   }

// 4th level (hi.4.p4, lo.4.p4)
  if(lo.ma.p4.4-hi.ma.p4.4>Ask-Bid)   {
     ObjectCreate("lo.4.p4",OBJ_TREND,0,t1.p4, lo.ma.p4.4, t2.p4, lo.ma.p4.4);
     ObjectSet("lo.4.p4",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("lo.4.p4",OBJPROP_WIDTH,2);
     ObjectSet("lo.4.p4",OBJPROP_RAY,false);
     ObjectSet("lo.4.p4",OBJPROP_COLOR,fib.SR.shadow.5.c);
     ObjectSetText("lo.4.p4",DoubleToStr(lo.ma.p4.4,Digits),7,"Arial",fib.SR.shadow.5.c);

     ObjectCreate("hi.4.p4",OBJ_TREND,0,t1.p4, hi.ma.p4.4, t2.p4, hi.ma.p4.4);
     ObjectSet("hi.4.p4",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("hi.4.p4",OBJPROP_WIDTH,2);
     ObjectSet("hi.4.p4",OBJPROP_RAY,false);
     ObjectSet("hi.4.p4",OBJPROP_COLOR,fib.SR.shadow.5.c);
     ObjectSetText("hi.4.p4",DoubleToStr(hi.ma.p4.4,Digits),7,"Arial",fib.SR.shadow.5.c);   }

// 5th level (hi.5.p4, lo.5.p4)
  if(lo.ma.p4.5-hi.ma.p4.5>Ask-Bid)   {
     ObjectCreate("lo.5.p4",OBJ_TREND,0,t1.p4, lo.ma.p4.5, t2.p4, lo.ma.p4.5);
     ObjectSet("lo.5.p4",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("lo.5.p4",OBJPROP_WIDTH,2);
     ObjectSet("lo.5.p4",OBJPROP_RAY,false);
     ObjectSet("lo.5.p4",OBJPROP_COLOR,fib.SR.shadow.6.c);
     ObjectSetText("lo.5.p4",DoubleToStr(lo.ma.p4.5,Digits),7,"Arial",fib.SR.shadow.6.c);

     ObjectCreate("hi.5.p4",OBJ_TREND,0,t1.p4, hi.ma.p4.5, t2.p4, hi.ma.p4.5);
     ObjectSet("hi.5.p4",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("hi.5.p4",OBJPROP_WIDTH,2);
     ObjectSet("hi.5.p4",OBJPROP_RAY,false);
     ObjectSet("hi.5.p4",OBJPROP_COLOR,fib.SR.shadow.6.c);
     ObjectSetText("hi.5.p4",DoubleToStr(hi.ma.p4.5,Digits),7,"Arial",fib.SR.shadow.6.c);   }

// 6th level (hi.6.p4, lo.6.p4)
  if(lo.ma.p4.6-hi.ma.p4.6>Ask-Bid)   {
     ObjectCreate("lo.6.p4",OBJ_TREND,0,t1.p4, lo.ma.p4.6, t2.p4, lo.ma.p4.6);
     ObjectSet("lo.6.p4",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("lo.6.p4",OBJPROP_WIDTH,2);
     ObjectSet("lo.6.p4",OBJPROP_RAY,false);
     ObjectSet("lo.6.p4",OBJPROP_COLOR,fib.SR.shadow.7.c);
     ObjectSetText("lo.6.p4",DoubleToStr(lo.ma.p4.6,Digits),7,"Arial",fib.SR.shadow.7.c);

     ObjectCreate("hi.6.p4",OBJ_TREND,0,t1.p4, hi.ma.p4.6, t2.p4, hi.ma.p4.6);
     ObjectSet("hi.6.p4",OBJPROP_STYLE,STYLE_SOLID);
     ObjectSet("hi.6.p4",OBJPROP_WIDTH,2);
     ObjectSet("hi.6.p4",OBJPROP_RAY,false);
     ObjectSet("hi.6.p4",OBJPROP_COLOR,fib.SR.shadow.7.c);
     ObjectSetText("hi.6.p4",DoubleToStr(hi.ma.p4.6,Digits),7,"Arial",fib.SR.shadow.7.c);   }
//...............Moving Average Support & Resistance Levels..............................
  string space="             ";
 //     ObjectCreate("ma1.p4",OBJ_TEXT,0,t1.p4,ma1.p4);//13 ma
     ObjectSetText("ma1.p4",space+DoubleToStr(ma1.p4,Digits),8,"Arial",White);

 //     ObjectCreate("ma2.p4",OBJ_TEXT,0,t1.p4,ma2.p4);//21 ma
     ObjectSetText("ma2.p4",space+DoubleToStr(ma2.p4,Digits),8,"Arial",White);

 //     ObjectCreate("ma3.p4",OBJ_TEXT,0,t1.p4,ma3.p4);//34 ma
     if(Bid>ma3.p4) {ObjectSetText("ma3.p4",space+DoubleToStr(ma3.p4,Digits),8,"Arial",LightGreen);}
     if(Ask<ma3.p4) {ObjectSetText("ma3.p4",space+DoubleToStr(ma3.p4,Digits),8,"Arial",Pink);}
     if(Bid<=ma3.p4 && Ask>=ma3.p4)  {
        ObjectSetText("ma3.p4",space+DoubleToStr(ma3.p4,Digits),8,"Arial",Yellow);}

//      ObjectCreate("ma4.p4",OBJ_TEXT,0,t1.p4,ma4.p4);//55 ma
     if(Bid>ma4.p4) {ObjectSetText("ma4.p4",space+DoubleToStr(ma4.p4,Digits),8,"Arial",LightGreen);}
     if(Ask<ma4.p4) {ObjectSetText("ma4.p4",space+DoubleToStr(ma4.p4,Digits),8,"Arial",Pink);}
     if(Bid<=ma4.p4 && Ask>=ma4.p4)  {
        ObjectSetText("ma4.p4",space+DoubleToStr(ma4.p4,Digits),8,"Arial",Yellow);}

//      ObjectCreate("ma5.p4",OBJ_TEXT,0,t1.p4,ma5.p4);//89 ma
     if(Bid>ma5.p4) {ObjectSetText("ma5.p4",space+DoubleToStr(ma5.p4,Digits),8,"Arial",Green);}
     if(Ask<ma5.p4) {ObjectSetText("ma5.p4",space+DoubleToStr(ma5.p4,Digits),8,"Arial",Red);}
     if(Bid<=ma5.p4 && Ask>=ma5.p4)  {
        ObjectSetText("ma5.p4",space+DoubleToStr(ma5.p4,Digits),8,"Arial",Yellow);}

//      ObjectCreate("ma6.p4",OBJ_TEXT,0,t1.p4,NormalizeDouble(ma6.p4,Digits));//144 ma
     if(Bid>ma6.p4) {ObjectSetText("ma6.p4",space+DoubleToStr(ma6.p4,Digits),8,"Arial",Green);}
     if(Ask<ma6.p4) {ObjectSetText("ma6.p4",space+DoubleToStr(ma6.p4,Digits),8,"Arial",Red);}
     if(Bid<=ma6.p4 && Ask>=ma6.p4)  {
        ObjectSetText("ma6.p4",space+DoubleToStr(ma6.p4,Digits),8,"Arial",Yellow);}

//      ObjectCreate("ma7.p4",OBJ_TEXT,0,t1.p4,NormalizeDouble(ma7.p4,Digits));//233 ma
     if(Bid>ma7.p4) {ObjectSetText("ma7.p4",space+DoubleToStr(ma7.p4,Digits),8,"Arial",Green);}
     if(Ask<ma7.p4) {ObjectSetText("ma7.p4",space+DoubleToStr(ma7.p4,Digits),8,"Arial",Red);}
     if(Bid<=ma7.p4 && Ask>=ma7.p4)  {
        ObjectSetText("ma7.p4",space+DoubleToStr(ma7.p4,Digits),8,"Arial",Yellow);}
}//end p4.Fib.Plot()

void column()  {
//..................Time Frame Columns.................................................
//Addition - uses RSI of that timeframe to colour the lanes
//Dull red-green RSI are not with you
//brighter red-green RSI in your favour

// because RSI appears with the new bar I thing i can use Bar 0
// for faster notification.

     string column.down, column.up;
     column.down=Bid+" "; column.up=Ask+" ";

        //1st Column

       if(tmb1>rsiUpperTrigger)
        {
        ObjectCreate(column.up+p1.ma,OBJ_RECTANGLE,0,t1.p1,Ask,t2.p1,Ask*1.5);
        ObjectSet(column.up+p1.ma,OBJPROP_COLOR,LimeGreen);

        }
        else
              {
              ObjectCreate(column.up+p1.ma,OBJ_RECTANGLE,0,t1.p1,Ask,t2.p1,Ask*1.5);
              ObjectSet(column.up+p1.ma,OBJPROP_COLOR,Black);
              }

        if(tmr1<rsiLowerTrigger)
        {
        ObjectCreate(column.down+p1.ma,OBJ_RECTANGLE,0,t1.p1,Bid,t2.p1,0);
        ObjectSet(column.down+p1.ma,OBJPROP_COLOR,Red);

        }
        else
            {
            ObjectCreate(column.down+p1.ma,OBJ_RECTANGLE,0,t1.p1,Bid,t2.p1,0);
            ObjectSet(column.down+p1.ma,OBJPROP_COLOR,Black);
            }

        //2nd Column

       if(tmb2>rsiUpperTrigger)
       {
        ObjectCreate(column.up+p2.ma,OBJ_RECTANGLE,0,t1.p2,Ask,t2.p2,Ask*1.5);
        ObjectSet(column.up+p2.ma,OBJPROP_COLOR,LimeGreen);

        }
              else
              {
              ObjectCreate(column.up+p2.ma,OBJ_RECTANGLE,0,t1.p2,Ask,t2.p2,Ask*1.5);
              ObjectSet(column.up+p2.ma,OBJPROP_COLOR,Black);
              }

        if(tmr2<rsiLowerTrigger)
        {
        ObjectCreate(column.down+p2.ma,OBJ_RECTANGLE,0,t1.p2,0,t2.p2,Bid);
        ObjectSet(column.down+p2.ma,OBJPROP_COLOR,Red);

        }
              else
              {
              ObjectCreate(column.down+p2.ma,OBJ_RECTANGLE,0,t1.p2,0,t2.p2,Bid);
              ObjectSet(column.down+p2.ma,OBJPROP_COLOR,Black);
              }

        //3rd Column

        if(tmb3>rsiUpperTrigger)
        {
        ObjectCreate(column.up+p3.ma,OBJ_RECTANGLE,0,t1.p3,Ask,t2.p3,Ask*1.5);
        ObjectSet(column.up+p3.ma,OBJPROP_COLOR,LimeGreen);

        }
              else
              {
              ObjectCreate(column.up+p3.ma,OBJ_RECTANGLE,0,t1.p3,Ask,t2.p3,Ask*1.5);
              ObjectSet(column.up+p3.ma,OBJPROP_COLOR,Black);
              }

       if(tmr3<rsiLowerTrigger)
        {
         ObjectCreate(column.down+p3.ma,OBJ_RECTANGLE,0,t1.p3,Bid,t2.p3,0);
         ObjectSet(column.down+p3.ma,OBJPROP_COLOR,Red);

        }
              else
              {
              ObjectCreate(column.down+p3.ma,OBJ_RECTANGLE,0,t1.p3,Bid,t2.p3,0);
              ObjectSet(column.down+p3.ma,OBJPROP_COLOR,Black);
              }

        //4th column

        if(tmb4>rsiUpperTrigger)
        {
        ObjectCreate(column.up+p4.ma,OBJ_RECTANGLE,0,t1.p4,Ask,t2.p4,Ask*1.5);
        ObjectSet(column.up+p4.ma,OBJPROP_COLOR,LimeGreen);

        }
              else
              {
              ObjectCreate(column.up+p4.ma,OBJ_RECTANGLE,0,t1.p4,Ask,t2.p4,Ask*1.5);
              ObjectSet(column.up+p4.ma,OBJPROP_COLOR,Black);
              }

        if(tmr4<rsiLowerTrigger)
        {
        ObjectCreate(column.down+p4.ma,OBJ_RECTANGLE,0,t1.p4,Bid,t2.p4,0);
        ObjectSet(column.down+p4.ma,OBJPROP_COLOR,Red);

        }
              else
              {
              ObjectCreate(column.down+p4.ma,OBJ_RECTANGLE,0,t1.p4,Bid,t2.p4,0);
              ObjectSet(column.down+p4.ma,OBJPROP_COLOR,Black);
              }


       //5th Column

       if(tmb5>rsiUpperTrigger)
        {
        ObjectCreate(column.up+p5.ma,OBJ_RECTANGLE,0,t1.p5,Ask,t2.p5,Ask*1.5);
        ObjectSet(column.up+p5.ma,OBJPROP_COLOR,LimeGreen);

        }
        else
              {
              ObjectCreate(column.up+p5.ma,OBJ_RECTANGLE,0,t1.p5,Ask,t2.p5,Ask*1.5);
              ObjectSet(column.up+p5.ma,OBJPROP_COLOR,Black);
              }

        if(tmr1<rsiLowerTrigger)
        {
        ObjectCreate(column.down+p5.ma,OBJ_RECTANGLE,0,t1.p5,Bid,t2.p5,0);
        ObjectSet(column.down+p5.ma,OBJPROP_COLOR,Red);

        }
        else
            {
            ObjectCreate(column.down+p5.ma,OBJ_RECTANGLE,0,t1.p5,Bid,t2.p5,0);
            ObjectSet(column.down+p5.ma,OBJPROP_COLOR,Black);
            }

        //6th Column

       if(tmb6>rsiUpperTrigger)
       {
        ObjectCreate(column.up+p6.ma,OBJ_RECTANGLE,0,t1.p6,Ask,t2.p6,Ask*1.5);
        ObjectSet(column.up+p6.ma,OBJPROP_COLOR,LimeGreen);

        }
              else
              {
              ObjectCreate(column.up+p6.ma,OBJ_RECTANGLE,0,t1.p6,Ask,t2.p6,Ask*1.5);
              ObjectSet(column.up+p6.ma,OBJPROP_COLOR,Black);
              }

        if(tmr2<rsiLowerTrigger)
        {
        ObjectCreate(column.down+p6.ma,OBJ_RECTANGLE,0,t1.p6,0,t2.p6,Bid);
        ObjectSet(column.down+p6.ma,OBJPROP_COLOR,Red);

        }
              else
              {
              ObjectCreate(column.down+p6.ma,OBJ_RECTANGLE,0,t1.p6,0,t2.p6,Bid);
              ObjectSet(column.down+p6.ma,OBJPROP_COLOR,Black);
              }

        //7th Column

        if(tmb7>rsiUpperTrigger)
        {
        ObjectCreate(column.up+p7.ma,OBJ_RECTANGLE,0,t1.p7,Ask,t2.p7,Ask*1.5);
        ObjectSet(column.up+p7.ma,OBJPROP_COLOR,LimeGreen);

        }
              else
              {
              ObjectCreate(column.up+p7.ma,OBJ_RECTANGLE,0,t1.p7,Ask,t2.p7,Ask*1.5);
              ObjectSet(column.up+p7.ma,OBJPROP_COLOR,Black);
              }

       if(tmr3<rsiLowerTrigger)
        {
         ObjectCreate(column.down+p7.ma,OBJ_RECTANGLE,0,t1.p7,Bid,t2.p7,0);
         ObjectSet(column.down+p7.ma,OBJPROP_COLOR,Red);

        }
              else
              {
              ObjectCreate(column.down+p7.ma,OBJ_RECTANGLE,0,t1.p7,Bid,t2.p7,0);
              ObjectSet(column.down+p7.ma,OBJPROP_COLOR,Black);
              }

        //8th column

        if(tmb8>rsiUpperTrigger)
        {
        ObjectCreate(column.up+p8.ma,OBJ_RECTANGLE,0,t1.p8,Ask,t2.p8,Ask*1.5);
        ObjectSet(column.up+p8.ma,OBJPROP_COLOR,LimeGreen);

        }
              else
              {
              ObjectCreate(column.up+p8.ma,OBJ_RECTANGLE,0,t1.p8,Ask,t2.p8,Ask*1.5);
              ObjectSet(column.up+p8.ma,OBJPROP_COLOR,Black);
              }

        if(tmr4<rsiLowerTrigger)
        {
        ObjectCreate(column.down+p8.ma,OBJ_RECTANGLE,0,t1.p8,Bid,t2.p8,0);
        ObjectSet(column.down+p8.ma,OBJPROP_COLOR,Red);

        }
              else
              {
              ObjectCreate(column.down+p8.ma,OBJ_RECTANGLE,0,t1.p8,Bid,t2.p8,0);
              ObjectSet(column.down+p8.ma,OBJPROP_COLOR,Black);
              }

        //9th column

        if(tmb9>rsiUpperTrigger)
        {
        ObjectCreate(column.up+p9.ma,OBJ_RECTANGLE,0,t1.p9,Ask,t2.p9,Ask*1.5);
        ObjectSet(column.up+p9.ma,OBJPROP_COLOR,LimeGreen);

        }
              else
              {
              ObjectCreate(column.up+p9.ma,OBJ_RECTANGLE,0,t1.p9,Ask,t2.p9,Ask*1.5);
              ObjectSet(column.up+p9.ma,OBJPROP_COLOR,Black);
              }

        if(tmr4<rsiLowerTrigger)
        {
        ObjectCreate(column.down+p9.ma,OBJ_RECTANGLE,0,t1.p9,Bid,t2.p9,0);
        ObjectSet(column.down+p9.ma,OBJPROP_COLOR,Red);

        }
              else
              {
              ObjectCreate(column.down+p9.ma,OBJ_RECTANGLE,0,t1.p9,Bid,t2.p9,0);
              ObjectSet(column.down+p9.ma,OBJPROP_COLOR,Black);
              }

        }//end Columns



//---- done


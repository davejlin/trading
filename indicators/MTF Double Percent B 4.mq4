//+----------------------------------------------------------------------+
//|                                           MTF Double Percent B 4.mq4 |
//|                                                         David J. Lin |
//| MTF Double Percent B 4                                               |
//| written for Suresh Sundaram (sureshst_31@yahoo.com)                  |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|dave.j.lin@sbcglobal.net                                              |
//|Evanston, IL, November 26, 2007                                       |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2007 Suresh Sundaram & David J. Lin"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Aqua
#property indicator_color4 Magenta
//#property indicator_maximum 1
//#property indicator_minimum -1

//---- user adjustable parameters
extern double LevelHigh=0.80;
extern double LevelLow=0.20;

extern int TF1_BBPeriod=20;
extern int TF1_Shift=0;
extern int TF1_Price=PRICE_CLOSE;
extern double TF1_StdDeviation=2.0;

extern int TF2_BBPeriod=20;
extern int TF2_Shift=0;
extern int TF2_Price=PRICE_CLOSE;
extern double TF2_StdDeviation=2.0;

extern int TF3_BBPeriod=20;
extern int TF3_Shift=0;
extern int TF3_Price=PRICE_CLOSE;
extern double TF3_StdDeviation=2.0;

extern int TF4_BBPeriod=20;
extern int TF4_Shift=0;
extern int TF4_Price=PRICE_CLOSE;
extern double TF4_StdDeviation=2.0;

extern int TF1=PERIOD_H4;
extern int TF2=PERIOD_D1;
extern int TF3=PERIOD_W1;
extern int TF4=PERIOD_MN1;

extern int MaxBars=1000;  // (use negative number for all bars)

datetime ExpirationDate=D'2020.12.31'; // EA does not function after this date 
int AccNumber=-1;                      // EA functions only for this account number (set to negative number if this filter is not desired)
bool DemoOnly=false;                   // if set to true, EA functions only in demo accounts 

//---- buffers
double v0[],v1[],v2[],v3[];
//---- internal variables
int lookback,thistime,UseBars;
color clrL=Aqua,clrS=Magenta,clrRL=DarkOrange,clrRS=Yellow;
string strname="%B";
int window;
string windowname,ciBands="Bands";
double offset;
//----
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+  
int init()
{
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,v0);
 SetIndexLabel(0,"TF1");
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,v1);
 SetIndexLabel(1,"TF2");
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,v2);
 SetIndexLabel(2,"TF3");
 SetIndexStyle(3,DRAW_LINE);
 SetIndexBuffer(3,v3);
 SetIndexLabel(3,"TF4");

 SetLevelStyle(STYLE_DOT,1,Lime); 
// SetLevelStyle(STYLE_SOLID,1,Gray); 

 SetLevelValue(0,1.0); 
 SetLevelValue(1,LevelHigh);
 SetLevelValue(2,LevelLow);
 SetLevelValue(3,0.0); 

 windowname=StringConcatenate("Double %B (",TF1,",",TF2,")"); 
 IndicatorShortName(windowname); 
  
 lookback=MathMax(TF1,TF2)/Period();
 
 thistime=0; 
 
 if(MaxBars<0) UseBars=iBars(NULL,0)-2;
 else UseBars=MaxBars;
  
 return(0);
}
//+------------------------------------------------------------------+
int deinit()
{
 int objtotal=ObjectsTotal()-1; string name;int i,pos;

 for(i=objtotal;i>=0;i--) 
 {
  name=ObjectName(i);
  
  pos=StringFind(name,"%B");
  if(pos>=0) ObjectDelete(name);  
 }
}
//+------------------------------------------------------------------+
int start()
{
 if(noRun()) return(0);
// if(thistime==iTime(NULL,0,0)) return(0);
// thistime=iTime(NULL,0,0);
 window=WindowFind(windowname); 
 int i,imax,shift,time1,counted=IndicatorCounted();
 double a,b,close,bl,bh,v01,v11,v21,v31;
 string name;
 if(counted>0) imax=lookback;
 else imax=UseBars;
 
 for(i=imax;i>=1;i--)
 {   
  v0[i]=EMPTY_VALUE;
  v1[i]=EMPTY_VALUE;
  v2[i]=EMPTY_VALUE;
  v3[i]=EMPTY_VALUE;
   
  time1=iTime(NULL,0,i);
   
  shift=iBarShift(NULL,TF1,time1,false); 
  close=iClose(NULL,TF1,shift);

  bh=myBands(TF1,TF1_BBPeriod,TF1_Shift,TF1_Price,TF1_StdDeviation,1,shift);
  bl=myBands(TF1,TF1_BBPeriod,TF1_Shift,TF1_Price,TF1_StdDeviation,2,shift); 

  a=close-bl;
  b=1.0/(bh-bl);

  if(bl!=bh) v01=a*b;
  v01=NormalizeDouble(v01,4);

  shift=iBarShift(NULL,TF2,time1,false);  
  close=iClose(NULL,TF2,shift);

  bh=myBands(TF2,TF2_BBPeriod,TF2_Shift,TF2_Price,TF2_StdDeviation,1,shift);
  bl=myBands(TF2,TF2_BBPeriod,TF2_Shift,TF2_Price,TF2_StdDeviation,2,shift); 

  a=close-bl;
  b=1.0/(bh-bl);
 
  if(bl!=bh) v11=a*b;  
  v11=NormalizeDouble(v11,4);

  shift=iBarShift(NULL,TF3,time1,false);  
  close=iClose(NULL,TF3,shift);

  bh=myBands(TF3,TF3_BBPeriod,TF3_Shift,TF3_Price,TF3_StdDeviation,1,shift);
  bl=myBands(TF3,TF3_BBPeriod,TF3_Shift,TF3_Price,TF3_StdDeviation,2,shift); 

  a=close-bl;
  b=1.0/(bh-bl);
 
  if(bl!=bh) v21=a*b;  
  v21=NormalizeDouble(v21,4);
 
  shift=iBarShift(NULL,TF4,time1,false);  
  close=iClose(NULL,TF4,shift);

  bh=myBands(TF4,TF4_BBPeriod,TF4_Shift,TF4_Price,TF4_StdDeviation,1,shift);
  bl=myBands(TF4,TF4_BBPeriod,TF4_Shift,TF4_Price,TF4_StdDeviation,2,shift); 

  a=close-bl;
  b=1.0/(bh-bl);
 
  if(bl!=bh) v31=a*b;  
  v31=NormalizeDouble(v31,4);  
  
  v0[i]=v01;
  v1[i]=v11;
  v2[i]=v21;
  v3[i]=v31;  
 }
 return(0);
}
//+------------------------------------------------------------------+
double myBands(int tf,int period,int mashift,int price,double dev,int mode,int shift)
{
 int i,method=MODE_SMA;
 double sd=0.0, v1, bb, deviation;
 double ma=iMA(NULL,tf,period,mashift,method,price,shift);
 
 for(i=shift;i<=shift+period-1;i++)
 {
  v1=iClose(NULL,tf,i)-ma; 
  sd+=MathPow(v1,2);
 }
 sd/=period;
 deviation=MathSqrt(sd);
 deviation*=dev;
 
 switch(mode)
 {
  case 1: bb=ma+deviation; break;
  case 2: bb=ma-deviation; break;
 }
 bb=NormDigits(bb);
 return(bb);
}
//+------------------------------------------------------------------+
double NormDigits(double price)
{
 return(NormalizeDouble(price,Digits));
}
//+------------------------------------------------------------------+
bool noRun()
{
 if(TimeCurrent()>ExpirationDate) return(true);
 if(AccNumber>0 && AccountNumber()!=AccNumber) return(true);
 if(DemoOnly && !IsDemo()) return(true);
 
 return(false);
}
//+------------------------------------------------------------------+


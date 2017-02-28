//+----------------------------------------------------------------------+
//|                                             MTF Double Percent B.mq4 |
//|                                                         David J. Lin |
//| MTF Double Percent B                                                 |
//| written for Suresh Sundaram (sureshst_31@yahoo.com)                  |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|dave.j.lin@sbcglobal.net                                              |
//|Evanston, IL, September 10, 2007                                      |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2007 Suresh Sundaram & David J. Lin"

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Aqua
#property indicator_color4 Magenta
#property indicator_color5 DarkOrange
#property indicator_color6 Yellow
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

extern int TF1=PERIOD_H4;
extern int TF2=PERIOD_D1;

extern int MaxBars=1000;  // (use negative number for all bars)
extern int OffsetSymbol=5; // pips to offset the signal symbols in the main chart

datetime ExpirationDate=D'2020.12.31'; // EA does not function after this date 
int AccNumber=-1;                      // EA functions only for this account number (set to negative number if this filter is not desired)
bool DemoOnly=false;                   // if set to true, EA functions only in demo accounts 

//---- buffers
double v0[],v1[],v2[],v3[],v4[],v5[];
//---- internal variables
int lookback,thistime,UseBars;
color clrL=Aqua,clrS=Magenta,clrRL=DarkOrange,clrRS=Yellow;
string strname="%B";
int window,codeL=233,codeS=234,codeRL=217,codeRS=218;
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
 SetIndexStyle(2,DRAW_ARROW,codeL,2,clrL);
 SetIndexBuffer(2,v2);
 SetIndexLabel(2,"Long");
 SetIndexStyle(3,DRAW_ARROW,codeS,2,clrS);
 SetIndexBuffer(3,v3);
 SetIndexLabel(3,"Short"); 
 SetIndexStyle(4,DRAW_ARROW,codeRL,2,clrRL);
 SetIndexBuffer(4,v4);
 SetIndexLabel(4,"Reversal Long");
 SetIndexStyle(5,DRAW_ARROW,codeRS,2,clrRS);
 SetIndexBuffer(5,v5);
 SetIndexLabel(5,"Reversal Short"); 

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
 offset=OffsetSymbol*Point;
 
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
 int i,imax,shift,time1,time2,counted=IndicatorCounted();
 double a,b,close,bl,bh,v01,v02,v11,v12,time;
 string name;
 if(counted>0) imax=lookback;
 else imax=UseBars;
 
 for(i=imax;i>=1;i--)
 {   
  v0[i]=EMPTY_VALUE;
  v1[i]=EMPTY_VALUE;
  v2[i]=EMPTY_VALUE;
  v3[i]=EMPTY_VALUE;
  v4[i]=EMPTY_VALUE;
  v5[i]=EMPTY_VALUE;
   
  time1=iTime(NULL,0,i);
  time2=iTime(NULL,0,i+1);
   
  shift=iBarShift(NULL,TF1,time1,false); 
  close=iClose(NULL,TF1,shift);

//  bh=iCustom(NULL,TF1,ciBands,TF1_BBPeriod,TF1_Shift,TF1_StdDeviation,1,shift);
//  bl=iCustom(NULL,TF1,ciBands,TF1_BBPeriod,TF1_Shift,TF1_StdDeviation,2,shift);

  bh=myBands(TF1,TF1_BBPeriod,TF1_Shift,TF1_Price,TF1_StdDeviation,1,shift);
  bl=myBands(TF1,TF1_BBPeriod,TF1_Shift,TF1_Price,TF1_StdDeviation,2,shift); 

  a=close-bl;
  b=1.0/(bh-bl);

  if(bl!=bh) v01=a*b;
  v01=NormalizeDouble(v01,4);

  shift=iBarShift(NULL,TF1,time2,false);
  close=iClose(NULL,TF1,shift);

// bh=iCustom(NULL,TF1,ciBands,TF1_BBPeriod,TF1_Shift,TF1_StdDeviation,1,shift);
// bl=iCustom(NULL,TF1,ciBands,TF1_BBPeriod,TF1_Shift,TF1_StdDeviation,2,shift);

  bh=myBands(TF1,TF1_BBPeriod,TF1_Shift,TF1_Price,TF1_StdDeviation,1,shift);
  bl=myBands(TF1,TF1_BBPeriod,TF1_Shift,TF1_Price,TF1_StdDeviation,2,shift); 

  a=close-bl;
  b=1.0/(bh-bl);

  if(bl!=bh) v02=a*b;
  v02=NormalizeDouble(v02,4);

  shift=iBarShift(NULL,TF2,time1,false);  
  close=iClose(NULL,TF2,shift);

//  bh=iCustom(NULL,TF2,ciBands,TF2_BBPeriod,TF2_Shift,TF2_StdDeviation,1,shift);
//  bl=iCustom(NULL,TF2,ciBands,TF2_BBPeriod,TF2_Shift,TF2_StdDeviation,2,shift);

  bh=myBands(TF2,TF2_BBPeriod,TF2_Shift,TF2_Price,TF2_StdDeviation,1,shift);
  bl=myBands(TF2,TF2_BBPeriod,TF2_Shift,TF2_Price,TF2_StdDeviation,2,shift); 

  a=close-bl;
  b=1.0/(bh-bl);
 
  if(bl!=bh) v11=a*b;  
  v11=NormalizeDouble(v11,4);
  
  shift=iBarShift(NULL,TF2,time2,false); 
  close=iClose(NULL,TF2,shift);

//  bh=iCustom(NULL,TF2,ciBands,TF2_BBPeriod,TF2_Shift,TF2_StdDeviation,1,shift);
//  bl=iCustom(NULL,TF2,ciBands,TF2_BBPeriod,TF2_Shift,TF2_StdDeviation,2,shift);

  bh=myBands(TF2,TF2_BBPeriod,TF2_Shift,TF2_Price,TF2_StdDeviation,1,shift);
  bl=myBands(TF2,TF2_BBPeriod,TF2_Shift,TF2_Price,TF2_StdDeviation,2,shift); 

  a=close-bl;
  b=1.0/(bh-bl);
 
  if(bl!=bh) v12=a*b;  
  v12=NormalizeDouble(v12,4);

  v0[i]=v01;
  v1[i]=v11;
   
  time=iTime(NULL,0,i-1);
  name=StringConcatenate(strname,time);
  if(ObjectFind(name)>=0) ObjectDelete(name);  
  
  if(v01>LevelLow && (v12<LevelLow && v11>LevelLow)) 
  {
   v2[i]=LevelLow;
   DrawCross(iLow(NULL,0,i-1)-offset,time,strname,clrL,codeL);
  }
  if(v11>LevelLow && (v02<LevelLow && v01>LevelLow)) 
  {
   v2[i]=LevelLow;
   DrawCross(iLow(NULL,0,i-1)-offset,time,strname,clrL,codeL);
  }   
  if(v01<LevelHigh&& (v12>LevelHigh&& v11<LevelHigh))
  {
   v3[i]=LevelHigh;
   DrawCross(iHigh(NULL,0,i-1)+offset,time,strname,clrS,codeS);
  }
  if(v11<LevelHigh&& (v02>LevelHigh&& v01<LevelHigh))
  {
   v3[i]=LevelHigh;  
   DrawCross(iHigh(NULL,0,i-1)+offset,time,strname,clrS,codeS);
  }
  if(v01>LevelHigh&& (v12<LevelHigh&& v11>LevelHigh))
  {
   v4[i]=LevelHigh;
   DrawCross(iLow(NULL,0,i-1)-offset,time,strname,clrRL,codeRL);
  }
  if(v11>LevelHigh&& (v02<LevelHigh&& v01>LevelHigh))
  {
   v4[i]=LevelHigh;
   DrawCross(iLow(NULL,0,i-1)-offset,time,strname,clrRL,codeRL);
  }
  if(v01<LevelLow && (v12>LevelLow && v11<LevelLow)) 
  {
   v5[i]=LevelLow;
   DrawCross(iHigh(NULL,0,i-1)+offset,time,strname,clrRS,codeRS);
  }
  if(v11<LevelLow && (v02>LevelLow && v01<LevelLow)) 
  {
   v5[i]=LevelLow;
   DrawCross(iHigh(NULL,0,i-1)+offset,time,strname,clrRS,codeRS);
  }
 }
 return(0);
}
//+------------------------------------------------------------------+
void DrawCross(double price, int time1, string str, color clr, int code)
{
 string name=StringConcatenate(str,time1,window);
 ObjectDelete(name);  
 ObjectCreate(name,OBJ_ARROW,0,time1,price);
 ObjectSet(name,OBJPROP_COLOR,clr);
 ObjectSet(name,OBJPROP_ARROWCODE,code); 
 ObjectSet(name,OBJPROP_WIDTH,1);
 return;
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


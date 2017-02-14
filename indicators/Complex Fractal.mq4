//+----------------------------------------------------------------------+
//|                                               VT Complex Fractal.mq4 |
//|                                                         David J. Lin |
//| VT Complex Fractal                                                   |
//| written for John Stathers <stathersj@hotmail.com>                    |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|dave.j.lin@sbcglobal.net                                              |
//|Evanston, IL, November 27, 2007                                       |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2007 John Stathers & David J. Lin"

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Red
#property indicator_color5 Blue
#property indicator_color6 Red
//#property indicator_maximum 1
//#property indicator_minimum -1

//---- user adjustable parameters
extern int MAperiod1=8;
extern int MAperiod2=13;
extern int MAshift1=5;
extern int MAshift2=8;
extern int MAmethod1=MODE_SMMA;
extern int MAmethod2=MODE_SMMA;
extern int MAprice1=PRICE_MEDIAN;
extern int MAprice2=PRICE_MEDIAN;
extern int MACDfast=5;
extern int MACDslow=34;
extern int MACDsignal=8;
extern int MACDprice=PRICE_MEDIAN;
extern int RSIperiod=13; 
extern int RSIprice=PRICE_MEDIAN;
//---- buffers
double MA1[],MA2[],FUp[],FDn[],AUp[],ADn[];
//---- internal variables
datetime thistime;
color clrL=Blue, clrS=Red;
int   codeL=233,codeS=234;
int offset=5;
bool Flag=true;
//----
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+  
int init()
{
 SetIndexStyle(0,DRAW_ARROW,codeL,2,clrL);
 SetIndexArrow(0,codeL);
 SetIndexBuffer(0,AUp);
 SetIndexLabel(0,"Up");
 SetIndexStyle(1,DRAW_ARROW,codeS,2,clrS);
 SetIndexArrow(1,codeS);
 SetIndexBuffer(1,ADn);
 SetIndexLabel(1,"Down");
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,MA1);
 SetIndexLabel(2,"MA1");
 SetIndexStyle(3,DRAW_LINE);
 SetIndexBuffer(3,MA2);
 SetIndexLabel(3,"MA2");
 SetIndexStyle(4,DRAW_LINE);
 SetIndexBuffer(4,FUp);
 SetIndexLabel(4,"FUp");
 SetIndexStyle(5,DRAW_LINE);
 SetIndexBuffer(5,FDn);
 SetIndexLabel(5,"FDn"); 
 return(0);
}
//+------------------------------------------------------------------+
int deinit()
{
 return(0);
}
//+------------------------------------------------------------------+
int start()
{
 if(thistime==iTime(NULL,0,0)) return(0);
 thistime=iTime(NULL,0,0);
 
 int i,imax,counted=IndicatorCounted();
 double val,macdf,macds,rsi; string name;
 datetime time;
 if(counted>0) imax=3;
 else imax=Bars-1;

 for(i=imax;i>=1;i--)
 {   
// Fractal Channel 
  val=iFractals(NULL,0,MODE_UPPER,i);
  if(val>0) FUp[i]=High[i]; 
  else      FUp[i]=FUp[i+1]; 
  
  val=iFractals(NULL,0,MODE_LOWER,i);
  if(val>0) FDn[i]=Low[i];
  else      FDn[i]=FDn[i+1];
 }

 if(counted>0) imax=1;
 else imax=Bars-1; 
 
 for(i=imax;i>=1;i--)
 {   
// MAs
  MA1[i]=iMA(NULL,0,MAperiod1,MAshift1,MAmethod1,MAprice1,i);
  MA2[i]=iMA(NULL,0,MAperiod2,MAshift2,MAmethod2,MAprice2,i);
// MACD
  macdf=iMACD(NULL,0,MACDfast,MACDslow,MACDsignal,MACDprice,MODE_MAIN,i);
  macds=iMACD(NULL,0,MACDfast,MACDslow,MACDsignal,MACDprice,MODE_SIGNAL,i);
// RSI
  rsi=iRSI(NULL,0,RSIperiod,RSIprice,i);
 
  if(MA1[i]>MA2[i] && macdf>macds && rsi>50. && !Flag) 
  {
   AUp[i]=NormDigits(iLow(NULL,0,i)-NormPoints(offset));
   Flag=true;
  }

  if(MA1[i]<MA2[i] && macdf<macds && rsi<50. && Flag) 
  {
   ADn[i]=NormDigits(iHigh(NULL,0,i)+NormPoints(offset));
   Flag=false;
  }   
    
 }
 return(0);
}
//+------------------------------------------------------------------+
double NormDigits(double price)
{
 return(NormalizeDouble(price,Digits));
}
//+------------------------------------------------------------------+
double NormPoints(double price)
{
 return(NormDigits(price*Point));
}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                       MA_ATR.mq4 |
//|                                                 December 22, 2008|
//| 2 MA + ATR system based on Art Collins' article in Futures Dec 08|
//|                                                                  |
//| dave.j.lin@sbcglobal.net                                         |
//| coded by David J. Lin                                                                 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, David J. Lin"
#property link      "http://www.systemselectgroup.com/"

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Lime
#property indicator_color4 Magenta

//---- indicator parameters
extern int MA_Period1=8;
extern int MA_Period2=50;
extern int ATR_Period=3;
extern double EntryFraction=0.25;
extern double ExitFraction=0.50;

int MA_Shift=0;
int MA_Method=0;
int MA_Price=PRICE_CLOSE;
//---- indicator buffers
double ExtMapBuffer1[],ExtMapBuffer2[];
double ExtMapBuffer3[],ExtMapBuffer4[];
string stringEntry="Entry ",stringExit="Exit ";
color colorEntry=Lime,colorExit=Magenta;
//----
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
 int    draw_begin1,draw_begin2;
 string short_name;
//---- drawing settings
 SetIndexStyle(0,DRAW_LINE);
 SetIndexShift(0,MA_Shift);
 IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
 if(MA_Period1<1) MA_Period1=1;
 if(MA_Period2<1) MA_Period2=1; 
 draw_begin1=MA_Period1-1;
 draw_begin2=MA_Period2-1; 
//---- indicator short name
 short_name="MA_ATR ";
 IndicatorShortName(short_name+MA_Period1+" "+MA_Period2);
 SetIndexDrawBegin(0,draw_begin1);
 SetIndexBuffer(0,ExtMapBuffer1);
 SetIndexDrawBegin(1,draw_begin2);
 SetIndexBuffer(1,ExtMapBuffer2); 

 SetIndexBuffer(2,ExtMapBuffer3);
 SetIndexStyle(2,DRAW_ARROW,EMPTY,2);
 SetIndexArrow(2,159);   

 SetIndexBuffer(3,ExtMapBuffer4);
 SetIndexStyle(3,DRAW_ARROW,EMPTY,2);
 SetIndexArrow(3,159);   
//---- initialization done
 return(0);
}
//+------------------------------------------------------------------+
int deinit()
{
 return(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
{
 if(Bars<=MA_Period1 || Bars<=MA_Period2) return(0);
 int i,limit,counted=IndicatorCounted();
 double atr,open,close,ma1,ma2,price;

//---- check for possible errors
 if (counted<0) return(-1);
//---- last counted bar will be recounted
 if (counted>0) counted--;
//----
 limit=Bars-counted;
//---- macd
 for(i=limit; i>=0; i--)
 {
  ma1=iMA(NULL,0,MA_Period1,MA_Shift,MA_Method,MA_Price,i);
  ma2=iMA(NULL,0,MA_Period2,MA_Shift,MA_Method,MA_Price,i); 

  ExtMapBuffer1[i]=ma1;
  ExtMapBuffer2[i]=ma2;   

  ma1=iMA(NULL,0,MA_Period1,MA_Shift,MA_Method,MA_Price,i+1);
  ma2=iMA(NULL,0,MA_Period2,MA_Shift,MA_Method,MA_Price,i+1); 
  
  close=iClose(NULL,0,i+1);
  
  if(close<ma1 && close>ma2)
  {
   open=iOpen(NULL,0,i);
   atr=NormDigits(EntryFraction*iATR(NULL,0,ATR_Period,i+1)); 
   price=NormDigits(open+atr);

   ExtMapBuffer3[i]=price;
  }
  else if(close>ma1 && close<ma2)
  {
   open=iOpen(NULL,0,i);
   atr=NormDigits(EntryFraction*iATR(NULL,0,ATR_Period,i+1)); 
   price=NormDigits(open-atr);

   ExtMapBuffer3[i]=price; 
  }
  else if(close>ma1 && close>ma2)
  {
   open=iOpen(NULL,0,i);  
   atr=NormDigits(ExitFraction*iATR(NULL,0,ATR_Period,i+1));   
   price=NormDigits(open-atr);

   ExtMapBuffer4[i]=price;   
  } 
  else if(close<ma1 && close<ma2)
  {
   open=iOpen(NULL,0,i);
   atr=NormDigits(ExitFraction*iATR(NULL,0,ATR_Period,i+1));   
   price=NormDigits(open+atr);

   ExtMapBuffer4[i]=price;   
  }  
 } 
//---- done
 return(0);
}
//+------------------------------------------------------------------+
double NormDigits(double value)
{
 return(NormalizeDouble(value,Digits));
}



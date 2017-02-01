//+----------------------------------------------------------------------+
//|                          Stochastic Channel Index Method - STOCH.mq4 |
//|                                                         David J. Lin |
//| Stochastic Channel Index Method - STOCH                              |
//|                                                                      |
//| Coded for Sérgio Spilari Filho <sergio@ssfconsultoriafinanceira.com> |
//| Coded by David J. Lin (dave.j.lin@gmail.com)                         |
//| Evanston, IL, May 26, 2013                                           |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2013,  Sérgio Spilari Filho and David J. Lin"

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 2
#property indicator_color1 LightSeaGreen
#property indicator_color2 Red
//---- input parameters
extern int KPeriod=5;
extern int DPeriod=3;
extern int Slowing=3;

//-- Index parameters

extern int    ShortTermMAperiod = 20;
extern int    ShortTermMAmethod = MODE_SMA;
extern int    LongTermMAperiod  = 40;
extern int    LongTermMAmethod  = MODE_SMA;

extern string IndexCustomIndicator="Utilities SCI Data Euro";

int modeHigh=0;
int modeLow=1;
int modeClose=3;
//---- buffers
double MainBuffer[];
double SignalBuffer[];
double HighesBuffer[];
double LowesBuffer[];
//----
int draw_begin1=0;
int draw_begin2=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- 2 additional buffers are used for counting.
   IndicatorBuffers(4);
   SetIndexBuffer(2, HighesBuffer);
   SetIndexBuffer(3, LowesBuffer);
//---- indicator lines
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0, MainBuffer);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1, SignalBuffer);
//---- name for DataWindow and indicator subwindow label
   short_name="SCI Sto("+KPeriod+","+DPeriod+","+Slowing+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
   SetIndexLabel(1,"Signal");
//----
   draw_begin1=KPeriod+Slowing;
   draw_begin2=draw_begin1+DPeriod;
   SetIndexDrawBegin(0,draw_begin1);
   SetIndexDrawBegin(1,draw_begin2);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Stochastic oscillator                                            |
//+------------------------------------------------------------------+
int start()
  {
   int    i,k;
   int    counted_bars=IndicatorCounted();
   double price;
//----
   if(Bars<=draw_begin2) return(0);
//---- initial zero
   if(counted_bars<1)
     {
      for(i=1;i<=draw_begin1;i++) MainBuffer[Bars-i]=0;
      for(i=1;i<=draw_begin2;i++) SignalBuffer[Bars-i]=0;
     }
//---- minimums counting
   i=Bars-KPeriod;
   if(counted_bars>KPeriod) i=Bars-counted_bars-1;
   while(i>=0)
     {
      double min=1000000;
      k=i+KPeriod-1;
      while(k>=i)
        {
         price=iCustom(NULL,0,IndexCustomIndicator,ShortTermMAperiod,ShortTermMAmethod,LongTermMAperiod,LongTermMAmethod,modeLow,k);
         if(min>price) min=price;
         k--;
        }
      LowesBuffer[i]=min;
      i--;
     }
//---- maximums counting
   i=Bars-KPeriod;
   if(counted_bars>KPeriod) i=Bars-counted_bars-1;
   while(i>=0)
     {
      double max=-1000000;
      k=i+KPeriod-1;
      while(k>=i)
        {
         price=iCustom(NULL,0,IndexCustomIndicator,ShortTermMAperiod,ShortTermMAmethod,LongTermMAperiod,LongTermMAmethod,modeHigh,k);
         if(max<price) max=price;
         k--;
        }
      HighesBuffer[i]=max;
      i--;
     }
//---- %K line
   i=Bars-draw_begin1;
   if(counted_bars>draw_begin1) i=Bars-counted_bars-1;
   while(i>=0)
     {
      double sumlow=0.0;
      double sumhigh=0.0;
      for(k=(i+Slowing-1);k>=i;k--)
        {
         sumlow+=iCustom(NULL,0,IndexCustomIndicator,ShortTermMAperiod,ShortTermMAmethod,LongTermMAperiod,LongTermMAmethod,modeClose,k)-LowesBuffer[k];
         sumhigh+=HighesBuffer[k]-LowesBuffer[k];
        }
      if(sumhigh==0.0) MainBuffer[i]=100.0;
      else MainBuffer[i]=sumlow/sumhigh*100;
      i--;
     }
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
//---- signal line is simple movimg average
   for(i=0; i<limit; i++)
      SignalBuffer[i]=iMAOnArray(MainBuffer,Bars,DPeriod,0,MODE_SMA,i);
//----
   return(0);
  }
//+------------------------------------------------------------------+
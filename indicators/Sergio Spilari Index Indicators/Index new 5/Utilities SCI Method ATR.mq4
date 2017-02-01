//+----------------------------------------------------------------------+
//|                            Stochastic Channel Index Method - ATR.mq4 |
//|                                                         David J. Lin |
//| Stochastic Channel Index Method - ATR                                |
//|                                                                      |
//| Coded for Sérgio Spilari Filho <sergio@ssfconsultoriafinanceira.com> |
//| Coded by David J. Lin (dave.j.lin@gmail.com)                         |
//| Evanston, IL, May 26, 2013                                           |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2013,  Sérgio Spilari Filho and David J. Lin"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 DodgerBlue
//---- input parameters
extern int AtrPeriod=14;

//-- Index parameters
extern int atrTimeFrame=PERIOD_D1;

extern int    ShortTermMAperiod = 20;
extern int    ShortTermMAmethod = MODE_SMA;
extern int    LongTermMAperiod  = 40;
extern int    LongTermMAmethod  = MODE_SMA;

extern string IndexCustomIndicator="Utilities SCI Data Euro";

int modeHigh=0;
int modeLow=1;
int modeClose=3;
//---- buffers
double AtrBuffer[];
double TempBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- 1 additional buffer used for counting.
   IndicatorBuffers(2);
//---- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,AtrBuffer);
   SetIndexBuffer(1,TempBuffer);
//---- name for DataWindow and indicator subwindow label
   short_name="SCI ATR("+AtrPeriod+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
//----
   SetIndexDrawBegin(0,AtrPeriod);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Average True Range                                               |
//+------------------------------------------------------------------+
int start()
  {
   int i,counted_bars=IndicatorCounted();
//----
   if(Bars<=AtrPeriod) return(0);
//---- initial zero
   if(counted_bars<1)
      for(i=1;i<=AtrPeriod;i++) AtrBuffer[Bars-i]=0.0;
//----
   i=Bars-counted_bars-1;
   while(i>=0)
     {
      double high=iCustom(NULL,atrTimeFrame,IndexCustomIndicator,ShortTermMAperiod,ShortTermMAmethod,LongTermMAperiod,LongTermMAmethod,modeHigh,i);

      double low =iCustom(NULL,atrTimeFrame,IndexCustomIndicator,ShortTermMAperiod,ShortTermMAmethod,LongTermMAperiod,LongTermMAmethod,modeLow,i);
      if(i==Bars-1) TempBuffer[i]=high-low;
      else
        {
         double prevclose=iCustom(NULL,atrTimeFrame,IndexCustomIndicator,ShortTermMAperiod,ShortTermMAmethod,LongTermMAperiod,LongTermMAmethod,modeClose,i+1);
         TempBuffer[i]=MathMax(high,prevclose)-MathMin(low,prevclose);
        }
                            
      i--;
     }
//----
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   for(i=0; i<limit; i++)
      AtrBuffer[i]=iMAOnArray(TempBuffer,0,AtrPeriod,0,MODE_SMA,i);
//----
   return(0);
  }
//+------------------------------------------------------------------+
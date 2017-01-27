//+------------------------------------------------------------------+
//|                                                          ATR.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 DodgerBlue
//---- input parameters
extern int AtrPeriod=14;

//-- Index parameters
extern string IndexCustomIndicator="Index - Euro 2";
extern int atrTimeFrame=PERIOD_D1;

extern string SymbolsPrefix     = "";
extern string SymbolsSuffix     = "";
extern int    ShortTermMAperiod = 20;
extern int    ShortTermMAmethod = MODE_SMA;
extern int    LongTermMAperiod  = 40;
extern int    LongTermMAmethod  = MODE_SMA;

bool   ShowLineValue    = false;
bool   ShowBars         = false;
bool   ShowCrossingDots = false;
string Identifier       = "index";
color  colorBarDown     = Red;
color  colorBarUp       = Green;
color  colorBarNeutral  = DimGray;
color  colorWickUp      = Blue;
color  colorWickDown    = Red;
color  colorWickNeutral = DimGray;
int    widthWick        = 1;
int    widthBody        = 3;

bool   alertsOn         = false;
bool   alertsOnCurrent  = false;
bool   alertsMessage    = false;
bool   alertsSound      = false;
bool   alertsEmail      = false;

int modeClose=0;
int modeHigh=5;
int modeLow=6;
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
   short_name="Stochastic Channel Index ATR("+AtrPeriod+")";
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
      double high=iCustom(NULL,atrTimeFrame,IndexCustomIndicator,SymbolsPrefix,SymbolsSuffix,ShortTermMAperiod,ShortTermMAmethod,LongTermMAperiod,LongTermMAmethod,ShowLineValue,ShowBars,ShowCrossingDots,Identifier,colorBarDown,colorBarUp,colorBarNeutral,colorWickUp,colorWickDown,colorWickNeutral,widthWick,widthBody,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,modeHigh,i);

      double low =iCustom(NULL,atrTimeFrame,IndexCustomIndicator,SymbolsPrefix,SymbolsSuffix,ShortTermMAperiod,ShortTermMAmethod,LongTermMAperiod,LongTermMAmethod,ShowLineValue,ShowBars,ShowCrossingDots,Identifier,colorBarDown,colorBarUp,colorBarNeutral,colorWickUp,colorWickDown,colorWickNeutral,widthWick,widthBody,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,modeLow,i);
      if(i==Bars-1) TempBuffer[i]=high-low;
      else
        {
         double prevclose=iCustom(NULL,atrTimeFrame,IndexCustomIndicator,SymbolsPrefix,SymbolsSuffix,ShortTermMAperiod,ShortTermMAmethod,LongTermMAperiod,LongTermMAmethod,ShowLineValue,ShowBars,ShowCrossingDots,Identifier,colorBarDown,colorBarUp,colorBarNeutral,colorWickUp,colorWickDown,colorWickNeutral,widthWick,widthBody,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,modeClose,i+1);
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
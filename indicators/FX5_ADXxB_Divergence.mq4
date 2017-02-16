//+------------------------------------------------------------------+
//|                                         FX5_ADXxB_Divergence.mq4 |
//|                                                              FX5 |
//|                                                    hazem@uk2.net |
//|Adapted by David J. Lin to Waddah_Attar_ADXxBollinger             |
//|dave.j.lin@sbcglobal.net                                          |
//|Evanston, IL, November 4, 2007                                    |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, FX5"
#property link      "hazem@uk2.net"
//----
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Magenta
#property indicator_minimum 0
//---- input parameters
extern string    separator1 = "*** ADXxBollinger Settings ***";
extern int       ADXPeriod = 13;
extern int       BandsPeriod=20;
extern double    SignalLimit=0.8500; // above which to show divergence signals (auto adjusted x 100 for JPY pairs)
extern string    separator2 = "*** Indicator Settings ***";
extern bool      drawDivergenceLines = true;
extern bool      displayAlert = true;
//---- buffers
double ADXxB[];
double ExtBuffer1[];
double ExtBuffer2[];
double bullishDivergence[];
double bearishDivergence[];
//----
static datetime lastAlertTime;
string indicatorname;
double signallimit;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexBuffer(0, ExtBuffer1);
   SetIndexStyle(0, DRAW_HISTOGRAM, 0, 2);
   SetIndexBuffer(1, ExtBuffer2);
   SetIndexStyle(1, DRAW_HISTOGRAM, 0, 2);
   SetIndexBuffer(4, ADXxB);
   SetIndexStyle(4, DRAW_NONE);   
//----   
   SetIndexBuffer(2, bullishDivergence);
   SetIndexBuffer(3, bearishDivergence);
   SetIndexStyle(2, DRAW_ARROW);
   SetIndexStyle(3, DRAW_ARROW);
//----   
   SetIndexArrow(2, 233);
   SetIndexArrow(3, 234);
//----
   IndicatorDigits(Digits + 2);
   indicatorname=StringConcatenate("FX5_ADXxB_Divergence(",ADXPeriod,",",BandsPeriod,")");
   IndicatorShortName(indicatorname);
   
   if(StringFind(Symbol(),"JPY",0)>0) signallimit=100.*SignalLimit;
   else signallimit=SignalLimit;
   
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   for(int i = ObjectsTotal() - 1; i >= 0; i--)
     {
       string label = ObjectName(i);
       if(StringFind(label,"ADXxBDivergenceLine",0)<0)
           continue;
       ObjectDelete(label);   
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int countedBars = IndicatorCounted();
   if(countedBars < 0)
       countedBars = 0;
   CalculateIndicator(countedBars);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateIndicator(int countedBars)
  {
   for(int i = Bars - countedBars; i >= 0; i--)
     {
      CalculateADXxB(i);
      CatchBullishDivergence(i + 2);
      CatchBearishDivergence(i + 2);
     }              
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateADXxB(int i)
  {
   double adxbU = iCustom(NULL,0,"Waddah_Attar_ADXxBollinger",ADXPeriod,BandsPeriod,0,i);
   double adxbD = iCustom(NULL,0,"Waddah_Attar_ADXxBollinger",ADXPeriod,BandsPeriod,1,i);   
   if(adxbU!=0) 
   {
    ADXxB[i]=adxbU;
    ExtBuffer1[i]=adxbU;
   }
   else 
   {
    ADXxB[i]=adxbD;
    ExtBuffer2[i]=adxbD;
   }
//----
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CatchBullishDivergence(int shift)
  {
   color clr;
   if(IsIndicatorTrough(shift) == false)
       return;
   int currentTrough = shift;
   int lastTrough = GetIndicatorLastTrough(shift);
   
   if(ADXxB[currentTrough]<=signallimit) return;

   if(ADXxB[currentTrough] > ADXxB[lastTrough] && Low[currentTrough] < Low[lastTrough])
     {
      if(ExtBuffer1[currentTrough]!=EMPTY_VALUE) // green bars:  normal signal
      {
       bullishDivergence[currentTrough] = ADXxB[currentTrough];
       clr=Green;
      }
      else // red bars: opposite signal  
      {                          
       bearishDivergence[currentTrough] = ADXxB[currentTrough];
       clr=Red;
      }
      if(drawDivergenceLines == true)
        {
          DrawPriceTrendLine(Time[currentTrough], Time[lastTrough], Low[currentTrough], 
                             Low[lastTrough], clr, STYLE_SOLID);
          DrawIndicatorTrendLine(Time[currentTrough], Time[lastTrough], ADXxB[currentTrough],
                                 ADXxB[lastTrough], clr, STYLE_SOLID);
        }
      if(displayAlert == true)
          DisplayAlert("Classical bullish ADXxB divergence on: ", currentTrough);  
     }
   if(ADXxB[currentTrough] < ADXxB[lastTrough] && Low[currentTrough] > Low[lastTrough])
     {
      if(ExtBuffer1[currentTrough]!=EMPTY_VALUE) // green bars:  normal signal
      {
       bullishDivergence[currentTrough] = ADXxB[currentTrough];
       clr=Green;
      }
      else // red bars: opposite signal
      {                           
       bearishDivergence[currentTrough] = ADXxB[currentTrough];
       clr=Red;
      }
      if(drawDivergenceLines == true)
        {
          DrawPriceTrendLine(Time[currentTrough], Time[lastTrough], Low[currentTrough], 
                             Low[lastTrough], clr, STYLE_DOT);
          DrawIndicatorTrendLine(Time[currentTrough], Time[lastTrough], ADXxB[currentTrough],
                                 ADXxB[lastTrough], clr, STYLE_DOT);
        }
      if(displayAlert == true)
          DisplayAlert("Reverse bullish ADXxB divergence on: ", currentTrough);   
     }      
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CatchBearishDivergence(int shift)
  {
   color clr;
   if(IsIndicatorPeak(shift) == false)
       return;
   int currentPeak = shift;
   int lastPeak = GetIndicatorLastPeak(shift);
   
   if(ADXxB[currentPeak]<=signallimit) return;

   if(ADXxB[currentPeak] < ADXxB[lastPeak] && High[currentPeak] > High[lastPeak])
     {
      if(ExtBuffer1[currentPeak]!=EMPTY_VALUE) // green bars:  normal signal
      {     
       bearishDivergence[currentPeak] = ADXxB[currentPeak];
       clr=Red;
      }
      else // red bars: opposite signal
      {
       bullishDivergence[currentPeak] = ADXxB[currentPeak];
       clr=Blue;
      }
       if(drawDivergenceLines == true)
         {
           DrawPriceTrendLine(Time[currentPeak], Time[lastPeak], High[currentPeak], 
                              High[lastPeak], clr, STYLE_SOLID);
           DrawIndicatorTrendLine(Time[currentPeak], Time[lastPeak], ADXxB[currentPeak],
                                  ADXxB[lastPeak], clr, STYLE_SOLID);
         }
       if(displayAlert == true)
           DisplayAlert("Classical bearish ADXxB divergence on: ", currentPeak);  
     }
   if(ADXxB[currentPeak] > ADXxB[lastPeak] && High[currentPeak] < High[lastPeak])
     {
      if(ExtBuffer1[currentPeak]!=EMPTY_VALUE) // green bars:  normal signal
      {     
       bearishDivergence[currentPeak] = ADXxB[currentPeak];
       clr=Red;
      }
      else // red bars: opposite signal
      {
       bullishDivergence[currentPeak] = ADXxB[currentPeak];
       clr=Blue;
      }
       if(drawDivergenceLines == true)
         {
           DrawPriceTrendLine(Time[currentPeak], Time[lastPeak], High[currentPeak], 
                              High[lastPeak], clr, STYLE_DOT);
           DrawIndicatorTrendLine(Time[currentPeak], Time[lastPeak], ADXxB[currentPeak],
                                  ADXxB[lastPeak], clr, STYLE_DOT);
         }
       if(displayAlert == true)
           DisplayAlert("Reverse bearish ADXxB divergence on: ", currentPeak);   
     }   
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsIndicatorPeak(int shift)
  {
   if(ADXxB[shift] > ADXxB[shift+1] && ADXxB[shift] > ADXxB[shift-1])
     {
      return(true);
     }   
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsIndicatorTrough(int shift)
  {
   if(ADXxB[shift] < ADXxB[shift+1] && ADXxB[shift] < ADXxB[shift-1])
     {
      return(true);
     }   
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetIndicatorLastPeak(int shift)
  {
    for(int i = shift + 5; i < Bars; i++)
      {
        if(ADXxB[i] >= ADXxB[i+1] && ADXxB[i] > ADXxB[i+2] &&
           ADXxB[i] >= ADXxB[i-1] && ADXxB[i] > ADXxB[i-2])
            return(i);
      }
    return(-1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetIndicatorLastTrough(int shift)
  {  
    for(int i = shift + 5; i < Bars; i++)
      {
        if(ADXxB[i] <= ADXxB[i+1] && ADXxB[i] < ADXxB[i+2] &&
           ADXxB[i] <= ADXxB[i-1] && ADXxB[i] < ADXxB[i-2])
            return(i);
      }
    return(-1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DisplayAlert(string message, int shift)
  {
   if(shift <= 2 && Time[shift] != lastAlertTime)
     {
       lastAlertTime = Time[shift];
       Alert(message, Symbol(), " , ", Period(), " minutes chart");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawPriceTrendLine(datetime x1, datetime x2, double y1, 
                        double y2, color lineColor, double style)
  {
   string label = "ADXxBDivergenceLine# " + DoubleToStr(x1, 0);
   ObjectDelete(label);
   ObjectCreate(label, OBJ_TREND, 0, x1, y1, x2, y2, 0, 0);
   ObjectSet(label, OBJPROP_RAY, 0);
   ObjectSet(label, OBJPROP_COLOR, lineColor);
   ObjectSet(label, OBJPROP_STYLE, style);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawIndicatorTrendLine(datetime x1, datetime x2, double y1, 
                            double y2, color lineColor, double style)
  {
   int indicatorWindow = WindowFind(indicatorname);
   if(indicatorWindow < 0)
       return;
   string label = "ADXxBDivergenceLine$# " + DoubleToStr(x1, 0);
   ObjectDelete(label);
   ObjectCreate(label, OBJ_TREND, indicatorWindow, x1, y1, x2, y2, 0, 0);
   ObjectSet(label, OBJPROP_RAY, 0);
   ObjectSet(label, OBJPROP_COLOR, lineColor);
   ObjectSet(label, OBJPROP_STYLE, style);
  }
//+------------------------------------------------------------------+




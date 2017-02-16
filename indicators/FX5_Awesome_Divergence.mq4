//+------------------------------------------------------------------+
//|                                       FX5_Awesome_Divergence.mq4 |
//|                                                              FX5 |
//|                                                    hazem@uk2.net |
//|Adapted by David J. Lin to Awesome                                |
//|dave.j.lin@sbcglobal.net                                          |
//|Evanston, IL, March 15, 2008                                      |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, FX5"
#property link      "hazem@uk2.net"
//----
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 DodgerBlue
#property indicator_color2 Green
#property indicator_color3 Red
//---- input parameters
extern string    separator1 = "*** RSI Settings ***";
extern string    intro="Awesome Diververgence needs no parameters";
extern string    separator2 = "*** Indicator Settings ***";
extern bool      drawDivergenceLines = true;
extern bool      displayAlert = true;
//---- buffers
double AOBuffer[];
double bullishDivergence[];
double bearishDivergence[];
//----
static datetime lastAlertTime;
string indicatorname;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0, DRAW_LINE);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexStyle(2, DRAW_ARROW);
//----   
   SetIndexBuffer(0, AOBuffer);
   SetIndexBuffer(1, bullishDivergence);
   SetIndexBuffer(2, bearishDivergence);
//----   
   SetIndexArrow(1, 233);
   SetIndexArrow(2, 234);
//----
   IndicatorDigits(Digits + 2);
   indicatorname="FX5_Awesome_Divergence";
   IndicatorShortName(indicatorname);
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
       if(StringFind(label,"AODivergenceLine",0)<0)
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
      CalculateAO(i);
      CatchBullishDivergence(i + 2);
      CatchBearishDivergence(i + 2);
     }              
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateAO(int i)
  {
   AOBuffer[i] = iAO(NULL, 0, i);
//----
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CatchBullishDivergence(int shift)
  {
   if(IsIndicatorTrough(shift) == false)
       return;
   int currentTrough = shift;
   int lastTrough = GetIndicatorLastTrough(shift);
  
   if(AOBuffer[currentTrough] > AOBuffer[lastTrough] && Low[currentTrough] < Low[lastTrough])
     {
      bullishDivergence[currentTrough] = AOBuffer[currentTrough];
      if(drawDivergenceLines == true)
        {
          DrawPriceTrendLine(Time[currentTrough], Time[lastTrough], Low[currentTrough], 
                             Low[lastTrough], Green, STYLE_SOLID);
          DrawIndicatorTrendLine(Time[currentTrough], Time[lastTrough], AOBuffer[currentTrough],
                                 AOBuffer[lastTrough], Green, STYLE_SOLID);
        }
      if(displayAlert == true)
          DisplayAlert("Classical bullish Awesome divergence on: ", currentTrough);  
     }
   if(AOBuffer[currentTrough] < AOBuffer[lastTrough] && Low[currentTrough] > Low[lastTrough])
     {
      bullishDivergence[currentTrough] = AOBuffer[currentTrough];
      if(drawDivergenceLines == true)
        {
          DrawPriceTrendLine(Time[currentTrough], Time[lastTrough], Low[currentTrough], 
                             Low[lastTrough], Green, STYLE_DOT);
          DrawIndicatorTrendLine(Time[currentTrough], Time[lastTrough], AOBuffer[currentTrough],
                                 AOBuffer[lastTrough], Green, STYLE_DOT);
        }
      if(displayAlert == true)
          DisplayAlert("Reverse bullish Awesome divergence on: ", currentTrough);   
     }      
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CatchBearishDivergence(int shift)
  {
   if(IsIndicatorPeak(shift) == false)
       return;
   int currentPeak = shift;
   int lastPeak = GetIndicatorLastPeak(shift);
  
   if(AOBuffer[currentPeak] < AOBuffer[lastPeak] && High[currentPeak] > High[lastPeak])
     {
       bearishDivergence[currentPeak] = AOBuffer[currentPeak];
       if(drawDivergenceLines == true)
         {
           DrawPriceTrendLine(Time[currentPeak], Time[lastPeak], High[currentPeak], 
                              High[lastPeak], Red, STYLE_SOLID);
           DrawIndicatorTrendLine(Time[currentPeak], Time[lastPeak], AOBuffer[currentPeak],
                                  AOBuffer[lastPeak], Red, STYLE_SOLID);
         }
       if(displayAlert == true)
           DisplayAlert("Classical bearish Awesome divergence on: ", currentPeak);  
     }
   if(AOBuffer[currentPeak] > AOBuffer[lastPeak] && High[currentPeak] < High[lastPeak])
     {
       bearishDivergence[currentPeak] = AOBuffer[currentPeak];
       if(drawDivergenceLines == true)
         {
           DrawPriceTrendLine(Time[currentPeak], Time[lastPeak], High[currentPeak], 
                              High[lastPeak], Red, STYLE_DOT);
           DrawIndicatorTrendLine(Time[currentPeak], Time[lastPeak], AOBuffer[currentPeak],
                                  AOBuffer[lastPeak], Red, STYLE_DOT);
         }
       if(displayAlert == true)
           DisplayAlert("Reverse bearish Awesome divergence on: ", currentPeak);   
     }   
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsIndicatorPeak(int shift)
  {
   if(AOBuffer[shift] > AOBuffer[shift+1] && AOBuffer[shift] > AOBuffer[shift-1])
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
   if(AOBuffer[shift] < AOBuffer[shift+1] && AOBuffer[shift] < AOBuffer[shift-1])
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
        if(AOBuffer[i] >= AOBuffer[i+1] && AOBuffer[i] > AOBuffer[i+2] &&
           AOBuffer[i] >= AOBuffer[i-1] && AOBuffer[i] > AOBuffer[i-2])
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
        if(AOBuffer[i] <= AOBuffer[i+1] && AOBuffer[i] < AOBuffer[i+2] &&
           AOBuffer[i] <= AOBuffer[i-1] && AOBuffer[i] < AOBuffer[i-2])
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
   string label = "AODivergenceLine# " + DoubleToStr(x1, 0);
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
   string label = "AODivergenceLine$# " + DoubleToStr(x1, 0);
   ObjectDelete(label);
   ObjectCreate(label, OBJ_TREND, indicatorWindow, x1, y1, x2, y2, 0, 0);
   ObjectSet(label, OBJPROP_RAY, 0);
   ObjectSet(label, OBJPROP_COLOR, lineColor);
   ObjectSet(label, OBJPROP_STYLE, style);
  }
//+------------------------------------------------------------------+




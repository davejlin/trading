//+------------------------------------------------------------------+
//|                                                SCI Main Body.mqh |
//|                                   Copyright © 2013, David J. Lin |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, David J. Lin"
#property link      ""

//---- buffers

double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
double ExtMapBuffer7[];
double ExtMapBuffer8[];

datetime RTimeArray[];
datetime lasttime;

int TimeFrame;
int atrTimeFrame;
int IndexStyleType;

int    window;
string name;

int modeHigh=0;
int modeLow=1;
int modeOpen=2;
int modeClose=3;
int modeMA1=4;
int modeMA2=5;

string ATRCustomIndicator="Utilities SCI Method ATR";
string MACustomIndicator="Utilities SCI Method MA";
string STOCHCustomIndicator="Utilities SCI Method STOCH";
string IndexCustomIndicator="Utilities SCI Data";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int init()
{
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexBuffer(4,ExtMapBuffer5);
   SetIndexBuffer(5,ExtMapBuffer6);
   SetIndexBuffer(6,ExtMapBuffer7);
   SetIndexBuffer(7,ExtMapBuffer8);   
   
   if(ShowStochAndBands)
   {
    IndexStyleType = DRAW_LINE;
   }
   else
   {
    IndexStyleType = DRAW_NONE;
   }
   
   for(int i=0; i<4; i++)
   {
    SetIndexStyle(i,IndexStyleType);
   }

   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+2);

   TimeFrame = Period();
   atrTimeFrame=PERIOD_D1;
   if (TimeFrame >= atrTimeFrame)
      switch (TimeFrame)
         {
            case PERIOD_D1: atrTimeFrame = PERIOD_W1; break;
            default:        atrTimeFrame = PERIOD_MN1;
         }
 
   SetIndexLabel(0,"Stoch["+TimeFrame+"] L"+DoubleToStr(L_overBought1,2)+"");
   SetIndexLabel(1,"Stoch["+TimeFrame+"] L"+DoubleToStr(L_50         ,2)+"");
   SetIndexLabel(2,"Stoch["+TimeFrame+"] L"+DoubleToStr(L_overSold1  ,2)+"");
   SetIndexLabel(3,"Stoch["+TimeFrame+"]("+KPeriod+","+DPeriod+","+Slowing+")Main");
   SetIndexLabel(4,ShortTermMAperiod+" average");
   SetIndexLabel(5,LongTermMAperiod+" average");
   SetIndexLabel(6,"High");
   SetIndexLabel(7,"Low");

   name = "SCI "+Identifier+" ["+TimeFrame+"/"+Period()+"]("+KPeriod+","+DPeriod+","+Slowing+")["+maPeriod+"]";
   IndicatorShortName(name);
 
   IndexCustomIndicator="Utilities SCI Data "+Identifier;
 
   if(maxBars<=0 || maxBars>Bars) maxBars = Bars;
   
   lasttime = 0;
 
   return(0);
}
int deinit()
{
   string oName;
   for (int i = ObjectsTotal() - 1; i >= 0; i--)
   {
      oName = ObjectName(i); if (StringFind(oName, name, 0) >= 0) ObjectDelete(oName);
   }
   return (0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
{
   double maValue,avgRange,stochValue;//,signalValue;
   double StochBandsOverBought,StochBandsCenter,StochBandsOverSold,StochMain;
   double prevStochMain,curStochBandsOverBought,curStochBandsOverSold,curStochMain;
   double high,low,open,close;
   int    counted_bars=IndicatorCounted();
   int    limit;
   int    i,r;
   window = WindowFind(name);
   
   if(counted_bars<0) return(-1);
   if(counted_bars==0)
   {
      limit = maxBars-1;
   }
   else
   {
      counted_bars--;   
      limit = MathMax(Bars-counted_bars,2);
   }
      
      ArrayCopySeries(RTimeArray ,MODE_TIME ,NULL,atrTimeFrame);
   
      for (i=0,r=0;i<limit;i++)
         {
            if(Time[i]<RTimeArray[r]) r++;
            
            avgRange         = iCustom(NULL,atrTimeFrame,ATRCustomIndicator,maPeriod,atrTimeFrame,ShortTermMAperiod,ShortTermMAmethod,LongTermMAperiod,LongTermMAmethod,IndexCustomIndicator,0,r);
            maValue          = iCustom(NULL,TimeFrame,MACustomIndicator,maPeriod,0,maMethod,maPrice,ShortTermMAperiod,ShortTermMAmethod,LongTermMAperiod,LongTermMAmethod,IndexCustomIndicator,0,i);
            stochValue       = iCustom(NULL,TimeFrame,STOCHCustomIndicator,KPeriod,DPeriod,Slowing,ShortTermMAperiod,ShortTermMAmethod,LongTermMAperiod,LongTermMAmethod,IndexCustomIndicator,0,i);
            //signalValue      = iCustom(NULL,TimeFrame,STOCHCustomIndicator,KPeriod,DPeriod,Slowing,ShortTermMAperiod,ShortTermMAmethod,LongTermMAperiod,LongTermMAmethod,IndexCustomIndicator,1,i);

            StochBandsOverBought = maValue+(avgRange*(L_overBought1 -50.0)/100); 
            StochBandsCenter     = maValue+(avgRange*(L_50          -50.0)/100); 
            StochBandsOverSold   = maValue+(avgRange*(L_overSold1   -50.0)/100); 
            StochMain            = maValue+(avgRange*(stochValue    -50.0)/100);

            if(ShowStochAndBands)
            {
             ExtMapBuffer1[i] = StochBandsOverBought; 
             ExtMapBuffer2[i] = StochBandsCenter; 
             ExtMapBuffer3[i] = StochBandsOverSold; 
  
             ExtMapBuffer4[i] = StochMain;
            }

            if(i==0)
            {
             curStochBandsOverBought = StochBandsOverBought;
             curStochBandsOverSold   = StochBandsOverSold;
             curStochMain            = StochMain;
            }
            else if(i==1)
            {
             prevStochMain           = StochMain;
            }
                        
            ExtMapBuffer5[i] = iCustom(NULL,0,IndexCustomIndicator,ShortTermMAperiod,ShortTermMAmethod,LongTermMAperiod,LongTermMAmethod,modeMA1,i);
            ExtMapBuffer6[i] = iCustom(NULL,0,IndexCustomIndicator,ShortTermMAperiod,ShortTermMAmethod,LongTermMAperiod,LongTermMAmethod,modeMA2,i);

            high  = iCustom(NULL,0,IndexCustomIndicator,ShortTermMAperiod,ShortTermMAmethod,LongTermMAperiod,LongTermMAmethod,modeHigh,i);
            low   = iCustom(NULL,0,IndexCustomIndicator,ShortTermMAperiod,ShortTermMAmethod,LongTermMAperiod,LongTermMAmethod,modeLow,i);
            open  = iCustom(NULL,0,IndexCustomIndicator,ShortTermMAperiod,ShortTermMAmethod,LongTermMAperiod,LongTermMAmethod,modeOpen,i);
            close = iCustom(NULL,0,IndexCustomIndicator,ShortTermMAperiod,ShortTermMAmethod,LongTermMAperiod,LongTermMAmethod,modeClose,i);

            ExtMapBuffer7[i] = high; // for proper chart scaling
            ExtMapBuffer8[i] = low;  // for proper chart scaling
            
            if (!ShowBars) continue;

            color  theBarColor  = colorBarNeutral;
            color  theWickColor = colorWickNeutral;
            
                 if (close<open) { theBarColor = colorBarDown; theWickColor = colorWickDown; }
            else if (close>open) { theBarColor = colorBarUp;   theWickColor = colorWickUp;   }
               
            drawBar(Time[i],high,low,open,close,theBarColor,theWickColor);

         }
   
   if(lasttime==Time[0])
    return(0);
          
   if(alert(ExtMapBuffer6[0],ExtMapBuffer6[1],curStochMain,prevStochMain,curStochBandsOverBought,curStochBandsOverSold))
    lasttime = Time[0];
         
   return(0);
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

#include "SCI Utilities.mqh"
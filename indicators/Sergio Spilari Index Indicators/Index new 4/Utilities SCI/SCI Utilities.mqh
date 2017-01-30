//+------------------------------------------------------------------+
//|                                                SCI Utilities.mqh |
//|                                   Copyright © 2013, David J. Lin |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, David J. Lin"
#property link      ""

void drawBar(int bTime, double prHigh, double prLow, double prOpen, double prClose, color barColor, color wickColor)
{
   string oName;
          oName = name+TimeToStr(bTime)+"w";
            if (ObjectFind(oName) < 0) ObjectCreate(oName,OBJ_TREND,window,bTime,0,bTime,0);
                 ObjectSet(oName, OBJPROP_PRICE1, prHigh);
                 ObjectSet(oName, OBJPROP_PRICE2, prLow);
                 ObjectSet(oName, OBJPROP_COLOR, wickColor);
                 ObjectSet(oName, OBJPROP_WIDTH, widthWick);
                 ObjectSet(oName, OBJPROP_RAY, false);
                 ObjectSet(oName, OBJPROP_BACK, true);
           
         oName = name+TimeToStr(bTime)+"b";
            if (ObjectFind(oName) < 0)ObjectCreate(oName,OBJ_TREND,window,bTime,0,bTime,0);
                 ObjectSet(oName, OBJPROP_PRICE1, prOpen);
                 ObjectSet(oName, OBJPROP_PRICE2, prClose);
                 ObjectSet(oName, OBJPROP_COLOR, barColor);
                 ObjectSet(oName, OBJPROP_WIDTH, widthBody);
                 ObjectSet(oName, OBJPROP_RAY, false);
                 ObjectSet(oName, OBJPROP_BACK, true);
}

bool alert(double ma0, double ma1, double stoch0, double stoch1, double overbought0, double oversold0)
{

 if(ma0>=ma1)
 {
  if(stoch1>oversold0 && stoch0<=oversold0)
  {
   Alert(Identifier+" MA Increasing and Stoch Oversold!");
   return (true);
  }
 }
 else
 {
  if(stoch1<overbought0 && stoch0>=overbought0)
  {
   Alert(Identifier+" MA Decreasing and Stoch Overbought!");
   return(true);
  }
 }
 
 return(false);
}
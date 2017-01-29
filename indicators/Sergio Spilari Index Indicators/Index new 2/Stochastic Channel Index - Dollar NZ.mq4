//+----------------------------------------------------------------------+
//|                             Stochastic Channel Index - Dollar NZ.mq4 |
//|                                                         David J. Lin |
//| Stochastic Channel Index - Dollar NZ                                 |
//|                                                                      |
//| Coded for Sérgio Spilari Filho <sergio@ssfconsultoriafinanceira.com> |
//| Coded by David J. Lin (dave.j.lin@gmail.com)                         |
//| Evanston, IL, May 26, 2013                                           |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2013,  Sérgio Spilari Filho and David J. Lin"

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 DarkGreen          // Stoch 80
#property indicator_color2 DarkGreen          // Stoch L_50
#property indicator_color3 DarkGreen          // Stoch 20
#property indicator_color4 Gold               // Stoch Main
#property indicator_color5 DeepSkyBlue        // Index MA1
#property indicator_color6 PaleVioletRed      // Index MA2

#property indicator_style2 STYLE_DOT
#property indicator_style5 STYLE_DASH
#property indicator_style6 STYLE_DOT

//---- parameters

extern int KPeriod    = 14;
extern int DPeriod    =  3;
extern int Slowing    =  3;
extern int maPeriod   = 14;
extern int maMethod   =  1;
extern int maPrice    =  0;
extern double L_overBought1 = 76.4;//80
extern double L_50          = 50.0;
extern double L_overSold1   = 23.6;//20

extern string timeFrame = "Current Timeframe";
extern string note_TimeFrames = "M1;5,15,30,60(H1);H4;D1;W1;MN";

extern string Identifier       = "Dollar NZ";
 
extern int    ShortTermMAperiod = 20;
extern int    ShortTermMAmethod = MODE_SMA;
extern int    LongTermMAperiod  = 40;
extern int    LongTermMAmethod  = MODE_SMA;

extern bool   ShowBars         = true;
extern color  colorBarDown     = Red;
extern color  colorBarUp       = Green;
extern color  colorBarNeutral  = DimGray;
extern color  colorWickUp      = Blue;
extern color  colorWickDown    = Red;
extern color  colorWickNeutral = DimGray;
extern int    widthWick        = 1;
extern int    widthBody        = 3;

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
datetime TTimeArray[];

int TimeFrame;
int atrTimeFrame;

int    window;
string name;

int modeHigh=0;
int modeLow=1;
int modeOpen=2;
int modeClose=3;
int modeMA1=4;
int modeMA2=5;

string ATRCustomIndicator="Stochastic Channel Index Method - ATR";
string MACustomIndicator="Stochastic Channel Index Method - MA";
string STOCHCustomIndicator="Stochastic Channel Index Method - STOCH";
string IndexCustomIndicator="Stochastic Channel Index Method - DATA";
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

   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+2);

   TimeFrame = stringToTimeFrame(timeFrame);
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

   name = "Stoch Channel Index "+Identifier+" ["+TimeFrame+"/"+Period()+"]("+KPeriod+","+DPeriod+","+Slowing+")["+maPeriod+"]";
   IndicatorShortName(name);
 
   IndexCustomIndicator="Stochastic Channel Index Method - DATA "+Identifier;
 
   return(0);
}
int deinit()
{
   return(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
{
   double maValue,avgRange,stochValue,signalValue;
   double high,low,open,close;
   int    counted_bars=IndicatorCounted();
   int    limit;
   int    i,r,y;
   window = WindowFind(name);
   
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   
      limit=MathMax(Bars-counted_bars,TimeFrame/Period());   

      ArrayCopySeries(RTimeArray ,MODE_TIME ,NULL,atrTimeFrame);
      ArrayCopySeries(TTimeArray ,MODE_TIME ,NULL,TimeFrame);
   
      for (i=0,r=0,y=0;i<limit;i++)
         {
            if(Time[i]<RTimeArray[r]) r++;
            if(Time[i]<TTimeArray[y]) y++;
            
            avgRange         = iCustom(NULL,atrTimeFrame,ATRCustomIndicator,maPeriod,atrTimeFrame,ShortTermMAperiod,ShortTermMAmethod,LongTermMAperiod,LongTermMAmethod,IndexCustomIndicator,0,r);
            maValue          = iCustom(NULL,TimeFrame,MACustomIndicator,maPeriod,0,maMethod,maPrice,TimeFrame,ShortTermMAperiod,ShortTermMAmethod,LongTermMAperiod,LongTermMAmethod,IndexCustomIndicator,0,y);
            stochValue       = iCustom(NULL,TimeFrame,STOCHCustomIndicator,KPeriod,DPeriod,Slowing,TimeFrame,ShortTermMAperiod,ShortTermMAmethod,LongTermMAperiod,LongTermMAmethod,IndexCustomIndicator,0,y);
            signalValue      = iCustom(NULL,TimeFrame,STOCHCustomIndicator,KPeriod,DPeriod,Slowing,TimeFrame,ShortTermMAperiod,ShortTermMAmethod,LongTermMAperiod,LongTermMAmethod,IndexCustomIndicator,1,y);

            ExtMapBuffer1[i] = maValue+(avgRange*(L_overBought1 -50.0)/100); 
            ExtMapBuffer2[i] = maValue+(avgRange*(L_50          -50.0)/100); 
            ExtMapBuffer3[i] = maValue+(avgRange*(L_overSold1   -50.0)/100); 
  
            ExtMapBuffer4[i] = maValue+(avgRange*(stochValue    -50.0)/100);
            
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
   return(0);
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int stringToTimeFrame(string tfs)
{
   int tf=0;
       tfs = StringUpperCase(tfs);
         if (tfs=="M1" || tfs=="1")     tf=PERIOD_M1;
         if (tfs=="M5" || tfs=="5")     tf=PERIOD_M5;
         if (tfs=="M15"|| tfs=="15")    tf=PERIOD_M15;
         if (tfs=="M30"|| tfs=="30")    tf=PERIOD_M30;
         if (tfs=="H1" || tfs=="60")    tf=PERIOD_H1;
         if (tfs=="H4" || tfs=="240")   tf=PERIOD_H4;
         if (tfs=="D1" || tfs=="1440")  tf=PERIOD_D1;
         if (tfs=="W1" || tfs=="10080") tf=PERIOD_W1;
         if (tfs=="MN" || tfs=="43200") tf=PERIOD_MN1;
         if (tf<Period()) tf=Period();
  return(tf);
}

string StringUpperCase(string str)
{
   string   s = str;
   int      lenght = StringLen(str) - 1;
   int      char;
   
   while(lenght >= 0)
      {
         char = StringGetChar(s, lenght);
         
         if((char > 96 && char < 123) || (char > 223 && char < 256))
                  s = StringSetChar(s, lenght, char - 32);
          else 
              if(char > -33 && char < 0)
                  s = StringSetChar(s, lenght, char + 224);
         lenght--;
   }
   return(s);
}


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


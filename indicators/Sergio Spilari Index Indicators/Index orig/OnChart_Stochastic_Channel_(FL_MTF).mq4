//+------------------------------------------------------------------+
//|OnChart_Stochastic_Channel(FL_MTF)[cw]mod  OnChart Stochastic.mq4 |
//|                                                           mladen |
//|  mtf  Fibo Levels [forexTSD.com; 2007]                           |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 DarkGreen          //80//
#property indicator_color2 DarkSlateGray      //70   //L_overBough
#property indicator_color3 DarkGreen          //L_50
#property indicator_color4 DarkSlateGray      //30   //L_overSold
#property indicator_color5 DarkGreen          //20//
#property indicator_color6 Red
#property indicator_color7 Gold
#property indicator_style3 STYLE_DOT
#property indicator_style6 STYLE_DOT


//---- parameters
//
//
//
//

extern int KPeriod    = 14;
extern int DPeriod    =  3;
extern int Slowing    =  3;
extern int maPeriod   = 14;
extern int maMethod   =  1;
extern int maPrice    =  0;
extern double L_overBought1 = 76.4;//80
extern double L_overBought  = 61.8;//70
extern double L_50          = 50.0;
extern double L_overSold    = 38.2;//30
extern double L_overSold1   = 23.6;//20

extern string timeFrame = "Current Timeframe";
extern string note_TimeFrames = "M1;5,15,30,60(H1);H4;D1;W1;MN";
//---- buffers
//
//
//
//

double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
double ExtMapBuffer7[];
datetime RTimeArray[];
datetime TTimeArray[];
int      TimeFrame;
int      atrTimeFrame;
string   shortName;

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

  IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+2);

   //
   //
   //
   //
   //
   
   TimeFrame = stringToTimeFrame(timeFrame);
   atrTimeFrame=PERIOD_D1;
   if (TimeFrame >= atrTimeFrame)
      switch (TimeFrame)
         {
            case PERIOD_D1: atrTimeFrame = PERIOD_W1; break;
            default:        atrTimeFrame = PERIOD_MN1;
         }

   IndicatorShortName("OnChart_Stoch["+TimeFrame+"/"+Period()+"]("+KPeriod+","+DPeriod+","+Slowing+")["+maPeriod+"]");  
 
   SetIndexLabel(0,"Stoch["+TimeFrame+"] L"+DoubleToStr(L_overBought1,2)+"");
   SetIndexLabel(1,"Stoch["+TimeFrame+"] L"+DoubleToStr(L_overBought ,2)+"");
   SetIndexLabel(2,"Stoch["+TimeFrame+"] L"+DoubleToStr(L_50         ,2)+"");
   SetIndexLabel(3,"Stoch["+TimeFrame+"] L"+DoubleToStr(L_overSold   ,2)+"");
   SetIndexLabel(4,"Stoch["+TimeFrame+"] L"+DoubleToStr(L_overSold1  ,2)+"");
   SetIndexLabel(5,"Stoch["+TimeFrame+"]("+KPeriod+","+DPeriod+","+Slowing+")Sig");
   SetIndexLabel(6,"Stoch["+TimeFrame+"]("+KPeriod+","+DPeriod+","+Slowing+")Main");

 
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
   double maValue;
   double avgRange;
   double stochValue;
   double signalValue;
   int    counted_bars=IndicatorCounted();
   int    limit;
   int    i,r,y;
   
//----
   
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
      limit=MathMax(Bars-counted_bars,TimeFrame/Period());   
      
      ArrayCopySeries(RTimeArray ,MODE_TIME ,NULL,atrTimeFrame);
      ArrayCopySeries(TTimeArray ,MODE_TIME ,NULL,TimeFrame);

   //----
   //
   //
   //
   //
   
      for (i=0,r=0,y=0;i<limit;i++)
         {
            if(Time[i]<RTimeArray[r]) r++;
            if(Time[i]<TTimeArray[y]) y++;
               avgRange         = iATR(NULL,atrTimeFrame,maPeriod,r);
               maValue          = iMA(NULL,TimeFrame,maPeriod,0,maMethod,maPrice,y);
               stochValue       = iStochastic(NULL,TimeFrame,KPeriod,DPeriod,Slowing,maMethod,0,MODE_MAIN,  y);
               signalValue      = iStochastic(NULL,TimeFrame,KPeriod,DPeriod,Slowing,maMethod,0,MODE_SIGNAL,y);
               
               //
               //
               //
               //
               //
     
         ExtMapBuffer1[i] = maValue+(avgRange*(L_overBought1 -50.0)/100); 
         ExtMapBuffer2[i] = maValue+(avgRange*(L_overBought  -50.0)/100); 
         ExtMapBuffer3[i] = maValue+(avgRange*(L_50          -50.0)/100); 
         ExtMapBuffer4[i] = maValue+(avgRange*(L_overSold    -50.0)/100); 
         ExtMapBuffer5[i] = maValue+(avgRange*(L_overSold1   -50.0)/100); 
  
         ExtMapBuffer6[i] = maValue+(avgRange*(signalValue   -50.0)/100);  
         ExtMapBuffer7[i] = maValue+(avgRange*(stochValue    -50.0)/100); 
     
         }
   
   //
   //
   //
   //
   //

   return(0);
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//
//
//
//
//

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

//
//
//
//
//

string StringUpperCase(string str)
{
   string   s = str;
   int      lenght = StringLen(str) - 1;
   int      char;
   
   while(lenght >= 0)
      {
         char = StringGetChar(s, lenght);
         
         //
         //
         //
         //
         //
         
         if((char > 96 && char < 123) || (char > 223 && char < 256))
                  s = StringSetChar(s, lenght, char - 32);
          else 
              if(char > -33 && char < 0)
                  s = StringSetChar(s, lenght, char + 224);
         lenght--;
   }
   
   //
   //
   //
   //
   //
   
   return(s);
}
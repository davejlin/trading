//+------------------------------------------------------------------+
//|                                        Alert Price Cross MAs.mq4 |
//|                                         Copyright David Lin 2018 |
//|                                             dave.j.lin@gmail.com |
//|                                                                  |
//|                               Written for RoyalMiguel Enterprise |
//|                                                    April 27, 2018|
//+------------------------------------------------------------------+
#property copyright   "2018 David Lin"
#property link        "dave.j.lin@gmail.com"
#property description "Alerts on price hitting MAs\nWritten for RoyalMiguel Enterprise\nApril 27,2018"
#property strict

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue
//--- indicator parameters
input int            MAPeriod1=13;        // Period 1
input int            MAShift1=0;          // Shift 1
input ENUM_MA_METHOD MAMethod1=MODE_SMA;  // Method 1
input ENUM_APPLIED_PRICE MAPrice1=PRICE_CLOSE;  // Price 1
input int            MAPeriod2=5;         // Period 2
input int            MAShift2=0;          // Shift 2
input ENUM_MA_METHOD MAMethod2=MODE_SMA;  // Method 2
input ENUM_APPLIED_PRICE MAPrice2=PRICE_CLOSE;  // Price 2
//--- buffers
double MABuffer1[];
double MABuffer2[];
double lastPrice;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   IndicatorBuffers(2);
   IndicatorDigits(Digits);
//--- MA 1
   SetIndexBuffer(0,MABuffer1);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexShift(0,MAShift1);
   SetIndexLabel(0,"MA 1");
//--- MA 2
   SetIndexBuffer(1,MABuffer2);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexShift(1,MAShift2);
   SetIndexLabel(1,"MA 2");
//--- check for input parameter
   if(MAPeriod1<=0 || MAPeriod2<=0)
   {
      Print("Wrong input parameter MA Period=", MAPeriod1, " ", MAPeriod2);
      return(INIT_FAILED);
   }
//---
   SetIndexDrawBegin(0,MAPeriod1-MAShift1);
   SetIndexDrawBegin(1,MAPeriod2-MAShift2);
   
   ArraySetAsSeries(MABuffer1, true);
   ArraySetAsSeries(MABuffer2, true);
//--- initialization done
   lastPrice = iClose(NULL,0,0);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Alert Price Cross MAs                                            |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   int i,pos1,pos2;
//---
   if(rates_total<=MAPeriod1 || rates_total<=MAPeriod2 || MAPeriod1<=0 || MAPeriod2<=0 )
      return(0);
      
//--- starting calculation
   if(prev_calculated==0)
   {
      pos1=rates_total-MAPeriod1;
      pos2=rates_total-MAPeriod2;
   }
   else
   {
      pos1=1;
      pos2=1;
   }
//--- main cycle
   for(i=0; i<pos1 && !IsStopped(); i++)
   {
      //--- MA 1
      MABuffer1[i]=iMA(NULL, 0, MAPeriod1, MAShift1, MAMethod1, MAPrice1, i);
   }
   for(i=0; i<pos2 && !IsStopped(); i++)
   {
      //--- MA 2
      MABuffer2[i]=iMA(NULL, 0, MAPeriod2, MAShift2, MAMethod2, MAPrice2, i);
   }

   double thisPrice = close[0];
   CheckAlertTrigger(thisPrice, lastPrice, MABuffer1[0], "Price has crossed MA1 ("+MAPeriod1+","+MAShift1+") on "+ Symbol());
   CheckAlertTrigger(thisPrice, lastPrice, MABuffer2[0], "Price has crossed MA2 ("+MAPeriod2+","+MAShift2+") on "+ Symbol());
   lastPrice = thisPrice;

//---- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
void CheckAlertTrigger(double thisPrice, double lastPrice, double maPrice, string message)
{
   if((thisPrice>=maPrice && lastPrice<maPrice) || (thisPrice<=maPrice && lastPrice>maPrice))
   {
      Alert(message);
   }
}
//+------------------------------------------------------------------+
//|                                                 5dayBreakout.mq4 |
//|                                                        Bill Sica |
//|                                         http://www.tetsuyama.com |
//+------------------------------------------------------------------+
#property copyright "Bill Sica"
#property link      "http://www.tetsuyama.com"

#property indicator_chart_window
//---- input parameters
extern int       DAYS=50;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int init()
  {
//---- indicators

//---- indicators

   

//----
   return(0);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   double daily_high[20];
   double daily_low[20];
   double yesterday_close;
   double phigh,plow;
   int i=1;

//---- TODO: add your code here
ArrayResize(daily_high,DAYS);
ArrayResize(daily_low,DAYS);
ArrayInitialize(daily_high,0);
ArrayInitialize(daily_low,0);

ArrayCopySeries(daily_low, MODE_LOW, Symbol(), PERIOD_D1);
ArrayCopySeries(daily_high, MODE_HIGH, Symbol(), PERIOD_D1);

/* initialise */
plow=daily_low[1];
phigh=daily_high[1];

for(i=1;i<DAYS;i++)
{
   if(plow>daily_low[i])
   {
      plow =daily_low[i];
   }
}

for(i=1;i<DAYS;i++)
{
   if(phigh<daily_high[i])
   {
      phigh =daily_high[i];
   }
}

Comment("\n50dayH ",phigh,"\n50dayL ",plow);

ObjectDelete("50dayHigh");
ObjectDelete("50dayLow");

ObjectCreate("50dayHigh", OBJ_HLINE,0, CurTime(),phigh);
ObjectSet("50dayHigh",OBJPROP_COLOR,SpringGreen);
ObjectSet("50dayHigh",OBJPROP_STYLE,STYLE_SOLID);

ObjectCreate("50dayLow", OBJ_HLINE,0, CurTime(),plow);
ObjectSet("50dayLow",OBJPROP_COLOR,Red);
ObjectSet("50dayLow",OBJPROP_STYLE,STYLE_SOLID);

ObjectsRedraw();

   return(0);
  }
//+------------------------------------------------------------------
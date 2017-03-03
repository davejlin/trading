//+------------------------------------------------------------------+
//|                                                 Spread Alarm.mq4 |
//| Spread Alarm                                                     |
//| written for geneva wheeless (gkw1018@yahoo.com)                  |
//|                                                                  |
//| Coded by David J. Lin (dave.j.lin@sbcglobal.net)                 |
//| Evanston, IL, July 27, 2007                                      |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007 David J. Lin"
#property indicator_chart_window
//---- input parameters
extern int Spread=5;

double sref;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
 sref=NormDigits(Spread*Point);
 return(0);
}
//+------------------------------------------------------------------+
//| Trail Line                                                       |
//+------------------------------------------------------------------+
int start()
{
 double snow=NormDigits(Ask-Bid);
 if(snow>=sref) Alert("Spread is "+Spread+" pips!");

 Comment("Spread: "+DoubleToStr(snow/Point,0));
 return(0);
}
//+------------------------------------------------------------------+
double NormDigits(double value)
{                            
 return(NormalizeDouble(value,Digits));
}                           
//+------------------------------------------------------------------+



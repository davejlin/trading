//+----------------------------------------------------------------------+
//|                                             Bollinger Band Alert.mq4 |
//|                                       Copyright © 2008, David J. Lin |
//|Alert when price hits Bollinger Bands                                 |
//|Written for Elizabeth Mackert (blackridge5626@msn.com)                |
//|                                                                      |
//|Coded by David J. Lin (dave.j.lin@sbcglobal.net)                      |
//|Evanston, IL, February 21, 2008                                       |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2008, David J. Lin"
#property link      ""
#property indicator_buffers 2
#property indicator_chart_window

extern int TriggerPips=10;      // pips beyond Bollinger Band value at which to alert
extern int BBPeriod=20;         // Bollinger Band period 
extern int BBDeviation=2;       // Bollinger Band deviation (integer values only) 
extern int BBShift=0;           // Bollinger Band shift 
extern int BBPrice=PRICE_CLOSE; // Bollinger Band price 
extern bool Confirmed=true;     // true: use confirmed bar BB values, false: use instantaneous BB values
extern bool AlertAlarm=true;    // true: platform alert ON, false: platform alert OFF
extern bool AlertEmail=true;    // true: email alert ON, false: email alert OFF

extern color color1=MediumSeaGreen;

double upper[],lower[];
double triggerpoints;
datetime alerttime;
int shift;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
//---- indicator line
 SetIndexStyle(0, DRAW_LINE, 0, 1, color1);
 SetIndexStyle(1, DRAW_LINE, 0, 1, color1);
 SetIndexBuffer(0, upper);
 SetIndexBuffer(1, lower);
 SetIndexLabel(0, "Upper BB");
 SetIndexLabel(1, "Lower BB");
 string short_name = "Bollinger Bands Alert";
 IndicatorShortName(short_name);
 if(Confirmed) shift=1;
 else shift=0;
 triggerpoints=NormalizeDouble(TriggerPips*Point,Digits);
//----
 return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
//----
//----
 return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
 int i,imax,counted_bars=IndicatorCounted();
 int checktime=iBarShift(NULL,0,alerttime,false);
 
//----
 if(counted_bars>0) imax=Bars-counted_bars+1;
 else               imax=Bars-1;
   
 for(i=imax;i>=shift;i--)
 {
  upper[i]=iBands(NULL,0,BBPeriod,BBDeviation,BBShift,BBPrice,MODE_UPPER,i);
  lower[i]=iBands(NULL,0,BBPeriod,BBDeviation,BBShift,BBPrice,MODE_LOWER,i);     

  if(i==shift && checktime>0)
  {
   double bbup=upper[i];
   double bbdn=lower[i];
   
   if(iClose(NULL,0,0)>=NormalizeDouble(bbup+triggerpoints,Digits))
   {
    SendMessage(i,"Upper BB",bbup);
    alerttime=iTime(NULL,0,0);
   }
  
   if(iClose(NULL,0,0)<=NormalizeDouble(bbdn-triggerpoints,Digits))
   {
    SendMessage(i,"Lower BB",bbdn);
    alerttime=iTime(NULL,0,0); 
   }
  }
       
 }
//----
 return(0);
}
//+------------------------------------------------------------------+
void SendMessage(int i, string bias, double bb)
{
 string td=TimeToStr(iTime(NULL,0,i),TIME_DATE|TIME_MINUTES);     
 string message=StringConcatenate(Symbol()," Bid has exceeded ", bias, " at ",td,". BB value=",bb," Bid=",iClose(NULL,0,0));
 if (AlertAlarm) Alert(message);
 if (AlertEmail) SendMail("MT4 Bollinger Bands Alert!",message);
 return;
}
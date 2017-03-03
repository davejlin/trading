//+----------------------------------------------------------------------+
//|                                                Stoch Cross Alert.mq4 |
//|                                       Copyright © 2007, David J. Lin |
//|Alert when Stochastics crosses                                        |
//|Written for Leo Lepore (forexleo@yahoo.com)                           |
//|                                                                      |
//|Coded by David J. Lin (dave.j.lin@sbcglobal.net)                      |
//|Evanston, IL, December 10, 2007                                       |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2007, David J. Lin"
#property link      ""
#property indicator_buffers 2
#property indicator_separate_window

extern int KPeriod=5;
extern int DPeriod=3;
extern int Slowing=3;
extern bool Confirmed=true; //true: use confirmed bar values, false: use instantaneous values
extern bool AlertEmail=true;
extern bool AlertAlarm=true;

extern color color1=Red;
extern color color2=Lime;

int Method=MODE_SMA;
int Price=PRICE_CLOSE;

double main[],signal[];
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
 SetIndexStyle(1, DRAW_LINE, 0, 1, color2);
 SetIndexBuffer(0, main);
 SetIndexBuffer(1, signal);
 SetIndexLabel(0, "main");
 SetIndexLabel(1, "signals");
 string short_name = "Stoch Cross Alert";
 IndicatorShortName(short_name);
 if(Confirmed) shift=1;
 else shift=0;
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
 double stoch1m,stoch1s,stoch2m,stoch2s;
 int i,is,imax,counted_bars=IndicatorCounted();
 int checktime=iBarShift(NULL,0,alerttime,false);
 bool limit=true;  
//----
 if(counted_bars>0) imax=1;
 else imax=Bars;
   
 for(i=shift;i<=imax;i++)
 {
  main[i]=iStochastic(NULL,0,KPeriod,DPeriod,Slowing,Method,Price,MODE_MAIN,i);
  signal[i]=iStochastic(NULL,0,KPeriod,DPeriod,Slowing,Method,Price,MODE_SIGNAL,i);     

  if(counted_bars>0 && checktime>1 && limit)
  {
   stoch1m=main[i];
   stoch1s=signal[i];
   stoch2m=iStochastic(NULL,0,KPeriod,DPeriod,Slowing,Method,Price,MODE_MAIN,i+1);
   stoch2s=iStochastic(NULL,0,KPeriod,DPeriod,Slowing,Method,Price,MODE_SIGNAL,i+1); 
   
   if(stoch1m>=stoch1s && stoch2m<=stoch2s)
   {
    SendMessage(i,"Up",stoch1m,stoch1s);
    alerttime=iTime(NULL,0,i);
    limit=false;
   }
  
   if(stoch1m<=stoch1s && stoch2m>=stoch2s)
   {
    SendMessage(i,"Down",stoch1m,stoch1s);
    alerttime=iTime(NULL,0,i);     
    limit=false; 
   }
  }
       
 }
//----
 return(0);
}
//+------------------------------------------------------------------+
void SendMessage(int i, string bias, double v1, double v2)
{
 string td=TimeToStr(iTime(NULL,0,i),TIME_DATE|TIME_MINUTES);     
 string message=StringConcatenate(Symbol()," Stoch has crossed ", bias, " at ",td,". Main=",v1," Signal=",v2);
 if (AlertAlarm) Alert(message);
 if (AlertEmail) SendMail("MT4 Stoch-Cross Alert!",message);
 return;
}
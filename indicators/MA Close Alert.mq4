//+----------------------------------------------------------------------+
//|                                                   MA Close Alert.mq4 |
//|                                       Copyright © 2007, David J. Lin |
//|Alert when closes beyond MA                                           |
//|Written for Elizabeth Mackert <blackridge5626@msn.com>                |
//|                                                                      |
//|Coded by David J. Lin (dave.j.lin@sbcglobal.net)                      |
//|Evanston, IL, October 30, 2007                                        |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2007, David J. Lin"
#property link      ""
#property indicator_buffers 2
#property indicator_chart_window

extern int MAPeriod=10;
extern color color1=Lime;

int MAShift=0;
int MAMethod=MODE_SMA;
int MAPrice=PRICE_CLOSE;

double MA[];
datetime alerttime;
int shift;
bool AlertEmail=true;
bool AlertAlarm=true;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
//---- indicator line
 SetIndexStyle(0, DRAW_LINE, 0, 1, color1);
 SetIndexBuffer(0, MA);
 SetIndexLabel(0, "MA");
 string short_name = "MA Close Alert";
 IndicatorShortName(short_name);
 shift=1;
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
 double ma,close,open;
 int i,is,imax,counted_bars=IndicatorCounted();
 int checktime=iBarShift(NULL,0,alerttime,false);
//----
 if(counted_bars>0) imax=1;
 else imax=Bars;
   
 for(i=imax;i>=1;i--)
 {
  MA[i]=iMA(NULL,0,MAPeriod,MAShift,MAMethod,MAPrice,i);
     
  ma=MA[i];

  if(imax!=1) continue;  

  if(checktime>1)
  {
   close=iClose(NULL,0,i);
   open=iOpen(NULL,0,i);
  
   if(open<=ma && close>ma) 
   { 
    SendMessage(i,"Close Up Above MA Line!");
    alerttime=iTime(NULL,0,i);    
   }

   if(open>=ma && close<ma) 
   { 
    SendMessage(i,"Close Down Below MA Line!");
    alerttime=iTime(NULL,0,i);    
   }
  } 
 }
//----
 return(0);
}
//+------------------------------------------------------------------+
void SendMessage(int i, string note)
{
 string td=TimeToStr(iTime(NULL,0,i),TIME_DATE|TIME_MINUTES);     
 string message=StringConcatenate(Symbol()," ",note," at ",td);
 if (AlertAlarm) Alert(message);
 if (AlertEmail) SendMail("MA Close Alert!",message);
 return;
}
//+------------------------------------------------------------------+


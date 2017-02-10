//+----------------------------------------------------------------------+
//|                                                 2 MA Cross Alert.mq4 |
//|                                       Copyright © 2007, David J. Lin |
//|Alert when MA crosses                                                 |
//|Written for forex4me (Forex Factory)                                  |
//|D. B <travelnut92@yahoo.com>                                          |
//|Coded by David J. Lin (dave.j.lin@sbcglobal.net)                      |
//|Evanston, IL, July 10, 2008                                           |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2008, David J. Lin"
#property link      ""
#property indicator_buffers 2
#property indicator_chart_window

extern int MAPeriod1=3;
extern int MAPeriod2=8;
//extern int MAPeriod3=50;
extern int MAMethod1=MODE_EMA;
extern int MAMethod2=MODE_SMA;
extern bool Confirmed=true; //true: use confirmed bar values, false: use instantaneous values
extern bool AlertEmail=true;
extern bool AlertAlarm=true;

extern color color1=Magenta;
extern color color2=White;
//extern color color3=White;

int MAShift=0;
int MAPrice=PRICE_CLOSE;

double MA1[],MA2[];
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
// SetIndexStyle(2, DRAW_LINE, 0, 1, color3); 
 SetIndexBuffer(0, MA1);
 SetIndexBuffer(1, MA2);
// SetIndexBuffer(2, MA3);
 SetIndexLabel(0, "MA1");
 SetIndexLabel(1, "MA2");
// SetIndexLabel(2, "MA3");
 string short_name = "MA Cross Alert";
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
 double ma1,ma1b,ma2,ma2b;
 int i,is,imax,counted_bars=IndicatorCounted();
 int checktime=iBarShift(NULL,0,alerttime,false);
 bool limit=true;  
//----
 if(counted_bars>0) imax=1;
 else imax=Bars;
   
 for(i=shift;i<=imax;i++)
 {
  MA1[i]=iMA(NULL,0,MAPeriod1,MAShift,MAMethod1,MAPrice,i);
  MA2[i]=iMA(NULL,0,MAPeriod2,MAShift,MAMethod2,MAPrice,i);
//  MA3[i]=iMA(NULL,0,MAPeriod3,MAShift,MAMethod,MAPrice,i);        

  if(counted_bars>0 && checktime>1 && limit)
  {
   ma1=MA1[i];
   ma2=MA2[i];
   ma1b=iMA(NULL,0,MAPeriod1,MAShift,MAMethod1,MAPrice,i+1);
   ma2b=iMA(NULL,0,MAPeriod2,MAShift,MAMethod2,MAPrice,i+1);
   
   if(ma1>=ma2 && ma1b<=ma2b)
   {
    SendMessage(i,"Up",ma1,ma2);
    alerttime=iTime(NULL,0,i);
    limit=false;
   }
  
   if(ma1<=ma2 && ma1b>=ma2b)
   {
    SendMessage(i,"Down",ma1,ma2);
    alerttime=iTime(NULL,0,i);     
    limit=false; 
   }
  }
       
 }
//----
 return(0);
}
//+------------------------------------------------------------------+
void SendMessage(int i, string bias, double v1, double v3)
{
 string td=TimeToStr(iTime(NULL,0,i),TIME_DATE|TIME_MINUTES);     
 string message=StringConcatenate(Symbol()," MA has crossed ", bias, " at ",td,". MA1=",v1," MA3=",v3);
 if (AlertAlarm) Alert(message);
 if (AlertEmail) SendMail("MT4 MA-Cross Alert!",message);
 return;
}
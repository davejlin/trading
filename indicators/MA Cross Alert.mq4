//+----------------------------------------------------------------------+
//|                                                   MA Cross Alert.mq4 |
//|                                       Copyright © 2007, David J. Lin |
//|Alert when MA crosses                                                 |
//|Written for Leo Lepore (forexleo@yahoo.com)                           |
//|                                                                      |
//|Coded by David J. Lin (dave.j.lin@sbcglobal.net)                      |
//|Evanston, IL, September 24, 2007                                      |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2007, David J. Lin"
#property link      ""
#property indicator_buffers 3
#property indicator_chart_window

extern int MAPeriod1=5;
extern int MAPeriod2=15;
extern int MAPeriod3=50;
extern bool Confirmed=true; //true: use confirmed bar values, false: use instantaneous values
extern bool AlertEmail=true;
extern bool AlertAlarm=true;

extern color color1=Red;
extern color color2=Lime;
extern color color3=White;

int MAShift=0;
int MAMethod=MODE_EMA;
int MAPrice=PRICE_CLOSE;

double MA1[],MA2[],MA3[];
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
 SetIndexStyle(2, DRAW_LINE, 0, 1, color3); 
 SetIndexBuffer(0, MA1);
 SetIndexBuffer(1, MA2);
 SetIndexBuffer(2, MA3);
 SetIndexLabel(0, "MA1");
 SetIndexLabel(1, "MA2");
 SetIndexLabel(2, "MA3");
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
 double ma1,ma1b,ma3,ma3b;
 int i,is,imax,counted_bars=IndicatorCounted();
 int checktime=iBarShift(NULL,0,alerttime,false);
 bool limit=true;  
//----
 if(counted_bars>0) imax=1;
 else imax=Bars;
   
 for(i=shift;i<=imax;i++)
 {
  MA1[i]=iMA(NULL,0,MAPeriod1,MAShift,MAMethod,MAPrice,i);
  MA2[i]=iMA(NULL,0,MAPeriod2,MAShift,MAMethod,MAPrice,i);
  MA3[i]=iMA(NULL,0,MAPeriod3,MAShift,MAMethod,MAPrice,i);        

  if(counted_bars>0 && checktime>1 && limit)
  {
   ma1=MA1[i];
   ma3=MA3[i];
   ma1b=iMA(NULL,0,MAPeriod1,MAShift,MAMethod,MAPrice,i+1);
   ma3b=iMA(NULL,0,MAPeriod3,MAShift,MAMethod,MAPrice,i+1);
   
   if(ma1>=ma3 && ma1b<=ma3b)
   {
    SendMessage(i,"Up",ma1,ma3);
    alerttime=iTime(NULL,0,i);
    limit=false;
   }
  
   if(ma1<=ma3 && ma1b>=ma3b)
   {
    SendMessage(i,"Down",ma1,ma3);
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
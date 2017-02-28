//+----------------------------------------------------------------------+
//|                                            MA Slope Change Alert.mq4 |
//|                                       Copyright © 2007, David J. Lin |
//|Alert when MA slope changes                                           |
//|Written for Sam Moore <skmoore@lcturbonet.com>                        |
//|                                                                      |
//|Coded by David J. Lin (dave.j.lin@sbcglobal.net)                      |
//|Evanston, IL, October 31, 2007                                        |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2007, David J. Lin"
#property link      ""
#property indicator_buffers 2
#property indicator_chart_window

extern int MAPeriod1=10;
extern int MAPeriod2=20;
extern int MAShift1=0;
extern int MAShift2=0;
extern int MAMethod1=MODE_SMA;
extern int MAMethod2=MODE_SMA;
extern int MAPrice1=PRICE_CLOSE;
extern int MAPrice2=PRICE_CLOSE;
extern color color1=Red;
extern color color2=Blue;
extern bool AlertEmail=true;
extern bool AlertAlarm=true;

double MA1[],MA2[];
datetime alerttime;
string pd;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
//---- indicator line
 SetIndexStyle(0, DRAW_LINE, 0, 1, color1);
 SetIndexStyle(1, DRAW_LINE, 0, 1, color2);
 SetIndexBuffer(0, MA1);
 SetIndexBuffer(1, MA2);
 SetIndexLabel(0, "MA1");
 SetIndexLabel(1, "MA2");
 string short_name = "MA Slope Change Alert";
 IndicatorShortName(short_name);

 switch(Period())
 {
  case 1:     pd=" M1 ";  break;
  case 5:     pd=" M5 ";  break;
  case 15:    pd=" M15 "; break;
  case 30:    pd=" M30 "; break;
  case 60:    pd=" H1 ";  break;
  case 240:   pd=" H4 ";  break;
  case 1440:  pd=" D1 ";  break;
  case 10080: pd=" W1 ";  break;
  case 40320: pd=" M1 ";  break;
  default:    pd=" Non-Standard Timeframe ";break;
 }
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
 double ma11,ma12,ma13,ma21,ma22,ma23;
 string note;
 int i,is,imax,counted_bars=IndicatorCounted();
 int checktime=iBarShift(NULL,0,alerttime,false);
 
//----
 if(counted_bars>0) imax=1;
 else imax=Bars;
   
 for(i=imax;i>=1;i--)
 {
  MA1[i]=iMA(NULL,0,MAPeriod1,MAShift1,MAMethod1,MAPrice1,i);
  MA2[i]=iMA(NULL,0,MAPeriod2,MAShift2,MAMethod2,MAPrice2,i);       

  ma11=MA1[i];
  ma21=MA2[i];
  
  if(imax!=1) continue;

  if(checktime>1)
  {
   ma12=iMA(NULL,0,MAPeriod1,MAShift1,MAMethod1,MAPrice1,i+1);
   ma13=iMA(NULL,0,MAPeriod1,MAShift1,MAMethod1,MAPrice1,i+2);   
   ma22=iMA(NULL,0,MAPeriod2,MAShift2,MAMethod2,MAPrice2,i+1);  
   ma23=iMA(NULL,0,MAPeriod2,MAShift2,MAMethod2,MAPrice2,i+2);

   if(ma11>ma12 && ma12<=ma13 && ma22<=ma23)
   {
    note="MA#1 slope change Up ";
    SendMessage(i,note);
    alerttime=iTime(NULL,0,i);     
   }

   if(ma21>ma22 && ma12<=ma13 && ma22<=ma23)
   {
    note="MA#2 slope change Up ";
    SendMessage(i,note);
    alerttime=iTime(NULL,0,i);     
   }

   if(ma11<=ma12 && ma12>=ma13 && ma22>=ma23)
   {
    note="MA#1 slope change Down ";
    SendMessage(i,note);
    alerttime=iTime(NULL,0,i);    
   } 

   if(ma21<=ma22 && ma12>=ma13 && ma22>=ma23)
   {
    note="MA#2 slope change Down ";
    SendMessage(i,note);
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
 string message=StringConcatenate(Symbol(),pd,note," at ",td);
 if (AlertAlarm) Alert(message);
 if (AlertEmail) SendMail("MA Cross Slope Alert!",message);
 return;
}
//+------------------------------------------------------------------+


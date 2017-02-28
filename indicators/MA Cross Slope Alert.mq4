//+----------------------------------------------------------------------+
//|                                             MA Cross Slope Alert.mq4 |
//|                                       Copyright © 2007, David J. Lin |
//|Alert when MA crosses                                                 |
//|Written for Elizabeth Mackert <blackridge5626@msn.com>                |
//|                                                                      |
//|Coded by David J. Lin (dave.j.lin@sbcglobal.net)                      |
//|Evanston, IL, October 16, 2007                                        |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2007, David J. Lin"
#property link      ""
#property indicator_buffers 2
#property indicator_chart_window

extern int MAPeriod1=10;
extern int MAPeriod2=20;
extern int MADifference=5;
extern bool SlopeChangeAlert=true;
extern color color1=Red;
extern color color2=Blue;

int MAShift=0;
int MAMethod=MODE_EMA;
int MAPrice=PRICE_CLOSE;

double MA1[],MA2[];
double madiff;
datetime alerttime1,alerttime2,alerttime3;
int shift;
bool crossup,crossdn;
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
 SetIndexStyle(1, DRAW_LINE, 0, 1, color2);
 SetIndexBuffer(0, MA1);
 SetIndexBuffer(1, MA2);
 SetIndexLabel(0, "MA1");
 SetIndexLabel(1, "MA2");
 string short_name = "MA Cross Slope Alert";
 IndicatorShortName(short_name);
 shift=0;
 madiff=NormPoints(MADifference);
 crossup=false;crossdn=false;
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
 double ma11,ma12,ma13,ma21,ma22,ma23,diff;
 string note;
 int i,is,imax,counted_bars=IndicatorCounted();
 int checktime1=iBarShift(NULL,0,alerttime1,false);
 int checktime2=iBarShift(NULL,0,alerttime2,false);
 int checktime3=iBarShift(NULL,0,alerttime3,false);
 
//----
 if(counted_bars>0) imax=1;
 else imax=Bars;
   
 for(i=imax;i>=1;i--)
 {
  MA1[i]=iMA(NULL,0,MAPeriod1,MAShift,MAMethod,MAPrice,i);
  MA2[i]=iMA(NULL,0,MAPeriod2,MAShift,MAMethod,MAPrice,i);       

  ma11=MA1[i];
  ma21=MA2[i];

  ma12=iMA(NULL,0,MAPeriod1,MAShift,MAMethod,MAPrice,i+1);
  ma22=iMA(NULL,0,MAPeriod2,MAShift,MAMethod,MAPrice,i+1);

  if(ma11>=ma21 && ma12<=ma22) 
  {
   crossup=true;crossdn=false;
  }
  if(ma11<=ma21 && ma12>=ma22) 
  {
   crossdn=true;crossup=false;  
  }
  
  if(imax!=1) continue;
  if(checktime1>1)
  {
   diff=MathAbs(ma11-ma21);

   if(diff>=madiff)
   {
    if(crossup)
    {
     note=StringConcatenate("MA Cross Up exceeds ",MADifference," pips ");
     SendMessage(i,note);
     alerttime1=iTime(NULL,0,i);    
     crossup=false;
    }
   
    if(crossdn)
    {
     note=StringConcatenate("MA Cross Down exceeds ",MADifference," pips ");
     SendMessage(i,note);
     alerttime1=iTime(NULL,0,i);    
     crossdn=false;
    }
   }
  }

  if(!SlopeChangeAlert) continue;

  if(checktime2>1)
  {  
   ma13=iMA(NULL,0,MAPeriod1,MAShift,MAMethod,MAPrice,i+2);
   if(ma11>=ma12 && ma12<=ma13)
   {
    note="MA#1 slope change from Down to Up.";
    SendMessage(i,note);
    alerttime2=iTime(NULL,0,i);     
   }
   if(ma11<=ma12 && ma12>=ma13)
   {
    note="MA#1 slope change from Up to Down.";
    SendMessage(i,note);
    alerttime2=iTime(NULL,0,i);    
   }   
   
  } 

  if(checktime3>1)
  {  
   ma23=iMA(NULL,0,MAPeriod2,MAShift,MAMethod,MAPrice,i+2);
   if(ma21>=ma22 && ma22<=ma23)
   {
    note="MA#2 slope change from Down to Up.";
    SendMessage(i,note);
    alerttime3=iTime(NULL,0,i);     
   }
   if(ma21<=ma22 && ma22>=ma23)
   {
    note="MA#2 slope change from Up to Down.";
    SendMessage(i,note);
    alerttime3=iTime(NULL,0,i);    
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
 if (AlertEmail) SendMail("MA Cross Slope Alert!",message);
 return;
}
//+------------------------------------------------------------------+
double NormPoints(int pips)
{
 return(NormalizeDouble(pips*Point,Digits));
}
//+------------------------------------------------------------------+
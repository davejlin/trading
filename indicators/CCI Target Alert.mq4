//+----------------------------------------------------------------------+
//|                                                 CCI Target Alert.mq4 |
//|                                       Copyright © 2007, David J. Lin |
//|Alert when CCI reaches a specified target                             |
//|Written for Leo Lepore (forexleo@yahoo.com)                           |
//|                                                                      |
//|Coded by David J. Lin (dave.j.lin@sbcglobal.net)                      |
//|Evanston, IL, September 24, 2007                                      |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2007, David J. Lin"
#property link      ""
#property indicator_buffers 3
#property indicator_separate_window

extern int CCIPeriod=20;     // CCI 
extern int CCIPrice=PRICE_TYPICAL;
extern int CCITarget=150;    // CCI target to trigger alert (use positive or negative values as desired)
extern bool Confirmed=true; //true: use confirmed bar values, false: use instantaneous values
extern bool AlertEmail=true;
extern bool AlertAlarm=true;

double CCI[];
datetime alerttime;
int shift;
color CCIcolor=Red;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
//---- indicator line
 SetIndexStyle(0, DRAW_LINE, 0, 1, CCIcolor);
 SetIndexBuffer(0, CCI);
 SetIndexLabel(0, "CCI");
 string short_name = "CCI Target Alert";
 IndicatorShortName(short_name);
 if(Confirmed) shift=1;
 else shift=0;
 SetLevelValue(0,100.); 
 SetLevelValue(1,-100.);

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
 double cci1,cci2;
 int i,is,imax,counted_bars=IndicatorCounted();
 int checktime=iBarShift(NULL,0,alerttime,false);
 bool limit=true;  
//----
 if(counted_bars>0) imax=1;
 else imax=Bars;
   
 for(i=0;i<=imax;i++)
 {
  is=i+shift;
  CCI[i]=iCCI(NULL,0,CCIPeriod,CCIPrice,is);       

  if(counted_bars>0 && checktime>1 && limit)
  {
   cci1=iCCI(NULL,0,CCIPeriod,CCIPrice,is); 
   cci2=iCCI(NULL,0,CCIPeriod,CCIPrice,is+1); 
   
   if(CCITarget>0)
   {
    if(cci1>=CCITarget && cci2<=CCITarget)
    {
     SendMessage(i,"Up",cci1);
     alerttime=iTime(NULL,0,i);
     limit=false;
    }
   }
   else if(CCITarget<0) 
   {
    if(cci1<=CCITarget && cci2>=CCITarget)
    {
     SendMessage(i,"Down",cci1);
     alerttime=iTime(NULL,0,i);     
     limit=false; 
    }
   }
  }
       
 }
//----
 return(0);
}
//+------------------------------------------------------------------+
void SendMessage(int i, string bias, double v1)
{
 string td=TimeToStr(iTime(NULL,0,i),TIME_DATE|TIME_MINUTES);     
 string message=StringConcatenate(Symbol()," CCI has crossed ", bias, " at ",td,". CCI = ",v1);
 if (AlertAlarm) Alert(message);
 if (AlertEmail) SendMail("MT4 CCI Target Alert!",message);
 return;
}
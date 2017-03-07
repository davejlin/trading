//+------------------------------------------------------------------+
//|                                                   Trail Line.mq4 |
//| Trail Line                                                       |
//| written for Jason (soeasy69@rogers.com)                          |
//|                                                                  |
//| Coded by David J. Lin (dave.j.lin@sbcglobal.net)                 |
//| Evanston, IL, July 17, 2007                                      |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007 David J. Lin"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Aqua

//---- input parameters
extern int TrailPips=10;
extern int WarningPips=4;
extern int TriggerPips=1;

color LineColor=Aqua;
bool WarningAlert=false;
bool TriggerAlert=true;
bool TimeChart=true;     // true=time-based chart, false=tick-based chart (use Tick Tock)
int NTicks=1;            // number of ticks in a tick-bar, should be set to the same value as NTick in Tick Tock
datetime StartDate=D'2007.07.01 00:00';

bool Alert_US=true;
int US_Start_Hour=15;
int US_Start_Minute=0;
int US_Stop_Hour=23;
int US_Stop_Minute=59;
bool Alert_Asian=true;
int Asian_Start_Hour=0;
int Asian_Start_Minute=0;
int Asian_Stop_Hour=7;
int Asian_Stop_Minute=0;
bool Alert_Europe=true;
int Europe_Start_Hour=7;
int Europe_Start_Minute=0;
int Europe_Stop_Hour=15;
int Europe_Stop_Minute=0;

//---- sound-file names
string WarningSound="alert.wav";
string TriggerSound="TCAlert.wav";

//---- buffers
double Trail[],Bias[];
double anchor,ptrail,pwarning,ptrigger,value1,value2;
bool up;
string ciTickTock="Tick Tock";
int cnt,startbars,Nbars,tf=0,index=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
 IndicatorBuffers(2);

 string short_name="Trail Line";
 IndicatorShortName(short_name);
 SetIndexBuffer(0,Trail); 
 SetIndexStyle(0,DRAW_LINE,0,2,LineColor);
 SetIndexLabel(0,short_name);

        short_name="Bias";
 SetIndexBuffer(1,Bias); 
 SetIndexStyle(1,DRAW_NONE);
 SetIndexLabel(1,short_name); 
 
 anchor=0;
 
 Print(Symbol());
 if(Symbol()=="#EPU7" || Symbol()=="SPSEP7" || Symbol()=="S&P500")
 {
  TrailPips*=25;
  WarningPips*=25;
  TriggerPips*=25;
 }
 
 ptrail=NormDigits(TrailPips*Point);
 pwarning=NormDigits(WarningPips*Point);
 ptrigger=NormDigits(TriggerPips*Point);

 cnt=0;Nbars=1;

 startbars=iBarShift(NULL,tf,StartDate,false);

 if(TimeChart) 
 {
  value1=iClose(NULL,tf,startbars);
  Trail[startbars]=value1;  
  Bias[startbars]=1;
 }
 else 
 {
  value1=iCustom(NULL,tf,ciTickTock,NTicks,1,index);
  Trail[index]=iClose(NULL,tf,index);  
  Bias[index]=1;  
 }
 anchor=NormDigits(value1-ptrail);
 up=true; 

 return(0);
}
//+------------------------------------------------------------------+
//| Trail Line                                                       |
//+------------------------------------------------------------------+
int start()
{
 int i,j,k,startcount,cb=IndicatorCounted();
 
 if(TimeChart) // time-based bar charts
 {
  if(cb==0) startcount=startbars;
  else startcount=0;
  
  for(k=startcount;k>=index;k--)
  { 
   if(k==0)
   {
    value1=iClose(NULL,tf,k);
    value2=value1;
   }
   else
   {
    if(up) 
    {
     value1=iHigh(NULL,tf,k);
     value2=iLow(NULL,tf,k);
    }
    else  
    { 
     value1=iLow(NULL,tf,k);
     value2=iHigh(NULL,tf,k);
    }
   }
  
   TrailLine(k);
  }
 }
 else          // tick-based bar charts
 {          
  if(NTicks<0) return(0);

  if(k==0)
  {
   value1=iCustom(NULL,tf,ciTickTock,NTicks,1,index);
   value2=value1;
  }  
  else
  {
   if(up) 
   {
    value1=iCustom(NULL,tf,ciTickTock,NTicks,2,index);
    value2=iCustom(NULL,tf,ciTickTock,NTicks,3,index);
   }
   else   
   {
    value1=iCustom(NULL,tf,ciTickTock,NTicks,3,index);
    value2=iCustom(NULL,tf,ciTickTock,NTicks,2,index);
   }
  }
  
  if(Trail[index]==EMPTY_VALUE) //new bar - re-shift
  {
   for(i=1;i<=Nbars+1;i++)
   {  
    j=i-1;
    Trail[j]=Trail[i];
   }
  }
  TrailLine(index);
  cnt++;   
  if(cnt==NTicks)
  {  
   Nbars++;
   for(i=Nbars+1;i>=0;i--)
   {
    if(Trail[i]==EMPTY_VALUE) continue;
    Trail[i+1]=Trail[i];
   }
   cnt=0;
  }   
 }
 return(0);
}
//+------------------------------------------------------------------+
double NormDigits(double value)
{                            
 return(NormalizeDouble(value,Digits));
}                           
//+------------------------------------------------------------------+
void TrailLine(int a)
{
 double diff;
 if(up)
 {
  if(value2<=NormDigits(anchor-ptrigger))
  {
   anchor=NormDigits(value2+ptrail);
   up=false;
   Bias[a]=-1;
   if(TriggerAlert && a==0 && AlertTimeFilter())
   {
    Alert("SELL at: ",value2);
    PlaySound(TriggerSound);   
   }
  }
  else
  {
   diff=NormDigits(value1-anchor-ptrail);
   if(diff>=0) anchor=NormDigits(value1-ptrail);   
   Bias[a]=1;
   
   if(value2<=NormDigits(anchor+pwarning))
   {
    if(WarningAlert && a==0 && AlertTimeFilter())
    {   
     Alert("Prepare to sell!");
     PlaySound(WarningSound);   
    }
   }
  }
 }
 else
 {
  if(value2>=NormDigits(anchor+ptrigger))
  {
   anchor=NormDigits(value2-ptrail);
   up=true;
   Bias[a]=1;   
   if(TriggerAlert && a==0 && AlertTimeFilter())
   {   
    Alert("BUY at:", value2);
    PlaySound(TriggerSound);
   }
  }
  else
  {
   diff=NormDigits(anchor-value1-ptrail);
   if(diff>=0) anchor=NormDigits(value1+ptrail); 
   Bias[a]=-1;

   if(value1>=NormDigits(anchor-pwarning))
   {
    if(WarningAlert && a==0 && AlertTimeFilter())
    {   
     Alert("Prepare to buy!");
     PlaySound(WarningSound);   
    }
   }     
  }
 } 
 Trail[a]=anchor;
 return;
}
//+------------------------------------------------------------------+
bool AlertTimeFilter()
{
 int hour=Hour(),min=Minute();

 if(Alert_Asian) 
 {
  if(hour>=Asian_Start_Hour && min>=Asian_Start_Minute)
  {
   if(hour<=Asian_Stop_Hour)
   {
    if(hour<Asian_Stop_Hour) return(true);
    else if(hour==Asian_Stop_Hour && min<=Asian_Stop_Minute) return(true);
   }
  }
 }

 if(Alert_Europe) 
 {
  if(hour>=Europe_Start_Hour && min>=Europe_Start_Minute)
  {
   if(hour<=Europe_Stop_Hour)
   {
    if(hour<Europe_Stop_Hour) return(true);
    else if(hour==Europe_Stop_Hour && min<=Europe_Stop_Minute) return(true);
   }
  }
 }

 if(Alert_US) 
 {
  if(hour>=US_Start_Hour && min>=US_Start_Minute)
  {
   if(hour<=US_Stop_Hour)
   {
    if(hour<US_Stop_Hour) return(true); 
    else if(hour==US_Stop_Hour && min<=US_Stop_Minute) return(true); 
   }
  }
 }
 
 return(false);
} 



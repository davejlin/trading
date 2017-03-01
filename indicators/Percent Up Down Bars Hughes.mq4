//+----------------------------------------------------------------------+
//|                                      Percent Up Down Bars Hughes.mq4 |
//|                                                         David J. Lin |
//|Paint Percentage Up & Down Bars different colors                      |
//|for Jason Hughes jason.5.hughes@bt.com                                |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|(dave.j.lin@gmail.com)                                                |
//|Evanston, IL, February 21, 2011                                       |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2011, Jason Hughes & David J. Lin"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 4

extern bool AlertSound=true;        // true to turn on audible alert 
extern bool AlertOnce=true;         // true to sound alert only once upon qualification, false to sound alert every tick of qualifying bar
extern bool AlertCompletedBar=true; // true to sound alert on the last completed bar, false to sound alert on the most current, incompleted bar 
extern double Percentage=0.30;      // percentage from top/bottom of bar
extern color UpColor=Lime;          // color of up bar 
extern color DnColor=Red;           // color of down bar 
extern int BarWidth=3;              // width of colored bar

double b1[],b2[],b3[],b4[];
datetime timecurrent;
int alertbar;
string timename;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
 SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY,BarWidth,UpColor);
 SetIndexBuffer(0,b1);
 SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,BarWidth,UpColor);
 SetIndexBuffer(1,b2);
 SetIndexStyle(2,DRAW_HISTOGRAM,EMPTY,BarWidth,DnColor);
 SetIndexBuffer(2,b3);
 SetIndexStyle(3,DRAW_HISTOGRAM,EMPTY,BarWidth,DnColor);
 SetIndexBuffer(3,b4);

 for(int i=Bars-1;i>=0;i--) ResetBuffers(i);
 
 if(AlertCompletedBar) alertbar=1;
 else                  alertbar=0;

 timecurrent=0;

 switch(Period())
 {
  case 1: timename=" M1";
  break;
  case 5: timename=" M5";
  break;
  case 15: timename=" M15";
  break;  
  case 30: timename=" M30";
  break;  
  case 60: timename=" H1";
  break;
  case 240: timename=" H4";
  break;  
  case 1440: timename=" D1";
  break;  
  case 10080: timename=" W1";
  break;  
  default: timename=" MN";
  break;  
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
 int i,bias,imax,counted_bars=IndicatorCounted();
 if(counted_bars>0) imax=Bars-counted_bars;
 else imax=Bars-1;    

//----
 for(i=imax;i>=0;i--) 
 {
  ResetBuffers(i);
  bias=PaintBar(i);
  if(bias>0)
  {  
   b1[i] = iOpen(NULL,0,i);
   b2[i] = iClose(NULL,0,i);  
    
   alert(" Up Bar Alert!",i);
  }
  else if(bias<0)
  { 
   b3[i] = iOpen(NULL,0,i);
   b4[i] = iClose(NULL,0,i);  
    
   alert(" Down Bar Alert!",i);
  }  
 } 
//----
 return(0);
}

void ResetBuffers(int shift) 
{
 b1[shift] = EMPTY_VALUE;
 b2[shift] = EMPTY_VALUE;
 b3[shift] = EMPTY_VALUE;
 b4[shift] = EMPTY_VALUE;
 return;
}
//+------------------------------------------------------------------+
int PaintBar(int shift) 
{
 double high=iHigh(NULL,0,shift);
 double low=iLow(NULL,0,shift); 

 double open=iOpen(NULL,0,shift); 
 double close=iClose(NULL,0,shift);

 double fraction=NormDigits(Percentage*(high-low));
 double upperfraction=NormDigits(high-fraction);
 double lowerfraction=NormDigits(low+fraction);
 
 if(open<=lowerfraction&&close>=upperfraction)
 {
  if(open<close) return(1);
 } 
 else if(open>=upperfraction&&close<=lowerfraction)
 {
  if(open>close) return(-1);
 }

 return (0);
}
//+------------------------------------------------------------------+
double NormDigits(double price)
{
 return(NormalizeDouble(price,Digits));
}
//+------------------------------------------------------------------+
void alert(string message,int i)
{
 if(!AlertSound || i!=alertbar) return;
 if(AlertOnce)
 {   
  if(iTime(NULL,0,0)==timecurrent) return;
  timecurrent=iTime(NULL,0,0);
 }
 Alert(Symbol()+timename+message);
 return;
}
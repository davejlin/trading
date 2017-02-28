//+----------------------------------------------------------------------+
//|                                             MA Price Cross Alert.mq4 |
//|                                       Copyright © 2008, David J. Lin |
//|Alert when price crosses MA                                           |
//|Written for Sam Moore (skmoore@lcturbonet.com)                        |
//|                                                                      |
//|Coded by David J. Lin (dave.j.lin@sbcglobal.net)                      |
//|Evanston, IL, Ocotober 21, 2008                                       |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2008, David J. Lin"
#property link      ""
#property indicator_buffers 3
#property indicator_chart_window

extern int MAPeriod=7;
extern int MAShift=3;
extern int MAMethod=MODE_SMA;
extern int MAPrice=PRICE_WEIGHTED;
extern int MAPipsAboveBelow=10; 
extern bool AlertEnvelope=true;
extern bool AlertEmail=true;
extern bool AlertAlarm=true;

extern color color1=Blue;
extern color color2=Red;

double MA[],MAa[],MAb[];
datetime alerttime1,alerttime2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
//---- indicator line
 SetIndexStyle(0, DRAW_LINE, 0, 1, color1);
 SetIndexStyle(1, DRAW_LINE, 0, 1, color2);
 SetIndexStyle(2, DRAW_LINE, 0, 1, color2); 
 SetIndexBuffer(0, MA);
 SetIndexBuffer(1, MAa);
 SetIndexBuffer(2, MAb);
 SetIndexLabel(0, "MA");
 SetIndexLabel(1, "MAa");
 SetIndexLabel(2, "MAb");
 string short_name = "MA Price Cross Alert";
 IndicatorShortName(short_name);
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
 double ma,ma1,ma2,p;
 int i,imax,counted_bars=IndicatorCounted();
 int checktime1=iBarShift(NULL,0,alerttime1,false);
 int checktime2=iBarShift(NULL,0,alerttime2,false); 
 bool limit1=true;
 bool limit2=true;  
//----
 if(counted_bars>0) imax=1;
 else imax=Bars-1;
   
 for(i=0;i<=imax;i++)
 {
  MA[i]=iMA(NULL,0,MAPeriod,MAShift,MAMethod,MAPrice,i);
  MAa[i]=NormDigits(MA[i]+NormPoints(MAPipsAboveBelow));
  MAb[i]=NormDigits(MA[i]-NormPoints(MAPipsAboveBelow));       

  if(i==1 && counted_bars>0 && checktime1>1 && limit1)
  {
   ma=MA[i];
   ma1=MA[i+1];   
   p=iClose(NULL,0,i+1);
   if(p<=ma1 && iClose(NULL,0,i)>=ma)
   {
    SendMessage(i,"Price Crossing MA Upwards",ma,iClose(NULL,0,i));
    alerttime1=iTime(NULL,0,i);
    limit1=false;
   }
   
   p=iClose(NULL,0,i+1);
   if(p>=ma1 && iClose(NULL,0,i)<=ma)
   {
    SendMessage(i,"Price Crossing MA Downwards",ma,iClose(NULL,0,i));
    alerttime1=iTime(NULL,0,i);     
    limit1=false; 
   }
  }
  
 if(i==0 && counted_bars>0 && checktime2>1 && limit2 && AlertEnvelope)
 {
  if(iClose(NULL,0,i)>ma)
  {
   ma2=MAa[i];
   p=iClose(NULL,0,i+1);
   if(p>=ma2 && iClose(NULL,0,i)<=ma2)
   {
    SendMessage(i,"Price Crossing upper-Envelope Downwards",ma,iClose(NULL,0,i));
    alerttime2=iTime(NULL,0,i);     
    limit2=false; 
   }
  }
  else if(iClose(NULL,0,i)<ma)
  {
   ma2=MAb[i];
   p=iClose(NULL,0,i+1);
   if(p<=ma2 && iClose(NULL,0,i)>=ma2)
   {
    SendMessage(i,"Price Crossing lower-Envelope Upwards",ma,iClose(NULL,0,i));
    alerttime2=iTime(NULL,0,i);     
    limit2=false; 
   }
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
 string message=StringConcatenate(Symbol(), bias, " at ",td,". MA=",v1," Bid=",v3);
 if (AlertAlarm) Alert(message);
 if (AlertEmail) SendMail("MT4 MA Price Cross Alert!",message);
 return;
}
double NormPoints(int pips)
{
 return(NormalizeDouble(pips*Point,Digits));
}
double NormDigits(double price)
{
 return(NormalizeDouble(price,Digits));
}
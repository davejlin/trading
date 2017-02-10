//+------------------------------------------------------------------+
//|                                   2nd Skies HiLo Analyzer.mq4    |
//| 2nd Skies HiLo Analyzer                                          |
//| written for Chris Capre, 2ndSkies.com (Info@2ndSkies.com)        |
//|                                                                  |
//| Coded by David J. Lin (dave.j.lin@sbcglobal.net)                 |
//| Evanston, IL, January 18, 2010                                   |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010 Chris Capre, David J. Lin"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red

extern int Start_Hour=16;   // hours (platform time) to start daily analysis
extern int Start_Minute=5;  // minute to start daily analysis
extern int End_Hour=22;     // hours (platform time) to end daily analysis
extern int End_Minute=0;    // minute to end daily analysis

extern int Entry=30;        // pips beyond High-Low for entry price 
extern int Stop=500;        // pips stop-loss
extern int Target1=250;     // pips take-profit 1
extern int Target2=500;     // pips take-profit 2

//---- buffers
double Entry_p,Stop_p,Target1_p,Target2_p;
bool initial;
int handle;
color clrL=Blue, clrS=Red;
int   codeL=159,codeS=159;
double AUp[],ADn[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
 IndicatorBuffers(2);

 string short_name="HiLo Analyzer";
 IndicatorShortName(short_name);
 
 Entry_p  =NormPoints(Entry);
 Stop_p   =NormPoints(Stop);
 Target1_p=NormPoints(Target1);
 Target2_p=NormPoints(Target2);

 string filename=StringConcatenate("HiLo_Analysis_",Symbol(),"_",Start_Hour,"_",Start_Minute,"_",End_Hour,"_",End_Minute,".csv");
 handle=FileOpen(filename,FILE_CSV|FILE_WRITE,',');
 FileWrite(handle,"Date","Entry Long","SL Long","T1 Long","T2 Long","Entry Short","SL Short","T1 Short","T2 Short");  
 initial=false;

 SetIndexStyle(0,DRAW_ARROW,codeL,2,clrL);
 SetIndexArrow(0,codeL);
 SetIndexBuffer(0,AUp);
 SetIndexLabel(0,"Up");
 SetIndexStyle(1,DRAW_ARROW,codeS,2,clrS);
 SetIndexArrow(1,codeS);
 SetIndexBuffer(1,ADn);
 SetIndexLabel(1,"Down"); 
  
 return(0);
}
//+------------------------------------------------------------------+
//| Trail Line                                                       |
//+------------------------------------------------------------------+
int start()
{
 if(initial) return(0);
 
 int i,i1,i2,j,ihigh,ilow,span,hour,min;
 int Dbars=iBars(NULL,PERIOD_D1)-1; // in days
 datetime maxtime=iTime(NULL,0,Bars-1);
 datetime TimeD1,TimeD2;
 double high,low;
 double Entrylong, SLlong, T1long, T2long, Entryshort, SLshort, T1short, T2short;

 for(i=0;i<Dbars;i++) // in days
 { 
  TimeD1=iTime(NULL,PERIOD_D1,i);
  TimeD2=iTime(NULL,PERIOD_D1,i+1); 

  if(TimeD2<maxtime) 
  {
   LogData(i,0,0,0,0,0,0,0,0);
   break; // data exceeded or non-existant
  }
   
  i1=iBarShift(NULL,0,TimeD1,false);
  i2=iBarShift(NULL,0,TimeD2,false);
   
  int istart=-1;
  int iend=-1;
  for(j=i1;j<i2;j++)
  {
   hour=TimeHour(iTime(NULL,0,j));
   min=TimeMinute(iTime(NULL,0,j));
   if(hour==End_Hour&&min==End_Minute)     iend  =j;   
   else if(hour==Start_Hour&&min==Start_Minute) 
   {
    istart=j;
    break;
   }
  }
  
  if(istart<0||iend<0) LogData(i,0,0,0,0,0,0,0,0);
  else
  {
   span=istart-iend;
   ihigh=iHighest(NULL,0,MODE_HIGH,span,iend);
   ilow=iLowest(NULL,0,MODE_LOW,span,iend);   
   high=iHigh(NULL,0,ihigh);
   low=iLow(NULL,0,ilow);
   AUp[ihigh]=NormDigits(high+NormPoints(50));
   ADn[ilow]=NormDigits(low-NormPoints(50));
   Entrylong=NormDigits(high+Entry_p);
   SLlong=NormDigits(Entrylong-Stop_p);
   T1long=NormDigits(Entrylong+Target1_p);
   T2long=NormDigits(Entrylong+Target2_p);
   Entryshort=NormDigits(low-Entry_p);
   SLshort=NormDigits(Entryshort+Stop_p);
   T1short=NormDigits(Entryshort-Target1_p);
   T2short=NormDigits(Entryshort-Target2_p);
   LogData(i, Entrylong, SLlong, T1long, T2long, Entryshort, SLshort, T1short, T2short);
  }
 }
 
 FileClose(handle);
 initial=true;

 return(0);
}
//+------------------------------------------------------------------+
void LogData(int i,double Entrylong, double SLlong, double T1long, double T2long,double Entryshort, double SLshort, double T1short, double T2short)
{ 
 FileWrite(handle,
           TimeToStr(iTime(NULL,PERIOD_D1,i),TIME_DATE),
           DoubleToStr(Entrylong,Digits), 
           DoubleToStr(SLlong,Digits),
           DoubleToStr(T1long,Digits),
           DoubleToStr(T2long,Digits),
           DoubleToStr(Entryshort,Digits),
           DoubleToStr(SLshort,Digits),
           DoubleToStr(T1short,Digits),
           DoubleToStr(T2short,Digits));
 return;
}
//+------------------------------------------------------------------+
double NormDigits(double a)
{
 return(NormalizeDouble(a,Digits));
}
//+------------------------------------------------------------------+
double NormPoints(int pips)
{
 return(NormDigits(pips*Point));
}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                     2nd Skies Pivot Analyzer.mq4 |
//| 2nd Skies Pivot Analyzer                                         |
//| written for Chris Capre, 2ndSkies.com (Info@2ndSkies.com)        |
//|                                                                  |
//| Coded by David J. Lin (dave.j.lin@sbcglobal.net)                 |
//| Evanston, IL, July 19, 2009                                      |
//| updated July 26, 2009 w/ additional critera                      |
//| updated July 28, 2009 w/ exra criteria refinement                |
//| updated July 31, 2009 w/ time criteria statistics                |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009 David J. Lin"

#property indicator_chart_window
#property indicator_buffers 0

extern int NM2pips=60;
extern int NM3pips=90;

//---- buffers

int R1cnt,R2cnt,R3cnt,S1cnt,S2cnt,S3cnt;
int M1cnt,M4cnt,R2NMcnt,S2NMcnt,R3NMcnt,S3NMcnt;
int M1time,M4time,R2time,R3time,S2time,S3time;
int M1timecnt,M4timecnt,R2timecnt,R3timecnt,S2timecnt,S3timecnt;
double onepnts,twopnts,threepnts,NM2pnts,NM3pnts;
bool initial;
int timeanalysis=PERIOD_H1;
int maxtimebars;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
 IndicatorBuffers(0);

 string short_name="Pivot Analyzer";
 IndicatorShortName(short_name);
    
 R1cnt=0;
 R2cnt=0;
 R3cnt=0;  
 M4cnt=0;  
 S1cnt=0;
 S2cnt=0;
 S3cnt=0;
 M1cnt=0;
 R2NMcnt=0;
 R3NMcnt=0;  
 S2NMcnt=0;
 S3NMcnt=0;
 R2time=0;
 R3time=0;
 S2time=0;
 S3time=0;
 M1time=0;
 M4time=0;
 R2timecnt=0;
 R3timecnt=0;
 S2timecnt=0;
 S3timecnt=0;
 M1timecnt=0;
 M4timecnt=0; 
 
 onepnts=NormalizeDouble(1.0*Point,Digits);
 twopnts=NormalizeDouble(2.0*Point,Digits);
 threepnts=NormalizeDouble(3.0*Point,Digits);
 NM2pnts=NormalizeDouble(NM2pips*Point,Digits); 
 NM3pnts=NormalizeDouble(NM3pips*Point,Digits); 
 
 initial=false;
 
 maxtimebars=1440/timeanalysis; 
 
 return(0);
}
//+------------------------------------------------------------------+
//| Trail Line                                                       |
//+------------------------------------------------------------------+
int start()
{
 if(initial) return(0);
 
 int i,time,limit=Bars-1;
 double P,S1,R1,S2,R2,S3,R3,M1,M2,M3,M4,high,low,phigh,plow,pclose;
 
 for(i=limit;i>=0;i--)
 {
  high=iHigh(NULL,0,i);
  low =iLow(NULL,0,i);

  phigh =iHigh(NULL,0,i+1);
  plow  =iLow(NULL,0,i+1);
  pclose=iClose(NULL,0,i+1);

  P =(phigh+plow+pclose)/3.0;
  R1=(2.0*P)-plow;  
  S1=(2.0*P)-phigh;
  R2=P+(phigh-plow);
  S2=P-(phigh-plow); 
  R3=2.0*phigh-plow;
  S3=2.0*plow-phigh;   
  
  M1=0.5*(S1+S2);
  M2=0.5*(S1+P);
  M3=0.5*(P+R1);
  M4=0.5*(R1+R2);
  
  if(high>=NormDouble(R1+twopnts)) R1cnt++;
  if(high>=NormDouble(R2+twopnts)) R2cnt++;  
  if(high>=NormDouble(R3+twopnts)) R3cnt++; 
  if(high>=M4) M4cnt++;

  if(low<=NormDouble(S1-twopnts)) S1cnt++;
  if(low<=NormDouble(S2-twopnts)) S2cnt++;  
  if(low<=NormDouble(S3-twopnts)) S3cnt++;
  if(low<=M1) M1cnt++;
  
  if(high>=NormDouble(R2-NM2pnts)&&high<=NormDouble(R2+onepnts))  R2NMcnt++;
  if(high>=NormDouble(R3-NM3pnts)&&high<=NormDouble(R3+onepnts))  R3NMcnt++;

  if(low<=NormDouble(S2+NM2pnts)&&low>=NormDouble(S2-onepnts))    S2NMcnt++;
  if(low<=NormDouble(S3+NM3pnts)&&low>=NormDouble(S3-onepnts))    S3NMcnt++;

// time statistics

  if(high>=M4) 
  {
   time=TimeStats(R1,M4,iTime(NULL,0,i),true);
   if(time>=0)
   {
    M4time+=time;
    M4timecnt++;
   } 
  }
  
  if(high>=R2) 
  {
   time=TimeStats(R1,R2,iTime(NULL,0,i),true);
   if(time>=0)
   {
    R2time+=time;
    R2timecnt++;
   }
  }

  if(high>=R3) 
  {
   time=TimeStats(R1,R3,iTime(NULL,0,i),true);
   if(time>=0)
   {
    R3time+=time;
    R3timecnt++;
   }
  }
  
  if(low<=M1)  
  {
   time=TimeStats(S1,M1,iTime(NULL,0,i),false);
   if(time>=0)
   {
    M1time+=time;
    M1timecnt++;
   }
  }
  
  if(low<=S2)  
  {
   time=TimeStats(S1,S2,iTime(NULL,0,i),false);
   if(time>=0)
   {
    S2time+=time;
    S2timecnt++;
   }
  }
  
  if(low<=S3)  
  {
   time=TimeStats(S1,S3,iTime(NULL,0,i),false);
   if(time>=0)
   {
    S3time+=time;
    S3timecnt++;
   }
  } 
 }
 
 LogData();
  
 initial=true;

 return(0);
}
//+------------------------------------------------------------------+
int TimeStats(double price1, double price2, datetime DayTime, bool bias)
{
 int timeBars=iBarShift(NULL,timeanalysis,DayTime,true);

 if(timeBars<0) return(-1); // include only days with data in analysis
 
 int i,j;
 double price,open;
 
 if(bias)
 {
  for(i=timeBars;i>=timeBars-maxtimebars;i--) // should hit in 24 hours
  {

   price=iHigh(NULL,timeanalysis,i);
   open=iOpen(NULL,timeanalysis,i);   

   if(open<=NormDouble(price1+twopnts)&&price>=NormDouble(price1+twopnts))
   {
    for(j=i;j>=timeBars-maxtimebars;j--)
    {
     if(TimeHour(iTime(NULL,timeanalysis,j))>=23) return(-1); // stop at NY close based on Chris' GMT+2 Alpari platform
    
     price=iHigh(NULL,timeanalysis,j);
     open=iOpen(NULL,timeanalysis,j);    
    
     if(open>=NormDouble(price1+twopnts)&&price<=NormDouble(price1+twopnts)) break; // start clock over after re-count 
     if(open<=price2&&price>=price2) return(i-j);
    }
   }
  }
 }
 else
 {
  for(i=timeBars;i>=timeBars-maxtimebars;i--) // should hit in 24 hours
  {
  
   price=iLow(NULL,timeanalysis,i);
   open=iOpen(NULL,timeanalysis,i);  
     
   if(open>=NormDouble(price1-twopnts)&& price<=NormDouble(price1-twopnts))
   {
    for(j=i;j>=timeBars-maxtimebars;j--)
    {
     if(TimeHour(iTime(NULL,timeanalysis,j))>=23) return(-1); // stop at NY close based on Chris' GMT+2 Alpari platform
    
     price=iLow(NULL,timeanalysis,j);
     open=iOpen(NULL,timeanalysis,j);     
     
     if(open<=NormDouble(price1-twopnts)&& price>=NormDouble(price1-twopnts)) break; // start clock over after re-count   
     if(open>=price2&&price<=price2) return(i-j);
    }
   }
  }
 } 

 return(-1);
}
//+------------------------------------------------------------------+
void LogData()
{
 int bars=Bars-1;

 if(R2timecnt==0) R2timecnt=1;
 if(R3timecnt==0) R3timecnt=1;
 if(S2timecnt==0) S2timecnt=1;
 if(S3timecnt==0) S3timecnt=1;
 if(M1timecnt==0) M1timecnt=1;
 if(M4timecnt==0) M4timecnt=1;

 string timename;
 switch(Period())
 {
  case 1: timename="M1";
  break;
  case 5: timename="M5";
  break;
  case 15: timename="M15";
  break;  
  case 30: timename="M30";
  break;  
  case 60: timename="H1";
  break;
  case 240: timename="H4";
  break;  
  case 1440: timename="D1";
  break;  
  case 10080: timename="W1";
  break;  
  default: timename="MN";
  break;  
 }

 string filename=StringConcatenate("Pivot_Analysis_",Symbol(),"_",timename,".csv");
 int handle=FileOpen(filename,FILE_CSV|FILE_WRITE,','); 

 FileWrite(handle,"R1","S1","M4","M1","R2","S2","R3","S3");
 
 FileWrite(handle,DoubleToStr(R1cnt*100./bars,1),DoubleToStr(S1cnt*100./bars,1),
                  DoubleToStr(M4cnt*100./bars,1),DoubleToStr(M1cnt*100./bars,1),
                  DoubleToStr(R2cnt*100./bars,1),DoubleToStr(S2cnt*100./bars,1),
                  DoubleToStr(R3cnt*100./bars,1),DoubleToStr(S3cnt*100./bars,1)); 

 FileWrite(handle,"R2NM","S2NM","R3NM","S3NM");

 FileWrite(handle,DoubleToStr(R2NMcnt*100./bars,1),DoubleToStr(S2NMcnt*100./bars,1),
                  DoubleToStr(R3NMcnt*100./bars,1),DoubleToStr(S3NMcnt*100./bars,1));                   
                  
 FileWrite(handle,"M4t","M1t","R2t","S2t","R3t","S3t");
 FileWrite(handle,DoubleToStr(M4time*timeanalysis/M4timecnt/60.,1),DoubleToStr(M1time*timeanalysis/M1timecnt/60.,1), 
                  DoubleToStr(R2time*timeanalysis/R2timecnt/60.,1),DoubleToStr(S2time*timeanalysis/S2timecnt/60.,1),
                  DoubleToStr(R3time*timeanalysis/R3timecnt/60.,1),DoubleToStr(S3time*timeanalysis/S3timecnt/60.,1)); 

 FileWrite(handle,"Bars total");
 FileWrite(handle,DoubleToStr(bars,0));

 FileClose(handle);
 
 return;
}
//+------------------------------------------------------------------+
double NormDouble(double a)
{
 return(NormalizeDouble(a,Digits));
}
//+------------------------------------------------------------------+


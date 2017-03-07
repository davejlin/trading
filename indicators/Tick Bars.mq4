//+----------------------------------------------------------------------+
//|                                                        Tick Bars.mq4 |
//|                                                         David J. Lin |
//| Charts Ticks based upon volume bins.                                 |
//| Much,much improved efficiency version (June 30, 2008).               |
//| This version uses histogram drawing instead of objects               |
//| This version uses index j to continue updating a limited sized array.|
//| Thus, upon application, only the most recent bar needs updating, not |
//| the entire analysis period.                                          |
//|                                                                      |
//| Constant volume display in a separate window is built-in ... just    |
//| uncomment the appropriate lines, suffixed by "volume"                | 
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|dave.j.lin@sbcglobal.net                                              |
//|Evanston, IL, May 28, 2007                                            |
//+----------------------------------------------------------------------+
#property copyright "2007 David J. Lin"
#property link      ""


#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Green
#property indicator_color2 Green
#property indicator_color3 Green
#property indicator_color4 Green
#property indicator_color5 Red
#property indicator_color6 Red
#property indicator_color7 Red
#property indicator_color8 Red
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 1
#property indicator_width6 1
#property indicator_width7 2
#property indicator_width8 2

//---- input parameters
extern int VolumeBin=25;
extern datetime StartDate=D'2008.06.01 00:00:00';
int BaseBar=PERIOD_M1;
//---- buffers
double high[],low[],open[],close[],volume[];
double Hbull[],Lbull[],Obull[],Cbull[],Hbear[],Lbear[],Obear[],Cbear[];
string myName;
int j,HistoryBars,arraysize;
datetime currentTime;
bool norun=false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- indicators

  if(VolumeBin<1)
  {
   norun=true;
   Print("***WARNING: Invalid VolumeBin!!***");
   return(0);
  }   
   
  arraysize=iBarShift(NULL,BaseBar,StartDate,false);
  if (arraysize<1) 
  {
   norun=true; 
   Print("***WARNING: Invalid StartDate!!***");
   return(0);
  }
   
  arraysize *= 5; // we hope this times the shift is enough space!  should be.

  ArrayResize(high,arraysize);
  ArrayResize(low,arraysize);
  ArrayResize(open,arraysize);
  ArrayResize(close,arraysize);       
  ArrayResize(volume,arraysize);
 
  IndicatorBuffers(8);

  SetIndexBuffer(0,Hbull);  
  SetIndexStyle(0,DRAW_HISTOGRAM);
  SetIndexLabel(0, "high bull");

  SetIndexBuffer(1,Lbull);
  SetIndexStyle(1,DRAW_HISTOGRAM);
  SetIndexLabel(1, "low bull");

  SetIndexBuffer(2,Obull);
  SetIndexStyle(2,DRAW_HISTOGRAM);
  SetIndexLabel(2, "open bull");
  
  SetIndexBuffer(3,Cbull);
  SetIndexStyle(3,DRAW_HISTOGRAM);
  SetIndexLabel(3, "close bull");    

  SetIndexBuffer(4,Hbear);  
  SetIndexStyle(4,DRAW_HISTOGRAM);
  SetIndexLabel(4, "high bear");

  SetIndexBuffer(5,Lbear);
  SetIndexStyle(5,DRAW_HISTOGRAM);
  SetIndexLabel(5, "low bear");

  SetIndexBuffer(6,Obear);
  SetIndexStyle(6,DRAW_HISTOGRAM);
  SetIndexLabel(6, "open bear");
  
  SetIndexBuffer(7,Cbear);
  SetIndexStyle(7,DRAW_HISTOGRAM);
  SetIndexLabel(7, "close bear");   
          

  myName=StringConcatenate("Tick Bars (",VolumeBin,",",arraysize,")");
  IndicatorShortName(myName);  
  Comment(myName);

  FillInitialArray();
  DrawBars(2);
   
//----
return(0);
}
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function |
//+------------------------------------------------------------------+
int deinit()
{
//----
return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function |
//+------------------------------------------------------------------+
int start()
{
 if(norun) return(0);

 MonitorTicks();
 Comment(j," ",arraysize," ",j/arraysize," ",volume[j]," ",VolumeBin," ",volume[j]/VolumeBin);
// Print(volume[j]);

// more efficient: re-draw all bars only when volume exceeds binning or new time-bar.
 if(volume[j]>=VolumeBin) 
 {
  j++;

  if(j>arraysize-1)
  {
   norun=true; 
   Print("***WARNING: Array Size Exceeded!!***");
   return(0);
  }
  
  double price=iClose(NULL,0,0); // = Bid, but backtester needs this expression
    
  high[j]=price;
  low[j]=price;
  open[j]=price;
  close[j]=price;      
  volume[j]=1;   
    
  DrawBars(2); 
 }
 else if(currentTime!=iTime(NULL,0,0)) DrawBars(2);
 else DrawBars(1); // otherwise, re-draw only latest bar
  
// if(Symbol()=="EURCHFm") Print(j+" "+index+" "+volume[j]); 

 currentTime=iTime(NULL,0,0);
 
 return(0);
}
//+------------------------------------------------------------------+ 
void FillInitialArray()
{
 HistoryBars=iBarShift(NULL,BaseBar,StartDate,false);
 
 int i=HistoryBars;
   
 //---- computations for tick charting
 int limit=Bars-1;
 
 for(j=0;j<=limit;j++)
 {
  high[j]=iHigh(NULL,BaseBar,i);
  low[j]=iLow(NULL,BaseBar,i);
  if(j>0) open[j]=close[j-1];
  else    open[j]=iClose(NULL,BaseBar,i);
  close[j]=iClose(NULL,BaseBar,i);      
  volume[j]=iVolume(NULL,BaseBar,i);
 
  if(i==0) break;
 
  if(volume[j]>=VolumeBin)
  {
   i--;
   if(i==0) break;
   continue;
  }
 
  while(volume[j]<=VolumeBin)
  {
   i--; 
   if(iHigh(NULL,BaseBar,i)>high[j]) high[j]=iHigh(NULL,BaseBar,i);
   if(iLow(NULL,BaseBar,i)<low[j]) low[j]=iLow(NULL,BaseBar,i);
   close[j]=iClose(NULL,BaseBar,i);
   volume[j]+=iVolume(NULL,BaseBar,i); 
   if(i==0) break; 
  }
  if(i==0) break;    
  i--; 
 }
 
 if(j==limit+1) j--; // corrects the augmentation of j by one if it completes the entire loop (e.g. for high timeframe charts)
}
//+------------------------------------------------------------------+
void MonitorTicks()
{ 
 double price=iClose(NULL,0,0); // = Bid, but backtester needs this expression

 if(price>high[j]) high[j]=price;
 if(price<low[j])  low[j]=price;
 close[j]=price;
 volume[j]++; 
 return;
}
//+------------------------------------------------------------------+ 
void DrawBars(int flag)
{
 int i,k,start,end;

 switch(flag)
 {
  case 1: start=0;end=0;break;
  case 2: start=0;end=j;break;
  default: start=0;end=j;break;
 }

// draw tick bars 
 for(i=start,k=j;i<=end;i++,k--)
 {
  Hbull[i]=EMPTY_VALUE;
  Lbull[i]=EMPTY_VALUE;
  Obull[i]=EMPTY_VALUE;
  Cbull[i]=EMPTY_VALUE;

  Hbear[i]=EMPTY_VALUE;
  Lbear[i]=EMPTY_VALUE;
  Obear[i]=EMPTY_VALUE;
  Cbear[i]=EMPTY_VALUE;
 
  if(open[k]<close[k]) 
  {
   Hbull[i]=high[k];
   Lbull[i]=low[k];
   Obull[i]=open[k];
   Cbull[i]=close[k];
  }
  else
  {
   Hbear[i]=high[k];
   Lbear[i]=low[k];
   Obear[i]=open[k];
   Cbear[i]=close[k];     
  }
 }
 
 if(flag==2) // clear previous data due to chart shifting
 {
  Hbull[j+1]=EMPTY_VALUE;
  Lbull[j+1]=EMPTY_VALUE;
  Obull[j+1]=EMPTY_VALUE;
  Cbull[j+1]=EMPTY_VALUE;

  Hbear[j+1]=EMPTY_VALUE;
  Lbear[j+1]=EMPTY_VALUE;
  Obear[j+1]=EMPTY_VALUE;
  Cbear[j+1]=EMPTY_VALUE; 
 }
 
 return;
}
//+------------------------------------------------------------------+ 


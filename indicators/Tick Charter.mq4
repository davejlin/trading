//+----------------------------------------------------------------------+
//|                                                     Tick Charter.mq4 |
//|                                                         David J. Lin |
//| Charts Ticks based upon volume bins.                                 |
//| Much improved efficiency version (June 1, 2007).                     |
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
//#property indicator_separate_window // volume
//#property indicator_buffers 1 // volume
#property indicator_buffers 4
#property indicator_color1 Black
#property indicator_color2 Black
#property indicator_color3 Black
#property indicator_color4 Black

//---- input parameters
extern int VolumeBin=233;
datetime StartDate=D'2008.01.01 00:00:00';
int BaseBar=PERIOD_M1;
bool DrawBar=true;
bool DrawLines=true;
color BullColor=Green;
color BearColor=Red;
//---- buffers
double high[],low[],open[],close[],volume[];
double H[],L[],O[],C[];
//double volumeChart[]; // volume
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

  ArrayInitialize(high,0);
  ArrayInitialize(low,0);
  ArrayInitialize(open,0);
  ArrayInitialize(close,0);      
  ArrayInitialize(volume,0);

/*  IndicatorBuffers(1);  // volume 
  
  SetIndexStyle(0,DRAW_HISTOGRAM,0,1);
  SetIndexBuffer(0,volumeChart);
  SetIndexLabel(0, "volume");
*/
 
  IndicatorBuffers(4);

  SetIndexBuffer(0,H);  
  SetIndexStyle(0,DRAW_NONE);
  SetIndexLabel(0, "high");

  SetIndexBuffer(1,L);
  SetIndexStyle(1,DRAW_NONE);
  SetIndexLabel(1, "low");

  SetIndexBuffer(2,O);
  SetIndexStyle(2,DRAW_NONE);
  SetIndexLabel(2, "open");
  
  SetIndexBuffer(3,C);
  SetIndexStyle(3,DRAW_NONE);
  SetIndexLabel(3, "close");    
  
//  SetIndexStyle(2,DRAW_NONE);
//  SetIndexBuffer(2,high);
//  SetIndexLabel(2, "high");

//  SetIndexStyle(3,DRAW_NONE);
//  SetIndexBuffer(3,low);
//  SetIndexLabel(3, "low");   

//  SetIndexStyle(4,DRAW_NONE);
//  SetIndexBuffer(4,volume);
//  SetIndexLabel(4, "volume");        

  myName=StringConcatenate("Tick Charter (",VolumeBin,",",arraysize,")");
  IndicatorShortName(myName);  
  Comment(myName);
  
//----
return(0);
}
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function |
//+------------------------------------------------------------------+
int deinit()
{
 ObDeleteObjectsByPrefix("Tick");
//----
return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function |
//+------------------------------------------------------------------+
int start()
{
 if(norun) return(0);
 
 int counted=IndicatorCounted();

 if(counted<=0) 
 {
  FillInitialArray();
  DrawBars(2);
 }

 MonitorTicks();
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
 else if(currentTime!=Time[0]) DrawBars(2);
 else DrawBars(1); // otherwise, re-draw only latest bar
  
// if(Symbol()=="EURCHFm") Print(j+" "+index+" "+volume[j]); 

 currentTime=Time[0];
 
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
}
//+------------------------------------------------------------------+ 
void DrawBars(int flag)
{
 int i,k,start,end,window;
 datetime time1,time2;
 string barnameB,barnameH,barnameL; 

 switch(flag)
 {
  case 1: start=0;end=0;break;
  case 2: start=0;end=j;break;
  default: start=0;end=j;break;
 }
// window=WindowFind(myName);
 window=0;

// draw tick bars 
 for(i=start,k=j;i<=end;i++,k--)
 {

// volumeChart[i]=volume[k];  // volume 
  if(DrawLines)
  {
   H[i]=high[k];
   L[i]=low[k];
   O[i]=open[k];
   C[i]=close[k];
  }
 
  if(!DrawBar) continue;
  
  if(i==0)
  {
   time1=Time[0];
   time2=Time[0]+(Period()*60);
  }
  else
  {
   time1=Time[i];
   time2=Time[i-1];
  }
  
//  barname=TimeToStr(Time[k],TIME_DATE|TIME_MINUTES);
  barnameB=StringConcatenate("Tick",i);
  barnameH=StringConcatenate("Tick",i,"H");
  barnameL=StringConcatenate("Tick",i,"L");  
  
  ObjectDelete(barnameB);
  ObjectDelete(barnameH);
  ObjectDelete(barnameL);

  if(open[k]==close[k]) 
  {
   ObjectCreate(barnameB, OBJ_TREND, window, time1-Period()*60, open[k], time2, open[k]);  
   ObjectSet(barnameB, OBJPROP_RAY, false);   
  }
  else
  {
   ObjectCreate(barnameB, OBJ_TREND, window, time1, open[k], time1, close[k]);
   ObjectSet(barnameB, OBJPROP_RAY, false); 
   ObjectSet(barnameB,OBJPROP_WIDTH,3);
  }
  
  ObjectCreate(barnameH, OBJ_TREND, window, time1, open[k], time1, high[k]);  
  ObjectSet(barnameH, OBJPROP_RAY, false); 
//  ObjectSet(barnameH,OBJPROP_WIDTH,1);

  ObjectCreate(barnameL, OBJ_TREND, window, time1, open[k], time1, low[k]);  
  ObjectSet(barnameL, OBJPROP_RAY, false);   
//  ObjectSet(barnameL,OBJPROP_WIDTH,1);  
  
  if(open[k]>close[k]) 
  {
   ObjectSet(barnameB, OBJPROP_COLOR, BearColor);  
   ObjectSet(barnameH, OBJPROP_COLOR, BearColor);
   ObjectSet(barnameL, OBJPROP_COLOR, BearColor);
  }
  else 
  {
   ObjectSet(barnameB, OBJPROP_COLOR, BullColor); 
   ObjectSet(barnameH, OBJPROP_COLOR, BullColor);
   ObjectSet(barnameL, OBJPROP_COLOR, BullColor);
  } 
 }
 return;
}
//+------------------------------------------------------------------+ 
void ObDeleteObjectsByPrefix(string Prefix)
  {
   int L = StringLen(Prefix);
   int i = 0; 
   while(i < ObjectsTotal())
     {
       string ObjName = ObjectName(i);
       if(StringSubstr(ObjName, 0, L) != Prefix) 
         { 
           i++; 
           continue;
         }
       ObjectDelete(ObjName);
     }
  }


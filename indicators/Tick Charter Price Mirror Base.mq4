//+----------------------------------------------------------------------+
//|                                                     Tick Charter.mq4 |
//|                                                         David J. Lin |
//| Charts Ticks based upon volume bins                                  |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|dave.j.lin@sbcglobal.net                                              |
//|Evanston, IL, May 28, 2007                                            |
//+----------------------------------------------------------------------+
#property copyright "2007 David J. Lin"
#property link      ""

#property indicator_separate_window

//---- input parameters
extern int VolumeBin=1000;
extern int HistoryBars=500;
//---- buffers
double high[],low[],open[],close[],volume[];
string myName;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
  int arraysize=HistoryBars;
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

  IndicatorBuffers(4);
  
  SetIndexStyle(0,DRAW_NONE);
  SetIndexBuffer(0,open);
  SetIndexLabel(0, "open");

  SetIndexStyle(1,DRAW_NONE);
  SetIndexBuffer(1,close);
  SetIndexLabel(1, "close");
  
  SetIndexStyle(2,DRAW_NONE);
  SetIndexBuffer(2,high);
  SetIndexLabel(2, "high");

  SetIndexStyle(3,DRAW_NONE);
  SetIndexBuffer(3,low);
  SetIndexLabel(3, "low");      

  myName=StringConcatenate("Tick Charter (",VolumeBin,")");
  IndicatorShortName(myName);  

//----
return(0);
}
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function |
//+------------------------------------------------------------------+
int deinit()
{
//----
 ObjectsDeleteAll();
//----
return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function |
//+------------------------------------------------------------------+
int start()
{
 int i,limit,window;
 datetime time1,time2;
 string barname,barnamehigh,barnamelow;
 
 window=WindowFind(myName);
 
 int counted_bars = IndicatorCounted();
 //---- last counted bar will be recounted
 if(counted_bars>0) 
  limit=Bars-counted_bars-1;
 else limit=HistoryBars-1;
 
 //---- computations for tick charting
 for(i=limit;i>=0;i--)
 {
  high[i]   = High[i];
  low[i]    = Low[i];
  open[i]   = Open[i];
  close[i]  = Close[i];
  volume[i] = Volume[i];

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
  
  barname=TimeToStr(Time[i],TIME_DATE|TIME_MINUTES);
  barname=StringConcatenate(barname,"body");
  barnamehigh=StringConcatenate(barname,"high");
  barnamelow=StringConcatenate(barname,"low");  

  if(i==0) 
  {
   ObjectDelete(barname); 
   ObjectDelete(barnamelow);
   ObjectDelete(barnamehigh);
  }
    
  if(open[i]==close[i]) 
  {
   ObjectCreate(barname, OBJ_TREND, window, time1-Period()*60, open[i], time2, open[i]);  
   ObjectSet(barname, OBJPROP_RAY, false);   
  }
  else
  {
   ObjectCreate(barname, OBJ_RECTANGLE, window, time1, open[i], time2, close[i]);
  }
  
  ObjectCreate(barnamehigh, OBJ_TREND, window, time1, open[i], time1, high[i]);  
  ObjectSet(barnamehigh, OBJPROP_RAY, false); 

  ObjectCreate(barnamelow, OBJ_TREND, window, time1, open[i], time1, low[i]);  
  ObjectSet(barnamelow, OBJPROP_RAY, false);   
  
  if(open[i]>close[i]) 
  {
   ObjectSet(barname, OBJPROP_COLOR, Red);  
   ObjectSet(barnamehigh, OBJPROP_COLOR, Red);
   ObjectSet(barnamelow, OBJPROP_COLOR, Red);
  }
  else 
  {
   ObjectSet(barname, OBJPROP_COLOR, Green); 
   ObjectSet(barnamehigh, OBJPROP_COLOR, Green);
   ObjectSet(barnamelow, OBJPROP_COLOR, Green);
  }
 }
 return(0);
}
//+------------------------------------------------------------------+ 
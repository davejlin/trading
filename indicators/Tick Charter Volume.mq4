//+----------------------------------------------------------------------+
//|                                              Tick Charter Volume.mq4 |
//|                                                         David J. Lin |
//| Volume of Tick Charter                                               |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|dave.j.lin@sbcglobal.net                                              |
//|Evanston, IL, May 28, 2007                                            |
//+----------------------------------------------------------------------+
#property copyright "2007 David J. Lin"
#property link      ""

#property indicator_separate_window
#property indicator_color1 Green

//---- input parameters
extern int VolumeBin=133;
extern int HistoryBars=3000;
extern int BaseBar=PERIOD_M1;
//---- buffers
double volume[],volumetemp[];
string myName;
int j,index;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
       
 ArrayResize(volumetemp,HistoryBars); 
 ArrayInitialize(volumetemp,0); 
    
 IndicatorBuffers(1);
  
 SetIndexStyle(0,DRAW_HISTOGRAM,0,1);
 SetIndexBuffer(0,volume);
 SetIndexLabel(0, "volume");

 myName=StringConcatenate("Tick Charter Volume(",VolumeBin,")");
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
//----
return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function |
//+------------------------------------------------------------------+
int start()
{
 if(HistoryBars>iBars(NULL,BaseBar)) return(0);
 int i,k,limit;
 datetime time1,time2;
 string barname,barnamehigh,barnamelow;
 bool openflag=true;
  
 index=0; // first time
   
 //---- computations for tick charting
 limit=HistoryBars-1; // constantly redraw
 
 for(i=limit;i>=0;i--)
 {
  j=i+index;

  if(openflag) volumetemp[j]=iVolume(NULL,BaseBar,i);
  else volumetemp[j]+=iVolume(NULL,BaseBar,i);

  if(volumetemp[j]>VolumeBin) // draw bar and advance time index only if volume satisfies binning
  {   
   openflag=true;
   if(j==i) index=0;
  }
  else
  {
   openflag=false;
   index++; // back-pedal the time index to continue accumulating in the unfilled bin
  }
 }
 
// draw tick bars 
  
 for(i=limit;i>=j;i--)
 {
  k=i-j;
  volume[k]=volumetemp[i];
 }
 
 return(0);
}
//+------------------------------------------------------------------+ 
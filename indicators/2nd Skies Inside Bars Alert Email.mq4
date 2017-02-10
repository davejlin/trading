//+----------------------------------------------------------------------+
//|                                                      Inside_Bars.mq4 |
//|                                                         David J. Lin |
//|Paint Inside Bars a different color                                   |
//|for Chris Capre                                                       |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|(dave.j.lin@gmail)                                                    |
//|Evanston, IL, June 2, 2009                                            |
//+----------------------------------------------------------------------+
#property copyright "David J. Lin"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 4

#property indicator_color1 Red
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_color4 Red
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 3
#property indicator_width4 3

double b1[],b2[],b3[],b4[];

extern bool AlertSound=true;     // true to turn on audible alert 
extern bool AlertEmail=false;    // true to send email alert 

datetime timecurrent;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,b1);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,b2);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,b3);
 SetIndexStyle(3,DRAW_HISTOGRAM);
 SetIndexBuffer(3,b4);

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
 if(iTime(NULL,0,0)==timecurrent) return(0);
 timecurrent=iTime(NULL,0,0);

 int i,bias,imax,counted_bars=IndicatorCounted();
 if(counted_bars>0) imax=1;
 else imax=Bars-1;    
//----
 for(i=imax;i>=1;i--) 
 {
  ResetBuffers(i);
  bias=PaintBar(i);
  if(bias>0)
  {
   b1[i] = iHigh(NULL,0,i);
   b2[i] = iLow(NULL,0,i);  
   b3[i] = iOpen(NULL,0,i);
   b4[i] = iClose(NULL,0,i);  
   
   if(i>1) continue;

   string td=TimeToStr(iTime(NULL,0,i),TIME_DATE|TIME_MINUTES);    
   string message=StringConcatenate("Inside Bar Alert ",Symbol()," at ",td,"\nBid: ",DoubleToStr(Bid,Digits)," Ask: ",DoubleToStr(Ask,Digits));
  
   if(AlertSound) Alert(message);
   if(AlertEmail) SendMail("Inside Bar Alert",message);
   
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
 double high1=iHigh(NULL,0,shift);
 double low1=iLow(NULL,0,shift);
 double high2=iHigh(NULL,0,shift+1);
 double low2=iLow(NULL,0,shift+1);  
      
 if (high2>=high1 && low2<=low1) return(1);
 else                            return (0);
}
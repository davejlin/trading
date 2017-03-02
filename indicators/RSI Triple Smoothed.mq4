//+------------------------------------------------------------------+
//|                                          RSI Triple Smoothed.mq4 |
//| RSI Triple Smoothed                                                       |
//| written for Ottok (ottok@lantic.net)                             |
//|                                                                  |
//| Coded by David J. Lin (dave.j.lin@sbcglobal.net)                 |
//| Evanston, IL, July 25, 2007                                      |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007 David J. Lin"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Gray
#property indicator_color2 Blue
#property indicator_color3 Red

//---- input parameters
extern int RSIPeriod=14;
extern int EMAPeriod=3; 
extern int Shift=5;
//---- buffers
double RSI1[],RSI2[],RSI3[],RSIa[],RSIb[];
int Price=PRICE_CLOSE,tf=0,shift=0,method=MODE_EMA;
bool noRun=false;
datetime expiry=D'2007.07.31';
int init()
{
 IndicatorBuffers(5);
 SetIndexBuffer(0,RSI1);
 SetIndexStyle(0,DRAW_LINE,0,1,Gray);
 SetIndexLabel(0,"RSI");

 SetIndexEmptyValue(0,0.0); 
 SetIndexBuffer(1,RSI2);
 SetIndexStyle(1,DRAW_LINE,0,1,Blue);
 SetIndexLabel(1,"RSI smoothed");

 SetIndexEmptyValue(1,0.0);
 SetIndexBuffer(2,RSI3);
 SetIndexStyle(2,DRAW_LINE,0,1,Red);
 SetIndexLabel(2,"RSI smoothed shifted");
 
 SetIndexEmptyValue(2,0.0);  
 SetIndexBuffer(3,RSIa);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexEmptyValue(3,0.0);
 SetIndexBuffer(4,RSIb);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexEmptyValue(4,0.0);  
 
 if(Time[0]>expiry)
 {
  Alert("RSI Triple Smoothed has expired on: "+TimeToStr(expiry));
  noRun=true;
 }
 return(0);
}

int deinit()
{
 return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
 if(noRun) return(0);
 int index,i;
 int counted_bars=IndicatorCounted();
 if (counted_bars==0) index=iBars(NULL,tf)-RSIPeriod-EMAPeriod;
 else if (counted_bars>0) index=iBars(NULL,tf)-counted_bars;
      
 for(i=index;i>=0;i--)
 {  
  RSI1[i]=iRSI(NULL,tf,RSIPeriod,Price,i);
 }

 for(i=index;i>=0;i--)
 {  
  RSIa[i]=iMAOnArray(RSI1,0,EMAPeriod,shift,method,i);
 } 

 for(i=index;i>=0;i--)
 {  
  RSIb[i]=iMAOnArray(RSIa,0,EMAPeriod,shift,method,i);
 } 

 for(i=index;i>=0;i--)
 {  
  RSI2[i]=iMAOnArray(RSIb,0,EMAPeriod,shift,method,i);  
 }  

 for(i=index+Shift;i>=0;i--)
 {  
  RSI3[i-Shift]=RSI2[i];
 } 

 return(0);
}
//+------------------------------------------------------------------+
//+----------------------------------------------------------------------+
//|                                                   Pin_Bars_Capre.mq4 |
//|                                                         David J. Lin |
//|Paint Pin Bars a different color                                      |
//|for Chris Capre                                                       |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|(dave.j.lin@sbcglobal.net)                                            |
//|Evanston, IL, November 7, 2009                                        |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2009, Chris Capre & David J. Lin"
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

extern bool AlertSound=true;     // true to turn on audible alert 
extern int SwingLookbackBars=6;  // bars lookback to define swing high / swing low 
extern double BodyRatio=0.33;    // ratio of body to entire candle to qualify (e.g. if 0.33, the body must be less than 1/3 of the total candle height)
extern double BodyRegion=0.33;   // region of body to entire candle to qualify (e.g. if 0.33, body must be in upper/lower 1/3)

double b1[],b2[],b3[],b4[];
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
 timecurrent=0;
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
 if(counted_bars>0) imax=Bars-IndicatorCounted();
 else imax=Bars-1;    

//----
 for(i=imax;i>=0;i--) 
 {
  ResetBuffers(i);
  bias=PaintBar(i);
  if(bias>0)
  {
   b1[i] = iHigh(NULL,0,i);
   b2[i] = iLow(NULL,0,i);  
   b3[i] = iOpen(NULL,0,i);
   b4[i] = iClose(NULL,0,i);  
    
   if(!AlertSound || i!=1) continue;
   
   Alert("Pin Bar Aler!");
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

 double swinghigh=iHigh(NULL,0,iHighest(NULL,0,MODE_HIGH,SwingLookbackBars,shift));
 double swinglow=iLow(NULL,0,iLowest(NULL,0,MODE_LOW,SwingLookbackBars,shift));

 if(high1!=swinghigh && low1!=swinglow) return(0);  // 1

 double open1=iOpen(NULL,0,shift); 
 double close1=iClose(NULL,0,shift);
 
 double open2=iOpen(NULL,0,shift+1); 
 double close2=iClose(NULL,0,shift+1); 
 double high2=iHigh(NULL,0,shift+1);
 double low2=iLow(NULL,0,shift+1); 

 double bodyhigher1=MathMax(open1,close1);
 double bodylower1=MathMin(open1,close1);

 double bodyheight=NormDigits(bodyhigher1-bodylower1);
 double candleheight=NormDigits(high1-low1);
 
 if(bodyheight>NormDigits(BodyRatio*candleheight)) return(0);  // 2

// double bodyhigher2=MathMax(open2,close2);
// double bodylower2=MathMin(open2,close2); 

 if(bodyhigher1>high2 || bodylower1<low2) return(0); // 3

 if(high1==swinghigh)
 {
  if(bodyhigher1>NormDigits(low1+NormDigits(BodyRegion*candleheight))) return(0); // 4
  
  return(1);  
 } 
 else if(low1==swinglow)
 {
  if(bodylower1<NormDigits(high1-NormDigits(BodyRegion*candleheight))) return(0); // 4 

  return(1);
 }
        
 return (0);
}
//+------------------------------------------------------------------+
double NormDigits(double price)
{
 return(NormalizeDouble(price,Digits));
}
//+------------------------------------------------------------------+


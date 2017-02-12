//+------------------------------------------------------------------+
//|                                  AOAC (Awesome + Accelerator.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//| Modified by David J. Lin (dave.j.lin@sbcglobal.net)              |
//| to show both Awesome & Accelerator in one indicator              |
//| March 24, 2008 Monday                                            |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2005, MetaQuotes Software Corp."
#property  link      "http://www.metaquotes.net/"
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 7
#property  indicator_color1  Black
#property  indicator_color2  Blue
#property  indicator_color5  Magenta
#property  indicator_color6  Red
#property  indicator_color7  Green
//---- indicator buffers
double     ExtBuffer0[];
double     ExtBuffer1[];
double     ExtBuffer3[];
double     ExtBuffer4[];
double     ExtBuffer5[];
double     ExtBuffer6[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- 2 additional buffers are used for counting.
   IndicatorBuffers(7);
//---- drawing settings
   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_LINE);     
   SetIndexStyle(3,DRAW_NONE);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexStyle(5,DRAW_HISTOGRAM);
   SetIndexStyle(6,DRAW_HISTOGRAM);   
   IndicatorDigits(Digits+2);
   SetIndexDrawBegin(0,38);
   SetIndexDrawBegin(1,38);
   SetIndexDrawBegin(5,34);
   SetIndexDrawBegin(6,34);   
//---- 4 indicator buffers mapping
   SetIndexBuffer(0,ExtBuffer0);
   SetIndexBuffer(1,ExtBuffer1);
   SetIndexBuffer(3,ExtBuffer3);
   SetIndexBuffer(4,ExtBuffer4);
   SetIndexBuffer(5,ExtBuffer5);
   SetIndexBuffer(6,ExtBuffer6);   
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("AOAC");
   SetIndexLabel(1,"AC");
   SetIndexLabel(4,"5 SMA");   
   SetIndexLabel(5,"AO Increasing");
   SetIndexLabel(6,"AO Decreasing");   
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Accelerator/Decelerator Oscillator                               |
//+------------------------------------------------------------------+
int start()
  {
   int    limit;
   int    counted_bars=IndicatorCounted();
   double prev,current;
   //---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   //---- macd counted in the 1-st additional buffer
   for(int i=0; i<limit; i++)
      ExtBuffer3[i]=iMA(NULL,0,5,0,MODE_SMA,PRICE_MEDIAN,i)-iMA(NULL,0,34,0,MODE_SMA,PRICE_MEDIAN,i);
   //---- signal line counted in the 2-nd additional buffer
   for(i=0; i<limit; i++)
      ExtBuffer4[i]=iMAOnArray(ExtBuffer3,Bars,5,0,MODE_SMA,i);
   //---- dispatch values between 2 buffers
   bool up=true;
   for(i=limit-1; i>=0; i--)
     {
      current=ExtBuffer3[i];
      prev=ExtBuffer3[i+1];
      if(current>prev) up=true;
      if(current<prev) up=false;
      if(!up)
        {
         ExtBuffer5[i]=current;
         ExtBuffer6[i]=0.0;
        }
      else
        {
         ExtBuffer6[i]=current;
         ExtBuffer5[i]=0.0;
        }     
      
      current=ExtBuffer3[i]-ExtBuffer4[i];
      ExtBuffer1[i]=current;
      ExtBuffer0[i]=current;
     }
   //---- done
   return(0);
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                 AD Main Body.mqh |
//|                                   Copyright © 2013, David J. Lin |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, David J. Lin"
#property link      ""

//---- buffers

double ExtMapBuffer1[];

int modeHigh=0;
int modeLow=1;
int modeOpen=2;
int modeClose=3;
int modeVolume=6;

string IndexCustomIndicator="Utilities SCI Data";
//+------------------------------------------------------------------+
int init()
{
 IndicatorShortName("A/D Index");
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,ExtMapBuffer1);
 SetIndexEmptyValue(0,0.0);

 IndicatorShortName("A/D "+Identifier); 
 IndexCustomIndicator="Utilities SCI Data "+Identifier;
 return(0);
}
//+------------------------------------------------------------------+
int deinit()
{
 return (0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
{
   double high,low,open,close,volume;
   int    counted_bars=IndicatorCounted();
   int    limit;
   int    i;
   
   if(counted_bars<0) return(-1);
   if(counted_bars==0)
   {
      limit = maxBars-1;
   }
   else
   {
      counted_bars--;   
      limit = MathMax(Bars-counted_bars,2);
   }
   
   for (i=limit-1;i>=0;i--)
   {
     high  = iCustom(NULL,0,IndexCustomIndicator,20,0,40,0,modeHigh,i);
     low   = iCustom(NULL,0,IndexCustomIndicator,20,0,40,0,modeLow,i);
     open  = iCustom(NULL,0,IndexCustomIndicator,20,0,40,0,modeOpen,i);
     close = iCustom(NULL,0,IndexCustomIndicator,20,0,40,0,modeClose,i);
     volume= iCustom(NULL,0,IndexCustomIndicator,20,0,40,0,modeVolume,i);
     
     ExtMapBuffer1[i]=(close-low)-(high-close);

     if(ExtMapBuffer1[i]!=0)
     {
      double diff=high-low;
      if(0==diff)
       ExtMapBuffer1[i]=0;
      else
      {
       ExtMapBuffer1[i]/=diff;
       ExtMapBuffer1[i]*=volume;
      }
     }
     if(i<maxBars-1) ExtMapBuffer1[i]+=ExtMapBuffer1[i+1];
   }      
   return(0);
}

//+------------------------------------------------------------------+


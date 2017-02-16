//+------------------------------------------------------------------+
//|                                             Fractal Channel.mq4  |
//|                                 Copyright © 2008 David J. Lin    |
//|                                       dave.j.lin@sbcglobal.net   |
//|                                                                  |
//| modified by David J. Lin to improve efficiency for use in Apollo |
//| March 11, 2008                                                   |
//+------------------------------------------------------------------+
#property copyright "David J. Lin"
#property link      "mailto:dave.j.lin@sbcglobal.net"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue
//---- buffers
double v1[];
double v2[];
//----
double val1;
double val2;
datetime thistime;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+  
int init()
{
//---- drawing settings
 SetIndexArrow(0, 119);
 SetIndexArrow(1, 119);
//----  
 SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2);
 SetIndexDrawBegin(0, 1);
 SetIndexBuffer(0, v1);
 SetIndexLabel(0, "Resistance");  
//----
 SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 2);
 SetIndexDrawBegin(1, 1);
 SetIndexBuffer(1, v2);
 SetIndexLabel(1, "Support");
//----

 return(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start() // improves efficiency by only counting most recent fractal (the rest don't need to be changed!)
{
 if(thistime==iTime(NULL,0,0)) return(-1);
 thistime=iTime(NULL,0,0);
 
 int i,j;

 if(IndicatorCounted()==0) // establish history
 {
  for(i=Bars-1;i>=0;i--)
  {   
   val1=iFractals(NULL, 0, MODE_UPPER, i);
   if(val1 > 0) v1[i]=iHigh(NULL,0,i);
   else v1[i] = v1[i+1]; 

   val2 = iFractals(NULL, 0, MODE_LOWER, i);
   if(val2 > 0) v2[i] = iLow(NULL,0,i);
   else v2[i] = v2[i+1];
  }
 }

// forward in time from here, using backward analysis ... 

 for(i=0;i<=Bars-1;i++)
 {   
  val1 = iFractals(NULL, 0, MODE_UPPER, i);
  if(val1 > 0)
  {
   for(j=0;j<=i;j++) v1[j]=iHigh(NULL,0,i);
   break; // efficiency booster
  }
 }

 for(i=0;i<=Bars-1;i++)
 {   
  val2 = iFractals(NULL, 0, MODE_LOWER, i);
  if(val2 > 0)
  {
   for(j=0;j<=i;j++) v2[j]=iLow(NULL,0,i);
   break; // efficiency booster
  }
 } 
  
 return(0);
}
 
//+------------------------------------------------------------------+
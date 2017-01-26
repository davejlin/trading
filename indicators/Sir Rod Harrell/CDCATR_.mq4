//+------------------------------------------------------------------+
//|                                                      CDCATR%.mq4 |
//| Current Daily COMBO ATR%                                         |
//| by Sir Rod Harrell (SirRodCA@aol.com)                            |
//|                                                                  |
//| Coded by David J. Lin (dave.j.lin@sbcglobal.net)                 |
//| Evanston, IL, July 17, 2007                                      |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007 Sir Rod Harrell" // concept
#property copyright "Copyright © 2007 David J. Lin"    // indicator

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 DodgerBlue
#property indicator_color2 Red
//---- input parameters
extern int Option=1;
extern int Period1=30;
extern int Period2=20;
extern int Period3=10;
extern int Period4= 5;
extern int Period5= 4;
extern int Period6= 3;
extern int Period7= 2;
extern int Period8= 1;
extern int MaxBars=300;
//---- buffers
double Points[],Percents[];
double atr[];
int p[];
int N,tf,VolumeLimit=100;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
 string short_name;
 switch(Option)
 {
  case 1:
   N=8;
   tf=PERIOD_D1;
   ArrayResize(p,N);
   ArrayResize(atr,N);
   p[0]=Period1;p[1]=Period2;p[2]=Period3;p[3]=Period4;
   p[4]=Period5;p[5]=Period6;p[6]=Period7;p[7]=Period8;
   short_name=StringConcatenate("CDCATR% D1 (",p[0],",",p[1],","+p[2],",",p[3],",",p[4],","+p[5],",",p[6],",",p[7],")");   
  break;
  case 2:
   N=5;
   tf=PERIOD_D1;
   ArrayResize(p,N);
   ArrayResize(atr,N);
   p[0]=Period1;p[1]=Period2;p[2]=Period3;p[3]=Period4;
   p[4]=Period8;
   short_name=StringConcatenate("CDCATR% D1 (",p[0],",",p[1],","+p[2],",",p[3],",",p[4],")");      
  break;
  case 3:
   N=5;
   tf=PERIOD_D1;
   ArrayResize(p,N);
   ArrayResize(atr,N);
   p[0]=Period4;p[1]=Period5;p[2]=Period6;p[3]=Period7;
   p[4]=Period8;
   short_name=StringConcatenate("CDCATR% D1 (",p[0],",",p[1],","+p[2],",",p[3],",",p[4],")");      
   break;
  case 4:
   N=5;
   tf=PERIOD_W1;
   ArrayResize(p,N);
   ArrayResize(atr,N);
   p[0]=Period4;p[1]=Period5;p[2]=Period6;p[3]=Period7;
   p[4]=Period8;
   short_name=StringConcatenate("CDCATR% W1 (",p[0],",",p[1],","+p[2],",",p[3],",",p[4],")");      
   break; 
  default:
   N=8;
   tf=PERIOD_D1;
   ArrayResize(p,N);
   ArrayResize(atr,N);
   p[0]=Period1;p[1]=Period2;p[2]=Period3;p[3]=Period4;
   p[4]=Period5;p[5]=Period6;p[6]=Period7;p[7]=Period8;
   short_name=StringConcatenate("CDCATR% D1 (",p[0],",",p[1],","+p[2],",",p[3],",",p[4],","+p[5],",",p[6],",",p[7],")");   
  break;   
 }

 IndicatorBuffers(2);
 IndicatorShortName(short_name);

        short_name="Points";
 SetIndexBuffer(0,Points); 
 SetIndexStyle(0,DRAW_LINE);
 SetIndexLabel(0,short_name);
 
        short_name="Percents";
 SetIndexBuffer(1,Percents);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexLabel(1,short_name); 
 
 if(MaxBars>Bars-1) MaxBars=Bars-1;
 
 return(0);
}
//+------------------------------------------------------------------+
//| Average True Range w/volume considerations                       |
//+------------------------------------------------------------------+
int start()
{
 int i,j,max,shift,counted_bars=IndicatorCounted();
 double pointsumave,prevclose;

 if(counted_bars>0) max=Bars-1-counted_bars;
 else  max=MaxBars;

 for(i=0;i<=max;i++)
 {
  shift=iBarShift(NULL,tf,Time[i]);
  if(shift+1>iBars(NULL,tf)-1) continue;
  prevclose=iClose(NULL,tf,shift+1);
  for(j=0;j<N;j++) 
  {
   atr[j]=myATR(p[j],shift);
  }
  pointsumave=0;
  for(j=0;j<N;j++) pointsumave+=atr[j];
  Points[i]= pointsumave/N;
  Percents[i]=Points[i]/prevclose*100;
 }
 return(0);
}
//+------------------------------------------------------------------+
double myATR(int period, int shift)
{
 double atrvalue;
 double high,low,prevclose,range,sum=0;
 for(int i=shift;i<shift+period;i++)
 {
  if(i+1>iBars(NULL,tf)-1) continue; 
  high=iHigh(NULL,tf,i);
  low=iLow(NULL,tf,i);
  prevclose=iClose(NULL,tf,i+1);
  range=MathMax(high,prevclose)-MathMin(low,prevclose);
  if(iVolume(NULL,tf,i)>VolumeLimit) atrvalue+=range;
 }
 return(atrvalue/period);
}
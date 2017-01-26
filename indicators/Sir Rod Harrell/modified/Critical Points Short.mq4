//+------------------------------------------------------------------+
//|                                              Critical Points.mq4 |
//|                                                     David J. Lin |
//|                                                                  |
//|Coded by David J. Lin                                             |
//|dave.j.lin@sbcglobal.net                                          |
//|Evanston, IL, June 26, 2007                                       |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007 David J. Lin"
//+------------------------------------------------------------------+
//|                                              Critical Points.mq4 |
//|                                                         emsjoflo |
//|                                  automaticforex.invisionzone.com |
//+------------------------------------------------------------------+


#property copyright "emsjoflo"
#property link      "automaticforex.invisionzone.com"

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Red
//---- input parameters
extern int       MAPeriod=157;
extern int       MAType = 0;
extern int       Fib1=21;
extern int       Fib2=34;
extern int       Fib3=55;
extern int       Fib4=89;
extern int       Fib5=144;
extern int       Fib6=233;
extern int       Fib7=377;
extern int       Fib8=610;
extern color     Color1=Khaki;
extern color     Color2=LightGreen;
extern color     Color3=LightSkyBlue;
extern color     Color4=Plum;
extern color     Color5=LightSalmon;
extern color     Color6=Tomato;
extern color     Color7=Magenta;
extern color     Color8=Aqua;
double Line1,Line_1,Line2,Line_2,Line3,Line_3,Line4,Line_4,Line5,Line_5,Line6,Line_6,Line7,Line_7,Line8,Line_8,MAVal,MAValOld;

//---- buffers
double v1[],v2[],v3[],v4[],v5[],v6[],v7[],v8[];
//---- variables
int    MAMode;
string strMAType;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
IndicatorBuffers(8);
SetIndexBuffer(0,v1);
SetIndexStyle(0,DRAW_LINE,0,2,Color1);
SetIndexBuffer(1,v2);
SetIndexStyle(1,DRAW_LINE,0,2,Color2);
SetIndexBuffer(2,v3);
SetIndexStyle(2,DRAW_LINE,0,2,Color3);
SetIndexBuffer(3,v4);
SetIndexStyle(3,DRAW_LINE,0,2,Color4);
SetIndexBuffer(4,v5);
SetIndexStyle(4,DRAW_LINE,0,2,Color5);
SetIndexBuffer(5,v6);
SetIndexStyle(5,DRAW_LINE,0,2,Color6);
SetIndexBuffer(6,v7);
SetIndexStyle(6,DRAW_LINE,0,2,Color7);
SetIndexBuffer(7,v8);
SetIndexStyle(7,DRAW_LINE,0,2,Color8);
SetIndexLabel(0, "CP S1");
SetIndexLabel(1, "CP S2");
SetIndexLabel(2, "CP S3");
SetIndexLabel(3, "CP S4");
SetIndexLabel(4, "CP S5");
SetIndexLabel(5, "CP S6");
SetIndexLabel(6, "CP S7");
SetIndexLabel(7, "CP S8");
//----
switch (MAType)
   {
      case 1: strMAType="EMA"; MAMode=MODE_EMA; break;
      case 2: strMAType="SMMA"; MAMode=MODE_SMMA; break;
      case 3: strMAType="LWMA"; MAMode=MODE_LWMA; break;
      case 4: strMAType="LSMA"; break;
      default: strMAType="SMA"; MAMode=MODE_SMA; break;
   }
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

double LSMA(int Rperiod, int shift)
{
   int i;
   double sum;
   int length;
   double lengthvar;
   double tmp;
   double wt;

   length = Rperiod;
 
   sum = 0;
   for(i = length; i >= 1  ; i--)
   {
     lengthvar = length + 1;
     lengthvar /= 3;
     tmp = 0;
     tmp = ( i - lengthvar)*Close[length-i+shift];
     sum+=tmp;
    }
    wt = sum*6/(length*(length+1));
    
    return(wt);
}


//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int counted_bars = IndicatorCounted();
   //---- check for possible errors
   if (counted_bars<0) return(-1);
   //---- last counted bar will be recounted
   if (counted_bars>0) counted_bars--;
   limit = Bars - counted_bars;

   for(int i=limit; i>=0; i--)
   {
   
    if(i>Bars-MAPeriod-1) continue;
    
      if (MAType == 4)
      {
        MAVal = LSMA(MAPeriod,i);
      }
      else
      {
      
        MAVal=iMA(NULL,0,MAPeriod,0,MAMode,PRICE_CLOSE,i);
      }

   Line1=MAVal-Fib1*Point;
   Line2=MAVal-Fib2*Point;
   Line3=MAVal-Fib3*Point;
   Line4=MAVal-Fib4*Point;
   Line5=MAVal-Fib5*Point;   
   Line6=MAVal-Fib6*Point;
   Line7=MAVal-Fib7*Point;
   Line8=MAVal-Fib8*Point; 
   
  
  v1[i]=Line1;v2[i]=Line2;v3[i]=Line3;v4[i]=Line4;
  v5[i]=Line5;v6[i]=Line6;v7[i]=Line7;v8[i]=Line8;

//----
 }
 return(0);
}
  
//+------------------------------------------------------------------+
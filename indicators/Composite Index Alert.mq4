//+----------------------------------------------------------------------+
//|                                            Composite Index Alert.mq4 |
//|                                                         David J. Lin |
//| Composite Index Alert                                                |
//|                                                                      |
//| Coded for Gabriele Halstrup <gabriele.halstrup@t-online.de>          |
//| Coded by David J. Lin (dave.j.lin@gmail.com)                         |
//| Evanston, IL, July 13, 2013                                          |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gabriele Halstrup and David J. Lin"

//+----------------------------------------------------------------------------------+
//|                                                              Composite index.mq4 |
//|                                                                           mladen |
//+----------------------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Gold
#property indicator_color3 Lime

//
//
//
//
//

extern bool Alert_Toggle        = true;
extern double Alert_Limit_Upper = 100;
extern double Alert_Limit_Lower = 0;

extern int  RSI.Price       = PRICE_CLOSE;
extern int  RSI.SlowLength  = 14;
extern int  RSI.FastLength  =  3;
extern int  Momentum.Length =  9;
extern int  SMA.Length1     =  3;
extern int  SMA.Length2     = 13;
extern int  SMA.Length3     = 33;

//
//
//
//
//

double buffer1[];
double buffer2[];
double buffer3[];
double working[][3];

datetime currentTime;

//+----------------------------------------------------------------------------------+
//|                                                                                  |
//+----------------------------------------------------------------------------------+
//
//
//
//
//

int init()
{
   SetIndexBuffer(0,buffer1);
   SetIndexBuffer(1,buffer2);
   SetIndexBuffer(2,buffer3);
   
   currentTime=0;
   
   return(0);
}
int deinit()
{
   return(0);
}

//+----------------------------------------------------------------------------------+
//|                                                                                  |
//+----------------------------------------------------------------------------------+
//
//
//
//
//

#define __slowRSI 0
#define __fastRSI 1
#define __composite 2

//
//
//
//
//

int start()
{
   int counted_bars=IndicatorCounted();
   int i,r,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = Bars-counted_bars;
         if (ArrayRange(working,0) != Bars) ArrayResize(working,Bars);

   //
   //
   //
   //
   //
        
   for(i=limit, r=Bars-i-1; i >= 0; i--,r++)
   {
      working[r][__slowRSI] = iRSI(NULL,0,RSI.SlowLength,RSI.Price,i);
      working[r][__fastRSI] = iRSI(NULL,0,RSI.FastLength,RSI.Price,i);
      
         double RSIDelta = working[r][__slowRSI]-working[r-Momentum.Length][__slowRSI];
         double RSIsma   = iSma(__fastRSI,SMA.Length1,r);
         
      working[r][__composite] = RSIDelta+RSIsma;
      
      //
      //
      //
      //
      //
      
      buffer1[i] = working[r][__composite];
      buffer2[i] = iSma(__composite,SMA.Length2,r);
      buffer3[i] = iSma(__composite,SMA.Length3,r);
   }
   
   if(!Alert_Toggle || currentTime>=Time[0])
    return(0);

   checkAlert();

   return(0);
}

//+----------------------------------------------------------------------------------+
//|                                                                                  |
//+----------------------------------------------------------------------------------+
//
//
//
//
//

double iSma(int forBuffer,int period, int shift)
{
   double sum   =0;
   
   if (shift>=period)
   {
      for (int i=0; i<period; i++) sum += working[shift-i][forBuffer];
      return(sum/period);
   }
   else return(working[shift][forBuffer]);
}

void checkAlert()
{  
   if( (buffer1[1]<Alert_Limit_Upper && buffer1[0]>=Alert_Limit_Upper) ||
       (buffer1[1]>Alert_Limit_Upper && buffer1[0]<=Alert_Limit_Upper) )
   {
    Alert(Symbol()+" Composite Upper: "+" "+DoubleToStr(Alert_Limit_Upper,2)+" at "+TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES|TIME_SECONDS));
    currentTime=Time[0];
   }
   else if( (buffer1[1]>Alert_Limit_Lower && buffer1[0]<=Alert_Limit_Lower) ||
            (buffer1[1]<Alert_Limit_Lower && buffer1[0]>=Alert_Limit_Lower) )
   {
    Alert(Symbol()+" Composite Lower: "+" "+DoubleToStr(Alert_Limit_Lower,2)+" at "+TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES|TIME_SECONDS));
    currentTime=Time[0];
   }
   return;
}
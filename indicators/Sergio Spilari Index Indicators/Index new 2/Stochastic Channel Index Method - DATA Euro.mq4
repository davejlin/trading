//+----------------------------------------------------------------------+
//|                           Stochastic Channel Index Method - DATA.mq4 |
//|                                                         David J. Lin |
//| Stochastic Channel Index Method - DATA                               |
//|                                                                      |
//| Coded for Sérgio Spilari Filho <sergio@ssfconsultoriafinanceira.com> |
//| Coded by David J. Lin (dave.j.lin@gmail.com)                         |
//| Evanston, IL, May 26, 2013                                           |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2013,  Sérgio Spilari Filho and David J. Lin"

#property indicator_separate_window
#property indicator_buffers 6

extern int    ShortTermMAperiod = 20;
extern int    ShortTermMAmethod = MODE_SMA;
extern int    LongTermMAperiod  = 40;
extern int    LongTermMAmethod  = MODE_SMA;

double IndexClose[];
double IndexHigh[];
double IndexLow[];
double IndexOpen[];
double IndexMa1[];
double IndexMa2[];

int numPairs=7;
string symbols[] = {"EURUSD","EURJPY","EURGBP","EURAUD","EURCHF","EURCAD","EURNZD"};
double pows[]    = {0.100,0.100,0.100,0.100,0.100,0.100,0.100};
//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------

int init()
{
   IndicatorBuffers(6);
   SetIndexBuffer(0,IndexHigh); SetIndexLabel(0,"High"); SetIndexStyle(0,DRAW_NONE);
   SetIndexBuffer(1,IndexLow);  SetIndexLabel(1,"Low");  SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(2,IndexOpen); SetIndexLabel(2,"Open"); SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(3,IndexClose);SetIndexLabel(3,"Close");SetIndexStyle(3,DRAW_NONE);
   SetIndexBuffer(4,IndexMa1);  SetIndexLabel(4,"Ma1");  SetIndexStyle(4,DRAW_NONE);
   SetIndexBuffer(5,IndexMa2);  SetIndexLabel(5,"Ma2");  SetIndexStyle(5,DRAW_NONE);
  
   return(0);
}

int deinit()
{
}

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------

int start()
{
   int i,limit,counted_bars=IndicatorCounted();

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;

   limit=Bars-counted_bars;

   for (i=limit; i>=0; i--)
   {
      double idxClose = 50.14348112;
      double idxOpen  = 50.14348112;
      double idxHigh  = 50.14348112;
      double idxLow   = 50.14348112;

      for (int k=0; k<numPairs; k++)
      {
         int y = iBarShift(symbols[k],0,Time[i]);

            idxClose *= MathPow(iClose(symbols[k],0,y),pows[k]);
            idxOpen  *= MathPow(iOpen (symbols[k],0,y),pows[k]);
            idxHigh  *= MathPow(iHigh (symbols[k],0,y),pows[k]);
            idxLow   *= MathPow(iLow  (symbols[k],0,y),pows[k]);
      }
      IndexOpen[i]  = idxOpen;
      IndexHigh[i]  = idxHigh;
      IndexLow[i]   = idxLow;
      IndexClose[i] = idxClose;
   }
   
   for(i=limit; i>=0; i--)
   {
      IndexMa1[i] = iMAOnArray(IndexClose,0,ShortTermMAperiod,0,ShortTermMAmethod,i);
      IndexMa2[i] = iMAOnArray(IndexClose,0,LongTermMAperiod ,0,LongTermMAmethod ,i);
   }    
   return(0);
}
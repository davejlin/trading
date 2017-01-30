//+------------------------------------------------------------------+
//|                                                SCI Data Body.mq4 |
//|                                   Copyright © 2013, David J. Lin |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, David J. Lin"
#property link      ""

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

         idxClose *= indexClose(k,y);
         idxOpen  *= indexOpen(k,y);
            
         idxHigh  *= indexHigh(k,y);
         idxLow   *= indexLow(k,y);
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

double indexClose(int j, int i)
{
 return(MathPow(iClose(symbols[j],0,i),pows[j]));
}

double indexOpen(int j, int i)
{
 return(MathPow(iOpen(symbols[j],0,i),pows[j]));
}

double indexHigh(int j, int i)
{
 double pow=pows[j];
 if(pow>=0)
 {
  return (MathPow(iHigh(symbols[j],0,i),pow));
 }
 else
 {
  return (MathPow(iLow(symbols[j],0,i),pow));
 }
}

double indexLow(int j, int i)
{
 double pow=pows[j];
 if(pow>=0)
 {
  return (MathPow(iLow(symbols[j],0,i),pow));
 }
 else
 {
  return (MathPow(iHigh(symbols[j],0,i),pow));
 }
}
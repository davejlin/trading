//+----------------------------------------------------------------------+
//|                                               Fourier_Oscillator.mq4 |
//|                                                         David J. Lin |
//| Tracks slope of Fourier indicator as a function of time              |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|dave.j.lin@sbcglobal.net                                              |
//|Evanston, IL, January 1, 2007                                         |
//+----------------------------------------------------------------------+
//----------------------------------------
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow
//-------------------------------
extern int hrf = 9;
extern int hrT3 = 6;
extern int days = 1;
//-----------------------------------------
double ak[], bk[], fx[], w, ak0, ss, sc, sk, dfx[],slope[];
double pi = 3.1415926535897932384626433832795;
int    T, sm, k, pt3;
//==========================================
int init()
{
   IndicatorBuffers(4);
   SetIndexStyle(0, DRAW_LINE); 
   SetIndexBuffer(0, slope);
   SetIndexBuffer(1, fx);
   SetIndexBuffer(2, ak);
   SetIndexBuffer(3, bk);
   SetIndexLabel(0, "Fourier Slope ("+days+" days)");   
   IndicatorShortName("Fourier Oscillator ("+days+" days)");
//--------------------------
   pt3 = hrT3 * 60 / Period();
   T = days * 1440 / Period(); 
   w = 2 * pi / T;
   k = T / (hrf * 60 / Period());
   return(0);
}
//***************************************************
int start()
{
   SetIndexDrawBegin(0, T);
//-----------------
  int n, i, j, limit, NBars=1000;
//-----------------
 int counted_bars = IndicatorCounted();
 //---- last counted bar will be recounted
 if(counted_bars>0) counted_bars--;
 else counted_bars=1;
 
 limit = NBars - T - counted_bars;
 for(j=limit;j>=0;j--)
 {
   ak0 = 0.0;
   for(n = j; n <= j+k; n++)
   {
      sc = 0.0; ss = 0.0;  
      for(i = 0; i <= T - 1; i++)
      {
         if(n == 0)
            ak0 += Close[i+j]; 
         if(n != 0)
         {
            sc += Close[i+j] * MathCos(n * i * w);
            ss += Close[i+j] * MathSin(n * i * w);
         }
      }
      ak[n] = sc * 2 / T;
      bk[n] = ss * 2 / T;
   }
   ak0 = ak0 / T; 
//--------------------------
   for(i = 0; i <= T - 1; i++)
   {
      sk = 0.0;
      for(n = j+1; n <= j+k; n++)
      {
         sk = sk + ak[n] * MathCos(n * i * w) + bk[n] * MathSin(n * i * w);
      }
      fx[i] = ak0 + sk;  
   } 
//---------------------------
  slope[j]=(fx[0]-fx[1])/Period()/Point;
 }
 return(0);
}
//****************************************************
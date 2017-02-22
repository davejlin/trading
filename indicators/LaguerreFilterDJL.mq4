//+------------------------------------------------------------------+
//|                                            LaguerreFilterDJL.mq4 |
//| Modification of Moving Averages.mq4 to show Laguerre Filter      |
//+------------------------------------------------------------------+
#property copyright "David J. Lin"
#property link " "

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Yellow
#property indicator_width1 3
#property indicator_width2 3

//---- indicator parameters
extern int MA_Period=10;
int MA_Shift=0;
int MA_Method=1;
//---- indicator buffers
double ExtMapBuffer[];
//----
int ExtCountedBars=0;

//---- Laguerre input parameters
extern double    gamma      = 0.75;
int       Price_Type = 0; 
//---- Laguerre indicator buffers
double Filter[];
double L0[];
double L1[];
double L2[];
double L3[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   int    draw_begin;
   string short_name;
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexShift(0,MA_Shift);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
   if(MA_Period<2) MA_Period=13;
   draw_begin=MA_Period-1;
//---- indicator short name
   switch(MA_Method)
     {
      case 1 : short_name="EMA(";  draw_begin=0; break;
      case 2 : short_name="SMMA("; break;
      case 3 : short_name="LWMA("; break;
      default :
         MA_Method=0;
         short_name="SMA(";
     }
//   IndicatorShortName(short_name+MA_Period+")");
   SetIndexDrawBegin(0,draw_begin);
  //---- indicator buffers mapping
   SetIndexBuffer(0,ExtMapBuffer);

  //---- Laguerre indicators
   IndicatorBuffers(6);  
   SetIndexStyle(1, DRAW_LINE);
   SetIndexDrawBegin(1, 1);
	SetIndexLabel(1, "LaguerreFilter");
	SetIndexBuffer(1, Filter);
   SetIndexBuffer(2, L0);
   SetIndexBuffer(3, L1);
   SetIndexBuffer(4, L2);
   SetIndexBuffer(5, L3);

   short_name="LaguerreFilter(" + DoubleToStr(gamma, 2) + ")";
   IndicatorShortName(short_name);
   
  //---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   if(Bars<=MA_Period) return(0);
   ExtCountedBars=IndicatorCounted();
//---- check for possible errors
   if (ExtCountedBars<0) return(-1);
//---- last counted bar will be recounted
   if (ExtCountedBars>0) ExtCountedBars--;
//----
   switch(MA_Method)
     {
      case 0 : sma();  break;
      case 1 : ema();  break;
      case 2 : smma(); break;
      case 3 : lwma();
     }
     
   Laguerre();
//---- done
   return(0);
  }
  
//+------------------------------------------------------------------+
//| Laguerre Filter                                                  |
//+------------------------------------------------------------------+  

void Laguerre()
{
	int    limit;
	int    counted_bars = IndicatorCounted();
	double CU, CD;
	//---- last counted bar will be recounted
	if (counted_bars>0)
		counted_bars--;
	else
		counted_bars = 1;
	limit = Bars - counted_bars;
	//---- computations for RSI
	for (int i=limit; i>=0; i--)
	{
		double Price=iMA(NULL,0,1,0,0,Price_Type,i);
		
		L0[i] = (1.0 - gamma)*Price + gamma*L0[i+1];
		L1[i] = -gamma*L0[i] + L0[i+1] + gamma*L1[i+1];
		L2[i] = -gamma*L1[i] + L1[i+1] + gamma*L2[i+1];
		L3[i] = -gamma*L2[i] + L2[i+1] + gamma*L3[i+1];
		
		CU = 0;
		CD = 0;
		if (L0[i] >= L1[i])
			CU = L0[i] - L1[i];
		else
			CD = L1[i] - L0[i];
		if (L1[i] >= L2[i])
			CU = CU + L1[i] - L2[i];
		else
			CD = CD + L2[i] - L1[i];
		if (L2[i] >= L3[i])
			CU = CU + L2[i] - L3[i];
		else
			CD = CD + L3[i] - L2[i];

		if (CU + CD != 0)
			Filter[i] = (L0[i] + 2 * L1[i] + 2 * L2[i] + L3[i]) / 6.0;
	}
   return(0);
}
    
//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
void sma()
  {
   double sum=0;
   int    i,pos=Bars-ExtCountedBars-1;
//---- initial accumulation
   if(pos<MA_Period) pos=MA_Period;
   for(i=1;i<MA_Period;i++,pos--)
      sum+=Close[pos];
//---- main calculation loop
   while(pos>=0)
     {
      sum+=Close[pos];
      ExtMapBuffer[pos]=sum/MA_Period;
	   sum-=Close[pos+MA_Period-1];
 	   pos--;
     }
//---- zero initial bars
   if(ExtCountedBars<1)
      for(i=1;i<MA_Period;i++) ExtMapBuffer[Bars-i]=0;      
  }

//+------------------------------------------------------------------+
//| Exponential Moving Average                                       |
//+------------------------------------------------------------------+
void ema()
  {
   double pr=2.0/(MA_Period+1);
   int    pos=Bars-2;
   if(ExtCountedBars>2) pos=Bars-ExtCountedBars-1;
//---- main calculation loop
   while(pos>=0)
     {
      if(pos==Bars-2) ExtMapBuffer[pos+1]=Close[pos+1];
      ExtMapBuffer[pos]=Close[pos]*pr+ExtMapBuffer[pos+1]*(1-pr);
 	   pos--;
     }
  }
//+------------------------------------------------------------------+
//| Smoothed Moving Average                                          |
//+------------------------------------------------------------------+
void smma()
  {
   double sum=0;
   int    i,k,pos=Bars-ExtCountedBars+1;
//---- main calculation loop
   pos=Bars-MA_Period;
   if(pos>Bars-ExtCountedBars) pos=Bars-ExtCountedBars;
   while(pos>=0)
     {
      if(pos==Bars-MA_Period)
        {
         //---- initial accumulation
         for(i=0,k=pos;i<MA_Period;i++,k++)
           {
            sum+=Close[k];
            //---- zero initial bars
            ExtMapBuffer[k]=0;
           }
        }
      else sum=ExtMapBuffer[pos+1]*(MA_Period-1)+Close[pos];
      ExtMapBuffer[pos]=sum/MA_Period;
 	   pos--;
     }
  }
//+------------------------------------------------------------------+
//| Linear Weighted Moving Average                                   |
//+------------------------------------------------------------------+
void lwma()
  {
   double sum=0.0,lsum=0.0;
   double price;
   int    i,weight=0,pos=Bars-ExtCountedBars-1;
//---- initial accumulation
   if(pos<MA_Period) pos=MA_Period;
   for(i=1;i<=MA_Period;i++,pos--)
     {
      price=Close[pos];
      sum+=price*i;
      lsum+=price;
      weight+=i;
     }
//---- main calculation loop
   pos++;
   i=pos+MA_Period;
   while(pos>=0)
     {
      ExtMapBuffer[pos]=sum/weight;
      if(pos==0) break;
      pos--;
      i--;
      price=Close[pos];
      sum=sum-lsum+price*MA_Period;
      lsum-=Close[i];
      lsum+=price;
     }
//---- zero initial bars
   if(ExtCountedBars<1)
      for(i=1;i<MA_Period;i++) ExtMapBuffer[Bars-i]=0;
  }
//+------------------------------------------------------------------+


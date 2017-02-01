//+----------------------------------------------------------------------+
//|                             Stochastic Channel Index Method - MA.mq4 |
//|                                                         David J. Lin |
//| Stochastic Channel Index Method - MA                                 |
//|                                                                      |
//| Coded for Sérgio Spilari Filho <sergio@ssfconsultoriafinanceira.com> |
//| Coded by David J. Lin (dave.j.lin@gmail.com)                         |
//| Evanston, IL, May 26, 2013                                           |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2013,  Sérgio Spilari Filho and David J. Lin"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red
//---- indicator parameters
extern int MA_Period=14;
extern int MA_Shift=0;
extern int MA_Method=0;
extern int MA_Price=0;

//-- Index parameters

extern int    ShortTermMAperiod = 20;
extern int    ShortTermMAmethod = MODE_SMA;
extern int    LongTermMAperiod  = 40;
extern int    LongTermMAmethod  = MODE_SMA;

extern string IndexCustomIndicator="Utilities SCI Data Euro";

int modeHigh=0;
int modeLow=1;
int modeOpen=2;
int modeClose=3;
//---- indicator buffers
double ExtMapBuffer[];
//----
int ExtCountedBars=0;
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
   if(MA_Period<2) MA_Period=14;
   draw_begin=MA_Period-1;
//---- indicator short name
   switch(MA_Method)
     {
      case 1 : short_name="SCI EMA(";  draw_begin=0; break;
      case 2 : short_name="SCI SMMA("; break;
      case 3 : short_name="SCI LWMA("; break;
      default :
         MA_Method=0;
         short_name="SCI SMA(";
     }
   IndicatorShortName(short_name+MA_Period+")");
   SetIndexDrawBegin(0,draw_begin);
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtMapBuffer);
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
//---- done
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
      sum+=AppliedPrice(pos);
//---- main calculation loop
   while(pos>=0)
     {
      sum+=AppliedPrice(pos);
      ExtMapBuffer[pos]=sum/MA_Period;
	   sum-=AppliedPrice(pos+MA_Period-1);
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
      if(pos==Bars-2) ExtMapBuffer[pos+1]=AppliedPrice(pos+1);
      ExtMapBuffer[pos]=AppliedPrice(pos)*pr+ExtMapBuffer[pos+1]*(1-pr);
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
            sum+=AppliedPrice(k);
            //---- zero initial bars
            ExtMapBuffer[k]=0;
           }
        }
      else sum=ExtMapBuffer[pos+1]*(MA_Period-1)+AppliedPrice(pos);
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
      price=AppliedPrice(pos);
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
      price=AppliedPrice(pos);
      sum=sum-lsum+price*MA_Period;
      lsum-=AppliedPrice(i);
      lsum+=price;
     }
//---- zero initial bars
   if(ExtCountedBars<1)
      for(i=1;i<MA_Period;i++) ExtMapBuffer[Bars-i]=0;
  }
//+------------------------------------------------------------------+
double AppliedPrice(int i)
{
 double appliedPrice=0;
 double price1,price2,price3;
 switch(MA_Price)
 {
  case PRICE_CLOSE:
   appliedPrice=iCustom(NULL,0,IndexCustomIndicator,ShortTermMAperiod,ShortTermMAmethod,LongTermMAperiod,LongTermMAmethod,modeClose,i);
  break;
  case PRICE_OPEN:
   appliedPrice=iCustom(NULL,0,IndexCustomIndicator,ShortTermMAperiod,ShortTermMAmethod,LongTermMAperiod,LongTermMAmethod,modeOpen,i);
  break;
  case PRICE_HIGH:
   appliedPrice=iCustom(NULL,0,IndexCustomIndicator,ShortTermMAperiod,ShortTermMAmethod,LongTermMAperiod,LongTermMAmethod,modeHigh,i);
  break;
  case PRICE_LOW:
   appliedPrice=iCustom(NULL,0,IndexCustomIndicator,ShortTermMAperiod,ShortTermMAmethod,LongTermMAperiod,LongTermMAmethod,modeLow,i);
  break;
  case PRICE_MEDIAN:
   price1=iCustom(NULL,0,IndexCustomIndicator,ShortTermMAperiod,ShortTermMAmethod,LongTermMAperiod,LongTermMAmethod,modeHigh,i);
   price2=iCustom(NULL,0,IndexCustomIndicator,ShortTermMAperiod,ShortTermMAmethod,LongTermMAperiod,LongTermMAmethod,modeLow,i);
   appliedPrice=0.5*(price1+price2);
  break;
  case PRICE_TYPICAL:
   price1=iCustom(NULL,0,IndexCustomIndicator,ShortTermMAperiod,ShortTermMAmethod,LongTermMAperiod,LongTermMAmethod,modeHigh,i);
   price2=iCustom(NULL,0,IndexCustomIndicator,ShortTermMAperiod,ShortTermMAmethod,LongTermMAperiod,LongTermMAmethod,modeLow,i);
   price3=iCustom(NULL,0,IndexCustomIndicator,ShortTermMAperiod,ShortTermMAmethod,LongTermMAperiod,LongTermMAmethod,modeClose,i);
   appliedPrice=0.333333333*(price1+price2+price3);
  break;
  case PRICE_WEIGHTED:
   price1=iCustom(NULL,0,IndexCustomIndicator,ShortTermMAperiod,ShortTermMAmethod,LongTermMAperiod,LongTermMAmethod,modeHigh,i);
   price2=iCustom(NULL,0,IndexCustomIndicator,ShortTermMAperiod,ShortTermMAmethod,LongTermMAperiod,LongTermMAmethod,modeLow,i);
   price3=iCustom(NULL,0,IndexCustomIndicator,ShortTermMAperiod,ShortTermMAmethod,LongTermMAperiod,LongTermMAmethod,modeClose,i);
   appliedPrice=0.25*(price1+price2+price3+price3);
  break;  
  default:
   appliedPrice=iCustom(NULL,0,IndexCustomIndicator,ShortTermMAperiod,ShortTermMAmethod,LongTermMAperiod,LongTermMAmethod,modeClose,i);
  break;  
 }
 return (appliedPrice);
}
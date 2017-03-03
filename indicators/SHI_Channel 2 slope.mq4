//+------------------------------------------------------------------+
//|                                                SHI_Channel 2.mq4 |
//|                                 Copyright © 2004, Shurka & Kevin |
//|                                                                  |
//| Modified by David J. Lin (dave.j.lin@sbcglobal.net)              |
//| to register slope history & slope                                |
//| March 26, 2008 Wednesday                                         |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, David J. Lin"
#property link      ""

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color5 Red
double TL3[];
//---- input parameters
extern int       AllBars=240;
extern int       BarsForFract=0;
extern int       MaxBars=5000;
int CurrentBar=0;
double Step=0;
int B1=-1,B2=-1;
int UpDown=0;
double P1=0,P2=0,PP=0;
int AB=300,BFF=0,bff;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(1);

   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,TL3);
   SetIndexLabel(0,"TLSlope");   
  
	if ((AllBars==0) || (Bars<AllBars)) AB=Bars; else AB=AllBars; //AB-количество обсчитываемых баров
	if (BarsForFract>0) 
		BFF=BarsForFract; 
	else
	{
		switch (Period())
		{
			case 1: BFF=12; break;
			case 5: BFF=48; break;
			case 15: BFF=24; break;
			case 30: BFF=24; break;
			case 60: BFF=12; break;
			case 240: BFF=15; break;
			case 1440: BFF=10; break;
			case 10080: BFF=6; break;
			default: return(-1); break;
		}
	}
   bff=2*BFF+1;
   
   if(MaxBars>Bars||MaxBars<=0) MaxBars=Bars;
   
//----

   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
	  
//----
   return(0);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
//   if(thistime==Time[0]) return(-1);
//   thistime=Time[0];
   int i,j,limit,counted_bars=IndicatorCounted();
   double tl1a,tl1b,tl2,diff; color clr; string name; datetime time;
//---- 
   //---- last counted bar will be recounted
   if(counted_bars>0) 
   {
    counted_bars--;
    limit=Bars-counted_bars;
   }
   else 
   {
    limit=MaxBars-1-AB;
   }
   //---- macd counted in the 1-st additional buffer
   for(i=limit; i>=0; i--)
   {
	 CurrentBar=i+2;
    B1=-1; B2=-1; UpDown=0;
	 while(((B1==-1) || (B2==-1)) && (CurrentBar<i+AB))
	 {
		if((UpDown<1) && (CurrentBar==iLowest(Symbol(),Period(),MODE_LOW,bff,CurrentBar-BFF))) 
		{
			if(UpDown==0) { UpDown=-1; B1=CurrentBar; P1=Low[B1]; }
			else { B2=CurrentBar; P2=Low[B2];}
		}
		if((UpDown>-1) && (CurrentBar==iHighest(Symbol(),Period(),MODE_HIGH,bff,CurrentBar-BFF))) 
		{
			if(UpDown==0) { UpDown=1; B1=CurrentBar; P1=High[B1]; }
			else { B2=CurrentBar; P2=High[B2]; }
		}
		CurrentBar++;
  	 }
	 if((B1==-1) || (B2==-1)) {continue;}
	 Step=(P2-P1)/(B2-B1);
	 P1=P1-(B1-i)*Step; B1=i;
	
 	 P2=P1+AB*Step;
    
    diff=-NormalizeDouble(Step,Digits)/Point;
    TL3[i]=diff;
   }
   return(0);
  }
//+------------------------------------------------------------------+
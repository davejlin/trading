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

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Red
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Blue
#property indicator_color5 Red
double TL1d[],TL2d[],TL1u[],TL2u[],TL3[];
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
datetime T1,T2,thistime;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(5);
   
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexBuffer(0,TL1d);
   SetIndexLabel(0,"TL1d");
   
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexBuffer(1,TL2d);
   SetIndexLabel(1,"TL2d");   

   SetIndexStyle(2,DRAW_ARROW);
   SetIndexBuffer(2,TL1u);
   SetIndexLabel(2,"TL1u");
   
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexBuffer(3,TL2u);
   SetIndexLabel(3,"TL2u"); 

   SetIndexStyle(4,DRAW_NONE);
   SetIndexBuffer(4,TL3);
   SetIndexLabel(4,"TLSlope");   
  
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
			default: DelObj(); return(-1); break;
		}
	}
   bff=2*BFF+1;
   
   if(MaxBars>Bars||MaxBars<=0) MaxBars=Bars;

   SetIndexDrawBegin(3,AB);
   
//----

   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
	ObjectDelete("TL1");
	ObjectDelete("TL2");
	ObjectDelete("MIDL"); 

 int objtotal=ObjectsTotal()-1; string name;int i,pos;
 double price;

 for(i=objtotal;i>=0;i--) 
 {
  name=ObjectName(i);
  
  pos=StringFind(name,"tl");
  if(pos>=0) ObjectDelete(name);   
 }
	  
//----
   return(0);
  }

void DelObj()
{
	ObjectDelete("TL1");
	ObjectDelete("TL2");
	ObjectDelete("MIDL");
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
//   if(thistime==Time[0]) return(-1);
//   thistime=Time[0];
   int i,j,limit,counted_bars=IndicatorCounted();
   double tl1,tl2,diff; color clr; string name; datetime time;
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
	 if((B1==-1) || (B2==-1)) {DelObj(); continue;}
	 Step=(P2-P1)/(B2-B1);
	 P1=P1-(B1-i)*Step; B1=i;
	
	 if(UpDown==1)
	 { 
		PP=Low[i+2]-2*Step;
		for(j=i+3;j<=B2;j++) 
		{
			if(Low[j]<PP+Step*(j-i)) { PP=Low[j]-(j-i)*Step; }
		}
	 } 
	 else
	 { 
		PP=High[i+2]-2*Step;
		for(j=i+3;j<=B2;j++) 
		{
			if(High[j]>PP+Step*(j-i)) { PP=High[j]-(j-i)*Step;}
		}
	}

 	 P2=P1+AB*Step;
	 T1=Time[B1]; T2=Time[i+AB];

	 DelObj();
	 ObjectCreate("TL1",OBJ_TREND,0,T2,PP+Step*AB,T1,PP); 
		ObjectSet("TL1",OBJPROP_COLOR,Lime); 
		ObjectSet("TL1",OBJPROP_WIDTH,2); 
		ObjectSet("TL1",OBJPROP_STYLE,STYLE_SOLID); 
    ObjectCreate("TL2",OBJ_TREND,0,T2,P2,T1,P1); 
		ObjectSet("TL2",OBJPROP_COLOR,Lime); 
		ObjectSet("TL2",OBJPROP_WIDTH,2); 
		ObjectSet("TL2",OBJPROP_STYLE,STYLE_SOLID); 
	 ObjectCreate("MIDL",OBJ_TREND,0,T2,0.5*(P2+PP+Step*AB),T1,0.5*(P1+PP));
		ObjectSet("MIDL",OBJPROP_COLOR,Lime); 
		ObjectSet("MIDL",OBJPROP_WIDTH,1); 
		ObjectSet("MIDL",OBJPROP_STYLE,STYLE_DOT); 

    tl1=ObjectGetValueByShift("TL1",i);
    tl2 =ObjectGetValueByShift("TL2",i);
    
    diff=-NormalizeDouble(Step,Digits)/Point;
    TL3[i]=diff;

    if(diff>=0)
    {
     TL1u[i]=tl1;		
     TL2u[i]=tl2;
     TL1d[i]=EMPTY_VALUE;		
     TL2d[i]=EMPTY_VALUE;     
    }
    else
    {
     TL1d[i]=tl1;		
     TL2d[i]=tl2;
     TL1u[i]=EMPTY_VALUE;		
     TL2u[i]=EMPTY_VALUE;     
    }    
    
/*   
    if(diff>0) clr=Blue;
    else       clr=Red;  

    time=Time[i];
    name=StringConcatenate("tl1",TimeToStr(time,TIME_DATE|TIME_MINUTES));
    ObjectDelete(name);
	 ObjectCreate(name,OBJ_ARROW,0,time,tl1a); 
		ObjectSet(name,OBJPROP_COLOR,clr); 
		ObjectSet(name,OBJPROP_WIDTH,2); 
		ObjectSet(name,OBJPROP_ARROWCODE,158); 
		
    name=StringConcatenate("tl2",TimeToStr(time,TIME_DATE|TIME_MINUTES));
    ObjectDelete(name);	 	
    ObjectCreate(name,OBJ_ARROW,0,time,tl2); 
		ObjectSet(name,OBJPROP_COLOR,clr); 
		ObjectSet(name,OBJPROP_WIDTH,2); 
		ObjectSet(name,OBJPROP_ARROWCODE,158); 
*/
//----
   }
   return(0);
  }
//+------------------------------------------------------------------+
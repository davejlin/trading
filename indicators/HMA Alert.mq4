//+----------------------------------------------------------------------+
//|                                                        HMA Alert.mq4 |
//|                                       Copyright © 2010, David J. Lin |
//|HMA Alert Indicator                                                   |
//|Written for Don Learish <DBL10S@aol.com> &                            |
//|Elizabeth Mackert <blackridge5626@msn.com>                            |
//|                                                                      |
//|Coded by David J. Lin (dave.j.lin@sbcglobal.net)                      |
//|Evanston, IL, April 2, 2010                                           |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2010, David J. Lin"
#property indicator_chart_window
#property indicator_buffers 4

extern int AlertMode=1;
extern bool AlertFirstTime=true;
extern int MAPeriod=5;
extern int MAShift=0;
extern int MAMethod=MODE_SMMA;
extern color MAColor=Lime;
extern int HMA1Period=5; 
extern int HMA1Shift=0;
extern int HMA1Method=MODE_LWMA; 
extern int HMA1Price=PRICE_CLOSE;
extern color HMA1Color=Red;
extern int HMA2Period=10; 
extern int HMA2Shift=0;
extern int HMA2Method=MODE_LWMA; 
extern int HMA2Price=PRICE_CLOSE;
extern color HMA2Color=Blue;

int HMA1Period_half,HMA2Period_half;
int MA1Price=PRICE_HIGH;
int MA2Price=PRICE_LOW;
double HMA1[],HMA2[],MAH[],MAL[];
datetime alerttime;
bool AlertEmail=true;
bool AlertAlarm=true;
int init()
{
//---- indicators
//---- indicator line
 SetIndexStyle(0,DRAW_LINE,0,1,MAColor);
 SetIndexBuffer(0,MAH);
 SetIndexLabel(0, "MA High");
 SetIndexStyle(1,DRAW_LINE,0,1,MAColor);
 SetIndexBuffer(1,MAL);
 SetIndexLabel(1, "MA Low"); 
 SetIndexStyle(2,DRAW_LINE,0,1,HMA1Color);
 SetIndexBuffer(2,HMA1);
 SetIndexLabel(2,"HMA1"); 
 SetIndexStyle(3,DRAW_LINE,0,1,HMA2Color);
 SetIndexBuffer(3,HMA2);
 SetIndexLabel(3,"HMA2"); 
 string ind_name="HMA Alert";
 IndicatorShortName(ind_name);
 HMA1Period_half=HMA1Period/2;
 HMA2Period_half=HMA2Period/2; 
//----
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
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
 double h1[],h2[];
 int i,imax,counted_bars=IndicatorCounted();
 int HMA1psqrt=MathSqrt(HMA1Period),HMA2psqrt=MathSqrt(HMA2Period);

//----
 imax=MathMin(Bars-1,Bars-(counted_bars-HMA1Period-1));    
 ArrayResize(h1,imax); ArraySetAsSeries(h1, true);
 for(i=imax;i>=0;i--) h1[i]=2.0*f(i,HMA1Period_half,HMA1Shift,HMA1Method,HMA1Price)-f(i,HMA1Period,HMA1Shift,HMA1Method,HMA1Price);        
 for(i=imax-HMA1Period;i>=0;i--) {HMA1[i]=EMPTY_VALUE;HMA1[i]=iMAOnArray(h1,0,HMA1psqrt,HMA1Shift,HMA1Method,i);}

 imax=MathMin(Bars-1,Bars-(counted_bars-HMA2Period-1));    
 ArrayResize(h2,imax); ArraySetAsSeries(h2, true);
 for(i=imax;i>=0;i--) h2[i]=2.0*f(i,HMA2Period_half,HMA2Shift,HMA2Method,HMA2Price)-f(i,HMA2Period,HMA2Shift,HMA2Method,HMA2Price);        
 for(i=imax-HMA2Period;i>=0;i--) {HMA2[i]=EMPTY_VALUE;HMA2[i]=iMAOnArray(h2,0,HMA2psqrt,HMA2Shift,HMA2Method,i);}

 if(counted_bars>0) counted_bars--;
 imax=Bars-counted_bars;   
 for(i=imax;i>=0;i--){MAH[i]=EMPTY_VALUE;MAH[i]=iMA(NULL,0,MAPeriod,MAShift,MAMethod,MA1Price,i);MAL[i]=EMPTY_VALUE;MAL[i]=iMA(NULL,0,MAPeriod,MAShift,MAMethod,MA2Price,i);}
  
 int checktime=iBarShift(NULL,0,alerttime,false); 
 if(checktime>1)
 {
  i=1;double mah,mal,hm1,hm2;mah=MAH[i];mal=MAL[i];hm1=HMA1[i];hm2=HMA2[i];
  
  if(AlertMode==1)
  {
   if(AlertFirstTime)
   {
    double hm1ipo=HMA1[i+1],mahipo=MAH[i+1],malipo=MAL[i+1];
    if(hm1ipo<mahipo&&hm1>mah) 
    { 
     SendMessage(i,"Hull1 Above H5s");
     alerttime=iTime(NULL,0,i);    
    }
    else if(hm1ipo>malipo&&hm1<mal)
    { 
     SendMessage(i,"Hull2 Below H5s");
     alerttime=iTime(NULL,0,i);    
    }    
   }
   else
   {
    if(hm1>mah) 
    { 
     SendMessage(i,"Hull1 Above H5s");
     alerttime=iTime(NULL,0,i);    
    }
    else if(hm1<mal)
    { 
     SendMessage(i,"Hull2 Below H5s");
     alerttime=iTime(NULL,0,i);    
    }    
   }
  }
  else
  {
   if(hm1>mah&&hm2>mah) 
   { 
    SendMessage(i,"Hull1&2 Above H5s");
    alerttime=iTime(NULL,0,i);    
   }   
   else if(hm1<mal&&hm2<mal) 
   { 
    SendMessage(i,"Hull1&2 Below H5s");
    alerttime=iTime(NULL,0,i);    
   }       
  } 
 }
//----
 return(0);
}
double f(int i,int p,int s,int m,int pr) 
{ 
 return(iMA(NULL,0,p,s,m,pr,i));    
} 
//+------------------------------------------------------------------+
void SendMessage(int i, string note)
{
 string td=TimeToStr(iTime(NULL,0,i),TIME_DATE|TIME_MINUTES);     
 string message=StringConcatenate(Symbol()," ",Period()," ",note," at ",td);
 if (AlertAlarm) Alert(message);
 if (AlertEmail) SendMail("MA Close Alert!",message);
 return;
}
//+------------------------------------------------------------------+


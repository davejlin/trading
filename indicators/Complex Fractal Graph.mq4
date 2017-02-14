//+----------------------------------------------------------------------+
//|                                            Complex Fractal Graph.mq4 |
//|                                                         David J. Lin |
//| Complex Fractal Graph                                                |
//| Graphs buy/sell zone boxes based on Complex Fractal criteria         |
//| written for John Stathers <stathersj@hotmail.com>                    |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|dave.j.lin@sbcglobal.net                                              |
//|Evanston, IL, July 30, 2009                                           |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2009 John Stathers & David J. Lin"

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Red
#property indicator_color5 Blue
#property indicator_color6 Red
//#property indicator_maximum 1
//#property indicator_minimum -1

//---- user adjustable parameters
extern double RetracePercent=0.50;   // percentage retracement to define box
extern bool ShowDetails=true;        // true = show details (MA, arrows, fractal lines, buy/sell zones), false = hide details (only show buy/sell zones)
extern double StopLevel=0.25;        // > 1 : pips; < 1 : % of fractal range

extern int MAperiod1=5;
extern int MAperiod2=10;
extern int MAshift1=0;
extern int MAshift2=0;
extern int MAmethod1=MODE_SMA;
extern int MAmethod2=MODE_SMA;
extern int MAprice1=PRICE_CLOSE;
extern int MAprice2=PRICE_CLOSE;
extern int MACDfast=12;
extern int MACDslow=26;
extern int MACDsignal=9;
extern int MACDprice=PRICE_CLOSE;
extern int RSIperiod=14; 
extern int RSIprice=PRICE_CLOSE;
//---- buffers
double MA1[],MA2[],FUp[],FDn[],AUp[],ADn[],Bias[],LastChangeTime[];
//---- internal variables
datetime thistime;
color clrL=Blue, clrS=Red;
color clrBoxL=RoyalBlue, clrBoxS=Red, clrStop=Lime;
int   codeL=233,codeS=234;
int offset=5,nexttime;
bool initial=true;
string objName="CFG";
string objstopName="CFGstop";
//----
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+  
int init()
{
 if(ShowDetails)
 {
  SetIndexStyle(0,DRAW_ARROW,codeL,2,clrL);
  SetIndexArrow(0,codeL);
  SetIndexBuffer(0,AUp);
  SetIndexLabel(0,"Up");
  SetIndexStyle(1,DRAW_ARROW,codeS,2,clrS);
  SetIndexArrow(1,codeS);
  SetIndexBuffer(1,ADn);
  SetIndexLabel(1,"Down");
  SetIndexStyle(2,DRAW_LINE);
  SetIndexBuffer(2,MA1);
  SetIndexLabel(2,"MA1");
  SetIndexStyle(3,DRAW_LINE);
  SetIndexBuffer(3,MA2);
  SetIndexLabel(3,"MA2");
  SetIndexStyle(4,DRAW_LINE);
  SetIndexBuffer(4,FUp);
  SetIndexLabel(4,"FUp");
  SetIndexStyle(5,DRAW_LINE);
  SetIndexBuffer(5,FDn);
  SetIndexLabel(5,"FDn");
 }
 else
 {
  SetIndexStyle(0,DRAW_NONE);
  SetIndexArrow(0,codeL);
  SetIndexBuffer(0,AUp);
  SetIndexLabel(0,"Up");
  SetIndexStyle(1,DRAW_NONE);
  SetIndexArrow(1,codeS);
  SetIndexBuffer(1,ADn);
  SetIndexLabel(1,"Down");
  SetIndexStyle(2,DRAW_NONE);
  SetIndexBuffer(2,MA1);
  SetIndexLabel(2,"MA1");
  SetIndexStyle(3,DRAW_NONE);
  SetIndexBuffer(3,MA2);
  SetIndexLabel(3,"MA2");
  SetIndexStyle(4,DRAW_NONE);
  SetIndexBuffer(4,FUp);
  SetIndexLabel(4,"FUp");
  SetIndexStyle(5,DRAW_NONE);
  SetIndexBuffer(5,FDn);
  SetIndexLabel(5,"FDn"); 
 }

 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,Bias);
 SetIndexLabel(6,"Bias");

 SetIndexStyle(7,DRAW_NONE);
 SetIndexBuffer(7,LastChangeTime);
 SetIndexLabel(7,"LastChangeTime");
 
 initial=true;
 nexttime=Period()*60; // use this to extend buy/sell zone 1 bar into future from most current bar
                       // (iTime(NULL,0,-1) gives 0, so need to manually calculate the correct time of the future bar)
 return(0);
}
//+------------------------------------------------------------------+
int deinit()
{
 DeleteAll();
 return(0);
}  
//+------------------------------------------------------------------+
int start()
{  
 if(thistime==iTime(NULL,0,0)) return(0);
 thistime=iTime(NULL,0,0);
 
 ResetAll();
 
 int i,imax,counted=IndicatorCounted();
 double FRange,val,macdf,macds,rsi,price1,price2; string name;
 datetime time1,time2;
 
// must forego efficiency for accuracy ... due to the repainting nature of the fractal indicator 

 for(i=Bars-1;i>=0;i--)
 {   
// Fractal Channel 
  val=fractals(i,true);
  if(val>0) FUp[i]=iHigh(NULL,0,i); 
  else      FUp[i]=FUp[i+1]; 
  
  val=fractals(i,false);
  if(val>0) FDn[i]=iLow(NULL,0,i);
  else      FDn[i]=FDn[i+1];
   
// MAs
  MA1[i]=iMA(NULL,0,MAperiod1,MAshift1,MAmethod1,MAprice1,i);
  MA2[i]=iMA(NULL,0,MAperiod2,MAshift2,MAmethod2,MAprice2,i);
// MACD
  macdf=iMACD(NULL,0,MACDfast,MACDslow,MACDsignal,MACDprice,MODE_MAIN,i);
  macds=iMACD(NULL,0,MACDfast,MACDslow,MACDsignal,MACDprice,MODE_SIGNAL,i);
// RSI
  rsi=iRSI(NULL,0,RSIperiod,RSIprice,i);
 
  if(MA1[i]>MA2[i] && macdf>macds && rsi>50. && Bias[i+1]<=0) 
  {
   AUp[i]=NormDigits(iLow(NULL,0,i)-NormPoints(offset));
   LastChangeTime[i]=iTime(NULL,0,i);   
   Bias[i]=1;   

   FRange=NormDigits(FUp[i]-FDn[i]);
  
   time1=iTime(NULL,0,i);
   time2=iTime(NULL,0,i)+nexttime;
   
   price1=FDn[i];
   price2=NormDigits(FUp[i]-RetracePercent*FRange);
   DrawBox(price1, price2, time1, time2, clrBoxL);  
   DrawStopLines(price1,time1,time2,FRange,true); 
  }
  else if(MA1[i]<MA2[i] && macdf<macds && rsi<50. && Bias[i+1]>=0) 
  {
   ADn[i]=NormDigits(iHigh(NULL,0,i)+NormPoints(offset));
   LastChangeTime[i]=iTime(NULL,0,i);
   Bias[i]=-1;   

   FRange=NormDigits(FUp[i]-FDn[i]);  
   time1=iTime(NULL,0,i);
   time2=iTime(NULL,0,i)+nexttime;
   
   price1=FUp[i];
   price2=NormDigits(FDn[i]+RetracePercent*FRange);   
   DrawBox(price1, price2, time1, time2, clrBoxS);  
   DrawStopLines(price1,time1,time2,FRange,false);    
  }
  else 
  {
   Bias[i]=Bias[i+1]; // no change in bias
   LastChangeTime[i]=LastChangeTime[i+1];  
   UpdateBox(i);
  }
 }
 return(0);
}
//+------------------------------------------------------------------+
int fractals(int i, bool toggle)
{
 if(toggle)
 {
  if(iHigh(NULL,0,i)>=iHigh(NULL,0,i+1)&&iHigh(NULL,0,i)>=iHigh(NULL,0,i-1)
  && iHigh(NULL,0,i)>=iHigh(NULL,0,i+2)&&iHigh(NULL,0,i)>=iHigh(NULL,0,i-2))
   return(1);
 }
 else
 {
  if(iLow(NULL,0,i)<=iLow(NULL,0,i+1)&&iLow(NULL,0,i)<=iLow(NULL,0,i-1)
  && iLow(NULL,0,i)<=iLow(NULL,0,i+2)&&iLow(NULL,0,i)<=iLow(NULL,0,i-2))
   return(1);
 } 
 return(-1);
}

//+------------------------------------------------------------------+
void UpdateBox(int i)
{
 if(LastChangeTime[i]<=0) return;

 datetime time1,time2; 
 double price,price1,price2,FRange;
 string name; 
 
 if(FUp[i]==FUp[i+1] && FDn[i]==FDn[i+1]) // no change in fractal range
 {
  name=StringConcatenate(objName,TimeToStr(LastChangeTime[i])); 
  ObjectSet(name,OBJPROP_TIME2,iTime(NULL,0,i)+nexttime);

  name=StringConcatenate(objstopName,TimeToStr(LastChangeTime[i]));
  ObjectSet(name,OBJPROP_TIME2,iTime(NULL,0,i)+nexttime);
  return;
 }
 else // fractal range has changed
 {
  if(Bias[i]>0) // long conditions
  {
   FRange=NormDigits(FUp[i]-FDn[i]);
     
   LastChangeTime[i]=iTime(NULL,0,i);   
   time1=iTime(NULL,0,i);
   time2=iTime(NULL,0,i)+nexttime;   
   
   name=StringConcatenate(objName,TimeToStr(LastChangeTime[i]));   
   price1=FDn[i];
   price2=NormDigits(FUp[i]-RetracePercent*FRange);
   DrawBox(price1, price2, time1, time2, clrBoxL);        
   DrawStopLines(price1,time1,time2,FRange,true);    
  }
  else if(Bias[i]<0) // short conditions
  {
   FRange=NormDigits(FUp[i]-FDn[i]);
     
   LastChangeTime[i]=iTime(NULL,0,i);
   time1=iTime(NULL,0,i);
   time2=iTime(NULL,0,i)+nexttime;   
   
   name=StringConcatenate(objName,TimeToStr(LastChangeTime[i]));    
   price1=FUp[i];
   price2=NormDigits(FDn[i]+RetracePercent*FRange);
   DrawBox(price1, price2, time1, time2, clrBoxS);
   DrawStopLines(price1,time1,time2,FRange,false);    
  }
 }
 
 return;
}
//+------------------------------------------------------------------+
void DrawBox(double price1, double price2, datetime time1, datetime time2, color clr)
{
 string name=StringConcatenate(objName,TimeToStr(time1));
 ObjectDelete(name);
 if(!ObjectCreate(name,OBJ_RECTANGLE,0,time1,price1,time2,price2))
 {
//  Print("Error Object Create: ",GetLastError());
 }
 ObjectSet(name,OBJPROP_COLOR,clr);
 return;
}
//+------------------------------------------------------------------+
void DrawStopLines(double price1, datetime time1, datetime time2, double FRange, bool toggle)
{
 double price;
 
 if(StopLevel>=1)
 {
  if(toggle) price=NormDigits(price1-NormPoints(StopLevel));
  else       price=NormDigits(price1+NormPoints(StopLevel));
 }
 else
 {
  if(toggle) price=NormDigits(price1-StopLevel*FRange);
  else       price=NormDigits(price1+StopLevel*FRange); 
 }

 string name=StringConcatenate(objstopName,TimeToStr(time1));
 ObjectDelete(name);
 if(!ObjectCreate(name,OBJ_TREND,0,time1,price,time2,price))
 {
//  Print("Error Object Create: ",GetLastError());
 }
 ObjectSet(name,OBJPROP_RAY,false);
 ObjectSet(name,OBJPROP_COLOR,clrStop);
 ObjectSet(name,OBJPROP_WIDTH,2);
 
 return;
}
//+------------------------------------------------------------------+
void ResetAll()
{
 ArrayInitialize(FUp,EMPTY_VALUE);
 ArrayInitialize(FDn,EMPTY_VALUE);
 ArrayInitialize(AUp,EMPTY_VALUE);
 ArrayInitialize(ADn,EMPTY_VALUE);
 ArrayInitialize(Bias,EMPTY_VALUE); 
 ArrayInitialize(LastChangeTime,EMPTY_VALUE); 
 DeleteAll();
 return;
}
//+------------------------------------------------------------------+
void DeleteAll()
{
 int objtotal=ObjectsTotal()-1; string name;int i,pos;

 for(i=objtotal;i>=0;i--) 
 {
  name=ObjectName(i);
  
  pos=StringFind(name,objName);
  if(pos>=0) ObjectDelete(name);
 }
 return;
}
//+------------------------------------------------------------------+
double NormDigits(double price)
{
 return(NormalizeDouble(price,Digits));
}
//+------------------------------------------------------------------+
double NormPoints(double price)
{
 return(NormDigits(price*Point));
}
//+------------------------------------------------------------------+


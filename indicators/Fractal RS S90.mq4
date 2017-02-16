//+----------------------------------------------------------------------+
//|                                                   Fractal RS S90.mq4 |
//|                                                         David J. Lin |
//| Fractal RS (Fractal Resistance & Support) S90                        |
//| using open & close w/ pip's difference instead of breach             |
//| written for geneva wheeless (gkw1018@yahoo.com)                      |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|dave.j.lin@sbcglobal.net                                              |
//|Evanston, IL, April 15, 2008                                           |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2008 David J. Lin"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color3 Red
#property indicator_color4 Blue

extern datetime StartDate=D'2008.04.01';
extern bool TrackingLines=false;

//---- buffers
double v0[],v1[],v2[],v3[];
double UnusedUpF[][2],UnusedDnF[][2];
int UnusedUpFN,UnusedDnFN;
double LineRes[][2],LineSup[][2];
int LineResN,LineSupN;
color colorSupport=Blue;
color colorResistance=Red;
int shift,thistime;
string stringSupport="FS S90",stringResistance="FR S90";
string stringHSupport="HS S90",stringHResistance="HR S90"; // historical lines
double lastSupport,lastResistance;
//----
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+  
int init()
{
 string pd;
 switch(Period())
 {
  case 1:     pd="M1 ";break;
  case 5:     pd="M5 ";break;
  case 15:    pd="M15 ";break;
  case 30:    pd="M30 ";break;
  case 60:    pd="H1 ";break;
  case 240:   pd="H4 ";break;
  case 1440:  pd="D1 ";break;
  case 10080: pd="W1 ";break;
  case 40320: pd="M1 ";break;
  default:    pd=StringConcatenate(DoubleToStr(Period(),0)," ");break;
 }
 stringSupport=StringConcatenate(pd,stringSupport);
 stringResistance=StringConcatenate(pd,stringResistance);
 stringHSupport=StringConcatenate(pd,stringHSupport);
 stringHResistance=StringConcatenate(pd,stringHResistance);

 IndicatorBuffers(4);
 
 SetIndexStyle(0, DRAW_NONE);
 SetIndexBuffer(0, v0);
 SetIndexLabel(0, "Fractal R S90");  

 SetIndexStyle(1, DRAW_NONE);
 SetIndexBuffer(1, v1);
 SetIndexLabel(1, "Fractal S S90");

 if(TrackingLines)
 {
  SetIndexStyle(2, DRAW_LINE, STYLE_DOT, 1, colorSupport);
  SetIndexBuffer(2, v2);
  SetIndexLabel(2, "Support S90");  

  SetIndexStyle(3, DRAW_LINE, STYLE_DOT, 1, colorResistance);
  SetIndexBuffer(3, v3);
  SetIndexLabel(3, "Resistance S90");
 }
 else
 {
  SetIndexStyle(2, DRAW_NONE);
  SetIndexBuffer(2, v2);
  SetIndexLabel(2, "Support S90");  

  SetIndexStyle(3, DRAW_NONE);
  SetIndexBuffer(3, v3);
  SetIndexLabel(3, "Resistance S90"); 
 }

 shift=iBarShift(NULL,0,StartDate,false);   
 if(shift>Bars) shift=Bars; 

 lastSupport=EMPTY_VALUE;lastResistance=EMPTY_VALUE; // avoid marking the same fractal after violation

 UnusedUpFN=0;
 UnusedDnFN=0;
 LineSupN=0;
 LineResN=0;
 
 return(0);
}
//+------------------------------------------------------------------+
int deinit()
{
 int objtotal=ObjectsTotal()-1; string name;int i,pos,time1,time2;
 double price;

 for(i=objtotal;i>=0;i--) 
 {
  name=ObjectName(i);
  
  pos=StringFind(name,stringResistance);
  if(pos>=0) ObjectDelete(name);

  pos=StringFind(name,stringSupport);
  if(pos>=0) ObjectDelete(name);

  pos=StringFind(name,stringHSupport);
  if(pos>=0) ObjectDelete(name);
  
  pos=StringFind(name,stringHResistance);
  if(pos>=0) ObjectDelete(name);    
   
 }
 return(0);
}  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
{ 
 if(thistime==iTime(NULL,0,0)) return(0);
 thistime=iTime(NULL,0,0);
  
 double Fup,Fdn,close,open,low,high,price,nextprice;
 int i,k,imax,time1,time2,newN,counted=IndicatorCounted();
 if(counted>0) imax=Bars-(counted+1);
 else imax=shift-2;

 for(i=imax;i>=1;i--)
 {   
  Fup=iFractals(NULL,0,MODE_UPPER,i+2);
  if(Fup>0) 
  {
   v0[i]=iHigh(NULL,0,i+2);
   lastResistance=EMPTY_VALUE; // refresh for a new fractal
   AddFractal(true,v0[i],iTime(NULL,0,i+2));
  }
  else 
  {
   v0[i]=v0[i+1];
  }
  
  Fdn=iFractals(NULL,0,MODE_LOWER,i+2);
  if(Fdn>0) 
  { 
   v1[i] = iLow(NULL,0,i+2);
   lastSupport=EMPTY_VALUE; // refresh for a new fractal
   AddFractal(false,v1[i],iTime(NULL,0,i+2));
  }
  else 
  {
   v1[i]=v1[i+1];
  }
     
  close=NormDigits(iClose(NULL,0,i));
  open =NormDigits(iOpen(NULL,0,i));
  low  =NormDigits(iLow(NULL,0,i));
  high =NormDigits(iHigh(NULL,0,i));

  newN=0;
  for(k=UnusedDnFN-1;k>=0;k--)
  {
   price=NormDigits(UnusedDnF[k,0]);
   
   if(close>price) break;
 
   if(close<price && open<price)
   {
    v2[i]=price;
    time1=UnusedDnF[k,1];
    time2=iTime(NULL,0,1);
    DrawLine(price,time1,time2,stringResistance,colorResistance);
    AddRSValue(false,price,time1);
    newN++;
   }
  }

  if(newN!=0)
  {
   UnusedDnFN-=newN;
   ArrayResize(UnusedDnF,UnusedDnFN);
  }

  newN=0;
  for(k=LineResN-1;k>=0;k--)
  {
   price=LineRes[k,0];
   if(close<price) break;
   if(close>price && open>price)
   {   
    DeleteLine(i,price,stringResistance,false);
    newN++;
   }
  }

  if(newN!=0)
  {
   LineResN-=newN;
   ArrayResize(LineRes,LineResN);
  }
  
  newN=0;
  for(k=UnusedUpFN-1;k>=0;k--)
  {
   price=NormDigits(UnusedUpF[k,0]);
   
   if(close<price) break;
 
   if(close>price && open>price)
   {
    v3[i]=price;
    time1=UnusedUpF[k,1];
    time2=iTime(NULL,0,1);
    DrawLine(price,time1,time2,stringSupport,colorSupport);
    AddRSValue(true,price,time1);
    newN++;
   }
  }

  if(newN!=0)
  {
   UnusedUpFN-=newN;
   ArrayResize(UnusedUpF,UnusedUpFN);
  }

  newN=0;
  for(k=LineSupN-1;k>=0;k--)
  {
   price=LineSup[k,0];
   if(close>price) break;
   if(close<price && open<price)
   {   
    DeleteLine(i,price,stringSupport,true);
    newN++;
   }
  }

  if(newN!=0)
  {
   LineSupN-=newN;
   ArrayResize(LineSup,LineSupN);
  }
  
 } 
 UpdateLines();
 return(0);
}
 
//+------------------------------------------------------------------+
double NormDigits(double price)
{
 return(NormalizeDouble(price,Digits));
}
//+------------------------------------------------------------------+
void DrawLine(double price, int time1, int time2, string str, color clr)
{
 string name=StringConcatenate(str,TimeToStr(time1));
 if(!ObjectCreate(name,OBJ_TREND,0,time1,price,time2,price))
 {
  Print("Error Object Create: ",GetLastError());
 }
 ObjectSet(name,OBJPROP_RAY,false);
 ObjectSet(name,OBJPROP_COLOR,clr);
 ObjectSet(name,OBJPROP_WIDTH,1);
 return;
}
//+------------------------------------------------------------------+
void DeleteLine(int index, double price, string str, bool bias)
{
 int objtotal=ObjectsTotal()-1; 
 string name;int i,pos,time1,time2;double price1;

 if(bias)
 {
  for(i=objtotal;i>=0;i--) // support lines
  {
   name=ObjectName(i);
   pos=StringFind(name,str);
   if(pos<0) continue;
   price1=ObjectGet(name,OBJPROP_PRICE1);
   if(price==price1) 
   {
    time1=ObjectGet(name,OBJPROP_TIME1);
    time2=iTime(NULL,0,index);
    ObjectDelete(name);
    DrawLine(price1,time1,time2,stringHSupport,colorSupport);
    return;
   }
  }
 }
 else
 {
  for(i=objtotal;i>=0;i--) // resistance lines
  {
   name=ObjectName(i);
   pos=StringFind(name,str);
   if(pos<0) continue;
   price1=ObjectGet(name,OBJPROP_PRICE1);
   if(price==price1) 
   {
    time1=ObjectGet(name,OBJPROP_TIME1);
    time2=iTime(NULL,0,index);    
    ObjectDelete(name);    
    DrawLine(price1,time1,time2,stringHResistance,colorResistance); 
    return;
   }
  } 
 }
 return;
}

//+------------------------------------------------------------------+
void UpdateLines()
{
 int objtotal=ObjectsTotal()-1,pos1,pos2; string name;

 for(int i=objtotal;i>=0;i--) 
 {
  name=ObjectName(i);  
  pos1=StringFind(name,stringSupport);
  pos2=StringFind(name,stringResistance);
  
  if(pos1>=0 || pos2>=0)
  {
   ObjectSet(ObjectName(i),OBJPROP_TIME2,iTime(NULL,0,1));
  }
  
 }
 return;
}
//+------------------------------------------------------------------+
void AddFractal(bool flag, double price, datetime time)
{
 if(flag)
 {
  UnusedUpFN++;
  ArrayResize(UnusedUpF,UnusedUpFN);
  UnusedUpF[UnusedUpFN-1,0]=NormDigits(price);
  UnusedUpF[UnusedUpFN-1,1]=time;  
  ArraySort(UnusedUpF,WHOLE_ARRAY,0,MODE_DESCEND);
 }
 else
 {
  UnusedDnFN++;
  ArrayResize(UnusedDnF,UnusedDnFN);
  UnusedDnF[UnusedDnFN-1,0]=NormDigits(price);
  UnusedDnF[UnusedDnFN-1,1]=time; 
  ArraySort(UnusedDnF,WHOLE_ARRAY,0,MODE_ASCEND);   
 }
 return;
}
//+------------------------------------------------------------------+
void AddRSValue(bool flag, double price, datetime time)
{
 if(flag)
 {
  LineSupN++;
  ArrayResize(LineSup,LineSupN);
  LineSup[LineSupN-1,0]=NormDigits(price);
  LineSup[LineSupN-1,1]=time;  
  ArraySort(LineSup,WHOLE_ARRAY,0,MODE_ASCEND);
 }
 else
 {
  LineResN++;
  ArrayResize(LineRes,LineResN);
  LineRes[LineResN-1,0]=NormDigits(price);
  LineRes[LineResN-1,1]=time; 
  ArraySort(LineRes,WHOLE_ARRAY,0,MODE_DESCEND);   
 }
 return;
}
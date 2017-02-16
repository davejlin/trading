//+----------------------------------------------------------------------+
//|                                                       Fractal RS.mq4 |
//|                                                         David J. Lin |
//| Fractal RS (Fractal Resistance & Support)                            |
//| written for geneva wheeless (gkw1018@yahoo.com)                      |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|dave.j.lin@sbcglobal.net                                              |
//|Evanston, IL, July 30-August 6, 2007                                  |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2007 David J. Lin"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color3 Lime
#property indicator_color4 Magenta

extern datetime StartDate=D'2007.09.01';
extern bool TrackingLines=true;

//---- buffers
double v0[],v1[],v2[],v3[];
color colorSupport=Lime;
color colorResistance=Magenta;
int shift,thistime;
string stringSupport="FS ",stringResistance="FR ";
string stringHSupport="HS ",stringHResistance="HR "; // historical lines
double lastSupport,lastResistance;
//----
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+  
int init()
{
 IndicatorBuffers(4);
 
 SetIndexStyle(0, DRAW_NONE);
 SetIndexBuffer(0, v0);
 SetIndexLabel(0, "Fractal R");  

 SetIndexStyle(1, DRAW_NONE);
 SetIndexBuffer(1, v1);
 SetIndexLabel(1, "Fractal S");

 if(TrackingLines)
 {
  SetIndexStyle(2, DRAW_LINE, STYLE_DOT, 1, colorSupport);
  SetIndexBuffer(2, v2);
  SetIndexLabel(2, "Support");  

  SetIndexStyle(3, DRAW_LINE, STYLE_DOT, 1, colorResistance);
  SetIndexBuffer(3, v3);
  SetIndexLabel(3, "Resistance");
 }
 else
 {
  SetIndexStyle(2, DRAW_NONE);
  SetIndexBuffer(2, v2);
  SetIndexLabel(2, "Support");  

  SetIndexStyle(3, DRAW_NONE);
  SetIndexBuffer(3, v3);
  SetIndexLabel(3, "Resistance"); 
 }

 shift=iBarShift(NULL,0,StartDate,false);   
 if(shift>Bars) shift=Bars; 

 lastSupport=EMPTY_VALUE;lastResistance=EMPTY_VALUE; // avoid marking the same fractal after violation
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
  
 double Fup,Fdn,Res,Sup,close,open,low,high,price,nextprice;
 bool newR,newS;
 int i,iup,idn,k,imax,time1,time2,counted=IndicatorCounted();
 if(counted>0) imax=1;
 else imax=shift-2;

 for(i=imax;i>=1;i--)
 {   
  Fup=iFractals(NULL,0,MODE_UPPER,i+3);
  if(Fup>0) 
  {
   v0[i]=iHigh(NULL,0,i+3);
   lastResistance=EMPTY_VALUE; // refresh for a new fractal
   iup=i+3;
  }
  else 
  {
   v0[i]=v0[i+1];
  }
  
  Fdn=iFractals(NULL,0,MODE_LOWER,i+3);
  if(Fdn>0) 
  { 
   v1[i] = iLow(NULL,0,i+3);
   lastSupport=EMPTY_VALUE; // refresh for a new fractal
   idn=i+3;
  }
  else 
  {
   v1[i]=v1[i+1];
  }
     
  close=NormDigits(iClose(NULL,0,i));
  open =NormDigits(iOpen(NULL,0,i));
  low  =NormDigits(iLow(NULL,0,i));
  high =NormDigits(iHigh(NULL,0,i));

  Res=NormDigits(v0[i]);
  Sup=NormDigits(v1[i]);
 
  newS=false;
  if(Sup!=EMPTY_VALUE && Sup!=lastSupport) 
  {
   if(close<Sup && open<Sup)
   {
    if(i==1) idn=FindLastFractal(false);
    v2[i]=NormDigits(Sup);
    time1=iTime(NULL,0,idn);
    time2=iTime(NULL,0,1);
    if(v2[i]!=v2[i+1]) 
    {
     DrawLine(Sup,time1,time2,stringResistance,colorSupport);
     newS=true;
    }
   }
  }

  if(!newS)
  {
   price=NormDigits(v2[i+1]);
   if(price!=EMPTY_VALUE)
   {
    if(high>=price)
    {   
     DeleteLine(i,price,stringResistance,true);
     lastSupport=price;  // avoid marking the same fractal after violation

     for(k=0;k<100;k++) // get rid of multiple violations/bar 
     {
      nextprice=FindLast(true);
      if(high>=nextprice)
      {
       DeleteLine(i,nextprice,stringResistance,true);
       lastSupport=price; // avoid marking the same fractal after violation
      } 
      else
      {
       v2[i]=nextprice;
       break;
      }
      
     }
    }
    else v2[i]=v2[i+1];   
   }
  }
 
  newR=false;
  if(Res!=EMPTY_VALUE && Res!=lastResistance) 
  {
   if(close>Res && open>Res)
   {
    if(i==1) iup=FindLastFractal(true);   
    v3[i]=NormDigits(Res);
    time1=iTime(NULL,0,iup);
    time2=iTime(NULL,0,1);  
    if(v3[i]!=v3[i+1])
    {
     DrawLine(Res,time1,time2,stringSupport,colorResistance);
     newR=true;
    }
   } 
  }

  if(!newR)
  {
   price=NormDigits(v3[i+1]);  
   if(price!=EMPTY_VALUE)
   {  
    if(low<=price)
    {
     DeleteLine(i,price,stringSupport,false);
     lastResistance=price;  // avoid marking the same fractal after violation
     
     for(k=0;k<100;k++) // get rid of multiple violations/bar 
     {
      nextprice=FindLast(false);
      if(low<=nextprice)
      {
       DeleteLine(i,nextprice,stringSupport,false);
       lastResistance=price; // avoid marking the same fractal after violation
      } 
      else
      {
       v3[i]=nextprice;
       break;
      }
      
     }
    }
    else v3[i]=v3[i+1];   
   }
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
 ObjectSet(name,OBJPROP_WIDTH,2);
 return;
}
//+------------------------------------------------------------------+
void DeleteLine(int index, double price, string str, bool bias)
{
 int objtotal=ObjectsTotal()-1; 
 string name;int i,pos,time1,time2;double price1;

 if(bias)
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
    DrawLine(price1,time1,time2,stringHSupport,colorSupport);
    return;
   }
  }
 }
 else
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
double FindLast(bool flag)
{
 int i,objtotal=ObjectsTotal()-1,pos; string name; double price,keepprice;

 if(flag) // resistance ... seeking next lowest
 {
  keepprice=9999999;
  for(i=objtotal;i>=0;i--) 
  {
   name=ObjectName(i);  
   pos=StringFind(name,stringResistance);
   if(pos>=0) keepprice=MathMin(ObjectGet(name,OBJPROP_PRICE1),keepprice); 
  }
  if(keepprice==9999999) keepprice=EMPTY_VALUE;
 }
 else // support ... seeking next highest
 {
  keepprice=0;
  for(i=objtotal;i>=0;i--) 
  {
   name=ObjectName(i);  
   pos=StringFind(name,stringSupport);
   if(pos>=0) keepprice=MathMax(ObjectGet(name,OBJPROP_PRICE1),keepprice); 
  } 
  if(keepprice==0) keepprice=EMPTY_VALUE;
 }
 return(NormDigits(keepprice));
}
//+------------------------------------------------------------------+
int FindLastFractal(bool flag)
{
 int i;
 if(flag)
 {
  for(i=3;i<=1000;i++)
  {
   if(iFractals(NULL,0,MODE_UPPER,i)>0) return(i);
  }
 }
 else
 {
  for(i=3;i<=1000;i++)
  {
   if(iFractals(NULL,0,MODE_LOWER,i)>0) return(i);
  } 
 }
 return(0);
}
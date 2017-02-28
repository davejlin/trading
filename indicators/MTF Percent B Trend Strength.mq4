//+----------------------------------------------------------------------+
//|                                     MTF Percent B Trend Strength.mq4 |
//|                                                         David J. Lin |
//| MTF Percent B Trend Strength                                         |
//| written for Suresh Sundaram (sureshst_31@yahoo.com)                  |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|dave.j.lin@sbcglobal.net                                              |
//|Evanston, IL, September 11, 2007                                      |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2007 Suresh Sundaram & David J. Lin"

#property indicator_separate_window
#property indicator_maximum 5
#property indicator_minimum 0
//---- user adjustable parameters

extern int TF1_BBPeriod=20;
extern int TF1_Shift=0;
extern double TF1_StdDeviation=2.0;
extern int cShift1=1;

extern int TF2_BBPeriod=20;
extern int TF2_Shift=0;
extern double TF2_StdDeviation=2.0;
extern int cShift2=1;

extern int TF3_BBPeriod=20;
extern int TF3_Shift=0;
extern double TF3_StdDeviation=2.0;
extern int cShift3=1;

extern int TF4_BBPeriod=20;
extern int TF4_Shift=0;
extern double TF4_StdDeviation=2.0;
extern int cShift4=1;

extern int TF1=PERIOD_D1;
extern int TF2=PERIOD_H4;
extern int TF3=PERIOD_H1;
extern int TF4=PERIOD_M30;

extern double level1=0.20;
extern double level2=0.50;
extern double level3=0.80;

extern int MaxBars=1000;  // (use negative number for all bars)

extern int BB_Price=PRICE_CLOSE;

datetime ExpirationDate=D'2020.12.31'; // EA does not function after this date 
int AccNumber=-1;                      // EA functions only for this account number (set to negative number if this filter is not desired)
bool DemoOnly=false;                   // if set to true, EA functions only in demo accounts 

//---- buffers
double BBPeriod[4],Shift[4],StdDeviation[4],TimeFrame[4];
int cShift[4];
//---- internal variables
int lookback,thistime,TF;
color clru1=LightBlue,clru2=Aqua,clru3=MediumBlue,clru4=LawnGreen;
color clrd1=Red,clrd2=Magenta,clrd3=Orange,clrd4=Yellow;
color clrNULL=White,textcolor=Red;
string strpBTS="pBTS";
int codewd=110,window,UseBars;
string ciBands="Bands";
string windowname,timelabel1,timelabel2,timelabel3,timelabel4;
//----
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+  
int init()
{ 
 TF=MathMin(TF1,TF2); TF=MathMin(TF,TF3); TF=MathMin(TF,TF4); 
 if(TF!=Period()) TF=MathMin(TF,Period());

 int tfmax=MathMax(TF1,TF2);tfmax=MathMax(tfmax,TF3);tfmax=MathMax(tfmax,TF4);
 if(tfmax!=Period()) tfmax=MathMax(tfmax,Period());
 
 lookback=tfmax/TF;
 
 TimeFrame[0]=TF4;TimeFrame[1]=TF3;TimeFrame[2]=TF2;TimeFrame[3]=TF1;
 BBPeriod[0]=TF4_BBPeriod;BBPeriod[1]=TF3_BBPeriod;BBPeriod[2]=TF2_BBPeriod;BBPeriod[3]=TF1_BBPeriod;
 Shift[0]=TF4_Shift;Shift[1]=TF3_Shift;Shift[2]=TF2_Shift;Shift[3]=TF1_Shift; 
 StdDeviation[0]=TF4_StdDeviation;StdDeviation[1]=TF3_StdDeviation;StdDeviation[2]=TF2_StdDeviation;StdDeviation[3]=TF1_StdDeviation;  
 cShift[0]=cShift4;cShift[1]=cShift3;cShift[2]=cShift2;cShift[3]=cShift1; 

 thistime=0; 
 windowname=StringConcatenate("%B Trend Strength (",TF1,",",TF2,",",TF3,",",TF4,")");
 IndicatorShortName(windowname); 

 if(MaxBars<0) UseBars=iBars(NULL,0)-2;
 else UseBars=MaxBars;  

 timelabel1=TimeLabel(TF1);
 timelabel2=TimeLabel(TF2);
 timelabel3=TimeLabel(TF3);
 timelabel4=TimeLabel(TF4);   
 
 return(0);
}
//+------------------------------------------------------------------+
int deinit()
{
 int objtotal=ObjectsTotal()-1; string name;int i,pos;

 for(i=objtotal;i>=0;i--) 
 {
  name=ObjectName(i);
  
  pos=StringFind(name,strpBTS);
  if(pos>=0) ObjectDelete(name);  
 }
}
//+------------------------------------------------------------------+
int start()
{
 if(noRun()) return(0);
 if(thistime==iTime(NULL,TF,0)) return(0);
 thistime=iTime(NULL,TF,0);
 window=WindowFind(windowname); 
 int i,j,imax,shift,counted=IndicatorCounted();
 double a,b,close1,close2,bl1,bh1,bl2,bh2,v1,v2;
 color clr1,clr2,clr3,clr4;
 if(counted>0) imax=lookback;
 else imax=UseBars;

 for(i=imax;i>=1;i--)
 {   
  for(j=0;j<4;j++)
  {
   shift=iBarShift(NULL,TimeFrame[j],iTime(NULL,0,i),false);
  
   close1=iClose(NULL,TimeFrame[j],shift);
   close2=iClose(NULL,TimeFrame[j],shift+cShift[j]);

//   bh1=iCustom(NULL,TimeFrame[j],ciBands,BBPeriod[j],Shift[j],StdDeviation[j],1,shift);
//   bl1=iCustom(NULL,TimeFrame[j],ciBands,BBPeriod[j],Shift[j],StdDeviation[j],2,shift);
//   bh2=iCustom(NULL,TimeFrame[j],ciBands,BBPeriod[j],Shift[j],StdDeviation[j],1,shift+cShift[j]);
//   bl2=iCustom(NULL,TimeFrame[j],ciBands,BBPeriod[j],Shift[j],StdDeviation[j],2,shift+cShift[j]);

   bh1=myBands(TimeFrame[j],BBPeriod[j],Shift[j],BB_Price,StdDeviation[j],1,shift);
   bl1=myBands(TimeFrame[j],BBPeriod[j],Shift[j],BB_Price,StdDeviation[j],2,shift);
   bh2=myBands(TimeFrame[j],BBPeriod[j],Shift[j],BB_Price,StdDeviation[j],1,shift+cShift[j]);
   bl2=myBands(TimeFrame[j],BBPeriod[j],Shift[j],BB_Price,StdDeviation[j],2,shift+cShift[j]);

   if(bh1!=bl1) 
   {
    a=close1-bl1;
    b=1.0/(bh1-bl1);
    v1=a*b;
    v1=NormalizeDouble(v1,4);
   }
   if(bh2!=bl2) 
   {
    a=close2-bl2;
    b=1.0/(bh2-bl2);
    v2=a*b;
    v2=NormalizeDouble(v2,4); 
   }
   if(v1>v2)      {clr1=clru1;clr2=clru2;clr3=clru3;clr4=clru4;}
   else if(v1<v2) {clr1=clrd1;clr2=clrd2;clr3=clrd3;clr4=clrd4;}
   else           {clr1=clrNULL;clr2=clrNULL;clr3=clrNULL;clr4=clrNULL;}

   if(v1<=level1)      DrawCross(j,iTime(NULL,0,i),strpBTS,clr1,codewd);
   else if(v1<=level2) DrawCross(j,iTime(NULL,0,i),strpBTS,clr2,codewd);
   else if(v1<=level3) DrawCross(j,iTime(NULL,0,i),strpBTS,clr3,codewd);
   else                DrawCross(j,iTime(NULL,0,i),strpBTS,clr4,codewd);      
  }
 }
 PrintLabels();
 return(0);
}
//+------------------------------------------------------------------+
void DrawCross(int j, int time1, string str, color clr, int code)
{
 string name=StringConcatenate(str,j,time1,window);
 ObjectDelete(name);
 ObjectCreate(name,OBJ_ARROW,window,time1,j+1);
 ObjectSet(name,OBJPROP_COLOR,clr);
 ObjectSet(name,OBJPROP_ARROWCODE,code); 
 ObjectSet(name,OBJPROP_WIDTH,1);
 return;
}
//+------------------------------------------------------------------+
void PrintLabels()
{
 string name;
 int time0=iTime(NULL,0,4);
 name=StringConcatenate(strpBTS,timelabel1,window);
 ObjectDelete(name); 
 ObjectCreate(name,OBJ_TEXT,window,time0,4.3);
 ObjectSetText(name,timelabel1,9,"David",textcolor);
 name=StringConcatenate(strpBTS,timelabel2,window);
 ObjectDelete(name);
 ObjectCreate(name,OBJ_TEXT,window,time0,3.3);
 ObjectSetText(name,timelabel2,9,"David",textcolor); 
 name=StringConcatenate(strpBTS,timelabel3,window);
 ObjectDelete(name);
 ObjectCreate(name,OBJ_TEXT,window,time0,2.3);
 ObjectSetText(name,timelabel3,9,"David",textcolor);  
 name=StringConcatenate(strpBTS,timelabel4,window);
 ObjectDelete(name);
 ObjectCreate(name,OBJ_TEXT,window,time0,1.3);
 ObjectSetText(name,timelabel4,9,"David",textcolor);  
 return;
}
//+------------------------------------------------------------------+
string TimeLabel(int TF)
{
 switch(TF)
 {
  case 1: return("M1");break;
  case 5: return("M5");break;
  case 15: return("M15");break;
  case 30: return("M30");break;
  case 60: return("H1");break;
  case 240: return("H4");break;
  case 1440:return("D1");break;
  case 10080: return("W1");break;
  case 43200: return("M1");break;
  default: return("Unknown");break;
 }
 return(" ");
}
//+------------------------------------------------------------------+
double myBands(int tf,int period,int mashift,int price,double dev,int mode,int shift)
{
 int i,method=MODE_SMA;
 double sd=0.0, v1, bb, deviation;
 double ma=iMA(NULL,tf,period,mashift,method,price,shift);
 
 for(i=shift;i<=shift+period-1;i++)
 {
  v1=iClose(NULL,tf,i)-ma; 
  sd+=MathPow(v1,2);
 }
 sd/=period;
 deviation=MathSqrt(sd);
 deviation*=dev;
 
 switch(mode)
 {
  case 1: bb=ma+deviation; break;
  case 2: bb=ma-deviation; break;
 }
 bb=NormDigits(bb);
 return(bb);
}
//+------------------------------------------------------------------+
double NormDigits(double price)
{
 return(NormalizeDouble(price,Digits));
}
//+------------------------------------------------------------------+
bool noRun()
{
 if(TimeCurrent()>ExpirationDate) return(true);
 if(AccNumber>0 && AccountNumber()!=AccNumber) return(true);
 if(DemoOnly && !IsDemo()) return(true);
 
 return(false);
}
//+------------------------------------------------------------------+


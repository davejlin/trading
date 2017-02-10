//+------------------------------------------------------------------+
//|                               2nd Skies Ichimoku Analyzer.mq4    |
//| 2nd Skies Ichimoku Analyzer                                      |
//| written for Chris Capre, 2ndSkies.com (Info@2ndSkies.com)        |
//|                                                                  |
//| Coded by David J. Lin (dave.j.lin@sbcglobal.net)                 |
//| Evanston, IL, December 2, 2009                                   |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009 Chris Capre, David J. Lin"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red

// M5
extern int Min_Time_M5=6;              // M5: minimum HOURS price must have been on one side of the kumo with no touches of the kumo
extern int Break_Pips_M5=60;           // M5: minimum pips to qualify as a break through to the other side of the kumo
extern double Close_Percentage_M5=75.0;// M5: percentage close into kumo to qualify as an end of cycle
// H1
extern int Min_Time_H1=8;              // H1: minimum HOURS price must have been on one side of the kumo with no touches of the kumo
extern int Break_Pips_H1=150;          // H1: minimum pips to qualify as a break through to the other side of the kumo
extern double Close_Percentage_H1=75.0;// H1: percentage close into kumo to qualify as an end of cycle
// H4
extern int Min_Time_H4=4;              // H4: minimum DAYS price must have been on one side of the kumo with no touches of the kumo
extern int Break_Pips_H4=300;          // H4: minimum pips to qualify as a break through to the other side of the kumo
extern double Close_Percentage_H4=75.0;// H4: percentage close into kumo to qualify as an end of cycle
// D1
extern int Min_Time_D1=90;             // D1: minimum DAYS price must have been on one side of the kumo with no touches of the kumo
extern int Break_Pips_D1=600;          // D1: minimum pips to qualify as a break through to the other side of the kumo
extern double Close_Percentage_D1=75.0;// D1: percentage close into kumo to qualify as an end of cycle
// other
extern int Min_Time_other=5;               // other: minimum HOURS price must have been on one side of the kumo with no touches of the kumo
extern int Break_Pips_other=50;            // other: minimum pips to qualify as a break through to the other side of the kumo
extern double Close_Percentage_other=75.0; // other: percentage close into kumo to qualify as an end of cycle

//---- buffers
int tenkan_sen=9;
int kijun_sen=26;
int senkou_span_b=52;
int min_bars;
int totup,totdn,tot;
int Min_Time,Break_Pips;
double Close_Percentage;
double break_up_ave,break_dn_ave;
double break_points,close_percentage;
bool initial;
color clrL=Blue, clrS=Red;
int   codeL=233,codeS=234;
double AUp[],ADn[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
 IndicatorBuffers(0);

 string short_name="Ichimoku Analyzer";
 IndicatorShortName(short_name);
 
 totup=0;totdn=0;tot=0;
 break_up_ave=0;break_dn_ave=0;

 SetIndexStyle(0,DRAW_ARROW,codeL,2,clrL);
 SetIndexArrow(0,codeL);
 SetIndexBuffer(0,AUp);
 SetIndexLabel(0,"Up");
 SetIndexStyle(1,DRAW_ARROW,codeS,2,clrS);
 SetIndexArrow(1,codeS);
 SetIndexBuffer(1,ADn);
 SetIndexLabel(1,"Down"); 

 switch(Period())
 {
  case 5: 
   Min_Time=Min_Time_M5;
   Break_Pips=Break_Pips_M5;
   Close_Percentage=Close_Percentage_M5;
   
   min_bars=Min_Time_M5*60./Period();
   break_points=NormPoints(Break_Pips_M5);
   close_percentage=Close_Percentage_M5/100.0;
  break;  
  case 60:
   Min_Time=Min_Time_H1;
   Break_Pips=Break_Pips_H1;
   Close_Percentage=Close_Percentage_H1;  
  
   min_bars=Min_Time_H1*60./Period();
   break_points=NormPoints(Break_Pips_H1);
   close_percentage=Close_Percentage_H1/100.0;  
  break;
  case 240:
   Min_Time=Min_Time_H4;
   Break_Pips=Break_Pips_H4;
   Close_Percentage=Close_Percentage_H4;  
  
   min_bars=Min_Time_H4*1440./Period();
   break_points=NormPoints(Break_Pips_H4);
   close_percentage=Close_Percentage_H4/100.0;  
  break;  
  case 1440:
   Min_Time=Min_Time_D1;
   Break_Pips=Break_Pips_D1;
   Close_Percentage=Close_Percentage_D1;
  
   min_bars=Min_Time_D1*1440./Period();
   break_points=NormPoints(Break_Pips_D1);
   close_percentage=Close_Percentage_D1/100.0;  
  break;   
  default:
   Min_Time=Min_Time_other;
   Break_Pips=Break_Pips_other;
   Close_Percentage=Close_Percentage_other;
  
   min_bars=Min_Time_other*60/Period();
   break_points=NormPoints(Break_Pips_other);
   close_percentage=Close_Percentage_other/100.0;  
  break;  
 }

 if(min_bars<0) min_bars=0;
 
 initial=false;
  
 return(0);
}
//+------------------------------------------------------------------+
//| Trail Line                                                       |
//+------------------------------------------------------------------+
int start()
{
 if(initial) return(0);
 
 double spanA,spanB,spanup,spandn,spancutoff,cutoffprice,open,close,high,low; 
 double close1,close2,spanA1,spanB1,spanA2,spanB2,spanup1,spandn1,spanup2,spandn2;
 int i,j,k,l,limit=Bars-1-min_bars,count,peak; 
 bool skip;

 break_up_ave=0;totup=0;
 for(i=limit;i>=0;i--) // break-upward 
 { 
  count=0;
  for(j=i;j<=i+min_bars;j++) // no-touch criteria
  {
   spanA=iIchimoku(NULL,0,tenkan_sen,kijun_sen,senkou_span_b,MODE_SENKOUSPANA,j);
   spanB=iIchimoku(NULL,0,tenkan_sen,kijun_sen,senkou_span_b,MODE_SENKOUSPANB,j);
  
   spandn=MathMin(spanA,spanB);
  
   high=iHigh(NULL,0,j);

   if(high<spandn) count++; 
  } // no-touch criteria
  
  if(count==min_bars)
  {
   skip=false;
   for(k=i;k>=0;k--)
   {
    spanA=iIchimoku(NULL,0,tenkan_sen,kijun_sen,senkou_span_b,MODE_SENKOUSPANA,k);
    spanB=iIchimoku(NULL,0,tenkan_sen,kijun_sen,senkou_span_b,MODE_SENKOUSPANB,k);
  
    spanup=MathMax(spanA,spanB);
    spandn=MathMin(spanA,spanB);

    close=iClose(NULL,0,k);
    
    if(close>=NormDigits(spanup+break_points))
    {
     for(l=k-1;l>=0;l--)
     {
      spanA1=iIchimoku(NULL,0,tenkan_sen,kijun_sen,senkou_span_b,MODE_SENKOUSPANA,l);
      spanB1=iIchimoku(NULL,0,tenkan_sen,kijun_sen,senkou_span_b,MODE_SENKOUSPANB,l);
  
      spanup1=MathMax(spanA1,spanB1);
      spandn1=MathMin(spanA1,spanB1);

      close1=iClose(NULL,0,l);      

      spanA2=iIchimoku(NULL,0,tenkan_sen,kijun_sen,senkou_span_b,MODE_SENKOUSPANA,l+1);
      spanB2=iIchimoku(NULL,0,tenkan_sen,kijun_sen,senkou_span_b,MODE_SENKOUSPANB,l+1);
  
      spanup2=MathMax(spanA2,spanB2);
      spandn2=MathMin(spanA2,spanB2);

      close2=iClose(NULL,0,l+1);      

      spancutoff=NormDigits(close_percentage*(spanup1-spandn1));  
      cutoffprice=NormDigits(spanup1-spancutoff);
      
      low=iLow(NULL,0,l);
      
      if(low<=cutoffprice||(close1<spanup1&&close2<spanup2))
      {
       peak=iHighest(NULL,0,MODE_HIGH,k-l+1,l);
       high=iHigh(NULL,0,peak);
       break_up_ave+=NormDigits(high-spanup);
       totup++;
       ADn[peak]=high+NormPoints(5);
       i=l;
       skip=true;
       break;
      }
      
      if(l==0) i=0; // fast-forward

     } // for l
    } // if

    if(skip) break;

    if(k==0) i=0; // fast-forward
    
   } // for k   
  } // if 
 } // for i

 break_dn_ave=0;totdn=0;
 for(i=limit;i>=0;i--) // break-downward 
 { 
  count=0;
  for(j=i;j<=i+min_bars;j++) // no-touch criteria
  {
   spanA=iIchimoku(NULL,0,tenkan_sen,kijun_sen,senkou_span_b,MODE_SENKOUSPANA,j);
   spanB=iIchimoku(NULL,0,tenkan_sen,kijun_sen,senkou_span_b,MODE_SENKOUSPANB,j);
  
   spanup=MathMax(spanA,spanB);
  
   low=iLow(NULL,0,j);

   if(low>spanup) count++; 
  } // no-touch criteria
  
  if(count==min_bars)
  {
   skip=false;
   for(k=i;k>=0;k--)
   {
    spanA=iIchimoku(NULL,0,tenkan_sen,kijun_sen,senkou_span_b,MODE_SENKOUSPANA,k);
    spanB=iIchimoku(NULL,0,tenkan_sen,kijun_sen,senkou_span_b,MODE_SENKOUSPANB,k);
  
    spanup=MathMax(spanA,spanB);
    spandn=MathMin(spanA,spanB);

    close=iClose(NULL,0,k);
    
    if(close<=NormDigits(spandn-break_points))
    {
     for(l=k-1;l>=0;l--)
     {
      spanA1=iIchimoku(NULL,0,tenkan_sen,kijun_sen,senkou_span_b,MODE_SENKOUSPANA,l);
      spanB1=iIchimoku(NULL,0,tenkan_sen,kijun_sen,senkou_span_b,MODE_SENKOUSPANB,l);
  
      spanup1=MathMax(spanA1,spanB1);
      spandn1=MathMin(spanA1,spanB1);

      close1=iClose(NULL,0,l);      

      spanA2=iIchimoku(NULL,0,tenkan_sen,kijun_sen,senkou_span_b,MODE_SENKOUSPANA,l+1);
      spanB2=iIchimoku(NULL,0,tenkan_sen,kijun_sen,senkou_span_b,MODE_SENKOUSPANB,l+1);
  
      spanup2=MathMax(spanA2,spanB2);
      spandn2=MathMin(spanA2,spanB2);

      close2=iClose(NULL,0,l+1);      

      spancutoff=NormDigits(close_percentage*(spanup1-spandn1));  
      cutoffprice=NormDigits(spandn1+spancutoff);
      
      high=iHigh(NULL,0,l);
      
      if(high>=cutoffprice||(close1>spandn1&&close2>spandn2))
      {
       peak=iLowest(NULL,0,MODE_LOW,k-l+1,l);
       low=iLow(NULL,0,peak);
       break_dn_ave+=NormDigits(spandn-low);
       totdn++;
       AUp[peak]=low-NormPoints(5);
       i=l;
       skip=true;
       break;
      }
      
      if(l==0) i=0; // fast-forward

     } // for l
    } // if

    if(skip) break;

    if(k==0) i=0; // fast-forward
    
   } // for k   
  } // if 
 } // for i
 
 LogData();
  
 initial=true;

 return(0);
}
//+------------------------------------------------------------------+
void LogData()
{
 double bars=Bars-1;

 string timename;
 switch(Period())
 {
  case 1: timename="M1";
  break;
  case 5: timename="M5";
  break;
  case 15: timename="M15";
  break;  
  case 30: timename="M30";
  break;  
  case 60: timename="H1";
  break;
  case 240: timename="H4";
  break;  
  case 1440: timename="D1";
  break;  
  case 10080: timename="W1";
  break;  
  default: timename="MN";
  break;  
 }

 string v1,v2,v3;

 if(totup!=0) v1=DoubleToStr(break_up_ave/totup/Point,0);
 else         v1="NULL";

 if(totdn!=0) v2=DoubleToStr(break_dn_ave/totdn/Point,0);
 else         v2="NULL";

 tot=totup+totdn;

 if(tot!=0) v3=DoubleToStr((break_up_ave+break_dn_ave)/tot/Point,0);
 else       v3="NULL";

 string filename=StringConcatenate("Ichimoku_Analysis_",Symbol(),"_",timename,"_",Min_Time,"_",Break_Pips,"_",Close_Percentage,".csv");
 int handle=FileOpen(filename,FILE_CSV|FILE_WRITE,',');
 
 FileWrite(handle,"up Ave","dn Ave","up&dn Ave"); 
 FileWrite(handle,v1,v2,v3);
                  
 FileWrite(handle,"up","dn","up&dn");
 FileWrite(handle,DoubleToStr(totup,0),DoubleToStr(totdn,0),DoubleToStr(tot,0));

 FileWrite(handle,"Bars total");
 FileWrite(handle,DoubleToStr(bars,0));

 FileClose(handle);
 
 return;
}
//+------------------------------------------------------------------+
double NormDigits(double a)
{
 return(NormalizeDouble(a,Digits));
}
//+------------------------------------------------------------------+
double NormPoints(int pips)
{
 return(NormDigits(pips*Point));
}
//+------------------------------------------------------------------+


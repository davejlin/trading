//+------------------------------------------------------------------+
//|                                  2nd Skies Shaved Bar Alert.mq4  |
//| 2nd Skies Shaved Bar Alert                                       |
//| written for Chris Capre, 2ndSkies.com (Info@2ndSkies.com)        |
//|                                                                  |
//| Coded by David J. Lin (dave.j.lin@sbcglobal.net)                 |
//| Evanston, IL, January 18, 2010                                   |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010 Chris Capre, David J. Lin"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red

extern double Percentage=5; // percentage of total range close within high/low to qualify as shaved bar 
extern bool AlertAlarm=true;
extern bool AlertEmail=false;

//---- buffers
double perc;
color clrL=Red, clrS=Blue;
int   codeL=159,codeS=159;
double AUp[],ADn[];
datetime alerttime;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
 IndicatorBuffers(0);
 
 string short_name="Shaved Bar Alert";
 IndicatorShortName(short_name);
 
 perc=0.01*Percentage;
 
 SetIndexStyle(0,DRAW_ARROW,codeL,2,clrL);
 SetIndexArrow(0,codeL);
 SetIndexBuffer(0,AUp);
 SetIndexLabel(0,"Up");
 SetIndexStyle(1,DRAW_ARROW,codeS,2,clrS);
 SetIndexArrow(1,codeS);
 SetIndexBuffer(1,ADn);
 SetIndexLabel(1,"Down"); 
  
 return(0);
}
//+------------------------------------------------------------------+
//| Trail Line                                                       |
//+------------------------------------------------------------------+
int start()
{
 int i,imax,counted_bars=IndicatorCounted();
 int checktime=iBarShift(NULL,0,alerttime,false);
 
 if(checktime==1) return(0);

 double open,close,high,low,span,cutoff,close2,high2,low2;

 if(counted_bars>0) imax=1;
 else imax=Bars-1;
 
 for(i=imax;i>=1;i--)
 { 
  close=iClose(NULL,0,i);
  open=iOpen(NULL,0,i);
  high=iHigh(NULL,0,i);
  low =iLow(NULL,0,i);
  if(close>open)
  {
   span=NormDigits(high-low);
   cutoff=NormDigits(high-(perc*span));
   if(close>=cutoff) ShavedBar(i,true,high);
  }
  else if(close<open)
  {
   span=NormDigits(high-low);
   cutoff=NormDigits(low+(perc*span));
   if(close<=cutoff) ShavedBar(i,false,low);   
  }
 } // for i

 return(0);
}
//+------------------------------------------------------------------+
void ShavedBar(int i, bool bias, double price)
{
 if(bias)  ADn[i]=NormDigits(price+NormPoints(50));
 else      AUp[i]=NormDigits(price-NormPoints(50));
 
 if(i>1) return;
 
 alerttime=iTime(NULL,0,i);
 
 string td=TimeToStr(alerttime,TIME_DATE|TIME_MINUTES);     
 string message=StringConcatenate(Symbol()," Shaved Bar formed at ",td,".");
 if (AlertAlarm) Alert(message);
 if (AlertEmail) SendMail("MT4 MA-Cross Alert!",message);
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


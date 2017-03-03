//+----------------------------------------------------------------------+
//|                                                Spread History BB.mq4 |
//|                                                         David J. Lin |
//| Plots spread history between 3 pairs & displays BB                   |
//| Written in collaboration with Rocko (13rocko@gmail.com)              |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|dave.j.lin@sbcglobal.net                                              |
//|Evanston, IL, January 30, 2007                                        |
//+----------------------------------------------------------------------+
#property copyright "2007 David J. Lin"
#property link      ""

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Yellow
#property indicator_color3 Yellow
#property indicator_color4 Yellow

//---- input parameters
extern datetime EntryPoint=D'2007.01.15 01:00';
extern string Pair1="EURUSDm";
extern string Pair2="USDJPYm";
extern string Pair3="EURJPYm";
extern bool Long1=false;
extern bool Long2=false;
extern bool Long3=true;
extern double Lots1=1;
extern double Lots2=1;
extern double Lots3=1;
extern int MAPeriod=72;
extern double BBDeviations=2.0;

//---- buffers
double Op[],MA[],UBand[],LBand[];
double InitialPrice1,InitialPrice2,InitialPrice3;
int mult[3],convert[3];
int BarsElapsed;
bool mini;
string Pair[3];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
Pair[0]=Pair1;
Pair[1]=Pair2;
Pair[2]=Pair3;
CheckPairs();
//---- indicators
IndicatorBuffers(4);
SetIndexStyle(0,DRAW_LINE);
SetIndexBuffer(0,Op);
SetIndexStyle(1,DRAW_LINE);
SetIndexBuffer(1,MA);
SetIndexStyle(2,DRAW_LINE);
SetIndexBuffer(2,UBand);
SetIndexStyle(3,DRAW_LINE);
SetIndexBuffer(3,LBand);
SetIndexLabel(0, "Spread");
SetIndexLabel(1, "MA");
SetIndexLabel(2, "Upper BB");
SetIndexLabel(3, "Lower BB");

IndicatorShortName("Spread: "+Pair1+", "+Pair2+" "+Pair3);
//first=true; // to properly place initial point & allow for re-initialization upon timeframe change
BarsElapsed=iBarShift(Pair1,0,EntryPoint,false); 
InitialPrice1=iClose(Pair1,0,BarsElapsed);
BarsElapsed=iBarShift(Pair2,0,EntryPoint,false); 
InitialPrice2=iClose(Pair2,0,BarsElapsed);
BarsElapsed=iBarShift(Pair3,0,EntryPoint,false); 
InitialPrice3=iClose(Pair3,0,BarsElapsed);
//----
return(0);
}
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function |
//+------------------------------------------------------------------+
int deinit()
{
//----

//----
return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function |
//+------------------------------------------------------------------+
int start()
{
 if(Bars<MAPeriod) return(0);
 
 int i,j,k,limit;
 double profit1,profit2,profit3;
 double sum,value1a,value1b,value2a,value2b,value3a,value3b,divisor1,divisor2,divisor3;

// int counted_bars = IndicatorCounted()+1; // IndicatorCounted() returns the count of bars minus one
// if(first) limit = BarsElapsed;
// else limit=Bars-counted_bars;
 
 limit = BarsElapsed;
 
 for(i=limit;i>=0;i--)
 {
  if(Long1){value1a=iClose(Pair1,0,i);value1b=InitialPrice1;}
  else{value1a=InitialPrice1;value1b=iClose(Pair1,0,i);}

  if(Long2){value2a=iClose(Pair2,0,i);value2b=InitialPrice2;}
  else{value2a=InitialPrice2;value2b=iClose(Pair2,0,i);} 

  if(Long3){value3a=iClose(Pair3,0,i);value3b=InitialPrice3;}
  else{value3a=InitialPrice3;value3b=iClose(Pair3,0,i);}   
 
  divisor1=ConvertFunction(convert[0],Pair[0],i);
  divisor2=ConvertFunction(convert[1],Pair[1],i);
  divisor3=ConvertFunction(convert[2],Pair[2],i);  
  
  profit1=mult[0]*(value1a-value1b)*Lots1/divisor1;
  profit2=mult[1]*(value2a-value2b)*Lots2/divisor2;
  profit3=mult[2]*(value3a-value3b)*Lots3/divisor3;  

  Op[i]=NormPrice(profit1+profit2+profit3);
 
  if(i>BarsElapsed-MAPeriod) continue;
  
  sum=0; 
  for(j=i+MAPeriod-1;j>=i;j--)
   sum+=Op[j];
  sum/=MAPeriod;
  
  MA[i]=NormPrice(sum); 
 }
 
//---- Bollinger Bands calculation   
 double oldval,newres,deviation;

// if(first) 
// else i=Bars-counted_bars;

 i=BarsElapsed-MAPeriod;
  
 while(i>=0)
 {
  sum=0.0;
  k=i+MAPeriod-1;
  oldval=MA[i];
  while(k>=i)
  {
   newres=Op[k]-oldval;
   sum+=newres*newres;
   k--;
  }
  deviation=BBDeviations*MathSqrt(sum/MAPeriod);
  UBand[i]=NormPrice(oldval+deviation);
  LBand[i]=NormPrice(oldval-deviation);
  i--;
 }
//----   
// first=false;
 return(0);
}
//+------------------------------------------------------------------+ 
void CheckPairs()
{
 int i,j; mini=false;
 string USDQ[4]; USDQ[0]="GBPUSD";USDQ[1]="EURUSD";USDQ[2]="AUDUSD";USDQ[3]="NZDUSD";
 string USDQm[4];USDQm[0]="GBPUSDm";USDQm[1]="EURUSDm";USDQm[2]="AUDUSDm";USDQm[3]="NZDUSDm";
 string USDB[3];USDB[0]="USDCHF";USDB[1]="USDJPY";USDB[2]="USDCAD";
 string USDBm[3];USDBm[0]="USDCHFm";USDBm[1]="USDJPYm";USDBm[2]="USDCADm";
 string JPY[5];JPY[0]="EURJPY";JPY[1]="GBPJPY";JPY[2]="CHFJPY";JPY[3]="NZDJPY";JPY[4]="AUDJPY"; 
 string JPYm[5];JPYm[0]="EURJPYm";JPYm[1]="GBPJPYm";JPYm[2]="CHFJPYm";JPYm[3]="NZDJPYm";JPYm[4]="AUDJPYm"; 
 string CHF[2];CHF[0]="GBPCHF";CHF[1]="EURCHF";
 string CHFm[2];CHFm[0]="GBPCHFm";CHFm[1]="EURCHFm"; 
 string CAD[2];CAD[0]="AUDCAD";CAD[1]="EURCAD";
 string CADm[2];CADm[0]="AUDCADm";CADm[1]="EURCADm"; 
 string NZD="AUDNZD",NZDm="AUDNZDm";
 string GBP="EURGBP",GBPm="EURGBPm";  
 string AUD="EURAUD",AUDm="EURAUDm";  

 for(i=0;i<3;i++)
  convert[i]=-1; // use this for error check
  
 for(j=0;j<3;j++)
 {
// USD Quote
// USD Quote standard 
  for(i=0;i<4;i++) 
  {
   if(Pair[j]==USDQ[i]) 
   {
    convert[j]=1;  
    mult[j]=100000;
   }
  }
// USD Quote minis

  for(i=0;i<4;i++) 
  {
   if(Pair[j]==USDQm[i]) 
   { 
    convert[j]=1; 
    mult[j]=10000;    
    mini=true;  
   }
  }
 
// USD Base
// USD Base standard 
  for(i=0;i<3;i++) 
  {
   if(Pair[j]==USDB[i]) 
   {
    convert[j]=2;  
    mult[j]=100000;
   }
  }
// USD Base minis
  for(i=0;i<3;i++) 
  {
   if(Pair[j]==USDBm[i]) 
   { 
    convert[j]=2; 
    mult[j]=10000;     
    mini=true;  
   }
  } 
 
// JPY 
// JPY standard  
  for(i=0;i<5;i++) 
  {
   if(Pair[j]==JPY[i]) 
   { 
    convert[j]=3;  
    mult[j]=100000;
   }
  }

// JPY minis
  for(i=0;i<5;i++) 
  {
   if(Pair[j]==JPYm[i]) 
   { 
    convert[j]=3; 
    mult[j]=10000;
    mini=true;  
   }
  }

// CHF Base
 // CHF Base standard 
  for(i=0;i<2;i++) 
  {
   if(Pair[j]==CHF[i]) 
   {
    convert[j]=4;  
    mult[j]=100000;
   }
  }
// CHF Base minis
  for(i=0;i<2;i++) 
  {
   if(Pair[j]==CHFm[i]) 
   { 
    convert[j]=4; 
    mult[j]=10000;    
    mini=true;  
   }
  } 

// CAD Base
 // CAD Base standard 
  for(i=0;i<2;i++) 
  {
   if(Pair[j]==CAD[i]) 
   {
    convert[j]=5;  
    mult[j]=100000;
   }
  }
// CAD Base minis
  for(i=0;i<2;i++) 
  {
   if(Pair[j]==CADm[i]) 
   { 
    convert[j]=5; 
    mult[j]=10000;    
    mini=true;  
   }
  }

// NZD Base
// NZD Base standard 
  if(Pair[j]==NZD) 
  {
   convert[j]=6;  
   mult[j]=100000;
  }
// NZD Base minis
  if(Pair[j]==NZDm) 
  { 
   convert[j]=6; 
   mult[j]=10000;    
   mini=true;  
  }

// GBP Base
// GBP Base standard 
  if(Pair[j]==GBP) 
  {
   convert[j]=7;  
   mult[j]=100000;
  }
// GBP Base minis
  if(Pair[j]==GBPm) 
  { 
   convert[j]=7; 
   mult[j]=10000;    
   mini=true;  
  }  

// AUD Base
// AUD Base standard 
  if(Pair[j]==AUD) 
  {
   convert[j]=8;  
   mult[j]=100000;
  }
// AUD Base minis
  if(Pair[j]==AUDm) 
  { 
   convert[j]=8; 
   mult[j]=10000;    
   mini=true;  
  }  
 }
 
 if(convert[0]<0)
  Alert("WARNING: Invalid Pair name: "+Pair[0]);
 if(convert[1]<0)
  Alert("WARNING: Invalid Pair name: "+Pair[1]);
 if(convert[2]<0)
  Alert("WARNING: Invalid Pair name: "+Pair[2]);  
 
}

//+------------------------------------------------------------------+ 
double ConvertFunction(int flag, string pair, int index)
{
 switch(flag)
 {
  case 1: // USD quote
   return(1);
  break;
  case 2: // USD base
   return(iClose(pair,0,index));
  break;
  case 3: // JPY base
   if(mini)
    return(iClose("USDJPYm",0,index));
   else
    return(iClose("USDJPY",0,index));   
  break;
  case 4: // CHF base
   if(mini)
    return(iClose("USDCHFm",0,index));
   else
    return(iClose("USDCHF",0,index));   
  break;
  case 5: // CAD base
   if(mini)
    return(iClose("USDCADm",0,index));
   else
    return(iClose("USDCAD",0,index));   
  break;  
  case 6: // NZD base
   if(mini)
    return(1/iClose("NZDUSDm",0,index));
   else
    return(1/iClose("NZDUSD",0,index));   
  break;
  case 7: // GBP base
   if(mini)
    return(1/iClose("GBPUSDm",0,index));
   else
    return(1/iClose("GBPUSD",0,index));   
  break;
  case 8: // AUD base
   if(mini)
    return(1/iClose("AUDUSDm",0,index));
   else
    return(1/iClose("AUDUSD",0,index));   
  break;
 }
 return(1);
}
//+------------------------------------------------------------------+
double NormPrice(double price)
{
 return(NormalizeDouble(price,2));
}
//+------------------------------------------------------------------+
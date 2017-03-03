//+----------------------------------------------------------------------+
//|                                                   Spread History.mq4 |
//|                                                         David J. Lin |
//| Plots spread history between 5 pairs                                 |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|dave.j.lin@sbcglobal.net                                              |
//|Evanston, IL, May 8, 2008                                             |
//+----------------------------------------------------------------------+
#property copyright "2008 David J. Lin"
#property link      ""

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Yellow

//---- input parameters
extern datetime EntryPoint=D'2008.01.01 00:00';
extern string Pair1="EURUSD";
extern string Pair2="USDCAD";
extern string Pair3="AUDCAD";
extern string Pair4="EURAUD";
extern string Pair5="AUDNZD";
extern bool Long1=true;
extern bool Long2=true;
extern bool Long3=true;
extern bool Long4=false;
extern bool Long5=false;
extern double Lots1=1.0;
extern double Lots2=1.0;
extern double Lots3=0.5;
extern double Lots4=1.0;
extern double Lots5=1.0;
extern int MAPeriod=13;

//---- buffers
double Op[],MA[];
int mult[5],convert[5];
int BarsElapsed;
bool mini,first;
string Pair[5];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
Pair[0]=Pair1;
Pair[1]=Pair2;
Pair[2]=Pair3;
Pair[3]=Pair4;
Pair[4]=Pair5;
CheckPairs();
//---- indicators
IndicatorBuffers(3);
SetIndexStyle(0,DRAW_LINE);
SetIndexBuffer(0,Op);
SetIndexStyle(1,DRAW_LINE);
SetIndexBuffer(1,MA);
SetIndexLabel(0, "Spread");
SetIndexLabel(1, "MA");

IndicatorShortName("Spread: "+Pair1+", "+Pair2+", "+Pair3+", "+Pair4+", "+Pair5);
first=true; // to properly place initial point & allow for re-initialization upon timeframe change
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
 
 int i,j,limit;
 double profit1,profit2,profit3,profit4,profit5;
 double sum,value1a,value1b,value2a,value2b,value3a,value3b,value4a,value4b,value5a,value5b,divisor1,divisor2,divisor3,divisor4,divisor5;
 int counted_bars = IndicatorCounted();
 //---- last counted bar will be recounted
 if(counted_bars>0) counted_bars--;
 else counted_bars=1;

 BarsElapsed=iBarShift(Pair1,0,EntryPoint,false); 

 if(first) limit = BarsElapsed;
 else limit=Bars-counted_bars;
 
 for(i=limit;i>=0;i--)
 {
  if(Long1){value1a=iClose(Pair1,0,i);value1b=iClose(Pair1,0,BarsElapsed);}
  else{value1a=iClose(Pair1,0,BarsElapsed);value1b=iClose(Pair1,0,i);}

  if(Long2){value2a=iClose(Pair2,0,i);value2b=iClose(Pair2,0,BarsElapsed);}
  else{value2a=iClose(Pair2,0,BarsElapsed);value2b=iClose(Pair2,0,i);} 

  if(Long3){value3a=iClose(Pair3,0,i);value3b=iClose(Pair3,0,BarsElapsed);}
  else{value3a=iClose(Pair3,0,BarsElapsed);value3b=iClose(Pair3,0,i);}   

  if(Long4){value4a=iClose(Pair4,0,i);value4b=iClose(Pair4,0,BarsElapsed);}
  else{value4a=iClose(Pair4,0,BarsElapsed);value4b=iClose(Pair4,0,i);}  
  
  if(Long5){value5a=iClose(Pair5,0,i);value5b=iClose(Pair5,0,BarsElapsed);}
  else{value5a=iClose(Pair5,0,BarsElapsed);value5b=iClose(Pair5,0,i);}    
 
  divisor1=ConvertFunction(convert[0],Pair[0],i);
  divisor2=ConvertFunction(convert[1],Pair[1],i);
  divisor3=ConvertFunction(convert[2],Pair[2],i);  
  divisor4=ConvertFunction(convert[3],Pair[3],i);
  divisor5=ConvertFunction(convert[4],Pair[4],i);
  
  profit1=mult[0]*(value1a-value1b)*Lots1/divisor1;
  profit2=mult[1]*(value2a-value2b)*Lots2/divisor2;
  profit3=mult[2]*(value3a-value3b)*Lots3/divisor3;  
  profit4=mult[3]*(value4a-value4b)*Lots4/divisor4;
  profit5=mult[4]*(value5a-value5b)*Lots5/divisor5; 

  Op[i]=profit1+profit2+profit3+profit4+profit5;
 
  if(i>BarsElapsed-MAPeriod) continue;
  
  sum=0; 
  for(j=i+MAPeriod-1;j>=i;j--)
   sum+=Op[j];
  sum/=MAPeriod;
  
  MA[i]=sum;
 } 
 first=false;
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

 for(i=0;i<5;i++)
  convert[i]=-1; // use this for error check
  
 for(j=0;j<5;j++)
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
 if(convert[3]<0)
  Alert("WARNING: Invalid Pair name: "+Pair[3]);
 if(convert[4]<0)
  Alert("WARNING: Invalid Pair name: "+Pair[4]);  
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
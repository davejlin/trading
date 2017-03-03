//+----------------------------------------------------------------------+
//|                                            Supply Demand Leveler.mq4 |
//|                                                         David J. Lin |
//|                                                                      |
//| Searches for peak supply/demand levels based on heavy bars           |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|dave.j.lin@sbcglobal.net                                              |
//|Evanston, IL, July 13, 2008                                           |
//|                                                                      |
//|made MTF July 20, 2008                                                |
//+----------------------------------------------------------------------+
#property copyright "2008 David J. Lin"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 6

//---- input parameters
extern double SDITrigger=500000;  // threshhold to trigger Supply Demand Imbalance, based on Supply Demand Imbalance indicator
extern double SDIFloor=10;    // minimum value to establish base
extern int SDILookBack=0;     // previous bars to define base (use 0 for strict-cutoff)
extern int SDIEntryRange=2;   // previous bars to define entry range height
//---- buffers
extern int TimeFrame=0;
int BarMin=4;          // previous bars to calculate for average
extern color supplyCLR=LightSalmon;
extern color demandCLR=LightGreen;

double sH[],sL[],dH[],dL[],SDI[],Ave[];  // indicator buffer
double sh[500],sl[500],dh[500],dl[500]; // stores values sequentially
string S[500],D[500]; // stores object names sequentially
int Ns,Nd; // current count 
int tfshift,shift;

string namebase="SDLev_",Hnamebase="SDHist_";
string SDIName="Supply Demand Imbalance";
datetime bartime,bartimeTF; bool norun=false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
 if(TimeFrame==0) tfshift=1;
 else             tfshift=TimeFrame/Period();

 if(tfshift<1) 
 {
  Alert("TimeFrame is smaller than chart period!!");
  norun=true;
  return(0);
 }
//----
 IndicatorBuffers(6);
 SetIndexBuffer(0,sH);
 SetIndexBuffer(1,sL); 
 SetIndexBuffer(2,dH);
 SetIndexBuffer(3,dL); 
 SetIndexBuffer(4,SDI);
 SetIndexBuffer(5,Ave); 
  
 SetIndexStyle(0,DRAW_NONE);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexStyle(5,DRAW_NONE);

 SetIndexLabel(0, "sH");
 SetIndexLabel(1, "sL");
 SetIndexLabel(2, "dH");
 SetIndexLabel(3, "dL");
 SetIndexLabel(4, "SDI");
 SetIndexLabel(5, "Ave");
 
 IndicatorShortName("Supply Demand Levels("+TimeFrame+")"); 
 
 for(int i=0;i<500;i++)
 {
  sh[i]=0;sl[i]=0;dh[i]=0;dl[i]=0;  
  S[i]="";D[i]="";
 } 

 Ns=0;Nd=0;
 
 namebase="SDLev";Hnamebase="SDHist";
 
 namebase=StringConcatenate(namebase,TimeFrame,"_");
 Hnamebase=StringConcatenate(Hnamebase,TimeFrame,"_");
  
//----
return(0);
}
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function |
//+------------------------------------------------------------------+
int deinit()
{
//----
 int objtotal=ObjectsTotal()-1; string name;int i,pos1,pos2;

 for(i=objtotal;i>=0;i--) 
 {
  name=ObjectName(i);
  
  pos1=StringFind(name,namebase);
  pos2=StringFind(name,Hnamebase);
  if(pos1>=0 || pos2>=0) ObjectDelete(name);   
 }
//----
return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
 if(norun) return;
 int i,j,s,n,counted_bars,limit;
 double open,close,high,low,price1,price2;
 bool trigger;
 string time,label1;

 if(bartime==iTime(NULL,0,0)) return;
 bartime=iTime(NULL,0,0); 

 counted_bars = IndicatorCounted(); // IndicatorCounted() returns the count of unchanged bars minus one
 if(counted_bars>0) counted_bars++;
 else counted_bars=1+BarMin;

 limit=Bars-counted_bars;
 
 for(i=limit;i>0;i--)
 { 
  shift=iBarShift(NULL,TimeFrame,iTime(NULL,0,i),false); 
  if(shift==0) shift=1; // for MTF live charts
  
  UpdateSupplyDemandImbalance(i);

  if(bartimeTF==iTime(NULL,TimeFrame,shift))
  {
   sH[i]=sh[Ns];
   sL[i]=sl[Ns];
   dH[i]=dh[Nd];
   dL[i]=dl[Nd];  
   UpdateLines();
   continue;
  }
  bartimeTF=iTime(NULL,TimeFrame,shift);
    
  sH[i]=0;sL[i]=0;dH[i]=0;dL[i]=0;
  open=iOpen(NULL,TimeFrame,shift);
  close=iClose(NULL,TimeFrame,shift);
  high=iHigh(NULL,TimeFrame,shift);
  low=iLow(NULL,TimeFrame,shift); 
  
  sH[i]=sh[Ns];
  sL[i]=sl[Ns];
  dH[i]=dh[Nd];
  dL[i]=dl[Nd];

// Destroy old levels
  n=Ns;
  for(j=n;j>=0;j--) // if more than one destroyed per bar 
  {
   if(sl[j]==0) break;
   if(high<=sl[j]) break;
   
   if(j>0)
   {   
    sH[i]=sh[j-1];
    sL[i]=sl[j-1];     
   }
   else
   {
    sH[i]=0;
    sL[i]=0;     
   }
    
   sh[j]=0;
   sl[j]=0;
   EndObject(S[j],i,true); 
   S[j]="";       
   Ns--;
 
  }
  
  n=Nd;
  for(j=n;j>=0;j--) // if more than one destroyed per bar 
  {  
   if(dh[j]==0) break;
   if(low>=dh[j]) break;
  
   if(j>0)
   {
    dL[i]=dl[j-1];
    dH[i]=dh[j-1];     
   }
   else
   {
    dL[i]=0;
    dH[i]=0; 
   }
    
   dl[j]=0;    
   dh[j]=0;
   EndObject(D[j],i,false);  
   D[j]="";  
   Nd--;  
  }

// new levels: use Supply Demand Imbalance

// use external indicator 
//  SDI0=iCustom(NULL,TimeFrame,SDIName,BarMin,0,i);  
//  SDI1=iCustom(NULL,TimeFrame,SDIName,BarMin,0,i+1);    
// use internal calculation  
  trigger=false;

  if(SDILookBack==0)
  {
   if(SDI[i]>SDITrigger&&SDI[i+tfshift]<SDITrigger) trigger=true;
   else trigger=false;
  }
  else
  {
   if(SDI[i]>SDITrigger)
   {
    trigger=true;  

    for(j=1;j<=SDILookBack;j++)
    {
     if(SDI[i+(j*tfshift)]>SDIFloor) 
     {
      trigger=false;
      break;
     }
    } 
   }   
  }
       
  if(trigger)
  { 
   time=TimeToStr(iTime(NULL,0,i),TIME_DATE|TIME_MINUTES);
 
   if(close>open)
   {
    price1=iHigh(NULL,TimeFrame,shift+1);
    s=iLowest(NULL,TimeFrame,MODE_LOW,SDIEntryRange,shift);   
    price2=iLow(NULL,TimeFrame,s);    
    if(close>price1)
    {
     label1=StringConcatenate(namebase,"Demand_",time);
     
     Nd++; 
     dH[i]=price1;
     dL[i]=price2;    
     dh[Nd]=price1;
     dl[Nd]=price2;
     D[Nd]=label1;
     CreateZone(label1,price1,price2,i,demandCLR);
    }
   }
   else if(close<open)
   {
    s=iHighest(NULL,TimeFrame,MODE_HIGH,SDIEntryRange,shift);
    price1=iHigh(NULL,TimeFrame,s);
    price2=iLow(NULL,TimeFrame,shift+1);    
    if(close<price2)
    {
     label1=StringConcatenate(namebase,"Supply_",time);
    
     Ns++; 
     sH[i]=price1;
     sL[i]=price2;    
     sh[Ns]=price1;
     sl[Ns]=price2;
     S[Ns]=label1;   
     CreateZone(label1,price1,price2,i,supplyCLR);    
    }
   } 
  } 
  Comment("NSupply: ",Ns," NDemand: ",Nd," shift: ",shift);
  UpdateLines();  
  
 }
 return(0);
}
//+------------------------------------------------------------------+
double NormPoints(int pips)
{
 return(NormDigits(pips*Point));
}
//+------------------------------------------------------------------+
double NormDigits(double price)
{
 return(NormalizeDouble(price,Digits));
}
//+------------------------------------------------------------------+
void EndObject(string name,int i,bool sd)
{
 string linename,linenamenew;
 datetime oldtime1;
 double oldprice1,oldprice2;
 color oldcolor;
 for(int j=ObjectsTotal()-1;j>=0;j--)
 {
  linename=ObjectName(j);
  if(linename==name) 
  {
   oldtime1=ObjectGet(linename,OBJPROP_TIME1);
   oldprice1=ObjectGet(linename,OBJPROP_PRICE1);
   oldprice2=ObjectGet(linename,OBJPROP_PRICE2);
   oldcolor=ObjectGet(linename,OBJPROP_COLOR);

   if(sd) linenamenew=StringConcatenate(Hnamebase,"Supply_",TimeToStr(oldtime1));
   else   linenamenew=StringConcatenate(Hnamebase,"Demand_",TimeToStr(oldtime1));
     
   if(ObjectCreate(linenamenew, OBJ_RECTANGLE, 0, oldtime1, oldprice1, Time[i], oldprice2))
   {
    ObjectSet(linenamenew, OBJPROP_COLOR, oldcolor);
    ObjectSetText(linenamenew,linenamenew);
    ObjectDelete(linename);
   }
   else Alert("Cannot end ",linename," to create ",linenamenew," error: ",GetLastError());
   return;
  }
 }
 return;
}
//+------------------------------------------------------------------+
void CreateZone(string label1,double price1,double price2,int i,color CLR)
{
 if(ObjectCreate(label1, OBJ_RECTANGLE, 0, Time[i], price1,Time[1], price2))
 {
  ObjectSet(label1, OBJPROP_COLOR, CLR);
  ObjectSetText(label1,label1);  
 }
 else Alert("Cannot create ",label1," error: ",GetLastError());
 return;
}
//+------------------------------------------------------------------+
void UpdateLines()
{
 int objtotal=ObjectsTotal()-1,pos; string linename;

 for(int i=objtotal;i>=0;i--) 
 {
  linename=ObjectName(i);  
  pos=StringFind(linename,namebase);
  
  if(pos>=0) ObjectSet(linename,OBJPROP_TIME2,Time[0]);
  
 }
 return;
}
//+------------------------------------------------------------------+
void UpdateSupplyDemandImbalance(int i)
{
 SDI[i]=0;Ave[i]=0; 
 int j;

 double range1,range2,range3,range4,mid1,mid2,close0,close1,open0,open1,high0,high1,low0,low1;

 close0=iClose(NULL,TimeFrame,shift);
 close1=iClose(NULL,TimeFrame,shift+1);
  
 open0=iOpen(NULL,TimeFrame,shift);
 open1=iOpen(NULL,TimeFrame,shift+1);

 mid1=MathAbs(close0+open0);
 mid2=MathAbs(close1+open1);
  
 range1=0.5*MathAbs(mid1-mid2)/Point; // midpoint distance (midpoint of 1 minus midpoint of 2)

 mid1=MathAbs(close0-open0);
 mid2=MathAbs(close1-open1);
  
 range2=MathAbs(mid1-mid2)/Point; // difference of open/close range
  
 high0=iHigh(NULL,TimeFrame,shift);
 high1=iHigh(NULL,TimeFrame,shift+1);
  
 low0=iLow(NULL,TimeFrame,shift);
 low1=iLow(NULL,TimeFrame,shift+1);
   
 range3=MathAbs(high0-high1)/Point; // compare high distance 
 range4=MathAbs(low0-low1)/Point; // compare low distance
  
 SDI[i]=range1*range2*range3*range4;
  
 double average=0;
 for(j=i;j<i+BarMin;j++)
 {
  average+=SDI[j];
 }
  
 Ave[i]=average/BarMin; 
 return;
}
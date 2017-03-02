/*
xMeterMTF.mq4     
Copyright © 2007, MetaQuotes Software Corp.     
Price Meter System™ ©GPL     

Hartono Setiono
   5/17/2007 Redsigned based on xMeter_mini.mq4 indicator
*/

#property copyright "x Meter System™ ©GPL"
#property link      "forex-tsd dot com"
#property  indicator_chart_window
#property  indicator_buffers 0

#include <stdlib.mqh>
#include <stderror.mqh> 

#define TABSIZE  5                    // scale of currency's power !!!DON'T CHANGE THIS NUMBER!!!
#define ORDER    2                      // available type of order !!!DON'T CHANGE THIS NUMBER!!!

extern bool AccountIsIBFXmini = false;
extern int mTimeFrame = PERIOD_M15;
/*extern*/ bool LoopOnInit=false;

/* You can change any of the following arrays */
   string aTradePair[]= {"EURUSD"};
   string aPair[]   = {"EURUSD","GBPUSD","AUDUSD","NZDUSD","USDCHF","USDCAD","EURGBP","EURAUD","EURCHF","EURNZD","EURCAD","GBPAUD","GBPNZD","GBPCAD","GBPCHF","AUDCHF","AUDNZD","AUDCAD","NZDCAD","NZDCHF","CADCHF"};
                       
/* The following can also be changed but both must have the same dimension */
   string aMajor[] = {"USD","EUR","CHF","GBP","CAD","AUD","NZD"};
   int    aMajorPos[] = {130,110,90,70,50,30,10};


string aOrder[ORDER]    = {"BUY ","SELL "};
int    aTable[TABSIZE]  = {3,10,25,40,50,60,75,90,97,100};                 // grade table for currency's power

int PairCount;
int CurrencyCount;
double aMeter[];
double aHigh[];
double aLow[];
double aBid[];
double aAsk[];
double aRatio[];
double aRange[];
double aLookup[];
double aStrength[];
int aIndex[2][];

//+------------------------------------------------------------------+
//     expert initialization function                                |       
//+------------------------------------------------------------------+
int init()
  {
   int err,lastError, ps;
   PairCount=ArrayRange(aPair,0);
   CurrencyCount=ArrayRange(aMajor,0);
   ps=ArrayRange(aMajorPos,0);
   if(CurrencyCount!=ps) Print("The size of array aMajor is not equals to aMajorPos");

   ArrayResize(aMeter,CurrencyCount);
   ArrayResize(aHigh,PairCount);
   ArrayResize(aLow,PairCount);
   ArrayResize(aBid,PairCount);
   ArrayResize(aAsk,PairCount);
   ArrayResize(aRatio,PairCount);
   ArrayResize(aRange,PairCount);
   ArrayResize(aLookup,PairCount);
   ArrayResize(aStrength,PairCount);
   
   init_tradepair_index();
  
//----
   initGraph();
   if (LoopOnInit)
   {
      while (true)                                                           // infinite loop for main program
      {
        if (IsConnected()) main();
        if (!IsConnected()) objectBlank();
        WindowRedraw();
        Sleep(1000);                                                          // give your PC a breath
      }
   }
//----
   return(0);                                                               // end of init function
  }
//+------------------------------------------------------------------+
//     expert deinitialization function                              |       
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectsDeleteAll(0,OBJ_LABEL);
   Print("shutdown error - ",ErrorDescription(GetLastError()));                               // system is detached from platform
//----
   return(0);                                                               // end of deinit function
  }
//+------------------------------------------------------------------+
//     expert start function                                         |       
//+------------------------------------------------------------------+
int start()
  {
//----
   if (!LoopOnInit) main();
//----
   return(0);                                                               // end of start funtion
  }
//+------------------------------------------------------------------+
//     expert custom function                                        |       
//+------------------------------------------------------------------+    
void main()                                                                 // this a control center
  {
//----
   double point;
   int    index, pindex, cnt;
   string mySymbol;
   double cmeter;
     
   for (index = 0; index < PairCount; index++)                                // initialize all pairs required value 
   {
      RefreshRates();                                                       // refresh all currency's instrument
      if (AccountIsIBFXmini)
         mySymbol = StringConcatenate(aPair[index],"m");                                       // Add "m" for IBFX mini
      else
         mySymbol = aPair[index];                        
      point            = GetPoint(mySymbol);                                // get a point basis
      aHigh[index]     = iHigh(mySymbol,mTimeFrame,0); // MarketInfo(mySymbol,MODE_HIGH); //iHigh(mySymbol,mTimeFrame,iHighest(mySymbol,mTimeFrame,MODE_HIGH,mPeriod,0));   // find highest
      aLow[index]      = iLow(mySymbol,mTimeFrame,0); //iLow(mySymbol,mTimeFrame,iLowest(mySymbol,mTimeFrame,MODE_LOW,mPeriod,0));   // find lowest
      aBid[index]      = MarketInfo(mySymbol,MODE_BID);                 // set a last bid
      aAsk[index]      = MarketInfo(mySymbol,MODE_ASK);                 // set a last ask
      aRange[index]    = MathMax((aHigh[index]-aLow[index])/point,1);       // calculate range today
      aRatio[index]    = (aBid[index]-aLow[index])/aRange[index]/point;     // calculate pair ratio
      aLookup[index]   = iLookup(aRatio[index]*100);                        // set a pair grade
      aStrength[index] = 9.9-aLookup[index];                                  // set a pair strengh
  } 

   // calculate all currencies meter         
   for (pindex=0; pindex<CurrencyCount; pindex++)
   { 
     cnt=0; 
     cmeter=0;
     for (index = 0; index < PairCount; index++)                                // initialize all pairs required value 
     {
       if (StringSubstr(aPair[index],0,3)==aMajor[pindex])
       {
        cnt++;
        cmeter = cmeter + aLookup[index];
       }
       if (StringSubstr(aPair[index],3,3)==aMajor[pindex])
       {
        cnt++;
        cmeter = cmeter + aStrength[index];
       }
       if (cnt>0) aMeter[pindex]=NormalizeDouble(cmeter / cnt,1); else aMeter[pindex]=-1;
     }
   }
             
   objectBlank();
   
   for (pindex=0; pindex<CurrencyCount; pindex++)
   {
     paintCurr(pindex, aMeter[pindex]); 
   }
   paintLine();
                                                                            
//----
  }

void init_tradepair_index()
{
  int i,n,tpcount, m1index, m2index;
  string cpair, m1,m2;
  tpcount=ArraySize(aTradePair);
  
  for(n=0; n<tpcount; n++)
  {
    cpair=aTradePair[0];
    m1=StringSubstr(cpair,0,3);
    m2=StringSubstr(cpair,3,3);
    aIndex[0,n]=-1;
    aIndex[1,n]=-1;
    for(i=0;i<CurrencyCount;i++)
    {
      if(m1==aMajor[i]) aIndex[0,n]=i;
      if(m2==aMajor[i]) aIndex[1,n]=i;
    }
    if(aIndex[0,n]==-1 || aIndex[1,n]==-1) 
      Print("Currency Pair : ",cpair," is not tradeable, check array definition!");
  }
}
  
string GetSymbol(string mSymbol)
{
  string RetSymbol;
  if (AccountIsIBFXmini) RetSymbol = mSymbol + "m"; else RetSymbol = mSymbol;    
  return (RetSymbol);
}

double GetPoint(string mSymbol)
{
 double myPoint = 0.0001, YenPoint = 0.01;
 string mySymbol;
 if (StringSubstr(mySymbol,3,3) == "JPY") return (YenPoint);
 return(myPoint);
}
  
int iLookup(double ratio)                                                   // this function will return a grade value
  {                                                                         // based on its power.
   int   index=-1, i;
   
   if      (ratio <= aTable[0]) index = 0;
   else {
     for (i=1; i<TABSIZE; i++) if(ratio < aTable[i]) {index=i-1;  break; }
     if(index==-1) index=9.9;
   }
   return(index);                                                           // end of iLookup function
  }
  
void initGraph()
  {
   int pindex;
   ObjectsDeleteAll(0,OBJ_LABEL);

   for (pindex=0; pindex<CurrencyCount; pindex++)
   { 
   objectCreate(aMajor[pindex]+"_1",aMajorPos[pindex],43);
   objectCreate(aMajor[pindex]+"_2",aMajorPos[pindex],35);
   objectCreate(aMajor[pindex]+"_3",aMajorPos[pindex],27);
   objectCreate(aMajor[pindex]+"_4",aMajorPos[pindex],19);
   objectCreate(aMajor[pindex]+"_5",aMajorPos[pindex],11);
   objectCreate(aMajor[pindex],aMajorPos[pindex]+2,12,aMajor[pindex],7,"Arial Narrow",SkyBlue);
   objectCreate(aMajor[pindex]+"p",aMajorPos[pindex]+4,21,DoubleToStr(9,1),8,"Arial Narrow",Silver);
   }
   
   objectCreate("line",5,6,"-----------------------------------------",10,"Arial",Black);  
   objectCreate("line1",5,27,"------------------------------------------",10,"Arial",Black);  
   objectCreate("line2",5,69,"------------------------------------------",10,"Arial",Black);
   objectCreate("sign",5,1," - SS/F Consultoria Financeira -      ",8,"Arial Narrow",Black);
   WindowRedraw();
  }
//+------------------------------------------------------------------+
void objectCreate(string name,int x,int y,string text="-",int size=42,
                  string font="Arial",color colour=CLR_NONE)
  {
   ObjectCreate(name,OBJ_LABEL,0,0,0);
   ObjectSet(name,OBJPROP_CORNER,3);
   ObjectSet(name,OBJPROP_COLOR,colour);
   ObjectSet(name,OBJPROP_XDISTANCE,x);
   ObjectSet(name,OBJPROP_YDISTANCE,y);
   ObjectSetText(name,text,size,font,colour);
  }

void objectBlank()
  {
   int pindex;
   
   for (pindex=0; pindex<CurrencyCount; pindex++)
   { 
   ObjectSet(aMajor[pindex]+"_1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet(aMajor[pindex]+"_2",OBJPROP_COLOR,CLR_NONE);
   ObjectSet(aMajor[pindex]+"_3",OBJPROP_COLOR,CLR_NONE);
   ObjectSet(aMajor[pindex]+"_4",OBJPROP_COLOR,CLR_NONE);
   ObjectSet(aMajor[pindex]+"_5",OBJPROP_COLOR,CLR_NONE);
   ObjectSet(aMajor[pindex],OBJPROP_COLOR,CLR_NONE);
   ObjectSet(aMajor[pindex]+"p",OBJPROP_COLOR,CLR_NONE);
   }
  
   ObjectSet("line1",OBJPROP_COLOR,CLR_NONE);
   ObjectSet("line2",OBJPROP_COLOR,CLR_NONE); 
  }
  
void paintCurr(int pindex, double value)
{
  if (value > 0) ObjectSet(aMajor[pindex]+"_5",OBJPROP_COLOR,Red);
  if (value > 2) ObjectSet(aMajor[pindex]+"_4",OBJPROP_COLOR,Orange);
  if (value > 4) ObjectSet(aMajor[pindex]+"_3",OBJPROP_COLOR,Gold);   
  if (value > 6) ObjectSet(aMajor[pindex]+"_2",OBJPROP_COLOR,YellowGreen);
  if (value > 7) ObjectSet(aMajor[pindex]+"_1",OBJPROP_COLOR,Lime);
  ObjectSet(aMajor[pindex],OBJPROP_COLOR,Black);
  ObjectSetText(aMajor[pindex]+"p",DoubleToStr(value,1),8,"Arial Narrow",Black);
}
  
void paintLine()
  {
   ObjectSet("line1",OBJPROP_COLOR,DimGray);
   ObjectSet("line2",OBJPROP_COLOR,DimGray);
  }
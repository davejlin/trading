//+----------------------------------------------------------------------+
//|                                                Fractal RS Trader.mq4 |
//|                                                         David J. Lin |
//| Fractal RS Trader (Fractal Resistance & Support Trader)              |
//| written for geneva wheeless (gkw1018@yahoo.com)                      |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|dave.j.lin@sbcglobal.net                                              |
//|Evanston, IL, September 25, 2007                                      |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2007, David J. Lin"
#property link      ""

// User adjustable parameters:

extern bool Entry1=true;           // true = activate entry method
extern bool Entry2=true;            // true = activate entry method
extern bool Entry3=true;           // true = activate entry method

extern double Trigger1Retrace=0.50; // fraction of Trigger 1 trigger-bar retracement for entry
extern int Trigger1Window=10;        // number of bars after trigger-bar window of opportunity for Trigger 1 entry
extern double Trigger3Retrace=0.618;// fraction of normal fractal R-to-S distance retracement for Trigger 3 entry
extern int Trigger3Window=10;        // number of bars after Fractal RS line violation window of opportunity for Trigger 3 entry

                                  // Lottage:  enter zero ("0") if order is undesired 

extern double Lots11=0.01;         // Trigger 1 Order 1 lottage per trade
extern double Lots12=0.01;         // Trigger 1 Order 2 lottage per trade
extern double Lots13=0.01;         // Trigger 1 Order 3 lottage per trade
extern double Lots21=0.01;         // Trigger 2 Order 1 lottage per trade
extern double Lots22=0.01;         // Trigger 2 Order 2 lottage per trade
extern double Lots23=0.01;         // Trigger 2 Order 3 lottage per trade
extern double Lots31=0.01;         // Trigger 3 Order 1 lottage per trade
extern double Lots32=0.01;         // Trigger 3 Order 2 lottage per trade
extern double Lots33=0.01;         // Trigger 3 Order 3 lottage per trade

                                   // Take Profits:
                                   // positive values = pip TP
                                   // zero ("0") = appropriate arm-pit value at time of order inception
                                   // negative value = nearest pre-existing Fractal RS line

extern int TakeProfit11=50;         // Trigger 1 Order 1 pips desired TP
extern int TakeProfit12=100;         // Trigger 1 Order 2 pips desired TP
extern int TakeProfit13=-1;         // Trigger 1 Order 3 pips desired TP
extern int TakeProfit21=50;         // Trigger 2 Order 1 pips desired TP
extern int TakeProfit22=100;         // Trigger 2 Order 2 pips desired TP
extern int TakeProfit23=-1;         // Trigger 2 Order 3 pips desired TP
extern int TakeProfit31=50;         // Trigger 3 Order 1 pips desired TP
extern int TakeProfit32=100;         // Trigger 3 Order 2 pips desired TP
extern int TakeProfit33=-1;         // Trigger 3 Order 3 pips desired TP

                                   // Stop Losses:
                                   // positive values = pip SL
                                   // zero ("0") = contrary normal Fractal resistance/support level at time of order inception
                                   // negative value = close under the contrary normal Fractal resistance/support level at time of order inception

extern int StopLoss11=50;           // Trigger 1 Order 1 pips desired SL
extern int StopLoss12=0;           // Trigger 1 Order 2 pips desired SL
extern int StopLoss13=-1;           // Trigger 1 Order 3 pips desired SL 
extern int StopLoss21=50;           // Trigger 2 Order 1 pips desired SL
extern int StopLoss22=0;           // Trigger 2 Order 2 pips desired SL
extern int StopLoss23=-1;           // Trigger 2 Order 3 pips desired SL 
extern int StopLoss31=50;           // Trigger 3 Order 1 pips desired SL
extern int StopLoss32=0;           // Trigger 3 Order 2 pips desired SL
extern int StopLoss33=-1;           // Trigger 3 Order 3 pips desired SL 

extern int StopLossSafety=50;       // safety SL value for Stop-Loss based on opposite new-Fractal RS formation

                                    // Trail: for every additional TrailProfit of profit, raise the SL by TrailMove to lock in more profit
                                    // use "TrailProfit=0" if trail is not desired
                                    // use a negative percentage value if trail is based on normal Fractal RS distance
                                    
extern int TrailProfitMIN=10;       // MINIMUM pips desired TrailProfit
extern int TrailMoveMIN=1;          // MINIMUM Order 1 pips desired TrailMove

extern int TrailProfit11=-50;       // Trigger 1 Order 1 pips desired TrailProfit
extern int TrailMove11=-10;         // Trigger 1 Order 1 pips desired TrailMove
extern int TrailProfit12=25;        // Trigger 1 Order 2 pips desired TrailProfit
extern int TrailMove12=5;           // Trigger 1 Order 2 pips desired TrailMove
extern int TrailProfit13=40;        // Trigger 1 Order 3 pips desired TrailProfit
extern int TrailMove13=10;          // Trigger 1 Order 3 pips desired TrailMove
extern int TrailProfit21=-50;       // Trigger 2 Order 1 pips desired TrailProfit
extern int TrailMove21=-10;         // Trigger 2 Order 1 pips desired TrailMove
extern int TrailProfit22=25;        // Trigger 2 Order 2 pips desired TrailProfit
extern int TrailMove22=5;           // Trigger 2 Order 2 pips desired TrailMove
extern int TrailProfit23=40;        // Trigger 2 Order 3 pips desired TrailProfit
extern int TrailMove23=10;          // Trigger 2 Order 3 pips desired TrailMove
extern int TrailProfit31=-50;       // Trigger 3 Order 1 pips desired TrailProfit
extern int TrailMove31=-10;         // Trigger 3 Order 1 pips desired TrailMove
extern int TrailProfit32=25;        // Trigger 3 Order 2 pips desired TrailProfit
extern int TrailMove32=5;           // Trigger 3 Order 2 pips desired TrailMove
extern int TrailProfit33=40;        // Trigger 3 Order 3 pips desired TrailProfit
extern int TrailMove33=10;          // Trigger 3 Order 3 pips desired TrailMove

extern int NoTradeHourStart=-1;      // platform time inclusive (use negative value to turn off)
extern int NoTradeHourEnd=-1;        // platform time inclusive (use negative value to turn off)

extern datetime StartDate=D'2007.09.15';
// Internal usage parameters:
int Slippage=3,bo=1;
double Lots[3,3];
int magic[3,3],TakeProfit[3,3],StopLoss[3,3],TrailProfit[3,3],TrailMove[3,3];
string comment[3,3];
datetime ot[3];
int lotsprecision=2;
double lotsmin,lotsmax;
color clrL=Blue,clrS=Red;
string strL="FractRS L",strS="FractRS S";
int code=1,Norders=3;
bool LongExit,ShortExit;//LongExitSL,ShortExitSL;
datetime lasttime,tlastViolateS,tlastViolateR;
int FractUpi, FractDowni;
double FractUp, FractDown;
double lastResistance,lastSupport,lastestResistance,lastestSupport;
double Trig1LongTarget,Trig1ShortTarget,Trig3LongTarget,Trig3ShortTarget;
double LastR[100],LastS[100],LastRt[100],LastSt[100];
int NR=0,NS=0;
bool first=true;
int maxindex,minindex;
double maxvalue,minvalue,ArmPitUpTP,ArmPitDnTP;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//----

 lotsmin=MarketInfo(Symbol(),MODE_MINLOT); 
 lotsmax=MarketInfo(Symbol(),MODE_MAXLOT);

 if(lotsmin==0.10) lotsprecision=1;

 Lots[0,0]=Lots11;
 Lots[0,1]=Lots12;
 Lots[0,2]=Lots13;
 Lots[1,0]=Lots21;
 Lots[1,1]=Lots22;
 Lots[1,2]=Lots23;
 Lots[2,0]=Lots31;
 Lots[2,1]=Lots32;
 Lots[2,2]=Lots33;   
 
 StopLoss[0,0]=StopLoss11;
 StopLoss[0,1]=StopLoss12;
 StopLoss[0,2]=StopLoss13;
 StopLoss[1,0]=StopLoss21;
 StopLoss[1,1]=StopLoss22;
 StopLoss[1,2]=StopLoss23;
 StopLoss[2,0]=StopLoss31;
 StopLoss[2,1]=StopLoss32;
 StopLoss[2,2]=StopLoss33;   
 
 TakeProfit[0,0]=TakeProfit11;
 TakeProfit[0,1]=TakeProfit12;
 TakeProfit[0,2]=TakeProfit13;
 TakeProfit[1,0]=TakeProfit21;
 TakeProfit[1,1]=TakeProfit22;
 TakeProfit[1,2]=TakeProfit23;
 TakeProfit[2,0]=TakeProfit31;
 TakeProfit[2,1]=TakeProfit32;
 TakeProfit[2,2]=TakeProfit33;   

 TrailProfit[0,0]=TrailProfit11;
 TrailProfit[0,1]=TrailProfit12;
 TrailProfit[0,2]=TrailProfit13;
 TrailProfit[1,0]=TrailProfit21;
 TrailProfit[1,1]=TrailProfit22;
 TrailProfit[1,2]=TrailProfit23;
 TrailProfit[2,0]=TrailProfit31;
 TrailProfit[2,1]=TrailProfit32;
 TrailProfit[2,2]=TrailProfit33;

 TrailMove[0,0]=TrailMove11;
 TrailMove[0,1]=TrailMove12;
 TrailMove[0,2]=TrailMove13;
 TrailMove[1,0]=TrailMove21;
 TrailMove[1,1]=TrailMove22;
 TrailMove[1,2]=TrailMove23;
 TrailMove[2,0]=TrailMove31;
 TrailMove[2,1]=TrailMove32;
 TrailMove[2,2]=TrailMove33; 
 
 magic[0,0] =200000+Period(); 
 magic[0,1] =200001+Period();
 magic[0,2] =200002+Period();
 magic[1,0] =210000+Period(); 
 magic[1,1] =210001+Period();
 magic[1,2] =210002+Period();   
 magic[2,0] =220000+Period(); 
 magic[2,1] =220001+Period();
 magic[2,2] =220002+Period(); 
 
 string pd;
 switch(Period())
 {
  case 1:     pd="M1"; break;
  case 5:     pd="M5"; break;
  case 15:    pd="M15";break;
  case 30:    pd="M30";break;
  case 60:    pd="H1"; break;
  case 240:   pd="H4"; break;
  case 1440:  pd="D1"; break;
  case 10080: pd="W1"; break;
  case 40320: pd="M1"; break;
  default:    pd="Unknown";break;
 }
 comment[0,0]  =StringConcatenate(pd," FractRS 11"); 
 comment[0,1]  =StringConcatenate(pd," FractRS 12"); 
 comment[0,2]  =StringConcatenate(pd," FractRS 13");   
 comment[1,0]  =StringConcatenate(pd," FractRS 21"); 
 comment[1,1]  =StringConcatenate(pd," FractRS 22"); 
 comment[1,2]  =StringConcatenate(pd," FractRS 23");
 comment[2,0]  =StringConcatenate(pd," FractRS 31"); 
 comment[2,1]  =StringConcatenate(pd," FractRS 32"); 
 comment[2,2]  =StringConcatenate(pd," FractRS 33");

// First check closed trades
 int trade;                         
 int trades=OrdersHistoryTotal();           
 for(trade=0;trade<trades;trade++)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_HISTORY);

  if(OrderSymbol()!=Symbol())
   continue;

  int D1bars=iBarShift(NULL,PERIOD_D1,OrderCloseTime(),false);
  if(D1bars>30)
   continue;
   
  Status(OrderMagicNumber());
 }

// Now check open orders
                       
 trades=OrdersTotal();           
 for(trade=0;trade<trades;trade++)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()!=Symbol())
   continue;

  Status(OrderMagicNumber());
  if(OrderType()==OP_BUY)       DrawCross(OrderOpenPrice(),OrderOpenTime(),strL,clrL,code);
  else if(OrderType()==OP_SELL) DrawCross(OrderOpenPrice(),OrderOpenTime(),strS,clrS,code);
 }
 
 first=true;
 NR=0;NS=0;
 HideTestIndicators(true);
 ArmPitTargets();
 ManageOrders();
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
//---- 
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{ 
 if(noRun()) return(0);
//----
 if(lasttime!=iTime(NULL,0,0)) 
 {
  Signals();
  ArmPitTargets();  
 }
 lasttime=iTime(NULL,0,0);
 SubmitOrders();
 ExitSignals();  
 ManageOrders();
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert utility functions                                         |
//+------------------------------------------------------------------+

void SubmitOrders()
{
 if (Entry1) Trigger1();
             Trigger2(); //if (Entry2) ... condition for Entry2 internal ... required for Entry3
 if (Entry3) Trigger3();
 return;
}
//+------------------------------------------------------------------+
void Trigger1()
{ 
 int i,checktime=iBarShift(NULL,0,ot[0],false);
 if(checktime<bo) return;

 double lots,SL,TP; 

 if(Bid<=Trig1LongTarget)
 {
  if(Filter(true))
  {
   for(i=0;i<Norders;i++)
   {
    lots=Lots[0,i];
    if(lots<=0) continue;
    if(StopLoss[0,i]<0) SL=StopLong(Ask,StopLossSafety);
    else SL=StopLong(Ask,StopLoss[0,i]);
    TP=TakeLong(Ask,TakeProfit[0,i]);
    SendOrderLong(Symbol(),lots,Slippage,SL,TP,comment[0,i],magic[0,i],0,Blue);
   }
   ot[0]=TimeCurrent();
  }
 }
 
 if(Bid>=Trig1ShortTarget)
 {
  if(Filter(false))
  {  
   for(i=0;i<Norders;i++)
   {   
    lots=Lots[0,i];
    if(lots<=0) continue;     
    if(StopLoss[0,i]<0) SL=StopShort(Bid,StopLossSafety);
    else SL=StopShort(Bid,StopLoss[0,i]);
    TP=TakeShort(Bid,TakeProfit[0,i]);
    SendOrderShort(Symbol(),lots,Slippage,SL,TP,comment[0,i],magic[0,i],0,Red); 
   }
   ot[0]=TimeCurrent();
  }
 }
 
 return;
}
//+------------------------------------------------------------------+
void Trigger2()
{ 
 int i,checktime=iBarShift(NULL,0,ot[1],false);
 if(checktime<bo) return;

 double lots,SL,TP; 

 if(NR>0)
 {
  if(LastR[NR]==lastestResistance)
  {
   if(Bid<=LastR[NR])
   {
    if(Filter(true))
    {
     if(Entry2)
     {
      for(i=0;i<Norders;i++)
      {
       lots=Lots[1,i];
       if(lots<=0) continue;     
       if(StopLoss[1,i]<0) SL=StopLong(Ask,StopLossSafety);
       else SL=StopLong(Ask,StopLoss[1,i]);
       TP=TakeLong(Ask,TakeProfit[1,i]);
       SendOrderLong(Symbol(),lots,Slippage,SL,TP,comment[1,i],magic[1,i],0,Blue);
      }
     }
    }
    ot[1]=TimeCurrent();
    // Trigger 3 setup;
    tlastViolateR=TimeCurrent();
    Trig3LongTarget=NormDigits(LastR[NR]-(Trigger3Retrace*(FractUp-FractDown)));
   }
  } 
 }
 
 if(NS>0)
 {
  if(LastS[NS]==lastestSupport)
  { 
   if(Bid>=LastS[NS])
   {
    if(Filter(false))
    {  
     if(Entry2)
     {    
      for(i=0;i<Norders;i++)
      {   
       lots=Lots[1,i];
       if(lots<=0) continue;     
       if(StopLoss[1,i]<0) SL=StopShort(Bid,StopLossSafety);
       else SL=StopShort(Bid,StopLoss[1,i]);
       TP=TakeShort(Bid,TakeProfit[1,i]);
       SendOrderShort(Symbol(),lots,Slippage,SL,TP,comment[1,i],magic[1,i],0,Red);  
      }
     } 
     ot[1]=TimeCurrent();
     // Trigger 3 setup;     
     tlastViolateS=TimeCurrent();
     Trig3ShortTarget=NormDigits(LastS[NS]+(Trigger3Retrace*(FractUp-FractDown)));    
    }
   }
  }
 }
 return;
}
//+------------------------------------------------------------------+
void Trigger3()
{     
 int i,checktime=iBarShift(NULL,0,ot[2],false);
 if(checktime<bo) return;

 double lots,SL,TP; 

 checktime=iBarShift(NULL,0,tlastViolateR);
 
 if(checktime<Trigger3Window)
 {
  if(Trig3LongTarget!=EMPTY_VALUE)
  { 
   if(Bid<=Trig3LongTarget)
   {
    if(Filter(true))
    {
     for(i=0;i<Norders;i++)
     {
      lots=Lots[2,i];
      if(lots<=0) continue;     
      if(StopLoss[2,i]<0) SL=StopLong(Ask,StopLossSafety);
      else SL=StopLong(Ask,StopLoss[2,i]);
      TP=TakeLong(Ask,TakeProfit[2,i]);
      SendOrderLong(Symbol(),lots,Slippage,SL,TP,comment[2,i],magic[2,i],0,Blue);
     }
     ot[2]=TimeCurrent();    
     Trig3LongTarget=EMPTY_VALUE;    
    }
   }
  }
 }

 checktime=iBarShift(NULL,0,tlastViolateS); 

 if(checktime<Trigger3Window)
 {
  if(Trig3ShortTarget!=EMPTY_VALUE)
  {
   if(Bid>=Trig3ShortTarget)
   {
    if(Filter(false))
    {  
     for(i=0;i<Norders;i++)
     {   
      lots=Lots[2,i];
      if(lots<=0) continue;     
      if(StopLoss[2,i]<0) SL=StopShort(Bid,StopLossSafety);
      else SL=StopShort(Bid,StopLoss[2,i]);
      TP=TakeShort(Bid,TakeProfit[2,i]);
      SendOrderShort(Symbol(),lots,Slippage,SL,TP,comment[2,i],magic[2,i],0,Red);       
     }
     ot[2]=TimeCurrent();
     Trig3ShortTarget=EMPTY_VALUE;      
    }
   }
  }
 }
 return;
}
//+------------------------------------------------------------------+
void Signals()
{
 FractalRS();
 FractalLatest();
 Signals1();
// Signals2();
// Signals3();
 return;
}
//+------------------------------------------------------------------+
void Signals1()
{ 
 int i;
 double open,close,high,low,high2,low2,trigprice;
 Trig1LongTarget=0; Trig1ShortTarget=999999999;
 
 for(i=FractUpi-1;i>=1;i--)
 {
  if(i>Trigger1Window) continue;
//   open=iOpen(NULL,0,i);
//   close=iClose(NULL,0,i);
  high=iHigh(NULL,0,i);
  low=iLow(NULL,0,i); 
 
  if(high>FractUp)
  {
   if(iTime(NULL,0,i)>ot[0])
   {
    trigprice=NormDigits(high-(Trigger1Retrace*(high-low)));
    if(trigprice<FractUp) Trig1LongTarget=trigprice;
    else                  Trig1LongTarget=0;
   }
  }
 }
 
 for(i=FractDowni-1;i>=1;i--)
 {
  if(i>Trigger1Window) continue;
//   open=iOpen(NULL,0,i);
//   close=iClose(NULL,0,i);
  high=iHigh(NULL,0,i);
  low=iLow(NULL,0,i); 
 
  if(low<FractDown)
  {
   if(iTime(NULL,0,i)>ot[0])
   {
    trigprice=NormDigits(low+(Trigger1Retrace*(high-low)));
    if(trigprice>FractDown) Trig1ShortTarget=trigprice;
    else                    Trig1ShortTarget=999999999;
   }
  }  
 }
 return;
}
//+------------------------------------------------------------------+
void FractalLatest()
{
 int i;
 for(i=3;i<1000;i++)
 {
  if(iFractals(NULL,0, MODE_UPPER, i)<=0) continue;
//  FractUp=iHigh(NULL,PERIOD_H1,i);
  FractUpi=i;
  break;
 }

 for(i=3;i<1000;i++)
 {
  if(iFractals(NULL,0, MODE_LOWER, i)<=0) continue;
//  FractDown=iLow(NULL,PERIOD_H1,i);
  FractDowni=i;
  break;
 } 
 return;
}
//+------------------------------------------------------------------+
void FractalRS()
{
 int i,imax,iaug;
 double Fup,Fdn,close,open,low,high,price;
 bool newS,newR;
 
 if(first) 
 {
  int shift=iBarShift(NULL,0,StartDate,false);  
  imax=shift-2; 
  lastResistance=EMPTY_VALUE;
  lastSupport=EMPTY_VALUE;
  first=false;
 } 
 else imax=1;

 for(i=imax;i>=1;i--)
 {   
//  LongExitSL=false;ShortExitSL=false;
  iaug=i+2;
  Fup=iFractals(NULL,0,MODE_UPPER,iaug);
  if(Fup>0) 
  {
   FractUp=iHigh(NULL,0,iaug);
   lastResistance=EMPTY_VALUE; // refresh for a new fractal
  }
  
  Fdn=iFractals(NULL,0,MODE_LOWER,iaug);
  if(Fdn>0) 
  { 
   FractDown=iLow(NULL,0,iaug);
   lastSupport=EMPTY_VALUE; // refresh for a new fractal
  }

  close=NormDigits(iClose(NULL,0,i));
  open =NormDigits(iOpen(NULL,0,i));
  low  =NormDigits(iLow(NULL,0,i));
  high =NormDigits(iHigh(NULL,0,i));
  
  newS=false;
  if(FractDown!=lastSupport) 
  {
   if(close<FractDown && open<FractDown)
   {
    FractalArray(FractDown,high,low,true,true);
    lastSupport=FractDown;    
    lastestSupport=FractDown; // need latest to avoid entering upon pre-existing FRS line
    newS=true;
//    LongExitSL=true;
    Trig3ShortTarget=EMPTY_VALUE;
   }
  }

  if(!newS)
  {
   if(NS>0)
   {
    price=LastS[NS];
    if(high>=price)
    {   
     // Trig 3 setup:      
     tlastViolateS=TimeCurrent();     
     // Demote Array
     FractalArray(price,high,low,true,false);
     lastSupport=price;  // avoid marking the same fractal after violation
    }
   }
  }

  newR=false;
  if(FractUp!=lastResistance) 
  {
   if(close>FractUp && open>FractUp)
   {
    FractalArray(FractUp,high,low,false,true);
    lastResistance=FractUp;
    lastestResistance=FractUp; // need latest to avoid entering upon pre-existing FRS line
    newR=true;
//    ShortExitSL=true;    
    Trig3LongTarget=EMPTY_VALUE;     
   } 
  }

  if(!newR)
  {
   if(NR>0)
   {
    price=LastR[NR];    
    if(low<=price)
    {
     // Trig 3 setup:
     tlastViolateR=TimeCurrent();  
     // Demote Array
     FractalArray(FractUp,high,low,false,false);
     lastResistance=price;  // avoid marking the same fractal after violation     
    } 
   }
  }

 }  
 return;
}
//+------------------------------------------------------------------+
void FractalArray(double price, double high, double low, bool SupRes, bool AddSub)
{
 int i;
 
 if(NS>99) Alert("Warning ... Support Array limit of 100 exceeded!");
 if(NR>99) Alert("Warning ... Resistance Array limit of 100 exceeded!");
 
 if(SupRes)
 {
  if(AddSub)
  {
   NS++;
   LastS[NS]=price;
   LastSt[NS]=iTime(NULL,0,0);
  }
  else
  {
   for(i=NS;i>=1;i--)
   {
    if(high>=LastS[i])
    {
     NS--;         
    }
    else break;
   }
  }
 }
 else
 {
  if(AddSub)
  {
   NR++;      
   LastR[NR]=price;  
   LastRt[NR]=iTime(NULL,0,0);    
  }
  else
  {
   for(i=NR;i>=1;i--)
   {
    if(low<=LastR[i])
    {
     NR--;        
    }
    else break;
   }  
  }
 }
 return;
}
//+------------------------------------------------------------------+
void FractalSL(int shift, int flag=0)
{
 int i;double close;
 switch(flag)
 {
  case 0:
   if(OrderType()==OP_SELL)
   {
    for(i=shift+2;i<1000;i++)
    {
     if(iFractals(NULL,0, MODE_UPPER, i)<=0) continue;
   
     if(Bid>iHigh(NULL,0,i)) ExitOrder(false,true,2);
   
     break;
    }
   }
   else if(OrderType()==OP_BUY)
   {
    for(i=shift+2;i<1000;i++)
    {
     if(iFractals(NULL,0, MODE_LOWER, i)<=0) continue;

     if(Bid<iLow(NULL,0,i)) ExitOrder(true,false,2);

     break;
    } 
   }
  break;
  case 1:
   if(OrderType()==OP_SELL)
   {
    for(i=shift+2;i<1000;i++)
    {
     if(iFractals(NULL,0, MODE_UPPER, i)<=0) continue;
   
     close=iClose(NULL,0,1);
     if(close>iHigh(NULL,0,i)) ExitOrder(false,true,2);
   
     break;
    }
   }
   else if(OrderType()==OP_BUY)
   {
    for(i=shift+2;i<1000;i++)
    {
     if(iFractals(NULL,0, MODE_LOWER, i)<=0) continue;

     close=iClose(NULL,0,1);
     if(close<iLow(NULL,0,i)) ExitOrder(true,false,2);

     break;
    } 
   }   
  break;
 }

 return;
}
//+------------------------------------------------------------------+
void ManageOrders()
{
 int i,j,mn,trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  
  mn=OrderMagicNumber();
  for(i=0;i<Norders;i++)
  {
   for(j=0;j<Norders;j++)
   {
    if(mn==magic[i,j]) 
    {
     ManageOrder(i,j);
    }
   } 
  }
 
 }
 return;
}
//+------------------------------------------------------------------+
void ManageOrder(int i, int j)
{
 double profit=DetermineProfit();
 int shift=iBarShift(NULL,0,OrderOpenTime(),false);

 if(TakeProfit[i,j]<0)
 {
  if(profit>0) ExitOrder(LongExit,ShortExit,1); 
 }
 else if(TakeProfit[i,j]==0 && OrderTakeProfit()==0.0) // in case no Arm Pit TP
 {
  if(profit>0) ExitOrder(LongExit,ShortExit,1); 
 } 
 
 if(StopLoss[i,j]<0) 
 {
//  if(profit<0) ExitOrder(LongExitSL,ShortExitSL,2); // newly formed Fractal RS Line: not desired (10/17/07)
  if(profit<0) FractalSL(shift,1);  
 }
 else if(StopLoss[i,j]==0)
 {
  FractalSL(shift);
 } 
  
 if(TrailProfit[i,j]!=0) 
 {
  if(TrailProfit[i,j]>0) // pip trail
  {
   if(profit>=NormPoints(TrailProfit[i,j]))
   {
    QuantumTrailingStop(TrailProfit[i,j],TrailMove[i,j]);  
    FixedStopsB(TrailProfit[i,j],TrailMove[i,j]);
   }
  }
  else // percentage trail
  {
   int trailprofit,trailmove,fractdiff=(FractUp-FractDown)/Point;
   trailprofit=-0.01*TrailProfit[i,j]*fractdiff;
   trailprofit=MathMax(trailprofit,TrailProfitMIN);
   trailmove=-0.01*TrailMove[i,j]*fractdiff;
   trailmove=MathMax(trailmove,TrailMoveMIN);
   {
    QuantumTrailingStop(trailprofit,trailmove);  
    FixedStopsB(trailprofit,trailmove);
   }  
  }
 }
 return;
}
//+------------------------------------------------------------------+
void ExitSignals()
{
 LongExit=false;ShortExit=false;
 if(NR>0)
 {
  if(Bid==LastR[NR]) ShortExit=true;
 }
 if(NS>0)
 {
  if(Bid==LastS[NS]) LongExit=true;
 }
 return;
}
//+------------------------------------------------------------------+
bool Filter(bool long)
{
 int Trigger[1], totN=1,N,i,j,k;
 double value[2],index[2];
 bool trig;
 
 for(i=0;i<totN;i++) Trigger[i]=-1;

 if(long) // long filters
 {
  for(i=0;i<totN;i++)
  {
   switch(i)
   { 
    case 0:
    N=0;
    for(j=3;j<1000;j++)
    {
     if(iFractals(NULL,0, MODE_LOWER, j)<=0) continue;
     value[N]=iLow(NULL,0,j);
     index[N]=j;
     N++;
     if(N>1) break;
    }
    if(value[1]<value[0]&&value[1]<Bid&&value[0]<Bid) 
    {
     trig=true;    
     for(k=0;k<=index[1]-1;k++) // 11/16/07 avoid entries if price exceeded the 2nd fractal any time
     {
      if(iLow(NULL,0,k)<value[0])
      {
       trig=false;
       break;
      }
     }
     if(trig) Trigger[i]=1;     
    }
    break;  
   }
   if(Trigger[i]<0) return(false);       
  } 
 }
 else // short filters
 {
  for(i=0;i<totN;i++)
  {
   switch(i)
   { 
    case 0:
    N=0;
    for(j=3;j<1000;j++)
    {
     if(iFractals(NULL,0, MODE_UPPER, j)<=0) continue;
     value[N]=iHigh(NULL,0,j);
     index[N]=j;     
     N++;
     if(N>1) break;
    }
    if(value[1]>value[0]&&value[1]>Bid&&value[0]>Bid) 
    {
     trig=true;    
     for(k=0;k<=index[1]-1;k++) // 11/16/07 avoid entries if price exceeded 2nd fractal any time
     {
      if(iHigh(NULL,0,k)>value[0])
      {
       trig=false;
       break;
      }
     }
     if(trig) Trigger[i]=1;     
    }
    break;  
   }
   if(Trigger[i]<0) return(false);    
  }
 }

 return(true);  // no anti-trigger:  so, return true (to order)
}

//+------------------------------------------------------------------+

int SendOrderLong(string sym, double vol, int slip, double sl, double tp, string comment="", int m=0, datetime exp=0, color cl=CLR_NONE)
{  
 if(vol==0.00) return;
 int err;
 bool attempt=true;
 while(attempt)
 {
  if(IsTradeAllowed())
  {
   for(int z=0;z<5;z++)
   {  
    if(OrderSend(sym,OP_BUY,NormLots(vol),Ask,slip,NormDigits(sl),NormDigits(tp),comment,m,exp,cl)<0)
    {  
     err = GetLastError();
     Print("OrderSend Long failed, Error: ", err);
     Print("Ask: ", Ask, " S/L ", sl, " T/P ", tp);
     if(err>4000)
     { 
      attempt=false;
      break;
     }     
     RefreshRates();
    }
    else 
    {
     attempt=false;
     break;
    }
   }
  }
 }
 return(0);
}
//+------------------------------------------------------------------+

int SendOrderShort(string sym, double vol, int slip, double sl, double tp, string comment="", int m=0, datetime exp=0, color cl=CLR_NONE)
{  
 if(vol==0.00) return;
 int err;
 bool attempt=true;
 while(attempt)
 {
  if(IsTradeAllowed())
  {
   for(int z=0;z<5;z++)
   {  
    if(OrderSend(sym,OP_SELL,NormLots(vol),Bid,slip,NormDigits(sl),NormDigits(tp),comment,m,exp,cl)<0)
    {  
     err = GetLastError();
     Print("OrderSend Short failed, Error: ", err);
     Print("Bid: ", Bid, " S/L ", sl, " T/P ", tp);   
     if(err>4000)
     { 
      attempt=false;
      break;
     }     
     RefreshRates();
    }
    else 
    {
     attempt=false;
     break;
    }
   }
  }
 }
 return(0);
}

//+------------------------------------------------------------------+
bool CloseOrderLong(int ticket, double lots, int slip, color cl=CLR_NONE)
{ 
 bool attempt=true;
 while(attempt)
 {
  if(IsTradeAllowed())
  {
   for(int z=0;z<10;z++)
   {
    if(!OrderClose(ticket,NormLots(lots),Bid,slip,cl))
    {  
     int err = GetLastError();
     Print("OrderClose Long failed, Error: ", err, " Ticket #: ", ticket);
     Print("Bid: ", Bid);   
     if(err>4000)
     { 
      attempt=false;
      break;
     }     
     RefreshRates();
    }
    else
    {
     attempt=false;
     break;
    }
   }
  }
 }
 return(true);
} 
//+------------------------------------------------------------------+
bool CloseOrderShort(int ticket, double lots, int slip, color cl=CLR_NONE)
{
 bool attempt=true;
 while(attempt)
 {
  if(IsTradeAllowed())
  {
   for(int z=0;z<10;z++)
   {
    if(!OrderClose(ticket,NormLots(lots),Ask,slip,cl))
    {  
     int err = GetLastError();
     Print("OrderClose Short failed, Error: ", err, " Ticket #: ", ticket);
     Print("Ask: ", Ask);   
     if(err>4000)
     { 
      attempt=false;
      break;
     }     
     RefreshRates();
    }
    else
    {
     attempt=false;
     break;
    }
   }
  }
 }
 return(true);
} 
//+------------------------------------------------------------------+

void ModifyCompLong(double stopcal, double stopcrnt)
{
 stopcal=NormDigits(stopcal);
 stopcrnt=NormDigits(stopcrnt);

 if (stopcal==stopcrnt) return;
 
 if(stopcal>stopcrnt)
 {                     
  ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Blue); 
 }
 return;
}
//+------------------------------------------------------------------+

void ModifyCompShort(double stopcal, double stopcrnt)
{
 stopcal=NormDigits(stopcal);
 stopcrnt=NormDigits(stopcrnt);

 if (stopcal==stopcrnt) return;
  
 if(stopcrnt==0)
 { 
  ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red);     
 }
 else if(stopcal<stopcrnt&&stopcal!=0)
 {
  ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red); 
 }
 return;
}
//+------------------------------------------------------------------+
double StopLong(double price,int stop) // function to calculate normal stoploss if long
{
 if(stop<=0) return(0.0);
 return(NormDigits(price-NormPoints(stop))); 
}
//+------------------------------------------------------------------+
double StopShort(double price,int stop) // function to calculate normal stoploss if short
{
 if(stop<=0) return(0.0);
 return(NormDigits(price+NormPoints(stop))); 
}
//+------------------------------------------------------------------+
double TakeLong(double price,int take)  // function to calculate takeprofit if long
{
 if(take<0) return(0.0);
 if(take==0) // Arm Pit TPs
 {
  if(price>=ArmPitUpTP) return(0.0);
  else return(ArmPitUpTP);
 }
 
 return(NormDigits(price+NormPoints(take))); 
}
//+------------------------------------------------------------------+
double TakeShort(double price,int take)  // function to calculate takeprofit if short
{
 if(take<0) return(0.0); // if no take profit
 if(take==0) // Arm Pit TPs
 {
  if(price<=ArmPitDnTP) return(0.0);
  else return(ArmPitDnTP);
 }

 return(NormDigits(price-NormPoints(take))); 
}
//+------------------------------------------------------------------+
void FixedStopsB(int PP,int PFS)
{
  if(PFS<=0) return;

  double stopcrnt,stopcal;
  double profit,profitpoint;

  stopcrnt=OrderStopLoss();
  profitpoint=NormPoints(PP);  

//Long               

  if(OrderType()==OP_BUY)
  {
   profit=Bid-OrderOpenPrice();
   
   if(profit>=profitpoint)
   {
    stopcal=TakeLong(OrderOpenPrice(),PFS);
    ModifyCompLong(stopcal,stopcrnt);   
   }
  }    
//Short 
  if(OrderType()==OP_SELL)
  {  
   profit=OrderOpenPrice()-Ask;
   
   if(profit>=profitpoint)
   {
    stopcal=TakeShort(OrderOpenPrice(),PFS);
    ModifyCompShort(stopcal,stopcrnt);
   }
  }  
 return(0);
} 
//+------------------------------------------------------------------+
void QuantumTrailingStop(int TP, int TM) // for every additional TP of profit above SLMove, lock in an additional TM
{
 if(TP<=0) return;
  
 double stopcrnt,stopcal,profit,openprice; 
 int profitpips;
 
 stopcrnt= NormDigits(OrderStopLoss());
 openprice=NormDigits(OrderOpenPrice());
 profit=NormDigits(DetermineProfit());
             
 if(OrderType()==OP_BUY)
 {
  if(stopcrnt<openprice) return;
  profitpips=(stopcrnt-openprice)/Point;
  profitpips+=(TP-TM)+TP;

  if(profit>=NormPoints(profitpips))
  {
   stopcal=stopcrnt+NormPoints(TM);
   if (stopcal==stopcrnt) return;
   ModifyCompLong(stopcal,stopcrnt); 
  }
 }    

 if(OrderType()==OP_SELL)
 {  
  if(stopcrnt>openprice) return; 
  profitpips=(openprice-stopcrnt)/Point;
  profitpips+=(TP-TM)+TP;

  if(profit>=NormPoints(profitpips))
  {
   stopcal=stopcrnt-NormPoints(TM);

   if (stopcal==stopcrnt) return;  
   ModifyCompShort(stopcal,stopcrnt); 
  }
 }  
 
 return(0);
}
//+------------------------------------------------------------------+

bool ModifyOrder(int ticket, double price, double sl, double tp, datetime exp, color cl=CLR_NONE)
{ 
 bool attempt=true;
 while(attempt)
 {
  if(IsTradeAllowed())
  {
   if(OrderModify(ticket,price,sl,tp,exp,cl)==false)
   {  
    Print("OrderModify failed, Error: ",GetLastError(), " Ticket Number: ", ticket);
    Print("Old price: ", OrderOpenPrice(), " Old S/L ", OrderStopLoss(), " Old T/P ", OrderTakeProfit(), " Ask/Bid ",Ask,", ",Bid);
    Print(" New Price: ", price, " New S/L ", sl, " New T/P ", tp, " New Expiration ", exp);
   }
   attempt=false;
  }
 }
 return(true);
}
//+------------------------------------------------------------------+
double NormDigits(double price)
{
 return(NormalizeDouble(price,Digits));
}
//+------------------------------------------------------------------+
double NormPoints(int pips)
{
 return(NormalizeDouble(pips*Point,Digits));
}
//+------------------------------------------------------------------+
double NormLots(double lots)
{
 return(MathMax(NormalizeDouble(lotsmin,lotsprecision),NormalizeDouble(lots,lotsprecision)));
}
//+------------------------------------------------------------------+
double DetermineProfit()
{
 if(OrderType()==OP_BUY)  
 {
  return(Bid-OrderOpenPrice());
 } 
 else if(OrderType()==OP_SELL)
 { 
  return(OrderOpenPrice()-Ask); 
 }
 return(0);
}
//+------------------------------------------------------------------+
void ExitOrder(bool flag_Long,bool flag_Short,int flag)
{
 if(OrderType()==OP_BUY&&flag_Long)
 {
  if(flag==1)
  {
   if(OrderOpenTime()>LastSt[NS]) CloseOrderLong(OrderTicket(),OrderLots(),Slippage,Lime);
  }
  else CloseOrderLong(OrderTicket(),OrderLots(),Slippage,Lime);
 }
 else if(OrderType()==OP_SELL&&flag_Short)
 {
  if(flag==1)
  {
   if(OrderOpenTime()>LastRt[NR]) CloseOrderShort(OrderTicket(),OrderLots(),Slippage,Lime);
  }
  else CloseOrderShort(OrderTicket(),OrderLots(),Slippage,Lime);
 }
 return;
}

//+------------------------------------------------------------------+
void Status(int mn)
{   
      if(mn==magic[0,0]) ot[0]=OrderOpenTime();
 else if(mn==magic[0,1]) ot[0]=OrderOpenTime();
 else if(mn==magic[0,2]) ot[0]=OrderOpenTime();
 else if(mn==magic[1,0]) ot[1]=OrderOpenTime();
 else if(mn==magic[1,1]) ot[1]=OrderOpenTime();
 else if(mn==magic[1,2]) ot[1]=OrderOpenTime();
 else if(mn==magic[2,0]) ot[2]=OrderOpenTime();
 else if(mn==magic[2,1]) ot[2]=OrderOpenTime();
 else if(mn==magic[2,2]) ot[2]=OrderOpenTime();

 return;
}
//+------------------------------------------------------------------+
void DrawCross(double price, int time1, string str, color clr, int code)
{
 string name=StringConcatenate(str,time1);
 ObjectDelete(name);  
 ObjectCreate(name,OBJ_ARROW,0,time1,price);
 ObjectSet(name,OBJPROP_COLOR,clr);
 ObjectSet(name,OBJPROP_ARROWCODE,code); 
 ObjectSet(name,OBJPROP_WIDTH,1);
 return;
}
//+------------------------------------------------------------------+
bool noRun()
{
 if(NoTradeHourStart>=0&&NoTradeHourEnd>=0)
 {
  if(NoTradeHourEnd>NoTradeHourStart)
  {
   if(Hour()>=NoTradeHourStart&&Hour()<=NoTradeHourEnd) return(true);
  }
  else
  {
   if(Hour()>=NoTradeHourStart||Hour()<=NoTradeHourEnd) return(true);
  }
 }
 return(false);
}
//+------------------------------------------------------------------+
void ArmPitTargets()
{
 int i,imax;
 double Fup,Fdn;
 if(first) 
 {
  imax=iBarShift(NULL,0,StartDate,false)-2;
 }
 else imax=1;

 for(i=imax;i>=1;i--)
 { 
  Fup=iFractals(NULL,0,MODE_UPPER,i+2);
  if(Fup>0) 
  {
   FillArrays(i); 
   ArmPitUpTP=maxvalue;
  }
  Fdn=iFractals(NULL,0,MODE_LOWER,i+2);
  if(Fdn>0) 
  {
   FillArrays(i);
   ArmPitDnTP=minvalue;
  }
 }
 return;
}
//+------------------------------------------------------------------+
void FillArrays(int i)
{
 int j; double open, close;
 double barU[5],barD[5]; 
 for(j=0;j<=4;j++)
 {
  close=iClose(NULL,0,i+j);
  open=iOpen(NULL,0,i+j);
  if(close>open)
  {
   barU[j]=close;
   barD[j]=open;
  }
  else // includes possibility of equivalence
  {
   barU[j]=open;
   barD[j]=close;   
  }
 }

 double value1;
 maxindex=4;minindex=4;
 maxvalue=0;minvalue=99999999;
 for(j=4;j>=0;j--)
 {
  // Up:  highest "low"
  value1=barD[j];
  if(value1>maxvalue)
  {
   maxvalue=barD[j];
   maxindex=j;
  }

  // Down:  lowest "high"
  value1=barU[j];
  if(value1<minvalue)
  {
   minvalue=barU[j];
   minindex=j;
  }  
 } 
 return;
}
//+------------------------------------------------------------------+


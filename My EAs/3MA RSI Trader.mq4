//+----------------------------------------------------------------------+
//|                                                   3MA RSI Trader.mq4 |
//|                                                         David J. Lin |
//|Based on Moshe Kramer's strategy using 3 MAs and RSI                  |
//|Written for Moshe Kramer (shteekah28@yahoo.com)                       |
//|                                                                      |
//|Coded by David J. Lin (dave.j.lin@sbcglobal.net)                      |                                      |
//|Evanston, IL, September 1, 2007                                       |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2007, Moshe Kramer & David J. Lin"
#property link      ""

// User adjustable parameters:
extern bool trigMMA=true;            // Medium-Term MA Trigger 
extern bool trigLMA=true;            // Long-Term MA Trigger 
extern bool trigMLaT=true;           // Medium-Long anti-Trend Trigger  
extern bool trigSLT=true;            // Short-Long Trend Trigger
extern bool trigMLT=true;            // Medium-Long Trend Trigger
extern bool trigLT=true;             // Long Trend Trigger
extern bool trigRSI=true;            // RSI Trigger
extern bool trigStoch=true;          // Stoch Trigger

extern bool exitRSI=false;           // use Universal RSI exit signal for MA Triggers

extern int MAperiodS=13;             // short-term MA period          
extern int MAperiodM=25;             // medium-term MA period
extern int MAperiodL=75;             // long-term MA period

extern int RSIperiod=10;             // RSI period
extern int RSIshift=0;               // for RSI exit-signals:  0=instantaneous RSI values, 1=confirmed RSI values

extern int Kperiod=200;              // Stochastics %K period
extern int Dperiod=2;                //             %D period
extern int slowing=2;                //             slowing period

extern double Lots=0.01;             // lottage per trade
extern double LotsMLaT=0.01;         // lottage per MLaT trade

                              // Take Profits: (use negative number if not desired)
extern int FibSearch=25;             // number of bars to determine swing high/low for basis of Fibonacci TP (1.616, 2.618)
extern double FibTP1=1.618;          // Fibonacci TP level 1
extern double FibTP2=2.618;          // Fibonacci TP level 2
extern int TakeProfitMMA=-1;         // pips desired TP for Medium-Term MA trades
extern int TakeProfitLMA=-1;         // pips desired TP for Long-Term MA trades
extern int TakeProfitMLaT=20;        // pips desired TP for ML-anti-Trend trades
extern int TakeProfitSLT=-1;         // pips desired TP for Short-Long Trend trades
extern int TakeProfitMLT=-1;         // pips desired TP for Medium-Long Trend trades
extern int TakeProfitLT=-1;          // pips desired TP for Long Trend trades
extern int TakeProfitRSI=20;         // pips desired TP for RSI trades
extern int TakeProfitStoch=25;       // pips desired TP for Stoch trades
extern int TakeProfitRev=5;          // pips desired TP for Reverse trades

extern int StopLossMAX=30;           // pips maximum SL
extern int StopLoss=8;               // pips desired SL beyond highest high/lowest low in past 3 bars 
extern int SLSearch=3;               // number of bars to search for highest high/lowest low, including entry bar
extern int StopLossRev=5;            // pips desired SL for Reverse trades

                              // Move Stops:  after reaching BE+SLProfit, move SL to BE+SLMove
extern int SLProfit=25;              // pips profit after which to move SL (use negative number if not desired)
extern int SLMove=10;                // pips to move SL to BE+SLMove after SLProfit is reached

                              // Trail: for every additional TrailProfit of profit above SLMove, lock in an additional TrailMove of profit
extern int TrailProfit=25;           // pips desired trailing profit above SLProfit, engages after SLProfit is hit (use negative number if not desired)
extern int TrailMove=10;             // pips desired trailing stop added onto previous stop, engages after SLProfit is hit

extern int MMAbuffer=0;              // pips to define how close price can approach medium-term MA line to qualify for MMA Trigger
extern int LMAbuffer=0;              // pips to define how close price can approach long-term MA line to qualify for LMA Trigger
extern int MLaTbuffer=15;            // pips difference between Long MA & high/low to qualify for MLaT Trigger
extern int SLTbuffer=0;              // pips to define how close price can approach short-term MA line to qualify for SLT Trigger
extern int MLTbuffer=0;              // pips to define how close price can approach medium-term MA line to qualify for MLT Trigger
extern int LTbuffer=0;               // pips to define how close price can approach medium-term MA line to qualify for LT Trigger

extern double RSILongEntry=40;     // RSI value to enter RSI longs 
extern double RSILongExit1=65;       // RSI value above which to exit RSI longs 
extern double RSILongExit2=60;       // RSI value below which to exit RSI longs (if RSILongExit1 is not achieved)

extern double RSIShortEntry=60;    // RSI value to enter RSI shorts
extern double RSIShortExit1=35;      // RSI value below which to exit RSI shorts 
extern double RSIShortExit2=40;      // RSI value above which to exit RSI shorts (if RSIShortExit1 is not achieved)

extern double ExitLongRSI1=90;       // RSI value above which to universally exit all longs (all triggers) 
extern double ExitLongRSI2=85;       // RSI value below which to universally exit all longs (all triggers) (if ExitLongRSI1 is not achieved)

extern double ExitShortRSI1=15;      // RSI value below which to universally exit all shorts (all triggers) 
extern double ExitShortRSI2=10;      // RSI value above which to universally exit all shorts (all triggers) (if ExitShortRSI1 is not achieved)

extern double RSIfilterLong=100;     // no longs can enter above this RSI value (all MA triggers)
extern double RSIfilterShort=0;      // no shorts can enter below this RSI value (all MA triggers) 

extern double StochLongEntry=20;     // Stoch value to enter Stoch longs
extern double StochLongHalf=50;      // Stoch value to take 1/2 profits
extern double StochLongExit=80;      // Stoch value to exit Stoch longs

extern double StochShortEntry=80;    // Stoch value to enter Stoch shorts
extern double StochShortHalf=50;     // Stoch value to take 1/2 profits
extern double StochShortExit=20;     // Stoch value to exit Stoch shorts

extern int MaxNOrders=3;             // maximum number of simultaneous open orders per EA

extern int FilterSMPips=10;          // pips which Short- and Medium-Term MAs are within each other to prevent trades based on Short- and Medium MA triggers
extern int FilterSMBars=3;          // consecutive bars which Short- and Medium-Term MAs are within FilterSMPips of each other to prevent trades based on Short- and Medium MA triggers
extern int FilterMLPips=10;          // pips which Medium- and Long-Term MAs are within each other to prevent ALL MA-based trades 

int ADXPeriod=-1;             // period for ADX (enter negative value to turn off ADX filter)
double ADXLimit=10;           // ADX value above which to allow triggers

int TriggerLinesR = -1;       // Triggerlines Rperiod (enter negative value to turn off TriggerLines filter)
int TriggerLinesLSMA =20 ;     // Triggerlines LSMA period

double PSAR1Step=-1;         // PSAR1 step (enter negative value to turn off PSAR 1 filter)
double PSAR1Max=0.2;         // PSAR1 max 

double PSAR2Step=-1;         // PSAR2 step (enter negative value to turn off PSAR 2 filter)
double PSAR2Max=0.2;         // PSAR2 max 

// MA parameter settings
int MAshiftS=0;
int MAmethodS=MODE_SMA;
int MApriceS=PRICE_CLOSE;

int MAshiftM=0;
int MAmethodM=MODE_SMA;
int MApriceM=PRICE_CLOSE;

int MAshiftL=0;
int MAmethodL=MODE_SMA;
int MApriceL=PRICE_CLOSE;

// RSI parameter settings
int RSIprice=PRICE_CLOSE;             // RSI price

// Stoch parameter settings
int Stochmethod=MODE_SMA;
int Stochprice=0;
int Stochmode=MODE_MAIN;

// ADX parameter settins
int ADXPrice=PRICE_CLOSE;

// Internal usage parameters:
int Slippage=3,bo=1;
int lotsprecision=2;

color clrL=Blue,clrS=Red;
string strL="Long",strS="Short";
int code=1;

double lotsmin,lotsmax;
double MMABuffer,LMABuffer,SLTBuffer,MLTBuffer,LTBuffer,MLaTBuffer;
bool LongExit,ShortExit,LongExitRSI,ShortExitRSI,LongExitStoch,ShortExitStoch,LongHalfExitStoch,ShortHalfExitStoch;
int otMMA,otLMA,otSLT,otMLT,otLT,otMLaT,otRSI,otStoch;
string commentMMA,commentLMA,commentMLaT,commentSLT,commentMLT,commentLT,commentRSI,commentStoch,commentRev;
int magicLMA,magicMMA,magicMLaT,magicSLT,magicMLT,magicLT,magicRSI,magicStoch,magicRev;
int NordersL,NordersS;
datetime lasttime;
bool noSMTrades=false,noTrades=false;
bool MMALongTrigger=false,MMAShortTrigger=false,LMALongTrigger=false,LMAShortTrigger=false;
bool MLaTLongTrigger=false,MLaTShortTrigger=false,SLTLongTrigger=false,SLTShortTrigger=false;
bool MLTLongTrigger=false,MLTShortTrigger=false,LTLongTrigger=false,LTShortTrigger=false;
bool RSILongTrigger=false,RSIShortTrigger=false,StochLongTrigger=false,StochShortTrigger=false;
bool fTL[3];
int TF[3];
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//----
 lotsmin=MarketInfo(Symbol(),MODE_MINLOT); 
 lotsmax=MarketInfo(Symbol(),MODE_MAXLOT);
 if(lotsmin==0.10) lotsprecision=1;
 
 magicMMA  =30000000+Period(); 
 magicLMA  =31000000+Period();
 magicMLaT =32000000+Period();
 magicSLT  =33000000+Period();
 magicMLT  =34000000+Period(); 
 magicRSI  =35000000+Period(); 
 magicLT   =36000000+Period();
 magicStoch=37000000+Period(); 
 magicRev  =38000000+Period();  
 
 string pd;
 switch(Period())
 {
  case 1:     pd="M1"; TF[0]=PERIOD_M1;TF[1]=PERIOD_M5;TF[2]=PERIOD_M15;break;
  case 5:     pd="M5"; TF[0]=PERIOD_M5;TF[1]=PERIOD_M15;TF[2]=PERIOD_M30;break;
  case 15:    pd="M15";TF[0]=PERIOD_M15;TF[1]=PERIOD_M30;TF[2]=PERIOD_H1;break;
  case 30:    pd="M30";TF[0]=PERIOD_M30;TF[1]=PERIOD_H1;TF[2]=PERIOD_H4;break;
  case 60:    pd="H1"; TF[0]=PERIOD_H1;TF[1]=PERIOD_H4;TF[2]=PERIOD_D1;break;
  case 240:   pd="H4"; TF[0]=PERIOD_H4;TF[1]=PERIOD_D1;TF[2]=PERIOD_W1;break;
  case 1440:  pd="D1"; TF[0]=PERIOD_D1;TF[1]=PERIOD_W1;TF[2]=PERIOD_MN1;break;
  case 10080: pd="W1"; TF[0]=PERIOD_W1;TF[1]=PERIOD_MN1;TF[2]=PERIOD_MN1;break;
  case 40320: pd="M1"; TF[0]=PERIOD_MN1;TF[1]=PERIOD_MN1;TF[2]=PERIOD_MN1;break;
  default:    pd="Unknown";break;
 }
 commentMMA  =StringConcatenate(pd," MMA");  // medium-tem MA 
 commentLMA  =StringConcatenate(pd," LMA");  // long-term MA
 commentMLaT =StringConcatenate(pd," MLaT"); // medium-long anti-Trend
 commentSLT  =StringConcatenate(pd," SLT");  // short-long Trend
 commentMLT  =StringConcatenate(pd," MLT");  // medium-long Trend
 commentLT   =StringConcatenate(pd," LT");   // long Trend
 commentRSI  =StringConcatenate(pd," RSI");  // RSI
 commentStoch=StringConcatenate(pd," Stoch");// Stoch 
 commentRev  =StringConcatenate(pd," Reverse");// Reverse trade
 
// First check closed trades
 int trade;                         
 int trades=OrdersHistoryTotal();           
 for(trade=0;trade<trades;trade++)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_HISTORY);

  if(OrderSymbol()!=Symbol())
   continue;

  int D1bars=iBarShift(NULL,PERIOD_D1,OrderCloseTime(),false);
  if(D1bars>10)
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

 MMABuffer=NormPoints(MMAbuffer);
 LMABuffer=NormPoints(LMAbuffer);
 MLaTBuffer=NormPoints(MLaTbuffer); 
 SLTBuffer=NormPoints(SLTbuffer);
 MLTBuffer=NormPoints(MLTbuffer);
 LTBuffer=NormPoints(LTbuffer); 
 
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
//----
 if(lasttime!=iTime(NULL,0,0))
 {
  Triggers();
  Filters();
 }
 SubmitOrders(); 
 ExitOrders();  
 ManageOrders();
 lasttime=iTime(NULL,0,0);
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert utility functions                                         |
//+------------------------------------------------------------------+
void SubmitOrders()
{
 LongExit=false;ShortExit=false; 
 
 if(!noTrades)
 {
  if(!noSMTrades)
  {
   if(trigMMA)  Trigger0(); // Medium-Term MA Trigger 
   if(trigMLaT) Trigger2(); // Medium-Long anti-Trend Trigger
   if(trigSLT)  Trigger3(); // Short-Long  Trend Trigger
   if(trigMLT)  Trigger4(); // Medium-Long Trend Trigger
   if(trigRSI)  Trigger6(); // RSI Trend Trigger 
   if(trigStoch)Trigger7(); // Stoch Trigger     
  }
  if(trigLMA)  Trigger1(); // Long-Term MA Trigger
  if(trigLT)   Trigger5(); // Long Trend Trigger
 }
 return;
}
//+------------------------------------------------------------------+
void Trigger0() // Medium MA Trigger
{      
 int i,shift,checktime=iBarShift(NULL,0,otMMA,false);
 if(checktime<bo) return;

 double lots,SL,TP; 

 double prevHigh=iHigh(NULL,0,1); 
 double prevLow=iLow(NULL,0,1);

 double rsi=iRSI(NULL,0,RSIperiod,RSIprice,0);

 if(NordersL<MaxNOrders)
 {  
  if(MMALongTrigger)
  { 
   if(rsi<RSIfilterLong)
   {  
    if(Bid>prevHigh)
    {
     if(Filter(true))
     {
      lots=Lots; 
      shift=iLowest(NULL,0,MODE_LOW,SLSearch,0);
      prevLow=iLow(NULL,0,shift);
      SL=StopLong(prevLow,StopLoss);
      TP=TakeLong(Ask,TakeProfitMMA,SL,1);
      SendOrderLong(Symbol(),lots,Slippage,SL,TP,commentMMA,magicMMA,0,Blue);
      TP=TakeLong(Ask,TakeProfitMMA,SL,2);
      SendOrderLong(Symbol(),lots,Slippage,SL,TP,commentMMA,magicMMA,0,Blue);   

      SL=StopShort(Bid,StopLossRev);
      TP=TakeShort(Bid,TakeProfitRev);
      SendOrderShort(Symbol(),lots,Slippage,SL,TP,commentRev,magicRev,0,Red);

      ShortExit=true;
      otMMA=TimeCurrent();
      NordersL++;    
      return;
     }
    }
   }
  }
 } 

 if(NordersS<MaxNOrders)
 { 
  if(MMAShortTrigger)
  { 
   if(rsi>RSIfilterShort)
   { 
    if(Bid<prevLow)
    {
     if(Filter(false))
     {      
      lots=Lots;
      shift=iHighest(NULL,0,MODE_HIGH,SLSearch,0);
      prevHigh=iHigh(NULL,0,shift);
      SL=StopShort(prevHigh,StopLoss);
      TP=TakeShort(Bid,TakeProfitMMA,SL,1);
      SendOrderShort(Symbol(),lots,Slippage,SL,TP,commentMMA,magicMMA,0,Red);  
      TP=TakeShort(Bid,TakeProfitMMA,SL,2);
      SendOrderShort(Symbol(),lots,Slippage,SL,TP,commentMMA,magicMMA,0,Red);

      SL=StopLong(Ask,StopLossRev);
      TP=TakeLong(Ask,TakeProfitRev);
      SendOrderLong(Symbol(),lots,Slippage,SL,TP,commentRev,magicRev,0,Blue);

      LongExit=true;         
      otMMA=TimeCurrent();
      NordersS++;    
      return;
     }
    }
   }
  }
 }
 return;
}
//+------------------------------------------------------------------+
void Trigger1() // Long MA Trigger
{    
 int i,shift,checktime=iBarShift(NULL,0,otLMA,false);
 if(checktime<bo) return;

 double lots,SL,TP; 

 double prevHigh=iHigh(NULL,0,1); 
 double prevLow=iLow(NULL,0,1);

 double rsi=iRSI(NULL,0,RSIperiod,RSIprice,0);

 if(NordersL<MaxNOrders)
 {  
  if(LMALongTrigger)
  { 
   if(rsi<RSIfilterLong)
   {  
    if(Bid>prevHigh)
    {
     if(Filter(true))
     {    
      lots=Lots; 
      shift=iLowest(NULL,0,MODE_LOW,SLSearch,0);
      prevLow=iLow(NULL,0,shift);
      SL=StopLong(prevLow,StopLoss);
      TP=TakeLong(Ask,TakeProfitLMA,SL,1);
      SendOrderLong(Symbol(),lots,Slippage,SL,TP,commentLMA,magicLMA,0,Blue);
      TP=TakeLong(Ask,TakeProfitLMA,SL,2);
      SendOrderLong(Symbol(),lots,Slippage,SL,TP,commentLMA,magicLMA,0,Blue);   

      SL=StopShort(Bid,StopLossRev);
      TP=TakeShort(Bid,TakeProfitRev);
      SendOrderShort(Symbol(),lots,Slippage,SL,TP,commentRev,magicRev,0,Red);

      ShortExit=true;
      otLMA=TimeCurrent();
      NordersL++;    
      return;
     }
    }
   }
  }
 } 

 if(NordersS<MaxNOrders)
 { 
  if(LMAShortTrigger)
  {  
   if(rsi>RSIfilterShort)
   { 
    if(Bid<prevLow)
    {
     if(Filter(false))
     {     
      lots=Lots;
      shift=iHighest(NULL,0,MODE_HIGH,SLSearch,0);
      prevHigh=iHigh(NULL,0,shift);
      SL=StopShort(prevHigh,StopLoss);
      TP=TakeShort(Bid,TakeProfitLMA,SL,1);
      SendOrderShort(Symbol(),lots,Slippage,SL,TP,commentLMA,magicLMA,0,Red);  
      TP=TakeShort(Bid,TakeProfitLMA,SL,2);
      SendOrderShort(Symbol(),lots,Slippage,SL,TP,commentLMA,magicLMA,0,Red);

      SL=StopLong(Ask,StopLossRev);
      TP=TakeLong(Ask,TakeProfitRev);
      SendOrderLong(Symbol(),lots,Slippage,SL,TP,commentRev,magicRev,0,Blue);

      LongExit=true;         
      otLMA=TimeCurrent();
      NordersS++;    
      return;
     }
    }
   }
  }
 }
 return;
}
//+------------------------------------------------------------------+
void Trigger2() // Medium-Long anti-Trend Trigger
{    
 int i,shift,checktime=iBarShift(NULL,0,otMLaT,false);
 if(checktime<bo) return;

 double lots,SL,TP; 

 double prevHigh=iHigh(NULL,0,1); 
 double prevLow=iLow(NULL,0,1);
 
 double rsi=iRSI(NULL,0,RSIperiod,RSIprice,0);

 if(NordersL<MaxNOrders)
 {  
  if(MLaTLongTrigger)
  { 
   if(rsi<RSIfilterLong)
   {  
    if(Bid>prevHigh)
    {
     if(Filter(true))
     {    
      lots=LotsMLaT; 
      shift=iLowest(NULL,0,MODE_LOW,SLSearch,0);
      prevLow=iLow(NULL,0,shift);
      SL=StopLong(prevLow,StopLoss);
      TP=TakeLong(Ask,TakeProfitMLaT,SL,1);
      SendOrderLong(Symbol(),lots,Slippage,SL,TP,commentMLaT,magicMLaT,0,Blue);
      TP=TakeLong(Ask,TakeProfitMLaT,SL,2);
      SendOrderLong(Symbol(),lots,Slippage,SL,TP,commentMLaT,magicMLaT,0,Blue);   

      SL=StopShort(Bid,StopLossRev);
      TP=TakeShort(Bid,TakeProfitRev);
      SendOrderShort(Symbol(),lots,Slippage,SL,TP,commentRev,magicRev,0,Red);

      ShortExit=true;
      otMLaT=TimeCurrent();
      NordersL++;    
      return;
     }
    }
   }
  }
 } 

 if(NordersS<MaxNOrders)
 { 
  if(MLaTShortTrigger)
  {  
   if(rsi>RSIfilterShort)
   { 
    if(Bid<prevLow)
    {
     if(Filter(false))
     {      
      lots=LotsMLaT;
      shift=iHighest(NULL,0,MODE_HIGH,SLSearch,0);
      prevHigh=iHigh(NULL,0,shift);
      SL=StopShort(prevHigh,StopLoss);
      TP=TakeShort(Bid,TakeProfitMLaT,SL,1);
      SendOrderShort(Symbol(),lots,Slippage,SL,TP,commentMLaT,magicMLaT,0,Red);  
      TP=TakeShort(Bid,TakeProfitMLaT,SL,2);
      SendOrderShort(Symbol(),lots,Slippage,SL,TP,commentMLaT,magicMLaT,0,Red);

      SL=StopLong(Ask,StopLossRev);
      TP=TakeLong(Ask,TakeProfitRev);
      SendOrderLong(Symbol(),lots,Slippage,SL,TP,commentRev,magicRev,0,Blue);

      LongExit=true;         
      otMLaT=TimeCurrent();
      NordersS++;    
      return;
     }
    }
   }
  }
 }
 return;
}
//+------------------------------------------------------------------+
void Trigger3() // Short-Long Trend Trigger
{    
 int i,shift,checktime=iBarShift(NULL,0,otSLT,false);
 if(checktime<bo) return;

 double lots,SL,TP; 
 
 double prevHigh=iHigh(NULL,0,1); 
 double prevLow=iLow(NULL,0,1);

 double rsi=iRSI(NULL,0,RSIperiod,RSIprice,0);

 if(NordersL<MaxNOrders)
 { 
  if(SLTLongTrigger)
  { 
   if(rsi<RSIfilterLong)
   {
    if(Bid>prevHigh)
    {
     if(Filter(true))
     {    
      lots=Lots; 
      shift=iLowest(NULL,0,MODE_LOW,SLSearch,0);
      prevLow=iLow(NULL,0,shift); 
      SL=StopLong(prevLow,StopLoss);
      TP=TakeLong(Ask,TakeProfitSLT,SL,1);
      SendOrderLong(Symbol(),lots,Slippage,SL,TP,commentSLT,magicSLT,0,Blue);
      TP=TakeLong(Ask,TakeProfitSLT,SL,2);
      SendOrderLong(Symbol(),lots,Slippage,SL,TP,commentSLT,magicSLT,0,Blue);   

      SL=StopShort(Bid,StopLossRev);
      TP=TakeShort(Bid,TakeProfitRev);
      SendOrderShort(Symbol(),lots,Slippage,SL,TP,commentRev,magicRev,0,Red);
 
      ShortExit=true;
      otSLT=TimeCurrent();
      NordersL++;
      return;
     }
    }
   }
  }
 } 

 if(NordersS<MaxNOrders)
 { 
  if(SLTShortTrigger)
  { 
   if(rsi>RSIfilterShort)
   {  
    if(Bid<prevLow)
    {
     if(Filter(false))
     {        
      lots=Lots;
      shift=iHighest(NULL,0,MODE_HIGH,SLSearch,0);
      prevHigh=iHigh(NULL,0,shift);     
      SL=StopShort(prevHigh,StopLoss);
      TP=TakeShort(Bid,TakeProfitSLT,SL,1);
      SendOrderShort(Symbol(),lots,Slippage,SL,TP,commentSLT,magicSLT,0,Red);  
      TP=TakeShort(Bid,TakeProfitSLT,SL,2);
      SendOrderShort(Symbol(),lots,Slippage,SL,TP,commentSLT,magicSLT,0,Red);

      SL=StopLong(Ask,StopLossRev);
      TP=TakeLong(Ask,TakeProfitRev);
      SendOrderLong(Symbol(),lots,Slippage,SL,TP,commentRev,magicRev,0,Blue);

      LongExit=true;         
      otSLT=TimeCurrent();
      NordersS++;    
      return;
     }
    }
   }
  }
 }
 return;
}
//+------------------------------------------------------------------+
void Trigger4() // Medium-Long Trend Trigger
{    
 int i,shift,checktime=iBarShift(NULL,0,otMLT,false);
 if(checktime<bo) return;

 double lots,SL,TP; 

 double prevHigh=iHigh(NULL,0,1); 
 double prevLow=iLow(NULL,0,1);

 double rsi=iRSI(NULL,0,RSIperiod,RSIprice,0);

 if(NordersL<MaxNOrders)
 {  
  if(MLTLongTrigger)
  {
   if(rsi<RSIfilterLong)
   {  
    if(Bid>prevHigh)
    {
     if(Filter(true))
     {    
      lots=Lots; 
      shift=iLowest(NULL,0,MODE_LOW,SLSearch,0);
      prevLow=iLow(NULL,0,shift); 
      SL=StopLong(prevLow,StopLoss);
      TP=TakeLong(Ask,TakeProfitMLT,SL,1);
      SendOrderLong(Symbol(),lots,Slippage,SL,TP,commentMLT,magicMLT,0,Blue);
      TP=TakeLong(Ask,TakeProfitMLT,SL,2);
      SendOrderLong(Symbol(),lots,Slippage,SL,TP,commentMLT,magicMLT,0,Blue);   

      SL=StopShort(Bid,StopLossRev);
      TP=TakeShort(Bid,TakeProfitRev);
      SendOrderShort(Symbol(),lots,Slippage,SL,TP,commentRev,magicRev,0,Red);
 
      ShortExit=true;
      otMLT=TimeCurrent();
      NordersL++;    
      return;
     }
    }
   }
  }
 } 

 if(NordersS<MaxNOrders)
 { 
  if(MLTShortTrigger)
  {
   if(rsi>RSIfilterShort)
   { 
    if(Bid<prevLow)
    {
     if(Filter(false))
     {        
      lots=Lots;
      shift=iHighest(NULL,0,MODE_HIGH,SLSearch,0);
      prevHigh=iHigh(NULL,0,shift);     
      SL=StopShort(prevHigh,StopLoss);
      TP=TakeShort(Bid,TakeProfitMLT,SL,1);
      SendOrderShort(Symbol(),lots,Slippage,SL,TP,commentMLT,magicMLT,0,Red);  
      TP=TakeShort(Bid,TakeProfitMLT,SL,2);
      SendOrderShort(Symbol(),lots,Slippage,SL,TP,commentMLT,magicMLT,0,Red);

      SL=StopLong(Ask,StopLossRev);
      TP=TakeLong(Ask,TakeProfitRev);
      SendOrderLong(Symbol(),lots,Slippage,SL,TP,commentRev,magicRev,0,Blue);

      LongExit=true;         
      otMLT=TimeCurrent();
      NordersS++;    
      return;
     }
    }
   }
  }
 }
 return;
}
//+------------------------------------------------------------------+
void Trigger5() // Long Trend Trigger
{    
 int i,shift,checktime=iBarShift(NULL,0,otLT,false);
 if(checktime<bo) return;

 double lots,SL,TP; 

 double prevHigh=iHigh(NULL,0,1); 
 double prevLow=iLow(NULL,0,1);

 double rsi=iRSI(NULL,0,RSIperiod,RSIprice,0);

 if(NordersL<MaxNOrders)
 {  
  if(LTLongTrigger)
  {
   if(rsi<RSIfilterLong)
   {  
    if(Bid>prevHigh)
    {
     if(Filter(true))
     {    
      lots=Lots; 
      shift=iLowest(NULL,0,MODE_LOW,SLSearch,0);
      prevLow=iLow(NULL,0,shift); 
      SL=StopLong(prevLow,StopLoss);
      TP=TakeLong(Ask,TakeProfitLT,SL,1);
      SendOrderLong(Symbol(),lots,Slippage,SL,TP,commentLT,magicLT,0,Blue);
      TP=TakeLong(Ask,TakeProfitLT,SL,2);
      SendOrderLong(Symbol(),lots,Slippage,SL,TP,commentLT,magicLT,0,Blue);

      SL=StopShort(Bid,StopLossRev);
      TP=TakeShort(Bid,TakeProfitRev);
      SendOrderShort(Symbol(),lots,Slippage,SL,TP,commentRev,magicRev,0,Red);

      ShortExit=true;
      otLT=TimeCurrent();
      NordersL++;    
      return;
     }
    }
   }
  }
 } 

 if(NordersS<MaxNOrders)
 { 
  if(LTShortTrigger)
  {
   if(rsi>RSIfilterShort)
   { 
    if(Bid<prevLow)
    {
     if(Filter(false))
     {      
      lots=Lots;
      shift=iHighest(NULL,0,MODE_HIGH,SLSearch,0);
      prevHigh=iHigh(NULL,0,shift);     
      SL=StopShort(prevHigh,StopLoss);
      TP=TakeShort(Bid,TakeProfitLT,SL,1);
      SendOrderShort(Symbol(),lots,Slippage,SL,TP,commentLT,magicLT,0,Red);  
      TP=TakeShort(Bid,TakeProfitLT,SL,2);
      SendOrderShort(Symbol(),lots,Slippage,SL,TP,commentLT,magicLT,0,Red);  

      SL=StopLong(Ask,StopLossRev);
      TP=TakeLong(Ask,TakeProfitRev);
      SendOrderLong(Symbol(),lots,Slippage,SL,TP,commentRev,magicRev,0,Blue);

      LongExit=true;         
      otLT=TimeCurrent();
      NordersS++;    
      return;
     }
    }
   }
  }
 }
 return;
}
//+------------------------------------------------------------------+
void Trigger6() // RSI Trigger
{    
 LongExitRSI=false; ShortExitRSI=false;

 double rsi1=iRSI(NULL,0,RSIperiod,RSIprice,RSIshift);
 double rsi2=iRSI(NULL,0,RSIperiod,RSIprice,RSIshift+1);

 if(rsi1>=RSILongExit1) LongExitRSI=true;
 if(rsi1<=RSILongExit2&&rsi2>=RSILongExit2) LongExitRSI=true;
 
 if(rsi1<=RSIShortExit1) ShortExitRSI=true;
 if(rsi1>=RSIShortExit2&&rsi2<=RSIShortExit2) ShortExitRSI=true;
 
 int i,shift,checktime=iBarShift(NULL,0,otRSI,false);
 if(checktime<bo) return;

 double lots,SL,TP; 

 double prevHigh=iHigh(NULL,0,1); 
 double prevLow=iLow(NULL,0,1);

 if(NordersL<MaxNOrders)
 {  
  if(RSILongTrigger)
  {
   if(Bid>prevHigh)
   {
    if(Filter(true))
    {   
     lots=Lots; 
     shift=iLowest(NULL,0,MODE_LOW,SLSearch,0);
     prevLow=iLow(NULL,0,shift); 
     SL=StopLong(prevLow,StopLoss);
     TP=TakeLong(Ask,TakeProfitRSI,SL,1);
     SendOrderLong(Symbol(),lots,Slippage,SL,TP,commentRSI,magicRSI,0,Blue);
     TP=TakeLong(Ask,TakeProfitRSI,SL,2);
     SendOrderLong(Symbol(),lots,Slippage,SL,TP,commentRSI,magicRSI,0,Blue);

     SL=StopShort(Bid,StopLossRev);
     TP=TakeShort(Bid,TakeProfitRev);
     SendOrderShort(Symbol(),lots,Slippage,SL,TP,commentRev,magicRev,0,Red);
   
     ShortExit=true;
     otRSI=TimeCurrent();
     NordersL++;    
     return;
    }
   }
  }
 } 

 if(NordersS<MaxNOrders)
 { 
  if(RSIShortTrigger)
  {
   if(Bid<prevLow)
   {
    if(Filter(false))
    {      
     lots=Lots;
     shift=iHighest(NULL,0,MODE_HIGH,SLSearch,0);
     prevHigh=iHigh(NULL,0,shift);     
     SL=StopShort(prevHigh,StopLoss);
     TP=TakeShort(Bid,TakeProfitRSI,SL,1);
     SendOrderShort(Symbol(),lots,Slippage,SL,TP,commentRSI,magicRSI,0,Red);  
     TP=TakeShort(Bid,TakeProfitRSI,SL,2);
     SendOrderShort(Symbol(),lots,Slippage,SL,TP,commentRSI,magicRSI,0,Red);  

     SL=StopLong(Ask,StopLossRev);
     TP=TakeLong(Ask,TakeProfitRev);
     SendOrderLong(Symbol(),lots,Slippage,SL,TP,commentRev,magicRev,0,Blue);

     LongExit=true;         
     otRSI=TimeCurrent();
     NordersS++;    
     return;
    }
   }
  }
 }
 return;
}
//+------------------------------------------------------------------+
void Trigger7() // Stochastics Trigger
{    
 LongExitStoch=false; ShortExitStoch=false;
 LongHalfExitStoch=false; ShortHalfExitStoch=false;
 
 double stoch1=iStochastic(NULL,0,Kperiod,Dperiod,slowing,Stochmethod,Stochprice,Stochmode,1);
 double stoch2=iStochastic(NULL,0,Kperiod,Dperiod,slowing,Stochmethod,Stochprice,Stochmode,2);

 double prevHigh=iHigh(NULL,0,1); 
 double prevLow=iLow(NULL,0,1);

 if(stoch1>=StochLongExit)  LongExitStoch =true;
 if(stoch1<=StochShortExit) ShortExitStoch=true; 
 if(stoch1>=StochLongHalf)  
 {
  if(Bid>prevHigh) LongHalfExitStoch =true;
 }
 if(stoch1<=StochShortHalf) 
 {
  if(Bid<prevLow) ShortHalfExitStoch=true; 
 }
 
 int i,shift,checktime=iBarShift(NULL,0,otStoch,false);
 if(checktime<bo) return;

 double lots,SL,TP; 
 
 if(NordersL<MaxNOrders)
 {  
  if(StochLongTrigger)
  {
   if(Bid>prevHigh)
   {
    if(Filter(true,1))
    {   
     lots=Lots; 
     shift=iLowest(NULL,0,MODE_LOW,SLSearch,0);
     prevLow=iLow(NULL,0,shift); 
     SL=StopLong(prevLow,StopLoss);
     TP=TakeLong(Ask,TakeProfitStoch,SL,1);
     SendOrderLong(Symbol(),lots,Slippage,SL,TP,commentStoch,magicStoch,0,Blue);
     TP=TakeLong(Ask,TakeProfitStoch,SL,2);
     SendOrderLong(Symbol(),lots,Slippage,SL,TP,commentStoch,magicStoch,0,Blue);

     SL=StopShort(Bid,StopLossRev);
     TP=TakeShort(Bid,TakeProfitRev);
     SendOrderShort(Symbol(),lots,Slippage,SL,TP,commentRev,magicRev,0,Red);
   
     ShortExit=true;
     otStoch=TimeCurrent();
     NordersL++;    
     return;
    }
   }
  }
 } 

 if(NordersS<MaxNOrders)
 { 
  if(StochShortTrigger)
  {
   if(Bid<prevLow)
   {
    if(Filter(false,1))
    {    
     lots=Lots;
     shift=iHighest(NULL,0,MODE_HIGH,SLSearch,0);
     prevHigh=iHigh(NULL,0,shift);     
     SL=StopShort(prevHigh,StopLoss);
     TP=TakeShort(Bid,TakeProfitStoch,SL,1);
     SendOrderShort(Symbol(),lots,Slippage,SL,TP,commentStoch,magicStoch,0,Red);  
     TP=TakeShort(Bid,TakeProfitStoch,SL,2);
     SendOrderShort(Symbol(),lots,Slippage,SL,TP,commentStoch,magicStoch,0,Red);  

     SL=StopLong(Ask,StopLossRev);
     TP=TakeLong(Ask,TakeProfitRev);
     SendOrderLong(Symbol(),lots,Slippage,SL,TP,commentRev,magicRev,0,Blue);

     LongExit=true;         
     otStoch=TimeCurrent();
     NordersS++;    
     return;
    }
   }
  }
 }
 return;
}
//+------------------------------------------------------------------+

void Triggers()
{
 MMALongTrigger=false;  MMAShortTrigger=false;
 LMALongTrigger=false;  LMAShortTrigger=false;
 MLaTLongTrigger=false; MLaTShortTrigger=false; 
 SLTLongTrigger=false;  SLTShortTrigger=false;
 MLTLongTrigger=false;  MLTShortTrigger=false; 
 LTLongTrigger=false;   LTShortTrigger=false; 
 RSILongTrigger=false;  RSIShortTrigger=false;  
 StochLongTrigger=false;StochShortTrigger=false;  
  
 double prevClose=iClose(NULL,0,1);
 double prevOpen=iOpen(NULL,0,1); 
 double prevHigh=iHigh(NULL,0,1); 
 double prevLow=iLow(NULL,0,1); 
 
 double mas=iMA(NULL,0,MAperiodS,MAshiftS,MAmethodS,MApriceS,1); 
 double mam=iMA(NULL,0,MAperiodM,MAshiftM,MAmethodM,MApriceM,1);
 double mal=iMA(NULL,0,MAperiodL,MAshiftL,MAmethodL,MApriceL,1);

 double rsi1=iRSI(NULL,0,RSIperiod,RSIprice,1);
 double rsi2=iRSI(NULL,0,RSIperiod,RSIprice,2);

 double stoch1=iStochastic(NULL,0,Kperiod,Dperiod,slowing,Stochmethod,Stochprice,Stochmode,1);
 double stoch2=iStochastic(NULL,0,Kperiod,Dperiod,slowing,Stochmethod,Stochprice,Stochmode,2);
   
 if(mam>=NormDigits(prevOpen-MMABuffer))
 {
  if(mam<=NormDigits(prevClose+MMABuffer))
  {  
   MMALongTrigger=true;
  }
 }
 
 if(mam<=NormDigits(prevOpen+MMABuffer))
 {
  if(mam>=NormDigits(prevClose-MMABuffer))
  {  
   MMAShortTrigger=true;
  }
 } 
 
 if(mal>=NormDigits(prevOpen-LMABuffer))
 {
  if(mal<=NormDigits(prevClose+LMABuffer))
  {
   LMALongTrigger=true;   
  }
 }

 if(mal<=NormDigits(prevOpen+LMABuffer))
 {
  if(mal>=NormDigits(prevClose-LMABuffer))
  {
   LMAShortTrigger=true;
  }
 }

 if(mal>=prevOpen)
 {
  if(mam<=prevClose && mam>=prevOpen)
  {
   if(mal>=NormDigits(prevHigh+MLaTBuffer)) 
   { 
    MLaTLongTrigger=true; 
   }
  }
 }

 if(mal<=prevOpen)
 {
  if(mam>=prevClose && mam<=prevOpen)
  {
   if(mal<=NormDigits(prevLow-MLaTBuffer)) 
   {
    MLaTShortTrigger=true; 
   }
  }
 }

 if(mal<=prevOpen && mas<=prevOpen)
 {
  if(prevLow<=NormDigits(mas+SLTBuffer) && prevHigh>=mas) 
  { 
   SLTLongTrigger=true;
  }
 }
 
 if(mal>=prevOpen && mas>=prevOpen)
 {  
  if(prevHigh>=NormDigits(mas-SLTBuffer) && prevLow<=mas)
  {  
   SLTShortTrigger=true;
  }
 }

 if(mal<=prevOpen && mam<=prevOpen)
 {
  if(prevLow<=NormDigits(mam+MLTBuffer) && prevHigh>=mam) 
  {  
   MLTLongTrigger=true;
  }
 }

 if(mal>=prevOpen && mam>=prevOpen)
 {  
  if(prevHigh>=NormDigits(mam-MLTBuffer) && prevLow<=mam)
  {
   MLTShortTrigger=true;
  }
 }

 if(mal<=prevOpen)
 {
  if(prevLow<=NormDigits(mal+LTBuffer) && prevHigh>=mal) 
  {  
   LTLongTrigger=true;
  }
 }  

 if(mal>=prevOpen)
 {  
  if(prevHigh>=NormDigits(mal-LTBuffer) && prevLow<=mal)
  { 
   LTShortTrigger=true;
  }
 } 

 if(rsi1>=RSILongEntry && rsi2<=RSILongEntry && prevLow>=mal)
 {
  RSILongTrigger=true;
 }
 
 if(rsi1<=RSIShortEntry && rsi2>=RSIShortEntry && prevHigh<=mal)
 { 
  RSIShortTrigger=true;
 }

 if(stoch1>=StochLongEntry && stoch2<=StochLongEntry && prevLow>=mal)
 {
  StochLongTrigger=true;
 }
 
 if(stoch1<=StochShortEntry && stoch2>=StochShortEntry && prevHigh<=mal)
 { 
  StochShortTrigger=true;
 } 
 
 return;
}
//+------------------------------------------------------------------+
void Filters()
{
 noTrades=false;noSMTrades=false;
 double mas,mam,mal,diff,close;int n=0;

// if(FilterSMPips<0||FilterSMBars<0||FilterMLPips<0) return;

//1. noSMTrades
 for(int i=1;i<=FilterSMBars;i++)
 {
  mas=iMA(NULL,0,MAperiodS,MAshiftS,MAmethodS,MApriceS,i);
  mam=iMA(NULL,0,MAperiodM,MAshiftM,MAmethodM,MApriceM,i);  

  diff=MathAbs(mas-mam);
 
  if(diff<=NormPoints(FilterSMPips)) n++;
 }

 if(n>=FilterSMBars) noSMTrades=true;

 mas=iMA(NULL,0,MAperiodS,MAshiftS,MAmethodS,MApriceS,1);
 mam=iMA(NULL,0,MAperiodM,MAshiftM,MAmethodM,MApriceM,1);  
 mal=iMA(NULL,0,MAperiodL,MAshiftL,MAmethodL,MApriceL,1);

 diff=MathAbs(mam-mal);

// 2. noTrades 
 if(diff<=NormPoints(FilterMLPips)) noTrades=true;
 
// 3. noTrades 
 if(mas<mam && mas>mal) noTrades=true; 
 if(mas>mam && mas<mal) noTrades=true;

// 4. noSMTrades
 close=iClose(NULL,0,1);
 if(close>mam && close<mal) noSMTrades=true;
 if(close<mam && close>mal) noSMTrades=true; 
 
 return;
}
//+------------------------------------------------------------------+
bool Filter(bool long,int stochflag=0)
{
 int Trigger[4], totN=4, i,j;
 double value1;
 
 for(i=0;i<totN;i++) Trigger[i]=-1;

 TriggerLines();

 if(long) // long filters
 {
  for(i=0;i<totN;i++)
  {
   switch(i)
   { 
    case 0:
     if(TriggerLinesR>0)
     {
      if(fTL[0]) Trigger[i]=1;
     }
     else Trigger[i]=1;
     break;  
    case 1:
     if(ADXPeriod>0)
     {
      value1=iADX(NULL,0,ADXPeriod,ADXPrice,MODE_MAIN,0);
      if(value1>=ADXLimit) Trigger[i]=1;
     }
     else Trigger[i]=1;     
     break; 
    case 2:
     if(PSAR1Step>0 && stochflag==1)
     {
      value1=iSAR(NULL,0,PSAR1Step,PSAR1Max,0);
      if(Bid>value1) Trigger[i]=1;
     }
     else Trigger[i]=1;
     break;
    case 3:
     if(PSAR2Step>0 && stochflag==1)
     {
      value1=iSAR(NULL,0,PSAR2Step,PSAR2Max,0);
      if(Bid>value1) Trigger[i]=1;
     }
     else Trigger[i]=1;    
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
     if(TriggerLinesR>0)
     {    
      if(!fTL[0]) Trigger[i]=1;
     }
     else Trigger[i]=1;     
     break;    
    case 1:
     if(ADXPeriod>0)
     {    
      value1=iADX(NULL,0,ADXPeriod,ADXPrice,MODE_MAIN,0);
      if(value1>=ADXLimit) Trigger[i]=1;
     }
     else Trigger[i]=1;     
     break; 
    case 2:
     if(PSAR1Step>0 && stochflag==1)
     {
      value1=iSAR(NULL,0,PSAR1Step,PSAR1Max,0);
      if(Bid<value1) Trigger[i]=1;
     }
     else Trigger[i]=1;
     break;
    case 3:
     if(PSAR2Step>0 && stochflag==1)
     {
      value1=iSAR(NULL,0,PSAR2Step,PSAR2Max,0);
      if(Bid<value1) Trigger[i]=1;
     }
     else Trigger[i]=1;     
     break;                                                            
   } 
   if(Trigger[i]<0) return(false);    
  }
 }
  
// for(i=0;i<totN;i++) 
//  if(Trigger[i]<0) return(false); // one anti-trigger is sufficient to not trigger at all, so return false (to order)

 return(true);  // no anti-trigger:  so, return true (to order)
}
//+------------------------------------------------------------------+
void ManageOrders()
{
 NordersL=0;NordersS=0;
 double profit=0;
 int i,mn,trail,trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;

  mn=OrderMagicNumber();
  if(mn==magicMMA||mn==magicLMA||mn==magicMLaT||mn==magicSLT||mn==magicMLT||mn==magicLT||mn==magicRSI||mn==magicStoch)
  {
   if(OrderType()==OP_BUY)
   {
    NordersL++; 
    if(LongExit) 
    {
     profit=DetermineProfit();    
     if(profit>0)
     {
      ExitOrder(true,false);    
      NordersL--;
     }
    }
    if(mn==magicRSI)
    {
     if(LongExitRSI) 
     {
      ExitOrder(true,false);    
      NordersL--;
     }      
    }
    if(mn==magicStoch)
    {
     if(LongExitStoch) 
     {
      ExitOrder(true,false);    
      NordersL--;
     }  
     if(LongHalfExitStoch)
     {
      if(OrderLots()==Lots)
      {
       CloseOrderLong(OrderTicket(),0.5*OrderLots(),Slippage,Lime);       
      }
     }        
    }
   }
   else if(OrderType()==OP_SELL)
   {
    NordersS++;
    if(ShortExit) 
    {
     profit=DetermineProfit();    
     if(profit>0)
     {
      ExitOrder(false,true);   
      NordersS--;
     }
    }
    if(mn==magicRSI)
    {
     if(ShortExitRSI)
     {
      ExitOrder(false,true);   
      NordersS--;    
     }
    }   
    if(mn==magicStoch)
    {
     if(ShortExitStoch)
     {
      ExitOrder(false,true);   
      NordersS--;    
     }
     if(ShortHalfExitStoch)
     {
      if(OrderLots()==Lots)
      {
       CloseOrderShort(OrderTicket(),0.5*OrderLots(),Slippage,Lime);       
      }
     }
    }     
   }
  
   if(SLProfit>0) 
   {
    profit=DetermineProfit();
    if(profit>=NormPoints(SLProfit))
    {   
     if(TrailProfit>0) QuantumTrailingStop(TrailProfit,TrailMove);    
     FixedStopsB(SLProfit,SLMove);
    }
   }
  } 
 }
 return;
}
//+------------------------------------------------------------------+
void ExitOrders()
{
 if(exitRSI) 
 {
  double rsi1=iRSI(NULL,0,RSIperiod,RSIprice,RSIshift);
  double rsi2=iRSI(NULL,0,RSIperiod,RSIprice,RSIshift+1);

  if(rsi1>=ExitLongRSI1) LongExit=true;
  if(rsi1<=ExitLongRSI2&&rsi2>=ExitLongRSI2) LongExit=true;
 
  if(rsi1<=ExitShortRSI1) ShortExit=true;
  if(rsi1>=ExitShortRSI2&&rsi2<=ExitShortRSI2) ShortExit=true;
 }
 return;
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
   for(int z=0;z<10;z++)
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
   for(int z=0;z<10;z++)
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
    stopcal=TakeLong(OrderOpenPrice(),PFS,-1,0);
    ModifyCompLong(stopcal,stopcrnt);   
   }
  }    
//Short 
  if(OrderType()==OP_SELL)
  {  
   profit=OrderOpenPrice()-Ask;
   
   if(profit>=profitpoint)
   {
    stopcal=TakeShort(OrderOpenPrice(),PFS,-1,0);
    ModifyCompShort(stopcal,stopcrnt);
   }
  }  
 return(0);
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
double StopLong(double price,int stop)
{
 if(stop<=0) return(0.0);
 double SL=MathMax(NormDigits(price-NormPoints(stop)),NormDigits(Ask-NormPoints(StopLossMAX)));
 return(SL); 
}
//+------------------------------------------------------------------+
double StopShort(double price,int stop) 
{
 if(stop<=0) return(0.0);
 double SL=MathMin(NormDigits(price+NormPoints(stop)),NormDigits(Bid+NormPoints(StopLossMAX)));
 return(SL); 
}
//+------------------------------------------------------------------+
double TakeLong(double price,int take, double SL=-1, int mode=-1)  
{
 double TP;
 if(SL<0) return(NormDigits(price+NormPoints(take)));
 
 if(take<=0)
 {
  double minTP=NormDigits(2.0*price-SL);
  double fibTP;
  int shiftHigh=iHighest(NULL,0,MODE_HIGH,FibSearch,0);
  double prevHigh=iHigh(NULL,0,shiftHigh); 
  int shiftLow=iLowest(NULL,0,MODE_LOW,FibSearch,0);
  double prevLow=iLow(NULL,0,shiftLow);
  
  double fibBase=NormDigits(prevHigh-prevLow); 
  
  switch(mode)
  { 
   case 1: fibTP=NormDigits(price+(FibTP1*fibBase));break;
   case 2: fibTP=NormDigits(price+(FibTP2*fibBase));break;
   default: fibTP=NormDigits(price+(FibTP1*fibBase));break;
  }
  
  if(fibTP>minTP) TP=fibTP;
  else TP=minTP;
  
 } 
 else return(NormDigits(price+NormPoints(take))); 
 
 return(TP);
}
//+------------------------------------------------------------------+
double TakeShort(double price,int take, double SL=-1, int mode=-1) 
{
 double TP;
 if(SL<0) return(NormDigits(price-NormPoints(take))); 
 
 if(take<=0)
 {
  double minTP=NormDigits(2.0*price-SL);
  double fibTP;
  int shiftHigh=iHighest(NULL,0,MODE_HIGH,FibSearch,0);
  double prevHigh=iHigh(NULL,0,shiftHigh); 
  int shiftLow=iLowest(NULL,0,MODE_LOW,FibSearch,0);
  double prevLow=iLow(NULL,0,shiftLow);
  
  double fibBase=NormDigits(prevHigh-prevLow); 
  
  switch(mode)
  { 
   case 1: fibTP=NormDigits(price-(FibTP1*fibBase)) ;break;
   case 2: fibTP=NormDigits(price-(FibTP2*fibBase)) ;break;
   default: fibTP=NormDigits(price-(FibTP1*fibBase)) ;break;
  }
  
  if(fibTP<minTP) TP=fibTP;
  else TP=minTP;
   
 } 
 else return(NormDigits(price-NormPoints(take))); 

 return(TP);
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
  profitpips+=(SLProfit-SLMove)+TP;

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
  profitpips+=(SLProfit-SLMove)+TP;

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
  return(NormDigits(Bid-OrderOpenPrice()));
 } 
 else if(OrderType()==OP_SELL)
 { 
  return(NormDigits(OrderOpenPrice()-Ask)); 
 }
 return(0);
}
//+------------------------------------------------------------------+
void ExitOrder(bool flag_Long,bool flag_Short)
{
 if(OrderType()==OP_BUY&&flag_Long)
  CloseOrderLong(OrderTicket(),OrderLots(),Slippage,Lime);
 else if(OrderType()==OP_SELL&&flag_Short)
  CloseOrderShort(OrderTicket(),OrderLots(),Slippage,Lime);
 return;
}
//+------------------------------------------------------------------+
void Status(int magic)
{   
 if(magic==magicMMA)       otMMA =OrderOpenTime();
 else if(magic==magicLMA)  otLMA =OrderOpenTime();
 else if(magic==magicMLaT) otMLaT=OrderOpenTime(); 
 else if(magic==magicSLT)  otSLT =OrderOpenTime(); 
 else if(magic==magicMLT)  otMLT =OrderOpenTime(); 
 else if(magic==magicLT)   otLT =OrderOpenTime();  
 else if(magic==magicRSI)  otRSI =OrderOpenTime();  
 else if(magic==magicStoch)otStoch =OrderOpenTime();   
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
void TriggerLines()
{ 
 if(TriggerLinesR<0 || TriggerLinesLSMA<0) return;
 int i,j,k;
 int var_124 = TriggerLinesR;
 int var_128 = TriggerLinesLSMA;
 double var_132,var_140,arr_160,arr_168;
 double arr_156[2];
 
 for(k=0;k<3;k++)
 {
  for (i = 1; i >= 0; i--)
  {
   arr_160 = 0;
   for (j = var_124; j >= 1; j--)
   {
    var_132 = var_124 + 1;
    var_132 = var_132 / 3.0;
    var_140 = 0;
    var_140 = (j - var_132) * iOpen(NULL,TF[k],(var_124 - j) + i);
    arr_160 += var_140;
   }
   arr_156[i] = arr_160 * 6.0 / (var_124 * (var_124 + 1));
  }
 
  arr_168 = arr_156[1] + ((arr_156[0] - arr_156[1]) * 2) / (var_128 + 1);

  if (arr_156[0] < arr_168) fTL[k]=false; // red ... short 
  else fTL[k]=true; // blue ... long
 }
 
 return;
}
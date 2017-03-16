//+----------------------------------------------------------------------+
//|                                                      10hrXEAComp.mq4 |
//|                                                         David J. Lin |
//|Variation of 10hrX strategy submitted to 2006 MT4 competition by      |
//| Vince (forexportfolio@hotmail.com),                                  |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|(d-lin@northwestern.edu)                                              |
//|Evanston, IL, September 22, 2006                                      |
//|                                                                      |
//|StopLong, StopShort, TakeLong, TakeShort, and TrailingAlls            |
//| based on code by Patrick (IBFX tutorial)                             |
//+----------------------------------------------------------------------+
#property copyright "David J. Lin"
#property link      ""

string Pair="GBPUSD";                // Hardwired pair to trade

//Fixed Lots List:
  
double Lots10hrX;                    // lots to trade 10hrX (dynamically determined)
double Lots10hrXUnload;              // lots to unload 10hrX at TakeProfit_10hrXUnload (dynamically determined)

// Take Profit List:

extern int TakeProfit_10hrXMain=240;        // pips take profit 10hrX main order
extern int TakeProfit_10hrXUnload=110;      // pips take profit 10hrX unload
extern int TrailingStop_10hrX=90;           // pips trailing stop loss for 10hrX main order

extern int MA10hrXslowPeriod=10;            // SMA(10) acts as base line for 10hrX
extern int MA10hrXslowShift=2;              // Shift
extern int MA10hrXslowMethod=MODE_SMA;      // Mode
extern int MA10hrXslowPrice=PRICE_CLOSE;    // Method

int MA10hrXTimeframe=PERIOD_H1;      // use on hourly chart

extern int TriggerPips10hrX=20;             // pips above 10hrSMA/price cross to execute order (trigger)

double TriggerPrice10hrX;            // price of 10hrX trigger, calculated from TriggerPips10hrX at cross
double Time10hrX;                    // time of 10hrSMA/price cross
double Price10hrX;                   // price at 10hrSMA/price cross
datetime OrderTime10hrX=0;           // time of last 10hrX order
bool flag_order10hrX=true;           // true if NO 10hrX order is open
bool flag_10hrXLongCross=false;      // true if long trigger
bool flag_10hrXShortCross=false;     // true if long trigger

int WindowPeriod10hrX=2;             // number of periods after 10hrX trigger for window of opportunity
int BlackOutPeriod10hrX=2;           // hours to ignore future triggers 

// Misc Variables

int Slippage=3;                      // pips slippage allowed

bool flag_dump3=false;               // true if TakeProfit_10hrXUnload-ed
int magic3=3456;                     // 10hrX order's magic number base
string comment10hrX="10hrX";

//===========================================================================================
//===========================================================================================

int init()
{
// hello world

// In case EA becomes disabled/re-activated during trading:
// 1. Redetermine most recent order open times to re-establish proper blackout/opportunity windows.
// 2. Redetermine if a main order has been unloaded.

 int trade;                           
 int trades=OrdersTotal();           
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()!=Pair)
   continue;

  switch(OrderMagicNumber())
  {
   case 3456:
    OrderTime10hrX=OrderOpenTime();
    if(OrderLots()==Lots10hrX)
     flag_dump3=true;
    break;
  }
 }
 return(0); 
}

int deinit()
{
// goodbye world
 return(0);
}

//===========================================================================================
//===========================================================================================

int start()                          // main cycle
{
 DetermineLots();                    // Determine appropriate number of lots to use
 Main10hrX();                        // Detect triggers
 Monitor10hrX();                     // Execute triggers
 TakeProfitUnload();                 // Unload for partial profits
 TrailStop();                        // Trailing Stop
 return(0);
}

//===========================================================================================
//===========================================================================================

void Main10hrX()
{
//Calculate Indicators
 double fast1=iClose(Pair,MA10hrXTimeframe,1);
 double fast2=iClose(Pair,MA10hrXTimeframe,2);
 double fast3=iClose(Pair,MA10hrXTimeframe,3);
 double slow1=iMA(Pair,MA10hrXTimeframe,MA10hrXslowPeriod,MA10hrXslowShift,MA10hrXslowMethod,MA10hrXslowPrice,1); 
 double slow2=iMA(Pair,MA10hrXTimeframe,MA10hrXslowPeriod,MA10hrXslowShift,MA10hrXslowMethod,MA10hrXslowPrice,2);
 double slow3=iMA(Pair,MA10hrXTimeframe,MA10hrXslowPeriod,MA10hrXslowShift,MA10hrXslowMethod,MA10hrXslowPrice,3);

//Check for MA cross
 if(fast1>slow1 && fast2<slow2) // cross UP 1 hour ago
 {
  flag_10hrXLongCross=true;
  flag_10hrXShortCross=false;
  Price10hrX=(slow1+slow2)/2.0;
  Time10hrX=CurTime()-3600;     // adjust time by 1 hr, since it occurred 1 hr ago
  TriggerPrice10hrX=Price10hrX+(TriggerPips10hrX*MarketInfo(Pair,MODE_POINT));
 }
 else if(fast2>slow2 && fast3<slow3) // cross UP 2 hours ago
 {
  flag_10hrXLongCross=true;
  flag_10hrXShortCross=false;  
  Price10hrX=(slow2+slow3)/2.0; 
  Time10hrX=CurTime()-7200;     // adjust time by 2 hrs, since it occurred 2 hrs ago
  TriggerPrice10hrX=Price10hrX+(TriggerPips10hrX*MarketInfo(Pair,MODE_POINT));
 }
   
 if(fast1<slow1 && fast2>slow2) // cross DOWN 1 bar ago
 {
  flag_10hrXLongCross=false;
  flag_10hrXShortCross=true;  
  Price10hrX=(slow1+slow2)/2.0;
  Time10hrX=CurTime()-3600;     // adjust time by 1 hr, since it occurred 1 hr ago
  TriggerPrice10hrX=Price10hrX-(TriggerPips10hrX*MarketInfo(Pair,MODE_POINT));
 }
 else if(fast2<slow2 && fast3>slow3) // cross DOWN 2 bars ago
 {
  flag_10hrXLongCross=false;
  flag_10hrXShortCross=true;
  Price10hrX=(slow2+slow3)/2.0;  
  Time10hrX=CurTime()-7200;     // adjust time by 2 hrs, since it occurred 2 hrs ago
  TriggerPrice10hrX=Price10hrX-(TriggerPips10hrX*MarketInfo(Pair,MODE_POINT));
 }

 return(0);
}

//===========================================================================================
//===========================================================================================

void Monitor10hrX()
{

// Add 1 to WindowPeriod10hrX because crossover determination is delayed 1 full period
// The following gives a 2 hour window, if WindowPeriod10hrX=2:  
  double Window10hrX = (WindowPeriod10hrX*3600)- (CurTime()-Time10hrX);
  double checktime   = (BlackOutPeriod10hrX*3600)-(CurTime()-OrderTime10hrX);

  double SL=0.0;
  
  double AskPrice = MarketInfo(Pair,MODE_ASK);
  double BidPrice = MarketInfo(Pair,MODE_BID);
  
//Enter Long, Exit Short
//      
  if(AskPrice>=TriggerPrice10hrX&&flag_10hrXLongCross==true&&Window10hrX>=0&&checktime<=0)
  {
   CloseLongs(magic3);
   CloseShorts(magic3);

   SL=iLow(Pair,MA10hrXTimeframe,1);
   OrderSend(Pair,OP_BUY,Lots10hrX,AskPrice,Slippage,SL,TakeLong(AskPrice,TakeProfit_10hrXMain),comment10hrX,magic3,0,Blue);
   OrderTime10hrX=CurTime();
   flag_10hrXLongCross=false;
   flag_dump3=true;
 }//Long 
//
//Enter Short, Exit Long 
//
  if(BidPrice<=TriggerPrice10hrX&&flag_10hrXShortCross==true&&Window10hrX>=0&&checktime<=0)
  {
   CloseShorts(magic3);
   CloseLongs(magic3);

   SL=iHigh(Pair,MA10hrXTimeframe,1);  
   OrderSend(Pair,OP_SELL,Lots10hrX,BidPrice,Slippage,SL,TakeShort(BidPrice,TakeProfit_10hrXMain),comment10hrX,magic3,0,Red);
   OrderTime10hrX=CurTime();
   flag_10hrXShortCross=false;
   flag_dump3=true;
  }//Shrt

 return(0);
}

//===========================================================================================
//===========================================================================================

void CloseLongs(int magic)  // by Patrick (w/Mike's loop fix)
{
 int trade;
 int trades=OrdersTotal();
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()==Pair&&OrderMagicNumber()==magic&&OrderType()==OP_BUY)
   OrderClose(OrderTicket(),OrderLots(),MarketInfo(Pair,MODE_BID),Slippage,Blue); 
 } //for
 return(0);
}

//===========================================================================================
//===========================================================================================

void CloseShorts(int magic)  // by Patrick (w/Mike's loop fix)
{
 int trade;
 int trades=OrdersTotal();
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()==Pair&&OrderMagicNumber()==magic&&OrderType()==OP_SELL)
   OrderClose(OrderTicket(),OrderLots(),MarketInfo(Pair,MODE_ASK),Slippage,Red); 
 } //for
 return(0);
}

//===========================================================================================
//===========================================================================================

double TakeLong(double price,int take)  // function to calculate takeprofit if long (by Patrick)
{
 if(take==0)
  return(0.0); // if no take profit
 return(price+(take*MarketInfo(Pair,MODE_POINT))); 
             // plus, since the take profit is above us for long positions
}

//===========================================================================================
//===========================================================================================

double TakeShort(double price,int take)  // function to calculate takeprofit if short (by Patrick)
{
 if(take==0)
  return(0.0); // if no take profit
 return(price-(take*MarketInfo(Pair,MODE_POINT))); 
             // minus, since the take profit is below us for short positions
}

//===========================================================================================
//===========================================================================================

void TakeProfitUnload() // Unload LotsUnload at TakeProfit_MACDUnload and/or LotsUnloadMACD at TakeProfit_MACDUnload
{
  if(flag_dump3) 
   flag_dump3=TakeProfitCycle(flag_dump3,Lots10hrXUnload,magic3,TakeProfit_10hrXUnload);

 return(0); 
}

//===========================================================================================
//===========================================================================================

bool TakeProfitCycle(bool flag, double lots, int magic, int takeprofit) // cycles through proper orders to take profit
{  
 double stopcrnt;
 double stopcal;
  
 int trade;
 int trades=OrdersTotal();
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()!=Pair)
   continue;

//Long 
  if(OrderType()==OP_BUY&&OrderMagicNumber()==magic)
  {
   if(MarketInfo(Pair,MODE_BID)-OrderOpenPrice()>=takeprofit*MarketInfo(Pair,MODE_POINT))
   {
    OrderClose(OrderTicket(),lots,MarketInfo(Pair,MODE_BID),Slippage,Blue);
    flag=false;
   }
   else flag=true;  
  }//Long 
  
//Short 
   if(OrderType()==OP_SELL&&OrderMagicNumber()==magic)
   {
    if(OrderOpenPrice()-MarketInfo(Pair,MODE_ASK)>=takeprofit*MarketInfo(Pair,MODE_POINT))
    {
     OrderClose(OrderTicket(),lots,MarketInfo(Pair,MODE_ASK),Slippage,Red);
     flag=false; 
    }
    else flag=true;  
   }//Short   
  } //for
 return(flag);
}

//===========================================================================================
//===========================================================================================

void TrailStop() // Unload LotsUnload at TakeProfit_MACDUnload and/or LotsUnloadMACD at TakeProfit_MACDUnload
{

  if(TrailingStop_10hrX!=0) 
   TrailingAlls(magic3,TrailingStop_10hrX);
 
 return(0); 
}

//===========================================================================================
//===========================================================================================

// Accomodates multiple trails ... if unloaded, used trailing stop associated with main order 
// otherwise, use the trailing stop associated with TrailingStop_MethodUnload.

void TrailingAlls(int magic,int trail)  // client-side trailing stop (by Patrick, modified by David)
{  
 double stopcrnt;
 double stopcal;

 int trade;
 int trades=OrdersTotal();
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()!=Pair)
   continue;

//Long 
  if(OrderType()==OP_BUY && OrderMagicNumber()==magic)
  { 
   stopcal=MarketInfo(Pair,MODE_BID)-(trail*MarketInfo(Pair,MODE_POINT));  
   stopcrnt=OrderStopLoss();

   if(stopcrnt==0)
    OrderModify(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Blue);
   else if(stopcal>stopcrnt)
    OrderModify(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Blue);
  }//Long 
  
//Short 
  if(OrderType()==OP_SELL && OrderMagicNumber()==magic)
  {
    stopcal=MarketInfo(Pair,MODE_ASK)+(trail*MarketInfo(Pair,MODE_POINT));  
    stopcrnt=OrderStopLoss();
 
    if(stopcrnt==0)
     OrderModify(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red);
    else if(stopcal<stopcrnt)
    OrderModify(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red);
  }//Short   
 } //for
 return(0);
}

//===========================================================================================
//===========================================================================================

void DetermineLots()
{
 double balance=AccountBalance();
 
 if(balance>=6000)
 {
  Lots10hrX=5.0;
  Lots10hrXUnload=2.5;
 }
 else if(balance<6000&&balance>=5000)
 {
  Lots10hrX=4.0;
  Lots10hrXUnload=2.0;
 }
 else if(balance<5000&&balance>=4000)
 {
  Lots10hrX=3.0;
  Lots10hrXUnload=1.5;
 }
 else if(balance<4000&&balance>=3000)
 {
  Lots10hrX=2.0;
  Lots10hrXUnload=1.0;
 }
 else if(balance<3000&&balance>=2000)
 {
  Lots10hrX=1.0;
  Lots10hrXUnload=0.5;
 }
 else if(balance<2000&&balance>=1000)
 {
  Lots10hrX=0.5;
  Lots10hrXUnload=0.25;
 }
 else if(balance<1000&&balance>=500)
 {
  Lots10hrX=0.25;
  Lots10hrXUnload=0.13;
 }
 else
 {
  Lots10hrX=0.13;
  Lots10hrXUnload=0.65;
 }   
 return(0);
}
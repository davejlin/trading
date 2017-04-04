//+----------------------------------------------------------------------+
//|                                                   SecretMA_MACD2.mq4 |
//|                                                         David J. Lin |
//|                                                                      |
//|Based on a Secret MA crossover strategy + MACD crossover adjunct      |
//| by something_witty (IBFX forum) Vince ( forexportfolio@hotmail.com ) |  
//|                                                                      |
//|  - Trigger = crossover of current price action & secret MA & MACD.   |
//|  - Stop Loss = optional for MA order, 70 for MACD order              |
//|  - Take Profit = you can takeprofit w/ 1/2 order                     |
//|  - Trailing stop = optional                                          |
//|  - Timeframe = recommended: H1 or longer, but this EA can be applied |
//|     to any timeframe.                                                |
//|  - Pairs = Any                                                       |
//|  - Money Management = none or stoploss.                              |
//|     WARNING:  this EA does NOT take margin into account,             |
//|               so beware of margin.                                   |
//|  - SecretMA : one open order always by design                        |
//|  - MACD: at most one open order open at a time, future triggers      |
//|          in same direction modifies/tops off previous open order     |
//|          Associated modification sub-routines were                   |
//|          coded by Mike (mike@netwin.co.nz)                           |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|d-lin@northwestern.edu                                                |
//|Evanston, IL, September 13, 2006                                      |
//|                                                                      |
//|StopLong, StopShort, TakeLong, TakeShort, and TrailingAlls            |
//| coded by Patrick (IBFX tutorial)                                     |
//+----------------------------------------------------------------------+
#property copyright "David J. Lin"
#property link      ""

extern bool flag_MA=true;            // toggle for Secret MA trades
extern bool flag_MACD=true;          // toggle for MACD trades
extern double LotsMA=20.0;             // lots to trade Secret MA (fractional values ok)
extern double LotsMAUnload=10.0;       // lots to unload at TakeProfit_MAUnload (fractional values ok)
extern double LotsMACD=20.0;         // lots to trade MACD (fractional values ok)
extern double LotsMACDUnload=10.0;   // lots to unload MACD at TakeProfit_MACDUnload (fractional values ok)
extern int MACDBlackOutPeriod=5;     // number of periods after MACD trigger to ignore additional signals
extern int TakeProfit_MAMain=0;      // pips take profit Secret MA main order
extern int TakeProfit_MAUnload=30;   // pips take profit Secret MA unload
extern int TakeProfit_MACDMain=120;  // pips take profit MACD main order
extern int TakeProfit_MACDUnload=60; // pips take profit MACD unload
extern int StopLoss_MA=0;            // pips stop loss for Secret MA main order
extern int StopLoss_MACD=70;         // pips stop loss for MACD main order
extern int Slippage=3;               // pips slippage allowed
extern int TrailingStop=0;           // pips to trail both Secret MA and MACD orders 
 
int MA1Period=1;                     // EMA(1) acts as trigger line to gauge immediate price action 
int MA1Shift=0;                      // Shift
int MA1Method=MODE_EMA;              // Mode
int MA1Price=PRICE_CLOSE;            // Method

int MA2Period=10;                    // SMA(10) acts as base line
int MA2Shift=25;                     // Shift ... *** Secret *** ... Shhh ...
int MA2Method=MODE_SMA;              // Mode
int MA2Price=PRICE_CLOSE;            // Method

int MACDfast=12;                     // MACD ema fast period
int MACDslow=26;                     // MACD ema slow period
int MACDsignal=9;                    // MACD sma signal period

int magic1=5678;                     // Secret MA order's magic number base
int magic2=8765;                     // MACD order's magic number base
bool flag_dump1=false;               // flag to gauge whether to check TakeProfit_MAUnload
bool flag_dump2=false;               // flag to gauge whether to check TakeProfit_MACDUnload
datetime lasttime=0;                 // stores current bar's time to trigger MA calculation
datetime MACDtime=0;                 // stores time of most recent MACD order
int timeleft=0;                      // stores time remaining in MACD blackout

int init()
{
// hello world
 magic1=magic1+Period();             // adjust magic number based on period 
 magic2=magic2+Period();             // adjust magic number based on period
 
 int trade;                          // Determine order open time of most recent MACD order
 int trades=OrdersTotal();
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()!=Symbol())
   continue;

  if(OrderMagicNumber()==magic2)
   MACDtime=OrderOpenTime();
  else
   MACDtime=0; 
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
 Main();                             // order execution and maintenance
}

//===========================================================================================
//===========================================================================================

void Main()                    // Trigger order execution
{
 TakeProfitUnload();           // Unload part of order
 TrailingAlls(TrailingStop);   // Trailing Stop

 if(lasttime==Time[0])         // only need to trigger MA and MACD orders at the start of each bar
  return(0);
 lasttime=Time[0];

 if(flag_MA)
  MainSecretMA();

 if(flag_MACD)
  MainMACD();

}

//===========================================================================================
//===========================================================================================

void MainSecretMA()
{
//Calculate Secret MA Indicators
 double fast1=iMA(NULL,0,MA1Period,MA1Shift,MA1Method,MA1Price,1); 
 double fast2=iMA(NULL,0,MA1Period,MA1Shift,MA1Method,MA1Price,2);
 double slow1=iMA(NULL,0,MA2Period,MA2Shift,MA2Method,MA2Price,1); 
 double slow2=iMA(NULL,0,MA2Period,MA2Shift,MA2Method,MA2Price,2);
  
//
//Secret MA Enter Long, Exit Short 
//      
 if(fast1>slow1 && fast2<slow2)
 {
  CloseShorts(magic1);
  OrderSend(Symbol(),OP_BUY,LotsMA,Ask,Slippage,StopLong(Ask,StopLoss_MA),TakeLong(Ask,TakeProfit_MAMain),NULL,magic1,0,Blue);
  flag_dump1=true;
 }//Long
  
//
//Secret Enter Short, Exit Long 
//
 if(fast1<slow1 && fast2>slow2)
 {
  CloseLongs(magic1); 
  OrderSend(Symbol(),OP_SELL,LotsMA,Bid,Slippage,StopShort(Bid,StopLoss_MA),TakeShort(Bid,TakeProfit_MAMain),NULL,magic1,0,Red);
  flag_dump1=true;
 }//Shrt
}

//===========================================================================================
//===========================================================================================

void MainMACD()
{
 int ticketNumber;
//Calculate MACD Indicators
 double base1=iMACD(NULL,0,MACDfast,MACDslow,MACDsignal,PRICE_CLOSE,MODE_BASE,1);
 double base2=iMACD(NULL,0,MACDfast,MACDslow,MACDsignal,PRICE_CLOSE,MODE_BASE,2);
 double signal1=iMACD(NULL,0,MACDfast,MACDslow,MACDsignal,PRICE_CLOSE,MODE_SIGNAL,1);
 double signal2=iMACD(NULL,0,MACDfast,MACDslow,MACDsignal,PRICE_CLOSE,MODE_SIGNAL,2);  

// Determine number of seconds from most recent MACD trigger
 timeleft=(MACDBlackOutPeriod*Period()*60)-(Time[0]-MACDtime);
  
//
//Enter MACD Long, Exit Short/Long 
//    
 if(base1>signal1 && base2<signal2 && signal1<-0.0010 && timeleft<=0)
 {
  CloseShorts(magic2);

  ticketNumber = GetLong(magic2); // check whether to modify existing longs
  if(ticketNumber >=0)
   ModifyMACDLongs(ticketNumber);
  else
  {  
   OrderSend(Symbol(),OP_BUY,LotsMACD,Ask,Slippage,StopLong(Ask,StopLoss_MACD),TakeLong(Ask,TakeProfit_MACDMain),NULL,magic2,0,Blue);
   flag_dump2=true;
  }   
  MACDtime=Time[0];
 }//Long 
 
//
//Enter MACD Short, Exit Long/Short
//
 if(base1<signal1 && base2>signal2 && signal1>0.0010 && timeleft<=0)
 {
  CloseLongs(magic2);
   
  ticketNumber = GetShort(magic2); // check whether to modify existing short
  if(ticketNumber >=0)
   ModifyMACDShorts(ticketNumber);
  else
  {
   OrderSend(Symbol(),OP_SELL,LotsMACD,Bid,Slippage,StopShort(Bid,StopLoss_MACD),TakeShort(Bid,TakeProfit_MACDMain),NULL,magic2,0,Red);
   flag_dump2=true;
  }
  MACDtime=Time[0];
 }//Short 
}

//===========================================================================================
//===========================================================================================

void ModifyMACDLongs(int ticketNumber) // by Mike
{
// If long(s) already open, modify so we don't have to repay the spread. 
// If there is a long open and it has lots==LotsMACD we can just modify. If its already been unloaded we can modify the
// exiting one and order a new one to cover the difference. If we have already been through this process and have two
// outstanding orders we modify both.

// Coded by Mike

 int ticketNumber2; 
 double lotsToOrder;
 double profitTarget;

 if(OrderLots() == LotsMACD)
 {  
  OrderModify(ticketNumber,OrderOpenPrice(),StopLong(Ask,StopLoss_MACD),TakeLong(Ask,TakeProfit_MACDMain),0,Blue);
  flag_dump2=true;
 }
 else
 {  
  if(OrderLots() == LotsMACDUnload)
  {  
   OrderModify(ticketNumber,OrderOpenPrice(),StopLong(Ask,StopLoss_MACD),TakeLong(Ask,TakeProfit_MACDUnload),0,Blue);
   lotsToOrder = LotsMACD - LotsMACDUnload;
   profitTarget = TakeLong(Ask,TakeProfit_MACDMain);
  }
  else
  {  
   OrderModify(ticketNumber,OrderOpenPrice(),StopLong(Ask,StopLoss_MACD),TakeLong(Ask,TakeProfit_MACDMain),0,Blue);
   lotsToOrder = LotsMACDUnload;
   profitTarget = TakeLong(Ask,TakeProfit_MACDUnload);
  }
         
  ticketNumber2 = GetLong(magic2,ticketNumber); 
  if(ticketNumber2 >= 0)
   OrderModify(ticketNumber2,OrderOpenPrice(),StopLong(Ask,StopLoss_MACD),profitTarget,0,Blue);
  else
   OrderSend(Symbol(),OP_BUY,lotsToOrder,Ask,Slippage,StopLong(Ask,StopLoss_MACD),profitTarget,NULL,magic2,0,Blue);  
 }
}

//===========================================================================================
//===========================================================================================

void ModifyMACDShorts(int ticketNumber)  // by Mike
{
 int ticketNumber2; 
 double lotsToOrder;
 double profitTarget;
 
 if(OrderLots() == LotsMACD)
 {  
  OrderModify(ticketNumber,OrderOpenPrice(),StopShort(Bid,StopLoss_MACD),TakeShort(Bid,TakeProfit_MACDMain),0,Red);
  flag_dump2=true;
 }
 else
 {  
  if(OrderLots() == LotsMACDUnload)
  {  
   OrderModify(ticketNumber,OrderOpenPrice(),StopShort(Bid,StopLoss_MACD),TakeShort(Bid,TakeProfit_MACDUnload),0,Red);
   lotsToOrder = LotsMACD - LotsMACDUnload;
   profitTarget = TakeShort(Bid,TakeProfit_MACDMain);
  }
  else
  {  
   OrderModify(ticketNumber,OrderOpenPrice(),StopShort(Bid,StopLoss_MACD),TakeShort(Bid,TakeProfit_MACDMain),0,Red);
   lotsToOrder = LotsMACDUnload;
   profitTarget = TakeShort(Bid,TakeProfit_MACDUnload);
  }
         
 ticketNumber2 = GetShort(magic2,ticketNumber); 
 if(ticketNumber2 >= 0)
  OrderModify(ticketNumber2,OrderOpenPrice(),StopShort(Bid,StopLoss_MACD),profitTarget,0,Red);
 else
  OrderSend(Symbol(),OP_SELL,lotsToOrder,Bid,Slippage,StopShort(Bid,StopLoss_MACD),profitTarget,NULL,magic2,0,Red);  
 }
}

//===========================================================================================
//===========================================================================================

int GetLong(int magic, int prevTicket=-1)  // by Mike
{
 int trade;
 int trades=OrdersTotal();
 for(trade=trades-1;trade>=0;trade--)
 {  
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()==Symbol()&&OrderMagicNumber()==magic&&OrderType()==OP_BUY && OrderTicket()!=prevTicket)
   return(OrderTicket());
 }
 return(-1);
}
//===========================================================================================
//===========================================================================================

int GetShort(int magic, int prevTicket=-1)  // by Mike
{
 int trade;
 int trades=OrdersTotal();
 for(trade=trades-1;trade>=0;trade--)
 {  
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()==Symbol()&&OrderMagicNumber()==magic&&OrderType()==OP_SELL && OrderTicket()!=prevTicket)
   return(OrderTicket());
 }
 return(-1);
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
  
  if(OrderSymbol()==Symbol()&&OrderMagicNumber()==magic&&OrderType()==OP_BUY)
   OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Blue); 
 } //for
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
  
  if(OrderSymbol()==Symbol()&&OrderMagicNumber()==magic&&OrderType()==OP_SELL)
   OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Red); 
 } //for
}

//===========================================================================================
//===========================================================================================

double TakeLong(double price,int take)  // function to calculate takeprofit if long (by Patrick)
{
 if(take==0)
  return(0.0); // if no take profit
 return(price+(take*Point)); 
             // plus, since the take profit is above us for long positions
}

//===========================================================================================
//===========================================================================================

double TakeShort(double price,int take)  // function to calculate takeprofit if short (by Patrick)
{
 if(take==0)
  return(0.0); // if no take profit
 return(price-(take*Point)); 
             // minus, since the take profit is below us for short positions
}

//===========================================================================================
//===========================================================================================

double StopLong(double price,int stop) // function to calculate stoploss if long (by Patrick)
{
 if(stop==0)
  return(0.0); // if no stop loss
 return(price-(stop*Point)); 
             // minus, since the stop loss is below us for long positions
             // Point is 0.01 or 0.001 depending on currency, so stop*POINT is a way to convert pips into price with multiplication 
}

//===========================================================================================
//===========================================================================================

double StopShort(double price,int stop) // function to calculate stoploss if short (by Patrick)
{
 if(stop==0)
  return(0.0); // if no stop loss
 return(price+(stop*Point)); 
             // plus, since the stop loss is above us for short positions
}

//===========================================================================================
//===========================================================================================

void TakeProfitUnload() // Unload LotsUnload at TakeProfit_MACDUnload and/or LotsUnloadMACD at TakeProfit_MACDUnload
{
 if(flag_dump1) 
 {
  if(TakeProfit_MAUnload==0||LotsMAUnload==0.0)
   return;  
  flag_dump1=TakeProfitCycle(flag_dump1,LotsMAUnload,magic1,TakeProfit_MAUnload);
 }
 
 if(flag_dump2) 
 {
  if(TakeProfit_MACDUnload==0||LotsMACDUnload==0.0)
   return;  
  flag_dump2=TakeProfitCycle(flag_dump2,LotsMACDUnload,magic2,TakeProfit_MACDUnload);
 } 
 return(0);
}

//===========================================================================================
//===========================================================================================

bool TakeProfitCycle(bool flag, int lots, int magic, int takeprofit) // cycles through proper orders to take profit
{  
 double stopcrnt;
 double stopcal;
  
 int trade;
 int trades=OrdersTotal();
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()!=Symbol())
   continue;

//Long 
  if(OrderType()==OP_BUY&&OrderMagicNumber()==magic)
  {
   if(Bid-OrderOpenPrice()>=takeprofit*Point)
   {
    OrderClose(OrderTicket(),lots,Bid,Slippage,Blue);
    flag=false;
   }  
  }//Long 
  
//Short 
   if(OrderType()==OP_SELL&&OrderMagicNumber()==magic)
   {
    if(OrderOpenPrice()-Ask>=takeprofit*Point)
    {
     OrderClose(OrderTicket(),lots,Ask,Slippage,Red);
     flag=false; 
    } 
   }//Short   
  } //for
 return(flag);
}

//===========================================================================================
//===========================================================================================

void TrailingAlls(int trail)             // client-side trailing stop (by Patrick, modified by David)
{
 if(trail==0)
  return;
  
 double stopcrnt;
 double stopcal;
  
 int trade;
 int trades=OrdersTotal();
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()!=Symbol())
   continue;

//Long 
  if(OrderType()==OP_BUY&&(OrderMagicNumber()==magic1||OrderMagicNumber()==magic2))
  {
   stopcrnt=OrderStopLoss();
   stopcal=Bid-(trail*Point); 
   if(stopcrnt==0)
    OrderModify(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Blue);
   else if(stopcal>stopcrnt)
    OrderModify(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Blue);
  }//Long 
  
//Short 
  if(OrderType()==OP_SELL&&(OrderMagicNumber()==magic1||OrderMagicNumber()==magic2))
  {
   stopcrnt=OrderStopLoss();
   stopcal=Ask+(trail*Point); 
   if(stopcrnt==0)
    OrderModify(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red);
   else if(stopcal<stopcrnt)
    OrderModify(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red);
  }//Short   
 } //for
}



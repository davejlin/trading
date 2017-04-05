//+----------------------------------------------------------------------+
//|                                                         Trifecta.mq4 |
//|                                                         David J. Lin |
//|Three MA cross methods based on the trading strategies of             |
//| Vince (forexportfolio@hotmail.com),                                  |
//|and programmed in collaboration with                                  |
//| Mike  (mike@netwin.co.nz).                                           |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|(d-lin@northwestern.edu)                                              |
//|Evanston, IL, September 24, 2006                                      |
//|                                                                      |
//|StopLong, StopShort, TakeLong, TakeShort, and TrailingAlls            |
//| based on code by Patrick (IBFX tutorial)                             |
//+----------------------------------------------------------------------+
#property copyright "David J. Lin"
#property link      ""

// Toggles for Trading Models (true=active, false=inactive)

extern bool flag_40_200=true;      // toggle for 40/200 MA trades
extern bool flag_7_20  =true;      // toggle for 7/20 MA trades
extern bool flag_10_100=true;      // toggle for 10/100 MA trades


//Fixed Lots List:
  
double Lots1=1.0;                  // lots to trade 40/200 MA (fractional values ok)
double Lots1Unload=0.5;            // lots to unload 40/200   (fractional values ok)
double Lots2=1.0;                  // lots to trade 7/20 MA (fractional values ok)
double Lots2Unload=0.5;            // lots to unload 7/20 (fractional values ok)
double Lots3=1.0;                  // lots to trade 10/100 MA (fractional values ok)
double Lots3Unload=0.5;            // lots to unload 10/100 MA (fractional values ok)


// Take Profit List:

int TakeProfit_1=0;                 // pips take profit 40/200
int TakeProfit_1Unload=80;          // pips take profit 40/200 unload
int TakeProfit_2=0;                 // pips take profit 7/20
int TakeProfit_2Unload=30;          // pips take profit 7/20 unload
int TakeProfit_3=0;                 // pips take profit 10/100
int TakeProfit_3Unload=25;          // pips take profit 10/100 unload


// Stop Loss List:

int StopLoss_1=0;                   // pips stop loss for 40/200
int StopLoss_2=0;                   // pips stop loss for 7/20
int StopLoss_3=0;                   // pips stop loss for 10/100

// Trailing Stop List:

int TrailingStop_1=0;               // pips trailing stop loss for 40/200
int TrailingStop_2=0;               // pips trailing stop loss for 7/20
int TrailingStop_3=0;               // pips trailing stop loss for 10/100

// 40/200 Variables:

int MA1fastPeriod=40;               // Period
int MA1fastTimeframe=PERIOD_M30;    // Timeframe
int MA1fastShift=0;                 // Shift
int MA1fastMethod=MODE_SMA;         // Mode
int MA1fastPrice=PRICE_CLOSE;       // Method

int MA1slowPeriod=200;              // Period
int MA1slowTimeframe=PERIOD_M30;    // Timeframe
int MA1slowShift=0;                 // Shift
int MA1slowMethod=MODE_SMA;         // Mode
int MA1slowPrice=PRICE_CLOSE;       // Method

int BlackoutPeriod1=30;             // minutes to blackout future 40/200 orders after one has occurred
datetime OrderTime1=0;              // time of latest 40/200 order
bool flag_order1=true;              // true if NO 40/200 MA orders are open

// 7/20 Variables:

int MA2fastPeriod=7;                // Period
int MA2fastTimeframe=PERIOD_H4;     // Timeframe
int MA2fastShift=0;                 // Shift
int MA2fastMethod=MODE_SMA;         // Mode
int MA2fastPrice=PRICE_CLOSE;       // Method

int MA2slowPeriod=20;               // Period
int MA2slowTimeframe=PERIOD_H4;     // Timeframe
int MA2slowShift=0;                 // Shift
int MA2slowMethod=MODE_SMA;         // Mode
int MA2slowPrice=PRICE_CLOSE;       // Method

int BlackoutPeriod2=240;            // minutes to blackout future 7/20 orders after one has occurred
datetime OrderTime2=0;              // time of latest 7/20 order
bool flag_order2=true;              // true if NO 7/20 MA orders are open

// 10/100 Variables:

int MA3fastPeriod=10;               // Period
int MA3fastTimeframe=PERIOD_H1;     // Timeframe
int MA3fastShift=0;                 // Shift
int MA3fastMethod=MODE_SMA;         // Mode
int MA3fastPrice=PRICE_CLOSE;       // Method

int MA3slowPeriod=100;              // Period
int MA3slowTimeframe=PERIOD_H1;     // Timeframe
int MA3slowShift=0;                 // Shift
int MA3slowMethod=MODE_SMA;         // Mode
int MA3slowPrice=PRICE_CLOSE;       // Method

int BlackoutPeriod3=60;             // minutes to blackout future 10/100 orders after one has occurred
datetime OrderTime3=0;              // time of latest 10/100 order
bool flag_order3=true;              // true if NO 10/100 MA orders are open

// Misc Variables

int Slippage=3;                      // pips slippage allowed

// Flags which indicate partial takeprofit unloading

bool flag_dump1=false;               // true if 40/200 Unload-ed
bool flag_dump2=false;               // true if 7/20 Unload-ed
bool flag_dump3=false;               // true if 10/100 Unload-ed

// Magic numbers (to identify which orders belong to which models)

int magic1=40200;                    // 40/200 magic number base
int magic2=720;                      // 7/20 magic number base
int magic3=10100;                    // 10/100 magic number base

// Strings 

string comment1="40_200";
string comment2="7_20";
string comment3="10_100";

//===========================================================================================
//===========================================================================================

int start()                          // main cycle
{
 OrderStatus();                      // check order status to establish open orders and time
 DisplayStatus();                    // display current status of methods
 Main();                             // order execution and maintenance
}

//===========================================================================================
//===========================================================================================

void Main()                          // Main Cycle
{
                                     // The following need every tick info:  
 if(flag_40_200)
  Main1();

 if(flag_7_20)
  Main2();   

 if(flag_10_100)
  Main3();
                                         
 TakeProfitUnload();                 // Unload for partial profits
 TrailStop();                        // Trailing Stop
   
 return(0);
}

//===========================================================================================
//===========================================================================================

void Main1()
{
//Calculate Secret MA Indicators
 double fast1=iMA(NULL,MA1fastTimeframe,MA1fastPeriod,MA1fastShift,MA1fastMethod,MA1fastPrice,1); 
 double fast2=iMA(NULL,MA1fastTimeframe,MA1fastPeriod,MA1fastShift,MA1fastMethod,MA1fastPrice,2);
 double slow1=iMA(NULL,MA1slowTimeframe,MA1slowPeriod,MA1slowShift,MA1slowMethod,MA1slowPrice,1); 
 double slow2=iMA(NULL,MA1slowTimeframe,MA1slowPeriod,MA1slowShift,MA1slowMethod,MA1slowPrice,2);

 double checktime=(BlackoutPeriod1*60)-(CurTime()-OrderTime1); // need to monitor time in case of EA re-start

//40/200 MA Enter Long, Close Shorts
//      
  if(fast1>slow1&&fast2<slow2&&checktime<0)
  {
   CloseShorts(magic1);
   SendOrderLong(Symbol(),Lots1,Slippage,StopLong(Ask,StopLoss_1),TakeLong(Ask,TakeProfit_1),comment1,magic1,0,Blue);
   flag_dump1=true;
   OrderTime1=CurTime();
  }//Long
  
//
//40/200 MA Enter Short, Close Longs
//
  if(fast1<slow1&&fast2>slow2&&checktime<0)
  {
   CloseLongs(magic1);
   SendOrderShort(Symbol(),Lots1,Slippage,StopShort(Bid,StopLoss_1),TakeShort(Bid,TakeProfit_1),comment1,magic1,0,Red);
   flag_dump1=true;
   OrderTime1=CurTime();   
  }//Shrt   
  
 return(0);
}

//===========================================================================================
//===========================================================================================

void Main2()
{
//Calculate Secret MA Indicators
 double fast1=iMA(NULL,MA2fastTimeframe,MA2fastPeriod,MA2fastShift,MA2fastMethod,MA2fastPrice,1); 
 double fast2=iMA(NULL,MA2fastTimeframe,MA2fastPeriod,MA2fastShift,MA2fastMethod,MA2fastPrice,2);
 double slow1=iMA(NULL,MA2slowTimeframe,MA2slowPeriod,MA2slowShift,MA2slowMethod,MA2slowPrice,1); 
 double slow2=iMA(NULL,MA2slowTimeframe,MA2slowPeriod,MA2slowShift,MA2slowMethod,MA2slowPrice,2);

 double checktime=(BlackoutPeriod2*60)-(CurTime()-OrderTime2); // need to monitor time in case of EA re-start

//7/20 MA Enter Long, Close Shorts
//      
  if(fast1>slow1&&fast2<slow2&&checktime<0)
  {
   CloseShorts(magic2);
   SendOrderLong(Symbol(),Lots2,Slippage,StopLong(Ask,StopLoss_2),TakeLong(Ask,TakeProfit_2),comment2,magic2,0,Blue);
   flag_dump2=true;
   OrderTime2=CurTime();
  }//Long
  
//
//7/20 MA Enter Short, Close Longs
//
  if(fast1<slow1&&fast2>slow2&&checktime<0)
  {
   CloseLongs(magic2);
   SendOrderShort(Symbol(),Lots2,Slippage,StopShort(Bid,StopLoss_2),TakeShort(Bid,TakeProfit_2),comment2,magic2,0,Red);
   flag_dump2=true;
   OrderTime2=CurTime();   
  }//Shrt   
  
 return(0);
}

//===========================================================================================
//===========================================================================================

void Main3()
{
//Calculate Secret MA Indicators
 double fast1=iMA(NULL,MA3fastTimeframe,MA3fastPeriod,MA3fastShift,MA3fastMethod,MA3fastPrice,1); 
 double fast2=iMA(NULL,MA3fastTimeframe,MA3fastPeriod,MA3fastShift,MA3fastMethod,MA3fastPrice,2);
 double slow1=iMA(NULL,MA3slowTimeframe,MA3slowPeriod,MA3slowShift,MA3slowMethod,MA3slowPrice,1); 
 double slow2=iMA(NULL,MA3slowTimeframe,MA3slowPeriod,MA3slowShift,MA3slowMethod,MA3slowPrice,2);

 double checktime=(BlackoutPeriod3*60)-(CurTime()-OrderTime3); // need to monitor time in case of EA re-start

//10/100 MA Enter Long, Close Shorts
//      
  if(fast1>slow1&&fast2<slow2&&checktime<0)
  {
   CloseShorts(magic3);
   SendOrderLong(Symbol(),Lots3,Slippage,StopLong(Ask,StopLoss_3),TakeLong(Ask,TakeProfit_3),comment3,magic3,0,Blue);
   flag_dump3=true;
   OrderTime3=CurTime();
  }//Long
  
//
//40/200 MA Enter Short, Close Longs
//
  if(fast1<slow1&&fast2>slow2&&checktime<0)
  {
   CloseLongs(magic3);
   SendOrderShort(Symbol(),Lots3,Slippage,StopShort(Bid,StopLoss_3),TakeShort(Bid,TakeProfit_3),comment3,magic3,0,Red);
   flag_dump3=true;
   OrderTime3=CurTime();   
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
  
  if(OrderSymbol()==Symbol()&&OrderMagicNumber()==magic&&OrderType()==OP_BUY)
   CloseOrderLong(OrderTicket(),OrderLots(),Slippage,Blue); 
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
  
  if(OrderSymbol()==Symbol()&&OrderMagicNumber()==magic&&OrderType()==OP_SELL)
   CloseOrderShort(OrderTicket(),OrderLots(),Slippage,Red); 
 } //for
 return(0);
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

void TakeProfitUnload() // Unload 
{
 if(flag_dump1) 
 {
  if(TakeProfit_1Unload!=0) 
   flag_dump1=TakeProfitCycle(flag_dump1,Lots1Unload,magic1,TakeProfit_1Unload);
 }
 
 if(flag_dump2) 
 {
  if(TakeProfit_2Unload!=0)
   flag_dump2=TakeProfitCycle(flag_dump2,Lots2Unload,magic2,TakeProfit_2Unload);
 }
  
  if(flag_dump3) 
 {
  if(TakeProfit_3Unload!=0)
   flag_dump3=TakeProfitCycle(flag_dump3,Lots3Unload,magic3,TakeProfit_3Unload);
 }

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
  
  if(OrderSymbol()!=Symbol())
   continue;

//Long 
  if(OrderType()==OP_BUY&&OrderMagicNumber()==magic)
  {
   if(Bid-OrderOpenPrice()>=takeprofit*Point)
   {
    CloseOrderLong(OrderTicket(),lots,Slippage,Blue);
    flag=false;
   }
   else flag=true;  
  }//Long 
  
//Short 
   if(OrderType()==OP_SELL&&OrderMagicNumber()==magic)
   {
    if(OrderOpenPrice()-Ask>=takeprofit*Point)
    {
     CloseOrderShort(OrderTicket(),lots,Slippage,Red);
     flag=false; 
    }
    else flag=true;  
   }//Short   
  } //for
 return(flag);
}

//===========================================================================================
//===========================================================================================

void TrailStop() 
{
 if(flag_40_200) 
 {
  if(TrailingStop_1!=0) 
   TrailingAlls(magic1,TrailingStop_1);
 }
 
 if(flag_7_20) 
 {
  if(TrailingStop_2!=0) 
   TrailingAlls(magic2,TrailingStop_2);
 }
 
  if(flag_10_100) 
 {
  if(TrailingStop_3!=0) 
   TrailingAlls(magic3,TrailingStop_3);
 }
 
 return(0); 
}

//===========================================================================================
//===========================================================================================

// Accomodates multiple trails ... if unloaded, used trailing stop associated with main order 
// otherwise, use the trailing stop associated with TrailingStop_MethodUnload.

void TrailingAlls(int magic,int trail,int trail2=-1,double lots1=0,double lots2=0)  // client-side trailing stop (by Patrick, modified by David)
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
  if(OrderType()==OP_BUY && OrderMagicNumber()==magic)
  { 
  if(trail2==-1)
   stopcal=Bid-(trail*Point);  
  else
  {
   if(OrderLots()==lots1-lots2) // unloaded, so use trail
    stopcal=Bid-(trail*Point); 
   else
    stopcal=Bid-(trail2*Point); // not yet unloaded, so use TrailingStop_MethodUnload
  }
  
   stopcrnt=OrderStopLoss();

   if(stopcrnt==0)
    ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Blue);
   else if(stopcal>stopcrnt)
    ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Blue);
  }//Long 
  
//Short 
  if(OrderType()==OP_SELL && OrderMagicNumber()==magic)
  {
   if(trail2==-1)
    stopcal=Ask+(trail*Point);  
   else
   {
    if(OrderLots()==lots1-lots2) // unloaded, so use trail
     stopcal=Ask+(trail*Point); 
    else
     stopcal=Ask+(trail2*Point); // not yet unloaded, so use TrailingStop_MethodUnload
   }
   
    stopcrnt=OrderStopLoss();
 
    if(stopcrnt==0)
     ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red);
    else if(stopcal<stopcrnt)
     ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red);
  }//Short   
 } //for
 return(0);
}

//===========================================================================================
//===========================================================================================

void OrderStatus()                   // Check order status
{
 int trade;                          // dummy variable to cycle through trades
 int trades=OrdersTotal();           // total number of open orders
 
 flag_order1=true;                   // first assume we have no open 40/200 orders
 flag_order2=true;                   // first assume we have no open 7/20 orders
 flag_order3=true;                   // first assume we have no open 10/100 orders

 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
   
  if(OrderSymbol()!=Symbol())
   continue;
   
  switch(OrderMagicNumber())
  {
   case 40200:
    flag_order1=false;              // false if there are open 40/200 orders
    continue;
   case 720:
    flag_order2=false;              // false if there are open 7/20 orders
    continue;
   case 10100:
    flag_order3=false;              // false if there are open 10/100 orders
    continue;
  }
 }
return(0);
}
  
//===========================================================================================
//===========================================================================================

int init()
{
// hello world

// Set semaphore for multiple threads
 if(!GlobalVariableCheck("SEMAPHORE"))
  GlobalVariableSet("SEMAPHORE",0);

// In case EA becomes disabled/re-activated during trading:
// 1. Redetermine most recent order open times to re-establish proper blackout/opportunity windows.
// 2. Redetermine if a main order has been unloaded.

// First check closed trades
 int trade;                         
 int trades=HistoryTotal();           
 for(trade=trades-1;trade>=0;trade--)   // The most recent closed order has the largest position number, so this works backward from the most recent closed orders
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_HISTORY);

  if(OrderSymbol()!=Symbol())
   continue;

  double timediff=(CurTime()-OrderCloseTime())/3600;  // time difference in hours
  
  if(timediff >= 1) // only interested in closed trades in this hour
   continue;

  switch(OrderMagicNumber())
  {
   case 40200: 
    OrderTime1=OrderOpenTime();
    continue;
   case 720:
    OrderTime2=OrderOpenTime();
    continue;
   case 10100:
    OrderTime3=OrderOpenTime();
    continue;
  }   
 } 

// Now, check open trades
                           
 trades=OrdersTotal();           
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()!=Symbol())
   continue;

  switch(OrderMagicNumber())
  {
   case 40200: 
    OrderTime1=OrderOpenTime();
    if(OrderLots()==Lots1)
     flag_dump1=true;
    continue;
   case 720:
    OrderTime2=OrderOpenTime();
    if(OrderLots()==Lots2)
     flag_dump2=true;
    continue;
   case 10100:
    OrderTime3=OrderOpenTime();
    if(OrderLots()==Lots3)
     flag_dump3=true;
    continue;
  }
 }
 return(0); 
}

//===========================================================================================
//===========================================================================================

int deinit()
{
// goodbye world
 return(0);
}

//===========================================================================================
//===========================================================================================

int SendOrderLong(string sym, double vol, int slip, double sl, double tp, string comment="", int magic=0, datetime exp=0, color cl=CLR_NONE)
{  
 int err;
 GetSemaphore();
 for(int z=0;z<5;z++)
 {  
  if(OrderSend(sym,OP_BUY,vol,Ask,slip,sl,tp,comment,magic,exp,cl)<0)
  {  
   err = GetLastError();
   Print("OrderClose long failed, Error: ", err, " Magic Number: ", magic);
   if(err>4000) break;
   RefreshRates();
  }
  else
   break;
 }
 ReleaseSemaphore();
}

//===========================================================================================
//===========================================================================================

int SendOrderShort(string sym, double vol, int slip, double sl, double tp, string comment="", int magic=0, datetime exp=0, color cl=CLR_NONE)
{  
 int err;
 GetSemaphore();
 for(int z=0;z<5;z++)
 {  
  if(OrderSend(sym,OP_SELL,vol,Bid,slip,sl,tp,comment,magic,exp,cl)<0)
  {  
   err = GetLastError();
   Print("OrderClose short failed, Error: ", err, " Magic Number: ", magic);
   if(err>4000) break;
   RefreshRates();
  }
  else
   break;
 }
 ReleaseSemaphore();
}

//===========================================================================================
//===========================================================================================

bool CloseOrderLong(int ticket, double lots, int slip, color cl=CLR_NONE)
{
 int err;

 GetSemaphore();
 for(int z=0;z<10;z++)
 {
  if(!OrderClose(ticket,lots,Bid,slip,cl))
  {  
   err = GetLastError();
   Print("OrderClose long failed, Error: ", err, " Ticket #: ", ticket);
   if(err>4000) 
    break;
   RefreshRates();
  }
  else
  break;
 }
 ReleaseSemaphore();
} 

//===========================================================================================
//===========================================================================================

bool CloseOrderShort(int ticket, double lots, int slip, color cl=CLR_NONE)
{
 int err;

 GetSemaphore();
 for(int z=0;z<10;z++)
 {
  if(!OrderClose(ticket,lots,Ask,slip,cl))
  {  
   err = GetLastError();
   Print("OrderClose short failed, Error: ", err, " Ticket #: ", ticket);
   if(err>4000) 
    break;
   RefreshRates();
  }
  else
  break;
 }
 ReleaseSemaphore();
} 

//===========================================================================================
//===========================================================================================

bool ModifyOrder(int ticket, double price, double sl, double tp, datetime exp, color cl=CLR_NONE) // by Mike
{
 GetSemaphore();
 OrderModify(ticket,price,sl,tp,exp,cl);
 ReleaseSemaphore();
}

//===========================================================================================
//===========================================================================================

bool GetSemaphore()  // by Mike
{  
 while(!IsStopped())
 {  
  if(GlobalVariableSetOnCondition("SEMAPHORE",1,0)==true)  
   break;
  Sleep(500);
 }
 return(true);
}

//===========================================================================================
//===========================================================================================

bool ReleaseSemaphore()  // by Mike
{  GlobalVariableSet("SEMAPHORE",0);
   return(true);
}

//===========================================================================================
//===========================================================================================

void DisplayStatus()
{
 ObjectSetText( "Hello", "Hello", 10, "Arial", Black );
 return(0);
}
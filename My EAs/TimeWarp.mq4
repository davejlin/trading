//+------------------------------------------------------------------+
//|                                                     TimeWarp.mq4 |
//|                                                     David J. Lin |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "David J. Lin"
#property link      ""

extern bool flag_TWFilter=true;           // toggle for Laguerre Filter method
extern bool flag_TWRSI=true;              // toggle for Laguerre RSI method
extern bool flag_TWFilterRSI=true;        // toggle for Laguerre Filter+RSI methods

// Laguerre Filter:
double Lots=1.0;                   // lots to order
double LotsUnload=0.5;             // unload partial order
int TakeProfit=0;                  // pips to take profit
int TakeProfit_Unload=0;           // pips to take profit for unload order
int StopLoss=0;                    // pips to stop loss
int TrailingStop=0;                // pips to trail stop (activated only after order is unloaded)
int TrailingStop_Unload=0;         // pips to trail stop (for the partial order which will be unloaded)

int MA_Period=12;                  // MA period for trigger line
int MA_Shift=0;                    // MA shift for trigger line
int MA_Method=MODE_EMA;            // MA method for trigger line
int MA_Price=MODE_CLOSE;           // MA price for trigger line

int OrderTime=0;                   // time of most recent open order
int checktime=0;                   // time remaining during which to ignore future triggers

extern double Gamma2=0.70;         // gamma for 2 point Laguerre Filter
extern double Gamma4=0.925;        // gamma for 4 point Laguerre Filter

// Laguerre RSI:
double LotsRSI=1.0;                // lots to order
double LotsRSIUnload=0.5;          // unload partial order
int TakeProfitRSI=0;               // pips to take profit
int TakeProfitRSI_Unload=0;        // pips to take profit for unload order
int StopLossRSI=0;                 // pips to stop loss
int TrailingStopRSI=0;             // pips to trail stop (activated only after order is unloaded)
int TrailingStopRSI_Unload=0;      // pips to trail stop (for the partial order which will be unloaded)

int OrderTimeRSI=0;                // time of most recent open order
int checktimeRSI=0;                // time remaining during which to ignore future triggers

extern double GammaRSI=0.50;       // gamma for Laguerre RSI
double LRSIhigh=0.80;       // upper limit for Laguerre RSI
double LRSIlow =0.20;       // lower limit for Laguerre RSI

// Laguerre Filter/RSI:
double LotsFilterRSI=1.0;                // lots to order
double LotsFilterRSIUnload=0.5;          // unload partial order
int TakeProfitFilterRSI=0;               // pips to take profit
int TakeProfitFilterRSI_Unload=0;        // pips to take profit for unload order
int StopLossFilterRSI=0;                 // pips to stop loss
int TrailingStopFilterRSI=0;             // pips to trail stop (activated only after order is unloaded)
int TrailingStopFilterRSI_Unload=0;      // pips to trail stop (for the partial order which will be unloaded)

double LFilterRSIthreshhold=0.50;              // dividing line to determine strength

extern int stoch1=10;
extern int stoch2=3;
extern int stoch3=3;
double stochLow=30.0;
double stochHigh=70.0;
int stochMethod=MODE_SMA;

int OrderTimeFilterRSI=0;                // time of most recent open order
int checktimeFilterRSI=0;                // time remaining during which to ignore future triggers

int Slippage=3;                    // pips slippage allowed

int BlackOutPeriod=0;              // minutes to ignore future triggers after an order is opened

int modeL2=0;                      // mode number for 2 point Laguerre in iCustom call to LaguerreFilterDJL
int modeL4=1;                      // mode number for 4 point Laguerre in iCustom call to LaguerreFilterDJL
int modeRSI=0;                     // mode number for Laguerre RSI in iCustom call to LaguerreRSI

int magic=727;                     // magic number for Laguerre Filter orders 
int magicRSI=272;                  // magic number for Laguerre RSI orders
int magicFilterRSI=777;            // magic number for Laguerre Filter+RSI orders
string comment="Laguerre Filter";  // comment for order
string commentRSI="Laguerre RSI";  // comment for order
string commentFilterRSI="Laguerre Filter/RSI"; // comment for order
bool flag_order=false;             // TRUE if NO orders are open
bool flag_dump=false;              // TRUE if order has NOT been unloaded yet
bool flag_orderRSI=false;          // TRUE if NO orders are open
bool flag_dumpRSI=false;           // TRUE if order has NOT been unloaded yet
bool flag_orderFilterRSI=false;          // TRUE if NO orders are open
bool flag_dumpFilterRSI=false;           // TRUE if order has NOT been unloaded yet

//===========================================================================================
//===========================================================================================

int start()
{
 OrderStatus();
 DisplayStatus();
 Main();
 return(0);
}
//===========================================================================================
//===========================================================================================

void OrderStatus()                   // Check order status
{
 int trade;                          // dummy variable to cycle through trades
 int trades=OrdersTotal();           // total number of open orders
 
 flag_order=true;                    // first assume we have no open Laguerre Filter orders
 flag_orderRSI=true;                 // first assume we have no open Laguerre RSI orders
 flag_orderFilterRSI=true;           // first assume we have no open Laguerre Filter/RSI orders

 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
   
  if(OrderSymbol()!=Symbol())
   continue;
   
  switch(OrderMagicNumber())
  {
   case 727:
    flag_order=false;                // false if there are open orders
    break;
   case 272:
    flag_orderRSI=false;                // false if there are open orders
    break;
   case 777:
    flag_orderFilterRSI=false;                // false if there are open orders
    break;       
  }
  
 }
 return(0);
}

//===========================================================================================
//===========================================================================================

void Main()
{
 if(flag_TWFilter) MainTimeWarpFilter();
 if(flag_TWRSI) MainTimeWarpRSI();
 if(flag_TWFilterRSI) MainTimeWarpFilterRSI();
 TakeProfitUnload();
 TrailStop();
 return(0);
}

//===========================================================================================
//===========================================================================================
void MainTimeWarpFilter()
{
 double MA1   = iMA(NULL,0,MA_Period,MA_Shift,MA_Method,MA_Price,1);
 double MA2   = iMA(NULL,0,MA_Period,MA_Shift,MA_Method,MA_Price,2);
 double L21   = iCustom(NULL,0,"LaguerreFilterDJL",Gamma2,Gamma4,modeL2,1);
 double L22   = iCustom(NULL,0,"LaguerreFilterDJL",Gamma2,Gamma4,modeL2,2);  
 double L41   = iCustom(NULL,0,"LaguerreFilterDJL",Gamma2,Gamma4,modeL4,1);
 double L42   = iCustom(NULL,0,"LaguerreFilterDJL",Gamma2,Gamma4,modeL4,2);

 checktime   = (BlackOutPeriod*60)-(CurTime()-OrderTime);
 
// if(MA1>L1&&MA2<L2&&checktime<0) // enter long, exit short
 if(L21>L41&&L22<L42&&checktime<0) // enter long, exit short
 {
  CloseShorts(magic);
  SendOrderLong(Symbol(),Lots,Slippage,StopLong(Ask,StopLoss),TakeLong(Ask,TakeProfit),comment,magic,0,Blue);
  OrderTime=CurTime();
  flag_dump=true;
 }
 
// if(MA1<L1&&MA2>L2&&checktime<0) // enter short, exit long
 if(L21<L41&&L22>L42&&checktime<0) // enter short, exit long
 {
  CloseLongs(magic);
  SendOrderShort(Symbol(),Lots,Slippage,StopShort(Bid,StopLoss),TakeShort(Bid,TakeProfit),comment,magic,0,Red);
  OrderTime=CurTime();
  flag_dump=true;   
 }

 return(0);
}

//===========================================================================================
//===========================================================================================

void MainTimeWarpRSI()
{
 double LRSI1 = iCustom(NULL,0,"Laguerre RSI",GammaRSI,modeRSI,1);
 double LRSI2 = iCustom(NULL,0,"Laguerre RSI",GammaRSI,modeRSI,2);

 checktimeRSI   = (BlackOutPeriod*60)-(CurTime()-OrderTimeRSI);

 if(flag_orderRSI)
 { 
  if(LRSI1>LRSIlow&&LRSI2<=LRSIlow&&checktimeRSI<0) // enter long, exit short
  {
   CloseShorts(magicRSI);
   SendOrderLong(Symbol(),LotsRSI,Slippage,StopLong(Ask,StopLossRSI),TakeLong(Ask,TakeProfitRSI),commentRSI,magicRSI,0,Blue);
   OrderTimeRSI=CurTime();
   flag_dumpRSI=true;
  }
 
  if(LRSI1<LRSIhigh&&LRSI2>=LRSIhigh&&checktimeRSI<0) // enter short, exit long
  {
   CloseLongs(magicRSI);
   SendOrderShort(Symbol(),LotsRSI,Slippage,StopShort(Bid,StopLossRSI),TakeShort(Bid,TakeProfitRSI),commentRSI,magicRSI,0,Red);
   OrderTimeRSI=CurTime();
   flag_dumpRSI=true;   
  }
 } 
 else
 {
  if(LRSI1>LRSIlow&&LRSI2<=LRSIlow) 
   CloseShorts(magicRSI);
  if(LRSI1<LRSIhigh&&LRSI2>=LRSIhigh)
   CloseLongs(magicRSI);
 }
 return(0);
 
} 
//===========================================================================================
//===========================================================================================
void MainTimeWarpFilterRSI()
{
// Lagurerre
 double L21   = iCustom(NULL,0,"LaguerreFilterDJL",Gamma2,Gamma4,modeL2,1);
 double L22   = iCustom(NULL,0,"LaguerreFilterDJL",Gamma2,Gamma4,modeL2,2);  
 double L41   = iCustom(NULL,0,"LaguerreFilterDJL",Gamma2,Gamma4,modeL4,1);
 double L42   = iCustom(NULL,0,"LaguerreFilterDJL",Gamma2,Gamma4,modeL4,2);

// Laguerre RSI
 double LRSI1 = iCustom(NULL,0,"Laguerre RSI",GammaRSI,modeRSI,1);
 double LRSI2 = iCustom(NULL,0,"Laguerre RSI",GammaRSI,modeRSI,2); 

 // stochastics
 double stochasticBase1=iStochastic(NULL,0,stoch1,stoch2,stoch3,stochMethod,0,MODE_BASE,1);
 double stochasticBase2=iStochastic(NULL,0,stoch1,stoch2,stoch3,stochMethod,0,MODE_BASE,2);
 double stochasticSign1=iStochastic(NULL,0,stoch1,stoch2,stoch3,stochMethod,0,MODE_SIGNAL,1);
 double stochasticSign2=iStochastic(NULL,0,stoch1,stoch2,stoch3,stochMethod,0,MODE_SIGNAL,2);


 checktimeFilterRSI   = (BlackOutPeriod*60)-(CurTime()-OrderTimeFilterRSI);

 if(flag_orderFilterRSI)
 { 
  if(L21>L41&&L22<L42&&LRSI1>=LFilterRSIthreshhold&&checktimeFilterRSI<0) // enter long
  {
//   if(stochasticBase1>stochasticBase2&&stochasticSign1>stochasticSign2&&stochasticBase1<=stochHigh)  
//   if(stochasticBase1>=stochHigh)
   {
    SendOrderLong(Symbol(),LotsFilterRSI,Slippage,StopLong(Ask,StopLossFilterRSI),TakeLong(Ask,TakeProfitFilterRSI),commentFilterRSI,magicFilterRSI,0,Blue);
    OrderTimeFilterRSI=CurTime();
    flag_dumpFilterRSI=true;
   } 
  }
 
  if(L21<L41&&L22>L42&&LRSI1<=LFilterRSIthreshhold&&checktimeFilterRSI<0) // enter short
  {
//   if(stochasticBase1<stochasticBase2&&stochasticSign1<stochasticSign2&&stochasticBase1>=stochLow)
//   if(stochasticBase1<=stochLow)
   {  
    SendOrderShort(Symbol(),LotsFilterRSI,Slippage,StopShort(Bid,StopLossFilterRSI),TakeShort(Bid,TakeProfitFilterRSI),commentFilterRSI,magicFilterRSI,0,Red);
    OrderTimeFilterRSI=CurTime();
    flag_dumpFilterRSI=true;   
   }
  }
 } 
 else
 {
//  if((L21>L41&&L22<L42)||(LRSI2<LFilterRSIthreshhold&&LRSI1>=LFilterRSIthreshhold))
  if(L21>L41&&L22<L42)
   CloseShorts(magicFilterRSI); 
//  if((L21<L41&&L22>L42)||(LRSI2>=LFilterRSIthreshhold&&LRSI1<LFilterRSIthreshhold)) 
  if(L21<L41&&L22>L42)
   CloseLongs(magicFilterRSI);
 }
 
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

void TakeProfitUnload() // Unload LotsUnload at TakeProfit_Unload
{
 if(flag_dump) 
 {
  if(TakeProfit_Unload!=0) 
   flag_dump=TakeProfitCycle(flag_dump,LotsUnload,magic,TakeProfit_Unload);
 }

 if(flag_dumpRSI) 
 {
  if(TakeProfitRSI_Unload!=0) 
   flag_dumpRSI=TakeProfitCycle(flag_dumpRSI,LotsRSIUnload,magicRSI,TakeProfitRSI_Unload);
 } 
 
 if(flag_dumpFilterRSI) 
 {
  if(TakeProfitFilterRSI_Unload!=0) 
   flag_dumpFilterRSI=TakeProfitCycle(flag_dumpFilterRSI,LotsFilterRSIUnload,magicFilterRSI,TakeProfitFilterRSI_Unload);
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

void TrailStop() // Unload LotsUnload at TakeProfit_MACDUnload and/or LotsUnloadMACD at TakeProfit_MACDUnload
{
  if(TrailingStop!=0) 
   TrailingAlls(magic,TrailingStop,TrailingStop_Unload,Lots,LotsUnload);

  if(TrailingStopRSI!=0) 
   TrailingAlls(magicRSI,TrailingStopRSI,TrailingStopRSI_Unload,LotsRSI,LotsRSIUnload);   

  if(TrailingStopFilterRSI!=0) 
   TrailingAlls(magicFilterRSI,TrailingStopFilterRSI,TrailingStopFilterRSI_Unload,LotsFilterRSI,LotsFilterRSIUnload);   
    
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

int init()
{
// hello world
// Set semaphore for multiple threads
 if(!GlobalVariableCheck("SEMAPHORE"))
  GlobalVariableSet("SEMAPHORE",0);

// In case EA becomes disabled/re-activated during trading:
// 1. Redetermine most recent order open times to re-establish proper blackout/opportunity windows.
// 2. Redetermine if a main order has been unloaded.

// In case EA becomes disabled/re-activated during trading,
// re-determine most recent order close times to prevent re-submission before a full period (hour or day) has elapsed

// First check closed trades
 int trade;                         
 int trades=HistoryTotal();           
 for(trade=trades-1;trade>=0;trade--)   // The most recent closed order has the largest position number, so this works backward from the most recent closed orders
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_HISTORY);

  if(OrderSymbol()!=Symbol())
   continue;

  double timediff=(CurTime()-OrderCloseTime())/60;  // time difference in minutes
  
  if(timediff >= Period()) // only interested in closed trades in this period
   continue;

  switch(OrderMagicNumber())
  {
   case 727: 
    OrderTime=OrderOpenTime();
    continue;
   case 272:
    OrderTimeRSI=OrderOpenTime();
    continue; 
   case 777:
    OrderTimeFilterRSI=OrderOpenTime();
    continue;     
  }   
 } 

// Now check open orders
                       
 trades=OrdersTotal();           
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()!=Symbol())
   continue;

  switch(OrderMagicNumber())
  {
   case 727: 
    OrderTime=OrderOpenTime();
    if(OrderLots()==Lots)
     flag_dump=true;
    continue;
   case 272:
    OrderTimeRSI=OrderOpenTime();
    if(OrderLots()==LotsRSI)
     flag_dumpRSI=true;    
    continue;
   case 777:
    OrderTimeFilterRSI=OrderOpenTime();
    if(OrderLots()==LotsFilterRSI)
     flag_dumpFilterRSI=true;     
    continue;     
  }
 } 
 DisplayStatusInit();
 BlackOutPeriod=Period();
 return(0);
}

//===========================================================================================
//===========================================================================================

int deinit()
{
 return(0);
}

//===========================================================================================
//===========================================================================================

void DisplayStatus()
{
 return(0);
}

//===========================================================================================
//===========================================================================================

void DisplayStatusInit()
{
 return(0);
}

//===========================================================================================
//===========================================================================================


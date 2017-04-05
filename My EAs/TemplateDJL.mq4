//+------------------------------------------------------------------+
//|                                                  TemplateDJL.mq4 |
//|                                                     David J. Lin |
//| Super skeletal template for trading EAs                          |
//| Coded by David J. Lin                                            |
//| d-lin@northwestern.edu                                           |
//|                                                                  |
//| September 28, 2006                                               |
//+------------------------------------------------------------------+
#property copyright "David J. Lin"
#property link      ""

double Lots=1.0;                // lots to order
double LotsUnload=0.5;          // unload partial order
int TakeProfit=0;               // pips to take profit
int TakeProfit_Unload=0;        // pips to take profit for unload order
int StopLoss=0;                 // pips to stop loss
int TrailingStop=0;             // pips to trail stop (activated only after order is unloaded)
int TrailingStop_Unload=0;      // pips to trail stop (for the partial order which will be unloaded)

double Gamma=0.75;              // gamma for Laguerre
double LRSIhigh=0.80;           // upper limit for Laguerre RSI
double LRSIlow =0.20;           // lower limit for Laguerre RSI

int Slippage=0;                 // pips slippage allowed

int magic=727;                  // magic number for Laguerre orders 

int BlackOutPeriod=60;          // minutes to ignore future triggers after an order is opened
int OrderTime=0;                // time of most recent open order
int checktime=0;                // time remaining during which to ignore future triggers

bool flag_order=false;          // TRUE if NO orders are open
bool flag_dump=false;           // TRUE if order has NOT been unloaded yet

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
 
 flag_order=true;                    // first assume we have no open orders

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
  }
  
 }
 return(0);
}

//===========================================================================================
//===========================================================================================

void Main()
{
 MainEngine();
 TakeProfitUnload();
 TrailStop();
 return(0);
}

//===========================================================================================
//===========================================================================================
void MainEngine()
{
 checktime   = (BlackOutPeriod*60)-(CurTime()-OrderTime);
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

  double timediff=(CurTime()-OrderCloseTime())/3600;  // time difference in hours
  
  if(timediff >= 1) // only interested in closed trades in this hour
   continue;

  switch(OrderMagicNumber())
  {
   case 727: 
    OrderTime=OrderOpenTime();
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
  }
 } 
 DisplayStatusInit();
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


//+----------------------------------------------------------------------+
//|                                                      2MACrossRSI.mq4 |
//|                                                         David J. Lin |
//|Based on a 2EMA crossover strategy introduced to me by Nathan Hodge   |
//| (bmwboyee at IBFX forum)                                             |  
//|                                                                      |
//|  - Trigger = RSI to confirm 2EMA crossover:                          |
//|              Long:  cross up   + RSI>50 cross                        |
//|              Short: cross down + RSI<50 cross                        |
//|  - Exits   = Long:  cross down + RSI<50 cross                        |
//|              Short: cross up   + RSI>50 cross                        |
//|  - Stoploss = low of last bar if long, high of last bar if short.    |
//|  - Timeframe = recommended: M5 or longer, but this EA can be applied |
//|     to any timeframe.                                                |
//|  - Pairs = Any                                                       |
//|  - Money Management = stoploss.  WARNING:  this EA does NOT take     |
//|     margin considerations into account, so beware of margin.         |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|d-lin@northwestern.edu                                                |
//|Evanston, IL, September 12, 2006                                      |
//|                                                                      |
//|TakeLong, TakeShort, and TrailingAlls coded by Patrick (IBFX tutorial)|
//+----------------------------------------------------------------------+
#property copyright "David J. Lin"
#property link      ""

extern int MAFastPeriod=5;
extern int MASlowPeriod=12;
extern int rsiPeriod=21;
extern double Lots=1.0;

extern int Slippage=3;
extern int StopLoss=40;
extern int TrailingStop=40;
extern int TakeProfit=0;

extern int MAFastShift=0;
extern int MAFastMethod=MODE_SMA;
extern int MAFastPrice=PRICE_CLOSE;

extern int MASlowShift=0;
extern int MASlowMethod=MODE_SMA;
extern int MASlowPrice=PRICE_CLOSE;

extern int rsiPrice=PRICE_CLOSE;

datetime lasttime=0;
bool flag_check=true;
int magic = 111;

int init()
{
 return(0);
}

int deinit()
{
 return(0);
}


//===========================================================================================
//===========================================================================================

int start()         // main cycle
{
 TrailingAlls(TrailingStop);   //Trailing Stop

 if(lasttime==Time[0]) //Time[0] is the time at close/open of a bar
  return(0);
 lasttime=Time[0]; 

 OrderStatus();     // Check order status
 if(flag_check)     
  CheckTrigger();   // Trigger order execution
 else
  MonitorOrders();  // Monitor open orders
}

//===========================================================================================
//===========================================================================================

void OrderStatus()          // Check order status
{
 int trade;                 // dummy variable to cycle through trades
 int trades=OrdersTotal();  // total number of pending/open orders
 flag_check=true;           // first assume we have no open/pending orders
 for(trade=0;trade<trades;trade++)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES); 
  if(OrderSymbol()==Symbol()&&OrderMagicNumber()==magic)
   flag_check=false;        // deselect flag_check if there are open/pending orders for this pair
 }
return(0);
}

//===========================================================================================
//===========================================================================================

int CheckTrigger()
{ 
//Calculate Indicators
// use information from bars 1 and 2, which are the most recently completely formed bars   
 double fast1=iMA(NULL,0,MAFastPeriod,MAFastShift,MAFastMethod,MAFastPrice,1); 
 double fast2=iMA(NULL,0,MAFastPeriod,MAFastShift,MAFastMethod,MAFastPrice,2);
 double slow1=iMA(NULL,0,MASlowPeriod,MASlowShift,MASlowMethod,MASlowPrice,1); 
 double slow2=iMA(NULL,0,MASlowPeriod,MASlowShift,MASlowMethod,MASlowPrice,2);
 double rsi1=iRSI(NULL,0,rsiPeriod,rsiPrice,1);
 double rsi2=iRSI(NULL,0,rsiPeriod,rsiPrice,2);
  
 if(fast1>slow1&&fast2<slow2&&rsi1>50.0&&rsi2<50.0)
  OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,StopLong(Ask,StopLoss),TakeLong(Ask,TakeProfit),NULL,magic,0,Blue);

 if(fast1<slow1&&fast2>slow2&&rsi1<50.0&&rsi2>50.0)
  OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,StopShort(Bid,StopLoss),TakeShort(Bid,TakeProfit),NULL,magic,0,Red);

 return(0);
}

//===========================================================================================
//===========================================================================================

void MonitorOrders()
{  
//Calculate Indicators
// use information from bars 1 and 2, which are the most recently completely formed bars   
 double fast1=iMA(NULL,0,MAFastPeriod,MAFastShift,MAFastMethod,MAFastPrice,1); 
 double fast2=iMA(NULL,0,MAFastPeriod,MAFastShift,MAFastMethod,MAFastPrice,2);
 double slow1=iMA(NULL,0,MASlowPeriod,MASlowShift,MASlowMethod,MASlowPrice,1); 
 double slow2=iMA(NULL,0,MASlowPeriod,MASlowShift,MASlowMethod,MASlowPrice,2);
 double rsi1=iRSI(NULL,0,rsiPeriod,rsiPrice,1);
 double rsi2=iRSI(NULL,0,rsiPeriod,rsiPrice,2);
 
 int trade;
 int trades=OrdersTotal();
 for(trade=0;trade<trades;trade++)
 {    
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()==Symbol()&&OrderMagicNumber()==magic)
  {
   if(fast1<slow1&&fast2>slow2&&OrderType()==OP_BUY&&rsi1<50.0&&rsi2>50.0)
    OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Blue); 
   
   if(fast1>slow1&&fast2<slow2&&OrderType()==OP_SELL&&rsi1>50.0&&rsi2<50.0)
    OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Red); 
  }
    
 }
return(0);
}

//===========================================================================================
//===========================================================================================

double StopLong(double price,int stop)
{
 if(stop==0)
  return(0.0); // if no stop loss
 return(price-(stop*Point)); 
             // minus, since the stop loss is below us for long positions
             // Point is 0.01 or 0.0001 depending on currency, so stop*POINT is a way to convert pips into price with multiplication 
}

double StopShort(double price,int stop)
{
 if(stop==0)
  return(0.0); // if no stop loss
 return(price+(stop*Point)); 
             // plus, since the stop loss is above us for short positions
}

double TakeLong(double price,int take)
{
 if(take==0)
  return(0.0); // if no take profit
 return(price+(take*Point)); 
             // plus, since the take profit is above us for long positions
}

double TakeShort(double price,int take)
{
 if(take==0)
  return(0.0); // if no take profit
 return(price-(take*Point)); 
             // minus, since the take profit is below us for short positions
}

void TrailingAlls(int trail)
{
 if(trail==0)
  return;
  
 double stopcrnt;
 double stopcal;
  
 int trade;
 int trades=OrdersTotal();
 for(trade=0;trade<trades;trade++)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()==Symbol()&&OrderMagicNumber()==magic)
  {
//Long 
   if(OrderType()==OP_BUY)
   {
    stopcrnt=OrderStopLoss();
    stopcal=Bid-(trail*Point); 
    if(stopcrnt==0)
     OrderModify(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Blue);
    else if(stopcal>stopcrnt)
     OrderModify(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Blue);
    }
   
//Short 
   if(OrderType()==OP_SELL)
   {
    stopcrnt=OrderStopLoss();
    stopcal=Ask+(trail*Point); 
    if(stopcrnt==0)
     OrderModify(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red);
    else if(stopcal<stopcrnt)
     OrderModify(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red);
    }
   }
 } //for
}
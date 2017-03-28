//+----------------------------------------------------------------------+
//|                                                      DoubleStrike.mq4|
//|                                                         David J. Lin |
//|Matthew Nguyen's DoubleStrike EA                                      |
//|                                                                      |
//|Coded by:                                                             |
//|David J. Lin                                                          |
//|d-lin@northwestern.edu                                                |
//|Evanston, IL, September 15, 2006                                      |
//|                                                                      |
//+----------------------------------------------------------------------+
#property copyright "David J. Lin"
#property link      ""

extern bool LowerStrike=true;
extern bool UpperStrike=true;
extern int HourStart=21;
extern int HourStop=11;
extern int TakeProfitLow=15;
extern int TakeProfitHigh=15;
extern int Top=10;
extern int Safety=5;
extern int StopLoss=0;
extern int Slippage=3;

int magic = 22;
double LowestPrice=0.0;
double HighestPrice=0.0;
bool flag_submit=true;
bool flag_price=true;
bool flag_close=true;
bool flag_day=true;
bool flag_preserve;
int today=99;

int init()
{
 magic = magic+Period();
 CheckPrices();
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
 OrderStatus();     // Check order status
 if(flag_submit&&flag_day&&DayOfWeek()!=0&&DayOfWeek()!=5&&TimeHour(Time[0])==HourStart)     
  SubmitOrders();
 else
  MonitorOrders();
}

//===========================================================================================
//===========================================================================================

void OrderStatus()          // Check order status
{
 int trade;                 // dummy variable to cycle through trades
 int trades=OrdersTotal();  // total number of pending/open orders
 flag_submit=true;           // first assume we have no open/pending orders
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES); 
  if(OrderSymbol()==Symbol()&&OrderMagicNumber()==magic)
   flag_submit=false;        // deselect flag_check if there are open/pending orders for this pair
 }
return(0);
}

//===========================================================================================
//===========================================================================================

void SubmitOrders()
{
 double price;
 double lots= AccountBalance()/2000;

 if(TimeHour(Time[0])==HourStart&&flag_price)
 {
  CheckPrices();
  flag_price=false;
 } 
 
 if(LowerStrike)
 {
  price=LowestPrice;
  OrderSend(Symbol(),OP_BUYLIMIT,lots,price,Slippage,StopLong(price,StopLoss),TakeLong(price,TakeProfitLow),NULL,magic,0,Blue);
 }
 if(UpperStrike) 
 {
  price=HighestPrice;
  OrderSend(Symbol(),OP_BUYSTOP,lots,price,Slippage,StopLong(price,StopLoss),TakeLong(price,TakeProfitHigh),NULL,magic,0,Blue);  
 }
 
 flag_day=false;
 
 return(0);
}

//===========================================================================================
//===========================================================================================
void MonitorOrders()
{
 if(flag_preserve==true&&TimeHour(CurTime())==HourStop-1)
  {
   PreserveProfits();
   flag_preserve=false;
  } 

 if(today!=Day())
 {
  flag_day=true;
  flag_price=true;
  flag_close=true;
  flag_preserve=true;
 }
 today=Day();
 
 if(TimeHour(Time[0])==HourStop&&flag_close)
 {
  CloseLongs();
  CloseShorts();
  flag_close=false;
 }

}
//===========================================================================================
//===========================================================================================
void CheckPrices()
{
// Find the lowest & highest prices since 0:00
 LowestPrice = 999999.0;
 HighestPrice=-999999.0;
 int i=0;
 for(i=0;i<HourStart*2;i++)
 {
  if(iLow(NULL,PERIOD_M30,i)<LowestPrice)
   LowestPrice=iLow(NULL,PERIOD_M30,i);
  if(iHigh(NULL,PERIOD_M30,i)>HighestPrice)
   HighestPrice=iHigh(NULL,PERIOD_M30,i);
 }
 HighestPrice=HighestPrice+(Top*Point);
// Print(LowestPrice," ",HighestPrice);
} 
//===========================================================================================
//===========================================================================================
void PreserveProfits()
{
 double price;
 int trade;                 // dummy variable to cycle through trades
 int trades=OrdersTotal();  // total number of pending/open orders

 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES); 
  if(OrderSymbol()==Symbol()&&OrderMagicNumber()==magic)
  {
   if(OrderType()==OP_BUY)
   OrderModify(OrderTicket(),OrderOpenPrice(),StopLong(OrderOpenPrice(),StopLoss),TakeLong(OrderOpenPrice(),Safety),0,Blue);
   
   if(OrderType()==OP_SELL)
   OrderModify(OrderTicket(),OrderOpenPrice(),StopShort(OrderOpenPrice(),StopLoss),TakeShort(OrderOpenPrice(),Safety),0,Blue);
  }
 }//for  
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

double TakeLong(double price,int take)
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

void CloseLongs()
{
 int trade;
 int trades=OrdersTotal();
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()==Symbol()&&OrderMagicNumber()==magic)
  {
   if(OrderType()==OP_BUY)
    OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Blue); 
   
   if(OrderType()==OP_BUYSTOP||OrderType()==OP_BUYLIMIT)
     OrderDelete(OrderTicket());
  }   
 } //for
}

//===========================================================================================
//===========================================================================================

void CloseShorts()
{
 int trade;
 int trades=OrdersTotal();
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()==Symbol()&&OrderMagicNumber()==magic)
  {
   if(OrderType()==OP_SELL)
    OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Blue); 
   
   if(OrderType()==OP_SELLLIMIT)
     OrderDelete(OrderTicket());
  }   
 } //for
}

//===========================================================================================
//===========================================================================================


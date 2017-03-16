//+------------------------------------------------------------------+
//|                                                     2MAScalp.mq4 |
//|                                                     David J. Lin |
//|September 8, 2006 Fri                                             |
//+------------------------------------------------------------------+
#property copyright "David J. Lin"
#property link      ""

extern int Buffer=5;
extern double Lots=1.0;
extern int Slippage=3;
extern int StopLoss=15;
extern int TrailingStop=0;
extern int TakeProfit=5;
extern double Safety=2;     // pips minimum profit (once the trade is profitable by Safety+1)
extern int MAFastPeriod=3;
extern int MAFastShift=0;
extern int MAFastMethod=MODE_EMA;
extern int MAFastPrice=PRICE_CLOSE;

extern int MASlowPeriod=18;
extern int MASlowShift=0;
extern int MASlowMethod=MODE_EMA;
extern int MASlowPrice=PRICE_CLOSE;

extern int today1=0;
extern int today2=5;

bool flag_check=true;       // flag to check whether or not to place orders
bool flag_safety=true;      // flag to check safety (to take minimum profit once in green)

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

int start()
{
 OrderStatus(); 
 if(flag_check) 
  CheckTrigger();
 else // Monitor Open Orders  
  MonitorOrders();
}

//===========================================================================================
//===========================================================================================

void OrderStatus()
{
 int trade;                  // dummy variable to cycle through trades
 int trades=OrdersTotal();  // total number of pending/open orders
 flag_check=true; // first assume we have no open/pending orders
 for(trade=0;trade<trades;trade++)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES); 
  if(OrderSymbol()==Symbol())
   flag_check=false; // deselect flag_check if there are open/pending orders for this pair
 }
return(0);
}

//===========================================================================================
//===========================================================================================

void CheckTrigger()
{ 
   
//Calculate Indicators
 double fast1=iMA(NULL,0,MAFastPeriod,MAFastShift,MAFastMethod,MAFastPrice,1); 
 double fast2=iMA(NULL,0,MAFastPeriod,MAFastShift,MAFastMethod,MAFastPrice,2);
 // use information from bars 1 and 2, which are the most recently completely formed bars   
 double slow1=iMA(NULL,0,MASlowPeriod,MASlowShift,MASlowMethod,MASlowPrice,1); 
 double slow2=iMA(NULL,0,MASlowPeriod,MASlowShift,MASlowMethod,MASlowPrice,2);
  
//Don't enter trades certain days:
   if(DayOfWeek()!=today1 && DayOfWeek()!=today2)
   {
//
//Enter Long 
//

    double MACross = 0.5*(fast1+fast2);

    if(fast1>slow1 && fast2<slow2 && Ask>=(MACross+(Buffer*Point)))
    { 
//     OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,StopLong(Ask,StopLoss),TakeLong(Ask,TakeProfit),NULL,0,0,Blue);
     OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,0.0,TakeLong(Ask,TakeProfit),NULL,0,0,Blue);
     flag_safety=true;
    } //Long
//
//Enter Short 
//
    if(fast1<slow1 && fast2>slow2 && Bid<=(MACross-(Buffer*Point)))
    {
//     OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,StopShort(Bid,StopLoss),TakeShort(Bid,TakeProfit),NULL,0,0,Red);
     OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,0.0,TakeShort(Bid,TakeProfit),NULL,0,0,Red);
     flag_safety=true;
    }//Shrt
   }//day
return(0);
}

//===========================================================================================
//===========================================================================================

void MonitorOrders()
{
 int trade;                  // dummy variable to cycle through trades
 int trades=OrdersTotal();  // total number of pending/open orders
 int TradeTime;              // number of seconds remaining before cancel order
 double price;               // dummy variable to calculate order prices
 double OrderPrice;          // price of order
 
 for(trade=0;trade<trades;trade++)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES); 
  if(OrderSymbol()!=Symbol())
  continue;
   
  if(OrderType()==OP_BUY)
  {
   Comment("BUY!");
   
   OrderPrice = OrderOpenPrice();
   price=(Bid-OrderPrice);
   
   if(price<=(-StopLoss*Point))  // manual stop loss
   {
    OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Blue); // close out order to ensure Safety pips profit
    Comment("Manual Stop-Loss hit!!");
   }
   
   if(flag_safety)
   {
    if((Bid-OrderPrice)>((Safety+1)*Point))
     flag_safety=false; // trip flag once profitable by Safety+1 pips
   } 
   else
   {
    if(price<(Safety*Point) || price>=(TakeProfit*Point))
    {
     OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Blue); // close out order to ensure Safety pips profit
    } 
     Comment("BUY-Safety.");
   }
  }  

  if(OrderType()==OP_SELL)
  {
   Comment("SELL!");
   price=(OrderPrice-Ask);   
   if(price<=(-StopLoss*Point))  // manual stop loss 
   {
    OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Red);  // close out order to satisfy stop/loss 
    Comment("Manual Stop-Loss hit!!"); 
   }
   if(flag_safety)
   {
    if((OrderPrice-Ask)>((Safety+1)*Point))
    flag_safety=false; // trip flag once profitable 
   }
   else
   {
    if(price<(Safety*Point)|| price>=(TakeProfit*Point))
    {
     OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Red);  // close out order to ensure Safety pips profit
    }
    Comment("SELL-Safety!");
   }       
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


//===========================================================================================
//===========================================================================================


//+----------------------------------------------------------------------+
//|                                                      RangeTrader.mq4 |
//|                                                         David J. Lin |
//|A Range Trading Utility                                               |
//|                                                                      |
//|This EA assists in placing limit orders, for example, in a range-     |
//| trading situation.                                                   |
//|                                                                      |
//| Cycle     = toggle to activate perpetual range-trading cycle         |
//| PriceBuy  = lower price at which to buy                              |
//| PriceSell = higher price at which to sell                            |
//| LotsBuy   = lots to buy at lower price                               |
//| LotsSell  = lots to sell at higher price                             |
//| TakeProfitBuy  = t/p for the buy order                               |
//| TakeProfitSell = t/p for the sell order                              |
//| StopLossBuy    = s/l for the buy order                               |
//| StopLossSell   = s/l for the sell order                              |
//| TrailingStop   = t/s for both orders                                 |
//| Slippage       = slippage allowed                                    |
//|                                                                      |
//| If Cycle is TRUE, the EA will open new limit orders perpetually,     |
//|  once the executed order of that type has been closed.               |
//|                                                                      |
//| If TakeProfitBuy or TakeProfitSell are set to zero, then the take-   |
//|  profit is set to be the opposite price.  (For example, PriceSell    |
//|  becomes the t/p of the buy limit, and vice versa.)                  |
//|                                                                      |
//| Interestingly, for EURUSD during 1/2006-9/2006, this method set      |
//|  perpetually into motion with PriceBuy=1.2675 and PriceSet=1.2700    |
//|  using 1 standard lot (no s/l, t/p, t/s) nets nearly $7000 without   |
//|  any losses in backtesting.  This is a good example where an         |
//|  apparently profitable method on paper may not be a viable trading   |
//|  method in practice.                                                 |
//|                                                                      |
//| This EA can distinguish the orders which it places from other        |
//|  orders (submitted by other EAs or manually), so you may place       |
//|  other orders while the EA is running.  However, it is not programmed|
//|  to properly take into account the possibility of simultaneous order |
//|  requests (for example, if multiple EAs are running and trigger      |
//|  orders at the same instant), and in such an eventuality, it is      |
//|  possible that some orders may not be executed due to a              |
//|  trading-thread conflict.                                            |
//|                                                                      |
//| The user of this EA agrees not to hold the author liable for any     |
//|  trading losses incurred while using it.                             |
//|                                                                      |
//| Please notify author about any bugs and/or suggestions for           |
//|  improvements.                                                       |                                         
//|                                                                      |
//|Coded by:                                                             |
//|David J. Lin                                                          |
//|d-lin@northwestern.edu                                                |
//|Evanston, IL, September 15-26, 2006                                   |
//|                                                                      |
//+----------------------------------------------------------------------+
#property copyright "David J. Lin"
#property link      ""

extern bool Cycle=false;
extern double PriceBuy=0.0;
extern double PriceSell=0.0;
extern double LotsBuy=1.0;
extern double LotsSell=1.0;
extern int TakeProfitBuy=0;
extern int TakeProfitSell=0;
extern int StopLossBuy=0;
extern int StopLossSell=0;
extern int TrailingStop=0;
extern int Slippage=3;

int magicBuy = 11;
int magicSell = 22;
bool BuyOpen=false;
bool SellOpen=false;
bool quit=false;
bool init=true;

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
 CheckError();
 if(quit) return(-1); 
 if(init) SubmitOrders();
 if(!Cycle) init=false; 
  else init=true;
 TrailingAlls(TrailingStop);  
}

//===================================================================================
//===========================================================================================

void SubmitOrders()
{
 CheckOpen();
 if(!BuyOpen)
  OrderSend(Symbol(),OP_BUYLIMIT,LotsBuy,PriceBuy,Slippage,StopLong(PriceBuy,StopLossBuy),TakeLong(PriceBuy,TakeProfitBuy),"Range Buy",magicBuy,0,Blue);
 if(!SellOpen)
  OrderSend(Symbol(),OP_SELLLIMIT,LotsSell,PriceSell,Slippage,StopShort(PriceSell,StopLossSell),TakeShort(PriceSell,TakeProfitSell),"Range Sell",magicSell,0,Red);
 return(0);
}

//===========================================================================================
//===========================================================================================

void CheckError()
{
 if(PriceBuy>=PriceSell)
 {
  Alert("Warning!! PriceBuy is greater than or equal to PriceSell!! Please re-enter!!");
  quit=true;
  return(-1);
 }   
}

//===========================================================================================
//===========================================================================================

void CheckOpen()
{
 BuyOpen=false;
 SellOpen=false;
 int trade;
 int trades=OrdersTotal();
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()==Symbol()&&OrderMagicNumber()==magicBuy&&(OrderType()==OP_BUYLIMIT||OrderType()==OP_BUY))
   BuyOpen=true;
  if(OrderSymbol()==Symbol()&&OrderMagicNumber()==magicSell&&(OrderType()==OP_SELLLIMIT||OrderType()==OP_SELL))
   SellOpen=true;
 }
 return(0);
}

//===========================================================================================
//===========================================================================================

double StopLong(double price,int stop) // function to calculate stoploss if long (by Patrick)
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

double TakeLong(double price,int take)  // function to calculate takeprofit if long (by Patrick, modified by David)
{
 if(take==0)
  return(PriceSell); // if no take profit specified, make take profit at PriceSell
 return(price+(take*Point)); 
             // plus, since the take profit is above us for long positions
}

//===========================================================================================
//===========================================================================================

double TakeShort(double price,int take)  // function to calculate takeprofit if short (by Patrick, modified by David)
{
 if(take==0)
  return(PriceBuy); // if no take profit, make take profit at PriceBuy
 return(price-(take*Point)); 
             // minus, since the take profit is below us for short positions
}

//===========================================================================================
//===========================================================================================

void TrailingAlls(int trail)  // trailing stop (by Patrick)
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
  
  if(OrderSymbol()==Symbol())
  {
//Long 
   if(OrderType()==OP_BUY&&OrderMagicNumber()==magicBuy)
   {
    stopcrnt=OrderStopLoss();
    stopcal=Bid-(trail*Point); 
    if(stopcrnt==0)
     OrderModify(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Blue);
    else if(stopcal>stopcrnt)
     OrderModify(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Blue);
    }
   
//Short 
   if(OrderType()==OP_SELL&&OrderMagicNumber()==magicSell)
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
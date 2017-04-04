//===========================================================================================
//===========================================================================================
// StraddleOrderOCO.mq4 
// David J. Lin (dave.j.lin@sbcglobal.net)
// Evanston, IL, December 5, 2006 
//
// This "initiator" EA applies a straddle buy-sell stops upon application.
// Upon market entry of one order, the other is canceled (OCO).
// The EA no longer functions after the other order is canceled.
//
// Buy1        = pips above current Ask at which to enter long 
// Sell1       = pips below current Bid at which to enter short 
// Lots1       = number of lots to order (fractional values ok) 
// StopLoss1   = pips stop-loss
// TakeProfit1 = pips take-profit
// Slippage    = pips slippage
//===========================================================================================
//===========================================================================================
#property copyright "David J. Lin, 2006"

extern int Buy1 = 15;
extern int Sell1 = 15;
extern double Lots1=10.0;
extern int StopLoss1=0;
extern int TakeProfit1=25;

extern int Slippage=0;

bool check=true;

int longTicketN;
int shortTicketN;

//===========================================================================================
//===========================================================================================

int init()
{
 SubmitOrders();
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
 if(check)
  CheckOrders(); 
 return(-1);
}

//===========================================================================================
//===========================================================================================
void SubmitOrders()
{
//Immediately straddle the trade:
 double entry = Ask+(Buy1*Point);
 OrderSend(Symbol(),OP_BUYSTOP,Lots1,entry,Slippage,StopLong(entry,StopLoss1),TakeLong(entry,TakeProfit1),NULL,1,0,Blue);
        entry = Bid-(Sell1*Point);
 OrderSend(Symbol(),OP_SELLSTOP,Lots1,entry,Slippage,StopShort(entry,StopLoss1),TakeShort(entry,TakeProfit1),NULL,2,0,Red); 

 int trade; 
 int trades=OrdersTotal(); 

 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()!=Symbol())
   continue;
   
  if(OrderType()==OP_BUYSTOP&&OrderMagicNumber()==1)
   longTicketN=OrderTicket();
  else if(OrderType()==OP_SELLSTOP&&OrderMagicNumber()==2)
   shortTicketN=OrderTicket();
   
 }
 
 return;
} 
//===========================================================================================
//===========================================================================================
void CheckOrders()
{
 int trade; 
 int trades=OrdersTotal(); 

 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;

  if(OrderType()==OP_BUY&&OrderMagicNumber()==1)
  {
   OrderDelete(shortTicketN);
   check=false;
   return;
  }
  else if(OrderType()==OP_SELL&&OrderMagicNumber()==2)
  {
   OrderDelete(longTicketN);
   check=false;
   return;
  }
 }  
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


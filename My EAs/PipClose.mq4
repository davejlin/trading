//+------------------------------------------------------------------+
//|                                                     PipClose.mq4 |
//|                                                     David J. Lin |
//|December 13, 2006                                                 |
//|d-lin@northwestern.edu                                            |
//|                                                                  |
//|Closes two orders with ticket numbers Ticket1 and Ticket2         |
//|after the sum of their profits exceeds PipGoal pips.              | 
//|Permits monitoring of orders possibly with different pairs.       |                                                              |
//+------------------------------------------------------------------+
#property copyright "David J. Lin"
#property link      ""

//===========================================================================================
//===========================================================================================

extern int Ticket1=0;   // Ticket number of Order 1
extern int Ticket2=0;   // Ticket number of Order 2
extern int PipGoal=100; // pip goal of combined profit
extern int slippage=3;  // pip slippage allowed

bool check=true;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   CheckStatus();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
   if(check)
    CheckStatus();
//----
   return(0);
  }
//+------------------------------------------------------------------+

//===========================================================================================
//===========================================================================================
void CheckStatus()
{
 double PD1=Profit(Ticket1);
 double PD2=Profit(Ticket2);
 double PD=PD1+PD2;
// Print("Current combined pip profit: ", PD);
 if(PD>=PipGoal)
  CloseAllOrders();
}

double Profit(int ticket)
{
 OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES);
 if(OrderType()==OP_BUY)  
  return((MarketInfo(OrderSymbol(),MODE_BID)-OrderOpenPrice())/MarketInfo(OrderSymbol(),MODE_POINT));
 else if(OrderType()==OP_SELL)
  return((OrderOpenPrice()-MarketInfo(OrderSymbol(),MODE_ASK))/MarketInfo(OrderSymbol(),MODE_POINT));
} 

void CloseAllOrders()
{  
 CloseOrder(Ticket1);
 CloseOrder(Ticket2);
 Print("PipClose has closed orders ", Ticket1, " and ", Ticket2);
 check=false;
 Print("PipClose is now inactive.");  
 return;
}

void CloseOrder(int ticket)
{
 bool status;
 OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES);
 for(int i=1;i<=10;i++)
 {
  if (OrderType()==OP_BUY)
   status=OrderClose(ticket,OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),slippage);
  else if(OrderType()==OP_SELL)
   status=OrderClose(ticket,OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),slippage); 
  
  if(!status)
  {
   int err = GetLastError();
   Print("OrderClose failed, Error: ", err, " Ticket #: ", ticket);
   Print("Bid ",MarketInfo(OrderSymbol(),MODE_BID)," Ask ", MarketInfo(OrderSymbol(),MODE_ASK) );   
   if(err>4000) 
    break;
   RefreshRates();
  }  
  else
   break;
 }
 return; 
}
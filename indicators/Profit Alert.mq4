//+----------------------------------------------------------------------+
//|                                                     Profit Alert.mq4 |
//|                                                         David J. Lin |
//|Written for Paul Dean (pdean123@embarqmail.com)                       |
//|                                                                      |
//|Coded by David J. Lin (dave.j.lin@sbcglobal.net)                      |
//|Evanston, IL, September 13, 2007                                      |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2007, Paul Dean & David J. Lin"
#property link      ""
#property indicator_chart_window

// User adjustable parameters:
extern int TargetPipProfit=10;                 // pip profit after which to send email alert
extern string TextHeader="MT4 Profit Alert!!"; // header of email message 
// variables
datetime AlertTime;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//----
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
 MonitorOrders();
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert utility functions                                         |
//+------------------------------------------------------------------+

void MonitorOrders()
{
 int profit=0;
 int i,j,trail,trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);

  profit+=DetermineProfit();
 }
  
 int checktime=iBarShift(NULL,0,AlertTime,false); 
 if(checktime<1) return;

 string message; 
 if(TargetPipProfit>=0)
 {
  if(profit>=TargetPipProfit) 
  {
   message=StringConcatenate("Account has reached ",profit," pips of profit!");
   SendMessage(message);
   Alert(message);
   AlertTime=TimeCurrent();
  } 
 }
 else
 {
  if(profit<=TargetPipProfit) 
  {
   message=StringConcatenate("Account has reached ",profit," pips of profit!");
   SendMessage(message);
   Alert(message);
   AlertTime=TimeCurrent();
  } 
 }
  
 return;
}
//+------------------------------------------------------------------+
int DetermineProfit()
{
 double price=OrderOpenPrice();
 string sym=OrderSymbol();
 double profitpips,ask,bid;
 double point=MarketInfo(sym,MODE_POINT);
 
 if(OrderType()==OP_BUY)  
 {
  bid=MarketInfo(sym,MODE_BID);
  profitpips=NormDigits(sym,bid-price);
  return(profitpips/point);
 } 
 else if(OrderType()==OP_SELL)
 { 
  ask=MarketInfo(sym,MODE_ASK);
  profitpips=NormDigits(sym,price-ask);
  return(profitpips/point); 
 }
 return(0);
}
//+------------------------------------------------------------------+
double NormDigits(string sym, double price)
{
 double digits=MarketInfo(sym,MODE_DIGITS);
 return(NormalizeDouble(price,digits));
}
//+------------------------------------------------------------------+
void SendMessage(string message)
{
 SendMail(TextHeader,message);
 return;
}
//+------------------------------------------------------------------+


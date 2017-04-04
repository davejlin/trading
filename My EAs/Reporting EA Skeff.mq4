//+------------------------------------------------------------------+
//|                                    Reporting Indicator Skeff.mq4 |
//|              Copyright © 2012, Mike Skeffington and David J. Lin |
//|                                                                  |
//| written for Mike Skeffington (ttolman@prodigix.com)              |
//|                                                                  |
//| Coded by David J. Lin (dave.j.lin@gmail.com)                     |
//| Evanston, IL, February 7, 2012                                   |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Mike Skeffington and David J. Lin"
#property link      ""

extern datetime DateStart = D'01.01.2012 00:00';
extern datetime DateEnd = D'01.02.2012 00:00';
extern int OrderMagicN1 = 0;
extern color TitleColor=Red;    // color of text titles
extern color ValueColor=Yellow; // color of numerical values

int OrderMagicN2;
int top=90;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
 OrderMagicN2=OrderMagicN1*10;

 MakeLabel( "sumT", 70, top-75 );
 MakeLabel( "sumV", 10, top-75 ); 
 
 ObjectSetText( "sumT",  "Total Pips:", 10, "Arial", TitleColor ); 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
 ObjectDelete( "sumT" );
 ObjectDelete( "sumV" );   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
//----
   ScanClosedOrders();
//----
   return(0);
  }
//+------------------------------------------------------------------+
int MakeLabel( string str, int a, int b ) 
{
 ObjectCreate( str, OBJ_LABEL, 0, 0, 0 );
 ObjectSet( str, OBJPROP_CORNER, 1 );
 ObjectSet( str, OBJPROP_XDISTANCE, a );
 ObjectSet( str, OBJPROP_YDISTANCE, b );
 ObjectSet( str, OBJPROP_BACK, true );
 return(0);
}
//+------------------------------------------------------------------+
void ScanClosedOrders()
{
 double pipProfit=0,value;
 int trade,trades=OrdersHistoryTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 { 
  OrderSelect(trade,SELECT_BY_POS,MODE_HISTORY);
  
  if(OrderMagicN1!=0)
  {
   if(OrderMagicNumber()!=OrderMagicN1&&OrderMagicNumber()!=OrderMagicN2) continue;
  }
  
  if(OrderCloseTime()<DateStart || OrderCloseTime()>DateEnd) continue;
   
  if(OrderType()==OP_BUY)
  {
   value = (OrderClosePrice()-OrderOpenPrice())/MarketInfo(OrderSymbol(),MODE_POINT);
   if(MarketInfo(OrderSymbol(),MODE_DIGITS)==5||MarketInfo(OrderSymbol(),MODE_DIGITS)==3) value/=10;
   pipProfit+=value;    
  }
  else if(OrderType()==OP_SELL)
  {
   value = (OrderOpenPrice() - OrderClosePrice())/MarketInfo(OrderSymbol(),MODE_POINT);
   if(MarketInfo(OrderSymbol(),MODE_DIGITS)==5||MarketInfo(OrderSymbol(),MODE_DIGITS)==3) value/=10;
   pipProfit+=value;
  }
 }
 
 ObjectSetText( "sumV", DoubleToStr(pipProfit,1), 10, "Arial", ValueColor );
}
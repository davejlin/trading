//+----------------------------------------------------------------------+
//|                                              Paul Ekey Sample EA.mq4 |
//|                                                         David J. Lin |
//| Based on a trading strategy by Paul Ekey                             |
//| (pmekey@comcast.net)                                                 |
//|                                                                      |
//| Coded by David J. Lin (dave.j.lin@gmail.com)                         |
//| Evanston, IL, September 24, 2010                                     |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2010, David J. Lin"

// Internal usage parameters:
//---- input parameters
extern int TakeProfit=0;
extern int StopLoss=0;
extern double Lots=1.0;
//---- MA paramters
extern int MA_Period=21;
extern int MA_Shift=0;
extern int MA_Method=MODE_SMA;
extern int MA_Price=PRICE_CLOSE;
//---- MACD parameters
extern double MACD_EntryLong=0.0001;
extern double MACD_EntryShort=-0.0001;
extern double MACD_ExitLong=-0.0001;
extern double MACD_ExitShort=0.0001;
extern int MACD_Fast=12;
extern int MACD_Slow=26;
extern int MACD_Signal=9;
extern int MACD_Price=PRICE_CLOSE;
//---- buffers
bool orderlong,ordershort,triggered;
int Magic;
string comment="Paul Ekey Sample EA";
datetime ots,otl,lasttime;
double lotsmin,lotsmax;
double StopLossPoints,TakeProfitPoints;
int lotsprecision;
int Slippage=5;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//---- 

 lotsmin=MarketInfo(Symbol(),MODE_MINLOT); 
 lotsmax=MarketInfo(Symbol(),MODE_MAXLOT); 

 if(lotsmin==1)         lotsprecision=0;
 else if(lotsmin==0.50) lotsprecision=1; // for PFG ECN
 else if(lotsmin==0.10) lotsprecision=1;
 else if(lotsmin==0.01) lotsprecision=2;
 else                   lotsprecision=1; 

 if(StringFind(Symbol(),"JPY")>0) 
 {
  if(Digits==3)
  {
   StopLossPoints=NormPoints(StopLoss*10);
   TakeProfitPoints=NormPoints(TakeProfit*10);  
  }
  else
  {
   StopLossPoints=NormPoints(StopLoss);
   TakeProfitPoints=NormPoints(TakeProfit);  
  }  
 }
 else
 {
  if(Digits==5)
  {
   StopLossPoints=NormPoints(StopLoss*10);
   TakeProfitPoints=NormPoints(TakeProfit*10);  
  }
  else
  {
   StopLossPoints=NormPoints(StopLoss);
   TakeProfitPoints=NormPoints(TakeProfit);  
  }  
 } 

 
 string timename;
 switch(Period())
 {
  case 1: timename="M1";
  break;
  case 5: timename="M5";
  break;
  case 15: timename="M15";
  break;  
  case 30: timename="M30";
  break;  
  case 60: timename="H1";
  break;
  case 240: timename="H4";
  break;  
  case 1440: timename="D1";
  break;  
  case 10080: timename="W1";
  break;  
  default: timename="MN";
  break;  
 }
 
 lasttime=iTime(NULL,0,0);
 
 triggered=false;

 if(CheckNumberOrder()>0) triggered=true; 
 
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
//---- 
 ReleaseSemaphore();
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
//----   
 ManageOrders();
 Main();
  
 if(lasttime==iTime(NULL,0,0)) return(0);
 lasttime=iTime(NULL,0,0);

//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert utility functions                                         |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void Main()
{ 
 if(triggered) return;
 
 double SL,TP;
 int ticket;
 string td;

 double open=iOpen(NULL,0,0);

 if(Trigger(true)&&otl<lasttime)
 {
  SL=StopLong(Ask,StopLossPoints);
  TP=TakeLong(Ask,TakeProfitPoints);  

  ticket=SendOrderLong(Symbol(),Lots,Slippage,0,0,comment,Magic);     
  
  otl=TimeCurrent();
  td=TimeToStr(otl,TIME_DATE|TIME_MINUTES);
  AddSLTP(SL,TP,ticket);
  triggered=true;  
 } 
 
 if(Trigger(false)&&ots<lasttime)
 {
  SL=StopShort(Bid,StopLossPoints);
  TP=TakeShort(Bid,TakeProfitPoints);  

  ticket=SendOrderShort(Symbol(),Lots,Slippage,0,0,comment,Magic);   
  
  ots=TimeCurrent();
  td=TimeToStr(ots,TIME_DATE|TIME_MINUTES);
  AddSLTP(SL,TP,ticket);
  triggered=true;
 } 

 return; 
}
//+------------------------------------------------------------------+
bool Trigger(bool flag)
{
 double ma=iMA(NULL,0,MA_Period,MA_Shift,MA_Method,MA_Price,0);
 double macd=iMACD(NULL,0,MACD_Fast,MACD_Slow,MACD_Signal,MACD_Price,MODE_MAIN,0);
 if(flag)
 {
  if(Bid>=ma&&macd>=MACD_EntryLong) return(true);
  else return(false);
 }
 else
 {
  if(Bid<=ma&&macd<=MACD_EntryShort) return(true);
  else return(false); 
 }
 return(false);
}
//+------------------------------------------------------------------+
void ManageOrders()
{ 
 if(CheckNumberOrder()==0) triggered=false;

 int trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 { 
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  MACDExit(); 
 }
 return;
}
//+------------------------------------------------------------------+
bool ModifyOrder(int ticket, double price, double sl, double tp, datetime exp, color cl=CLR_NONE)
{ 
 GetSemaphore();

 if(OrderModify(ticket,price,sl,tp,exp,cl)==false)
 {  
  Print("OrderModify failed, Error: ",GetLastError(), " Ticket Number: ", ticket);
  Print("Old price: ", OrderOpenPrice(), " Old S/L ", OrderStopLoss(), " Old T/P ", OrderTakeProfit(), " Ask/Bid ",Ask,", ",Bid);
  Print(" New Price: ", price, " New S/L ", sl, " New T/P ", tp, " New Expiration ", exp);
 }
 ReleaseSemaphore();
}
//+------------------------------------------------------------------+
int SendOrderLong(string sym, double vol, int slip, double sl, double tp, string comment="", int magic=0, datetime exp=0, color cl=Blue)
{ 
 int ticket,err;
 GetSemaphore();
 for(int z=0;z<5;z++)
 {  
  ticket=OrderSend(sym,OP_BUY,NormLots(vol),Ask,slip,NormDigits(sl),NormDigits(tp),comment,magic,exp,cl);
  if(ticket<0)
  {  
   err = GetLastError();
   Print("OrderSend Long failed, Error: ", err, " Magic Number: ", magic);
   Print("Ask: ", Ask, " S/L ", sl, " T/P ", tp);
   if(err>4000) break;
   RefreshRates();
  }
  else
   break;
 }
 ReleaseSemaphore();
 return(ticket);
}
//+------------------------------------------------------------------+
int SendOrderShort(string sym, double vol, int slip, double sl, double tp, string comment="", int magic=0, datetime exp=0, color cl=Red)
{  
 int ticket,err;
 GetSemaphore();
 for(int z=0;z<5;z++)
 {  
  ticket=OrderSend(sym,OP_SELL,NormLots(vol),Bid,slip,NormDigits(sl),NormDigits(tp),comment,magic,exp,cl);
  if(ticket<0)
  {  
   err = GetLastError();
   Print("OrderSend Short failed, Error: ", err, " Magic Number: ", magic);
   Print("Bid: ", Bid, " S/L ", sl, " T/P ", tp);   
   if(err>4000) break;
   RefreshRates();
  }
  else
   break;
 }
 ReleaseSemaphore();
 return(ticket);
}
//+------------------------------------------------------------------+
bool CloseOrderLong(int ticket, double lots, int slip, color cl=CLR_NONE)
{
 GetSemaphore();
 for(int z=0;z<10;z++)
 {
  if(!OrderClose(ticket,NormLots(lots),Bid,slip,cl))
  {  
   int err = GetLastError();
   Print("OrderClose Long failed, Error: ", err, " Ticket #: ", ticket);
   Print("Bid: ", Bid);   
   if(err>4000) break;
   RefreshRates();
  }
  else break;
 }
 ReleaseSemaphore();
} 
//+------------------------------------------------------------------+
bool CloseOrderShort(int ticket, double lots, int slip, color cl=CLR_NONE)
{
 GetSemaphore();
 for(int z=0;z<10;z++)
 {
  if(!OrderClose(ticket,NormLots(lots),Ask,slip,cl))
  {  
   int err = GetLastError();
   Print("OrderClose Short failed, Error: ", err, " Ticket #: ", ticket);
   Print("Ask: ", Ask);   
   if(err>4000) break;
   RefreshRates();
  }
  else break;
 }
 ReleaseSemaphore();
} 
//+------------------------------------------------------------------+
bool GetSemaphore()
{  
 if(!GlobalVariableCheck("SEMAPHORE")) GlobalVariableSet("SEMAPHORE",0);
 while(!IsStopped())
 {  
  if(GlobalVariableSetOnCondition("SEMAPHORE",1,0)==true) break;
  Sleep(500);
 }
 return(true);
}
//+------------------------------------------------------------------+
bool ReleaseSemaphore()
{
 GlobalVariableSet("SEMAPHORE",0);
 return(true);
}
//+------------------------------------------------------------------+
double NormPoints(int pips)
{
 return(NormDigits(pips*Point));
}
//+------------------------------------------------------------------+
double NormDigits(double price)
{
 return(NormalizeDouble(price,Digits));
}
//+------------------------------------------------------------------+
double NormLots(double lots)
{
 if(lotsmin==0.50) // for PFG ECN
 {
  int lotmod=lots/lotsmin;
  lots=lotmod*lotsmin; // increments of 0.50 lots
 }

 return(MathMax(NormalizeDouble(lotsmin,lotsprecision),NormalizeDouble(lots,lotsprecision)));
}
//+------------------------------------------------------------------+
void ExitOrder(bool flag_Long,bool flag_Short)
{
 if(OrderType()==OP_BUY&&flag_Long)
  CloseOrderLong(OrderTicket(),OrderLots(),Slippage,Lime);
 else if(OrderType()==OP_SELL&&flag_Short)
  CloseOrderShort(OrderTicket(),OrderLots(),Slippage,Lime); 
 return;
}
//+------------------------------------------------------------------+ 
void ExitAllOrders(bool long)
{
 int trade,trades=OrdersTotal(); 
 if(long)
 {
  for(trade=trades-1;trade>=0;trade--)
  {
   OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
   if(OrderSymbol()!=Symbol()) continue;
   ExitOrder(true,false);
  }
 }
 else
 {
  for(trade=trades-1;trade>=0;trade--)
  {
   OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
   if(OrderSymbol()!=Symbol()) continue;
   ExitOrder(false,true);
  }
 } 
 
 triggered=false;

 return;
}
//+------------------------------------------------------------------+
double TakeLong(double price,double take)  // function to calculate takeprofit if long
{
 if(take==0) return(0);
 return(NormDigits(price+take)); 
             // plus, since the take profit is above us for long positions
}
//+------------------------------------------------------------------+
double TakeShort(double price,double take)  // function to calculate takeprofit if short
{
 if(take==0) return(0);
 return(NormDigits(price-take)); 
             // minus, since the take profit is below us for short positions
}
//+------------------------------------------------------------------+
double StopShort(double price,double stop) // function to calculate normal stoploss if short
{
 if(stop==0) return(0);
 return(NormDigits(price+stop)); 
             // plus, since the stop loss is above us for short positions
}
//+------------------------------------------------------------------+
double StopLong(double price,double stop) // function to calculate normal stoploss if long
{
 if(stop==0) return(0);
 return(NormDigits(price-stop)); 
             // minus, since the stop loss is below us for long positions
             // Point is 0.01 or 0.001 depending on currency, so stop*POINT is a way to convert pips into price with multiplication 
}
//+------------------------------------------------------------------+
void MACDExit()
{  
// if(lasttime==iTime(NULL,0,0)) return;
 double macd=iMACD(NULL,0,MACD_Fast,MACD_Slow,MACD_Signal,MACD_Price,MODE_MAIN,0);

 if(OrderType()==OP_BUY)       
 {
  if(macd<=MACD_ExitLong) ExitAllOrders(true);
 }
 else if(OrderType()==OP_SELL)       
 {   
  if(macd>=MACD_ExitShort) ExitAllOrders(false); 
 }
 return;
}
//+------------------------------------------------------------------+ 
void AddSLTP(double sl, double tp, int orderNumber)
{
 if(sl<=0&&tp<=0) return;
 if(OrderSelect(orderNumber,SELECT_BY_TICKET)) 
  ModifyOrder(orderNumber,OrderOpenPrice(),sl,tp,0,CLR_NONE);
 return;
}
//+------------------------------------------------------------------+
int CheckNumberOrder() // check number of orders in account regardless of origin
{
 int trade,trades=OrdersTotal(),total=0; 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  
  total++;
 }
 return(total);
}
//+------------------------------------------------------------------+


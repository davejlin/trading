//+----------------------------------------------------------------------+
//|                                                  BreakOut Trader.mq4 |
//|                                                         David J. Lin |
//| Double straddle at set time each day to catch breakouts              |
//|                                                                      |
//| Buy1,2        = pips above current Ask at which to enter long        |
//| Sell1,2       = pips below current Bid at which to enter short       |
//| Lots1,2       = number of lots to order (fractional values ok)       |
//| StopLoss1,2   = pips stop-loss                                       |
//| TakeProfit1,2 = pips take-profit                                     |
//| Slippage     = pips slippage                                         |
//|                                                                      |
//| Coded by David J. Lin                                                |
//| dave.j.lin@sbcglobal.net                                             |
//| Evanston, IL, June 29, 2008                                          |
//+----------------------------------------------------------------------+
#property copyright "David J. Lin, 2008"

extern int EntryHour=9;
extern int ExitHour=16;

extern int Set1 = 30;
extern int Set2 = 30;

extern double Lots1=1;
extern double Lots2=1;
extern int StopLoss1=25;
extern int StopLoss2=25;
extern int TakeProfit1=15;
extern int TakeProfit2=25;

extern int ProfitPoint1=10;
extern int ProfitPoint2=15;
extern int MoveStops=1;

extern int spread=2;

extern int Slippage=0;

bool check1=false;
bool check2=false;
bool orders=false;

int longTicketN1,longTicketN2;
int shortTicketN1,shortTicketN2;

bool cancel=true;
double lotsmin,lotsmax;
int lotsprecision=2;
int lastH1,lastD1;
int magic1=1,magic2=2,magic3=3,magic4=4;
//===========================================================================================
//===========================================================================================

int init()
{
 lotsmin=MarketInfo(Symbol(),MODE_MINLOT); 
 lotsmax=MarketInfo(Symbol(),MODE_MAXLOT);
 if(lotsmin==0.10) lotsprecision=1; 

 return(0);
}

int deinit()
{
 return(0);
}

void Params()
{
 return;
}

//===========================================================================================
//===========================================================================================
int start()
{
 Main();
 lastH1=iTime(NULL,PERIOD_H1,0);  
 lastD1=iTime(NULL,PERIOD_D1,0); 
 return(-1);
}
//===========================================================================================
//===========================================================================================
void Main()
{
 Params();
 SubmitOrders();
 ManageOrders(); 
 CancelOrders();
 ResetToggles();
 return;
}
//===========================================================================================
//===========================================================================================
void SubmitOrders()
{
 if(lastH1==iTime(NULL,PERIOD_H1,0)) return;
 if(DayOfWeek()==0) return; 
 if (!orders)
 {
// Trade at only certain times (before news releases)
// place the straddle 5 minutes before the hour:
  if(TimeHour(TimeCurrent())==EntryHour)
  {
   double entry,close=iClose(NULL,PERIOD_H1,1);  
//Immediately straddle the trade:
   if(Lots1>0)
   {
    entry = close+NormPoints(Set1+spread);
    SendPending(Symbol(),OP_BUYSTOP,Lots1,entry,Slippage,StopLong(entry,StopLoss1),TakeLong(entry,TakeProfit1),NULL,magic1,0,Blue);
    entry = close-NormPoints(Set1);
    SendPending(Symbol(),OP_SELLSTOP,Lots1,entry,Slippage,StopShort(entry,StopLoss1),TakeShort(entry,TakeProfit1),NULL,magic2,0,Red); 
   }
   if(Lots2>0)
   {
    entry = close+NormPoints(Set2+spread);
    SendPending(Symbol(),OP_BUYSTOP,Lots2,entry,Slippage,StopLong(entry,StopLoss2),TakeLong(entry,TakeProfit2),NULL,magic3,0,Blue);
    entry = close-NormPoints(Set2);
    SendPending(Symbol(),OP_SELLSTOP,Lots2,entry,Slippage,StopShort(entry,StopLoss2),TakeShort(entry,TakeProfit2),NULL,magic4,0,Red); 
   }

   int trade; 
   int trades=OrdersTotal(); 

   for(trade=trades-1;trade>=0;trade--)
   {
    OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
    if(OrderSymbol()!=Symbol()) continue;
   
    if(OrderType()==OP_BUYSTOP)
    {
          if(OrderMagicNumber()==magic1) longTicketN1=OrderTicket();
     else if(OrderMagicNumber()==magic3) longTicketN2=OrderTicket();
    }
    else if(OrderType()==OP_SELLSTOP)
    {
          if(OrderMagicNumber()==magic2) shortTicketN1=OrderTicket();
     else if(OrderMagicNumber()==magic4) shortTicketN2=OrderTicket();
    }
   }
   orders=true;
   check1=true;   
   check2=true;
  }
 }
 return;
} 
//===========================================================================================
//===========================================================================================
void ManageOrders()
{
 int trade; 
 int trades=OrdersTotal();
 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;

  if(check1) check1=CheckSet(magic1,magic2,shortTicketN1,longTicketN1);
  if(check2) check2=CheckSet(magic3,magic4,shortTicketN2,longTicketN2);

  if(OrderType()==OP_BUY || OrderType()==OP_SELL)
  {
        if(OrderMagicNumber()==magic1||OrderMagicNumber()==magic3) FixedStopsB(ProfitPoint1,MoveStops);
   else if(OrderMagicNumber()==magic2||OrderMagicNumber()==magic4) FixedStopsB(ProfitPoint2,MoveStops);
  }
 }
 return;
}
//===========================================================================================
//===========================================================================================
void CancelOrders()
{
 if(!cancel) return;
 if(lastH1==iTime(NULL,PERIOD_H1,0)) return;

 if(TimeHour(TimeCurrent())==ExitHour)
 {
  int trade; 
  int trades=OrdersTotal();
 
  for(trade=trades-1;trade>=0;trade--)
  {
   OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
   if(OrderSymbol()!=Symbol()) continue;

   if(OrderType()==OP_BUY)       ExitOrder(true,false);
   else if(OrderType()==OP_SELL) ExitOrder(false,true);
   else
   {
         if(OrderTicket()==longTicketN1)  DeleteOrder(longTicketN1);
    else if(OrderTicket()==shortTicketN1) DeleteOrder(shortTicketN1);
    else if(OrderTicket()==longTicketN2)  DeleteOrder(longTicketN2);
    else if(OrderTicket()==shortTicketN2) DeleteOrder(shortTicketN2);      
   }
  }
  cancel=false;
 }
 return;
}
//===========================================================================================
//===========================================================================================
void ResetToggles()
{
 if(lastD1==iTime(NULL,PERIOD_D1,0)) return;
 orders=false;
 cancel=true;
 return;
}
//===========================================================================================
//===========================================================================================
bool CheckSet(int m1, int m2, int tn1, int tn2) 
{
 if(OrderType()==OP_BUY&&OrderMagicNumber()==m1)
 {
  DeleteOrder(tn1);
  return(false);
 }
 else if(OrderType()==OP_SELL&&OrderMagicNumber()==m2)
 {
  DeleteOrder(tn2); 
  return(false);
 }
 return(true);
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
//+------------------------------------------------------------------+
void FixedStopsB(int PP,int PFS)
{
  if(PFS<=0) return;

  double stopcrnt,stopcal;
  double profit,profitpoint;

  stopcrnt=OrderStopLoss();
  profitpoint=NormPoints(PP);  

//Long               

  if(OrderType()==OP_BUY)
  {
   profit=Bid-OrderOpenPrice();
   
   if(profit>=profitpoint)
   {
    stopcal=TakeLong(OrderOpenPrice(),PFS);
    ModifyCompLong(stopcal,stopcrnt);   
   }
  }    
//Short 
  if(OrderType()==OP_SELL)
  {  
   profit=OrderOpenPrice()-Ask;
   
   if(profit>=profitpoint)
   {
    stopcal=TakeShort(OrderOpenPrice(),PFS);
    ModifyCompShort(stopcal,stopcrnt);
   }
  }  
 return(0);
} 
//+------------------------------------------------------------------+

void ModifyCompLong(double stopcal, double stopcrnt)
{
 stopcal=NormDigits(stopcal);
 stopcrnt=NormDigits(stopcrnt);

 if (stopcal==stopcrnt) return;
 
 if(stopcal>stopcrnt)
 {                     
  ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Blue); 
 }
 return;
}
//+------------------------------------------------------------------+

void ModifyCompShort(double stopcal, double stopcrnt)
{
 stopcal=NormDigits(stopcal);
 stopcrnt=NormDigits(stopcrnt);

 if (stopcal==stopcrnt) return;
  
 if(stopcrnt==0)
 { 
  ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red);     
 }
 else if(stopcal<stopcrnt&&stopcal!=0)
 {
  ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red); 
 }
 return;
}
//+------------------------------------------------------------------+

bool ModifyOrder(int ticket, double price, double sl, double tp, datetime exp, color cl=CLR_NONE)
{ 
 price=NormDigits(price);
 sl=NormDigits(sl);
 tp=NormDigits(tp);
 bool attempt=true;
 while(attempt)
 {
  if(IsTradeAllowed())
  {
   if(OrderModify(ticket,price,sl,tp,exp,cl)==false)
   {  
    Print("OrderModify failed, Error: ",GetLastError(), " Ticket Number: ", ticket);
    Print("Old price: ", OrderOpenPrice(), " Old S/L ", OrderStopLoss(), " Old T/P ", OrderTakeProfit(), " Ask/Bid ",Ask,", ",Bid);
    Print(" New Price: ", price, " New S/L ", sl, " New T/P ", tp, " New Expiration ", exp);
   }
   attempt=false;
  }
 }
 return(true);
}
//===========================================================================================
//===========================================================================================
int SendPending(string sym, int type, double vol, double price, int slip, double sl, double tp, string comment="", int magic=0, datetime exp=0, color cl=CLR_NONE)
{
 if(vol<=0) return(0);
 price=NormDigits(price);
 sl=NormDigits(sl);
 tp=NormDigits(tp);
 
 int ticket, err; 
 
 bool attempt=true;
 while(attempt)
 { 
  if(IsTradeAllowed())
  { 
   for(int z=0;z<5;z++)
   {    
    ticket=OrderSend(sym,type,NormLots(vol),NormDigits(price),slip,NormDigits(sl),NormDigits(tp),comment,magic,exp,cl);
    if(ticket<0)
    {  
     err = GetLastError();
     Print("OrderSend Pending failed, Error: ", err, " Magic Number: ", magic, " Type: ", type);
     Print("Price: ", price, " S/L ", sl, " T/P ", tp);
     Print("Bid: ", Bid, " Ask: ", Ask);
     if(err>4000)
     { 
      attempt=false;
      break;
     }
     RefreshRates();
    }
    else
    {
     attempt=false;
     break;
    }
   }
  }
 }
 return(ticket);
}
//===========================================================================================
//===========================================================================================
bool DeleteOrder(int ticket)
{ 
 bool attempt=true;
 while(attempt)
 {
  if(IsTradeAllowed())
  {
   if(OrderDelete(ticket)==false)
   {  
    Print("OrderDelete failed, Error: ",GetLastError(), " Ticket Number: ", ticket);
    Print("Price: ", OrderOpenPrice(), " S/L ", OrderStopLoss(), " T/P ", OrderTakeProfit(), " Ask/Bid ",Ask,", ",Bid);
    if(GetLastError()>4000) return(false);    
   }
   else return(true);
  }
 }
 return(true);
}
//+------------------------------------------------------------------+
bool CloseOrderLong(int ticket, double lots, int slip, color cl=CLR_NONE)
{ 
 bool attempt=true;
 while(attempt)
 {
  if(IsTradeAllowed())
  {
   for(int z=0;z<10;z++)
   {
    if(!OrderClose(ticket,NormLots(lots),Bid,slip,cl))
    {  
     int err = GetLastError();
     Print("OrderClose Long failed, Error: ", err, " Ticket #: ", ticket);
     Print("Bid: ", Bid);   
     if(err>4000)
     { 
      attempt=false;
      break;
     }     
     RefreshRates();
    }
    else
    {
     attempt=false;
     break;
    }
   }
  }
 }
 return(true);
} 
//+------------------------------------------------------------------+
bool CloseOrderShort(int ticket, double lots, int slip, color cl=CLR_NONE)
{
 bool attempt=true;
 while(attempt)
 {
  if(IsTradeAllowed())
  {
   for(int z=0;z<10;z++)
   {
    if(!OrderClose(ticket,NormLots(lots),Ask,slip,cl))
    {  
     int err = GetLastError();
     Print("OrderClose Short failed, Error: ", err, " Ticket #: ", ticket);
     Print("Ask: ", Ask);   
     if(err>4000)
     { 
      attempt=false;
      break;
     }     
     RefreshRates();
    }
    else
    {
     attempt=false;
     break;
    }
   }
  }
 }
 return(true);
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
//===========================================================================================
//===========================================================================================
double NormDigits(double price)
{
 return(NormalizeDouble(price,Digits));
}
double NormPoints(int pips)
{
 return(NormalizeDouble(pips*Point,Digits));
}
double NormLots(double lots)
{
 return(MathMax(NormalizeDouble(lotsmin,lotsprecision),NormalizeDouble(lots,lotsprecision)));
}
//===========================================================================================
//===========================================================================================


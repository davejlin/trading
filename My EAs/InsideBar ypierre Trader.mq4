//+----------------------------------------------------------------------+
//|                                         InsideBar ypierre Trader.mq4 |
//|                                                         David J. Lin |
//| Double straddle at inside bars                                       |
//|                                                                      |
//| Set1,2        = pips beyond high/low at which to enter pending stops |
//| Lots1,2       = number of lots to order (fractional values ok)       |
//| StopLoss1,2   = pips stop-loss                                       |
//| TakeProfit1,2 = pips take-profit                                     |
//| Slippage     = pips slippage                                         |
//|                                                                      |
//| Coded by David J. Lin                                                |
//| dave.j.lin@sbcglobal.net                                             |
//| Evanston, IL, July 2, 2008                                           |
//+----------------------------------------------------------------------+
#property copyright "David J. Lin, 2008"

extern int StartHour=4;        // server hour at which to begin trading (inclusive)
extern int EndHour=12;         // server hour at which to end trading (inclusive)
extern int ExitPendingHour=14; // server hour at which to exit unfilled pendings 

extern int Set1 = 0;
extern int Set2 = 0;

extern int Range=4; // pips difference between close and open to define signal 1 or 2

extern double Lots1=1; // enter zero or negative value if not desired
extern double Lots2=1; // enter zero or negative value if not desired
extern int TakeProfit1=80;
extern int TakeProfit2=80;
extern int StopLoss1=40;
extern int StopLoss2=40;
extern int Trail1=40; // Set1 desired Trail (use negative number to turn off)
extern int Trail2=40; // Set1 desired Trail (use negative number to turn off)

extern int ProfitPoint1=-1;  // pips profit after which to adjust stops to BE+MoveStops for Set1 (use negative number to turn off)
extern int ProfitPoint2=-1;  // pips profit after which to adjust stops to BE+MoveStops for Set2 (use negative number to turn off)
extern int MoveStops=1;

extern int Slippage=0;

bool check1=false;
bool check2=false;
bool order1=true;
bool order2=true;

int longTicketN1,longTicketN2;
int shortTicketN1,shortTicketN2;

double lotsmin,lotsmax;
int lotsprecision=2;
int lastH1,lastD1;
int magic1=5,magic2=6,magic3=7,magic4=8;
int ot1,ot2,pendexpire=3;
bool openorders1,openorders2;
//===========================================================================================
//===========================================================================================

int init()
{
 lotsmin=MarketInfo(Symbol(),MODE_MINLOT); 
 lotsmax=MarketInfo(Symbol(),MODE_MAXLOT);
 if(lotsmin==0.10) lotsprecision=1; 

// Now check open orders
                       
 int trade,trades=OrdersTotal();           
 for(trade=0;trade<trades;trade++)// The most recent closed order has the largest position number, so this works forward
                                  // to allow the values of the most recent closed orders to be the ones which are recorded

 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()!=Symbol()) continue;
  int magic=OrderMagicNumber();
  if(OrderType()==OP_BUY||OrderType()==OP_SELL) 
  {
   if(magic==magic1 || magic==magic2)
   { 
    order1=false;
    continue;
   }
   else if(magic==magic3 || magic==magic4)
   { 
    order2=false;
    continue;
   }   
  }
  
  Status(OrderMagicNumber());
 }
 
 return(0);
}

int deinit()
{
 return(0);
}

void Status(int magic)
{   
 switch(magic)
 {
  case 1: 
   longTicketN1=OrderTicket();
   check1=true; 
   order1=false;  
   ot1=OrderOpenTime();         
   break;
  case 2: 
   shortTicketN1=OrderTicket();
   check1=true;   
   order1=false;   
   ot1=OrderOpenTime();    
   break;  
  case 3: 
   longTicketN2=OrderTicket();
   check2=true;  
   order2=false;   
   ot2=OrderOpenTime();      
   break;
  case 4: 
   shortTicketN2=OrderTicket();
   check2=true;
   order2=false;  
   ot2=OrderOpenTime();     
   break;    
 }  
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
 SubmitOrders();
 ManageOrders(); 
 DeleteOrders();
 ResetToggles();
 return;
}
//===========================================================================================
//===========================================================================================
void SubmitOrders()
{
 if(lastH1==iTime(NULL,PERIOD_H1,0)) return;
 if(DayOfWeek()==0) return; 

 int hour=Hour();
 
 if(StartHour>=0&&EndHour>=0)
 {
  if(StartHour<EndHour)
  {
   if(hour<StartHour || hour>EndHour) return;
  }
  else
  {
   if(hour<StartHour && hour>EndHour) return;
  }
 }
 
 double spread, entry;
 double high1=iHigh(NULL,0,1);
 double high2=iHigh(NULL,0,2);
 double low1=iLow(NULL,0,1);
 double low2=iLow(NULL,0,2); 
 double close1=iClose(NULL,0,1);
 double open1=iOpen(NULL,0,1);

/* 
 if(order1)
 { 
  CancelOrders(1);
  spread=Ask-Bid;
//Immediately straddle the trade:
  if(Lots1>0)
  {
   entry = close+NormPoints(Set1)+spread;
   longTicketN1=SendPending(Symbol(),OP_BUYSTOP,Lots1,entry,Slippage,StopLong(entry,StopLoss1),TakeLong(entry,TakeProfit1),NULL,magic1,0,Blue);
   entry = close-NormPoints(Set1);
   shortTicketN1=SendPending(Symbol(),OP_SELLSTOP,Lots1,entry,Slippage,StopShort(entry,StopLoss1),TakeShort(entry,TakeProfit1),NULL,magic2,0,Red); 
  }
  ot1=TimeCurrent();
  check1=true;   
  order1=false;
 }
*/ 
 
 if(order2 && !openorders2)
 { 
  if(Bid<high2 && Bid>low2) // prevent gap entry attempts
  {
   if(high1<high2 && low1>low2 && MathAbs(close1-open1)<NormPoints(Range))
   {
    CancelOrders(2);
    spread=Ask-Bid;  
//Immediately straddle the trade:
    if(Lots2>0)
    {
     entry = NormDigits(high2+NormPoints(Set2)+spread);
     longTicketN2=SendPending(Symbol(),OP_BUYSTOP,Lots2,entry,Slippage,StopLong(entry,StopLoss2),TakeLong(entry,TakeProfit2),NULL,magic3,0,Blue);
     entry = NormDigits(low2-NormPoints(Set2));
     shortTicketN2=SendPending(Symbol(),OP_SELLSTOP,Lots2,entry,Slippage,StopShort(entry,StopLoss2),TakeShort(entry,TakeProfit2),NULL,magic4,0,Red); 
    }
    ot2=TimeCurrent();  
    check2=true;   
    order2=false;
   }
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
 openorders1=false;
 openorders2=false; 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;

  if(check1) check1=CheckSet(magic1,magic2,shortTicketN1,longTicketN1);
  if(check2) check2=CheckSet(magic3,magic4,shortTicketN2,longTicketN2);

  if(OrderType()==OP_BUY || OrderType()==OP_SELL)
  {
   double profit=NormDigits(DetermineProfit());
   if(OrderMagicNumber()==magic1||OrderMagicNumber()==magic2)  
   {
    if(ProfitPoint1>0) FixedStopsB(ProfitPoint1,MoveStops);
    if(Trail1>0) TrailStop(Trail1);
    openorders1=true; 
   }
   else if(OrderMagicNumber()==magic3||OrderMagicNumber()==magic4)
   {
    if(ProfitPoint2>0) FixedStopsB(ProfitPoint2,MoveStops);
    if(Trail2>0) TrailStop(Trail2);
    openorders2=true;    
   }   
  }

  if(lastH1!=iTime(NULL,PERIOD_H1,0))
  {
   if(OrderType()==OP_BUY || OrderType()==OP_SELL) continue;
  
   if(OrderMagicNumber()==magic1||OrderMagicNumber()==magic2)
    if(ExitPendingOrder(Period(),pendexpire)) check1=false;

   if(OrderMagicNumber()==magic3||OrderMagicNumber()==magic4)
    if(ExitPendingOrder(Period(),pendexpire)) check2=false;    
  } 
 }
 return;
}
//===========================================================================================
//===========================================================================================
void CancelOrders(int set=0)
{
 if(lastH1==iTime(NULL,PERIOD_H1,0)) return;

 int trade; 
 int trades=OrdersTotal();
 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
   
  if(OrderType()==OP_BUY || OrderType()==OP_SELL) continue;
  else
  {
   if(set==1)
   {
         if(OrderTicket()==longTicketN1)  DeleteOrder(longTicketN1);
    else if(OrderTicket()==shortTicketN1) DeleteOrder(shortTicketN1);
   }
   else if(set==2)
   {
         if(OrderTicket()==longTicketN2)  DeleteOrder(longTicketN2);
    else if(OrderTicket()==shortTicketN2) DeleteOrder(shortTicketN2);    
   }
  }
 }
 return;
}
//===========================================================================================
//===========================================================================================
void DeleteOrders()
{
 if(Hour()!=ExitPendingHour) return;
 if(!order1) CancelOrders(1);
 if(!order2) CancelOrders(2);
 return;
}
//===========================================================================================
//===========================================================================================
void ResetToggles()
{
 if(lastD1==iTime(NULL,PERIOD_D1,0)) return;
 if(!order1) order1=true;
 if(!order2) order2=true;
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

void TrailStop(int TS)
{
// if(DetermineProfit()<NormPoints(TS)) return; // only begin to trail after trail size is reached
 
 double stopcrnt,stopcal; 
 double profit;
 
 stopcrnt=OrderStopLoss();

// Normal Trailing Stop

//Long               
 if(OrderType()==OP_BUY)
 {
  stopcal=TrailLong(Bid,TS);
  ModifyCompLong(stopcal,stopcrnt);    
 }    
//Short 
 if(OrderType()==OP_SELL)
 {  
  stopcal=TrailShort(Ask,TS);
  ModifyCompShort(stopcal,stopcrnt);
 } 
 return(0);
}

double TrailLong(double price,int trail)
{
 return(price-NormPoints(trail)); 
}
double TrailShort(double price,int trail)
{
 return(price+NormPoints(trail)); 
}

//===========================================================================================
//===========================================================================================
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
bool ExitPendingOrder(int timeframe, int exp)
{
 if(OrderType()==OP_BUY||OrderType()==OP_SELL) return(false);
 
 int checktime=iBarShift(NULL,timeframe,OrderOpenTime(),false); 
 if(checktime<exp) return(false);
 
 DeleteOrder(OrderTicket());

 return(true);
}
//===========================================================================================
//===========================================================================================
double DetermineProfit()
{
 if(OrderType()==OP_BUY)  
 {
  return(Bid-OrderOpenPrice());
 } 
 else if(OrderType()==OP_SELL)
 { 
  return(OrderOpenPrice()-Ask); 
 }
 return(0);
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


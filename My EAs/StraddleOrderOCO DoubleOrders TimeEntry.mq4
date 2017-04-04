//===========================================================================================
//===========================================================================================
// StraddleOrderOCO DoubleOrders TimeEntry.mq4 
// David J. Lin (dave.j.lin@sbcglobal.net)
// Evanston, IL, June 27, 2008
//
// This "initiator" EA applies two sets of straddle buy-sell stops upon application.
// Upon market entry of one order, the other is canceled (OCO).
// The EA no longer functions after the other order is canceled.
//
// Buy1,2        = pips above current Ask at which to enter long 
// Sell1,2       = pips below current Bid at which to enter short 
// Lots1,2       = number of lots to order (fractional values ok) 
// StopLoss1,2   = pips stop-loss
// TakeProfit1,2 = pips take-profit
// Slippage     = pips slippage
//===========================================================================================
//===========================================================================================
#property copyright "David J. Lin, 2008"

extern int hour=8;
extern int minute=55;

extern int Buy1 = 30;
extern int Sell1 = 30;

extern int Buy2 = 50;
extern int Sell2 = 50;

extern double Lots1=0.1;
extern double Lots2= 0.1;
extern int StopLoss1=25;
extern int StopLoss2=25;
extern int TakeProfit1=15;
extern int TakeProfit2=15;

extern int Slippage=0;

bool check1=false;
bool check2=false;
bool orders=false;

int longTicketN1,longTicketN2;
int shortTicketN1,shortTicketN2;

double lotsmin,lotsmax;
int lotsprecision=2;
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

//===========================================================================================
//===========================================================================================

int start()
{
 SubmitOrders();
 CheckOrders(); 
 return(-1);
}

//===========================================================================================
//===========================================================================================
void SubmitOrders()
{
 if (!orders)
 {
// Trade at only certain times (before news releases)
// place the straddle 5 minutes before the hour:
  if(TimeHour(CurTime())==hour&&TimeMinute(CurTime())>=minute)
  {
   double entry;  
//Immediately straddle the trade:
   if(Lots1>0)
   {
    entry = Ask+(Buy1*Point);
    SendPending(Symbol(),OP_BUYSTOP,Lots1,entry,Slippage,StopLong(entry,StopLoss1),TakeLong(entry,TakeProfit1),NULL,1,0,Blue);
    entry = Bid-(Sell1*Point);
    SendPending(Symbol(),OP_SELLSTOP,Lots1,entry,Slippage,StopShort(entry,StopLoss1),TakeShort(entry,TakeProfit1),NULL,2,0,Red); 
   }
   if(Lots2>0)
   {
    entry = Ask+(Buy2*Point);
    SendPending(Symbol(),OP_BUYSTOP,Lots2,entry,Slippage,StopLong(entry,StopLoss2),TakeLong(entry,TakeProfit2),NULL,3,0,Blue);
    entry = Bid-(Sell2*Point);
    SendPending(Symbol(),OP_SELLSTOP,Lots2,entry,Slippage,StopShort(entry,StopLoss2),TakeShort(entry,TakeProfit2),NULL,4,0,Red); 
   }

   int trade; 
   int trades=OrdersTotal(); 

   for(trade=trades-1;trade>=0;trade--)
   {
    OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
    if(OrderSymbol()!=Symbol()) continue;
   
    if(OrderType()==OP_BUYSTOP)
    {
          if(OrderMagicNumber()==1) longTicketN1=OrderTicket();
     else if(OrderMagicNumber()==3) longTicketN2=OrderTicket();
    }
    else if(OrderType()==OP_SELLSTOP)
    {
          if(OrderMagicNumber()==2) shortTicketN1=OrderTicket();
     else if(OrderMagicNumber()==4) shortTicketN2=OrderTicket();
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
void CheckOrders()
{
 if(!check1&&!check2) return;
 int trade; 
 int trades=OrdersTotal();
 if(check1)
 {
  for(trade=trades-1;trade>=0;trade--)
  {
   OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
   if(OrderSymbol()!=Symbol()) continue;

   if(OrderType()==OP_BUY&&OrderMagicNumber()==1)
   {
    DeleteOrder(shortTicketN1);
    check1=false;
    break;
   }
   else if(OrderType()==OP_SELL&&OrderMagicNumber()==2)
   {
    DeleteOrder(longTicketN1);
    check1=false;
    break;
   }
  }
 }
 if(check2)
 {
  for(trade=trades-1;trade>=0;trade--)
  {
   OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
   if(OrderSymbol()!=Symbol()) continue;

   if(OrderType()==OP_BUY&&OrderMagicNumber()==3)
   {
    DeleteOrder(shortTicketN2);
    check2=false;
    break;
   }
   else if(OrderType()==OP_SELL&&OrderMagicNumber()==4)
   {
    DeleteOrder(longTicketN2);
    check2=false;
    break;
   }
  }
 } 
 return;
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
//===========================================================================================
//===========================================================================================
double NormDigits(double price)
{
 return(NormalizeDouble(price,Digits));
}
double NormLots(double lots)
{
 return(MathMax(NormalizeDouble(lotsmin,lotsprecision),NormalizeDouble(lots,lotsprecision)));
}
//===========================================================================================
//===========================================================================================


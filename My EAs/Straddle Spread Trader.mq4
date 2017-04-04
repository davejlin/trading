//+----------------------------------------------------------------------+
//|                                           Straddle Spread Trader.mq4 |
//|                                                         David J. Lin |
//|Based on a news scalping method                                       |
//|Written for Geneva Wheeless (gkw1018@yahoo.com)                       |
//|                                                                      |
//|Coded by David J. Lin (dave.j.lin@sbcglobal.net)                      |
//|Evanston, IL, August 7, 2007                                          |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2007, David J. Lin"
#property link      ""

// User adjustable parameters:
extern double Lots = 1;        // number of lots per order
extern int Straddle=10;        // pips for pending stop orders to straddle the market 
extern int Spread=25;          // pips spread beyond which to cancel pending stop orders (use negative number if no spread detection is desired)
extern int TakeProfit=100;     // pips desired TP (use negative number if no TP is desired)
extern int StopLoss=50;        // pips desired SL (use negative number if no SL is desired)
extern int TrailStop=50;       // pips desired trailing stop (use negative number if no trail is desired)
extern int SLProfit1=25;       // pips profit after which to move SL  (use negative number if not desired)
extern int SLMove1=1;          // pips to move SL to BE+SLMove after SLProfit is reached
extern int SLProfit2=50;       // pips profit after which to move SL  (use negative number if not desired)
extern int SLMove2=10;         // pips to move SL to BE+SLMove after SLProfit is reached
extern int SLProfit3=75;       // pips profit after which to move SL  (use negative number if not desired)
extern int SLMove3=25;         // pips to move SL to BE+SLMove after SLProfit is reached
extern int EndAdjustHour=18;   // GMT hour to stop adjusting straddle
extern int EndAdjustMinute=15; // GMT minute to stop adjusting straddle
extern bool Alarm=true;        // true=activate spread alarm, false=deactivate spread alarm

// Internal usage parameters:
int Slippage=3, Magic=51415553;
int lotsprecision=2;
double lotsmin,lotsmax,StraddlePoints,SpreadNow,SpreadPoints;
bool StraddleInPlay=false, OpenOrders=false, Run=true;
int TicketLong,TicketShort;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//----
 lotsmin=MarketInfo(Symbol(),MODE_MINLOT); 
 lotsmax=MarketInfo(Symbol(),MODE_MAXLOT);
 if(lotsmin==0.10) lotsprecision=1;
 
 StraddlePoints=NormPoints(Straddle);
 SpreadPoints=NormPoints(Spread);

 ManageOrders();
 if(!StraddleInPlay&&!OpenOrders) SubmitOrders(); 
 Run=true;
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
//---- 
 DeletePendings();
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
//----
 SpreadNow=NormDigits(Ask-Bid);
 Comment("Spread: "+DoubleToStr(SpreadNow/Point,0)); 
 if(Run) ManageOrders();
 if(Alarm) SpreadAlarm();
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert utility functions                                         |
//+------------------------------------------------------------------+

void SubmitOrders()
{
 double EntryPrice,SL,TP;

 EntryPrice = NormDigits(Ask+StraddlePoints);
 SL=StopLong(EntryPrice,StopLoss);
 TP=TakeLong(EntryPrice,TakeProfit);
 TicketLong=SendPending(Symbol(),OP_BUYSTOP,Lots,EntryPrice,Slippage,SL,TP,"Spread Straddle",Magic,0,Blue);

 EntryPrice = NormDigits(Bid-StraddlePoints);
 SL=StopShort(EntryPrice,StopLoss);
 TP=TakeShort(EntryPrice,TakeProfit); 
 TicketShort=SendPending(Symbol(),OP_SELLSTOP,Lots,EntryPrice,Slippage,SL,TP,"Spread Straddle",Magic,0,Red); 
 return;
}
//+------------------------------------------------------------------+
void AdjustOrders()
{
 if(SpreadPoints>0)
 {
  if(SpreadNow>=SpreadPoints) 
  {
   DeleteOrder(TicketLong);
   DeleteOrder(TicketShort);
   Run=false;
  }
 }

 if(Hour()>EndAdjustHour || (Hour()==EndAdjustHour && Minute()>=EndAdjustMinute) )
  return;

 if(!StraddleInPlay) return;

 double oldprice,newprice,SL,TP;

 OrderSelect(TicketLong,SELECT_BY_TICKET,MODE_TRADES);
 oldprice=OrderOpenPrice();
 newprice=NormDigits(Ask+StraddlePoints);
 if(newprice!=oldprice) 
 {
  SL=StopLong(newprice,StopLoss);
  TP=TakeLong(newprice,TakeProfit);
  ModifyOrder(TicketLong,newprice,SL,TP,0);
 }
 
 OrderSelect(TicketShort,SELECT_BY_TICKET,MODE_TRADES); 
 newprice=NormDigits(Bid-StraddlePoints);
 if(newprice!=oldprice) 
 {
  SL=StopShort(newprice,StopLoss);
  TP=TakeShort(newprice,TakeProfit);
  ModifyOrder(TicketShort,newprice,SL,TP,0);
 } 
 
 return;
}
//+------------------------------------------------------------------+
void SpreadAlarm()
{
 if(SpreadPoints>0)
 {
  if(SpreadNow>=SpreadPoints) Alert("Spread is "+SpreadNow+" pips!");
 }
 return;
}
//+------------------------------------------------------------------+
void ManageOrders()
{
 TicketLong=-1;TicketShort=-1;
 StraddleInPlay=true; OpenOrders=false;
 int i,j,trail,trade,trades=OrdersTotal(); 
 double profit;
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderMagicNumber()!=Magic) continue;
  
  if(OrderType()==OP_BUY)
  {
   StraddleInPlay=false; OpenOrders=true;
   profit=DetermineProfit();
   if(TrailStop>0) TrailingStop(TrailStop);   
   if(profit<=0) continue;
   if(SLProfit1>0) FixedStopsB(SLProfit1,SLMove1);
   if(SLProfit2>0) FixedStopsB(SLProfit2,SLMove2);
   if(SLProfit3>0) FixedStopsB(SLProfit3,SLMove3);  
  }
  else if(OrderType()==OP_SELL)
  {
   StraddleInPlay=false; OpenOrders=true;   
   profit=DetermineProfit();
   if(TrailStop>0) TrailingStop(TrailStop);    
   if(profit<=0) continue;    
   if(SLProfit1>0) FixedStopsB(SLProfit1,SLMove1);
   if(SLProfit2>0) FixedStopsB(SLProfit2,SLMove2);
   if(SLProfit3>0) FixedStopsB(SLProfit3,SLMove3);    
  }
  else if(OrderType()==OP_BUYSTOP)
  {
   TicketLong=OrderTicket();
  }
  else if(OrderType()==OP_SELLSTOP)
  {
   TicketShort=OrderTicket();
  }   
 } 
 
 
 if(StraddleInPlay)
 {
  if(TicketLong==-1 && TicketShort==-1) StraddleInPlay=false;
  else AdjustOrders();
 }
 else
 {
  if(TicketLong>0) DeleteOrder(TicketLong);
  else if(TicketShort>0) DeleteOrder(TicketShort);
 }

 return;
}
//+------------------------------------------------------------------+
void DeletePendings() // when exiting EA
{
 int i,trail,trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderMagicNumber()!=Magic) continue;
  
  if(OrderType()==OP_BUYSTOP||OrderType()==OP_SELLSTOP) DeleteOrder(OrderTicket()); 
  
 } 
 return;
}
//+------------------------------------------------------------------+

int SendPending(string sym, int type, double vol, double price, int slip, double sl, double tp, string comment="", int magic=0, datetime exp=0, color cl=CLR_NONE)
{
 int ticket, err;
 bool attempt=true;
 while(attempt)
 {
  if(IsTradeAllowed())
  {
   for(int z=0;z<20;z++)
   {  
    ticket=OrderSend(sym,type,NormLots(vol),NormalizeDouble(price,Digits),slip,NormalizeDouble(sl,Digits),NormalizeDouble(tp,Digits),comment,magic,exp,cl);
    if(ticket<0)
    {  
     err = GetLastError();
     Print("OrderSend Pending failed, Error: ", err, " Magic Number: ", magic, " Type: ", type);
     Print("Price: ", price, " S/L ", sl, " T/P ", tp);
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
//+------------------------------------------------------------------+

void DeleteOrder(int ticket)
{
 if(ticket<0) return;
 
 int err;
 bool attempt=true;
 while(attempt)
 {
  if(IsTradeAllowed())
  {
   for(int z=0;z<5;z++)
   {
    if(!OrderDelete(ticket))
    {  
     err = GetLastError();
     Print("OrderDelete failed, Error: ", err, " Ticket #: ", ticket); 
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
 return;
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
double StopLong(double price,int stop) // function to calculate normal stoploss if long
{
 if(stop<=0) return(0.0);
 return(NormDigits(price-NormPoints(stop))); 
}
//+------------------------------------------------------------------+
double StopShort(double price,int stop) // function to calculate normal stoploss if short
{
 if(stop<=0) return(0.0);
 return(NormDigits(price+NormPoints(stop))); 
}
//+------------------------------------------------------------------+
double TakeLong(double price,int take)  // function to calculate takeprofit if long
{
 if(take<=0) return(0.0);

 return(NormDigits(price+NormPoints(take))); 
}
//+------------------------------------------------------------------+
double TakeShort(double price,int take)  // function to calculate takeprofit if short
{
 if(take<=0) return(0.0); // if no take profit
 return(NormDigits(price-NormPoints(take))); 
}
//+------------------------------------------------------------------+
void TrailingStop(int TS)
{
 if(TS<=0) return;
 
 double stopcrnt,stopcal; 
 double profit;
 
 stopcrnt=NormDigits(OrderStopLoss());
             
 if(OrderType()==OP_BUY)
 {
  stopcal=TrailLong(Bid,TS);
  if (stopcal==stopcrnt) return;
  ModifyCompLong(stopcal,stopcrnt);  
 }    

 if(OrderType()==OP_SELL)
 {  
  stopcal=TrailShort(Ask,TS);
  if (stopcal==stopcrnt) return;  
  ModifyCompShort(stopcal,stopcrnt); 
 } 
 
 return(0);
}
//+------------------------------------------------------------------+
double TrailLong(double price,int trail)
{
 return(NormDigits(price-NormPoints(trail))); 
}
//+------------------------------------------------------------------+
double TrailShort(double price,int trail)
{
 return(NormDigits(price+NormPoints(trail))); 
}
//+------------------------------------------------------------------+
bool ModifyOrder(int ticket, double price, double sl, double tp, datetime exp, color cl=CLR_NONE)
{ 
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
//+------------------------------------------------------------------+
double NormDigits(double price)
{
 return(NormalizeDouble(price,Digits));
}
//+------------------------------------------------------------------+
double NormPoints(int pips)
{
 return(NormalizeDouble(pips*Point,Digits));
}
//+------------------------------------------------------------------+
double NormLots(double lots)
{
 return(MathMax(NormalizeDouble(lotsmin,lotsprecision),NormalizeDouble(lots,lotsprecision)));
}
//+------------------------------------------------------------------+
double DetermineProfit()
{
 if(OrderType()==OP_BUY)  
  return(Bid-OrderOpenPrice());
 else if(OrderType()==OP_SELL)
  return(OrderOpenPrice()-Ask); 
}
//+------------------------------------------------------------------+


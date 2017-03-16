//+----------------------------------------------------------------------+
//|                                         2ndSkies Straddle Pivots.mq4 |
//|                                                         David J. Lin |
//| Based on a trading strategy by Chris Capre                           |
//| (Info@2ndSkies.com)                                                  |
//|                                                                      |
//| Coded by David J. Lin (dave.j.lin@sbcglobal.net)                     |
//| Evanston, IL, March 20, 2010                                         |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2010, Chris Capre & David J. Lin"

// Internal usage parameters:
//---- input parameters
extern int EntryPips=3;         // pips above/below R1/S1 to enter
extern int StopPips=3;          // pips below/above M3/M2 to stop
extern int TakeProfit1Pips=0;   // pips below/above M4/M1 to take profit order 1
extern int TakeProfit2Pips=3;   // pips below/above R2/S2 to take profit order 2

extern int PivotStartHour=8;
extern int PivotStartMinute=0;

double   Lots=1;
int      DaysToPlot=15;
color    SupportLabelColor=Gray;
color    ResistanceLabelColor=Gray;
color    PivotLabelColor=Gray;
int      fontsize=8;
int      LabelShift = 0;
//---- buffers
bool OCO,triggered;
int Magic1,Magic2;
string comment="2ndSkies Straddle Pivots";
string ciPivots="AIME Pivots";
double lotsmin,lotsmax;
double StopLossPoints,TakeProfit1Points,TakeProfit2Points;
double EntryPoints,StopPoints,TakProfit1Points,TakProfit2Points;
double TakeProfitBTarget,TakeProfitSTarget;
double DP,R1,R2,S1,S2,M1,M2,M3,M4;
int lotsprecision;
int slippage=5;
int Number_of_Tries=5;
int ticketL1,ticketL2,ticketS1,ticketS2;
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
   EntryPoints=NormPoints(EntryPips*10);
   StopPoints=NormPoints(StopPips*10);   
   TakProfit1Points=NormPoints(TakeProfit1Pips*10);
   TakProfit2Points=NormPoints(TakeProfit2Pips*10);   
  }
  else
  {
   EntryPoints=NormPoints(EntryPips); 
   StopPoints=NormPoints(StopPips);   
   TakProfit1Points=NormPoints(TakeProfit1Pips);
   TakProfit2Points=NormPoints(TakeProfit2Pips);          
  }  
 }
 else
 {
  if(Digits==5)
  { 
   EntryPoints=NormPoints(EntryPips*10);   
   StopPoints=NormPoints(StopPips*10); 
   TakProfit1Points=NormPoints(TakeProfit1Pips*10);
   TakProfit2Points=NormPoints(TakeProfit2Pips*10);          
  }
  else
  { 
   EntryPoints=NormPoints(EntryPips);   
   StopPoints=NormPoints(StopPips);   
   TakProfit1Points=NormPoints(TakeProfit1Pips);
   TakProfit2Points=NormPoints(TakeProfit2Pips);   
  }  
 } 
 
 Magic1=1700;Magic2=1710;
 triggered=false;OCO=false;
 Reset();
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
 Main();
 ManageOrders();
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

 if(Hour()==PivotStartHour && Minute()>=PivotStartMinute)
 {
  CalcPivots(); 
  if(iOpen(NULL,0,0)>=S1 && iOpen(NULL,0,0)<=R1)
  {
   double LongEntryPrice,ShortEntryPrice;
   double SL,TP;
   int buytype=OP_BUYSTOP;
   int selltype=OP_SELLSTOP;

   LongEntryPrice=NormDigits(R1+EntryPoints);
   SL=NormDigits(M3-StopPoints);
 
   TP=NormDigits(M4-TakeProfit1Points);  
   ticketL1=SendPending(Symbol(),buytype,LongEntryPrice,Lots,slippage,0,0,comment,Magic1); 
   AddSLTP(SL,TP,ticketL1);

   TakeProfitBTarget=NormDigits(TP-LongEntryPrice);

   TP=NormDigits(R2-TakeProfit2Points); 
   ticketL2=SendPending(Symbol(),buytype,LongEntryPrice,Lots,slippage,0,0,comment,Magic2); 
   AddSLTP(SL,TP,ticketL2);  

   ShortEntryPrice=NormDigits(S1-EntryPoints);
   SL=NormDigits(M2+StopPoints);
  
   TP=NormDigits(M1+TakeProfit1Points);  
   ticketS1=SendPending(Symbol(),selltype,ShortEntryPrice,Lots,slippage,0,0,comment,Magic1); 
   AddSLTP(SL,TP,ticketS1);

   TakeProfitSTarget=NormDigits(ShortEntryPrice-TP);

   TP=NormDigits(S2+TakeProfit2Points);   
   ticketS2=SendPending(Symbol(),selltype,ShortEntryPrice,Lots,slippage,0,0,comment,Magic2); 
   AddSLTP(SL,TP,ticketS2);
  
   OCO=false;
  }
  triggered=true; // lock if succeed or fail
 }
 return; 
}
//+------------------------------------------------------------------+

void ManageOrders()
{ 
 int trade,trades=OrdersTotal(),nLpend,nSpend; 
 for(trade=trades-1;trade>=0;trade--)
 { 
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderMagicNumber()==Magic1||OrderMagicNumber()==Magic2)
  {  
   if(OrderType()==OP_BUYSTOP) nLpend++;
   else if(OrderType()==OP_SELLSTOP) nSpend++;
   
   if(OrderMagicNumber()==Magic2)
   {
    if(OrderType()==OP_BUY)       FixedStopsB(TakeProfitBTarget,0); 
    else if(OrderType()==OP_SELL) FixedStopsB(TakeProfitSTarget,0);
   }
   
   triggered=true;
  }
 }

 if(!OCO) CancelPendingOrders(nLpend,nSpend);       

 return;
}
//+------------------------------------------------------------------+
int SendPending(string sym, int type, double price, double vol, int slip, double sl, double tp, string comment="", int magic=0, datetime exp=0, color cl=CLR_NONE)
{
 if(vol<=0) return(0);
 
 price=NormDigits(price);
 sl=NormDigits(sl);
 tp=NormDigits(tp);
 
 int ticket, err; 
 
 GetSemaphore();
 for(int z=0;z<Number_of_Tries;z++)
 {   
  ticket=OrderSend(sym,type,NormLots(vol),price,slip,sl,tp,comment,magic,exp,cl);
  if(ticket<0)
  {  
   err = GetLastError();
   Print("OrderSend Pending failed, Error: ", err, " Magic Number: ", magic, " Type: ", type);
   Print("Price: ", price, " S/L ", sl, " T/P ", tp);
   Print("Bid: ", Bid, " Ask: ", Ask);
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
bool ClosePendingOrder(int ticket)
{
 GetSemaphore();
 for(int z=0;z<10;z++)
 {
  if(!OrderDelete(ticket))
  {  
   int err = GetLastError();
   Print("Order Pending failed, Error: ", err, " Ticket #: ", ticket);
   Print("Ask: ", Ask," Bid: ", Bid);   
   if(err>4000) break;
   RefreshRates();
  }
  else break;
 }
 ReleaseSemaphore();
} 
//+------------------------------------------------------------------+
void CancelPendingOrders(int nLpend, int nSpend)
{
 int cancel1=0,cancel2=0;
 
 if(nLpend!=nSpend)
 {
  if(nLpend==0)
  {
   cancel1=ticketS1;
   cancel2=ticketS2;
  }
  else if(nSpend==0)
  {
   cancel1=ticketL1;
   cancel2=ticketL2;
  }

  if(cancel1!=0&&cancel2!=0)
  {
   ClosePendingOrder(cancel1);
   ClosePendingOrder(cancel2);   
  
   OCO=true;
  }
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
void ModifyCompLong(double stopcal, double stopcrnt)
{
 stopcal=NormDigits(stopcal);
 stopcrnt=NormDigits(stopcrnt);

 if (stopcal==stopcrnt) return;
 
 if(stopcal>stopcrnt)
 {
 
  if(stopcal>=Bid) // check whether s/l is too close to market
   return;
                     
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

  if(stopcal<=Ask) // check whether s/l is too close to market
   return; 
   
  ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red);     
 }
 else if(stopcal<stopcrnt&&stopcal!=0)
 {

  if(stopcal<=Ask) // check whether s/l is too close to market
   return; 
 
  ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red); 
 }
 return;
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
double TakeLong(double price,double take)  // function to calculate takeprofit if long
{
 return(NormDigits(price+take)); 
             // plus, since the take profit is above us for long positions
}
//+------------------------------------------------------------------+
double TakeShort(double price,double take)  // function to calculate takeprofit if short
{
 return(NormDigits(price-take)); 
             // minus, since the take profit is below us for short positions
}
//+------------------------------------------------------------------+
void FixedStopsB(double PP,double PFS)
{
  double stopcrnt,stopcal;
  double profit,profitpoint;

  stopcrnt=OrderStopLoss();
  profitpoint=PP;  
          
  if(OrderType()==OP_BUY)
  {
   profit=NormDigits(Bid-OrderOpenPrice());
   
   if(profit>=profitpoint)
   {
    stopcal=TakeLong(OrderOpenPrice(),PFS);
    ModifyCompLong(stopcal,stopcrnt);
   }
  }    

  if(OrderType()==OP_SELL)
  {  
   profit=NormDigits(OrderOpenPrice()-Ask);
   
   if(profit>=profitpoint)
   {
    stopcal=TakeShort(OrderOpenPrice(),PFS);
    ModifyCompShort(stopcal,stopcrnt);  
   }
  }
 return;
} 
//+------------------------------------------------------------------+ 
void AddSLTP(double sl, double tp, int orderNumber)
{
 if(sl==0&&tp==0) return;
 if(OrderSelect(orderNumber,SELECT_BY_TICKET)) 
  ModifyOrder(orderNumber,OrderOpenPrice(),sl,tp,0,CLR_NONE);
 return;
}
//+------------------------------------------------------------------+
int CheckNumberOrder()
{
 int total=0;
 int trade,trades=OrdersTotal(),nLpend=0,nSpend=0; 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderMagicNumber()==Magic1||OrderMagicNumber()==Magic2)
  {
  
   if(OrderType()==OP_BUY||OrderType()==OP_BUYSTOP)
   {
    if(OrderMagicNumber()==Magic1) 
    { 
     ticketL1=OrderTicket();
     TakeProfitBTarget=NormDigits(OrderTakeProfit()-OrderOpenPrice());
    } 
    else ticketL2=OrderTicket();
   
   
    if(OrderType()==OP_BUYSTOP) nLpend++;
   }
   else if(OrderType()==OP_SELL||OrderType()==OP_SELLSTOP)
   {
    if(OrderMagicNumber()==Magic1)
    {
     ticketS1=OrderTicket();
     TakeProfitSTarget=NormDigits(OrderOpenPrice()-OrderTakeProfit());
    }
    else ticketS2=OrderTicket();
   
    if(OrderType()==OP_SELLSTOP) nSpend++;   
   }
   total++; 
   triggered=true;
  }
 }

 if(nLpend==nSpend) OCO=false;
 else               OCO=true;
 
 return(total);
}
//+------------------------------------------------------------------+
void CalcPivots() {
 DP=iCustom(NULL,PERIOD_D1,ciPivots,PivotStartHour,PivotStartMinute,DaysToPlot,SupportLabelColor,ResistanceLabelColor,PivotLabelColor,fontsize,LabelShift,0,0);
 S1=iCustom(NULL,PERIOD_D1,ciPivots,PivotStartHour,PivotStartMinute,DaysToPlot,SupportLabelColor,ResistanceLabelColor,PivotLabelColor,fontsize,LabelShift,1,0);
 R1=iCustom(NULL,PERIOD_D1,ciPivots,PivotStartHour,PivotStartMinute,DaysToPlot,SupportLabelColor,ResistanceLabelColor,PivotLabelColor,fontsize,LabelShift,2,0);
 S2=iCustom(NULL,PERIOD_D1,ciPivots,PivotStartHour,PivotStartMinute,DaysToPlot,SupportLabelColor,ResistanceLabelColor,PivotLabelColor,fontsize,LabelShift,3,0);
 R2=iCustom(NULL,PERIOD_D1,ciPivots,PivotStartHour,PivotStartMinute,DaysToPlot,SupportLabelColor,ResistanceLabelColor,PivotLabelColor,fontsize,LabelShift,4,0);

 M1=0.5*(S1+S2);
 M2=0.5*(S1+DP);
 M3=0.5*(R1+DP);
 M4=0.5*(R1+R2);
 return;
}
//+------------------------------------------------------------------+
void Reset() {
 if(CheckNumberOrder()==0) triggered=false;
}
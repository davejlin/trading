//+----------------------------------------------------------------------+
//|                                                          Vailoor.mq4 |
//|                                                         David J. Lin |
//| Vailoor                                                              |
//| for Vasanth and Meera Vailoor                                        |
//| vailoors@yahoo.com                                                   |
//|                                                                      |
//| Coded by David J. Lin (dave.j.lin@gmail.net)                         |
//| Evanston, IL, January 12, 2011                                       |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2011, Vasanth Vailoor and David J. Lin"

// Internal usage parameters:

//---- input parameters
extern int spacing=25; // pips primary grid spacing
extern double lotsBasis=4000; // dollars to base lot determination
extern double maxBalance=4000; // manual setting for maximum account balance for lot determination (the larger of this or actual account balance will be used)
extern int nStep=0; // the step at which to start the EA
extern bool Use_Time_Window=true; // true = use time filter, false = no time filter
extern int Start_Hour=8;   // hours (platform time) to activate EA
extern int Start_Minute=0; // minute to activate EA
extern int End_Hour=14;    // hours (platform time) to deactivate EA
extern int End_Minute=30;  // minute to deactivate EA
extern int Close_Hour=16;  // hours (platform time) to deactivate EA
extern int Close_Minute=0; // minute to deactivate EA
extern bool alert=true; // toggle for alerts upon order entries

//---- buffers
bool orderlong;
bool ordershort;
bool triggered;
bool runnable;
bool resolveStraddle;
bool sweepOrders;
bool phase2pending;
bool antNext;
bool firstPhaseTwoPass;
bool firstLaunch;

int Magic1=101;
int Magic2=102;
string comment="Vailoor";
datetime ots,otl,lasttime;

double Lots;
double maxLots;
double lotsmin;
double lotsmax;

int TakeProfit;
int StopLoss;
double StopLossPoints;
double TakeProfitPoints;
double spacingPoints;

int ticketLongP;
int ticketShortP;
int ticketLong;
int ticketShort;
int nLongP;
int nShortP;
int nLong;
int nShort;
int nTotal;
int nMarket;
int nPending;

double gridDn;
double gridUp;

int lotsprecision;
int Slippage=1;
string semaphorestring;
string teststring;
double point;
int direction[];
int lookBack=4; // number of steps to look back, also number of initial stop straddle pairs
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//---- 
 semaphorestring="SEMAPHORE";
 teststring="TEST";

 phase2pending=true; // toggle pending vs. market phaseTwo
 
 runnable=true;
 resolveStraddle=false;
 sweepOrders=true;
 antNext=false;
 firstPhaseTwoPass=true;
 firstLaunch=true;

 lotsmin=MarketInfo(Symbol(),MODE_MINLOT); 
 lotsmax=MarketInfo(Symbol(),MODE_MAXLOT); 

 if(lotsmin==1)         lotsprecision=0;
 else if(lotsmin==0.50) lotsprecision=1; // for PFG ECN
 else if(lotsmin==0.10) lotsprecision=1;
 else if(lotsmin==0.01) lotsprecision=2;
 else                   lotsprecision=1; 

 maxLots=0;
 TakeProfit=spacing;
 StopLoss=spacing;
 
 ArrayResize(direction,lookBack);
 for(int i=0;i<lookBack;i++)
 {
  direction[i]=-1;
 }

 if(StringFind(Symbol(),"JPY")>0) 
 {
  if(Digits==3)
  {
   spacingPoints=NormPoints(spacing*10);
   StopLossPoints=NormPoints(StopLoss*10);
   TakeProfitPoints=NormPoints(TakeProfit*10);  
   point=Point*10;   
  }
  else
  {
   spacingPoints=NormPoints(spacing);
   StopLossPoints=NormPoints(StopLoss);
   TakeProfitPoints=NormPoints(TakeProfit); 
   point=Point;       
  }  
 }
 else
 {
  if(Digits==5)
  {
   spacingPoints=NormPoints(spacing*10);
   StopLossPoints=NormPoints(StopLoss*10);
   TakeProfitPoints=NormPoints(TakeProfit*10); 
   point=Point*10;       
  }
  else
  {
   spacingPoints=NormPoints(spacing);
   StopLossPoints=NormPoints(StopLoss);
   TakeProfitPoints=NormPoints(TakeProfit);  
   point=Point;     
  }  
 } 
 
 initPriceGrid();
 
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
 
 CheckNumberOrder();
 
 if(IsTesting()) semaphorestring=StringConcatenate(semaphorestring,teststring);

 UpdateDataWindow();
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
 if(IsTesting()) GlobalVariableDel(semaphorestring);
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
 if(!runnable) return(0);
//----   

 ManageOrders();
 
 if(TimeCheck())
 {
  if(nStep==0&&nPending==0&&firstLaunch) initLaunch(); 
  if(nStep<lookBack) phaseOne();
  else               phaseTwo();
 }
 
 UpdateDataWindow();
  
 if(lasttime==iTime(NULL,0,0)) return(0);
 lasttime=iTime(NULL,0,0);
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert utility functions                                         |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void initLaunch() // initial launch
{ 
 if(triggered) return;
 
 double Price;
 double SL,TP;
 string td;

 resolveStraddle=true;
 firstPhaseTwoPass=true; 
 ticketLongP=0;
 ticketShortP=0;
 firstLaunch=false;

 if(nLongP==0)
 {
  phaseOneSubmit(true);  
 } 
 
 if(nShortP==0)
 {
  phaseOneSubmit(false); 
 } 

 if(ticketShortP>0&&ticketLongP>0)
 {
  triggered=true;
 }
 else // in case one-sided entry
 {
  triggered=false;
  if(ticketLongP>0) DeleteOrder(ticketLongP);
  if(ticketShortP>0) DeleteOrder(ticketShortP);
  if(!IsTesting()) runnable=false;
  Alert("WARNING: One-sided entry: please reapply EA.");
 }

 return; 
}
//+------------------------------------------------------------------+
void phaseOne()
{ 
 string td;
 
 if(nLong>0||nLongP>0)
 {
  if(Ask>=gridUp)
  { 

   UpdateDirection(1);   
   nStep++;
   UpdateGridPrice(true);  

   if(nStep<lookBack)
   {  
    phaseOneSubmit(true);  
   }

  }
  else if(Bid<=gridDn)
  {
   td=TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES);  
   if(alert) Alert("Vailoor EA Phase 1 Long Exit: #",ticketLong,": ",Symbol()," M",Period()," at ",td);   

   UpdateDirection(0); 
   nStep++;
   UpdateGridPrice(false);  

   if(nStep<lookBack)
   {   
    if(nLongP==1)
    {
     phaseOneModify(true);
    }

    if(nLong==0)
    {
     phaseOneSubmit(false); 
    
     resolveStraddle=true;
    }
   }

  }
 }
 
 if(nShort>0||nShortP>0)
 {
  if(Bid<=gridDn)
  {

   UpdateDirection(0);  
   nStep++;
   UpdateGridPrice(false);   
  
   if(nStep<lookBack)
   {  
    phaseOneSubmit(false); 
   }
  }
  else if(Ask>=gridUp)
  {
   td=TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES);   
   if(alert) Alert("Vailoor EA Phase 1 Short Exit: #",ticketShort,": ",Symbol()," M",Period()," at ",td);   

   UpdateDirection(1);
   nStep++;
   UpdateGridPrice(true);
   
   if(nStep<lookBack)
   { 
   
    if(nShortP==1)
    {
     phaseOneModify(false);
    }

    if(nShort==0)
    {
     phaseOneSubmit(true); 
    
     resolveStraddle=true;
    }
   }
   
  }
 }

 return;
}
//+------------------------------------------------------------------+
void phaseTwo()
{
 if(phase2pending) phaseTwoPending();
 else              phaseTwoMarket(); 
 // Market results slightly different than Pending due to Market using
 // hard close (slippage + last in-first out), while Pending using 
 // SL (more rounded exact figures + first in-first out).
 // Market: last in-first out due to phaseTwoClose looping in reverse order 
 // Pending: first in-first out due to phaseTwoModify looping in forward order
}
//+------------------------------------------------------------------+
void phaseTwoPending()
{ 
 if(sweepOrders) SweepOrders();
 
 string td;
 bool updateDirection;
 int dir;
 
 int idir=1; // anticipating future after first pass
 if(firstPhaseTwoPass) idir=0;
 
 if(Ask>=gridUp)
 {
  UpdateGridPrice(true);
  antNext=true;
  updateDirection=true;
  dir=1;
 }
 else if(Bid<=gridDn)
 {
  UpdateGridPrice(false);
  antNext=true;
  updateDirection=false;
  dir=0;
 } 
 
 if(!antNext&&!firstPhaseTwoPass) return;
 
 if(nLong>0)
 {
  if(direction[idir]==0)
  {
   phaseTwoSubmit(true,idir); 
  }
  else
  {
   if(nLongP>0) DeleteOrder(ticketLongP); 
   phaseTwoModify(true,gridDn);   
  }
 }
 else if(nShort>0)
 {
  if(direction[idir]==1)
  {
   phaseTwoSubmit(false,idir); 
  }
  else
  {
   if(nShortP>0) DeleteOrder(ticketShortP);   
   phaseTwoModify(false,gridUp);   
  } 
 }
 else
 {
  if(direction[idir]==0)
  {
   phaseTwoSubmit(true,idir); 
  }
  else
  {
   phaseTwoSubmit(false,idir);  
  }
 }

 if(!firstPhaseTwoPass)
 {
  UpdateDirection(dir); // must be here for correct direction element 
  nStep++;
  antNext=false; 
 }

 firstPhaseTwoPass=false;
 
 return;
}
//+------------------------------------------------------------------+
void phaseTwoMarket()
{ 
 if(sweepOrders) SweepOrders();

 double SL=0, TP=0;
 string td;
 
 if(Ask>=gridUp)
 { 
  if(direction[0]==0)
  {
   if(nShort==0)
   {
    CalcUnitLots();   
    ticketLong=SendOrderLong(Symbol(),Lots,Slippage,0,0,comment,Magic2);   

    otl=TimeCurrent();
    td=TimeToStr(otl,TIME_DATE|TIME_MINUTES);
    if(alert) Alert("Vailoor EA Phase 2 Long: #",ticketLong,": ",Symbol()," M",Period()," at ",td);
    if(SL>0||TP>0) AddSLTP(SL,TP,ticketLong);
   }
   else
   {
    phaseTwoClose(false);
   }   
  } 
  UpdateDirection(1);   
  nStep++;
  UpdateGridPrice(true);  
 }
 else if(Bid<=gridDn)
 {
  if(direction[0]==1)
  {
   if(nLong==0)
   {
    CalcUnitLots();   
    ticketShort=SendOrderShort(Symbol(),Lots,Slippage,0,0,comment,Magic2);   

    ots=TimeCurrent();
    td=TimeToStr(ots,TIME_DATE|TIME_MINUTES);
    if(alert) Alert("Vailoor EA Phase 2 Short: #",ticketShort,": ",Symbol()," M",Period()," at ",td);
    if(SL>0||TP>0) AddSLTP(SL,TP,ticketShort);
   }   
   else
   {
    phaseTwoClose(true);
   }
  }  
  UpdateDirection(0);  
  nStep++;
  UpdateGridPrice(false);
 }

 return;
}
//+------------------------------------------------------------------+
void ManageOrders()
{ 
 initTally();
 int trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 { 
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderMagicNumber()!=Magic1&&OrderMagicNumber()!=Magic2) continue;
  
  TradeTally(); 
  triggered=true;
 }
 ResolveStraddle();
 TimeExitOrders();
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
  Print(" New Price: ", DoubleToStr(price,Digits), " New S/L ", DoubleToStr(sl,Digits), " New T/P ", DoubleToStr(tp,Digits), " New Expiration ", exp);
 }
 ReleaseSemaphore();
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
   Print("Ask: ", DoubleToStr(Ask,Digits), " S/L ", DoubleToStr(sl,Digits), " T/P ", DoubleToStr(tp,Digits));
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
   Print("Bid: ", DoubleToStr(Bid,Digits), " S/L ", DoubleToStr(sl,Digits), " T/P ", DoubleToStr(tp,Digits));   
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
   Print("Bid: ", DoubleToStr(Bid,Digits));   
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
   Print("Ask: ", DoubleToStr(Ask,Digits));   
   if(err>4000) break;
   RefreshRates();
  }
  else break;
 }
 ReleaseSemaphore();
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
 for(int z=0;z<10;z++)
 {   
  ticket=OrderSend(sym,type,NormLots(vol),price,slip,sl,tp,comment,magic,exp,cl);
  if(ticket<0)
  {  
   err = GetLastError();
   Print("OrderSend Pending failed, Error: ", err, " Magic Number: ", magic, " Type: ", type);
   Print("Price: ", DoubleToStr(price,Digits), " S/L ", DoubleToStr(sl,Digits), " T/P ", DoubleToStr(tp,Digits));
   Print("Bid: ", DoubleToStr(Bid,Digits), " Ask: ", DoubleToStr(Ask,Digits));
   if(err==147)  
   {
    exp=0; // broker rejects expiration time so reset expiration to zero
   }
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
void DeleteOrder(int ticket)
{
 GetSemaphore();
 for(int z=0;z<5;z++)
 {
  if(!OrderDelete(ticket))
  {  
   int err = GetLastError();
   Print("OrderDelete failed, Error: ", err, " Ticket #: ", ticket);
   Print("Bid: ", DoubleToStr(Bid,Digits), " Ask: ", DoubleToStr(Ask,Digits));   
   if(err>4000) break;
   RefreshRates();
  }
  else break;
 } 
 ReleaseSemaphore();
 return;
}  
//+------------------------------------------------------------------+
bool GetSemaphore()
{  
 if(!GlobalVariableCheck(semaphorestring)) GlobalVariableSet(semaphorestring,0);
 while(!IsStopped())
 {  
  if(GlobalVariableSetOnCondition(semaphorestring,1,0)==true) break;
  Sleep(500);
 }
 return(true);
}
//+------------------------------------------------------------------+
bool ReleaseSemaphore()
{
 GlobalVariableSet(semaphorestring,0);
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
void CalcUnitLots()
{
 double max=MathMax(maxBalance,AccountBalance());
 double lots=NormalizeDouble(max/(10*lotsBasis),Digits);
 
 if(lots>maxLots) maxLots=lots;

 Lots=maxLots;
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
void CheckNumberOrder() // check number of orders in account
{
 initTally();
 
 int trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderMagicNumber()!=Magic1&&OrderMagicNumber()!=Magic2) continue;
  
  TradeTally();
  triggered=true; 
 }
 return;
}
//+------------------------------------------------------------------+
void initTally()
{
 triggered=false;

 ticketLongP=0;
 ticketShortP=0;
 ticketLong=0;
 ticketShort=0;

 nLongP=0;
 nShortP=0;
 nLong=0;
 nShort=0;
 
 nMarket=0;
 nPending=0;
 nTotal=0;
 return;
}
//+------------------------------------------------------------------+
void TradeTally()
{
 if(OrderType()==OP_BUY)
 {
  ticketLong=OrderTicket();
  nLong++;
  nMarket++;
 }
 else if(OrderType()==OP_SELL)
 {
  ticketShort=OrderTicket();
  nShort++;
  nMarket++;  
 }
 else if(OrderType()==OP_BUYSTOP)
 {
  ticketLongP=OrderTicket();
  nLongP++;
  nPending++;
 }
 else if(OrderType()==OP_SELLSTOP)
 {
  ticketShortP=OrderTicket();
  nShortP++;
  nPending++;
 }
 
 nTotal++;

 return;
}
//+------------------------------------------------------------------+
void initPriceGrid()
{
 double price = Bid / Point;

 if(Digits==3||Digits==5) price/=10;

 price=MathRound(price);

 int iprice = price; 
 int rem = iprice % spacing; 
 
 gridDn = NormDigits((price - rem)*Point);

 if(Digits==3||Digits==5)
 {
  gridDn*=10;
  price*=10*Point;
 }
 else price*=Point;

 gridUp = NormDigits(gridDn + spacingPoints);
 
 //Alert(gridDn+" "+price+" "+gridUp);
 return;
}
//+------------------------------------------------------------------+
void ResolveStraddle()
{
 if(!resolveStraddle) return;
 if(nPending!=1) return;
 
 string td=TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES);
 
 if(nShortP==1) 
 {
  DeleteOrder(ticketShortP);
  ticketShortP=0;
  nShortP=0;
  if(alert) Alert("Vailoor EA Phase 1 Long: #",ticketLong,": ",Symbol()," M",Period()," at ",td); 
  resolveStraddle=false; 
 }
 else if(nLongP==1) 
 {
  DeleteOrder(ticketLongP);
  ticketLongP=0;
  nLongP=0;  
  if(alert) Alert("Vailoor EA Phase 1 Short: #",ticketShort,": ",Symbol()," M",Period()," at ",td);
  resolveStraddle=false;    
 }
 return;
}
//+------------------------------------------------------------------+
void UpdateGridPrice(bool long)
{
 if(long)
 {
  gridDn=NormDigits(gridUp-spacingPoints);
  gridUp=NormDigits(gridUp+spacingPoints); 
 }
 else
 {
  gridUp=NormDigits(gridDn+spacingPoints);
  gridDn=NormDigits(gridDn-spacingPoints);  
 }
 return;
}
//+------------------------------------------------------------------+
void UpdateDirection(int dir)
{
 if(nStep<lookBack) direction[nStep]=dir;
 else
 {
  for(int i=0;i<lookBack-1;i++)
  {
   direction[i]=direction[i+1];
  }
  direction[lookBack-1]=dir;
 }
 return;
}
//+------------------------------------------------------------------+
void SweepOrders()
{ 
 if(nMarket>0)
 {
  ZeroSL();
 }
 if(ticketLongP>0) DeleteOrder(ticketLongP);
 if(ticketShortP>0) DeleteOrder(ticketShortP);  
 sweepOrders=false;
 return;
}
//+------------------------------------------------------------------+
void ZeroSL()
{ 
 int trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 { 
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderMagicNumber()!=Magic1&&OrderMagicNumber()!=Magic2) continue;
  
  if(OrderType()==OP_BUY||OrderType()==OP_SELL)
  {
   if(OrderStopLoss()!=0)
   {
    ModifyOrder(OrderTicket(),OrderOpenPrice(),0,0,0);
   }
  }
 }
 return;
}
//+------------------------------------------------------------------+
void phaseTwoClose(bool long)
{
 int count=0;
 int trade,trades=OrdersTotal(); 

 if(long)
 {
  for(trade=trades-1;trade>=0;trade--)
  { 
   OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
   if(OrderSymbol()!=Symbol()) continue;
   if(OrderType()!=OP_BUY) continue;
   
   if(OrderMagicNumber()==Magic2)
   {
    CloseOrderLong(OrderTicket(),OrderLots(),Slippage,Lime); 

    return; // 1 since 2 unit volume 
   }    
   else if(OrderMagicNumber()==Magic1)
   {  
    CloseOrderLong(OrderTicket(),OrderLots(),Slippage,Lime);
   
    count++;
    if(count==2) return; // 2 since 1 unit volume 
   }
   
  }
 }
 else
 {
  for(trade=trades-1;trade>=0;trade--)
  { 
   OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
   if(OrderSymbol()!=Symbol()) continue;
   if(OrderType()!=OP_SELL) continue;

   if(OrderMagicNumber()==Magic2)
   {
    CloseOrderShort(OrderTicket(),OrderLots(),Slippage,Lime);  

    return; // 1 since 2 unit volume 
   }    
   else if(OrderMagicNumber()==Magic1)
   {  
    CloseOrderShort(OrderTicket(),OrderLots(),Slippage,Lime);
   
    count++;
    if(count==2) return; // 2 since 1 unit volume 
   }

  } 
 }
 return;
}
//+------------------------------------------------------------------+
void phaseOneModify(bool longFlag)
{
 double Price;
 double SL=0;
 double TP=0;
 string td;
 if(longFlag)
 {
  Price=gridUp;
  SL=StopLong(Price,spacingPoints);
  TP=0;
    
  ModifyOrder(ticketLongP,Price,SL,TP,0,Blue);

  otl=TimeCurrent();
  td=TimeToStr(otl,TIME_DATE|TIME_MINUTES);
  if(alert) Alert("Vailoor EA Phase 1 Long Mod: #",ticketLongP,": ",Symbol()," M",Period()," at ",td);
 }
 else
 {
  Price=gridDn;
  SL=StopShort(Price,spacingPoints);
  TP=0;
    
  ModifyOrder(ticketShortP,Price,SL,TP,0,Red);

  ots=TimeCurrent();
  td=TimeToStr(ots,TIME_DATE|TIME_MINUTES);
  if(alert) Alert("Vailoor EA Phase 1 Short Mod: #",ticketShortP,": ",Symbol()," M",Period()," at ",td);
 }
 return;
}
//+------------------------------------------------------------------+
void phaseTwoModify(bool longFlag, double targetprice)
{
 ZeroSL();

 int count=0,type;
 int trade,trades=OrdersTotal(); 

 if(longFlag) type=OP_BUY;
 else         type=OP_SELL;
 
// for(trade=trades-1;trade>=0;trade--)  
 for(trade=0;trade<trades;trade++) // start from 0 for first in, first change
 { 
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderType()!=type) continue;
   
  if(OrderMagicNumber()==Magic2)
  {
   CompModifyOrder(longFlag,targetprice);

   return; // 1 since 2 unit volume 
  }    
  else if(OrderMagicNumber()==Magic1)
  {  
   CompModifyOrder(longFlag,targetprice);
   
   count++;
   if(count==2) return; // 2 since 1 unit volume 
  }
 }
 return;
}
//+------------------------------------------------------------------+
void phaseOneSubmit(bool long)
{
 double Price;
 double SL=0;
 double TP=0;
 string td;
 if(long)
 {
  Price=gridUp;
  SL=StopLong(Price,spacingPoints);
  TP=0;  
  CalcUnitLots();   
  ticketLongP=SendPending(Symbol(),OP_BUYSTOP,Price,Lots,Slippage,0,0,comment,Magic1,0,Blue); 
  //ticketLong=SendOrderLong(Symbol(),Lots,Slippage,0,0,comment,Magic1);   

  otl=TimeCurrent();
  td=TimeToStr(otl,TIME_DATE|TIME_MINUTES);
  if(alert) Alert("Vailoor EA Phase 1 Long: #",ticketLongP,": ",Symbol()," M",Period()," at ",td);
  if(SL>0||TP>0) AddSLTP(SL,TP,ticketLongP); 
 }
 else
 {
  Price=gridDn; 
  SL=StopShort(Price,spacingPoints);
  TP=0;  
  CalcUnitLots();
  ticketShortP=SendPending(Symbol(),OP_SELLSTOP,Price,Lots,Slippage,0,0,comment,Magic1,0,Red);   
  //ticketLong=SendOrderShort(Symbol(),Lots,Slippage,0,0,comment,Magic1);  
  
  ots=TimeCurrent();
  td=TimeToStr(ots,TIME_DATE|TIME_MINUTES);
  if(alert) Alert("Vailoor EA Phase 1 Short: #",ticketShortP,": ",Symbol()," M",Period()," at ",td);
  if(SL>0||TP>0) AddSLTP(SL,TP,ticketShortP); 
 }
 return;
}
//+------------------------------------------------------------------+
void phaseTwoSubmit(bool long, int idir)
{
 double Price;
 double SL=0;
 double TP=0;
 string td;
 
 if(long)
 {
  Price=NormDigits(gridUp);
   
  if(direction[idir+1]==1) SL=StopLong(Price,spacingPoints); // direction[2] here, since anticipating future
  else                     SL=0;

  TP=0;   
  CalcUnitLots();   
  if(nLongP==0) ticketLongP=SendPending(Symbol(),OP_BUYSTOP,Price,2*Lots,Slippage,0,0,comment,Magic2,0,Blue); 
  else          ModifyOrder(ticketLongP,Price,0,0,0,Blue);
  
  otl=TimeCurrent();
  td=TimeToStr(otl,TIME_DATE|TIME_MINUTES);
  if(alert) Alert("Vailoor EA Phase 2 Long: #",ticketLongP,": ",Symbol()," M",Period()," at ",td);
  if(SL>0||TP>0) AddSLTP(SL,TP,ticketLongP);

  if(nShortP>0) DeleteOrder(ticketShortP);  
 }
 else
 {
  Price=NormDigits(gridDn);

  if(direction[idir+1]==0) SL=StopShort(Price,spacingPoints); // direction[2] here, since anticipating future
  else                     SL=0;

  TP=0;   
  CalcUnitLots();   
  if(nShortP==0) ticketShortP=SendPending(Symbol(),OP_SELLSTOP,Price,2*Lots,Slippage,0,0,comment,Magic2,0,Red); 
  else           ModifyOrder(ticketShortP,Price,0,0,0,Red);
  
  ots=TimeCurrent();
  td=TimeToStr(ots,TIME_DATE|TIME_MINUTES);
  if(alert) Alert("Vailoor EA Phase 2 Short: #",ticketShortP,": ",Symbol()," M",Period()," at ",td);
  if(SL>0||TP>0) AddSLTP(SL,TP,ticketShortP);

  if(nLongP>0) DeleteOrder(ticketLongP); 
 }
 return;
}
//+------------------------------------------------------------------+
void CompModifyOrder(bool longFlag, double targetprice)
{
 if(longFlag)
 {
  if(targetprice!=OrderStopLoss()) ModifyOrder(OrderTicket(),OrderOpenPrice(),targetprice,0,0);
 }
 else
 {
  if(targetprice!=OrderStopLoss()) ModifyOrder(OrderTicket(),OrderOpenPrice(),targetprice,0,0);
 }
 return;
}
//+------------------------------------------------------------------+
void UpdateDataWindow()
{
 string info;
 double DU=NormDigits((gridUp-Ask)/point);
 double DL=NormDigits((Bid-gridDn)/point);
 string DUpper=DoubleToStr(DU,1);
 string DLower=DoubleToStr(DL,1);
 
 info = StringConcatenate("\nStep: ",DoubleToStr(nStep,0),
                          "\n# Market: ",DoubleToStr(nMarket,0),
                          "\n# Pending: ",DoubleToStr(nPending,0),
                          "\nDirection: ",direction[0]," ",direction[1]," ",direction[2]," ",direction[3],
                          "\nAsk: ",DoubleToStr(Ask,Digits),
                          "\nBid: ",DoubleToStr(Bid,Digits),                          
                          "\nUpper: ",DoubleToStr(gridUp,Digits),
                          "\nLower: ",DoubleToStr(gridDn,Digits),
                          "\nD Upper: ",DUpper,
                          "\nD Lower: ",DLower);
                          
 Comment(info);
 return;
}
//+------------------------------------------------------------------+
bool TimeCheck(int i=0)
{
 if(!Use_Time_Window) return(true);
 datetime time=iTime(NULL,0,i);
 if(Start_Hour>End_Hour)
 {
  if(TimeHour(time)>Start_Hour||TimeHour(time)<End_Hour) return(true);
 }
 else
 {
  if(TimeHour(time)>Start_Hour&&TimeHour(time)<End_Hour) return(true); 
 }

 if(TimeHour(time)==Start_Hour)
 {
  if(TimeMinute(time)>=Start_Minute) return(true);
 }  
 else if(TimeHour(time)==End_Hour)
 {
  if(TimeMinute(time)<=End_Minute) return(true);
  else // reset params upon end
  {
   nStep=0;
   firstLaunch=true;
  }
 } 
 
 return(false);
}
//+------------------------------------------------------------------+
void TimeExitOrders(int i=0)
{
 if(!Use_Time_Window) return;
 int trades=OrdersTotal();
 if(trades==0) return;

 datetime time=iTime(NULL,0,i);

 if(TimeHour(time)==Close_Hour && TimeMinute(time)>=Close_Minute)
 { 
  for(int trade=trades-1;trade>=0;trade--)
  {
   OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
   if(OrderSymbol()!=Symbol()) continue;
   if(OrderMagicNumber()!=Magic1&&OrderMagicNumber()!=Magic2) continue; 

   if(OrderType()==OP_BUY) CloseOrderLong(OrderTicket(),OrderLots(),Slippage,Lime);
   else if(OrderType()==OP_SELL) CloseOrderShort(OrderTicket(),OrderLots(),Slippage,Lime);
   else if((OrderType()==OP_BUYSTOP)) OrderDelete(OrderTicket());
   else if((OrderType()==OP_SELLSTOP)) OrderDelete(OrderTicket());
  }
  
  initTally();
 }
 return;
}
//+------------------------------------------------------------------+


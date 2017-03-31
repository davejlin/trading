//+----------------------------------------------------------------------+
//|                                     Multi-Pair Order Launcher EA.mq4 |
//|                                                         David J. Lin |
//| Multi-Pair Order Launcher EA                                         |
//|                                                                      |
//| Coded for Sérgio Spilari Filho <sergio@ssfconsultoriafinanceira.com> |
//| Coded by David J. Lin (dave.j.lin@gmail.com)                         |
//| Evanston, IL, June 9, 2013                                           |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2013,  Sérgio Spilari Filho and David J. Lin"

#include <stderror.mqh>
#import "stdlib.ex4"
   string ErrorDescription(int error_code);

// Internal usage parameters:
//---- input parameters
extern string Pair_1_Symbol = "";        // Pair 1's symbol 
extern string Pair_2_Symbol = "";        // Pair 2's symbol 
extern string Pair_3_Symbol = "";        // Pair 3's symbol 
extern string Pair_4_Symbol = "";        // Pair 4's symbol 

extern bool StopLoss_Prev_D1 = false;    // set SL to previous D1 bar's high/low
extern bool StopLoss_Current_D1 = false; // set SL to current D1 bar's high/low 
                                         // NOTE:  If both of the above are set to true,
                                         //        then previous D1 will be used.
                                         //        If both are false, no SL will be set.

//---- buffers
bool orderLong,orderShort,triggered,launch,allSLSet;
int Magic=12121;
string comment="Multi-Pair Order Launcher";
datetime ots,otl,lasttime;
double Lots,lotsmin,lotsmax;
int lotsprecision;
int Slippage=1;
int nOrders,totNPairs,totLaunchPairs;
int SLMode;
string semaphorestring;
string teststring;
string PairSymbols[4];
string symError="*ERROR*";
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//---- 
 semaphorestring="SEMAPHORE";
 teststring="TEST";

 lotsmin=MarketInfo(Symbol(),MODE_MINLOT); 
 lotsmax=MarketInfo(Symbol(),MODE_MAXLOT); 

 if(lotsmin==1)         lotsprecision=0;
 else if(lotsmin==0.10) lotsprecision=1;
 else if(lotsmin==0.01) lotsprecision=2;
 else                   lotsprecision=1; 
 
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
 
 InitializeParameters();

 if(IsTesting()) semaphorestring=StringConcatenate(semaphorestring,teststring);
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
//----
 ManageOrders();
 Main();
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert utility functions                                         |
//+------------------------------------------------------------------+
void InitializeParameters()
{
 LoadPair(0,Pair_1_Symbol);
 LoadPair(1,Pair_2_Symbol);
 LoadPair(2,Pair_3_Symbol);
 LoadPair(3,Pair_4_Symbol);
 
 totLaunchPairs=4;
 totNPairs=totLaunchPairs+1;
 
 Lots=0;

 orderLong=false;
 orderShort=false;
 triggered=false;
 launch=false;
 allSLSet=false;
 
 if(StopLoss_Prev_D1)
  SLMode=1;
 else if(StopLoss_Current_D1)
  SLMode=0;
 else
  SLMode=-1;
   
 return;
}
//+------------------------------------------------------------------+
void LoadPair(int i, string sym)
{
 int pairDigits = MarketInfo(sym,MODE_DIGITS);
 
 if(CheckError(sym))
 {
  PairSymbols[i] = symError;
  return;
 }
 
 PairSymbols[i] = sym;
 
}
//+------------------------------------------------------------------+
bool CheckError(string sym)
{
 int error=GetLastError();

 if(error==ERR_NO_ERROR)
 {
  return (false);
 }
 else if(error==ERR_UNKNOWN_SYMBOL)
 {
  Alert("Error ... No such currency pair: "+sym);
  return (true);
 }
 else
 {
  Alert("Error ... "+ErrorDescription(error));
  return (false);
 }  
 return(false);
}
//+------------------------------------------------------------------+
void Main()
{ 
 if(triggered || !launch) return;
 
 double SL;
 string td,sym;
 int ticket,i;

 if(orderLong)
 {

  for(i=0; i<totLaunchPairs; i++)
  {
   sym = PairSymbols[i];
   if(sym==symError)
    continue;
    
   ticket=SendOrderLong(sym,Lots,Slippage,0,0,comment,Magic);
   SL=StopLong(sym);
   AddSLTP(sym,SL,0,ticket);
  }
    
  otl=TimeCurrent();
  td=TimeToStr(otl,TIME_DATE|TIME_MINUTES);

  triggered=true;  
 } 
 else if(orderShort)
 {

  for(i=0; i<totLaunchPairs; i++)
  {
   sym = PairSymbols[i];
   if(sym==symError)
    continue;
      
   ticket=SendOrderShort(sym,Lots,Slippage,0,0,comment,Magic);
   SL=StopShort(sym);
   AddSLTP(sym,SL,0,ticket);
  }
    
  ots=TimeCurrent();
  td=TimeToStr(ots,TIME_DATE|TIME_MINUTES);

  triggered=true;
 } 

 return; 
}
//+------------------------------------------------------------------+
void ManageOrders()
{
 CheckNumberOrder();
 if(!triggered)
 {
  if(SetActionFlags())
   return;
 }
 
 if(allSLSet)
  return;
 
 for(int trade=0;trade<nOrders;trade++)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);

  if(OrderStopLoss()==0)
  {
   SetOrderSL();
  }
 }

 return;
}
//+------------------------------------------------------------------+
bool SetActionFlags()
{
 launch=false; 
 if(nOrders==1)
 {
  launch=true;
  return(true);
 }
 else if(nOrders>1)
 {
  triggered=true;
  launch=false;
  return(false);
 }
 else
 {
  triggered=false;
  launch=false;
  return(true);
 }
 return(false);
}
//+------------------------------------------------------------------+
bool ModifyOrder(string sym, int ticket, double price, double sl, double tp, datetime exp, color cl=CLR_NONE)
{ 
 bool status=false;

 GetSemaphore();

 if(OrderModify(ticket,price,sl,tp,exp,cl)==false)
 { 
  double digits = MarketInfo(sym,MODE_DIGITS); 
  Print("OrderModify failed, Error: ", ErrorDescription(GetLastError()), " ", sym, " Ticket Number: ", ticket);
  Print("Old price: ", OrderOpenPrice(), " Old S/L ", OrderStopLoss(), " Old T/P ", OrderTakeProfit(), " Ask/Bid ",NormDigits(MarketInfo(sym,MODE_ASK),sym),", ",NormDigits(MarketInfo(sym,MODE_BID),sym));
  Print(" New Price: ", DoubleToStr(price,digits), " New S/L ", DoubleToStr(sl,digits), " New T/P ", DoubleToStr(tp,digits), " New Expiration ", exp);

  status=false;
 }
 else
 {
  status=true;
 }

 ReleaseSemaphore();

 return(status);
}
//+------------------------------------------------------------------+
int SendOrderLong(string sym, double vol, int slip, double sl, double tp, string comment="", int magic=0, datetime exp=0, color cl=Blue)
{ 
 int ticket,err;
 
 GetSemaphore();
 
 double ask = NormDigits(MarketInfo(sym,MODE_ASK),sym);
 for(int z=0;z<5;z++)
 {  
  ticket=OrderSend(sym,OP_BUY,NormLots(vol),ask,slip,NormDigits(sl,sym),NormDigits(tp,sym),comment,magic,exp,cl);
  if(ticket<0)
  {  
   double digits = MarketInfo(sym,MODE_DIGITS);
   err = GetLastError();
   Print("OrderSend Long failed, Error: ", ErrorDescription(err), " ", sym, " Magic Number: ", magic);
   Print("Ask: ", DoubleToStr(ask,digits), " S/L ", DoubleToStr(sl,digits), " T/P ", DoubleToStr(tp,digits));
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
 
 double bid = NormDigits(MarketInfo(sym,MODE_BID),sym); 
 for(int z=0;z<5;z++)
 {  
  ticket=OrderSend(sym,OP_SELL,NormLots(vol),bid,slip,NormDigits(sl,sym),NormDigits(tp,sym),comment,magic,exp,cl);
  if(ticket<0)
  {
   double digits = MarketInfo(sym,MODE_DIGITS);    
   err = GetLastError();
   Print("OrderSend Short failed, Error: ", ErrorDescription(err), " ", sym, " Magic Number: ", magic);
   Print("Bid: ", DoubleToStr(bid,digits), " S/L ", DoubleToStr(sl,digits), " T/P ", DoubleToStr(tp,digits));   
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
double NormDigits(double price, string sym)
{
 return(NormalizeDouble(price,MarketInfo(sym,MODE_DIGITS)));
}
//+------------------------------------------------------------------+
double NormLots(double lots)
{
 return(MathMax(NormalizeDouble(lotsmin,lotsprecision),NormalizeDouble(lots,lotsprecision)));
}
//+------------------------------------------------------------------+
bool SetOrderSL()
{
 if(OrderType()==OP_BUY)
 {
  return(AddSLTP(OrderSymbol(),StopLong(OrderSymbol()),0,OrderTicket()));
 }
 else if(OrderType()==OP_SELL)
 {
  return(AddSLTP(OrderSymbol(),StopShort(OrderSymbol()),0,OrderTicket())); 
 }
 return (false);
}
//+------------------------------------------------------------------+
double StopShort(string sym)
{
 double SL=0;

 if(SLMode>-1)
  SL=iHigh(sym,PERIOD_D1,SLMode);

 return(SL); 
}
//+------------------------------------------------------------------+
double StopLong(string sym)
{
 double SL=0;

 if(SLMode>-1)
  SL=iLow(sym,PERIOD_D1,SLMode);

 return(SL); 
}
//+------------------------------------------------------------------+ 
bool AddSLTP(string sym, double sl, double tp, int orderNumber)
{
 if(orderNumber<0) return(false);
 if(sl==0&&tp==0) return(false);
 
 if(OrderSelect(orderNumber,SELECT_BY_TICKET)) 
  return(ModifyOrder(sym,orderNumber,OrderOpenPrice(),sl,tp,0,CLR_NONE));
 else
  return(false);
}
//+------------------------------------------------------------------+
void CheckNumberOrder()
{
 nOrders=OrdersTotal();

 if(allSLSet)
  return;

 int countSLSet=0; 
 for(int trade=0;trade<nOrders;trade++)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderMagicNumber()!=Magic)
  {
   if(OrderType()==OP_BUY)
    orderLong=true;
   else if(OrderType()==OP_SELL)
    orderShort=true;
    
   Lots = OrderLots();
  }
  
  if(OrderStopLoss()>0)
   countSLSet++;
 }
 
 if(countSLSet==totNPairs)
  allSLSet=true;
   
 return;
}
//+------------------------------------------------------------------+


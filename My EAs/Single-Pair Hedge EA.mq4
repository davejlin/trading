//+----------------------------------------------------------------------+
//|                                             Single Pair Hedge EA.mq4 |
//|                                                         David J. Lin |
//| Single Pair Hedge EA                                                 |
//|                                                                      |
//| Coded for Sérgio Spilari Filho <sergio@ssfconsultoriafinanceira.com> |
//| Coded by David J. Lin (dave.j.lin@gmail.com)                         |
//| Evanston, IL, June 15, 2013                                          |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2013,  Sérgio Spilari Filho and David J. Lin"

#include <stderror.mqh>
#import "stdlib.ex4"
string ErrorDescription(int error_code);

// Internal usage parameters:
//---- input parameters
extern string Pair_Symbol = "";        // Pair's symbol 

extern bool Buy = false;               // Buy order toggle
extern bool Sell = false;              // Sell order toggle

extern double Lots_Max = 100;          // Lots maximum
extern double Lots_Min = 0.1;          // Lots minimum

//---- buffers
bool orderLong,orderShort,triggered,launch;
int Magic=12122;
string comment="Single-Pair Hedge";
datetime ots,otl;
double lotsmin,lotsmax;
double PrimaryLots,PrimaryPrice;
int lotsprecision;
int Slippage=1;
int nOrders,totNPairs,totLaunchPairs;
string semaphorestring;
string teststring;
string symError="*ERROR*";
string PairSymbol;
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
 
 lotsmin = MathMax(lotsmin,Lots_Min); 
 lotsmax = MathMin(lotsmax,Lots_Max); 
 
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
 LoadPair();
 
 totLaunchPairs=1;
 totNPairs=totLaunchPairs+1;
 
 PrimaryLots=0;
 PrimaryPrice=0;

 orderLong=false;
 orderShort=false;
 triggered=false;
 launch=false;
 
 SetBias();

 return;
}
//+------------------------------------------------------------------+
void LoadPair()
{
 int pairDigits = MarketInfo(Pair_Symbol,MODE_DIGITS);
 
 if(CheckError())
 {
  PairSymbol = symError;
  return;
 }
 
 PairSymbol = Pair_Symbol;
 
}
//+------------------------------------------------------------------+
bool CheckError()
{
 int error=GetLastError();

 if(error==ERR_NO_ERROR)
 {
  return (false);
 }
 else if(error==ERR_UNKNOWN_SYMBOL)
 {
  Alert("Error ... No such currency pair: "+Pair_Symbol);
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
void SetBias()
{
 if(Buy && Sell)
 {
  Alert("Configuration ERROR! Both Buy and Sell are True!");
 }
 else if(!Buy && !Sell)
 {
  Alert("Configuration ERROR! Both Buy and Sell are False!");
 }
 else
 {
  orderLong  = Buy;
  orderShort = Sell;
 }
 return; 
}
//+------------------------------------------------------------------+
void Main()
{ 
 if(triggered || !launch) return;
 
 double lots;
 string td;
 int ticket,i;

 if(orderLong)
 {
  if(PairSymbol==symError)
   return;
  
  lots=CalculateLots(true);  
  ticket=SendOrderLong(PairSymbol,lots,Slippage,0,0,comment,Magic);
    
  otl=TimeCurrent();
  td=TimeToStr(otl,TIME_DATE|TIME_MINUTES);

  triggered=true;  
 } 
 else if(orderShort)
 {
  if(PairSymbol==symError)
   return;
   
  lots=CalculateLots(false);        
  ticket=SendOrderShort(PairSymbol,lots,Slippage,0,0,comment,Magic);

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
 if(triggered)
  return;
  
 SetActionFlags();
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
double CalculateLots(bool bias)
{
 double SecondaryPrice;
 
 if(bias)
 {
  SecondaryPrice = NormDigits(MarketInfo(PairSymbol,MODE_ASK),PairSymbol);
 }
 else
 {
  SecondaryPrice = NormDigits(MarketInfo(PairSymbol,MODE_BID),PairSymbol);
 }
 
 if(PrimaryLots<=0 || PrimaryPrice<=0 || SecondaryPrice<=0)
  return(0);
 
 return((PrimaryLots*PrimaryPrice)/SecondaryPrice);
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
 double normLots=MathMax(NormalizeDouble(lotsmin,lotsprecision),NormalizeDouble(lots,lotsprecision));
        normLots=MathMin(NormalizeDouble(lotsmax,lotsprecision),NormalizeDouble(normLots,lotsprecision));
 return(normLots);
}
//+------------------------------------------------------------------+
void CheckNumberOrder()
{
 nOrders=OrdersTotal();

 if(triggered)
  return;

 for(int trade=0;trade<nOrders;trade++)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderMagicNumber()!=Magic)
  { 
   PrimaryLots  = OrderLots();
   PrimaryPrice = OrderOpenPrice();
  }
 }  
 return;
}
//+------------------------------------------------------------------+


//+----------------------------------------------------------------------+
//|                                                              ASC.mq4 |
//|                                                         David J. Lin |
//|Based on a trading strategy using ASCTrend                            |
//|Coded by David J. Lin (dave.j.lin@sbcglobal.net)                      |                                         |
//|Evanston, IL, March 24, 2007                                          |
//+----------------------------------------------------------------------+
#property copyright "David J. Lin"
#property link      ""

// User adjustable parameters:

extern int TimeframeASC=PERIOD_H1;
extern int ASCRisk = 3;

// Internal usage parameters (do not change):

bool OrderASCLong=false,OrderASCShort=false,ExitASCLong=false,ExitASCShort=false;
bool OrderASC=false;
datetime OrderTimeASC=0; string ORDERTIMEASC;
string commentASC1="ASC1",commentASC2="ASC2",commentASC3="ASC3",commentASC4="ASC4";
int magicASC1=1001,magicASC2=1002,magicASC3=1003,magicASC4=1004;
int lastHour;
int pendingtimeASC=10;
int BlackoutPeriodASC=1;
int Slippage=3,StopLevel=5;
int  NASC,NASCBuyLimit,NASCBuyStop,NASCSellLimit,NASCSellStop;
double Lots, LotsFactor=0.01;
double PSARStep=0.007;
double PSARMax=0.20;
int PSARStopLossBuffer=12;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   ReInit();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
//----
 if(IsTesting()) GlobalVariablesDeleteAll();   
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
 if(lastHour==Hour()) return;
 DetermineLots();
 MainASC();
 lastHour=Hour();   
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert utility functions                                         |
//+------------------------------------------------------------------+
void ReInit()
{
 if(!GlobalVariableCheck("SEMAPHORE")) GlobalVariableSet("SEMAPHORE",0);
 
 ORDERTIMEASC=StringConcatenate("ORDERTIMEASC",Symbol()); 

 if(!GlobalVariableCheck(ORDERTIMEASC)) GlobalVariableSet(ORDERTIMEASC,0);

 OrderTimeASC=GlobalVariableGet(ORDERTIMEASC);  
  
 return;
}
//+------------------------------------------------------------------+
void MainASC()
{                                                                 
 ExitASCLong=false;ExitASCShort=false;
 
 int checktime=iBarShift(NULL,TimeframeASC,OrderTimeASC,false); 
 double ASCSell=iCustom(NULL,TimeframeASC,"ASCTrend1sig",ASCRisk,300,0,1);
 double ASCBuy= iCustom(NULL,TimeframeASC,"ASCTrend1sig",ASCRisk,300,1,1); 

 bool long=false, short=false;
 
 if (ASCSell>ASCBuy && ASCSell>0.001)
 {
  short=true; 
  ExitASCLong=true;
 }

 if (ASCBuy>ASCSell && ASCBuy >0.001)
 {
  long=true;
  ExitASCShort=true;
 }
  
 if(!long&&!short) return; 
 if(!OrderASC) return;
 if(checktime<=BlackoutPeriodASC) return;
 
 double FractalR=iCustom(NULL,TimeframeASC,"FractalChannel",0,0);
 double FractalS=iCustom(NULL,TimeframeASC,"FractalChannel",1,0);
 double FractalRange=FractalR-FractalS;
 double trigger=MathMax(0.5*FractalRange,NormPoints(5));
 double stop=2*FractalRange;
 double range=MathMax(iHigh(NULL,PERIOD_D1,1)-iLow(NULL,PERIOD_D1,1),NormPoints(10));
 double EntryPrice,SL,TP;
 
 if(long && OrderASCLong)
 {
 
  EntryPrice=Ask-trigger;
  SL=EntryPrice-stop;
   
  TP=EntryPrice+0.5*range;
  SendPending(Symbol(),OP_BUYLIMIT,Lots,EntryPrice,Slippage,SL,TP,commentASC1,magicASC1,PendTime(TimeCurrent(),pendingtimeASC),Blue);

  TP=EntryPrice+range;
  SendPending(Symbol(),OP_BUYLIMIT,Lots,EntryPrice,Slippage,SL,TP,commentASC2,magicASC2,PendTime(TimeCurrent(),pendingtimeASC),Blue);

  TP=EntryPrice+2*range;
  SendPending(Symbol(),OP_BUYLIMIT,Lots,EntryPrice,Slippage,SL,TP,commentASC3,magicASC3,PendTime(TimeCurrent(),pendingtimeASC),Blue);

  TP=EntryPrice+3*range;
  SendPending(Symbol(),OP_BUYLIMIT,Lots,EntryPrice,Slippage,SL,TP,commentASC4,magicASC4,PendTime(TimeCurrent(),pendingtimeASC),Blue);

  
  EntryPrice=Ask+trigger;
  SL=EntryPrice-stop;
  
  TP=EntryPrice+0.5*range;
  SendPending(Symbol(),OP_BUYSTOP,Lots,EntryPrice,Slippage,SL,TP,commentASC1,magicASC1,PendTime(TimeCurrent(),pendingtimeASC),Blue);

  TP=EntryPrice+range;
  SendPending(Symbol(),OP_BUYSTOP,Lots,EntryPrice,Slippage,SL,TP,commentASC2,magicASC2,PendTime(TimeCurrent(),pendingtimeASC),Blue);

  TP=EntryPrice+2*range;
  SendPending(Symbol(),OP_BUYSTOP,Lots,EntryPrice,Slippage,SL,TP,commentASC3,magicASC3,PendTime(TimeCurrent(),pendingtimeASC),Blue);

  TP=EntryPrice+3*range;
  SendPending(Symbol(),OP_BUYSTOP,Lots,EntryPrice,Slippage,SL,TP,commentASC4,magicASC4,PendTime(TimeCurrent(),pendingtimeASC),Blue);

  OrderTimeASC=TimeCurrent();
  GlobalVariableSet(ORDERTIMEASC,OrderTimeASC); 
  
  return;
 }
 
 if(short && OrderASCShort)
 {
  EntryPrice=Bid+trigger;
  SL=EntryPrice+stop;
   
  TP=EntryPrice-0.5*range;
  SendPending(Symbol(),OP_SELLLIMIT,Lots,EntryPrice,Slippage,SL,TP,commentASC1,magicASC1,PendTime(TimeCurrent(),pendingtimeASC),Red);

  TP=EntryPrice-range;
  SendPending(Symbol(),OP_SELLLIMIT,Lots,EntryPrice,Slippage,SL,TP,commentASC2,magicASC2,PendTime(TimeCurrent(),pendingtimeASC),Red);

  TP=EntryPrice-2*range;
  SendPending(Symbol(),OP_SELLLIMIT,Lots,EntryPrice,Slippage,SL,TP,commentASC3,magicASC3,PendTime(TimeCurrent(),pendingtimeASC),Red);

  TP=EntryPrice-3*range;
  SendPending(Symbol(),OP_SELLLIMIT,Lots,EntryPrice,Slippage,SL,TP,commentASC4,magicASC4,PendTime(TimeCurrent(),pendingtimeASC),Red);
  
  
  EntryPrice=Bid-trigger;
  SL=EntryPrice+stop;
  
  TP=EntryPrice-0.5*range;
  SendPending(Symbol(),OP_SELLSTOP,Lots,EntryPrice,Slippage,SL,TP,commentASC1,magicASC1,PendTime(TimeCurrent(),pendingtimeASC),Red);

  TP=EntryPrice-range;
  SendPending(Symbol(),OP_SELLSTOP,Lots,EntryPrice,Slippage,SL,TP,commentASC2,magicASC2,PendTime(TimeCurrent(),pendingtimeASC),Red);

  TP=EntryPrice-2*range;
  SendPending(Symbol(),OP_SELLSTOP,Lots,EntryPrice,Slippage,SL,TP,commentASC3,magicASC3,PendTime(TimeCurrent(),pendingtimeASC),Red);

  TP=EntryPrice-3*range;
  SendPending(Symbol(),OP_SELLSTOP,Lots,EntryPrice,Slippage,SL,TP,commentASC4,magicASC4,PendTime(TimeCurrent(),pendingtimeASC),Red);

  OrderTimeASC=TimeCurrent();
  GlobalVariableSet(ORDERTIMEASC,OrderTimeASC);
  
  return;
 }

 return; 
}
//+------------------------------------------------------------------+ 

void ManageOrders()
{
 CheckASCStatus();

 int trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;

  switch(OrderMagicNumber())
  {
   case 1001: 
    ManageASC1();
   break;
   case 1002: 
    ManageASC2();
   break;
   case 1003: 
    ManageASC3();
   break;
   case 1004: 
    ManageASC4();
   break;         
  }
 }
 
// OCO:
 
 if(!OrderASCLong  && NASCBuyLimit>0)   CancelPending(1);
 if(!OrderASCLong  && NASCBuyStop>0)    CancelPending(2);
 if(!OrderASCShort && NASCSellLimit>0)  CancelPending(3);
 if(!OrderASCShort && NASCSellStop>0)   CancelPending(4);
 
 return;
}
//+------------------------------------------------------------------+
void CheckASCStatus()
{
 OrderASCLong=true;OrderASCShort=true;OrderASC=true;
 NASC=0;NASCBuyLimit=0;NASCBuyStop=0;NASCSellLimit=0;NASCSellStop=0;
 
 int trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;

  if(OrderType()==OP_BUY) 
  {
   OrderASCLong=false;
   OrderASC=false;
   NASC++;
  }
  if(OrderType()==OP_SELL) 
  {
   OrderASCShort=false;
   OrderASC=false;
   NASC++;
  }
  if(OrderType()==OP_BUYLIMIT)
  {
   NASCBuyLimit++;
  }
  if(OrderType()==OP_BUYSTOP)
  {
   NASCBuyStop++; 
  }  
  if(OrderType()==OP_SELLLIMIT)
  {
   NASCSellLimit++;
  }
  if(OrderType()==OP_SELLSTOP)
  {
   NASCSellStop++; 
  } 
 } 
 return;
}
//+------------------------------------------------------------------+
void CancelPending(int flag)
{
 int target;
 switch(flag) 
 {
  case 1:
   target=OP_BUYLIMIT;
  break;
  case 2:
   target=OP_BUYSTOP;
  break;  
  case 3:
   target=OP_SELLLIMIT;
  break;  
  case 4:
   target=OP_SELLSTOP;
  break;  
 }
 int trade,trades=OrdersTotal(); 

 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);

  if(OrderSymbol()!=Symbol()) continue;
  if(OrderType()!=target) continue;

  OrderDelete(OrderTicket());
 } 
 return;
}
//+------------------------------------------------------------------+
void ManageASC1()
{
 ExitOrder(ExitASCLong,ExitASCShort,2);
 return;
}
//+------------------------------------------------------------------+
void ManageASC2()
{
 if(NASC==3) FixedStopsB(0,1);
 ExitOrder(ExitASCLong,ExitASCShort,2); 
 return;
}
//+------------------------------------------------------------------+
void ManageASC3()
{
 if(NASC==3) FixedStopsB(0,1);
 if(NASC==2) ASCStopAdjust(1);
 if(NASC==1) ASCStopAdjust(2);  
 ExitOrder(ExitASCLong,ExitASCShort,2);
 return;
}
//+------------------------------------------------------------------+
void ManageASC4()
{
 if(NASC==3) FixedStopsB(0,1);
 if(NASC==2) ASCStopAdjust(1); 
 if(NASC==1) ASCStopAdjust(2); 
 PSARTrail();
 ExitOrder(ExitASCLong,ExitASCShort,2);
 return;
}
//+------------------------------------------------------------------+
double NormalStopLong(double price,int stop)
{
 if(stop==0) return(0.0);
 else if(stop<5) stop=5; 
 return(price-NormPoints(stop)); 
}
//+------------------------------------------------------------------+
double NormalStopShort(double price,int stop)
{
 if(stop==0) return(0.0);
 else if(stop<5) stop=5;
 return(price+NormPoints(stop)); 
}
//+------------------------------------------------------------------+
double NormalTakeLong(double price,int take)  // function to calculate takeprofit if long
{
 if(take==0)
  return(0.0); // if no take profit

 return(NormDigits(price+NormPoints(take))); 
             // plus, since the take profit is above us for long positions
}
//+------------------------------------------------------------------+
double NormalTakeShort(double price,int take)  // function to calculate takeprofit if short
{
 if(take==0)
  return(0.0); // if no take profit

 return(NormDigits(price-NormPoints(take))); 
             // minus, since the take profit is below us for short positions
}
//+------------------------------------------------------------------+
int SendPending(string sym, int type, double vol, double price, int slip, double sl, double tp, string comment="", int magic=0, datetime exp=0, color cl=CLR_NONE)
{
 
// If existing pending order, modify.

 int trade; 
 int trades=OrdersTotal();
 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol())
   continue;
  if(OrderMagicNumber()!=magic)
   continue;
  if(OrderType()!=type)
   continue; 
   
  if(NormalizeDouble(price,Digits)==OrderOpenPrice()) // don't modify is it's the same price
   return;

  ModifyOrder(OrderTicket(),NormDigits(price),NormDigits(sl),NormDigits(tp),exp,cl);
   return;
 }
  
// In no existing pending order, submit new pending order.   
 int err;
 GetSemaphore();
 for(int z=0;z<5;z++)
 {  
  if(OrderSend(sym,type,NormLots(vol),NormDigits(price),slip,NormDigits(sl),NormDigits(tp),comment,magic,exp,cl)<0)
  {  
   err = GetLastError();
   Print("OrderSend Pending failed, Error: ", err, " Magic Number: ", magic, " Type: ", type);
   Print("Price: ", price, " S/L ", sl, " T/P ", tp);
   if(err>4000) break;
   RefreshRates();
  }
  else
   break;
 }
 ReleaseSemaphore();
}
//+------------------------------------------------------------------+
bool ModifyOrder(int ticket, double price, double sl, double tp, datetime exp, color cl=CLR_NONE) // by Mike
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
int SendOrderLong(string sym, double vol, int slip, double sl, double tp, string comment="", int magic=0, datetime exp=0, color cl=CLR_NONE)
{ 
 int err;
 GetSemaphore();
 for(int z=0;z<5;z++)
 {  
  if(OrderSend(sym,OP_BUY,NormLots(vol),Ask,slip,NormDigits(sl),NormDigits(tp),comment,magic,exp,cl)<0)
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
}
//+------------------------------------------------------------------+
int SendOrderShort(string sym, double vol, int slip, double sl, double tp, string comment="", int magic=0, datetime exp=0, color cl=CLR_NONE)
{  
 int err;
 GetSemaphore();
 for(int z=0;z<5;z++)
 {  
  if(OrderSend(sym,OP_SELL,NormLots(vol),Bid,slip,NormDigits(sl),NormDigits(tp),comment,magic,exp,cl)<0)
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
 if(IsTesting()) return(MathMax(0.1,NormalizeDouble(lots,1)));
 else return(MathMax(0.01,NormalizeDouble(lots,2)));
}
//+------------------------------------------------------------------+
void DetermineLots()
{
 Lots=LotsFactor*NormLots(AccountFreeMargin()/MarketInfo(Symbol(),MODE_MARGINREQUIRED) );
 return;
}
//+------------------------------------------------------------------+
datetime PendTime(int curtime,int hours)  // function to calculate pending expiration time
{
 return(TimeCurrent()+(hours*3600)); 
}
//+------------------------------------------------------------------+
void ExitOrder(bool flag_Long,bool flag_Short,int cancelpending=1)
{
 switch(cancelpending)
 {
  case 1:
   if(OrderType()==OP_BUY&&flag_Long)
    CloseOrderLong(OrderTicket(),OrderLots(),Slippage,Lime);
   else if(OrderType()==OP_SELL&&flag_Short)
    CloseOrderShort(OrderTicket(),OrderLots(),Slippage,Lime);
   break;
  case 2:
   if((OrderType()==OP_BUYSTOP||OrderType()==OP_BUYLIMIT)&&flag_Long)
    OrderDelete(OrderTicket());
   else if((OrderType()==OP_SELLSTOP||OrderType()==OP_SELLLIMIT)&&flag_Short)
    OrderDelete(OrderTicket());
   break;  
 }
 return;
}
//+------------------------------------------------------------------+
void FixedStopsB(int PP,int PFS)
{
  if(PFS==0) return;

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
    stopcal=NormalTakeLong(OrderOpenPrice(),PFS);
    ModifyCompLong(stopcal,stopcrnt);   
   }
  }    
//Short 
  if(OrderType()==OP_SELL)
  {  
   profit=OrderOpenPrice()-Ask;
   
   if(profit>=profitpoint)
   {
    stopcal=NormalTakeShort(OrderOpenPrice(),PFS);
    ModifyCompShort(stopcal,stopcrnt);
   }
  }  
 return(0);
} 
//+------------------------------------------------------------------+
void ASCStopAdjust(int flag)
{
 double mult,stopcal,stopcrnt=OrderStopLoss();
 switch(flag)
 {
  case 1: mult=0.5; break;
  case 2: mult=1.0; break;
 }
 
 int index=iBarShift(NULL,PERIOD_D1,OrderOpenTime(),false)+1; 
 double range=MathMax(iHigh(NULL,PERIOD_D1,index)-iLow(NULL,PERIOD_D1,index),NormPoints(10)); 
 
 if(OrderType()==OP_BUY)
 {
  stopcal=OrderOpenPrice()+mult*range;
  ModifyCompLong(stopcal,stopcrnt);
 }
 else if(OrderType()==OP_SELL)
 {
  stopcal=OrderOpenPrice()-mult*range;
  ModifyCompShort(stopcal,stopcrnt);
 }
 
 return;
}
//+------------------------------------------------------------------+
void ModifyCompLong(double stopcal, double stopcrnt)
{
 stopcal=NormDigits(stopcal);
 stopcrnt=NormDigits(stopcrnt);

 if (stopcal==stopcrnt) return;
 
 if(stopcal>stopcrnt)
 {
 
  if(stopcal>=Bid-NormPoints(StopLevel)) // check whether s/l is too close to market
   return;
                  
  ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Blue); 
 }
}
//+------------------------------------------------------------------+
void ModifyCompShort(double stopcal, double stopcrnt)
{
 stopcal=NormDigits(stopcal);
 stopcrnt=NormDigits(stopcrnt);

 if (stopcal==stopcrnt) return;
  
 if(stopcrnt==0)
 {

  if(stopcal<=Ask+NormPoints(StopLevel)) // check whether s/l is too close to market
   return; 
   
  ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red);     
 }
 else if(stopcal<stopcrnt&&stopcal!=0)
 {

  if(stopcal<=Ask+NormPoints(StopLevel)) // check whether s/l is too close to market
   return; 
 
  ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red); 
 }
}
//+------------------------------------------------------------------+
void PSARTrail(int hour=PERIOD_H1, double step=-1, double max=-1, int min=-1)
{
 int checktime=iBarShift(NULL,hour,OrderOpenTime(),false);
 if(checktime<1)
  return;

 double stopcrnt,stopcal,stopmin,value; 
 stopcrnt=OrderStopLoss();

 if(step<0) step=PSARStep;
 if(max<0) max=PSARMax;
 
 value=iSAR(NULL,hour,step,max,1); // use previous hour's value, now that PSAR trail is activated on top of new bar
 
// Parabolic SAR Trails

//Long               

 if(OrderType()==OP_BUY)
 {
  if(Bid<value) return; // must use friendly PSAR
  
  stopcal=value-NormPoints(PSARStopLossBuffer);

  if(min>0) stopmin=NormalStopLong(Ask,min);
  else stopmin=99999;
  if(stopcal>stopmin) return;
  if(stopcal<=stopcrnt) return;
  
  ModifyCompLong(stopcal,stopcrnt);    
 }    
//Short 
 if(OrderType()==OP_SELL)
 {   
  if(Bid>value) return; // must use friendly PSAR  
  
  stopcal=value+NormPoints(PSARStopLossBuffer);
  
  if(min>0) stopmin=NormalStopShort(Bid,min);
  else stopmin=0;
  if(stopcal<stopmin) return;
  if(stopcal>=stopcrnt) return;
  
  ModifyCompShort(stopcal,stopcrnt);
 } 
 return(0);
}
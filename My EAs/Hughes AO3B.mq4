//+----------------------------------------------------------------------+
//|                                                      Hughes AO3B.mq4 |
//|                                                         David J. Lin |
//| Hughes AO3B (Jason Hughes <jason.5.hughes@bt.com>)                   |
//|                                                                      |
//| Coded by David J. Lin (dave.j.lin@gmail.com)                         |
//| Evanston, IL, January 12, 2011                                       |
//| Addendum: PM Option 4, January 29, 2011                              |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2011, Jason Hughes & David J. Lin"

// Internal usage parameters:
//---- input parameters
extern int PMOption=4;    // position management option: 1,2,3
extern int PMBar=11;      // position management bar: beginning of bar #PMBar (total) after which to begin position management procedures
extern int EntryLong=3;   // pips above bar #2 high for buy stop entry
extern int EntryShort=1;  // pips below bar #2 low for short stop entry
extern int TakeProfit=50; // pips take profit target
extern int StopLoss=30;   // pips stop loss
extern int TakeProfit4=15;// pips take profit target (PMOption=4, Order #1)
extern int StopLoss4=20;  // pips stop loss (PMOption=4, both orders)
extern int TrailStop=1;   // pips from previous high/low to trail
extern double Risk=0.02;  // percentage to risk per trade based on StopLoss
extern double Risk4=0.01; // percentage to risk per trade based on StopLoss (PMOption=4, each order)
extern int StartHour=7;   // platform hour to start trading
extern int StartMin=30;   // platform minute to start trading
extern int EndHour=17;    // platform hour to end trading
extern int EndMin=30;     // platform minute to end trading
//---- internal parameters
bool orderlong,ordershort,triggered;
int Magic,Magic41,Magic42;
string comment="AO3B";
datetime ot,lasttime;
double lotsmin,lotsmax;
double StopLossPoints,TakeProfitPoints,TrailStopPoints;
double StopLossPoints4,TakeProfitPoints4;
double EntryLongPoints,EntryShortPoints;
double pricemodifier=5;
int lotsprecision;
int Slippage=1;
string semaphorestring="SEMAPHORE";
string order42moveSL="ORDER42MOVESL";
datetime ExpireTime;
double pendingbuffer=3;
double pendingbufferpoints;
double modifybuffer=3;
double modifybufferpoints;
string otstring="AO3BOT";
bool order41=false;
int Norders;
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
   StopLossPoints4=NormPoints(StopLoss4*10);
   TakeProfitPoints4=NormPoints(TakeProfit4*10);     
   TrailStopPoints=NormPoints(TrailStop*10);
   EntryLongPoints=NormPoints(EntryLong*10);
   EntryShortPoints=NormPoints(EntryShort*10);
   pendingbufferpoints=NormPoints(pendingbuffer*10);
   modifybufferpoints=NormPoints(modifybuffer*10);
  }
  else
  {
   StopLossPoints=NormPoints(StopLoss);
   TakeProfitPoints=NormPoints(TakeProfit); 
   StopLossPoints4=NormPoints(StopLoss4);
   TakeProfitPoints4=NormPoints(TakeProfit4);   
   TrailStopPoints=NormPoints(TrailStop);
   EntryLongPoints=NormPoints(EntryLong);
   EntryShortPoints=NormPoints(EntryShort);
   pendingbufferpoints=NormPoints(pendingbuffer); 
   modifybufferpoints=NormPoints(modifybuffer); 
  }  
 }
 else
 {
  if(Digits==5)
  {
   StopLossPoints=NormPoints(StopLoss*10);
   TakeProfitPoints=NormPoints(TakeProfit*10);
   StopLossPoints4=NormPoints(StopLoss4*10);
   TakeProfitPoints4=NormPoints(TakeProfit4*10);   
   TrailStopPoints=NormPoints(TrailStop*10);
   EntryLongPoints=NormPoints(EntryLong*10);
   EntryShortPoints=NormPoints(EntryShort*10); 
   pendingbufferpoints=NormPoints(pendingbuffer*10); 
   modifybufferpoints=NormPoints(modifybuffer*10);   
  }
  else
  {
   StopLossPoints=NormPoints(StopLoss);
   TakeProfitPoints=NormPoints(TakeProfit); 
   StopLossPoints4=NormPoints(StopLoss4);
   TakeProfitPoints4=NormPoints(TakeProfit4);   
   TrailStopPoints=NormPoints(TrailStop);
   EntryLongPoints=NormPoints(EntryLong);
   EntryShortPoints=NormPoints(EntryShort); 
   pendingbufferpoints=NormPoints(pendingbuffer);
   modifybufferpoints=NormPoints(modifybuffer);       
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

 Magic=1;
 Magic41=41;
 Magic42=42;
 
 triggered=false;
 if(CheckNumberOrder()>0) triggered=true; 
 
 if(IsTesting()) 
 {
  semaphorestring="SEMAPHORETEST";
  otstring="AO3BOTTEST";
  order42moveSL=StringConcatenate("ORDER42MOVESLTEST ",Symbol()," ",timename);
 }
 else            
 {
  semaphorestring="SEMAPHORE";
  otstring="AO3BOT";
  order42moveSL=StringConcatenate("ORDER42MOVESL ",Symbol()," ",timename);
 }
  
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
 if(IsTesting()) 
 {
  GlobalVariableDel(semaphorestring);
  GlobalVariableDel(otstring);
  GlobalVariableDel(order42moveSL);
 }
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
 if(CheckTime()) return;
 
 if(iBarShift(NULL,0,ot)==0) return; // avoid same bar re-orders 
 
 double SL,TP,price;
 string td;
 int ticket;

 if(Trigger(true))
 {
  price=EntryPrice(true);
    
  if(price<=NormDigits(Ask+pendingbufferpoints)) 
  {
   if(PMOption==4)
   {
    SL=StopLong(Ask,StopLossPoints4);
    TP=TakeLong(Ask,TakeProfitPoints4); 
    ticket=SendOrderLong(Symbol(),DetermineLots(Ask,SL),Slippage,SL,TP,comment,Magic41); 
    TP=NormDigits(0); 
    ticket=SendOrderLong(Symbol(),DetermineLots(Ask,SL),Slippage,SL,TP,comment,Magic42); 
    SetOrder42MoveSLFlag(0);  
   }
   else   
   {
    SL=StopLong(Ask,StopLossPoints);
    if(PMOption==2) TP=NormDigits(0);
    else            TP=TakeLong(Ask,TakeProfitPoints); 
    ticket=SendOrderLong(Symbol(),DetermineLots(Ask,SL),Slippage,SL,TP,comment,Magic);
   }
  }
  else           
  {
   if(PMOption==4)
   {
    SL=StopLong(price,StopLossPoints4);  
    TP=TakeLong(price,TakeProfitPoints4);
    ExpireTime=ExpirePending();
    ticket=SendPending(Symbol(),OP_BUYSTOP,price,DetermineLots(price,SL),Slippage,SL,TP,comment,Magic41,ExpireTime,Blue);   
    TP=NormDigits(0); 
    ticket=SendPending(Symbol(),OP_BUYSTOP,price,DetermineLots(price,SL),Slippage,SL,TP,comment,Magic42,ExpireTime,Blue);   
    SetOrder42MoveSLFlag(0);
   }
   else
   {   
    SL=StopLong(price,StopLossPoints);  
    if(PMOption==2) TP=NormDigits(0);
    else            TP=TakeLong(price,TakeProfitPoints);
    ExpireTime=ExpirePending();
    ticket=SendPending(Symbol(),OP_BUYSTOP,price,DetermineLots(price,SL),Slippage,SL,TP,comment,Magic,ExpireTime,Blue);
   }
  }
  
  if(ticket>0)
  {
   ot=TimeCurrent();
   if(!GlobalVariableCheck(otstring)) GlobalVariableSet(otstring,ot);
   td=TimeToStr(ot,TIME_DATE|TIME_MINUTES);
   Alert("AO3B submitted long: ",Symbol()," M",Period()," at ",td,", price: ",price);
   triggered=true; 
  }
  else
  {
   Alert("AO3B FAILED long: ",Symbol()," M",Period()," at ",td,", price: ",price);
  } 
 } 
 
 if(Trigger(false))
 {
  price=EntryPrice(false);

  if(price>=NormDigits(Bid-pendingbufferpoints)) 
  {
   if(PMOption==4)
   {
    SL=StopShort(Bid,StopLossPoints4);
    TP=TakeShort(Bid,TakeProfitPoints4);
    ticket=SendOrderShort(Symbol(),DetermineLots(SL,Bid),Slippage,SL,TP,comment,Magic41);
    TP=NormDigits(0);
    ticket=SendOrderShort(Symbol(),DetermineLots(SL,Bid),Slippage,SL,TP,comment,Magic42);       
    SetOrder42MoveSLFlag(0);
   }
   else   
   {  
    SL=StopShort(Bid,StopLossPoints);
    if(PMOption==2) TP=NormDigits(0);
    else            TP=TakeShort(Bid,TakeProfitPoints);
    ticket=SendOrderShort(Symbol(),DetermineLots(SL,Bid),Slippage,SL,TP,comment,Magic);
   }
  }
  else           
  {
   if(PMOption==4)
   {
    SL=StopShort(price,StopLossPoints4);
    TP=TakeShort(price,TakeProfitPoints4);
    ExpireTime=ExpirePending();  
    ticket=SendPending(Symbol(),OP_SELLSTOP,price,DetermineLots(SL,price),Slippage,SL,TP,comment,Magic41,ExpireTime,Red);   
    TP=NormDigits(0);
    ticket=SendPending(Symbol(),OP_SELLSTOP,price,DetermineLots(SL,price),Slippage,SL,TP,comment,Magic42,ExpireTime,Red);
    SetOrder42MoveSLFlag(0);
   }
   else   
   {  
    SL=StopShort(price,StopLossPoints);
    if(PMOption==2) TP=NormDigits(0);
    else            TP=TakeShort(price,TakeProfitPoints);
    ExpireTime=ExpirePending();  
    ticket=SendPending(Symbol(),OP_SELLSTOP,price,DetermineLots(SL,price),Slippage,SL,TP,comment,Magic,ExpireTime,Red);   
   }
  } 
  
  if(ticket>0)
  {
   ot=TimeCurrent();
   if(!GlobalVariableCheck(otstring)) GlobalVariableSet(otstring,ot);
   td=TimeToStr(ot,TIME_DATE|TIME_MINUTES);
   Alert("AO3B submitted short: ",Symbol()," M",Period()," at ",td,", price: ",price);
   triggered=true;
  }
  else
  {
   Alert("AO3B FAILED short: ",Symbol()," M",Period()," at ",td,", price: ",price);
  }
 } 

 return; 
}
//+------------------------------------------------------------------+
void ManageOrders()
{ 
 triggered=false;
 Norders=CheckNumberOrder(); // also sets Order41 status
 
 int trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 { 
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderMagicNumber()==Magic||OrderMagicNumber()==Magic41||OrderMagicNumber()==Magic42)
  {
   triggered=true;
   PositionManagement(); 
  }
 }
 return;
}
//+------------------------------------------------------------------+
void PositionManagement()
{

 if(PMOption==4)
 {
  if(!order41)
  {
   if(GetOrder42MoveSLFlag()==0) 
   {
    TrailingStop(0,true); // this bar 
    SetOrder42MoveSLFlag(1);
   }
  }
 }
 
 if(lasttime==iTime(NULL,0,0)) return(0);

 CancelPending();

 if(PMOption==4)
 {
  if(!order41) TRENDTrailingStop();
 }
 else
 {
  if(iBarShift(NULL,0,OrderOpenTime())<PMBar-3) return;
 
  if(PMOption==1) ExitOrder(true,true);
  else            TrailingStop();
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
  Print(" New Price: ", DoubleToStr(price,Digits), " New S/L ", DoubleToStr(sl,Digits), " New T/P ", DoubleToStr(tp,Digits), " New Expiration ", exp);
 }
 ReleaseSemaphore();
}
//+------------------------------------------------------------------+
void ModifyCompLong(double stopcal, double stopcrnt, bool force=false)
{
 stopcal=NormDigits(stopcal);
 stopcrnt=NormDigits(stopcrnt);

 if (stopcal==stopcrnt) return;
 
 if(force||stopcal>stopcrnt) ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Blue); 
 return;
}
//+------------------------------------------------------------------+
void ModifyCompShort(double stopcal, double stopcrnt, bool force=false)
{
 stopcal=NormDigits(stopcal);
 stopcrnt=NormDigits(stopcrnt);

 if (stopcal==stopcrnt) return;
  
 if(force||(stopcal<stopcrnt&&stopcal!=0)||stopcrnt==0) ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red); 
 return;
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
void CancelPending() // just in case tagged expiration time failed & kill mid-bar submissions at start of new bar
{
 if(iBarShift(NULL,0,ot)==1) ExitOrder(true,true,2);
}
//+------------------------------------------------------------------+
datetime ExpirePending()
{
 return(TimeCurrent()+(Period()*60));
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
void SetOrder42MoveSLFlag(double value)
{
 GlobalVariableSet(order42moveSL,value);
 return;
}
//+------------------------------------------------------------------+
double GetOrder42MoveSLFlag()
{
 return(GlobalVariableGet(order42moveSL)); 
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
 if(lots<lotsmin)      return(NormalizeDouble(lotsmin,lotsprecision));
 else if(lots>lotsmax) return(NormalizeDouble(lotsmax,lotsprecision));
 else                  return(NormalizeDouble(lots,lotsprecision));}
//+------------------------------------------------------------------+
double DetermineLots(double value1, double value2)  // function to determine lot sizes based on available free margin
{
 double risk;

 if(PMOption==4) risk=Risk4;
 else            risk=Risk;
 
 double permitLoss=risk*AccountFreeMargin();
 double tickSL=(value1-value2)/Point;
 double valueSL=tickSL*MarketInfo(Symbol(),MODE_TICKVALUE);
 
 return(Divide(permitLoss,valueSL));
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
   if((OrderType()==OP_BUYSTOP)&&flag_Long)
    OrderDelete(OrderTicket());
   else if((OrderType()==OP_SELLSTOP)&&flag_Short)
    OrderDelete(OrderTicket());
   break;  
 }
 return;
}
//+------------------------------------------------------------------+
double TakeLong(double price,double take)  // function to calculate takeprofit if long
{
 return(NormDigits(price+take)); 
}
//+------------------------------------------------------------------+
double TakeShort(double price,double take)  // function to calculate takeprofit if short
{
 return(NormDigits(price-take)); 
}
//+------------------------------------------------------------------+
double StopShort(double price,double stop) // function to calculate normal stoploss if short
{
 return(NormDigits(price+stop)); 
}
//+------------------------------------------------------------------+
double StopLong(double price,double stop) // function to calculate normal stoploss if long
{
 return(NormDigits(price-stop)); 
}
//+------------------------------------------------------------------+
void TrailingStop(int i=1,bool force=false) // force to deactivate requirement that stop be more protective (PMOption 4's move O#2 SL after O#1 TP)
{
 double stopcrnt,stopcal; 
 stopcrnt=OrderStopLoss(); 

//Long               
 if(OrderType()==OP_BUY)
 {
  stopcal=TrailLong(iLow(NULL,0,i),TrailStopPoints);

  if(stopcal>=NormDigits(Bid-modifybufferpoints)) // check whether s/l is too close to market
   stopcal=NormDigits(Bid-modifybufferpoints);

  ModifyCompLong(stopcal,stopcrnt,force);   
 }    
//Short 
 else if(OrderType()==OP_SELL)
 {  
  stopcal=TrailShort(iHigh(NULL,0,i),TrailStopPoints);

  if(stopcal<=NormDigits(Ask+modifybufferpoints)) // check whether s/l is too close to market
   stopcal=NormDigits(Ask+modifybufferpoints);
  
  ModifyCompShort(stopcal,stopcrnt,force);
 } 
 return;
}
//+------------------------------------------------------------------+
double TrailLong(double price,double trail)
{
 return(NormDigits(price-trail)); 
}
//+------------------------------------------------------------------+
double TrailShort(double price,double trail)
{
 return(NormDigits(price+trail)); 
}
//+------------------------------------------------------------------+
void TRENDTrailingStop(int i=1) // special TREND trail
{
 double stopcrnt,stopcal; 
 stopcrnt=OrderStopLoss(); 

//Long               
 if(OrderType()==OP_BUY)
 {
  if(!TREND(true)) return;
  stopcal=TrailLong(iLow(NULL,0,i),TrailStopPoints);

  if(stopcal>=NormDigits(Bid-modifybufferpoints)) // check whether s/l is too close to market
   stopcal=NormDigits(Bid-modifybufferpoints);

  ModifyCompLong(stopcal,stopcrnt);   
 }    
//Short 
 else if(OrderType()==OP_SELL)
 {  
  if(!TREND(false)) return;
  stopcal=TrailShort(iHigh(NULL,0,i),TrailStopPoints);

  if(stopcal<=NormDigits(Ask+modifybufferpoints)) // check whether s/l is too close to market
   stopcal=NormDigits(Ask+modifybufferpoints);
  
  ModifyCompShort(stopcal,stopcrnt);
 } 
 return;
}
//+------------------------------------------------------------------+
int CheckNumberOrder() // check number of open orders in account by EA
{
 order41=false;
 int trade,trades=OrdersTotal(),total=0; 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderMagicNumber()==Magic||OrderMagicNumber()==Magic41||OrderMagicNumber()==Magic42)
  {
   if(OrderMagicNumber()==Magic41) order41=true;
   ot=GlobalVariableGet(otstring);
   total++;
  }
 }
 return(total);
}
//+------------------------------------------------------------------+
double EntryPrice(bool long)
{
 double price;
 if(long)
 {
  price=NormDigits(iHigh(NULL,0,1)+EntryLongPoints);
  price/=Point;
  if(MathMod(price,10)!=0&&MathMod(price,5)==0) // ends in 5
  {
   price+=pricemodifier;
   price*=Point;
  } 
  else 
  {
   price*=0.1;
   price=MathRound(price);
   price*=10*Point;
  }
 }
 else
 {
  price=NormDigits(iLow(NULL,0,1)-EntryShortPoints);
  price/=Point;
  if(MathMod(price,10)!=0&&MathMod(price,5)==0) // ends in 5
  {
   price-=pricemodifier;
   price*=Point;
  }
  else 
  {
   price*=0.1;
   price=MathRound(price); 
   price*=10.0*Point;
  } 
 }
 return(NormDigits(price));
}
//+------------------------------------------------------------------+
bool CheckTime()
{
 int timehour=TimeHour(iTime(NULL,0,0)); 
 if(StartHour<EndHour)
 {
  if(timehour<StartHour || timehour>EndHour) return(true);
 }
 else
 {
  if(timehour<StartHour && timehour>EndHour) return(true);
 }

 int timeminute=TimeMinute(iTime(NULL,0,0));
 if(timehour==StartHour && timeminute<StartMin) return(true);
 if(timehour==EndHour && timeminute>EndMin) return(true); // timeminute>EndMin to allow a possible trade at EndMin
 
 return(false);
}
//+------------------------------------------------------------------+
bool Trigger(bool long)
{
 if(long)
 {
  if(iAO(NULL,0,1)>0)
  {
   if(iClose(NULL,0,1)<iOpen(NULL,0,1)&&iClose(NULL,0,2)<iOpen(NULL,0,2))
   {
    if(iClose(NULL,0,1)<iLow(NULL,0,2)) return(true);
   }
  }
 }
 else
 {
  if(iAO(NULL,0,1)<0)
  {
   if(iClose(NULL,0,1)>iOpen(NULL,0,1)&&iClose(NULL,0,2)>iOpen(NULL,0,2))
   {
    if(iClose(NULL,0,1)>iHigh(NULL,0,2)) return(true);
   }
  } 
 }
 return(false);
}
//+------------------------------------------------------------------+
double Divide(double v1, double v2)
{
 if(v2!=0) return(v1/v2);
 else      return(0.0);
}
//+------------------------------------------------------------------+
bool TREND(bool long)
{
 double spanthird;
 double close=iClose(NULL,0,1);
 double open=iOpen(NULL,0,1);
 double high=iHigh(NULL,0,1);
 double low=iLow(NULL,0,1);
 if(long)
 {
  if(close>open)
  {
   spanthird=NormDigits(Divide((high-low),3.0));
   if(open<=NormDigits(low+spanthird)&&close>=NormDigits(high-spanthird)) return(true);
  }
 }
 else
 {
  if(close<open)
  {
   spanthird=NormDigits(Divide((high-low),3.0));
   if(open>=NormDigits(high-spanthird)&&close<=NormDigits(low+spanthird)) return(true);
  } 
 }
 return(false);
}
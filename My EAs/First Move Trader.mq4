//+----------------------------------------------------------------------+
//|                                                First Move Trader.mq4 |
//|                                                         David J. Lin |
//|Catches the first move of the trading session                         |
//|Written for Jason Hughes <Jasonhughes3@aol.com>                       |
//|                                                                      |
//|Coded by David J. Lin (dave.j.lin@sbcglobal.net)                      |                                      |
//|Evanston, IL, November 16, 2007                                       |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2007, Jason Hughes & David J. Lin"
#property link      ""

// User adjustable parameters:
extern int StartHour=5;              // platform hour at which to begin tracking prices
extern int ExitHour=13;              // platform hour at which to exit day's trade if still open 
extern int TriggerPips=15;           // pips move from open price at which to enter trade
extern int TakeProfit=40;            // pips desired TP
extern int StopLoss=15;              // pips desired SL
extern int SLProfit=15;              // pips profit after which to move SL  (use negative number if not desired)
extern int SLMove=0;                 // pips to move SL to BE+SLMove after SLProfit is reached
extern bool FixedLots =true;        // true = use fixed number of lottage as specified by FixedLottage, false = use PercentRisk
extern double FixedLottage =0.01;    // fixed number of lots per trade (used if FixedLots=true)
extern double PercentRisk =0.010;    // percentage of account balance at risk per trade (used if FixedLots=false)

// Internal usage parameters:
int Slippage=3,bo=1,magic=432100;
int lotsprecision=2;
double lotsmin,lotsmax;
bool LongOrder,ShortOrder;
string comment="First Move";
color clrL=Blue,clrS=Red;
string strL="Long",strS="Short";
int code=1;
int Norders;
datetime ot,lasttime;
bool noRun=false;
int TimeCheck;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//----
 
 lotsmin=MarketInfo(Symbol(),MODE_MINLOT); 
 lotsmax=MarketInfo(Symbol(),MODE_MAXLOT);

 if(lotsmin==0.10) lotsprecision=1;
 
 if(ExitHour>StartHour)      TimeCheck=1;
 else if(ExitHour<StartHour) TimeCheck=2;
 else 
 {
  Alert("ERROR:  StartHour cannot be equal to ExitHour!!)");
  noRun=true;
  return(-1);
 }

// First check closed trades
 int trade;                         
 int trades=OrdersHistoryTotal();           
 for(trade=0;trade<trades;trade++)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_HISTORY);

  if(OrderSymbol()!=Symbol())
   continue;

  int D1bars=iBarShift(NULL,PERIOD_D1,OrderCloseTime(),false);
  if(D1bars>30)
   continue;
   
  Status(OrderMagicNumber());
 }

// Now check open orders
                       
 trades=OrdersTotal();           
 for(trade=0;trade<trades;trade++)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()!=Symbol())
   continue;

  Status(OrderMagicNumber());
  if(OrderType()==OP_BUY)       DrawCross(OrderOpenPrice(),OrderOpenTime(),strL,clrL,code);
  else if(OrderType()==OP_SELL) DrawCross(OrderOpenPrice(),OrderOpenTime(),strS,clrS,code);
 }
 
 HideTestIndicators(true);
 ManageOrders();
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
//---- 
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
//----
 if(noRun) return(-1);
 SubmitOrders();  
 ManageOrders();
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert utility functions                                         |
//+------------------------------------------------------------------+

void SubmitOrders()
{    
 double lots,SL,TP; 
 bool LongTrigger=false,ShortTrigger=false;
 
 int i,checktime=iBarShift(NULL,PERIOD_D1,ot,false); // 1 trade per day
 if(checktime<bo) return;

 switch(TimeCheck)
 {
  case 1:
   if(Hour()<StartHour||Hour()>=ExitHour) return;  
  break;
  case 2:
   if(Hour()<StartHour&&Hour()>=ExitHour) return;
  break;
 }

 int Dtime=iTime(NULL,PERIOD_D1,0)+(StartHour*3600)+(Period()*60); // delay by 1 bar for high/low analysis
 double targetprice;

 int shift=iBarShift(NULL,0,Dtime,false); 
 int shiftH=iHighest(NULL,0,MODE_HIGH,shift,1);
 int shiftL=iLowest(NULL,0,MODE_LOW,shift,1);
 double highprice=iHigh(NULL,0,shiftH);
 double lowprice =iLow(NULL,0,shiftL);

 if(LongOrder)
 {
  targetprice=NormDigits(highprice-NormPoints(TriggerPips)); 
  if(Bid<=targetprice&&Bid>NormDigits(targetprice-NormPoints(1)))  
  {
   SL=StopLong(Ask,StopLoss);
   lots=DetermineLots(Ask,SL,1);   
   TP=TakeLong(Ask,TakeProfit);
   SendOrderLong(Symbol(),lots,Slippage,SL,TP,comment,magic,0,Blue);
   ot=TimeCurrent();
  }
 } 

 if(ShortOrder)
 {
  targetprice=NormDigits(lowprice+NormPoints(TriggerPips));  
  if(Bid>=targetprice&&Bid<NormDigits(targetprice+NormPoints(1)))
  {   
   SL=StopShort(Bid,StopLoss);
   lots=DetermineLots(SL,Bid,1); 
   TP=TakeShort(Bid,TakeProfit);
   SendOrderShort(Symbol(),lots,Slippage,SL,TP,comment,magic,0,Red);  
   ot=TimeCurrent();
  }
 }
 
 return;
}

//+------------------------------------------------------------------+

void ManageOrders()
{
 LongOrder=true;
 ShortOrder=true;
 Norders=0;
 double profit=0;
 int i,j,trail,trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderMagicNumber()!=magic) continue;    

  ExitOrder();

  if(OrderType()==OP_BUY)
  {
   LongOrder=false;  
   Norders++; 
  }
  else if(OrderType()==OP_SELL)
  {
   ShortOrder=false;
   Norders++;
  }
  
  if(SLProfit>0) 
  {
   FixedStopsB(SLProfit,SLMove);
  }
 } 
 return;
}
//===========================================================================================
//===========================================================================================
void ExitOrder()
{
 switch(TimeCheck)
 {
  case 1:
   if(Hour()>=StartHour&&Hour()<ExitHour) return;
  break;
  case 2:
   if(Hour()>=StartHour||Hour()<ExitHour) return;
  break;
 }
 
 if(OrderType()==OP_BUY)
 {
  CloseOrderLong(OrderTicket(),OrderLots(),Slippage,Lime);
 }
 else if(OrderType()==OP_SELL)
 {
  CloseOrderShort(OrderTicket(),OrderLots(),Slippage,Lime);
 }
 return;
}
//+------------------------------------------------------------------+

int SendOrderLong(string sym, double vol, int slip, double sl, double tp, string comment="", int m=0, datetime exp=0, color cl=CLR_NONE)
{  
 if(vol==0.00) return;
 int err;
 bool attempt=true;
 while(attempt)
 {
  if(IsTradeAllowed())
  {
   for(int z=0;z<5;z++)
   {  
    if(OrderSend(sym,OP_BUY,NormLots(vol),Ask,slip,NormDigits(sl),NormDigits(tp),comment,m,exp,cl)<0)
    {  
     err = GetLastError();
     Print("OrderSend Long failed, Error: ", err);
     Print("Ask: ", Ask, " S/L ", sl, " T/P ", tp);
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
 return(0);
}
//+------------------------------------------------------------------+

int SendOrderShort(string sym, double vol, int slip, double sl, double tp, string comment="", int m=0, datetime exp=0, color cl=CLR_NONE)
{  
 if(vol==0.00) return;
 int err;
 bool attempt=true;
 while(attempt)
 {
  if(IsTradeAllowed())
  {
   for(int z=0;z<5;z++)
   {  
    if(OrderSend(sym,OP_SELL,NormLots(vol),Bid,slip,NormDigits(sl),NormDigits(tp),comment,m,exp,cl)<0)
    {  
     err = GetLastError();
     Print("OrderSend Short failed, Error: ", err);
     Print("Bid: ", Bid, " S/L ", sl, " T/P ", tp);   
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
 return(0);
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

void FixedStopsB(int PP,int PFS)
{
  if(PFS<0) return;

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
 if(take<0) return(0.0);

 return(NormDigits(price+NormPoints(take))); 
}
//+------------------------------------------------------------------+
double TakeShort(double price,int take)  // function to calculate takeprofit if short
{
 if(take<0) return(0.0); // if no take profit
 return(NormDigits(price-NormPoints(take))); 
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
void Status(int mn)
{   
 if(mn==magic) ot=OrderOpenTime();
 return;
}
//+------------------------------------------------------------------+
void DrawCross(double price, int time1, string str, color clr, int code)
{
 string name=StringConcatenate(str,time1);
 ObjectDelete(name);  
 ObjectCreate(name,OBJ_ARROW,0,time1,price);
 ObjectSet(name,OBJPROP_COLOR,clr);
 ObjectSet(name,OBJPROP_ARROWCODE,code); 
 ObjectSet(name,OBJPROP_WIDTH,1);
 return;
}
//+------------------------------------------------------------------+
double DetermineLots(double value1, double value2, double number)  // function to determine lot sizes based on account balance
{
 if(FixedLots) return(FixedLottage);
 if(value1<=0||value2<=0) return(lotsmin);
 
 double permitLoss=PercentRisk*AccountBalance();
 double pipSL=(value1-value2)/Point;
 double valueSL=pipSL*MarketInfo(Symbol(),MODE_TICKVALUE);
 
 double lots=permitLoss/valueSL;
 lots/=number;
 
 if(lots<lotsmin) return(lotsmin);
 else if(lots>lotsmax) return(lotsmax);
 
 return(lots);
}
//+------------------------------------------------------------------+
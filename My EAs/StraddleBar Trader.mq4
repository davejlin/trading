//+----------------------------------------------------------------------+
//|                                               StraddleBar Trader.mq4 |
//|                                                         David J. Lin |
//|Based a straddle strategy by Sam Moore                                |
//|Written for Sam Moore <skmoore@lcturbonet.com>                        |
//|                                                                      |
//|Coded by David J. Lin (dave.j.lin@sbcglobal.net)                      |
//|Evanston, IL, January 21, 2008                                        |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2008, Sam Moore & David J. Lin"
#property link      ""

// User adjustable parameters:
extern double Lots=0.01;             // lottage per trade
extern int Straddle=38;              // pips for straddle based on previous bar's close 
extern int ReEntry=17;               // pips from previous bar's close at which to re-enter complete straddle (use negative number if no re-entry is desired)
extern int StopLoss=28;              // pips initial SL 
extern int SLProfit1=13;             // pips profit after which to move SL (#1) (enter negative value to disable)
extern int SLMove1=4;                // pips to move SL to BE+SLMove after SLProfit is reached (#1)
extern int SLProfit2=20;             // pips profit after which to move SL (#2) (enter negative value to disable)
extern int SLMove2=10;               // pips to move SL to BE+SLMove after SLProfit is reached (#2)
extern int SLProfit3=30;             // pips profit after which to move SL (#3) (enter negative value to disable)
extern int SLMove3=18;               // pips to move SL to BE+SLMove after SLProfit is reached (#3)
extern int TSProfit=50;              // pips profit at which to begin trail (pip-by-pip) (enter negative value to disable)
extern int TSMove=5;                 // pips desired trailing stop, engages after TSProfit is hit (should equal TSProfit-SLMove3 for pip-by-pip trail)


// Internal usage parameters:
int Slippage=3,magic;
int lotsprecision=2;
double lotsmin,lotsmax;
bool LongOrder,ShortOrder,LongPendOrder,ShortPendOrder;
bool ReEntryLFlag,ReEntrySFlag;
string comment;
color clrL=Blue,clrS=Red;
string strL="StraddleBar Long",strS="StraddleBar Short";
int code=1;
datetime ot,lasttime;
double close,ReEntryH,ReEntryL;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//----

 lotsmin=MarketInfo(Symbol(),MODE_MINLOT); 
 lotsmax=MarketInfo(Symbol(),MODE_MAXLOT);

 if(lotsmin==0.10) lotsprecision=1;

 magic  =10000+Period(); 
 
 string pd;
 switch(Period())
 {
  case 1:     pd="M1"; break;
  case 5:     pd="M5"; break;
  case 15:    pd="M15";break;
  case 30:    pd="M30";break;
  case 60:    pd="H1"; break;
  case 240:   pd="H4"; break;
  case 1440:  pd="D1"; break;
  case 10080: pd="W1"; break;
  case 40320: pd="M1"; break;
  default:    pd="Unknown";break;
 }
 comment  =StringConcatenate(pd," StraddleBar"); 

// First check closed trades
 int trade;                         
 int trades=OrdersHistoryTotal();           
 for(trade=0;trade<trades;trade++)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_HISTORY);

  if(OrderSymbol()!=Symbol()) continue;

  if(OrderMagicNumber()!=magic) continue;

  int D1bars=iBarShift(NULL,PERIOD_D1,OrderCloseTime(),false);
  if(D1bars>30) continue;
   
  Status(OrderMagicNumber());
 }

// Now check open orders
                       
 trades=OrdersTotal();           
 for(trade=0;trade<trades;trade++)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()!=Symbol()) continue;

  if(OrderMagicNumber()!=magic) continue;

  Status(OrderMagicNumber());
  
       if(OrderType()==OP_BUY||OrderType()==OP_BUYSTOP)   DrawCross(OrderOpenPrice(),OrderOpenTime(),strL,clrL,code);
  else if(OrderType()==OP_SELL||OrderType()==OP_SELLSTOP) DrawCross(OrderOpenPrice(),OrderOpenTime(),strS,clrS,code);
 }
 
 HideTestIndicators(true);
 
 CheckReEntry();
 ManageOrders(); // must be after CheckReEntry 

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
 SubmitOrders();
 
 CheckReEntry(); 
 ManageOrders(); // must be after CheckReEntry

 NewBarReset();
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert utility functions                                         |
//+------------------------------------------------------------------+

void SubmitOrders()
{
 double SL,EntryPrice; 
 
 if(lasttime!=iTime(NULL,0,0))
 { 
  close=iClose(NULL,0,1);   
  double priceH=NormDigits(close+NormPoints(Straddle-1));
  double priceL=NormDigits(close-NormPoints(Straddle+1));
  if(Bid<=priceH&&Bid>=priceL) // new bar straddle, make sure there's legitimate price entry window if EA started off-bar 
  {
   if(LongPendOrder||(!LongPendOrder&&close!=iClose(NULL,0,2))) // avoid identical re-entries if pre-existing
   {
    EntryPrice=NormDigits(close+NormPoints(Straddle)+(Ask-Bid));
    SL=StopLong(EntryPrice,StopLoss);
    SendPending(Symbol(),OP_BUYSTOP,Lots,EntryPrice,Slippage,SL,0,comment,magic,0,Blue);
    ot=TimeCurrent();     
   }
   if(ShortPendOrder||(!ShortPendOrder&&close!=iClose(NULL,0,2))) // avoid identical re-entries if pre-existing
   {
    EntryPrice=NormDigits(close-NormPoints(Straddle));   
    SL=StopShort(EntryPrice,StopLoss);
    SendPending(Symbol(),OP_SELLSTOP,Lots,EntryPrice,Slippage,SL,0,comment,magic,0,Red);
    ot=TimeCurrent();     
   }
  }
  if(ReEntry>=0) // calculate re-entry values: only need to do once per bar 
  {
   ReEntryH=NormDigits(close+NormPoints(ReEntry));
   ReEntryL=NormDigits(close-NormPoints(ReEntry));
  }   
 }
 else if(ReEntry>=0)
 {
  if(Bid<=ReEntryH&&Bid>=ReEntryL)
  { 
   if(LongPendOrder&&ReEntryLFlag)
   {
    close=iClose(NULL,0,1);    
    EntryPrice=NormDigits(close+NormPoints(Straddle)+(Ask-Bid));
    SL=StopLong(EntryPrice,StopLoss);
    SendPending(Symbol(),OP_BUYSTOP,Lots,EntryPrice,Slippage,SL,0,comment,magic,0,Blue);
    ot=TimeCurrent();   
   }
   if(ShortPendOrder&&ReEntrySFlag)
   {
    close=iClose(NULL,0,1);    
    EntryPrice=NormDigits(close-NormPoints(Straddle));   
    SL=StopShort(EntryPrice,StopLoss);
    SendPending(Symbol(),OP_SELLSTOP,Lots,EntryPrice,Slippage,SL,0,comment,magic,0,Red);
    ot=TimeCurrent();
   }
  }
 } 
 return;
}

//+------------------------------------------------------------------+
void ManageOrders()
{
 LongOrder=true;ShortOrder=true;LongPendOrder=true;ShortPendOrder=true; 
 double profit;
 int trail,trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderMagicNumber()!=magic) continue;  

       if(OrderType()==OP_BUY)
       {       
        LongOrder=false;
        if(OrderOpenTime()>=lasttime) ReEntryLFlag=false; // don't re-enter if existing open (after current bar start) is currently in play  
       }       
  else if(OrderType()==OP_SELL)
       {
        ShortOrder=false;
        if(OrderOpenTime()>=lasttime) ReEntrySFlag=false; // don't re-enter if existing open (after current bar start) is currently in play  
       } 
  else if(OrderType()==OP_BUYSTOP)  LongPendOrder=false;  
  else if(OrderType()==OP_SELLSTOP) ShortPendOrder=false;
  
  profit=DetermineProfit();
  
  if(TSProfit>0)
  {
   if(profit>=NormPoints(TSProfit)) TrailingStop(TSMove);
  }
  
  if(SLProfit3>0)
  {
   if(profit>=NormPoints(SLProfit3)) FixedStopsB(SLProfit3,SLMove3);   
  }

  if(SLProfit2>0)
  {
   if(profit>=NormPoints(SLProfit2)) FixedStopsB(SLProfit2,SLMove2);  
  }
  
  if(SLProfit1>0)
  {
   if(profit>=NormPoints(SLProfit1)) FixedStopsB(SLProfit1,SLMove1);
  }
 
 } 
 return;
}
//+------------------------------------------------------------------+
void CheckReEntry()
{
 if(ReEntry<0) return;
 ReEntryLFlag=false; ReEntrySFlag=false;
  
 int trail,trade,trades=OrdersHistoryTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_HISTORY);
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderMagicNumber()!=magic) continue;  
  if(OrderOpenTime()<lasttime) return;

  if(OrderOpenTime()>=lasttime&&OrderCloseTime()>=lasttime) 
  {
   if(OrderType()==OP_BUY)       
   {
    ReEntryLFlag=true;
    return;
   }
   else if(OrderType()==OP_SELL) 
   {
    ReEntrySFlag=true;
    return;
   }
  }
 } 
 return;
}
//+------------------------------------------------------------------+
void NewBarReset()
{
 if(lasttime==iTime(NULL,0,0)) return;
 lasttime=iTime(NULL,0,0);
 return;
}
//+------------------------------------------------------------------+
int SendPending(string sym, int type, double vol, double price, int slip, double sl, double tp, string comment="", int magic=0, datetime exp=0, color cl=CLR_NONE)
{
 if(vol<=0) return(0);
 price=NormDigits(price);
 sl=NormDigits(sl);
 tp=NormDigits(tp);
 
 int ticket, err; 
 
 int ordernumber=CheckExistingPendings(type,magic,price,sl,tp,exp);
 if(ordernumber<0) return(0);
 
 bool attempt=true;
 while(attempt)
 { 
  if(IsTradeAllowed())
  { 
   for(int z=0;z<5;z++)
   {    
    if(ordernumber==0)
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
    else
    {
     if(ModifyOrder(ordernumber,NormDigits(price),NormDigits(sl),NormDigits(tp),exp,cl)==true)
     {
      attempt=false;
      break;
     }
    }
   }
  }
 }
 return(ticket);
}
//+------------------------------------------------------------------+
int CheckExistingPendings(int type, int magic, double price, double sl, double tp, datetime exp)
{
 int trade;
 int trades=OrdersTotal(); 
 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
     
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderMagicNumber()!=magic) continue;
  if(OrderType()!=type) continue;
  
  if(OrderOpenPrice()==price&&OrderStopLoss()==sl&&OrderTakeProfit()==tp&&OrderExpiration()==exp) return(-1);
  else return(OrderTicket());
 }
 return(0);
}
//+------------------------------------------------------------------+
void FixedStopsB(int PP,int PFS)
{
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
    if(GetLastError()>4000) return(false);
    RefreshRates();    
   }
   else return(true);
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
 {
  return(Bid-OrderOpenPrice());
 } 
 else if(OrderType()==OP_SELL)
 { 
  return(OrderOpenPrice()-Ask); 
 }
 return(0);
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
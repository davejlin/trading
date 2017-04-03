//+----------------------------------------------------------------------+
//|                                                   Pin Bar Trader.mq4 |
//|                                                         David J. Lin |
//|Based on a strategy using Pin Bars                                    |
//|Written for William (Brian) Watson <bwatson10@alltel.net>             |
//|                                                                      |
//|Coded by David J. Lin (dave.j.lin@sbcglobal.net)                      |
//|Evanston, IL, October 19-21                                           |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2007, William Watson & David J. Lin"
#property link      ""

// User adjustable parameters:
extern int Min_Nose_Ratio=60;        // pin bar minimum nose ratio
extern int Max_Body_Ratio=40;        // pin bar maximum body raio
extern double TradeRisk=2.5;         // percentage risk of account balance to calculate lottage per trade 
extern int AccountMaxTrades=5;       // maximum number of Pin Bar Trader orders in entire account 
extern int TakeProfit=200;           // pips desired TP (use negative number if no TP is desired)
extern int TrailStopBegin=30;        // pips profit after which to begin trail  (use negative number if no trail is desired)
extern int TrailStopATRPeriod=20;    // ATR period for trailing stop, engages after TrailStopBegin is hit
extern int TrailStopATRFactor=1.5;   // factor of ATR for trailing stop, engages after TrailStopBegin is hit

// Internal usage parameters:
int pend=16;
int Slippage=3,bo=1,magic;
int lotsprecision=2;
double lotsmin,lotsmax;
bool LongOrder,ShortOrder;
string comment;
color clrL=Blue,clrS=Red;
string strL="Long",strS="Short";
int code=1;
int NLmax=1,NSmax=1;
int NLorders,NSorders,Norders,TicketBuyStop,TicketSellStop,TicketBuyLimit,TicketSellLimit;
datetime lasttime,otL,otS;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//----
 lotsmin=MarketInfo(Symbol(),MODE_MINLOT); 
 lotsmax=MarketInfo(Symbol(),MODE_MAXLOT);

 if(lotsmin==0.10) lotsprecision=1;

 magic  =400000+Period(); 
 
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
 comment  =StringConcatenate(pd," PBT"); 

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
 if(lasttime!=iTime(NULL,0,0)) 
 {
  SubmitOrders();
 }
 lasttime=iTime(NULL,0,0); 
 ManageOrders();
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert utility functions                                         |
//+------------------------------------------------------------------+

void SubmitOrders()
{    
 double lots,EntryPrice,SL,TP,spread,high,low,mid; 
 bool LongTrigger=false,ShortTrigger=false;
 
 int i,checktime=iBarShift(NULL,0,otL,false);
 if(checktime>=bo)
 {
  if(NLorders<NLmax && Norders<AccountMaxTrades)
  {
   if(CheckPPB(1)>0)
   {
    high=iHigh(NULL,0,1);low=iLow(NULL,0,1);
    spread=Ask-Bid;
    mid=0.5*(high+low);
    EntryPrice=high+spread;
    SL=low;
    lots=DetermineLots(EntryPrice,SL);      
    TP=TakeLong(EntryPrice,TakeProfit);
    if(EntryPrice>Ask) TicketBuyStop=SendPending(Symbol(),OP_BUYSTOP,lots,EntryPrice,Slippage,SL,TP,comment,magic,PendTime(TimeCurrent(),pend),Blue);
    else TicketBuyStop=-1;
    EntryPrice=mid+spread;
    lots=DetermineLots(EntryPrice,SL);     
    TP=TakeLong(EntryPrice,TakeProfit);
    if(EntryPrice<Ask) TicketBuyLimit=SendPending(Symbol(),OP_BUYLIMIT,lots,EntryPrice,Slippage,SL,TP,comment,magic,PendTime(TimeCurrent(),pend),Blue);
    else TicketBuyLimit=-1;
    otL=TimeCurrent();
   } 
  }
 }
 
 checktime=iBarShift(NULL,0,otS,false);
 if(checktime>=bo)
 {
  if(NSorders<NSmax && Norders<AccountMaxTrades)
  {
   if(CheckNPB(1)>0)
   {   
    high=iHigh(NULL,0,1);low=iLow(NULL,0,1);
    spread=Ask-Bid;    
    mid=0.5*(high+low);   
    EntryPrice=low;
    SL=high+spread;  
    lots=DetermineLots(SL,EntryPrice);    
    TP=TakeShort(EntryPrice,TakeProfit); 
    if(EntryPrice<Bid) TicketSellStop=SendPending(Symbol(),OP_SELLSTOP,lots,EntryPrice,Slippage,SL,TP,comment,magic,PendTime(TimeCurrent(),pend),Red); 
    else TicketSellStop=-1;
    EntryPrice=mid;
    lots=DetermineLots(SL,EntryPrice);     
    TP=TakeShort(EntryPrice,TakeProfit);   
    if(EntryPrice>Bid) TicketSellLimit=SendPending(Symbol(),OP_SELLLIMIT,lots,EntryPrice,Slippage,SL,TP,comment,magic,PendTime(TimeCurrent(),pend),Red); 
    else TicketSellLimit=-1;
    otS=TimeCurrent();
   }
  }
 }
 return;
}

//+------------------------------------------------------------------+

void ManageOrders()
{
 NLorders=0; NSorders=0; Norders=0;
 double profit=0;
 int i,j,trail,trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;

  if(OrderType()==OP_BUY)
  {
   NLorders++; Norders++;
   TicketBuyStop=DeleteOrder(TicketBuyStop);
   TicketBuyLimit=DeleteOrder(TicketBuyLimit);
  }
  else if(OrderType()==OP_SELL)
  {
   NSorders++; Norders++;
   TicketSellStop=DeleteOrder(TicketSellStop);
   TicketSellLimit=DeleteOrder(TicketSellLimit);   
  }
  else if(OrderType()==OP_BUYSTOP)
  {
   NLorders++;   
  }
  else if(OrderType()==OP_SELLSTOP)
  {
   NSorders++;   
  }
  else if(OrderType()==OP_BUYLIMIT)
  {
   NLorders++;   
  }
  else if(OrderType()==OP_SELLLIMIT)
  {
   NSorders++;   
  }      
  
  if(TrailStopBegin>0) 
  {
   if(DetermineProfit()>NormPoints(TrailStopBegin))
   {
    trail=TrailStopATRFactor*(iATR(NULL,0,TrailStopATRPeriod,0))/Point;
    TrailingStop(trail);
   }
  }
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
datetime PendTime(int curtime,int hours)  // function to calculate pending expiration time
{
 return(TimeCurrent()+(hours*3600)); 
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
int DeleteOrder(int ticket)
{
 if(ticket<0) return(-1);
 
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
 return(-1);
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
double DetermineLots(double value1, double value2)  // function to determine lot sizes based on account balance
{
 if(value1==value2) return(0.00);
 double permitLoss=0.01*TradeRisk*AccountBalance();
 double pipSL=(value1-value2)/Point;
 double valueSL=pipSL*MarketInfo(Symbol(),MODE_TICKVALUE);
 
 double lots=permitLoss/valueSL;
 
 if(lots<lotsmin) return(lotsmin);
 else if(lots>lotsmax) return(lotsmax);
 
 return(lots);
}
//+------------------------------------------------------------------+
void Status(int mn)
{   
 if(mn==magic) 
 {
  if(OrderType()==OP_BUY)
  {
   otL=OrderOpenTime();
  }
  else if(OrderType()==OP_SELL)
  {
   otS=OrderOpenTime();
  }
  else if(OrderType()==OP_BUYSTOP)
  {  
  }
  else if(OrderType()==OP_SELLSTOP)
  {  
  }
  else if(OrderType()==OP_BUYLIMIT)
  {
  }
  else if(OrderType()==OP_SELLLIMIT)
  {
  } 
 } 
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
int CheckNPB(int bar_num)
{
   double bar_length, nose_length, body_length, eye_pos;
   bar_length = iHigh(NULL,0,bar_num)-iLow(NULL,0,bar_num);
   if(bar_length==0) return(-1);
   nose_length = iHigh(NULL,0,bar_num)-MathMax(iOpen(NULL,0,bar_num), iClose(NULL,0,bar_num));
   body_length = MathAbs(iOpen(NULL,0,bar_num)-iClose(NULL,0,bar_num));

   if( nose_length/bar_length > Min_Nose_Ratio*0.01 &&
       body_length/bar_length < Max_Body_Ratio*0.01 &&
       MathMax(iOpen(NULL,0,bar_num),iClose(NULL,0,bar_num))<iHigh(NULL,0,bar_num+1) &&
       MathMin(iOpen(NULL,0,bar_num),iClose(NULL,0,bar_num))>iLow(NULL,0,bar_num+1) &&
       iHigh(NULL,0,bar_num)>iHigh(NULL,0,bar_num+1))
   {
      return(1);
   }
   return(-1);
}
//+------------------------------------------------------------------+
int CheckPPB(int bar_num, bool verify=false)
{
   double bar_length, nose_length, body_length, eye_pos;
   bar_length = iHigh(NULL,0,bar_num)-iLow(NULL,0,bar_num);
   if(bar_length==0) return(-1);   
   nose_length = MathMin(iOpen(NULL,0,bar_num), iClose(NULL,0,bar_num))-iLow(NULL,0,bar_num);
   body_length = MathAbs(iOpen(NULL,0,bar_num)-iClose(NULL,0,bar_num));
   if( nose_length/bar_length > Min_Nose_Ratio*0.01 &&
       body_length/bar_length < Max_Body_Ratio*0.01 &&
       MathMax(iOpen(NULL,0,bar_num),iClose(NULL,0,bar_num))<iHigh(NULL,0,bar_num+1) &&
       MathMin(iOpen(NULL,0,bar_num),iClose(NULL,0,bar_num))>iLow(NULL,0,bar_num+1) &&
       iLow(NULL,0,bar_num)<iLow(NULL,0,bar_num+1))
   {
      return(1);
   }
   return(-1);
}
//+----------------------------------------------------------------------+
//|                                                        2ndSkiesC.mq4 |
//|                                                         David J. Lin |
//|Based on a pivot strategy                                             |
//|by Chris Capre, 2ndSkies.com (Info@2ndSkies.com)                      |
//|Coded by David J. Lin (dave.j.lin@sbcglobal.net)                      |
//|Evanston, IL, December 14, 2008                                       |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2008, Chris Capre & David J. Lin"
#property link      "2ndSkies.com"

// Internal usage parameters:
extern double LotsPerPosition=1.0; // fixed-lots per position
extern int starthour=7; // platform hour to start (inclusive)
extern int startmin=30; // platform minute to start
extern int endhour=21;  // platform hour to end (inclusive)

extern int PivotStartHour=8;
extern int PivotStartMinute=0;

int    xtPips=3;
string ciPivots="AIME Pivots";

int    StopLoss=24;         // pips beyond cloud SL
int    TakeProfit1=15;      // pips TP O1
int    TakeProfit2=51;      // pips TP O2
int    FixedStop=0;         // move SL 2nd order

int MAPeriod=6;             // EMA trail
int MAShift=0;
int MAMethod=MODE_EMA;
int MAPrice=PRICE_CLOSE;
int Trail=6;               // pips trail behind EMA

int       DaysToPlot=15;
color     SupportLabelColor=Gray;
color     ResistanceLabelColor=Gray;
color     PivotLabelColor=Gray;
int       fontsize=8;
int       LabelShift = 0;

double lotsmin,lotsmax;
int lotsprecision;
bool orderlong,ordershort;
int Slippage=5;
int Magic1,Magic2;
datetime ots,otl,lasttime,lastM1,starttime,lastLong,lastShort;
string comment1,comment2;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//---- 
 starttime=TimeCurrent();
 lotsmin=MarketInfo(Symbol(),MODE_MINLOT); 
 lotsmax=MarketInfo(Symbol(),MODE_MAXLOT); 
 
 comment1=StringConcatenate("2SC1 ",DoubleToStr(Period(),0)," ",Symbol());
 comment2=StringConcatenate("2SC2 ",DoubleToStr(Period(),0)," ",Symbol());
 
 Magic1=91+Period();
 Magic2=92+Period();
 
 if(lotsmin==1)         lotsprecision=0;
 else if(lotsmin==0.50) lotsprecision=1; // for PFG ECN
 else if(lotsmin==0.10) lotsprecision=1;
 else if(lotsmin==0.01) lotsprecision=2;
 else                   lotsprecision=1;
 
// First check closed trades
 int trade;                         
 int trades=OrdersHistoryTotal();           
 for(trade=0;trade<trades;trade++)   // The most recent closed order has the largest position number, so this works forward
                                     // to allow the values of the most recent closed orders to be the ones which are recorded
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_HISTORY);

  if(OrderSymbol()!=Symbol()) continue;
  if(OrderMagicNumber()==Magic1||OrderMagicNumber()==Magic2)
  {
//  int D1bars=iBarShift(NULL,PERIOD_D1,OrderCloseTime(),false);  // time difference in days
//  if(D1bars>60) // = only interested in recently closed trades
//   continue;
   Status(OrderMagicNumber());
   DrawCross(false);
  }
 }

// Now check open orders
 orderlong=false; ordershort=false; //reset flags
     
 trades=OrdersTotal();           
 for(trade=0;trade<trades;trade++)// The most recent closed order has the largest position number, so this works forward
                                  // to allow the values of the most recent closed orders to be the ones which are recorded

 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderMagicNumber()==Magic1||OrderMagicNumber()==Magic2)
  {
   Status(OrderMagicNumber());
   DrawCross(true);
  }
 }
 
// HideTestIndicators(true);  
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
 Main();
 ManageOrders(); 
 lasttime=iTime(NULL,0,0);
 lastM1=iTime(NULL,PERIOD_M1,0);
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert utility functions                                         |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void Main()
{ 
 if(orderlong||ordershort) return;
// if(lastM1==iTime(NULL,PERIOD_M1,0)) return;
 int timehour=TimeHour(iTime(NULL,0,0)); 
 if(starthour<endhour)
 {
  if(timehour<starthour || timehour>endhour) return;
 }
 else
 {
  if(timehour<starthour && timehour>endhour) return;
 }

 int timeminute=TimeMinute(iTime(NULL,0,0));
 if(timehour==starthour && timeminute<startmin) return; 

 double Lots,SL,TP1,TP2;
 string td;

 double S3=iCustom(NULL,0,ciPivots,PivotStartHour,PivotStartMinute,DaysToPlot,SupportLabelColor,ResistanceLabelColor,PivotLabelColor,fontsize,LabelShift,5,0);
 double R3=iCustom(NULL,0,ciPivots,PivotStartHour,PivotStartMinute,DaysToPlot,SupportLabelColor,ResistanceLabelColor,PivotLabelColor,fontsize,LabelShift,6,0);
 double open=iOpen(NULL,0,0);
  
 if(open<R3 && Bid>NormDigits(R3+NormPoints(xtPips)))
 { 
  if(iBarShift(NULL,0,otl,false)>0 && iBarShift(NULL,PERIOD_D1,otl,false)>0)
  {
//   if(filter(true))
   {
    SL=StopLong(Ask,StopLoss);
    TP1=TakeLong(Ask,TakeProfit1);  
    TP2=TakeLong(Ask,TakeProfit2); 
    
    Lots=LotsPerPosition;

    SendOrderLong(Symbol(),Lots,Slippage,0,0,comment1,Magic1);
    SendOrderLong(Symbol(),Lots,Slippage,0,0,comment2,Magic2);    
    otl=TimeCurrent();
    td=TimeToStr(otl,TIME_DATE|TIME_MINUTES);
    Alert("2ndSkiesC enter long: ",Symbol()," M",Period()," at",td);
    AddSLTP(SL,TP1,TP2);    
   }
  }
 }
 else if(open>S3 && Bid<NormDigits(S3-NormPoints(xtPips)))
 { 
  if(iBarShift(NULL,0,ots,false)>0 && iBarShift(NULL,PERIOD_D1,ots,false)>0)
  { 
//   if(filter(false))
   {
    SL=StopShort(Bid,StopLoss);
    TP1=TakeShort(Bid,TakeProfit1);
    TP2=TakeShort(Bid,TakeProfit2);    

    Lots=LotsPerPosition;
   
    SendOrderShort(Symbol(),Lots,Slippage,0,0,comment1,Magic1);
    SendOrderShort(Symbol(),Lots,Slippage,0,0,comment2,Magic2);    
    ots=TimeCurrent();
    td=TimeToStr(ots,TIME_DATE|TIME_MINUTES);
    Alert("2ndSkiesC enter short: ",Symbol()," M",Period()," at",td);   
    AddSLTP(SL,TP1,TP2);    
   }
  }
 }

 return; 
}
//+------------------------------------------------------------------+
bool filter(bool long)
{
 int Trigger[1], totN=0,i,j,k,trig;
 double MA1a,MA2a,MA3a,MA1b,MA2b,MA3b,MACDmain,MACDsig;
  
 for(i=0;i<totN;i++) Trigger[i]=-1;

 if(long) // long filters
 {
  for(i=0;i<totN;i++)
  {
   switch(i)
   {   
    case 0:
     CheckClosedOrders();
     if(iTime(NULL,0,trig)>lastLong) Trigger[i]=1;
    break;    
   }
   if(Trigger[i]<0) return(false);       
  } 
 }
 else // short filters
 {
  for(i=0;i<totN;i++)
  {
   switch(i)
   { 
    case 0:
     CheckClosedOrders();
     if(iTime(NULL,0,trig)>lastShort) Trigger[i]=1;
    break;           
   }
   if(Trigger[i]<0) return(false);    
  }
 }

 return(true);  // no anti-trigger:  so, return true (to order)
}
//+------------------------------------------------------------------+ 

void ManageOrders()
{
 orderlong=false;ordershort=false;
 int magic,trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;

  magic=OrderMagicNumber();
  if(magic==Magic1)
  {
   if(OrderType()==OP_BUY)       orderlong=true; 
   else if(OrderType()==OP_SELL) ordershort=true;

//   if(iBarShift(NULL,0,OrderOpenTime(),false)<1) continue;
//    if(lastM1==iTime(NULL,PERIOD_M1,0)) continue;
    
  }
  else if(magic==Magic2)
  {
   if(OrderType()==OP_BUY)       orderlong=true;     
   else if(OrderType()==OP_SELL) ordershort=true;    

   if(CheckSL()<0) FixedStopsB(TakeProfit1,FixedStop);
    
   if(iBarShift(NULL,0,OrderOpenTime(),false)<1) continue;
   if(lastM1==iTime(NULL,PERIOD_M1,0)) continue;
   MATrail();
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
int SendOrderLong(string sym, double vol, int slip, double sl, double tp, string comment="", int magic=0, datetime exp=0, color cl=Blue)
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
int SendOrderShort(string sym, double vol, int slip, double sl, double tp, string comment="", int magic=0, datetime exp=0, color cl=Red)
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
void FixedStopsB(int PP,int PFS)
{
 if(PFS<0) return;

 double stopcal;
 double stopcrnt=OrderStopLoss();
 double profitpoint=NormPoints(PP);  
 double profit=DetermineProfit();
//Long               
 if(OrderType()==OP_BUY)
 {
  if(profit>=profitpoint)
  {
   stopcal=TakeLong(OrderOpenPrice(),PFS);
   ModifyCompLong(stopcal,stopcrnt);   
  }
 }    
//Short 
 if(OrderType()==OP_SELL)
 {  
  if(profit>=profitpoint)
  {
   stopcal=TakeShort(OrderOpenPrice(),PFS);
   ModifyCompShort(stopcal,stopcrnt);
  }
 }  
 return(0);
} 
//+------------------------------------------------------------------+
double DetermineProfit()
{
 if(OrderType()==OP_BUY)  
  return(NormDigits(Bid-OrderOpenPrice()));
 else if(OrderType()==OP_SELL)
  return(NormDigits(OrderOpenPrice()-Ask)); 
 
 return(0); 
}
//+------------------------------------------------------------------+
double TakeLong(double price,int take)  // function to calculate takeprofit if long
{
 return(NormDigits(price+NormPoints(take))); 
             // plus, since the take profit is above us for long positions
}
//+------------------------------------------------------------------+
double TakeShort(double price,int take)  // function to calculate takeprofit if short
{
 return(NormDigits(price-NormPoints(take))); 
             // minus, since the take profit is below us for short positions
}
//+------------------------------------------------------------------+
double StopShort(double price,int stop) // function to calculate normal stoploss if short
{
 return(NormDigits(price+NormPoints(stop))); 
             // plus, since the stop loss is above us for short positions
}
//+------------------------------------------------------------------+
double StopLong(double price,int stop) // function to calculate normal stoploss if long
{
 return(NormDigits(price-NormPoints(stop))); 
             // minus, since the stop loss is below us for long positions
             // Point is 0.01 or 0.001 depending on currency, so stop*POINT is a way to convert pips into price with multiplication 
}
//+------------------------------------------------------------------+
double CheckSL()
{
 int type=OrderType();
 
      if(type==OP_BUY)  return( NormDigits(OrderStopLoss()-OrderOpenPrice()) );
 else if(type==OP_SELL) return( NormDigits(OrderOpenPrice()-OrderStopLoss()) );

 return(0.0);
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
void Status(int magic)
{
 if(magic==Magic1)
 {
  if(OrderType()==OP_BUY)       
  {
   otl=OrderOpenTime();
   orderlong=true;
  }
  else if(OrderType()==OP_SELL) 
  {
   ots=OrderOpenTime(); 
   ordershort=true;
  }
 }
 else if(magic==Magic2)
 {
  if(OrderType()==OP_BUY)       
  {
   otl=OrderOpenTime();
   orderlong=true;
  }
  else if(OrderType()==OP_SELL) 
  {
   ots=OrderOpenTime(); 
   ordershort=true;
  }  
 }
 return(0);  
}
//+------------------------------------------------------------------+
void CheckClosedOrders() // check most recently closed for time ... don't enter until new cross occurs after a close  
{
 lastLong=0;lastShort=0; 
 int trade;                         
 int trades=OrdersHistoryTotal();           
 for(trade=trades-1;trade>=0;trade--)   // The most recent closed order has the largest position number, so this works backward 
                                     // to find the most recently closed order 
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_HISTORY);

  if(OrderSymbol()!=Symbol()) continue;
  if(OrderType()==OP_BUY)
  {
   if(OrderMagicNumber()==Magic1||OrderMagicNumber()==Magic2)
   {
    lastLong=OrderCloseTime();
    break;
   }
  }
 }
 
 for(trade=trades-1;trade>=0;trade--)   // The most recent closed order has the largest position number, so this works backward 
                                     // to find the most recently closed order 
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_HISTORY);

  if(OrderSymbol()!=Symbol()) continue;
  if(OrderType()==OP_SELL)
  {
   if(OrderMagicNumber()==Magic1||OrderMagicNumber()==Magic2)
   {
    lastShort=OrderCloseTime();
    break;
   }
  }
 } 
 
 return;
} 
//+------------------------------------------------------------------+
void DrawCross(bool flag)
{
 color clr;
 string name;
 double price=OrderOpenPrice();
 datetime time=OrderOpenTime();
 string comment=OrderComment();
 int ticket=OrderTicket();
 int type=OrderType();

      if(type==OP_BUY||type==OP_BUYLIMIT||type==OP_BUYSTOP)    clr=Blue;
 else if(type==OP_SELL||type==OP_SELLLIMIT||type==OP_SELLSTOP) clr=Red;

 if(flag)
 {
  name=StringConcatenate(comment," #",ticket," ",TimeToStr(time)," ",price);

  ObjectDelete(name);  
  ObjectCreate(name,OBJ_ARROW,0,time,price);
  ObjectSet(name,OBJPROP_COLOR,clr);
  ObjectSet(name,OBJPROP_ARROWCODE,1); 
  ObjectSet(name,OBJPROP_WIDTH,1);
 }
 else
 {
//  if(type!=OP_BUY||type!=OP_SELL) comment=FindComment(OrderMagicNumber()); // expired pendings don't have method name for comment, must match up w/ list
 
  name=StringConcatenate(comment," #",ticket," ",TimeToStr(time)," ",price);

  ObjectDelete(name);  
  ObjectCreate(name,OBJ_ARROW,0,time,price);
  ObjectSet(name,OBJPROP_COLOR,clr);
  ObjectSet(name,OBJPROP_ARROWCODE,1); 
  ObjectSet(name,OBJPROP_WIDTH,1);
  
  double closeprice;
  if(type==OP_BUY||type==OP_SELL) closeprice=OrderClosePrice();
  else closeprice=OrderOpenPrice();
  datetime closetime=OrderCloseTime();
  
  name=StringConcatenate(comment,": ",price,"-->",closeprice);

  if(type==OP_BUYLIMIT||type==OP_BUYSTOP||type==OP_SELLLIMIT||type==OP_SELLSTOP) clr=Black;
  
  ObjectDelete(name);
  ObjectCreate(name,OBJ_TREND,0,time,price,closetime,closeprice);
  ObjectSet(name,OBJPROP_STYLE,STYLE_DOT);
  ObjectSet(name,OBJPROP_COLOR,clr);  
  ObjectSet(name,OBJPROP_RAY,false);

  if(type==OP_BUY||type==OP_SELL)
  {
   if(OrderStopLoss()!=OrderClosePrice()) clr=LimeGreen;
  }
  
  name=StringConcatenate(comment," #",ticket," ",TimeToStr(closetime)," ",closeprice);

  ObjectDelete(name);
  ObjectCreate(name,OBJ_ARROW,0,closetime,closeprice);
  ObjectSet(name,OBJPROP_ARROWCODE,3);
  ObjectSet(name,OBJPROP_COLOR,clr);   
 }
 return;
}
//+------------------------------------------------------------------+
void MATrail()
{  
// if(lasttime==iTime(NULL,0,0)) return;
 double stopcal;
 double stopcrnt=OrderStopLoss();
 double MA=iMA(NULL,0,MAPeriod,MAShift,MAMethod,MAPrice,0);

 if(OrderType()==OP_BUY)       
 {
  stopcal=NormDigits(MA-NormPoints(Trail));
  if(stopcal>OrderOpenPrice()) ModifyCompLong(stopcal,stopcrnt);
 }
 else if(OrderType()==OP_SELL)       
 {   
  stopcal=NormDigits(MA+NormPoints(Trail));
  if(stopcal<OrderOpenPrice()) ModifyCompShort(stopcal,stopcrnt); 
 }
 return;
}
//+------------------------------------------------------------------+ 

void AddSLTP(double sl, double tp1, double tp2)
{
 int magic,trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;

  if(OrderStopLoss()==0)
  {
   magic=OrderMagicNumber();
        if(magic==Magic1) ModifyOrder(OrderTicket(),OrderOpenPrice(),sl,tp1,0,CLR_NONE);
   else if(magic==Magic2) ModifyOrder(OrderTicket(),OrderOpenPrice(),sl,tp2,0,CLR_NONE); 
  }
 } 
 return;
}


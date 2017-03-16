//+----------------------------------------------------------------------+
//|                                                        2ndSkiesB.mq4 |
//|                                                         David J. Lin |
//|Based on an MA/MACD strategy                                          |
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
extern int endhour=16;  // platform hour to end (inclusive)

int    StopLoss=24;         // pips beyond cloud SL
int    TakeProfit=15;       // pips TP
int    FixedStop=0;         // move SL 2nd order

int MAPeriod1=3;
int MAPeriod2=24;
int MAPeriod3=30;
int MAShift=0;
int MAMethod=MODE_EMA;
int MAPrice=PRICE_CLOSE;

int MACDPeriodFast=12;
int MACDPeriodSlow=33;
int MACDPeriodSignal=9;

double lotsmin,lotsmax;
int lotsprecision;
bool orderlong,ordershort;
int Slippage=2;
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
 
 comment1=StringConcatenate("2SB1 ",DoubleToStr(Period(),0)," ",Symbol());
 comment2=StringConcatenate("2SB2 ",DoubleToStr(Period(),0)," ",Symbol());
 
 Magic1=81+Period();
 Magic2=82+Period();
 
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

 double Lots,SL,TP,MA1a,MA2a,MA3a,MA1b,MA2b,MA3b;
 string td;
 
 MA1a=iMA(NULL,0,MAPeriod1,MAShift,MAMethod,MAPrice,0);
 MA2a=iMA(NULL,0,MAPeriod2,MAShift,MAMethod,MAPrice,0);
 MA3a=iMA(NULL,0,MAPeriod3,MAShift,MAMethod,MAPrice,0); 

 MA1b=iMA(NULL,0,MAPeriod1,MAShift,MAMethod,MAPrice,1);
 MA2b=iMA(NULL,0,MAPeriod2,MAShift,MAMethod,MAPrice,1);
 MA3b=iMA(NULL,0,MAPeriod3,MAShift,MAMethod,MAPrice,1);
 
 if(((MA1a>MA2a && MA1b<MA2b)||(MA1a>MA3a && MA1b<MA3b)) && MA1a>MA3a && MA1a>MA2a && Bid>MA2a && Bid>MA3a)
 { 
  if(iBarShift(NULL,0,otl,false)>0)
  {
   if(filter(true))
   {
    SL=StopLong(Ask,StopLoss);
    TP=TakeLong(Ask,TakeProfit);  
    
    Lots=LotsPerPosition;

    SendOrderLong(Symbol(),Lots,Slippage,0,0,comment1,Magic1);
    SendOrderLong(Symbol(),Lots,Slippage,0,0,comment2,Magic2);    
    otl=TimeCurrent();
    td=TimeToStr(otl,TIME_DATE|TIME_MINUTES);
    Alert("2ndSkiesB enter long: ",Symbol()," M",Period()," at",td);
    AddSLTP(SL,TP);    
   }
  }
 }
 else if(((MA1a<MA2a && MA1b>MA2b)||(MA1a<MA3a && MA1b>MA3b)) && MA1a<MA3a && MA1a<MA2a && Bid<MA2a && Bid<MA3a)
 { 
  if(iBarShift(NULL,0,ots,false)>0)
  { 
   if(filter(false))
   {
    SL=StopShort(Bid,StopLoss);
    TP=TakeShort(Bid,TakeProfit);

    Lots=LotsPerPosition;
   
    SendOrderShort(Symbol(),Lots,Slippage,0,0,comment1,Magic1);
    SendOrderShort(Symbol(),Lots,Slippage,0,0,comment2,Magic2);    
    ots=TimeCurrent();
    td=TimeToStr(ots,TIME_DATE|TIME_MINUTES);
    Alert("2ndSkiesB enter short: ",Symbol()," M",Period()," at",td);  
    AddSLTP(SL,TP);     
   }
  }
 }

 return; 
}
//+------------------------------------------------------------------+

bool filter(bool long)
{
 int Trigger[3], totN=3,i,j,k,trig;
 double MA1a,MA2a,MA3a,MA1b,MA2b,MA3b,MACDmain,MACDsig;
  
 for(i=0;i<totN;i++) Trigger[i]=-1;

 if(long) // long filters
 {
  for(i=0;i<totN;i++)
  {
   switch(i)
   {
    case 0:   
     for(j=0;j<=5000;j++)
     {
      MA1a=iMA(NULL,0,MAPeriod1,MAShift,MAMethod,MAPrice,j);
      MA2a=iMA(NULL,0,MAPeriod2,MAShift,MAMethod,MAPrice,j);
      MA3a=iMA(NULL,0,MAPeriod3,MAShift,MAMethod,MAPrice,j);    
      MA1b=iMA(NULL,0,MAPeriod1,MAShift,MAMethod,MAPrice,j+1);
      MA2b=iMA(NULL,0,MAPeriod2,MAShift,MAMethod,MAPrice,j+1);
      MA3b=iMA(NULL,0,MAPeriod3,MAShift,MAMethod,MAPrice,j+1);        
     
      if(MA1a<MA2a && MA1b>MA2b) return(false); // negate upon contrary cross since
      if(MA1a<MA3a && MA1b>MA3b) return(false); // negate upon contrary cross since
     
      if(((MA1a>MA2a && MA1b<MA2b) || (MA1a>MA3a && MA1b<MA3b)) && MA1a>MA3a && MA1a>MA2a) 
      {
       if(iTime(NULL,0,j)>otl && iTime(NULL,0,j)>starttime ) // take trigger upon new cross only & after start
       {
        Trigger[i]=1;
        trig=j;
        break;
       }
       else return(false); 
      }
     }
    break;
    case 1: // MACD filter
     MACDmain=iMACD(NULL,0,MACDPeriodFast,MACDPeriodSlow,MACDPeriodSignal,PRICE_CLOSE,MODE_MAIN,0);
     MACDsig= iMACD(NULL,0,MACDPeriodFast,MACDPeriodSlow,MACDPeriodSignal,PRICE_CLOSE,MODE_SIGNAL,0);
     if(MACDmain>MACDsig) Trigger[i]=1;
    break;   
    case 2:
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
     for(j=0;j<=5000;j++)
     {
      MA1a=iMA(NULL,0,MAPeriod1,MAShift,MAMethod,MAPrice,j);
      MA2a=iMA(NULL,0,MAPeriod2,MAShift,MAMethod,MAPrice,j);
      MA3a=iMA(NULL,0,MAPeriod3,MAShift,MAMethod,MAPrice,j);    
      MA1b=iMA(NULL,0,MAPeriod1,MAShift,MAMethod,MAPrice,j+1);
      MA2b=iMA(NULL,0,MAPeriod2,MAShift,MAMethod,MAPrice,j+1);
      MA3b=iMA(NULL,0,MAPeriod3,MAShift,MAMethod,MAPrice,j+1);        
     
      if(MA1a>MA2a && MA1b<MA2b) return(false); // negate upon contrary cross since
      if(MA1a>MA3a && MA1b<MA3b) return(false); // negate upon contrary cross since
     
      if(((MA1a<MA2a && MA1b>MA2b) || (MA1a<MA3a && MA1b>MA3b)) && MA1a<MA3a && MA1a<MA2a) 
      {
       if(iTime(NULL,0,j)>ots && iTime(NULL,0,j)>starttime ) // take trigger upon new cross only & after start
       {
        Trigger[i]=1;
        trig=j;
        break;
       }
       else return(false); 
      }
     }
    break;  
    case 1: // MACD filter
     MACDmain=iMACD(NULL,0,MACDPeriodFast,MACDPeriodSlow,MACDPeriodSignal,PRICE_CLOSE,MODE_MAIN,0);
     MACDsig= iMACD(NULL,0,MACDPeriodFast,MACDPeriodSlow,MACDPeriodSignal,PRICE_CLOSE,MODE_SIGNAL,0);
     if(MACDmain<MACDsig) Trigger[i]=1;
    break;  
    case 2:
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

   if(CheckSL()<0) FixedStopsB(TakeProfit,FixedStop);
    
   if(iBarShift(NULL,0,OrderOpenTime(),false)<1) continue;
//   if(lastM1==iTime(NULL,PERIOD_M1,0)) continue;
   MACDExit();
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
void MACDExit()
{ 
 double MACDmain1=iMACD(NULL,0,MACDPeriodFast,MACDPeriodSlow,MACDPeriodSignal,PRICE_CLOSE,MODE_MAIN,0);
 double MACDsig1= iMACD(NULL,0,MACDPeriodFast,MACDPeriodSlow,MACDPeriodSignal,PRICE_CLOSE,MODE_SIGNAL,0);
 double MACDmain2=iMACD(NULL,0,MACDPeriodFast,MACDPeriodSlow,MACDPeriodSignal,PRICE_CLOSE,MODE_MAIN,1);
 double MACDsig2= iMACD(NULL,0,MACDPeriodFast,MACDPeriodSlow,MACDPeriodSignal,PRICE_CLOSE,MODE_SIGNAL,1);
 
 if(OrderType()==OP_BUY)       
 { 
  if(MACDmain1<MACDsig1 && MACDmain2>MACDsig2)
  {
   ExitOrder(true,false);
   Alert("2ndSkiesB2 cross-exit long: ",Symbol()," M",Period()," at",TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES));   
  }
 }
 else if(OrderType()==OP_SELL)       
 { 
  if(MACDmain1>MACDsig1 && MACDmain2<MACDsig2)
  {
   ExitOrder(false,true);
   Alert("2ndSkiesB2 cross-exit short: ",Symbol()," M",Period()," at",TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES));   
  }
 }
   
 return;
}
//+------------------------------------------------------------------+ 

void AddSLTP(double sl, double tp)
{
 int magic,trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;

  if(OrderStopLoss()==0)
  {
   magic=OrderMagicNumber();
        if(magic==Magic1) ModifyOrder(OrderTicket(),OrderOpenPrice(),sl,tp,0,CLR_NONE);
   else if(magic==Magic2) ModifyOrder(OrderTicket(),OrderOpenPrice(),sl,0, 0,CLR_NONE); 
  }
 } 
 return;
}
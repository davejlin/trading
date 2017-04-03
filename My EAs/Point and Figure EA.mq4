//+----------------------------------------------------------------------+
//|                                              Point and Figure EA.mq4 |
//|                                                         David J. Lin |
//| Point and Figure EA                                                  |
//| written for Melvin D'Souza (dmx_lab@yahoo.com)                       |
//|                                                                      |
//| Coded by David J. Lin (dave.j.lin@gmail.com)                         |
//| Evanston, IL, July 30, 2011                                          |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2011, Melvin D\'Souza and David J. Lin"

// Internal usage parameters:
//---- input parameters

extern int Magic=1;

// P&F parameters:
extern int boxValue = 10;
extern int Multiply = 3;

// Order parameters:
extern double Lots=0.1; // base lot unit
extern double LotMultiplier = 1.3; // Martingale lot multiplier (use 1.0 to disable)

extern int TakeProfit=0;
extern int StopLoss=0;
extern int TrailStop=0;
extern int MoveProfit=0;
extern int MoveStop=0;

//---- buffers
bool orderlong,ordershort,triggered;

string comment;
datetime ots,otl,lasttime;
double lotsmin,lotsmax;
double lottage;
double StopLossPoints,TakeProfitPoints;
double TrailStopPoints,MoveProfitPoints,MoveStopPoints;
int lotsprecision;
int Slippage=1;
string semaphorestring;
string teststring;
string nameEA;

bool EnterLong=false,EnterShort=false;

double   pointValue;
double   boxPoint;

bool     flag1 = true;
bool     flag2 = false;
bool     flag3 = false;

double   valueD1 = 0;
double   valueD2 = 0;
double   valueD4;
double   valueD5;

int      valueI1;

int      NBars;
int      limit;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//---- 
 nameEA=StringConcatenate("Point and Figure EA (",DoubleToStr(boxValue,0),",",DoubleToStr(Multiply,0),")\nMagic #: ",DoubleToStr(Magic,0));
 Comment(nameEA);
 
 comment=StringConcatenate("PF ",DoubleToStr(Magic,0));
 
 semaphorestring="SEMAPHORE";
 teststring="TEST";

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
   TrailStopPoints=NormPoints(TrailStop*10);
   MoveProfitPoints=NormPoints(MoveProfit*10);
   MoveStopPoints=NormPoints(MoveStop*10); 
  }
  else
  {
   StopLossPoints=NormPoints(StopLoss);
   TakeProfitPoints=NormPoints(TakeProfit);
   TrailStopPoints=NormPoints(TrailStop);
   MoveProfitPoints=NormPoints(MoveProfit);
   MoveStopPoints=NormPoints(MoveStop);     
  }  
 }
 else
 {
  if(Digits==5)
  {
   StopLossPoints=NormPoints(StopLoss*10);
   TakeProfitPoints=NormPoints(TakeProfit*10);
   TrailStopPoints=NormPoints(TrailStop*10);
   MoveProfitPoints=NormPoints(MoveProfit*10);
   MoveStopPoints=NormPoints(MoveStop*10);     
  }
  else
  {
   StopLossPoints=NormPoints(StopLoss);
   TakeProfitPoints=NormPoints(TakeProfit); 
   TrailStopPoints=NormPoints(TrailStop);
   MoveProfitPoints=NormPoints(MoveProfit);
   MoveStopPoints=NormPoints(MoveStop);     
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
 
 lasttime=iTime(NULL,0,0);
 
 triggered=false;

 if(CheckNumberOrder()>0) triggered=true; 
 
 if(IsTesting()) semaphorestring=StringConcatenate(semaphorestring,teststring);

 double myDigits;
 myDigits = MarketInfo (Symbol(), MODE_DIGITS);
 if (myDigits < 4) pointValue = 0.01;
 else              pointValue = 0.0001;
   
 if(MarketInfo(Symbol(),MODE_PROFITCALCMODE)!=0) pointValue=Point;
 boxPoint = NormalizeDouble(boxValue*pointValue,Digits); 
 NBars = Bars;

 PointNFigure(Bars);
 EnterLong=false;EnterShort=false; 
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
 EnterLong=false;EnterShort=false;
 PointNFigure(0);
 ManageOrders(); 
 Main();
   
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
 if(!EnterLong&&!EnterShort) return;
  
 double SL,TP;
 string td;
 int ticket;

 if(EnterLong)
 {
  SL=StopLong(Ask,StopLossPoints);
  TP=TakeLong(Ask,TakeProfitPoints);  

  ticket=SendOrderLong(Symbol(),lottage,Slippage,0,0,comment,Magic);     
  
  otl=TimeCurrent();
  td=TimeToStr(otl,TIME_DATE|TIME_MINUTES);
  Alert("PF entered long: ",Symbol()," M",Period()," at",td," Magic #:",DoubleToStr(Magic,0));
  AddSLTP(SL,TP,ticket);
  triggered=true;  
 } 
 else if(EnterShort)
 {
  SL=StopShort(Bid,StopLossPoints);
  TP=TakeShort(Bid,TakeProfitPoints);  

  ticket=SendOrderShort(Symbol(),lottage,Slippage,0,0,comment,Magic);   
  
  ots=TimeCurrent();
  td=TimeToStr(ots,TIME_DATE|TIME_MINUTES);
  Alert("PF entered short: ",Symbol()," M",Period()," at",td," Magic #:",DoubleToStr(Magic,0));
  AddSLTP(SL,TP,ticket);
  triggered=true;
 } 

 return; 
}
//+------------------------------------------------------------------+

void ManageOrders()
{ 
 lottage=Lots;

 int trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 { 
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderMagicNumber()!=Magic) continue;
  
  if(OrderType()==OP_BUY)
  {
   if(EnterShort) 
   {
    if(OrderProfit()<=0) lottage=NormLots(OrderLots()*LotMultiplier);
    triggered=false;
    ExitOrder(true,false);
   }
  }
  else if(OrderType()==OP_SELL)
  {
   if(EnterLong) 
   {
    if(OrderProfit()<=0) lottage=NormLots(OrderLots()*LotMultiplier);
    triggered=false;
    ExitOrder(false,true);
   }
  } 
  
  if(MoveProfit>0) FixedStopsB(MoveProfitPoints,MoveStopPoints);
  TrailingStop(TrailStopPoints);
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
 if(take==0) return(0);
 return(NormDigits(price+take)); 
             // plus, since the take profit is above us for long positions
}
//+------------------------------------------------------------------+
double TakeShort(double price,double take)  // function to calculate takeprofit if short
{
 if(take==0) return(0);
 return(NormDigits(price-take)); 
             // minus, since the take profit is below us for short positions
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
void AddSLTP(double sl, double tp, int orderNumber)
{
 if(sl==0&&tp==0) return;
 if(OrderSelect(orderNumber,SELECT_BY_TICKET)) 
  ModifyOrder(orderNumber,OrderOpenPrice(),sl,tp,0,CLR_NONE);
 return;
}
//+------------------------------------------------------------------+
void FixedStopsB(double PP,double PFS)
{
  double stopcrnt,stopcal;
  double profit,profitpoint;

  stopcrnt=OrderStopLoss();
  profitpoint=PP;  
          
  if(OrderType()==OP_BUY)
  {
   profit=NormDigits(Bid-OrderOpenPrice());
   
   if(profit>=profitpoint)
   {
    stopcal=NormDigits(OrderOpenPrice()+PFS);
    ModifyCompLong(stopcal,stopcrnt);
   }
  }
  else if(OrderType()==OP_SELL)
  {  
   profit=NormDigits(OrderOpenPrice()-Ask);
   
   if(profit>=profitpoint)
   {
    stopcal=NormDigits(OrderOpenPrice()-PFS);
    ModifyCompShort(stopcal,stopcrnt);  
   }
  }
 return;
} 
//+------------------------------------------------------------------+
void TrailingStop(double TS)
{
 if(TS<=0) return;
 
 double stopcrnt,stopcal; 
 
 stopcrnt=OrderStopLoss(); 

//Long               
 if(OrderType()==OP_BUY)
 {
  stopcal=TrailLong(Bid,TS);
  ModifyCompLong(stopcal,stopcrnt);    
 }    
//Short 
 else if(OrderType()==OP_SELL)
 {  
  stopcal=TrailShort(Ask,TS);
  ModifyCompShort(stopcal,stopcrnt);
 } 
 return(0);
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
int CheckNumberOrder() // check number of orders in account by EA
{
 int trade,trades=OrdersTotal(),total=0; 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderMagicNumber()!=Magic) continue;
  
  total++;
 }
 return(total);
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

int doReversal(int code, int shift)
{
 double price;

 if (code == 0)
 {
  if (shift == 0) price = iClose(NULL,0,0); else price = High[shift];
  while (price > valueD1 + boxPoint)
  {
   //drawNewX(valueD1,shift);    
   valueD1 = valueD1 + boxPoint;
   //chartBuffer[valueI2] = valueD1;
  }
  EnterLong=true;
 }
 else if (code == 1)
 {
  if (shift == 0) price = iClose(NULL,0,0); else price = Low[shift];
  while (price < valueD1 - boxPoint)
  {
   valueD1 = valueD1 - boxPoint;
   //drawNewO(valueD1,shift);
   //chartBuffer[valueI2] = valueD1;
  }
  EnterShort=true;
 }
}

//+------------------------------------------------------------------+
void PointNFigure(int limit)
{
 int j;
 
 for (j = limit; j >= 0; j--)
 {

  if (flag1)
  {
   if (Open[j] > Close[j])
   {
    valueD1 = High[j];
    flag2 = false;
    flag3 = true;
    //valueI2 = iBarShift(Symbol(),0,Time[j]);
   }
   else if (Open[j] < Close[j])
   {
    valueD1 = Low[j];
    flag2 = true;
    flag3 = false;
    //valueI2 = iBarShift(Symbol(),0,Time[j]);
   }
   else if (Open[j] == Close[j]) continue;

   flag1 = false;
  }

  if (Time[j] > valueI1)
  {
   valueD2 = valueD1;
   valueI1 = Time[j];
  }

  if (flag2)
  {
   if (j == 0) valueD4 = iClose(NULL,0,0); else valueD4 = High[j];
   while (valueD4 >= valueD1 + boxPoint)
   {
    //drawNewX(valueD1,j);
    valueD1 = valueD1 + boxPoint;
    //chartBuffer[valueI2] = valueD1;
   }

   if (j == 0)
   {
    valueD5 = valueD1;
    valueD4 = iClose(NULL,0,0);
   }
   else
   {
    valueD5 = valueD2;
    valueD4 = Low[j];
   }

   if (valueD5 - NormalizeDouble(boxPoint*Multiply,Digits) >= valueD4)
   {
    //if (valueI2 != 0) valueI2--;
    //if (!flag4)
    //{
    // valueI5++;
    // moveAllBack();
    //}

    doReversal(1,j);
    flag2 = false;
    flag3 = true;
    continue;
   }
  }

  if (flag3)
  {
   if (j == 0) valueD4 = iClose(NULL,0,0); else valueD4 = Low[j];
   while (valueD4 <= valueD1 - boxPoint)
   {
    valueD1 = valueD1 - boxPoint;
    //drawNewO(valueD1,j);
    //chartBuffer[valueI2] = valueD1;
   }
 
   if (j == 0)
   {
    valueD5 = valueD1;
    valueD4 = iClose(NULL,0,0);
   }
   else
   {
    valueD5 = valueD2;
    valueD4 = High[j];
   }
 
   if (valueD5 + NormalizeDouble(boxPoint*Multiply,Digits) <= valueD4)
   {
    //if (valueI2 != 0) valueI2--;
    //if (!flag4)
    //{
    // valueI5++;
    // moveAllBack();
    //}
 
    doReversal(0,j);
    flag2 = true;
    flag3 = false;
   }
  }
 }
 
 return;
}
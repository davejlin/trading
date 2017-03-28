//+----------------------------------------------------------------------+
//|                                                Decision Maker EA.mq4 |
//|                                                         David J. Lin |
//| Decision Maker EA                                                    |
//| for Mike Skeffington                                                 |
//| mike@skeff.com                                                       |
//|                                                                      |
//| Coded by David J. Lin (dave.j.lin@gmail.com)                         |
//| Evanston, IL, December 16, 2011                                      |
//| January 10, 2012 Add Spread Filter funtion                           |
//| April 14, 2012 Add Entry Persist conditions                          |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2011, Mike Skeffington and David J. Lin"

// External usage parameters:
//===== Order parameters =====
extern string _____Order_Params_____="Order Parameters";
extern bool Two_Orders=true; // true: O1 and O2, false: only O1

//===== Trigger parameters =====
extern string _____Trigger_Params_____="Bars in Trigger Window";
extern int Trigger_Window_Bars=3; // number of bars in trigger window 

//===== Risk parameters ===== 
extern string _____Risk_Params_____ ="Risk Percentage";
extern double Risk1=1.25; // O1 risk
extern double Risk2=1.25; // O2 risk

//===== Time parameters ===== 
extern string _____Time_Window_____ ="Time Window Parameters (platform 24hr)";
extern bool Use_Time_Window=true; // true = use time filter, false = no time filter
extern int Start_Hour=8;   // hours (platform time) to activate EA
extern int Start_Minute=0;  // minute to activate EA
extern int End_Hour=16;     // hours (platform time) to deactivate EA
extern int End_Minute=0;    // minute to deactivate EA

//===== Spread Filter parameters ===== 
extern string _____Spread_Filter_____ ="Spread Filter Parameters";
extern bool Use_Spread_Filter=false; // true = use spread filter, false = no spread filter
extern double Spread_Filter_Amount=10.0; // pips to filter spread by

//===== Order 2 Money Management parameters ===== 
extern string _____Order_2_MM_____ ="Order 2 MM Parameters";
extern bool Order2_MACD_Exit=true; // true: Order 2 exits on contrary MACD cross, false: doesn't
extern string _____Order_2_Options ="0=none; 1=BE; 2=half SL; 3=half TP1";
extern int Order2_Manage_Options=1; // When Order 1 TP1, Order 2 SL Management - 0) Inactive, 1) SL to BE, 2) SL to 1/2 initial SL, 3) SL to 1/2 TP1

//===== MA indicator parameters =====
// MA Method: 0=SMA 1=EMA 2=SMMA 3=LWMA
// MA Price: 0=Close 1=Open 2=High 3=Low 4=Median 5=Typical 6=Weighted
extern string _____MA_Params_____="Moving Average Parameters";
extern int    MA_Fast_Period=5;
extern int    MA_Fast_Shift=0;
extern string _____MAF_Method_____="0=SMA; 1=EMA; 2=SMMA; 3=LWMA";
extern int    MA_Fast_Method=0;
extern string _____MAF_Price_____="0=C; 1=O; 2=H; 3=L; 4=Med; 5=Typ; 6=Wt";
extern int    MA_Fast_Price=0;

extern int    MA_Slow_Period=25;
extern int    MA_Slow_Shift=0;
extern string _____MAS_Method_____="0=SMA; 1=EMA; 2=SMMA; 3=LWMA";
extern int    MA_Slow_Method=0;
extern string _____MAS_Price_____="0=C; 1=O; 2=H; 3=L; 4=Med; 5=Typ; 6=Wt";
extern int    MA_Slow_Price=0;

//===== FXBay - MACD indicator parameters ===== 
extern string _____MACD_Params_____="MACD Parameters";
extern bool   MACD_Activate=true;
extern int    MACD_FastEMA=12;
extern int    MACD_SlowEMA=26;
extern int    MACD_SignalEMA=9;

//===== CCI indicator parameters ===== 
// CCI Price: 0=Close 1=Open 2=High 3=Low 4=Median 5=Typical 6=Weighted
extern string _____CCI_Params_____="CCI Parameters";
extern bool   CCI_Activate=true;
extern int    CCI_Period=21;
extern string _____CCI_Price_____="0=C; 1=O; 2=H; 3=L; 4=Med; 5=Typ; 6=Wt";
extern int    CCI_Price=0;

//===== ATR indicator parameters ===== 
extern string _____ATR_Params_____="ATR Multiples SL/TP";
extern int    ATR_Period=14;
extern double ATR_SL=1.5;
extern double ATR_TP1=1.5; // use 0 or negative value for no TP1
extern double ATR_TP2=2.5; // use 0 or negative value for no TP2

//===== Misc parameters =====
extern string _____Misc_Params_____ ="Misc Parameters";
extern int OrderMagicN1=1; // order magic number O1
extern bool AlertToggle=true; // true: sounds alert upon entry, false: no alert 

// Internal usage parameters:
string indicator_MACD="FXBay - MACD";

//---- buffers
int StopLoss;
int TakeProfit;
double Lots;
int OrderMagicN2;
bool orderlong,ordershort;
string comment="Decision Maker EA";
datetime ots,otl,lasttime;
double lotsmin,lotsmax;
double StopLossPoints,TakeProfitPoints;
int lotsprecision;
int Slippage=1;
string semaphorestring;
string teststring;
int ticketN1,ticketN2;
double ticketN1SL,ticketN1TP,ticketN1Lots,ticketN1Open;
double ticketN2SL,ticketN2TP,ticketN2Lots,ticketN2Open;
bool longOrders,shortOrders;
bool Order2Modify;
double spreadFilterAmountPoints;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//---- 
 semaphorestring="SEMAPHORE";
 teststring="TEST";

 if(IsTesting()) semaphorestring=StringConcatenate(semaphorestring,teststring);

 lotsmin=MarketInfo(Symbol(),MODE_MINLOT); 
 lotsmax=MarketInfo(Symbol(),MODE_MAXLOT); 

 if(lotsmin==1)         lotsprecision=0;
 else if(lotsmin==0.50) lotsprecision=1; // for PFG ECN
 else if(lotsmin==0.10) lotsprecision=1;
 else if(lotsmin==0.01) lotsprecision=2;
 else                   lotsprecision=1; 

 OrderMagicN2=OrderMagicN1*10; // order magic number O2

 if(StringFind(Symbol(),"JPY")>0) 
 {
  if(Digits==3)
  {
   StopLossPoints=NormPoints(StopLoss*10);
   TakeProfitPoints=NormPoints(TakeProfit*10);  
   spreadFilterAmountPoints=NormPoints(Spread_Filter_Amount*10);
  }
  else
  {
   StopLossPoints=NormPoints(StopLoss);
   TakeProfitPoints=NormPoints(TakeProfit);  
   spreadFilterAmountPoints=NormPoints(Spread_Filter_Amount);   
  }  
 }
 else
 {
  if(Digits==5)
  {
   StopLossPoints=NormPoints(StopLoss*10);
   TakeProfitPoints=NormPoints(TakeProfit*10);  
   spreadFilterAmountPoints=NormPoints(Spread_Filter_Amount*10);   
  }
  else
  {
   StopLossPoints=NormPoints(StopLoss);
   TakeProfitPoints=NormPoints(TakeProfit);  
   spreadFilterAmountPoints=NormPoints(Spread_Filter_Amount);    
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

 CheckNumberOrder();
 UpdateDataWindow();
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
 ManageOrders();
 if(lasttime==iTime(NULL,0,0)) return(0);
 Main();
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
 if(!TimeCheck(0)) return;
 if(!SpreadFilter()) return;
 
 double SL,TP,ATR,stop;
 string td;

 if(iBarShift(NULL,0,otl)>=Trigger_Window_Bars && EntryTrigger(true))
 {
  if(shortOrders) ExitAllOrders(false);
  
  ATR=iATR(NULL,0,ATR_Period,1);
  stop=NormDigits(ATR_SL*ATR);  
  SL=StopLong(Ask,stop);

  if(ATR_TP1>=0) TP=TakeLong(Ask,NormDigits(ATR_TP1*ATR));
  else TP=0;

  Lots=CalcLots(stop,Risk1);

  ticketN1=SendOrderLong(Symbol(),Lots,Slippage,0,0,comment,OrderMagicN1);     
  AddSLTP(SL,TP,ticketN1);

  ticketN1SL=SL;
  ticketN1TP=TP;

  if(Two_Orders)
  {
   Lots=CalcLots(stop,Risk2);

   if(ATR_TP2>=0) TP=TakeLong(Ask,NormDigits(ATR_TP2*ATR));  
   else TP=0;

   ticketN2=SendOrderLong(Symbol(),Lots,Slippage,0,0,comment,OrderMagicN2);     
   AddSLTP(SL,TP,ticketN2);
  }
  
  Order2Modify=true;   
  otl=TimeCurrent();
  td=TimeToStr(otl,TIME_DATE|TIME_MINUTES);
  if(AlertToggle) Alert("Decision Maker entered long: ",Symbol()," M",Period()," at",td);   
 } 
 
 if(iBarShift(NULL,0,ots)>=Trigger_Window_Bars && EntryTrigger(false))
 {
  if(longOrders) ExitAllOrders(true);
   
  ATR=iATR(NULL,0,ATR_Period,1); 
  stop=NormDigits(ATR_SL*ATR);   
  SL=StopShort(Bid,stop);

  if(ATR_TP1>=0) TP=TakeShort(Bid,NormDigits(ATR_TP1*ATR));
  else TP=0;
  
  Lots=CalcLots(stop,Risk1);

  ticketN1=SendOrderShort(Symbol(),Lots,Slippage,0,0,comment,OrderMagicN1);
  AddSLTP(SL,TP,ticketN1);

  ticketN1SL=SL;
  ticketN1TP=TP;
  
  if(Two_Orders)
  {
   Lots=CalcLots(stop,Risk2);  

   if(ATR_TP2>=0) TP=TakeShort(Bid,NormDigits(ATR_TP2*ATR));  
   else TP=0;

   ticketN2=SendOrderShort(Symbol(),Lots,Slippage,0,0,comment,OrderMagicN2);   
   AddSLTP(SL,TP,ticketN2);
  }

  Order2Modify=true; 
  ots=TimeCurrent();
  td=TimeToStr(ots,TIME_DATE|TIME_MINUTES);
  if(AlertToggle) Alert("Decision Maker entered short: ",Symbol()," M",Period()," at",td);
 } 

 return; 
}
//+------------------------------------------------------------------+
void ManageOrders()
{ 
 ClearParameters1();
 int trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 { 
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderMagicNumber()!=OrderMagicN1&&OrderMagicNumber()!=OrderMagicN2) continue;
  OrderStats();
 }
 if(longOrders||shortOrders)
 {
  if(lasttime!=iTime(NULL,0,0)) 
  {
   MAExit();
   if(ticketN1==0 && ticketN2>0 && Order2_MACD_Exit) MACDExit();
  }
  if(Order2Modify && Order2_Manage_Options>0 && ticketN1==0 && ticketN2>0) Order2Manage();
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
void ModifyCompLong(double stopcal, double stopcrnt, int ticketN)
{
 stopcal=NormDigits(stopcal);
 stopcrnt=NormDigits(stopcrnt);

 if (stopcal==stopcrnt) return;
 
 if(stopcal>stopcrnt)
 {
 
  if(stopcal>=Bid) // check whether s/l is too close to market
   return;
  
  OrderSelect(ticketN,SELECT_BY_TICKET);                   
  ModifyOrder(ticketN,OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Blue); 
 }
 return;
}
//+------------------------------------------------------------------+
void ModifyCompShort(double stopcal, double stopcrnt, int ticketN)
{
 stopcal=NormDigits(stopcal);
 stopcrnt=NormDigits(stopcrnt);

 if (stopcal==stopcrnt) return;
  
 if(stopcrnt==0)
 {

  if(stopcal<=Ask) // check whether s/l is too close to market
   return; 

  OrderSelect(ticketN,SELECT_BY_TICKET);     
  ModifyOrder(ticketN,OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red);     
 }
 else if(stopcal<stopcrnt&&stopcal!=0)
 {

  if(stopcal<=Ask) // check whether s/l is too close to market
   return; 

  OrderSelect(ticketN,SELECT_BY_TICKET); 
  ModifyOrder(ticketN,OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red); 
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
double CalcLots(double sl, double risk)
{
 double permitLoss=risk*0.01*AccountEquity();
 double pipSL=sl/Point;
 double valueSL=pipSL*MarketInfo(Symbol(),MODE_TICKVALUE);
 double lots=NormLots(permitLoss/valueSL);
 lots=MathMin(lots,NormalizeDouble(lotsmax,lotsprecision));
 return(lots);
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
void ExitAllOrders(bool long)
{
 if(long)
 {
  if(ticketN1>0) 
  {
   CloseOrderLong(ticketN1,ticketN1Lots,Slippage,Lime);
   ticketN1=0;
  }
  if(ticketN2>0) 
  {
   CloseOrderLong(ticketN2,ticketN2Lots,Slippage,Lime);
   ticketN2=0;
  }  
  longOrders=false;
 }
 else
 {
  if(ticketN1>0) 
  {
   CloseOrderShort(ticketN1,ticketN1Lots,Slippage,Lime);
   ticketN1=0;
  }
  if(ticketN2>0) 
  {
   CloseOrderShort(ticketN2,ticketN2Lots,Slippage,Lime);
   ticketN2=0;
  }  
  shortOrders=false;
 } 
 return;
}
//+------------------------------------------------------------------+ 
void ExitOrder2(bool long)
{
 if(long)
 {
  if(ticketN2>0) 
  {
   CloseOrderLong(ticketN2,ticketN2Lots,Slippage,Lime);
   ticketN2=0;
  }  
 }
 else
 {
  if(ticketN2>0) 
  {
   CloseOrderShort(ticketN2,ticketN2Lots,Slippage,Lime);
   ticketN2=0;
  }
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
void MAExit()
{  
 if(longOrders)       
 {
  if(Event_MA(false,1)) ExitAllOrders(true);
 }
 else if(shortOrders)       
 {   
  if(Event_MA(true,1)) ExitAllOrders(false); 
 }
 return;
}
//+------------------------------------------------------------------+
void MACDExit()
{  
 if(longOrders)       
 {
  if(Event_MACD(false,1)) ExitOrder2(true);
 }
 else if(shortOrders)       
 {   
  if(Event_MACD(true,1)) ExitOrder2(false); 
 }
 return;
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
int CheckNumberOrder()
{
 ClearParameters0();
 ClearParameters1();
 int trade,trades=OrdersTotal(),total=0; 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderMagicNumber()!=OrderMagicN1&&OrderMagicNumber()!=OrderMagicN2) continue;
  
  OrderStats();
  total++;
 }
 return(total);
}
//+------------------------------------------------------------------+
bool EntryTrigger(bool dir)
{
 if(dir)
 {
  if(longOrders) return(false);
 }
 else
 {
  if(shortOrders) return(false);
 }
 
 bool ma=false;
 bool macd=false;
 bool cci=false;
 int i=1;
 
 for(i=1;i<=Trigger_Window_Bars;i++)
 {
  if(Event_MA(dir,i))
  {
   if(Event_MA_Persist(dir,i))
   {
    ma=true;
    break;
   }
  }
 }

 if(MACD_Activate)
 {
  for(i=1;i<=Trigger_Window_Bars;i++)
  {
   if(Event_MACD(dir,i))
   {
    if(Event_MACD_Persist(dir,i))
    {
     macd=true;
     break;
    }
   }
  }
 }
 
 if(CCI_Activate)
 {
  for(i=1;i<=Trigger_Window_Bars;i++)
  {
   if(Event_CCI(dir,i))
   {
    if(Event_CCI_Persist(dir,i))
    {
     cci=true;
     break;
    }
   }
  }
 }
 
 if(ma)
 {

  if(MACD_Activate && CCI_Activate)
  {
   if(macd && cci) return(true);
   else return(false);
  }
 
  if(!MACD_Activate && !CCI_Activate)
  {
   return(true);
  }
 
  if(MACD_Activate && !CCI_Activate)
  {
   if(macd) return(true);
   else return(false);
  }
  
  if(!MACD_Activate && CCI_Activate)
  {
   if(cci) return(true);
   else return(false);
  }
    
 }
  
 return(false);
}
//+------------------------------------------------------------------+
bool Event_MA(bool dir, int i)
{
 double MAf2=iMA(NULL,0,MA_Fast_Period,MA_Fast_Shift,MA_Fast_Method,MA_Fast_Price,i+1);
 double MAf1=iMA(NULL,0,MA_Fast_Period,MA_Fast_Shift,MA_Fast_Method,MA_Fast_Price,i);
 double MAs2=iMA(NULL,0,MA_Slow_Period,MA_Slow_Shift,MA_Slow_Method,MA_Slow_Price,i+1); 
 double MAs1=iMA(NULL,0,MA_Slow_Period,MA_Slow_Shift,MA_Slow_Method,MA_Slow_Price,i);
 if(dir)
 {
  if(MAf2<=MAs2 && MAf1>MAs1) return(true);
  else return(false);
 }
 else
 {
  if(MAf2>=MAs2 && MAf1<MAs1) return(true);
  else return(false);
 }
 return(false);
}
//+------------------------------------------------------------------+
bool Event_MA_Persist(bool dir, int i)
{
 for(int j=1;j<i;j++)
 {
  double MAf2=iMA(NULL,0,MA_Fast_Period,MA_Fast_Shift,MA_Fast_Method,MA_Fast_Price,j+1);
  double MAf1=iMA(NULL,0,MA_Fast_Period,MA_Fast_Shift,MA_Fast_Method,MA_Fast_Price,j);
  double MAs2=iMA(NULL,0,MA_Slow_Period,MA_Slow_Shift,MA_Slow_Method,MA_Slow_Price,j+1); 
  double MAs1=iMA(NULL,0,MA_Slow_Period,MA_Slow_Shift,MA_Slow_Method,MA_Slow_Price,j);
  if(dir)
  {
   if(MAf2>=MAs2 && MAf1<MAs1) return(false);
  }
  else
  {
   if(MAf2<=MAs2 && MAf1>MAs1) return(false);
  }
 }
 return(true);
}
//+------------------------------------------------------------------+
bool Event_MACD(bool dir, int i)
{
 double MACD2=iCustom(NULL,0,indicator_MACD,MACD_FastEMA,MACD_SlowEMA,MACD_SignalEMA,2,i+1);
 double MACD1=iCustom(NULL,0,indicator_MACD,MACD_FastEMA,MACD_SlowEMA,MACD_SignalEMA,2,i);
 if(dir)
 {
  if(MACD2<=0 && MACD1>0) return(true);
  else return(false);
 }
 else
 {
  if(MACD2>=0 && MACD1<0) return(true);
  else return(false);
 }
 return(false);
}
//+------------------------------------------------------------------+
bool Event_MACD_Persist(bool dir, int i)
{
 for(int j=1;j<i;j++)
 {
  double MACD2=iCustom(NULL,0,indicator_MACD,MACD_FastEMA,MACD_SlowEMA,MACD_SignalEMA,2,j+1);
  double MACD1=iCustom(NULL,0,indicator_MACD,MACD_FastEMA,MACD_SlowEMA,MACD_SignalEMA,2,j);
  if(dir)
  {
   if(MACD2>=0 && MACD1<0) return(false);
  }
  else
  {
   if(MACD2<=0 && MACD1>0) return(false);
  }
 }
 return(true);
}
//+------------------------------------------------------------------+
bool Event_CCI(bool dir, int i)
{
 double CCI2=iCCI(NULL,0,CCI_Period,CCI_Price,i+1);
 double CCI1=iCCI(NULL,0,CCI_Period,CCI_Price,i);
 if(dir)
 {
  if(CCI2<=0 && CCI1>0) return(true);
  else return(false);
 }
 else
 {
  if(CCI2>=0 && CCI1<0) return(true);
  else return(false);
 }
 return(false); 
}
//+------------------------------------------------------------------+
bool Event_CCI_Persist(bool dir, int i)
{
 for(int j=1;j<i;j++)
 {
  double CCI2=iCCI(NULL,0,CCI_Period,CCI_Price,j+1);
  double CCI1=iCCI(NULL,0,CCI_Period,CCI_Price,j);
  if(dir)
  {
   if(CCI2>=0 && CCI1<0) return(false);
  }
  else
  {
   if(CCI2<=0 && CCI1>0) return(false);
  }
 }
 return(true); 
}
//+------------------------------------------------------------------+
void ClearParameters0() // clear only on initialization
{
 Order2Modify=true;
 otl=0;ots=0; 
 ticketN1SL=0;ticketN1TP=0;ticketN1Lots=0;
 ticketN2SL=0;ticketN2TP=0;ticketN2Lots=0;
 ticketN1Open=0;
 ticketN2Open=0;
 return;
}
//+------------------------------------------------------------------+
void ClearParameters1() // clear every cycle
{
 ticketN1=0;ticketN2=0;
 longOrders=false;shortOrders=false;
 return;
}
//+------------------------------------------------------------------+
void OrderStats()
{
 if(OrderMagicNumber()==OrderMagicN1)      
 {
  ticketN1=OrderTicket();
  ticketN1SL=OrderStopLoss();
  ticketN1TP=OrderTakeProfit();
  ticketN1Lots=OrderLots();
  ticketN1Open=OrderOpenPrice();  
 }
 else if(OrderMagicNumber()==OrderMagicN2) 
 {
  ticketN2=OrderTicket();
  ticketN2SL=OrderStopLoss();
  ticketN2TP=OrderTakeProfit();  
  ticketN2Lots=OrderLots();  
  ticketN2Open=OrderOpenPrice();
 }

 if(OrderType()==OP_BUY)       
 {
  otl=OrderOpenTime();
  longOrders=true;
 }
 else if(OrderType()==OP_SELL) 
 {
  ots=OrderOpenTime();
  shortOrders=true;
 }
 return;
}
//+------------------------------------------------------------------+
void Order2Manage()
{
 Order2Modify=false;
 double newSL=0;
 if(Order2_Manage_Options==3) // 1/2 O1 TP1
 {
  if(longOrders)newSL=NormalizeDouble(ticketN2Open+0.5*(ticketN1TP-ticketN1Open),Digits);
  else if(shortOrders) newSL=NormalizeDouble(ticketN2Open-0.5*(ticketN1Open-ticketN1TP),Digits);
 }
 else if(Order2_Manage_Options==2) // 1/2 initial SL
 {
  if(longOrders)newSL=NormalizeDouble(ticketN2Open-0.5*(ticketN2Open-ticketN2SL),Digits);
  else if(shortOrders) newSL=NormalizeDouble(ticketN2Open+0.5*(ticketN2SL-ticketN2Open),Digits);  
 }
 else // BE
 {
  newSL=ticketN2Open; 
 }
 
 if(longOrders)
 {
  ModifyCompLong(newSL,ticketN2SL,ticketN2);
 }
 else if(shortOrders)
 {
  ModifyCompShort(newSL,ticketN2SL,ticketN2);
 }

 return;
}
//+------------------------------------------------------------------+
bool TimeCheck(int i)
{
 if(!Use_Time_Window) return(true);
 datetime time=iTime(NULL,0,i);
 if(Start_Hour>End_Hour)
 {
  if(TimeHour(time)>Start_Hour||TimeHour(time)<End_Hour) return(true);
 }
 else
 {
  if(TimeHour(time)>Start_Hour&&TimeHour(time)<End_Hour) return(true); 
 }

 if(TimeHour(time)==Start_Hour)
 {
  if(TimeMinute(time)>=Start_Minute) return(true);
 }  
 else if(TimeHour(time)==End_Hour)
 {
  if(TimeMinute(time)<=End_Minute) return(true);
 } 
 
 return(false);
}
//+------------------------------------------------------------------+
bool SpreadFilter()
{
 if(!Use_Spread_Filter) return(true);
 if(NormDigits(Ask-Bid)>=spreadFilterAmountPoints) 
  return (false);
 
 return (true);
}
//+------------------------------------------------------------------+
void UpdateDataWindow()
{
 string info;
 string orders,order2MM,order2MACD,macd,cci;
 string Start_Minute_string,End_Minute_string;

 if(Two_Orders) orders="2";
 else           orders="1";

 if(MACD_Activate) macd="Active: ";
 else              macd="Inactive: ";

 if(CCI_Activate) cci="Active: ";
 else             cci="Inactive: "; 

 if(Order2_Manage_Options<=0) order2MM="Inactive ";
 else if(Order2_Manage_Options==3) order2MM="1/2 TP1 ";
 else if(Order2_Manage_Options==2) order2MM="1/2 SL ";
 else order2MM="BE ";

 if(Order2_MACD_Exit) order2MACD="Active ";
 else                 order2MACD="Inactive ";
 
 if(Start_Minute<10) Start_Minute_string=StringConcatenate("0",Start_Minute);
 else Start_Minute_string=DoubleToStr(Start_Minute,0);
 
 if(End_Minute<10) End_Minute_string=StringConcatenate("0",End_Minute);
 else End_Minute_string=DoubleToStr(End_Minute,0); 
 
 info = StringConcatenate("\nOrders per Entry: ",orders,
                          "\n\nRisk 1: ",DoubleToStr(Risk1,2),"%",
                          "\nRisk 2: ",DoubleToStr(Risk2,2),"%",
                          "\n\nSL  : ",DoubleToStr(ATR_SL,2)," x ATR",
                          "\nTP1: ",DoubleToStr(ATR_TP1,2)," x ATR",
                          "\nTP2: ",DoubleToStr(ATR_TP2,2)," x ATR",
                          "\n\nStart Time: ",Start_Hour,":",Start_Minute_string,
                          "\nEnd Time: ",End_Hour,":",End_Minute_string,
                          "\nTrigger Window: ",Trigger_Window_Bars,
                          "\nSpread Filter: ",Spread_Filter_Amount,
                          "\n\nMA Fast/Slow: ", MA_Fast_Period,"/",MA_Slow_Period,
                          "\nMACD: ",macd,MACD_FastEMA,",",MACD_SlowEMA,",",MACD_SignalEMA,
                          "\nCCI: ",cci,CCI_Period,
                          "\nATR: ",ATR_Period,
                          "\n\nO2 MACD Exit: ",order2MACD,
                          "\nO2 MM: ",order2MM,
                          "\n\nMagic Number O1: ",OrderMagicN1,
                          "\nMagic Number O2: ",OrderMagicN2);
 Comment(info);
 return;
}
//+------------------------------------------------------------------+


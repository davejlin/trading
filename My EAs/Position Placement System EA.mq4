//+----------------------------------------------------------------------+
//|                                            Position Placement EA.mq4 |
//|                                                         David J. Lin |
//| Position Placement EA                                                |
//| for Mike Skeffington                                                 |
//| mike@skeff.com                                                       |
//|                                                                      |
//| Coded by David J. Lin (dave.j.lin@gmail.com)                         |
//| Evanston, IL, March 21-31, 2012                                      |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2012, Mike Skeffington and David J. Lin"

// External usage parameters:
//===== Order parameters =====
extern string _____Order_Params_____="Order Parameters";
extern bool Long=false;  // true = submit long orders
extern bool Short=false; // true = submit short orders 
extern bool Order1=true; // true = submit trade 1
extern bool Order2=true; // true = submit trade 2
extern bool Order3=true; // true = submit trade 3
extern bool Order4=true; // true = submit trade 4

//===== Risk parameters ===== 
extern string _____Risk_Params_____ ="Risk Percentage";
extern double Risk1=1.25; // O1 risk
extern double Risk2=1.25; // O2 risk
extern double Risk3=1.25; // O3 risk
extern double Risk4=1.25; // O4 risk

//===== ATR indicator parameters ===== 
extern string _____ATR_Params_____="ATR Multiples SL/TP";
extern int    ATR_Period=14;
extern double ATR_SL=1.5;
extern double ATR_TP1=1.5; // use 0 or negative value for no TP1
extern double ATR_TP2=2.5; // use 0 or negative value for no TP2
extern double ATR_TP3=3.5; // use 0 or negative value for no TP3
extern double ATR_TP4=4.5; // use 0 or negative value for no TP4

//===== Order Money Management parameters ===== 
extern string _____Order_MM_____ ="Order MM Parameters";
extern int MMOrderN=1; // order number of the basis for MM (Order 1, 2, 3, or 4) - "sliding basis"
extern string _____Order_Options ="0=none; 1=BE; 2=half SL; 3=half TP";
extern int Order_Manage_Options=1; // When OrderN TPs, other Orders SL Management - 0) Inactive, 1) SL to BE, 2) SL to 1/2 initial SL, 3) SL to 1/2 TP

//===== Misc parameters =====
extern string _____Misc_Params_____ ="Misc Parameters";
extern int OrderMagicN1=1; // order magic number for Order 1 (magic numbers for Order 2, 3, and 4 are +1 increments from Order 1's magic number)

//---- buffers
double Lots;
bool orderlong,ordershort;
string comment="PPS EA";
datetime ots,otl,lasttime;
double lotsmin,lotsmax;
int lotsprecision;
int Slippage=1;
string semaphorestring;
string teststring;
bool deactivateEA;
int ticketN1,ticketN2,ticketN3,ticketN4;
double ticketN1TP,ticketN2TP,ticketN3TP,ticketN4TP;
double ticketN1SL,ticketN2SL,ticketN3SL,ticketN4SL;
bool longOrders,shortOrders;
int nOrders;
int OrderMagicN2,OrderMagicN3,OrderMagicN4;
bool OrderMMModify;
double ticketMMOpen,ticketMMTP,ticketMMSL;
int ticketMM;
double ticketMMSL_A,ticketMMSL_B,ticketMMSL_C;
int ticketMM_A,ticketMM_B,ticketMM_C;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
 deactivateEA=false;
 if(Long && Short) 
 {
  Alert("*** WARNING: Both Long and Short are selected! EA deactivating! ***");
  deactivateEA=true;
  return(0);
 }
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
 
 nOrders=0;
 if(Order1) nOrders++;
 if(Order2) nOrders++;
 if(Order3) nOrders++;
 if(Order4) nOrders++;   
 
 OrderMagicN2=OrderMagicN1+1;
 OrderMagicN3=OrderMagicN1+2;
 OrderMagicN4=OrderMagicN1+3;
 
      if(MMOrderN<1) MMOrderN=1;
 else if(MMOrderN>4) MMOrderN=4;
 
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
 if(deactivateEA) return(0);     
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
 if(!Long && !Short) return;
 if(longOrders || shortOrders) return;
 
 double SL,TP,ATR,stop;
 string td;

 ATR=iATR(NULL,0,ATR_Period,1); 
 stop=NormDigits(ATR_SL*ATR);

 if(Long)
 {
  SL=StopLong(Ask,stop);  

  if(Order1)
  { 
   if(ATR_TP1>=0) TP=TakeLong(Ask,NormDigits(ATR_TP1*ATR));
   else TP=0;

   Lots=CalcLots(stop,Risk1);

   ticketN1=SendOrderLong(Symbol(),Lots,Slippage,0,0,comment,OrderMagicN1);
   AddSLTP(SL,TP,ticketN1);

   ticketN1TP=TP;
   ticketN1SL=SL;
  }
  
  if(Order2)
  { 
   if(ATR_TP2>=0) TP=TakeLong(Ask,NormDigits(ATR_TP2*ATR));  
   else TP=0;

   Lots=CalcLots(stop,Risk2);

   ticketN2=SendOrderLong(Symbol(),Lots,Slippage,0,0,comment,OrderMagicN2);
   AddSLTP(SL,TP,ticketN2);

   ticketN2TP=TP;   
   ticketN2SL=SL;   
  }
  
  if(Order3)
  { 
   if(ATR_TP3>=0) TP=TakeLong(Ask,NormDigits(ATR_TP3*ATR));  
   else TP=0;

   Lots=CalcLots(stop,Risk3);

   ticketN3=SendOrderLong(Symbol(),Lots,Slippage,0,0,comment,OrderMagicN3);
   AddSLTP(SL,TP,ticketN3);

   ticketN3TP=TP;
   ticketN3SL=SL;   
  }  

  if(Order4)
  { 
   if(ATR_TP4>=0) TP=TakeLong(Ask,NormDigits(ATR_TP4*ATR));  
   else TP=0;

   Lots=CalcLots(stop,Risk4);

   ticketN4=SendOrderLong(Symbol(),Lots,Slippage,0,0,comment,OrderMagicN4);
   AddSLTP(SL,TP,ticketN4);
   
   ticketN4TP=TP;   
   ticketN4SL=SL;   
  }

  AssignMMOrderN();
  
  longOrders=true;
  otl=TimeCurrent();
  td=TimeToStr(otl,TIME_DATE|TIME_MINUTES);
 } 
 else if(Short)
 {   
  SL=StopShort(Bid,stop);

  if(Order1)
  {
   if(ATR_TP1>=0) TP=TakeShort(Bid,NormDigits(ATR_TP1*ATR));
   else TP=0;
  
   Lots=CalcLots(stop,Risk1);

   ticketN1=SendOrderShort(Symbol(),Lots,Slippage,0,0,comment,OrderMagicN1);
   AddSLTP(SL,TP,ticketN1);

   ticketN1TP=TP;
   ticketN1SL=SL;   
  }
  
  if(Order2)
  {  
   if(ATR_TP2>=0) TP=TakeShort(Bid,NormDigits(ATR_TP2*ATR));  
   else TP=0;

   Lots=CalcLots(stop,Risk2);

   ticketN2=SendOrderShort(Symbol(),Lots,Slippage,0,0,comment,OrderMagicN2);
   AddSLTP(SL,TP,ticketN2);

   ticketN2TP=TP;   
   ticketN2SL=SL;   
  }

  if(Order3)
  {  
   if(ATR_TP3>=0) TP=TakeShort(Bid,NormDigits(ATR_TP3*ATR));  
   else TP=0;

   Lots=CalcLots(stop,Risk3);

   ticketN3=SendOrderShort(Symbol(),Lots,Slippage,0,0,comment,OrderMagicN3);
   AddSLTP(SL,TP,ticketN3);

   ticketN3TP=TP;   
   ticketN3SL=SL;   
  }

  if(Order4)
  {  
   if(ATR_TP4>=0) TP=TakeShort(Bid,NormDigits(ATR_TP4*ATR));  
   else TP=0;

   Lots=CalcLots(stop,Risk4);

   ticketN4=SendOrderShort(Symbol(),Lots,Slippage,0,0,comment,OrderMagicN4);
   AddSLTP(SL,TP,ticketN4);

   ticketN4TP=TP;   
   ticketN4SL=SL;   
  }

  AssignMMOrderN();

  shortOrders=true;
  ots=TimeCurrent();
  td=TimeToStr(ots,TIME_DATE|TIME_MINUTES);
 } 

 return; 
}
//+------------------------------------------------------------------+
void ManageOrders()
{ 
 if(!OrderMMModify) return;
 OrderSelect(ticketMM,SELECT_BY_TICKET);
 if(OrderCloseTime()==0) return;
 OrderMMManage();
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
int CheckNumberOrder()
{
 ClearParameters();
 int trade,trades=OrdersTotal(),total=0; 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderComment()!=comment) continue;
  if(OrderMagicNumber()!=OrderMagicN1&&OrderMagicNumber()!=OrderMagicN2
   &&OrderMagicNumber()!=OrderMagicN3&&OrderMagicNumber()!=OrderMagicN4) continue;
  
  OrderStats();
  total++;
 }
 
 if(total==nOrders) AssignMMOrderN(); // only need to do if all orders still open 
 
 return(total);
}
//+------------------------------------------------------------------+
void ClearParameters() // clear only on initialization
{
 otl=0;ots=0; 
 ticketN1TP=0;ticketN2TP=0;ticketN3TP=0;ticketN4TP=0;
 ticketN1=0;ticketN2=0;ticketN3=0;ticketN4=0;
 longOrders=false;shortOrders=false; 
 OrderMMModify=false;
 ticketMM=0;
 ticketMMTP=0;ticketMMSL=0;ticketMMOpen=0;
 ticketMM_A=0;ticketMM_B=0;ticketMM_C=0;
 ticketMMSL_A=0;ticketMMSL_B=0;ticketMMSL_C=0; 
 return;
}
//+------------------------------------------------------------------+
void OrderStats()
{
 if(OrderMagicNumber()==OrderMagicN1)      
 {
  ticketN1=OrderTicket();
  ticketN1TP=OrderTakeProfit();
  ticketN1SL=OrderStopLoss();  
 }
 else if(OrderMagicNumber()==OrderMagicN2) 
 {
  ticketN2=OrderTicket();
  ticketN2TP=OrderTakeProfit();
  ticketN2SL=OrderStopLoss();  
 }
 else if(OrderMagicNumber()==OrderMagicN3) 
 {
  ticketN3=OrderTicket();
  ticketN3TP=OrderTakeProfit();
  ticketN3SL=OrderStopLoss();  
 }
 else if(OrderMagicNumber()==OrderMagicN4) 
 {
  ticketN4=OrderTicket();
  ticketN4TP=OrderTakeProfit();
  ticketN4SL=OrderStopLoss();  
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
void OrderMMManage()
{
 OrderMMModify=false;
 if(Order_Manage_Options==0) return;
 
 double newSL=0;
 if(Order_Manage_Options==3) // 1/2 O1 TP1
 {
  if(longOrders)newSL=NormalizeDouble(ticketMMOpen+0.5*(ticketMMTP-ticketMMOpen),Digits);
  else if(shortOrders) newSL=NormalizeDouble(ticketMMOpen-0.5*(ticketMMOpen-ticketMMTP),Digits);
 }
 else if(Order_Manage_Options==2) // 1/2 initial SL
 {
  if(longOrders)newSL=NormalizeDouble(ticketMMOpen-0.5*(ticketMMOpen-ticketMMSL),Digits);
  else if(shortOrders) newSL=NormalizeDouble(ticketMMOpen+0.5*(ticketMMSL-ticketMMOpen),Digits);  
 }
 else // BE
 {
  newSL=ticketMMOpen; 
 }
 
 if(longOrders)
 {
  if(ticketMM_A>0) ModifyCompLong(newSL,ticketMMSL_A,ticketMM_A);
  if(ticketMM_B>0) ModifyCompLong(newSL,ticketMMSL_B,ticketMM_B);
  if(ticketMM_C>0) ModifyCompLong(newSL,ticketMMSL_C,ticketMM_C);    
 }
 else if(shortOrders)
 {
  if(ticketMM_A>0) ModifyCompShort(newSL,ticketMMSL_A,ticketMM_A);
  if(ticketMM_B>0) ModifyCompShort(newSL,ticketMMSL_B,ticketMM_B);
  if(ticketMM_C>0) ModifyCompShort(newSL,ticketMMSL_C,ticketMM_C);
 }

 return;
}
//+------------------------------------------------------------------+
void AssignMMOrderN()
{
 OrderMMModify=true;
 switch(MMOrderN)
 {
  case 1: ticketMM=ticketN1;
          ticketMM_A=ticketN2;
          ticketMM_B=ticketN3;
          ticketMM_C=ticketN4;
          ticketMMSL_A=ticketN2SL;
          ticketMMSL_B=ticketN3SL;
          ticketMMSL_C=ticketN4SL;
          break;
  case 2: ticketMM=ticketN2; 
          ticketMM_A=ticketN1;
          ticketMM_B=ticketN3;
          ticketMM_C=ticketN4;
          ticketMMSL_A=ticketN1SL;
          ticketMMSL_B=ticketN3SL;
          ticketMMSL_C=ticketN4SL;  
          break;
  case 3: ticketMM=ticketN3; 
          ticketMM_A=ticketN1;
          ticketMM_B=ticketN2;
          ticketMM_C=ticketN4;
          ticketMMSL_A=ticketN1SL;
          ticketMMSL_B=ticketN2SL;
          ticketMMSL_C=ticketN4SL;
          break;
  case 4: ticketMM=ticketN4;
          ticketMM_A=ticketN1;
          ticketMM_B=ticketN2;
          ticketMM_C=ticketN3;
          ticketMMSL_A=ticketN1SL;
          ticketMMSL_B=ticketN2SL;
          ticketMMSL_C=ticketN3SL;  
          break;
  default:ticketMM=ticketN1;
          ticketMM_A=ticketN2;
          ticketMM_B=ticketN3;
          ticketMM_C=ticketN4;
          ticketMMSL_A=ticketN2SL;
          ticketMMSL_B=ticketN3SL;
          ticketMMSL_C=ticketN4SL;
          break;
 }
 
 OrderSelect(ticketMM,SELECT_BY_TICKET);
 
 ticketMMOpen=OrderOpenPrice();
 ticketMMSL=OrderStopLoss();
 ticketMMTP=OrderTakeProfit();
 
 return;
}
//+------------------------------------------------------------------+
void UpdateDataWindow()
{
 string info;
 
 info = StringConcatenate("\nOrders per Entry: ",nOrders,
                        "\n\nRisk 1: ",DoubleToStr(Risk1,2),"%",
                          "\nRisk 2: ",DoubleToStr(Risk2,2),"%",
                          "\nRisk 3: ",DoubleToStr(Risk3,2),"%",
                          "\nRisk 4: ",DoubleToStr(Risk4,2),"%",                                                    
                          "\n\nSL  : ",DoubleToStr(ATR_SL,2)," x ATR",
                          "\nTP1: ",DoubleToStr(ATR_TP1,2)," x ATR",
                          "\nTP2: ",DoubleToStr(ATR_TP2,2)," x ATR",
                          "\nTP3: ",DoubleToStr(ATR_TP3,2)," x ATR",
                          "\nTP4: ",DoubleToStr(ATR_TP4,2)," x ATR",
                          "\n\nMMOrderN: ",DoubleToStr(MMOrderN,0),
                          "\nO1 Magic N: ",DoubleToStr(OrderMagicN1,0));
 Comment(info);
 return;
}
//+------------------------------------------------------------------+


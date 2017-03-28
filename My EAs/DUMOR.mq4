//+----------------------------------------------------------------------+
//|                                                            DUMOR.mq4 |
//|                                                         David J. Lin |
//| DUMOR lots progression method                                        |
//| by George Miller (tgmgetsmail@gmail.com)                             |
//|                                                                      |
//| Coded by David J. Lin (dave.j.lin@gmail.com)                         |
//| Evanston, IL, February 3, 2011                                       |
//|                                                                      |
//| v1.0 completed February 16, 2011                                     |
//| v1.1 update April 10, 2011 (spread limit, resume from last closed    |
//|      trade, exact price info output display)                         |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2011, George Miller and David J. Lin"
#include <WinUser32.mqh>

// Internal usage parameters:
//---- input parameters
extern string __________ID_Number="*** Unique Trade Set ID Number ***";
extern int Trade_Set_ID_Number=1; // choose unique magic number ID for EA's trade set

extern string __________Entry_Method="*** Entry Method ***";

extern bool Use_Entry_Market_Order=false; // true: use market order entry
extern bool Use_Entry_Trade_Time=false; // true; use time entry
extern bool Use_Entry_Exact_Price=false; // true: use exact price entry

extern bool Resume_From_Last_Closed_Trade=false; // true: resume from last closed trade

extern string __________First_Direction="*** First Direction for Time and Price Entries ***";

extern bool First_Long=false;   // true: first order is BUY, 
extern bool First_Short=false; // true: first order is SELL

extern string __________SL_TP="*** SL TP Parameters ***";

extern int Stop_Loss_Martingale=10; // pips stop loss for the Martingale selection
extern int Take_Profit_Martingale=10; // pips take profit for the Martingale selection

extern int Stop_Loss_Custom_Prog=10; // pips stop loss the Custom Progression selection
extern int Take_Profit_Custom_Prog=40; // pips take profit the Custom Progression selection

extern int Stop_Loss_Extra=0; // extra pips stop loss
extern int Take_Profit_Extra=0; // extra pips take profit

extern string __________Time_Entry="*** Time Entry Parameters ***";

// Entry Open Time parameters

extern bool  Use_Trade_Time1=true; // true: use time window 1
extern string Start_Time1="0:00"; // start time for time window 1
extern string Stop_Time1="2:00"; // stop time for time window 1
extern bool  Use_Trade_Time2=false; // time window 2
extern string Start_Time2="4:00";
extern string Stop_Time2="6:00";
extern bool  Use_Trade_Time3=false; // time window 3
extern string Start_Time3="8:00";
extern string Stop_Time3="10:00";
extern bool  Use_Trade_Time4=false; // time window 4
extern string Start_Time4="12:00";
extern string Stop_Time4="14:00";
extern bool  Use_Trade_Time5=false; // time window 5
extern string Start_Time5="16:00";
extern string Stop_Time5="18:00";
extern bool  Use_Trade_Time6=false; // time window 6
extern string Start_Time6="20:00";
extern string Stop_Time6="22:00";

extern bool Use_Pips_From_Open_Price=false; // true: use Pips_From_Open_Price, false: enter at Open Price
extern int  Pips_From_Open_Price=10; // enter long or short depending on direction from the open of Start_Time, must be greater than 0

extern string __________Price_Entry="*** Exact Price Entry Parameter ***";

// Entry Exact Price parameter
extern double Exact_Entry_Price=1.60000; // exact entry price 

extern string __________Cycle_Rev_BE="*** Cycle & Break Even Parameters ***";

extern int Break_Even_at_N=5; // progression level in each cycle after which to seek break-even (set to 0 or neg value to disable BE)
extern int Reverse_at_N=0;  // reverse trade logic after N trades into a cycle (set to 0 or neg value to disable Reversal at N)
extern int Max_Trade_Cycles=2; // maximum number of trade cycles

extern string __________Lots_Progressions="*** Lots & Progressions Parameters ***";

// Lots and Progressions parameters
extern double Lot_Size_Multiplier=2; // multiplier for Martingale Progression
extern double First_Lot_Size=0.10; // initial lot size for Martingale Progression
extern double Last_Lot_Size =25.60; // final lot size for Martingale Progression

extern bool   Use_Custom_Lot_Progression=false; // true: use Custom Progression, false: use Martingale Progession
extern string Custom_Lot_Progression="0.1;0.1;0.2;0.3;0.4;0.6;0.8;1.1;1.5;2.0;2.7;3.6;4.7;6.2;8.0;10.2;13.0;16.5;20.8;26.3;33.1;41.6;52.2;65.5;82.5;103.9;130.9;165;207.9;262;330.1;416;524.7;661.1";

extern string __________Misc="*** Misc Parameters ***";

extern bool Hide_EA_Comment=true; // true: omit “DUMOR” from comment line
extern int Slippage=6; // slippage
extern int BufferPips=1; // pips to buffer price entries, positive = stop entry case, negative = limit entry case 
extern int SpreadLimit=5; // pips to limit spread widening, after which to dialog user whether to resume or hibernate
  
//---- buffers
bool orderlong,ordershort,triggered;
string EAName;
datetime ots,otl,lasttime;
double lotsmin,lotsmax;
double Stop_Loss,Take_Profit;
double StopLossPoints,TakeProfitPoints;
double StopLossExtraPoints,TakeProfitExtraPoints;
double PointsFromOpenPrice;
int lotsprecision;
double BufferPoints; // points to buffer price entries
double precisionmultiplier; // for spread output
int precisiondigits; // for spread output
double SpreadLimitAmount; // for spread limit

string semaphorestring;
string teststring;
string timename;
string IDName,IDNamePeriod,IDNameComment;
string directionfirststring,directionnextstring;
string maxprogstring,maxcyclestring;
string reverseNstring,breakevenNstring;
string initlotstring;
string commentsectionstring;
string entrymethodstring;

double Lots[]; // array holding lots
int MaxProgLevels; // maximum number of progression levels
bool Disable; // primary disable switch 
bool EnterLong=false,EnterShort=false; // main toggle controls for long and short entries
bool TradeWindowOpen; // main toggle for trade window 
bool TradeWindowSubmit; // true upon first bar of trade window's start time 
int TradeWindowIndex; // index of current open trade window
bool UseTradeTime[6]; // array holding Use_Trade_Time toggles
int StartTime[2,6]; // array holding Start_Time hour (0) and minute (1) 
int StopTime[2,6]; // array holding Stop_Time hour (0) and minute (1)
double EnterTimePrice; // price of open time to track
bool inplay[2]; // order in play toggles, this tick (0), last tick (1)
int OrderDirection; // direction of last order, long (1), short (-1)
int OrderCycle; // cycle of last order
int OrderCycleInit; // cycle of initial order 
int OrderTicketN; // ticket number of last order 
double OrderPoints; // points result of last order
int OrderProg; // level of progression of last order  
int OrderProgInit; // level of progression of initial order
int OrderTradeWindow; // index of time window of last order
double OrderTradeLossPast; // dollar loss up to last order
double OrderTradeLoss; // dollar loss including latest loss
double OrderTradeLossInit; // dollar loss including latest loss to use for initial order
double OrderPL; // profit/loss of last order
double takeInit; // take for resume from last closed order function
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//---- 
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

 EAName="DUMOR";
 semaphorestring="SEMAPHORE";
 teststring="TEST";
  
 if(IsTesting()) 
 {
  semaphorestring=StringConcatenate(semaphorestring,teststring);
  IDName=StringConcatenate(teststring," ",Symbol()," ID# ",DoubleToStr(Trade_Set_ID_Number,0));
  IDNamePeriod=StringConcatenate(teststring," ",Symbol()," ",timename," ID# ",DoubleToStr(Trade_Set_ID_Number,0));
  IDNameComment=StringConcatenate(teststring,StringSubstr(Symbol(),0,1),StringSubstr(Symbol(),3,1),"#",DoubleToStr(Trade_Set_ID_Number,0));
 }
 else
 {
  IDName=StringConcatenate(Symbol()," ID# ",DoubleToStr(Trade_Set_ID_Number,0));
  IDNamePeriod=StringConcatenate(Symbol()," ",timename," ID# ",DoubleToStr(Trade_Set_ID_Number,0));
  IDNameComment=StringConcatenate(StringSubstr(Symbol(),0,1),StringSubstr(Symbol(),3,1),"#",DoubleToStr(Trade_Set_ID_Number,0));
 }
 
 Disable=CheckConflict();
 if(Disable)
 {
  SetDisable();
  return;
 } 
 
 lotsmin=MarketInfo(Symbol(),MODE_MINLOT); 
 lotsmax=MarketInfo(Symbol(),MODE_MAXLOT); 

 if(lotsmin==1)         lotsprecision=0;
 else if(lotsmin==0.50) lotsprecision=1;
 else if(lotsmin==0.10) lotsprecision=1;
 else if(lotsmin==0.01) lotsprecision=2;
 else                   lotsprecision=1; 

 if(Use_Custom_Lot_Progression) 
 {
  Stop_Loss=Stop_Loss_Custom_Prog;
  Take_Profit=Take_Profit_Custom_Prog;  
 }
 else
 {
  Stop_Loss=Stop_Loss_Martingale;
  Take_Profit=Take_Profit_Martingale; 
 }

 if(StringFind(Symbol(),"JPY")>0) 
 {
  if(Digits==3)
  {
   StopLossPoints=NormPoints(Stop_Loss*10);
   TakeProfitPoints=NormPoints(Take_Profit*10);  
   StopLossExtraPoints=NormPoints(Stop_Loss_Extra*10);
   TakeProfitExtraPoints=NormPoints(Take_Profit_Extra*10); 
   PointsFromOpenPrice=NormPoints(Pips_From_Open_Price*10); 
   BufferPoints=NormPoints(BufferPips*10);
   precisionmultiplier=0.1;
   precisiondigits=1;
   SpreadLimitAmount=SpreadLimit*10;
  }
  else
  {
   StopLossPoints=NormPoints(Stop_Loss);
   TakeProfitPoints=NormPoints(Take_Profit);
   StopLossExtraPoints=NormPoints(Stop_Loss_Extra);
   TakeProfitExtraPoints=NormPoints(Take_Profit_Extra); 
   PointsFromOpenPrice=NormPoints(Pips_From_Open_Price); 
   BufferPoints=NormPoints(BufferPips);
   precisionmultiplier=1.0;  
   precisiondigits=0;
   SpreadLimitAmount=SpreadLimit;             
  }  
 }
 else
 {
  if(Digits==5)
  {
   StopLossPoints=NormPoints(Stop_Loss*10);
   TakeProfitPoints=NormPoints(Take_Profit*10); 
   StopLossExtraPoints=NormPoints(Stop_Loss_Extra*10);
   TakeProfitExtraPoints=NormPoints(Take_Profit_Extra*10);
   PointsFromOpenPrice=NormPoints(Pips_From_Open_Price*10); 
   BufferPoints=NormPoints(BufferPips*10); 
   precisionmultiplier=0.1;    
   precisiondigits=1;    
   SpreadLimitAmount=SpreadLimit*10;       
  }
  else
  {
   StopLossPoints=NormPoints(Stop_Loss);
   TakeProfitPoints=NormPoints(Take_Profit);
   StopLossExtraPoints=NormPoints(Stop_Loss_Extra);
   TakeProfitExtraPoints=NormPoints(Take_Profit_Extra);
   PointsFromOpenPrice=NormPoints(Pips_From_Open_Price);
   BufferPoints=NormPoints(BufferPips); 
   precisionmultiplier=1.0;  
   precisiondigits=0;
   SpreadLimitAmount=SpreadLimit;                
  }  
 } 

 InitializeGV();
   
 triggered=false;
 if(CheckNumberOrder()>0) 
 {
  if(CheckRestart()) triggered=true; 
  else 
  {
   SetDisable();
   return;
  }
 }
 
 MaxProgLevels=InitializeLots();
 if(Use_Entry_Trade_Time) InitializeTradeTimes();
 InitializeVariables();

 maxprogstring=StringConcatenate(" (",DoubleToStr(MaxProgLevels,0),") ");
 maxcyclestring=StringConcatenate(" (",DoubleToStr(Max_Trade_Cycles,0),") ");
 reverseNstring=DoubleToStr(Reverse_at_N,0);
 breakevenNstring=DoubleToStr(Break_Even_at_N,0);
 initlotstring=DoubleToStr(Lots[0],lotsprecision);
 commentsectionstring=StringConcatenate("\nReverse Logic # ",reverseNstring,
                                        "\nBreak Even # ",breakevenNstring,
                                        "\nInit Lots = ",initlotstring);
 if(Use_Entry_Market_Order) entrymethodstring="\nMarket Order Entry";
 else if(Use_Entry_Trade_Time&&Use_Entry_Exact_Price) entrymethodstring="\nTrade Time and Exact Price Entry";
 else if(Use_Entry_Trade_Time) 
 {
  if(Use_Pips_From_Open_Price) entrymethodstring="\nTrade Time Entry: Pips from Open";
  else entrymethodstring="\nTrade Time Entry: at Open";
 }
 else entrymethodstring="\nExact Price Entry";
 
// Alert("Levels: "+proglevels);
// for(int i=0;i<proglevels;i++) Alert(Lots[i]);
  
 if(Resume_From_Last_Closed_Trade)
 {
  if(!triggered) 
  {
   int input=MessageBox(IDName+" \nVerify Resume From Last Closed Trade \n\nYes = Resume from last closed trade\nNo  = Start fresh with brand new trade-sets", WindowExpertName()+" Resume From Last Closed Trade", MB_YESNO|MB_ICONQUESTION|MB_DEFBUTTON1); 
   if(input==IDYES) CheckLastClosedTrade();   
   else ResetInit();
  }
  else ResetInit();
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
  GlobalVariableDel(directionfirststring); 
  GlobalVariableDel(directionnextstring);     
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
 if(Disable) 
 {
  Comment(IDNamePeriod);
  return(0);
 }
 
 if(lasttime!=iTime(NULL,0,0))
 {
  if(Use_Entry_Trade_Time) CheckTradeWindow();
 }
 lasttime=iTime(NULL,0,0);
  
 Main();
 ManageOrders();
  
 UpdateDataWindow(); 
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

 double stop,take; 
 EnterLong=false;EnterShort=false;

 if(Use_Entry_Market_Order) MarketOrderVerify();
 else if(Use_Entry_Trade_Time) TimeOrderVerify();
 else if(Use_Entry_Exact_Price) PriceOrderVerify();

 if(EnterLong)
 { 
  OrderProg=OrderProgInit;
  OrderCycle=OrderCycleInit; 
  OrderTradeLossPast=OrderTradeLossInit;
  OrderTradeLoss=OrderTradeLossInit;  
 
  stop=NormDigits(StopLossPoints+StopLossExtraPoints);
  
  if(Resume_From_Last_Closed_Trade) take=takeInit;
  else take=NormDigits(TakeProfitPoints+TakeProfitExtraPoints); 

  Submit(true,Lots[OrderProg-1],stop,take,OrderProg,OrderCycle,TradeWindowIndex,OrderTradeLoss); // prog starts at 1

  SetGV(directionfirststring,0);
  SetGV(directionnextstring,0);
  
  ResetInit();
 } 
 
 if(EnterShort)
 { 
  OrderProg=OrderProgInit;
  OrderCycle=OrderCycleInit; 
  OrderTradeLossPast=OrderTradeLossInit;
  OrderTradeLoss=OrderTradeLossInit;
   
  stop=NormDigits(StopLossPoints+StopLossExtraPoints);
  
  if(Resume_From_Last_Closed_Trade) take=takeInit;
  else take=NormDigits(TakeProfitPoints+TakeProfitExtraPoints); 

  Submit(false,Lots[OrderProg-1],stop,take,OrderProg,OrderCycle,TradeWindowIndex,OrderTradeLoss); // prog starts at 1

  SetGV(directionfirststring,0);
  SetGV(directionnextstring,0);
  
  ResetInit();
 } 

 return; 
}
//+------------------------------------------------------------------+

void ManageOrders()
{ 
 triggered=false;
 inplay[0]=false;
 
 int trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 { 
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderMagicNumber()!=Trade_Set_ID_Number) continue;  
  triggered=true;
  inplay[0]=true;
  TakeOrderStats(0);
  break; 
 }
 
 if(!inplay[0]&&inplay[1]) ResponseOrder();
 if(!inplay[0]&&!inplay[1]) OrderTicketN=0; // must be before inplay[1]=inplay[0]; to avoid error 4105 in info output section
  
 inplay[1]=inplay[0];
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
void Submit(bool long, double lots, double stop, double take, int prog, int cycle, int tradewindow, double loss)
{
 string comment;
 double SL,TP,EP;
 
 if(CheckSpreadLimit()) return;

 if(long)
 {  
  comment=PrepareComment(prog,cycle,tradewindow,loss);

  OrderTicketN=SendOrderLong(Symbol(),lots,Slippage,0,0,comment,Trade_Set_ID_Number);     
  
  OrderSelect(OrderTicketN,SELECT_BY_TICKET);
  EP=OrderOpenPrice();
  
  SL=StopLong(EP,stop);
  TP=TakeLong(EP,take);  
  
  AddSLTP(SL,TP,OrderTicketN);

  otl=TimeCurrent();  
  triggered=true;
 }
 else
 { 
  comment=PrepareComment(prog,cycle,tradewindow,loss); 

  OrderTicketN=SendOrderShort(Symbol(),lots,Slippage,0,0,comment,Trade_Set_ID_Number);   

  OrderSelect(OrderTicketN,SELECT_BY_TICKET);
  EP=OrderOpenPrice();
  
  SL=StopShort(EP,stop);
  TP=TakeShort(EP,take);
  
  AddSLTP(SL,TP,OrderTicketN);

  ots=TimeCurrent();
  triggered=true; 
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
 if(lotsmin==0.50)
 {
  int lotmod=lots/lotsmin;
  lots=lotmod*lotsmin; // increments of 0.50 lots
 }

 return(MathMax(NormalizeDouble(lotsmin,lotsprecision),NormalizeDouble(lots,lotsprecision)));
}
//+------------------------------------------------------------------+
double TakeLong(double price,double take)
{
 if(take==0) return(0);
 return(NormDigits(price+take)); 
}
//+------------------------------------------------------------------+
double TakeShort(double price,double take)
{
 if(take==0) return(0);
 return(NormDigits(price-take)); 
}
//+------------------------------------------------------------------+
double StopShort(double price,double stop)
{
 if(stop==0) return(0);
 return(NormDigits(price+stop)); 
}
//+------------------------------------------------------------------+
double StopLong(double price,double stop)
{
 if(stop==0) return(0);
 return(NormDigits(price-stop)); 
}
//+------------------------------------------------------------------+
double CalcPoints(int direction, double entry, double exit)
{
 if(direction>0) return(NormDigits(exit-entry));
 else if(direction<0) return(NormDigits(entry-exit));
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
 int trade,trades=OrdersTotal(),total=0; 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderMagicNumber()!=Trade_Set_ID_Number) continue; 
  TakeOrderStats(0);
  TakeOrderStats(1);  
  total++;
 }
 
 if(total==0) 
 {
  inplay[0]=false; 
  inplay[1]=false;
  OrderTicketN=0;
  OrderTradeWindow=-1;
  SetGV(directionfirststring,0);
  SetGV(directionnextstring,0);
 }
 return(total);
}
//+------------------------------------------------------------------+
int InitializeLots()
{
 int i=0,j=0,k=0;
 if(Use_Custom_Lot_Progression) 
 {
  string value;
  while (j>-2) 
  {
   j=StringFind(Custom_Lot_Progression,";",i);
   if (j>0) 
   {
    value=StringSubstr(Custom_Lot_Progression,i,j-i);
    k++;
    ArrayResize(Lots,k);
    Lots[k-1]=StrToDouble(value);
    i=j+1;
   } 
   else 
   {
    value=StringSubstr(Custom_Lot_Progression,i);
    k++;
    ArrayResize(Lots,k);
    Lots[k-1]=StrToDouble(value);
    j=-2;
   }
  }
 }
 else
 {
  double calclots=First_Lot_Size;
  while(calclots<=Last_Lot_Size)
  {
   ArrayResize(Lots,k+1);  
   Lots[k]=calclots;
   calclots*=Lot_Size_Multiplier;
   k++;
  }
 }
 return(k);
}
//+------------------------------------------------------------------+
void InitializeTradeTimes()
{
 UseTradeTime[0]=Use_Trade_Time1;
 UseTradeTime[1]=Use_Trade_Time2;
 UseTradeTime[2]=Use_Trade_Time3;
 UseTradeTime[3]=Use_Trade_Time4;
 UseTradeTime[4]=Use_Trade_Time5;
 UseTradeTime[5]=Use_Trade_Time6;

 StartTime[0,0]= TimeHour(StrToTime(Start_Time1));
 StartTime[0,1]= TimeHour(StrToTime(Start_Time2));
 StartTime[0,2]= TimeHour(StrToTime(Start_Time3));
 StartTime[0,3]= TimeHour(StrToTime(Start_Time4));
 StartTime[0,4]= TimeHour(StrToTime(Start_Time5));
 StartTime[0,5]= TimeHour(StrToTime(Start_Time6));
 
 StartTime[1,0]= TimeMinute(StrToTime(Start_Time1));
 StartTime[1,1]= TimeMinute(StrToTime(Start_Time2));
 StartTime[1,2]= TimeMinute(StrToTime(Start_Time3));
 StartTime[1,3]= TimeMinute(StrToTime(Start_Time4));
 StartTime[1,4]= TimeMinute(StrToTime(Start_Time5));
 StartTime[1,5]= TimeMinute(StrToTime(Start_Time6)); 

 StopTime[0,0]= TimeHour(StrToTime(Stop_Time1));
 StopTime[0,1]= TimeHour(StrToTime(Stop_Time2));
 StopTime[0,2]= TimeHour(StrToTime(Stop_Time3));
 StopTime[0,3]= TimeHour(StrToTime(Stop_Time4));
 StopTime[0,4]= TimeHour(StrToTime(Stop_Time5));
 StopTime[0,5]= TimeHour(StrToTime(Stop_Time6));
 
 StopTime[1,0]= TimeMinute(StrToTime(Stop_Time1));
 StopTime[1,1]= TimeMinute(StrToTime(Stop_Time2));
 StopTime[1,2]= TimeMinute(StrToTime(Stop_Time3));
 StopTime[1,3]= TimeMinute(StrToTime(Stop_Time4));
 StopTime[1,4]= TimeMinute(StrToTime(Stop_Time5));
 StopTime[1,5]= TimeMinute(StrToTime(Stop_Time6));

 if(!Use_Pips_From_Open_Price) return; // re-establish EnterTimePrice if EA re-started within trade window

 EnterTimePrice=-999;
 for(int i=0;i<6;i++)
 {
  if(UseTradeTime[i])
  {
   if(CheckTime(StartTime[0,i],StartTime[1,i],StopTime[0,i],StopTime[1,i])) continue; 
   
   // backtrack to find open bar
   for(int j=0;j<=Bars-1;j++)
   {
    if(TimeHour(iTime(NULL,0,j))==StartTime[0,i]&&TimeMinute(iTime(NULL,0,j))==StartTime[1,i])
    {
     EnterTimePrice=iOpen(NULL,0,j);
     return;
    }
   }
   Alert("WARNING: Unable to re-initialize EnterTimePrice! Please check StartTimes!");    
  }
 }
 
 return;
}
//+------------------------------------------------------------------+
void InitializeGV()
{
 
 directionfirststring=StringConcatenate(IDName," Direction First"); 
 if(!GlobalVariableCheck(directionfirststring)) SetGV(directionfirststring,0);

 directionnextstring=StringConcatenate(IDName," Direction Next");
 if(!GlobalVariableCheck(directionnextstring)) SetGV(directionnextstring,0);
 
 return;
}
//+------------------------------------------------------------------+
void InitializeVariables()
{
 inplay[0]=false;
 inplay[1]=false; // reset for safety
 
 TradeWindowSubmit=false;
 TradeWindowOpen=false;
 TradeWindowIndex=-1;
 
 OrderProgInit=1;
 OrderCycleInit=1; 
 OrderTradeLossInit=0;
}
//+------------------------------------------------------------------+
void ResetInit() // after first resume trade is executed
{
 Resume_From_Last_Closed_Trade=false; // so that take doesn't use takeInit again
 OrderProgInit=1;
 OrderCycleInit=1; 
 OrderTradeLossInit=0;
 return;
}
//+------------------------------------------------------------------+
double GetGV(string name)
{
 double value=GlobalVariableGet(name);
 int error=GetLastError();
 if(error!=0)
 {
  Print("GetGV Error: ",error);
  if(error==4058) SetGV(name,0);
 }
 return(value);
}
//+------------------------------------------------------------------+
void SetGV(string name, double value)
{
 GlobalVariableSet(name,value);
 int error=GetLastError(); 
 if(error!=0)
 {
  Print("SetGV Error: ",error);
 } 
 return;
}
//+------------------------------------------------------------------+
bool CheckConflict()
{
 if(!Use_Entry_Market_Order&&!Use_Entry_Trade_Time&&!Use_Entry_Exact_Price)
 {
  MessageBox(IDName+" \n\nAll Entry Methods are False!\n\nEA will be disabled. \n\nPlease fix inputs and re-apply EA.", WindowExpertName()+" Input Conflict Alert", MB_OK|MB_ICONERROR); 
  return(true); 
 }
 else if(First_Long&&First_Short) 
 {
  MessageBox(IDName+" \n\nBoth First_Long and First_Short are set to True!\n\nEA will be disabled. \n\nPlease fix inputs and re-apply EA.", WindowExpertName()+" Input Conflict Alert", MB_OK|MB_ICONERROR); 
  return(true);
 }
 else if((Use_Entry_Market_Order&&Use_Entry_Trade_Time)   || 
         (Use_Entry_Market_Order&&Use_Entry_Exact_Price))
 {
  MessageBox(IDName+" \n\nMarket entry is selected with Time and/or Price!\n\nEA will be disabled. \n\nPlease fix inputs and re-apply EA.", WindowExpertName()+" Input Conflict Alert", MB_OK|MB_ICONERROR);   
  return(true);
 }
 else if(Use_Entry_Trade_Time&&Use_Pips_From_Open_Price&&Pips_From_Open_Price<1)
 {
  MessageBox(IDName+" \n\nPips_From_Open_Price is less than 1!\n\nEA will be disabled. \n\nPlease fix inputs and re-apply EA.", WindowExpertName()+" Input Conflict Alert", MB_OK|MB_ICONERROR);    
  return(true);
 }
 else if(!First_Long&&!First_Short)
 {
  if(Use_Entry_Exact_Price||(Use_Entry_Trade_Time&&!Use_Pips_From_Open_Price))
  {
   MessageBox(IDName+" \n\nNeither First_Long nor First_Short is selected!\n\nEA will be disabled. \n\nPlease fix inputs and re-apply EA.", WindowExpertName()+" Input Conflict Alert", MB_OK|MB_ICONERROR);    
   return(true);
  }
 }

 return(false);
}
//+------------------------------------------------------------------+
bool CheckRestart()
{
 int input=MessageBox(IDName+" \nActive Trade in Progress! \n\nYes = Resume EA Control \nNo  = Disable EA (Hibernate)", WindowExpertName()+" Resume or Hiberante", MB_YESNO|MB_ICONQUESTION|MB_DEFBUTTON1); 
 if(input==IDYES) return(true);
 else             return(false);
}
//+------------------------------------------------------------------+
void MarketOrderVerify()
{
 EnterLong=false;EnterShort=false;
 int input=MessageBox(IDName+" \nInstant Market Order \n\nYes = BUY Order \nNo  = SELL Order \n\nCancel = Cancel Order", WindowExpertName()+" Instant Order Confirmation", MB_YESNOCANCEL|MB_ICONQUESTION|MB_DEFBUTTON3); 
 if(input==IDYES) 
 {
  EnterLong=true;
 }
 else if(input==IDNO) 
 {
  EnterShort=true;
 }
 else if(input==IDCANCEL)
 {
  SetDisable(); 
 }
 return;
}
//+------------------------------------------------------------------+
void CheckTradeWindow()
{
 TradeWindowSubmit=false;
 TradeWindowOpen=false;
 TradeWindowIndex=-1;
 for(int i=0;i<6;i++)
 {
  if(UseTradeTime[i])
  {
   if(StartTime[0,i]==TimeHour(iTime(NULL,0,0))&&StartTime[1,i]==TimeMinute(iTime(NULL,0,0)))
   {
    EnterTimePrice=iOpen(NULL,0,0); // save price of open 
    TradeWindowSubmit=true;
   }
   if(CheckTime(StartTime[0,i],StartTime[1,i],StopTime[0,i],StopTime[1,i])) continue; 
   
   TradeWindowOpen=true;
   TradeWindowIndex=i;
   return;
  }
 }
 return;
}
//+------------------------------------------------------------------+
void TimeOrderVerify()
{
 EnterLong=false;EnterShort=false;
 if(!TradeWindowOpen) return;
 if(OrderTradeWindow==TradeWindowIndex) return; // prevent re-entry after cycle completion in same time window
 
 int i;
 if(Use_Entry_Exact_Price)
 {
  PriceOrderVerify();
  if(EnterLong||EnterShort) OrderTradeWindow=TradeWindowIndex;
 }
 else if(Use_Pips_From_Open_Price)
 { // MathAbs to force positive BufferPoints
  if(Bid>=NormDigits(EnterTimePrice+PointsFromOpenPrice)&&Bid<=NormDigits(EnterTimePrice+PointsFromOpenPrice+MathAbs(BufferPoints)))
  {
   EnterLong=true;
   EnterTimePrice=-999;
   OrderTradeWindow=TradeWindowIndex;
  } // MathAbs to force positive BufferPoints
  else if(Bid<=NormDigits(EnterTimePrice-PointsFromOpenPrice)&&Bid>=NormDigits(EnterTimePrice-PointsFromOpenPrice-MathAbs(BufferPoints))) 
  {
   EnterShort=true;
   EnterTimePrice=-999;  
   OrderTradeWindow=TradeWindowIndex;    
  }
 }
 else if(TradeWindowSubmit)
 {
  if(First_Long) EnterLong=true;
  else if(First_Short) EnterShort=true;
   
  OrderTradeWindow=TradeWindowIndex;
 }
 return;
}
//+------------------------------------------------------------------+
void PriceOrderVerify()
{
 EnterLong=false;EnterShort=false;
 if(First_Long)
 {
  if(BufferPoints>=0) // stop entry case 
  {
   if(Bid>=Exact_Entry_Price&&Bid<=NormDigits(Exact_Entry_Price+BufferPoints)) EnterLong=true;
  }
  else // limit entry case 
  {
   if(Bid<=Exact_Entry_Price&&Bid>=NormDigits(Exact_Entry_Price+BufferPoints)) EnterLong=true;
  }
 }
 else if(First_Short)
 {
  if(BufferPoints>=0) // stop entry case 
  {
   if(Bid<=Exact_Entry_Price&&Bid>=NormDigits(Exact_Entry_Price-BufferPoints)) EnterShort=true;
  }
  else // limit entry case 
  {
   if(Bid>=Exact_Entry_Price&&Bid<=NormDigits(Exact_Entry_Price-BufferPoints)) EnterShort=true;  
  }
 } 
 return;
}
//+------------------------------------------------------------------+
bool CheckTime(int starthour, int startmin, int stophour, int stopmin)
{
 int timehour=TimeHour(iTime(NULL,0,0)); 
 if(starthour<stophour)
 {
  if(timehour<starthour || timehour>stophour) return(true);
 }
 else if(starthour<stophour)
 {
  if(timehour<starthour && timehour>stophour) return(true);
 }
 else // equals
 {
  if(timehour!=starthour) return(true);
 }

 int timeminute=TimeMinute(iTime(NULL,0,0));
 if(timehour==starthour && timeminute<startmin) return(true);
 if(timehour==stophour && timeminute>=stopmin) return(true);
 
 return(false);
}
//+------------------------------------------------------------------+
string PrepareComment(int prog, int cycle, int tradewindow, double loss)
{
 string name;

 if(Hide_EA_Comment) name=StringConcatenate(DoubleToStr(prog,0),"_",DoubleToStr(cycle,0),"@",DoubleToStr(tradewindow,0),"&",DoubleToStr(loss,2),"$",IDNameComment);
 else name=StringConcatenate(DoubleToStr(prog,0),"_",DoubleToStr(cycle,0),"@",DoubleToStr(tradewindow,0),"&",DoubleToStr(loss,2),"$",IDNameComment," ",EAName);
 
 return(name);
}
//+------------------------------------------------------------------+
void TakeOrderStats(int level)
{
 if(level==0)
 {
  OrderTicketN=OrderTicket();
 }
 else if(level==1)
 {
  OrderDirection=0;
  OrderPoints=0;
  OrderPL=0;
 
  if(OrderType()==OP_BUY) OrderDirection=1;
  else if(OrderType()==OP_SELL) OrderDirection=-1;

  OrderPoints=CalcPoints(OrderDirection,OrderOpenPrice(),OrderClosePrice());
  OrderPL=OrderProfit();
 
  if(IsTesting()) // tester does not use comments 
  {
   OrderProg=OrderProg;
   OrderCycle=OrderCycle;
   OrderTradeLossPast=OrderTradeLoss;
   OrderTradeLoss+=OrderProfit();   
  }
  else
  {
   int pos1,pos2,pos3,pos4;  
   OrderProg=0;
   OrderCycle=0;
   OrderTradeWindow=-1;
   
   pos1=StringFind(OrderComment(),"_",0);
   OrderProg=StrToInteger(StringSubstr(OrderComment(),0,pos1));
   pos2=StringFind(OrderComment(),"@",pos1+1);
   OrderCycle=StrToInteger(StringSubstr(OrderComment(),pos1+1,pos2-(pos1+1)));
   pos3=StringFind(OrderComment(),"&",pos2+1);
   OrderTradeWindow=StrToInteger(StringSubstr(OrderComment(),pos2+1,pos3-(pos2+1)));     
   pos4=StringFind(OrderComment(),"$",pos3+1);
   OrderTradeLossPast=StrToDouble(StringSubstr(OrderComment(),pos3+1,pos4-(pos3+1)));     

   OrderTradeLoss=OrderTradeLossPast+OrderProfit();
   
   //Alert(OrderProg+" "+OrderCycle+" "+OrderTradeWindow+" "+DoubleToStr(OrderTradeLoss,2));
  }
  
 }
 return;
}
//+------------------------------------------------------------------+
void ResponseOrder()
{
 double stop,take;
 OrderSelect(OrderTicketN,SELECT_BY_TICKET);
 TakeOrderStats(1);
 
 if(OrderPoints>0) // last win 
 {
 
  if(Use_Entry_Trade_Time)  // no new cycles outside of trade window
  {
   if(!TradeWindowOpen) return;
   if(OrderTradeWindow!=TradeWindowIndex) return;
  }
  
  if(Break_Even_at_N>0&&OrderProg+1>Break_Even_at_N) // > correct: no new cycles for break-even orders
  {
   if(!Use_Entry_Trade_Time) 
   {
    SetDisable("Break Even Achieved.");   
   }
   if(IsTesting()) Disable=false;   
   return; // no new cycles after break even
  }
  
  if(OrderCycle<Max_Trade_Cycles)
  {
   stop=NormDigits(StopLossPoints+StopLossExtraPoints);
   take=NormDigits(TakeProfitPoints+TakeProfitExtraPoints);  

   CheckFirstDirection();
   OrderProg=1;
   OrderCycle++;
   OrderTradeLossPast=0;   
   OrderTradeLoss=0;
   if(OrderDirection>0)
   {
    Submit(true,Lots[0],stop,take,OrderProg,OrderCycle,OrderTradeWindow,OrderTradeLoss);   
   }
   else if(OrderDirection<0)
   {   
    Submit(false,Lots[0],stop,take,OrderProg,OrderCycle,OrderTradeWindow,OrderTradeLoss);     
   }  
   
  }
  else
  {
   if(!Use_Entry_Trade_Time) 
   {
    SetDisable("Maximum Trade Cycles Achieved.");     
   }
   if(IsTesting()) Disable=false;
  }
 }
 else // last lost
 {
  if(OrderProg<MaxProgLevels) // < correct here
  {
   stop=NormDigits(StopLossPoints+StopLossExtraPoints);   
    
   if(Break_Even_at_N>0&&OrderProg+1>=Break_Even_at_N) take=CalcBE(OrderTradeLoss,Lots[OrderProg]);
   else take=NormDigits(TakeProfitPoints+TakeProfitExtraPoints);

   CheckReverseDirection();
   OrderProg++;
   OrderTradeLossPast=OrderTradeLoss;
   if(OrderDirection>0)
   {
    Submit(false,Lots[OrderProg-1],stop,take,OrderProg,OrderCycle,OrderTradeWindow,OrderTradeLoss); // Lots[OrderProg] correct for next prog (array starts at 0, prog starts at 1)
   }
   else if(OrderDirection<0)
   { 
    Submit(true,Lots[OrderProg-1],stop,take,OrderProg,OrderCycle,OrderTradeWindow,OrderTradeLoss); // Lots[OrderProg] correct for next prog (array starts at 0, prog starts at 1)  
   }
  }
  else
  {
   if(!Use_Entry_Trade_Time)
   {
    SetDisable("Maximum Progression Level Exceeded.");     
   }
   if(IsTesting()) Disable=false;   
  }  
 }
 
 return;
}
//+------------------------------------------------------------------+
void CheckReverseDirection()
{
 double value=GetGV(directionnextstring);
 if(value!=0)
 {
  OrderDirection=-value;
  SetGV(directionnextstring,0);
 }
 else
 {
  if(Reverse_at_N==OrderProg+1) // OrderProg+1 correct here
  {
   OrderDirection=-OrderDirection;
  }
 }
 return;
}
//+------------------------------------------------------------------+
void CheckFirstDirection()
{
 double value=GetGV(directionfirststring);
 if(value!=0) 
 {
  OrderDirection=value;
  SetGV(directionfirststring,0); 
  SetGV(directionnextstring,0);  
 }
 return;
}
//+------------------------------------------------------------------+
double CalcBE(double amount,double lottage)
{
 double amountpoint=-amount*Point;
 double target=NormDigits(Divide(amountpoint,(lottage*MarketInfo(Symbol(),MODE_TICKVALUE))));
 double targetamount=target*MarketInfo(Symbol(),MODE_TICKVALUE)*lottage;
 while(targetamount<amountpoint)
 {
  target=NormDigits(target+Point);
  targetamount=target*MarketInfo(Symbol(),MODE_TICKVALUE)*lottage;
 }
 return(target);
}
//+------------------------------------------------------------------+
double Divide(double v1, double v2)
{
 if(v2!=0) return(v1/v2);
 else      return(0.0);
}
//+------------------------------------------------------------------+
void UpdateDataWindow()
{
 string info,dfstring,dnstring,ticketstring;
 string dirstring,takestring,stopstring,pricestring;
 double value;

 if(OrderTicketN!=0)
 {
  OrderSelect(OrderTicketN,SELECT_BY_TICKET);
  OrderPL=OrderProfit();
 }
 else OrderPL=0;
 
 value=GetGV(directionfirststring);
 if(value==0)     dfstring="Trade Logic";
 else if(value>0) dfstring="Long";
 else             dfstring="Short";
 
 value=GetGV(directionnextstring);
 if(value==0)     dnstring="Trade Logic";
 else if(value>0) dnstring="Long";
 else             dnstring="Short"; 
 
 if(triggered)
 {
  ticketstring=CreateTicketString();
 }
 else
 {
  if(Use_Entry_Exact_Price)
  {
   pricestring=DoubleToStr(Exact_Entry_Price,Digits);   
   double stop=NormDigits(StopLossPoints+StopLossExtraPoints);
   double take;
   if(Resume_From_Last_Closed_Trade) take=takeInit;
   else take=NormDigits(TakeProfitPoints+TakeProfitExtraPoints); 
   
   if(First_Long) 
   {
    dirstring="Buy";
    takestring=DoubleToStr(TakeLong(Exact_Entry_Price,take),Digits);    
    stopstring=DoubleToStr(StopLong(Exact_Entry_Price,stop),Digits); 
   }
   else           
   {
    dirstring="Sell";
    takestring=DoubleToStr(TakeShort(Exact_Entry_Price,take),Digits);    
    stopstring=DoubleToStr(StopShort(Exact_Entry_Price,stop),Digits);    
   }
   ticketstring=StringConcatenate("\nExact Price Entry: ",dirstring," at ",pricestring,",TP: ",takestring,",SL: ",stopstring);
  }
  else
  {
   ticketstring=CreateTicketString();  
  }
 }
 
 info = StringConcatenate(IDNamePeriod,
                          entrymethodstring,
                          "\nSpread : ",DoubleToStr(MarketInfo(Symbol(),MODE_SPREAD)*precisionmultiplier,precisiondigits),
                          ticketstring,
                          "\nP/L $ ",DoubleToStr(OrderPL,2),  
                          "\nCumulative Loss $ ",DoubleToStr(OrderTradeLossPast,2),                                                  
                          "\nProg # ",DoubleToStr(OrderProg,0),maxprogstring,
                          "\nCycle # ",DoubleToStr(OrderCycle,0),maxcyclestring,
                          "\nDirection First = ",dfstring,
                          "\nDirection Next = ",dnstring,
                          commentsectionstring,
                          "\nAcc Balance $ ",DoubleToStr(AccountBalance(),2),
                          "\nAcc Equity $ ",DoubleToStr(AccountEquity(),2),
                          "\nMargin Free $ ",DoubleToStr(AccountFreeMargin(),2),
                          "\nMargin Used $ ",DoubleToStr(AccountMargin(),2));
 Comment(info);
 return;
}
//+------------------------------------------------------------------+
bool CheckSpreadLimit()
{
 if(MarketInfo(Symbol(),MODE_SPREAD)>=SpreadLimitAmount) 
 {
  Alert(IDName+" Spread Exceeded Limit! Spread: "+DoubleToStr(MarketInfo(Symbol(),MODE_SPREAD)*precisionmultiplier,precisiondigits));
  int input=MessageBox(IDName+" \nSpread Exceeded Limit! \n\nYes = Proceed Normally \nNo  = Disable EA (Hibernate)", WindowExpertName()+" Excessive Spread Alert", MB_YESNO|MB_ICONQUESTION|MB_DEFBUTTON1); 
  if(input==IDYES) return(false);
  else             
  {
   SetDisable();
   return(true);  
  }
 }
 return(false);
}
//+------------------------------------------------------------------+
void CheckLastClosedTrade()
{
 OrderTicketN=-1;
 int trade,trades=OrdersHistoryTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_HISTORY);
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderMagicNumber()!=Trade_Set_ID_Number) continue;
  OrderTicketN=OrderTicket();
  break;
 }
 
 if(OrderSelect(OrderTicketN,SELECT_BY_TICKET))
 {
  TakeOrderStats(1);
  if(OrderPoints>0) // last win 
  {

   if(Break_Even_at_N>0&&OrderProg+1>Break_Even_at_N) // > correct: no new cycles for break-even orders
   {
    if(!Use_Entry_Trade_Time) 
    {
     SetDisable("Break Even Achieved.");   
    }
    if(IsTesting()) Disable=false;   
    return; // no new cycles after break even
   }
  
   if(OrderCycle<Max_Trade_Cycles)
   {
    takeInit=NormDigits(TakeProfitPoints+TakeProfitExtraPoints);
    OrderProgInit=1;
    OrderCycle++;
    OrderCycleInit=OrderCycle;
    OrderTradeLossPast=0;   
    OrderTradeLossInit=0;
   }
   else
   {
    if(!Use_Entry_Trade_Time) 
    {
     SetDisable("Maximum Trade Cycles Achieved.");      
    }
    else ResetInit();
    if(IsTesting()) Disable=false;   
   } 
  }
  else // last lost
  {
   if(OrderProg<MaxProgLevels) // < correct here
   {    
    if(Break_Even_at_N>0&&OrderProg+1>=Break_Even_at_N) takeInit=CalcBE(OrderTradeLoss,Lots[OrderProg]);
    else takeInit=NormDigits(TakeProfitPoints+TakeProfitExtraPoints);

    OrderProg++;
    OrderProgInit=OrderProg;
    OrderCycleInit=OrderCycle;
    OrderTradeLossPast=OrderTradeLoss;
    OrderTradeLossInit=OrderTradeLoss;
   }
   else
   {
    if(!Use_Entry_Trade_Time)
    {
     SetDisable("Maximum Progression Level Exceeded.");     
    }
    else ResetInit();
    if(IsTesting()) Disable=false;   
   }  
  }
 }
 else
 {
  Alert(IDName+" Cannot Resume From Last Closed Trade! Error: "+GetLastError()+", Order Ticket #: ",OrderTicketN);
  SetDisable("Cannot Resume From Last Closed Trade!");
 } 
 return;
}
//+------------------------------------------------------------------+
string CreateTicketString()
{
 return(StringConcatenate("\nTicket # ",DoubleToStr(OrderTicketN,0)));
}
//+------------------------------------------------------------------+
void SetDisable(string comment=" ")
{
 IDNamePeriod=StringConcatenate(Symbol()," ",timename," ID# ",DoubleToStr(Trade_Set_ID_Number,0)," is DISABLED. ",comment);  
 Disable=true;
 return;
}
//+------------------------------------------------------------------+


//+----------------------------------------------------------------------+
//|                                                           LIVMOR.mq4 |
//|                                                         David J. Lin |
//| LIVMOR Trading Strategy                                              |
//| by George Miller (tgmgetsmail@gmail.com)                             |
//|                                                                      |
//| Coded by David J. Lin (dave.j.lin@gmail.com)                         |
//| Evanston, IL, March 14, 2011                                         |
//|                                                                      |
//| v1.0 completed , 2011                                                |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2011, George Miller and David J. Lin"
#include <WinUser32.mqh>

// Internal usage parameters:
//---- input parameters
extern string __________Close_All="*** Close All Trades ***";
extern bool Close_All_Trades=false; // true: close all open trades

extern string __________ID_Number="*** Unique Trade Set ID Number ***";
extern int Trade_Set_ID_Number=10; // choose unique magic number ID for EA's trade set

extern string __________Entry_Method="*** Entry Method ***";

extern bool Use_Entry_Market_Order=false; // true: use market order entry
extern bool Use_Entry_Exact_Price=false; // true: use exact price entry
extern bool Use_Entry_1=true; // true: use entry condition #1
extern bool Use_Entry_2=true; // true: use entry condition #2
extern bool Use_Entry_3=true; // true: use entry condition #3
extern bool Use_MACDStoch=true; // true: use MACD & Stoch conditions

extern string __________First_Direction="*** First Direction for Exact Price Entries ***";

extern bool First_Long=false;   // true: BUY
extern bool First_Short=false; // true: SELL

extern string __________SL_TP="*** SL TP Parameters ***";

extern int Mode_Stop_Loss=1; // 1 = use pips, 2 = use price 
extern int Mode_Take_Profit=1; // 1 = use pips, 2 = use price

extern int Stop_Loss=500;   // pips stop loss
extern int Take_Profit=100; // pips take profit

extern double Stop_Loss_Price=1.00000; // exact Stop Loss price
extern double Take_Profit_Price=1.00000; // exact Take Profit price

extern string __________Trail="*** Trail Parameters ***";

extern bool Use_Trail_Stop=false; // true = use trailing stop, false = don't use trailing stop
extern bool Use_Trail_After_Break_Even=false; // true = start trailing stop only after SL moves to BE, false = start trailing stop immediately
extern bool Use_Tightening_Trail=false; // true = use tightening trail, false = don't use tightening trail
extern bool Use_Move_SL_Profit=false; // true = use move SL to BE after Move_Break_Even_Profit is reached, false = don't move SL to BE when Move_Break_Even_Profit is reached
extern int Trail_Stop=30; // pips to trail
extern int Tightening_Trail_50=20; // pips to trail after 50% of profit reached, used when Use_Tightening_Stop=true;
extern int Tightening_Trail_80=10; // pips to trail after 80% of profit reached, used when Use_Tightening_Stop=true;
extern int Move_Stop_Loss_Profit=30; // pips profit after which to move stop loss to break even+Move_Stop_Loss_Amount
extern int Move_Stop_Loss_Amount=0; // pips to move SL past break even, use 0 for exactly break even

extern string __________Price_Entry="*** Exact Price Entry Parameter ***";

// Entry Exact Price parameter
extern double Exact_Entry_Price=1.60000; // exact entry price 

extern string __________Lots_Recovery="*** Lots & Recovery Parameters ***";

// Lots and Recovery Level parameters
extern bool Use_Level_Recovery=false; // true = use level recovery, false = do not use level recovery
extern bool Use_Timed_Recovery=true; // true = use timed recovery, false = do not use timed recovery
                                      // to turn off recovery system set both of the above to false 
extern bool Use_Level_Round_Numbers=false; // true = use round numbers at closest sweet spots for level recovery, false = use acutal entry prices for level recovery
extern double First_Lot_Size=0.10; // initial lot size
extern double Lot_Size_Multiplier=2.0; // multiplier for recovery progression
extern int Level_Spacing=10; // pips spacing between recovery levels
extern int Level_Number=10; // number of recovery levels
extern int Level_Change_TP_1st_Entry=2; // level at which to change tagged TPs to 1st trade's entry price
extern int Level_Basket_TP=3; // level at which to activate basket closure TP
extern int Mode_Basket_TP=1; // 1 = use pips (Basket_TP_Pips), 2 = use price (Basket_TP_Price) for baskcet closure TP
extern int Basket_TP_Pips=50; // pips basket closure profit TP
extern double Basket_TP_Price=1.00000; // exact price basket closure profit TP
extern int Level_Break_Even=7; // level at which to activate basket break even
extern int Mode_Basket_SL=3; // 1 = use pips (Basket_SL_Pips), 2 = use price (Basket_SL_Price), 3 = use percentage (Basket_SL_Percent) for baskcet closure SL
extern int Basket_SL_Pips=100; // pips basket closure SL (mode 1)
extern double Basket_SL_Price=1.00000; // exact price basket closure SL (mode 2)
extern double Basket_SL_Percent=5.0; // percentage of effective balance basket closure SL (mode 3)
extern int Time_Recovery_First_Time_Check=12; // first hour to check timed recovery, 24 hour format
extern int Time_Recovery_Frequency=0; // frequency of timed recovery check: 0(always), 1(every hour), 2(every 3 hours), 3(every 6 hours), 4(every 12 hours), 5(every 24 hours)

extern string __________Misc="*** Misc Parameters ***";

extern double EA_Working_Balance=10000; // effective dollar balance that the EA works with, used to calculate % drawdown and basket stop loss, cumulative upon trade completions 
extern int Pending_Expiration_Hours=0; // pending expiration time in hours, use 0 for no expiration
extern bool Hide_EA_Comment=true; // true: omit “DUMOR” from comment line
extern int Slippage=6; // slippage
extern int Buffer_Pips=1; // pips to buffer price entries, positive = stop entry case, negative = limit entry case 
extern int Buffer_SSpot_Pips=1; // pips to buffer sweet spot lines for market entry
extern int Buffer_Basket_SLTP_Pips=2; // pips to buffer basket SL/TP price exits
extern bool Alert_Entry_Exit=true; // toggle to turn on/off alerts for order entries and exits 
extern bool Alert_Secondary_Trade_Setup=false; // toggle to turn on/off alerts for order entries and exits 
  
extern string __________Indicators="*** Indicators Parameters ***";

extern double MACD_Upper_Limit=0; // upper limit for MACD, set to 0 for auto calculate Stoch_Upper_Limit% of max/min chart values
extern double MACD_Lower_Limit=0; // lower limit for MACD, set to 0 for auto calculate Stoch_Lower_Limit% of max/min chart values

extern int Stoch_Upper_Limit=60; // upper limit for Stochastics
extern int Stoch_Lower_Limit=40; // lower limit for Stochastics

extern int MACD_FastEMA=12; // MACD Fast EMA Period 
extern int MACD_SlowEMA=26; // MACD Slow EMA Period 
extern int MACD_SignalSMA=9; // MACD Signal SMA Period 
extern int MACD_Price=PRICE_CLOSE; // MACD Applied Price 

extern int Stoch1_K_Period=7; //%K Period for Stochastics 1
extern int Stoch1_D_Period=3; //%D Period for Stochastics 1
extern int Stoch1_Slow_Period=3; //Slowing Period for Stochastics 1
extern int Stoch1_MA_Method=MODE_LWMA; // MA Method for Stochastics 1
extern int Stoch1_MA_Price=1; // Price Method for Stochastics 1, 0 for Low/High, 1 for Close/Close

extern int Stoch2_K_Period=14; //%K Period for Stochastics 2
extern int Stoch2_D_Period=3; //%D Period for Stochastics 2
extern int Stoch2_Slow_Period=5; //Slowing Period for Stochastics 2
extern int Stoch2_MA_Method=MODE_LWMA; // MA Method for Stochastics 2
extern int Stoch2_MA_Price=1; // Price Method for Stochastics 2, 0 for Low/High, 1 for Close/Close

extern int BBands1_Period=25; // Period for Bollinger Bands 1
extern int BBands1_Deviations=1; // Deviations for Bollinger Bands 1
extern int BBands1_Shift=0; // Shift for Bollinger Bands 1
extern int BBands1_Price=PRICE_CLOSE; // Applied Price for Bollinger Bands 1

extern int BBands2_Period=25; // Period for Bollinger Bands 2
extern int BBands2_Deviations=1; // Deviations for Bollinger Bands 2
extern int BBands2_Shift=3; // Shift for Bollinger Bands 2
extern int BBands2_Price=PRICE_CLOSE; // Applied Price for Bollinger Bands 2

//---- buffers
bool orderlong,ordershort,triggered;
string EAName;
datetime ots,otl,lasttime,lasthour;
double lotsmin,lotsmax;
double StopLossPoints,TakeProfitPoints;
double TrailStopPoints,TighteningTrail50Points,TighteningTrail80Points;
double MoveStopLossProfitPoints,MoveStopLossAmountPoints;
double BasketTPPoints,BasketSLPoints,LevelSpacingPoints;
double BufferBasketSLTPPoints;
int lotsprecision;
int expiration; // pending expiration hours
double BufferPoints; // points to buffer price entries
double precisionmultiplier; // for spread output
int precisiondigits; // for spread output
double BufferSSpotPoints; // points to buffer sweet spot lines for market entry
int NumberTotal; // total number of open orders 
int MarketTotal; // total number of market orders 
int PendingTotal; // total number of pending orders 
double LotsTotal; // total number of lots opened
double Drawdown; // drawdown based on working balance

string semaphorestring;
string teststring;
string timename;
string IDName,IDNamePeriod,IDNameComment;
string initlotstring;
string commentsectionstring;
string entrymethodstring;
string sixthstring;
string spacingstring;

bool flagMACDup=false; // flag for MACD up 
bool flagMACDdown=false; // flag for MACD down
bool flagSTOCHup=false; // flag for Stochastics up 
bool flagSTOCHdown=false; // flag for Stochastics down
bool flagBBands1upper=false; // flag for Bollinger Bands 1 up
bool flagBBands1lower=false; // flag for Bollinger Bands 1 down
bool flagBBands2upper=false; // flag for Bollinger Bands 2 up
bool flagBBands2lower=false; // flag for Bollinger Bands 2 down
bool flag16down=false; // flag for 1/6 line down
bool flag56up=false; // flag for 5/6 line up
bool flagEntry3SetShort; // flag for setup short entry condition #3 when standing alone
bool flagEntry3SetLong; // flag for setup long entry condition #3 when standing alone
bool flagSLOpenPrice; // flag for whether SL is at BE or better
bool flagNewHour; // flag for new hour 
bool flagModifiedFirstOrderTP; // flag for whether 1st order's TP has been moved to its open price 

double MACDUpperLimit; // MACD Upper Limit
double MACDLowerLimit; // MACD Lower Limit
double MACDUpperMult; // MACD Upper Multiplier
double MACDLowerMult; // MACD Lower Multiplier

double Lots[]; // array holding lots
int MaxProgLevels; // maximum number of progression levels
bool Disable; // primary disable switch
bool EnterLong=false,EnterShort=false; // main toggle controls for long and short entries
int MarketTicketN[]; // ticket numbers of market orders 
int PendingTicketN[2]; // ticket numbers of pending orders 
double OrderFirstEntryPrice; // entry price of 1st order 
double OrderFirstTP; // TP of 1st order 
double OrderFirstSL; // SL of 1st order 
double OrderFirstLots; // lot size of 1st order 
int OrderDirection; // direction of last order, long (1), short (-1)
double Chart_Profit; // points profit of current order in terms of chart (reverse Ask/Bid) for recovery considerations
double Order_Profit; // points profit of current order for trail and fixed stop considerations
double BasketPriceTarget; // price sum holder for calculation of basket SL/TP price targets
double BasketTPPriceTarget; // market price target of basket TP points 
double BasketSLPriceTarget; // market price target of basket SL points 
double BasketBEPriceTarget; // market price target of basket break even BE
double BasketProfit; // dollar profit of current basket
double SpacingPips=50; // pips spacing for sweet spot lines
double SpacingPoints; // points spacing for sweet spot lines
double spacings[100]; // sweet spot levels
int spacinglower; // index of spacings of lower sweet spot level
int spacingupper; // index of spacings of higher sweet spot level
double SSpotupper,SSpotlower; // values of closest upper and lower sweet spots
double BBands1upper,BBands1lower,BBands2upper,BBands2lower; // values of BBands
double onesixth,fivesixth; // values of 1/6 and 5/6 lines
double Entry3SetSSpotupper,Entry3SetSSpotlower; // values of closest upper and lower sweet spots for entry condition 3 tracking when standing alone
double profitpoints50; // 50% of target
double profitpoints80; // 80% of target
int TimeCheckHour[]; // hours for time check
int TimeCheckFreqArray[6]={1,24,8,4,2,1}; // frequency of time check
int TimeCheckHourSeparationArray[6]={0,1,3,6,12,24}; // hours separating next time check
int TimeCheckFreq; // selected frequency of time check 
int TimeCheckHourSeparation; // selected hours separating next time check 
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

 EAName="LIVMOR";
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
 if(Close_All_Trades) Disable=ExitAll();
 
 if(Disable)
 {
  IDNamePeriod=StringConcatenate(Symbol()," ",timename," ID# ",DoubleToStr(Trade_Set_ID_Number,0)," is DISABLED.");
  Disable=true;
  return;
 } 
 
 lotsmin=MarketInfo(Symbol(),MODE_MINLOT); 
 lotsmax=MarketInfo(Symbol(),MODE_MAXLOT); 

 if(lotsmin==1)         lotsprecision=0;
 else if(lotsmin==0.50) lotsprecision=1;
 else if(lotsmin==0.10) lotsprecision=1;
 else if(lotsmin==0.01) lotsprecision=2;
 else                   lotsprecision=1; 

 if(StringFind(Symbol(),"JPY")>0) 
 {
  if(Digits==3)
  {
   StopLossPoints=NormPoints(Stop_Loss*10);
   TakeProfitPoints=NormPoints(Take_Profit*10);
   BufferPoints=NormPoints(Buffer_Pips*10);
   SpacingPoints=NormPoints(SpacingPips*10);
   BufferSSpotPoints=NormPoints(Buffer_SSpot_Pips*10);
   TrailStopPoints=NormPoints(Trail_Stop*10);
   TighteningTrail50Points=NormPoints(Tightening_Trail_50*10);
   TighteningTrail80Points=NormPoints(Tightening_Trail_80*10);
   MoveStopLossProfitPoints=NormPoints(Move_Stop_Loss_Profit*10);
   MoveStopLossAmountPoints=NormPoints(Move_Stop_Loss_Amount*10);
   BasketTPPoints=NormPoints(Basket_TP_Pips*10);
   BasketSLPoints=NormPoints(Basket_SL_Pips*10); 
   LevelSpacingPoints=NormPoints(Level_Spacing*10);  
   BufferBasketSLTPPoints=NormPoints(Buffer_Basket_SLTP_Pips*10);
   precisionmultiplier=0.1;
   precisiondigits=1;
  }
  else
  {
   StopLossPoints=NormPoints(Stop_Loss);
   TakeProfitPoints=NormPoints(Take_Profit); 
   BufferPoints=NormPoints(Buffer_Pips);
   SpacingPoints=NormPoints(SpacingPips); 
   BufferSSpotPoints=NormPoints(Buffer_SSpot_Pips);    
   TrailStopPoints=NormPoints(Trail_Stop);
   TighteningTrail50Points=NormPoints(Tightening_Trail_50);
   TighteningTrail80Points=NormPoints(Tightening_Trail_80);
   MoveStopLossProfitPoints=NormPoints(Move_Stop_Loss_Profit);
   MoveStopLossAmountPoints=NormPoints(Move_Stop_Loss_Amount);  
   BasketTPPoints=NormPoints(Basket_TP_Pips);    
   BasketSLPoints=NormPoints(Basket_SL_Pips);  
   LevelSpacingPoints=NormPoints(Level_Spacing); 
   BufferBasketSLTPPoints=NormPoints(Buffer_Basket_SLTP_Pips);      
   precisionmultiplier=1.0;  
   precisiondigits=0;          
  }  
 }
 else
 {
  if(Digits==5)
  {
   StopLossPoints=NormPoints(Stop_Loss*10);
   TakeProfitPoints=NormPoints(Take_Profit*10); 
   BufferPoints=NormPoints(Buffer_Pips*10); 
   SpacingPoints=NormPoints(SpacingPips*10);  
   BufferSSpotPoints=NormPoints(Buffer_SSpot_Pips*10);   
   TrailStopPoints=NormPoints(Trail_Stop*10);
   TighteningTrail50Points=NormPoints(Tightening_Trail_50*10);
   TighteningTrail80Points=NormPoints(Tightening_Trail_80*10);
   MoveStopLossProfitPoints=NormPoints(Move_Stop_Loss_Profit*10);
   MoveStopLossAmountPoints=NormPoints(Move_Stop_Loss_Amount*10);  
   BasketTPPoints=NormPoints(Basket_TP_Pips*10);  
   BasketSLPoints=NormPoints(Basket_SL_Pips*10);   
   LevelSpacingPoints=NormPoints(Level_Spacing*10);    
   BufferBasketSLTPPoints=NormPoints(Buffer_Basket_SLTP_Pips*10);   
   precisionmultiplier=0.1;    
   precisiondigits=1;         
  }
  else
  {
   StopLossPoints=NormPoints(Stop_Loss);
   TakeProfitPoints=NormPoints(Take_Profit);
   BufferPoints=NormPoints(Buffer_Pips); 
   SpacingPoints=NormPoints(SpacingPips); 
   BufferSSpotPoints=NormPoints(Buffer_SSpot_Pips);
   TrailStopPoints=NormPoints(Trail_Stop);
   TighteningTrail50Points=NormPoints(Tightening_Trail_50);
   TighteningTrail80Points=NormPoints(Tightening_Trail_80);
   MoveStopLossProfitPoints=NormPoints(Move_Stop_Loss_Profit);
   MoveStopLossAmountPoints=NormPoints(Move_Stop_Loss_Amount);
   BasketTPPoints=NormPoints(Basket_TP_Pips); 
   BasketSLPoints=NormPoints(Basket_SL_Pips); 
   LevelSpacingPoints=NormPoints(Level_Spacing);          
   BufferBasketSLTPPoints=NormPoints(Buffer_Basket_SLTP_Pips);             
   precisionmultiplier=1.0;  
   precisiondigits=0;              
  }  
 } 

 InitializeVariables();
 MaxProgLevels=InitializeLots();
 InitializeTimes();
   
 triggered=false;
 CheckNumberOrder(true);
 if(NumberTotal>0) 
 {
  if(CheckRestart()) triggered=true; 
  else 
  {
   IDNamePeriod=StringConcatenate(Symbol()," ",timename," ID# ",DoubleToStr(Trade_Set_ID_Number,0)," is DISABLED.");
   Disable=true;
   return;
  }
 }
 
 initlotstring=DoubleToStr(Lots[0],lotsprecision);
 commentsectionstring=StringConcatenate("\nInit Lots = ",initlotstring);
 if(Use_Entry_Market_Order) entrymethodstring="\nMarket Order Entry";
 else if(Use_Entry_Exact_Price) entrymethodstring="\nExact Price Entry";
 else 
 {
  string substring="";
  if(Use_Entry_1)   substring=StringConcatenate(substring," 1 ");
  if(Use_Entry_2)   substring=StringConcatenate(substring," 2 ");
  if(Use_Entry_3)   substring=StringConcatenate(substring," 3 ");  
  if(Use_MACDStoch) substring=StringConcatenate(substring," MS ");   
  entrymethodstring=StringConcatenate("\nEntry Conditions",substring);
 }
// Alert("Levels: "+proglevels);
// for(int i=0;i<proglevels;i++) Alert(Lots[i]);
  
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
 if(Disable) 
 {
  Comment(IDNamePeriod);
  return(0);
 }
 
 if(lasttime!=iTime(NULL,0,0))
 {
  GenerateSweetSpots(); 
 }
 lasttime=iTime(NULL,0,0);
 
 if(lasthour!=TimeHour(TimeCurrent()))
 {
  flagNewHour=true; 
 }
 lasthour=TimeHour(TimeCurrent()); 

 CheckIndicators1();
 CheckIndicators2();
 CheckIndicators3();
 CheckIndicators4();  

 Main12();
 Main3();

 ManageOrders();
  
 UpdateDataWindow(); 
 CheckError();
 
 flagNewHour=false;
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert utility functions                                         |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void Main12()
{  
 if(triggered) return;

 string comment;
 double stop,take; 
 EnterLong=false;EnterShort=false;

 if(Use_Entry_Market_Order) MarketOrderVerify();
 else if(Use_Entry_Exact_Price) PriceOrderVerify();
 else EntryConditions123Verify();

 if(EnterLong)
 {  
  if(iBarShift(NULL,0,otl)>0)
  {
   comment=PrepareComment();  
   stop=NormDigits(StopLossPoints);
   take=NormDigits(TakeProfitPoints); 
   if(Use_Entry_Market_Order||Use_Entry_Exact_Price) SubmitLong(Lots[0],stop,take,comment);
   else Submit(true,Lots[0],stop,take,comment);
   OrderDirection=1;
  }
 } 
 
 if(EnterShort)
 { 
  if(iBarShift(NULL,0,ots)>0)
  { 
   comment=PrepareComment();    
   stop=NormDigits(StopLossPoints);
   take=NormDigits(TakeProfitPoints);  
   if(Use_Entry_Market_Order||Use_Entry_Exact_Price) SubmitShort(Lots[0],stop,take,comment);   
   else Submit(false,Lots[0],stop,take,comment);
   OrderDirection=-1;
  }
 } 

 return; 
}
//+------------------------------------------------------------------+
void Main3()
{
 if(!Use_Entry_3) return;
 
 if(MarketTotal>0||Bid<=Entry3SetSSpotlower||Bid>=Entry3SetSSpotupper)
 {
  if(flagEntry3SetShort) flagEntry3SetShort=false;
  if(flagEntry3SetLong) flagEntry3SetLong=false;  
 }

 if(!flagEntry3SetShort&&!flagEntry3SetLong) return;

 string comment;
 double stop,take;
 if(flagEntry3SetShort)
 {
  if(flagBBands2upper&&BBands2upper>=fivesixth)
  {
   comment=PrepareComment();
   stop=NormDigits(StopLossPoints);
   take=NormDigits(TakeProfitPoints); 
   SubmitShort(Lots[0],stop,take,comment);
   OrderDirection=-1;
   flagEntry3SetShort=false;
  }
 }
 else if(flagEntry3SetLong) 
 {
  if(flagBBands2lower&&BBands2lower<=onesixth)
  {
   comment=PrepareComment(); 
   stop=NormDigits(StopLossPoints);
   take=NormDigits(TakeProfitPoints); 
   SubmitLong(Lots[0],stop,take,comment);
   OrderDirection=1; 
   flagEntry3SetLong=false;
  }
 }
 
 return;
}
//+------------------------------------------------------------------+

void ManageOrders()
{
 AugmentWorkingBalance(); 
 CheckNumberOrder(false);
 
 if(MarketTotal==1)
 { 
  OrderSelect(MarketTicketN[0],SELECT_BY_TICKET);  
  FindOrderProfit();
  StealthSLTP();
  TrailStop();
 }
  
 //CheckOrders();
 if(MarketTotal>0) 
 {
  if(PendingTotal>0) CancelPendings(); 
  Recovery();
  ManageRecovery();
 }
 return;
}
//+------------------------------------------------------------------+
void Recovery()
{
 if(!Use_Level_Recovery&&!Use_Timed_Recovery) return;
 if(MarketTotal>=Level_Number) return;

 OrderSelect(MarketTicketN[MarketTotal-1],SELECT_BY_TICKET);

 if(Use_Timed_Recovery)
 {
  if(Time_Recovery_Frequency>0)
  {
   if(CheckTimedRecovery()) return;
  }
 } 
 
 FindOrderProfit(false);

 if(Use_Level_Recovery&&MarketTotal==1&&Use_Level_Round_Numbers) RoundNumberCorrection();
 
 if(Chart_Profit<=-LevelSpacingPoints)
 {
  string comment=PrepareComment(); 
  double stop=OrderFirstSL;
  double take;
  
  if(MarketTotal+1>=Level_Change_TP_1st_Entry) take=OrderFirstEntryPrice;
  else take=OrderFirstTP;
  
  if(OrderDirection>0)
  {
   MarketTicketN[MarketTotal]=SubmitLong(Lots[MarketTotal],stop,take,comment,true,true);
  }
  else if(OrderDirection<0)
  { 
   MarketTicketN[MarketTotal]=SubmitShort(Lots[MarketTotal],stop,take,comment,true,true);    
  }
  MarketTotal++;
  NumberTotal++;

  if(!flagModifiedFirstOrderTP) // change all prior TPs to first order TP
  {
   if(MarketTotal>=Level_Change_TP_1st_Entry)
   {
    for(int i=0;i<MarketTotal;i++)
    {
     OrderSelect(MarketTicketN[i],SELECT_BY_TICKET); 
     if(OrderTakeProfit()!=OrderFirstEntryPrice) ModifyOrder(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),OrderFirstEntryPrice,0,Magenta); 
    }
   }
  }
 }
 return;
}
//+------------------------------------------------------------------+
bool CheckTimedRecovery()
{
 if(!flagNewHour) return(true);
 
 int elapsedorderhours=MathFloor((TimeCurrent()-OrderOpenTime())/3600.); // elapsed hours fully completed
 
 int hourstofirstcheck=Time_Recovery_First_Time_Check-TimeHour(OrderOpenTime()); // need this to calculate whether to use first time check 

 if(hourstofirstcheck<=0) hourstofirstcheck=24+hourstofirstcheck; // flip in case first check time before order entry time 

 int targethour;
 if(elapsedorderhours<=hourstofirstcheck) targethour=Time_Recovery_First_Time_Check; // first time check
 else targethour=TimeCheckHour[ArrayBsearch(TimeCheckHour,TimeHour(TimeCurrent()))]; // ever afterward

 //Alert("Hour: ",TimeHour(TimeCurrent())," Elapsed-hours: ",elapsedorderhours," Target-hour: ",targethour," Hours-to-1st-check: ",hourstofirstcheck);

 if(TimeHour(TimeCurrent())==targethour) return(false);
   
 return(true);
}
//+------------------------------------------------------------------+
void ManageRecovery()
{
 BasketTP();
 BasketBE();
 BasketSL();
 return;
}
//+------------------------------------------------------------------+
void BasketTP()
{
 if(MarketTotal<Level_Basket_TP) return;

 bool closeall=false; 

 if(Mode_Basket_TP==1) // points
 {
  if(OrderDirection>0)
  {
   if(CheckPriceTarget(true,Bid,BasketTPPriceTarget,BufferBasketSLTPPoints,false)) closeall=true;
  }
  else
  {// ask here because points
   if(CheckPriceTarget(false,Ask,BasketTPPriceTarget,BufferBasketSLTPPoints,false)) closeall=true;
  }
 }
 else // price 
 {
  if(OrderDirection>0)
  {
   if(CheckPriceTarget(true,Bid,Basket_TP_Price,BufferBasketSLTPPoints,false)) closeall=true;   
  }
  else
  {// ask here because exact price 
   if(CheckPriceTarget(false,Ask,Basket_TP_Price,BufferBasketSLTPPoints,false)) closeall=true;   
  }
 }
 
 if(closeall) 
 {
  ExitAllOrders();
  SendAlert(StringConcatenate(IDNamePeriod," Basket Take Profit Exit"));
 }
 return;
}
//+------------------------------------------------------------------+
void BasketBE()
{
 if(MarketTotal<Level_Break_Even) return;

 bool closeall=false; 

 if(OrderDirection>0)
 {
  if(CheckPriceTarget(true,Bid,BasketBEPriceTarget,BufferBasketSLTPPoints,false)) closeall=true;
 }
 else
 {// ask here because points
  if(CheckPriceTarget(false,Ask,BasketBEPriceTarget,BufferBasketSLTPPoints,false)) closeall=true; 
 }

 if(closeall) 
 { 
  ExitAllOrders();
  SendAlert(StringConcatenate(IDNamePeriod," Basket Break Even Exit"));
 }
 return;
} 
//+------------------------------------------------------------------+
void BasketSL()
{
 bool closeall=false; 

 if(Mode_Basket_SL==1) // points
 {
  if(OrderDirection>0)
  {
   if(CheckPriceTarget(false,Bid,BasketSLPriceTarget,BufferBasketSLTPPoints,false)) closeall=true; 
  }
  else
  {// ask here because points 
   if(CheckPriceTarget(true,Ask,BasketSLPriceTarget,BufferBasketSLTPPoints,false)) closeall=true;   
  }
 }
 else if(Mode_Basket_SL==2) // price 
 {
  if(OrderDirection>0)
  {
   if(CheckPriceTarget(false,Bid,Basket_SL_Price,BufferBasketSLTPPoints,false)) closeall=true;   
  }
  else
  {// ask here because exact price 
   if(CheckPriceTarget(true,Ask,Basket_SL_Price,BufferBasketSLTPPoints,false)) closeall=true;   
  }
 }
 else // percentage
 {
  if(Drawdown>=Basket_SL_Percent) closeall=true;
 }

 if(closeall) 
 { 
  ExitAllOrders();
  SendAlert(StringConcatenate(IDNamePeriod," Basket Stop Loss Exit"));
 } 
 return;
}
//+------------------------------------------------------------------+
bool CheckPriceTarget(bool direction, double BidAsk, double target, double buffer, bool bracket=true)
{ 
 if(bracket)
 {
  if(direction)
  {
   if(BidAsk>=target&&BidAsk<=NormDigits(target+buffer)) return(true);
  }
  else
  {
   if(BidAsk<=target&&BidAsk>=NormDigits(target-buffer)) return(true);  
  }
 }
 else
 {
  if(direction)
  {
   if(BidAsk>=target) return(true);
  }
  else
  {
   if(BidAsk<=target) return(true);  
  } 
 }
 return(false);
}
//+------------------------------------------------------------------+
void RoundNumberCorrection()
{
 int index=ArrayBsearch(spacings,OrderOpenPrice());
 double nearestSS;
 if(OrderDirection>0)
 {
  nearestSS=spacings[index];
  Chart_Profit+=NormDigits(OrderOpenPrice()-nearestSS);
 }
 else
 {
  nearestSS=NormDigits(spacings[index]+SpacingPoints);
  Chart_Profit+=NormDigits(nearestSS-OrderOpenPrice());
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
void Submit(bool long, double lots, double stop, double take, string comment)
{
 double SL,TP,EP;
 datetime exp;

 if(long)
 {  

// markets
  
  if(SSpotlower<=onesixth)
  {
   if(Bid<=NormDigits(SSpotlower+BufferSSpotPoints))
   {
    SubmitLong(lots,stop,take,comment);
    return;
   }
  }
  
  if(SSpotupper<=onesixth)
  {
   if(Bid>=NormDigits(SSpotupper-BufferSSpotPoints))
   {
    SubmitLong(lots,stop,take,comment);
    return;
   }  
  }

// pendings

  if(expiration>0) exp=TimeCurrent()+expiration;
  else             exp=0;

  if(SSpotlower<=onesixth)
  {
   SL=StopLong(SSpotlower,stop);
   TP=TakeLong(SSpotlower,take);

   SendPending(Symbol(),OP_BUYLIMIT,SSpotlower,lots,Slippage,SL,TP,comment,Trade_Set_ID_Number,exp,Blue);

   SendAlert(StringConcatenate(IDNamePeriod," entered buy limit at ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES)));   
  }
  
  if(SSpotupper<=onesixth)
  {
   SL=StopLong(SSpotupper,stop);
   TP=TakeLong(SSpotupper,take);

   SendPending(Symbol(),OP_BUYSTOP,SSpotupper,lots,Slippage,SL,TP,comment,Trade_Set_ID_Number,exp,Blue);  

   SendAlert(StringConcatenate(IDNamePeriod," entered buy stop at ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES)));   
  }
  
  otl=TimeCurrent();
  triggered=true;  

 }
 else
 { 

// markets

  if(SSpotlower>=fivesixth)
  {
   if(Bid<=NormDigits(SSpotlower+BufferSSpotPoints))
   {
    SubmitShort(lots,stop,take,comment); 
    return;
   }     
  }

  if(SSpotupper>=fivesixth)
  {
   if(Bid>=NormDigits(SSpotupper-BufferSSpotPoints))
   {
    SubmitShort(lots,stop,take,comment);        
    return;
   }  
  }  

// pendings

  if(expiration>0) exp=TimeCurrent()+expiration;
  else             exp=0;

  if(SSpotlower>=fivesixth)
  {
   SL=StopShort(SSpotlower,stop);
   TP=TakeShort(SSpotlower,take);
   
   SendPending(Symbol(),OP_SELLSTOP,SSpotlower,lots,Slippage,SL,TP,comment,Trade_Set_ID_Number,exp,Red);    

   SendAlert(StringConcatenate(IDNamePeriod," entered sell stop at ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES)));
  }

  if(SSpotupper>=fivesixth)
  {
   SL=StopShort(SSpotupper,stop);
   TP=TakeShort(SSpotupper,take);

   SendPending(Symbol(),OP_SELLLIMIT,SSpotupper,lots,Slippage,SL,TP,comment,Trade_Set_ID_Number,exp,Red);

   SendAlert(StringConcatenate(IDNamePeriod," entered sell limit at ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES)));   
  }  

  ots=TimeCurrent();
  triggered=true;  

 }
 return;
}
//+------------------------------------------------------------------+
int SubmitLong(double lots, double stop, double take, string comment, bool takeprice=false, bool stopprice=false)
{
 int TicketN=SendOrderLong(Symbol(),lots,Slippage,0,0,comment,Trade_Set_ID_Number);
 TagSLTP(true,TicketN,stop,take,takeprice,stopprice); 

 otl=TimeCurrent();
 triggered=true;
 SendAlert(StringConcatenate(IDNamePeriod," entered buy market at ",TimeToStr(otl,TIME_DATE|TIME_MINUTES)));
 return(TicketN);
}
//+------------------------------------------------------------------+
int SubmitShort(double lots, double stop, double take, string comment, bool takeprice=false, bool stopprice=false)
{
 int TicketN=SendOrderShort(Symbol(),lots,Slippage,0,0,comment,Trade_Set_ID_Number);
 TagSLTP(false,TicketN,stop,take,takeprice,stopprice);

 ots=TimeCurrent();
 triggered=true;
 SendAlert(StringConcatenate(IDNamePeriod," entered sell market at ",TimeToStr(ots,TIME_DATE|TIME_MINUTES))); 
 return(TicketN);
}
//+------------------------------------------------------------------+
void TagSLTP(bool long,int OrderTicketN, double stop, double take, bool takeprice=false, bool stopprice=false)
{
 OrderSelect(OrderTicketN,SELECT_BY_TICKET);
 double EP=OrderOpenPrice();
  
 double SL,TP;
 
 if(long)
 {
  if(stopprice) SL=stop;
  else SL=StopLong(EP,stop);
  
  if(takeprice) TP=take;
  else TP=TakeLong(EP,take); 
 }
 else
 {
  if(stopprice) SL=stop;
  else SL=StopShort(EP,stop);
  
  if(takeprice) TP=take;
  else TP=TakeShort(EP,take);
 }
  
 AddSLTP(SL,TP,OrderTicketN);

 return;
}
//+------------------------------------------------------------------+
void StealthSLTP()
{
 if(Order_Profit>=NormDigits(TakeProfitPoints-NormPoints(MarketInfo(Symbol(),MODE_SPREAD))))
 {
  ExitOrder(true,true);
  SendAlert(StringConcatenate(IDNamePeriod," Stealth Take Profit Exit"));   
  SecondaryTradeSetup();
 }
  
 if(flagSLOpenPrice)
 {
  if(Order_Profit<=-NormDigits(StopLossPoints-NormPoints(MarketInfo(Symbol(),MODE_SPREAD)))) 
  {  
   ExitOrder(true,true);
   SendAlert(StringConcatenate(IDNamePeriod," Stealth Stop Loss Exit"));   
  }
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
 for(int z=0;z<5;z++)
 {
  if(!OrderClose(ticket,NormLots(lots),Bid,slip,cl))
  {  
   int err = GetLastError();
   Print("OrderClose Long failed, Error: ", err, " Ticket #: ", ticket);
   Print("Bid: ", DoubleToStr(Bid,Digits), " Ask: ", DoubleToStr(Ask,Digits));
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
 for(int z=0;z<5;z++)
 {
  if(!OrderClose(ticket,NormLots(lots),Ask,slip,cl))
  {  
   int err = GetLastError();
   Print("OrderClose Short failed, Error: ", err, " Ticket #: ", ticket);
   Print("Bid: ", DoubleToStr(Bid,Digits), " Ask: ", DoubleToStr(Ask,Digits));  
   if(err>4000) break;
   RefreshRates();
  }
  else break;
 }
 ReleaseSemaphore();
} 
//+------------------------------------------------------------------+
bool DeleteOrder(int ticket)
{
 GetSemaphore();
 for(int z=0;z<5;z++)
 {
  if(!OrderDelete(ticket))
  {  
   int err = GetLastError();
   Print("OrderDelete failed, Error: ", err, " Ticket #: ", ticket);
   Print("Bid: ", DoubleToStr(Bid,Digits), " Ask: ", DoubleToStr(Ask,Digits));   
   if(err>4000) break;
   RefreshRates();
  }
  else break;
 } 
 ReleaseSemaphore();
 SendAlert(StringConcatenate(IDNamePeriod," deleted pending #,",DoubleToStr(ticket,0)," at ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES))); 
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
 for(int z=0;z<5;z++)
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
void ExitOrder(bool flag_Long,bool flag_Short)
{
 if(OrderType()==OP_BUY&&flag_Long)
  CloseOrderLong(OrderTicket(),OrderLots(),Slippage,Lime);
 else if(OrderType()==OP_SELL&&flag_Short)
  CloseOrderShort(OrderTicket(),OrderLots(),Slippage,Lime);
 return;
}
//+------------------------------------------------------------------+ 
void ExitAllOrders()
{ 
 for(int i=0;i<MarketTotal;i++)
 {
  OrderSelect(MarketTicketN[i],SELECT_BY_TICKET);
  ExitOrder(true,true);
 }
 triggered=false;
 return;
}
//+------------------------------------------------------------------+ 
bool ExitAll()
{
 int input=MessageBox(IDName+" \nClose All Trades \n\nYes = Close All Trades \nNo  = Do Not Close All Trades", WindowExpertName()+" Close All Trades Confirmation", MB_YESNO|MB_ICONQUESTION|MB_DEFBUTTON1); 
 
 if(input==IDNO) return(false);
 
 int trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderMagicNumber()!=Trade_Set_ID_Number) continue; 
  if(OrderType()==OP_BUY||OrderType()==OP_SELL) ExitOrder(true,true);
  else DeleteOrder(OrderTicket());
 }
 
 return(true);
}
//+------------------------------------------------------------------+
void CancelPendings()
{
 for(int i=0;i<PendingTotal;i++)
 {
  DeleteOrder(PendingTicketN[i]);
 }
 return;
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
 if(Mode_Take_Profit==1)
 {
  if(take==0) return(0);
  return(NormDigits(price+take));
 }
 else return(Take_Profit_Price);
}
//+------------------------------------------------------------------+
double TakeShort(double price,double take)
{
 if(Mode_Take_Profit==1)
 {
  if(take==0) return(0);
  return(NormDigits(price-take)); 
 }
 else return(Take_Profit_Price); 
}
//+------------------------------------------------------------------+
double StopShort(double price,double stop)
{
 if(Mode_Stop_Loss==1)
 {
  if(stop==0) return(0);
  return(NormDigits(price+stop)); 
 }
 else return(Stop_Loss_Price);
}
//+------------------------------------------------------------------+
double StopLong(double price,double stop)
{
 if(Mode_Stop_Loss==1)
 {
  if(stop==0) return(0);
  return(NormDigits(price-stop)); 
 }
 else return(Stop_Loss_Price); 
}
//+------------------------------------------------------------------+
void FixedStopsB(double PP,double PFS)
{
  double stopcrnt,stopcal;
  double profitpoint; 

  stopcrnt=OrderStopLoss();
  profitpoint=PP;  
          
  if(OrderType()==OP_BUY)
  {
   //profit=NormDigits(Bid-OrderOpenPrice());
   
   if(Order_Profit>=profitpoint)
   {
    stopcal=NormDigits(OrderOpenPrice()+PFS);
    ModifyCompLong(stopcal,stopcrnt);
   }
  }    

  if(OrderType()==OP_SELL)
  {  
   //profit=NormDigits(OrderOpenPrice()-Ask);
   
   if(Order_Profit>=profitpoint)
   {
    stopcal=NormDigits(OrderOpenPrice()-PFS);
    ModifyCompShort(stopcal,stopcrnt);  
   }
  }
 return;
}
//+------------------------------------------------------------------+
void TrailStop()
{
 if(Use_Move_SL_Profit) FixedStopsB(MoveStopLossProfitPoints,MoveStopLossAmountPoints);
 
 if(!Use_Trail_Stop) return;
 
 if(Use_Trail_After_Break_Even)
 {
  if(flagSLOpenPrice) return;
 }
  
 if(Use_Tightening_Trail)
 {
  if(Order_Profit>=profitpoints80) TrailingStop(TighteningTrail80Points);
  else if(Order_Profit>=profitpoints50) TrailingStop(TighteningTrail50Points);
  else  TrailingStop(TrailStopPoints);
 }
 else TrailingStop(TrailStopPoints);
 
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
void AddSLTP(double sl, double tp, int orderNumber)
{
 if(sl==0&&tp==0) return;
 if(OrderSelect(orderNumber,SELECT_BY_TICKET)) 
  ModifyOrder(orderNumber,OrderOpenPrice(),sl,tp,0,CLR_NONE);
 return;
}
//+------------------------------------------------------------------+ 
void AugmentWorkingBalance()
{
 for(int i=0;i<MarketTotal;i++)
 {
  OrderSelect(MarketTicketN[i],SELECT_BY_TICKET);
  if(OrderCloseTime()==0) continue;
  EA_Working_Balance+=OrderProfit();
  if(OrderType()==OP_BUY) SendAlert(StringConcatenate(IDNamePeriod," closed buy #,",DoubleToStr(OrderTicket(),0)," at ",TimeToStr(OrderCloseTime(),TIME_DATE|TIME_MINUTES)));  
  else if(OrderType()==OP_SELL) SendAlert(StringConcatenate(IDNamePeriod," closed sell #,",DoubleToStr(OrderTicket(),0)," at ",TimeToStr(OrderCloseTime(),TIME_DATE|TIME_MINUTES)));  
 }
 return;
}
//+------------------------------------------------------------------+
void CheckNumberOrder(bool reset)
{
 triggered=false;
 NumberTotal=0;MarketTotal=0;PendingTotal=0;LotsTotal=0;
 BasketPriceTarget=0;BasketProfit=0;Drawdown=0;
 BasketTPPriceTarget=0;BasketBEPriceTarget=0;BasketSLPriceTarget=0;
 int trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderMagicNumber()!=Trade_Set_ID_Number) continue; 
  TakeOrderStats();
  triggered=true;
 }
 
 if(MarketTotal>0) 
 {
  ArraySort(MarketTicketN,MarketTotal,0,MODE_ASCEND); // now [0] is 1st trade
  OrderSelect(MarketTicketN[0],SELECT_BY_TICKET);
  OrderFirstEntryPrice=OrderOpenPrice();
  OrderFirstSL=OrderStopLoss();
  OrderFirstTP=OrderTakeProfit();  
  OrderFirstLots=OrderLots();
  flagModifiedFirstOrderTP=false;
  if(OrderOpenPrice()==OrderTakeProfit()) flagModifiedFirstOrderTP=true; 
  if(OrderDirection>0) 
  {
   BasketBEPriceTarget=NormDigits(Divide(BasketPriceTarget,LotsTotal));
   BasketTPPriceTarget=NormDigits(Divide(BasketTPPoints*OrderFirstLots,LotsTotal)+BasketBEPriceTarget);
   BasketSLPriceTarget=NormDigits(BasketBEPriceTarget-Divide(BasketSLPoints*OrderFirstLots,LotsTotal));
  }
  else            
  {
   BasketBEPriceTarget=NormDigits(Divide(BasketPriceTarget,LotsTotal));
   BasketTPPriceTarget=NormDigits(BasketBEPriceTarget-Divide(BasketTPPoints*OrderFirstLots,LotsTotal));
   BasketSLPriceTarget=NormDigits(Divide(BasketSLPoints*OrderFirstLots,LotsTotal)+BasketBEPriceTarget);
  }  
  Drawdown=Divide(BasketProfit,EA_Working_Balance)*100.;
 }
 
 if(reset)
 {
  if(NumberTotal==0) 
  {
   ResetOrderArrays();
  }
 }
 return;
}
//+------------------------------------------------------------------+
void TakeOrderStats()
{
 if(OrderType()==OP_BUY)
 {
  OrderDirection=1;
  MarketTicketN[MarketTotal]=OrderTicket();   
  MarketTotal++;
  NumberTotal++;
  LotsTotal+=OrderLots();
  BasketPriceTarget+=OrderLots()*OrderOpenPrice();//no NormDigits here for accuracy
  BasketProfit+=OrderProfit();
 }
 else if(OrderType()==OP_SELL)
 {
  OrderDirection=-1;
  MarketTicketN[MarketTotal]=OrderTicket();   
  MarketTotal++;  
  NumberTotal++;   
  LotsTotal+=OrderLots(); 
  BasketPriceTarget+=OrderLots()*OrderOpenPrice();//no NormDigits here for accuracy 
  BasketProfit+=OrderProfit();      
 }
 else if(OrderType()==OP_BUYLIMIT)
 {
  OrderDirection=1;
  PendingTicketN[PendingTotal]=OrderTicket();   
  PendingTotal++;
  NumberTotal++;  
 }
 else if(OrderType()==OP_BUYSTOP)
 {
  OrderDirection=1;
  PendingTicketN[PendingTotal]=OrderTicket();    
  PendingTotal++;
  NumberTotal++;   
 }
 else if(OrderType()==OP_SELLLIMIT)
 {
  OrderDirection=-1;
  PendingTicketN[PendingTotal]=OrderTicket();    
  PendingTotal++;
  NumberTotal++;  
 }
 else if(OrderType()==OP_SELLSTOP)
 {
  OrderDirection=-1;
  PendingTicketN[PendingTotal]=OrderTicket();    
  PendingTotal++;
  NumberTotal++;   
 }  
 return;
}
//+------------------------------------------------------------------+
int InitializeLots()
{
 int k=0;
 double calclots=First_Lot_Size;
 while(k<Level_Number)
 {
  Lots[k]=calclots;
  calclots*=Lot_Size_Multiplier;
  k++;
 }
// for(int i=0;i<k;i++) Alert(i," ",Lots[i]);
 return(k);
}
//+------------------------------------------------------------------+
void InitializeVariables()
{
 if(MACD_Upper_Limit!=0) MACDUpperLimit=MACD_Upper_Limit;
 if(MACD_Lower_Limit!=0) MACDLowerLimit=MACD_Lower_Limit; 
 
 expiration=3600*Pending_Expiration_Hours;
 
 ArrayResize(Lots,Level_Number);
 ArrayResize(MarketTicketN,Level_Number);
 
 profitpoints50=NormPoints(0.5*TakeProfitPoints);
 profitpoints80=NormPoints(0.8*TakeProfitPoints); 
 
 otl=0; ots=0;
 
 MACDUpperMult=0.01*Stoch_Upper_Limit;
 MACDLowerMult=0.01*Stoch_Lower_Limit; 
 
 if(Time_Recovery_First_Time_Check<0||Time_Recovery_First_Time_Check>23) Time_Recovery_First_Time_Check=0;
 if(Time_Recovery_Frequency<0||Time_Recovery_Frequency>5) Time_Recovery_Frequency=0;
 
 TimeCheckHourSeparation=TimeCheckHourSeparationArray[Time_Recovery_Frequency];
 TimeCheckFreq=TimeCheckFreqArray[Time_Recovery_Frequency];
 
 BasketTPPriceTarget=0;
 BasketBEPriceTarget=0;
 BasketSLPriceTarget=0;  
 
 if(!Use_MACDStoch)
 {
  flagMACDup=true;flagMACDdown=true;
  flagSTOCHup=true;flagSTOCHdown=true;  
 }
 
 return;
}
//+------------------------------------------------------------------+
void InitializeTimes()
{
// frequency of timed recovery check: 0(always), 1(every hour), 2(every 3 hours), 3(every 6 hours), 4(every 12 hours), 5(every 24 hours)
 ArrayResize(TimeCheckHour,TimeCheckFreq);
 
 int value;
 
 for(int i=0;i<TimeCheckFreq;i++)
 {
  value=(Time_Recovery_First_Time_Check+(i*TimeCheckHourSeparation))%24;
  TimeCheckHour[i]=value;
  //Alert(i," ",TimeCheckHour[i]);
 }
 
 ArraySort(TimeCheckHour);
 
 return;
}
//+------------------------------------------------------------------+

bool CheckConflict()
{
 if(!Use_Entry_Market_Order&&!Use_Entry_Exact_Price&&!Use_Entry_1&&!Use_Entry_2&&!Use_Entry_3)
 {
  MessageBox(IDName+" \n\nAll Entry Methods are False!\n\nEA will be disabled. \n\nPlease fix inputs and re-apply EA.", WindowExpertName()+" Input Conflict Alert", MB_OK|MB_ICONERROR); 
  return(true); 
 }
 else if(Use_Entry_Market_Order&&Use_Entry_Exact_Price)
 {
  MessageBox(IDName+" \n\nMarket Entry is selected with Exact Price Entry!\n\nEA will be disabled. \n\nPlease fix inputs and re-apply EA.", WindowExpertName()+" Input Conflict Alert", MB_OK|MB_ICONERROR);   
  return(true);
 }
 else if(Use_Entry_Exact_Price)
 {
  if(First_Long&&First_Short) 
  {
   MessageBox(IDName+" \n\nExact Price Entry: Both First_Long and First_Short are set to True!\n\nEA will be disabled. \n\nPlease fix inputs and re-apply EA.", WindowExpertName()+" Input Conflict Alert", MB_OK|MB_ICONERROR); 
   return(true);
  } 
  else if(!First_Long&&!First_Short)
  {
   MessageBox(IDName+" \n\nExact Price Entry: Neither First_Long nor First_Short is selected!\n\nEA will be disabled. \n\nPlease fix inputs and re-apply EA.", WindowExpertName()+" Input Conflict Alert", MB_OK|MB_ICONERROR);    
   return(true);
  }
  else if(Use_Level_Recovery&&Use_Timed_Recovery)
  {
   MessageBox(IDName+" \n\nRecovery Level Selection: Both Level and Timed Recoveries are selected!\n\nEA will be disabled. \n\nPlease fix inputs and re-apply EA.", WindowExpertName()+" Input Conflict Alert", MB_OK|MB_ICONERROR);    
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
  Disable=true;
  IDNamePeriod=StringConcatenate(Symbol()," ",timename," ID# ",DoubleToStr(Trade_Set_ID_Number,0)," is DISABLED.");  
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
   if(CheckPriceTarget(true,Bid,Exact_Entry_Price,BufferPoints)) EnterLong=true;  
  }
  else // limit entry case 
  {
   if(CheckPriceTarget(false,Bid,Exact_Entry_Price,BufferPoints)) EnterLong=true;    
  }
 }
 else if(First_Short)
 {
  if(BufferPoints>=0) // stop entry case 
  {
   if(CheckPriceTarget(false,Bid,Exact_Entry_Price,BufferPoints)) EnterShort=true;    
  }
  else // limit entry case 
  {
   if(CheckPriceTarget(true,Bid,Exact_Entry_Price,BufferPoints)) EnterShort=true;    
  }
 } 
 return;
}//+------------------------------------------------------------------+
void EntryConditions123Verify()
{
 EnterLong=false;EnterShort=false;
 // don't reset Entry3Set internal parameters here to ensure persistent triggering conditions
 // reset Entry3Set internal parameters in Main3()
 
 if(Use_Entry_1)
 {
  if(flagBBands1upper&&flag56up)
  {
   if(fivesixth>=BBands1upper) 
   {
    if(flagMACDup&&flagSTOCHup) EnterShort=true;
   }
  }
  else if(flagBBands1lower&&flag16down)
  {
   if(onesixth<=BBands1lower) 
   {
    if(flagMACDdown&&flagSTOCHdown) EnterLong=true;
   }
  }
 }

 if(Use_Entry_2)
 {
  if(flagBBands1upper&&flag56up)
  {
   if(fivesixth<=BBands1upper) 
   {
    if(flagMACDup&&flagSTOCHup) EnterShort=true;
   }
  }
  else if(flagBBands1lower&&flag16down)
  {
   if(onesixth>=BBands1lower) 
   {
    if(flagMACDdown&&flagSTOCHdown) EnterLong=true;
   }
  } 
 } 

 if(Use_Entry_3)
 {
  if(flagBBands1upper&&flag56up)
  {
   if(flagMACDup&&flagSTOCHup) 
   {
    flagEntry3SetShort=true;
    Entry3SetSSpotupper=SSpotupper;
    Entry3SetSSpotlower=SSpotlower;
   }
  }
  else if(flagBBands1lower&&flag16down)
  {
   if(flagMACDdown&&flagSTOCHdown) 
   {
    flagEntry3SetLong=true;
    Entry3SetSSpotupper=SSpotupper;
    Entry3SetSSpotlower=SSpotlower; 
   }
  }
 }

} 
return;
//+------------------------------------------------------------------+
string PrepareComment()
{
 string name=" ";

 if(Hide_EA_Comment) name=" ";
 else name=StringConcatenate(IDNameComment," ",EAName);
 
 return(name);
}
//+------------------------------------------------------------------+
void ResetOrderArrays()
{
 for(int i=0;i<Level_Number;i++) MarketTicketN[i]=0;
 PendingTicketN[0]=0;
 PendingTicketN[1]=0;
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
void CheckIndicators1()
{
 if(!Use_MACDStoch) return;
 
 flagMACDup=false;flagMACDdown=false;
 flagSTOCHup=false;flagSTOCHdown=false;
  
 double macd=iMACD(NULL,0,MACD_FastEMA,MACD_SlowEMA,MACD_SignalSMA,MACD_Price,MODE_MAIN,1);

 if(MACD_Upper_Limit==0||MACD_Lower_Limit==0) // auto calc 15/85 max-min values
 {
  double max=-9999,min=9999;
  double macdi,diff;
  int barscount=WindowBarsPerChart();
  for(int i=0;i<barscount;i++)
  {
   macdi=iMACD(NULL,0,MACD_FastEMA,MACD_SlowEMA,MACD_SignalSMA,MACD_Price,MODE_MAIN,i);
   if(macdi>max)      max=macdi;
   else if(macdi<min) min=macdi;
  }
  diff=max-min;
  if(MACD_Upper_Limit==0) MACDUpperLimit=NormDigits(min+(MACDUpperMult*diff));
  if(MACD_Lower_Limit==0) MACDLowerLimit=NormDigits(min+(MACDLowerMult*diff));
 }

 double stoch1=iStochastic(NULL,0,Stoch1_K_Period,Stoch1_D_Period,Stoch1_Slow_Period,Stoch1_MA_Method,Stoch1_MA_Price,MODE_MAIN,1);
 double stoch2=iStochastic(NULL,0,Stoch2_K_Period,Stoch2_D_Period,Stoch2_Slow_Period,Stoch2_MA_Method,Stoch2_MA_Price,MODE_MAIN,1);

 if(macd>=MACDUpperLimit) flagMACDup=true;
 else if(macd<=MACDLowerLimit) flagMACDdown=true;

 if(stoch1>=Stoch_Upper_Limit&&stoch2>=Stoch_Upper_Limit) flagSTOCHup=true;
 else if(stoch1<=Stoch_Lower_Limit&&stoch2<=Stoch_Lower_Limit) flagSTOCHdown=true;

 return;
}
//+------------------------------------------------------------------+
void CheckIndicators2()
{
 flagBBands1upper=false;flagBBands1lower=false;
 flagBBands2upper=false;flagBBands2lower=false; 
 
 BBands1upper=iBands(NULL,0,BBands1_Period,BBands1_Deviations,BBands1_Shift,BBands1_Price,MODE_UPPER,0);
 BBands1lower=iBands(NULL,0,BBands1_Period,BBands1_Deviations,BBands1_Shift,BBands1_Price,MODE_LOWER,0);
 
 if(Bid>=BBands1upper) flagBBands1upper=true;
 if(Bid<=BBands1lower) flagBBands1lower=true;

 BBands2upper=iBands(NULL,0,BBands2_Period,BBands2_Deviations,BBands2_Shift,BBands2_Price,MODE_UPPER,0);
 BBands2lower=iBands(NULL,0,BBands2_Period,BBands2_Deviations,BBands2_Shift,BBands2_Price,MODE_LOWER,0);
 
 if(Bid<=BBands2upper) flagBBands2upper=true;
 if(Bid>=BBands2lower) flagBBands2lower=true;

 return;
}
//+------------------------------------------------------------------+
void CheckIndicators3()
{
 flag56up=false;flag16down=false;
 
 double value = WindowPriceMax(0)-WindowPriceMin(0);
 double sixth = value/6.0;
 double valueS = (value*(MathPow(10,Digits)));
 double sixthS = (sixth*(MathPow(10,Digits)));  
 double seventh = value/7;
 double seventhS = (seventh*(MathPow(10,Digits)));
   
// onesixth=NormDigits(WindowPriceMin(0)+sixth);
// fivesixth=NormDigits(WindowPriceMin(0)+(5.0*sixth));

 onesixth=NormDigits(WindowPriceMin(0)+(2.0*sixth)); // TEST: 2/6 - looser
 fivesixth=NormDigits(WindowPriceMin(0)+(4.0*sixth)); // TEST: 4/6 - looser
 
 if(Bid>=fivesixth) flag56up=true;
 else if(Bid<=onesixth) flag16down=true;

 sixthstring=StringConcatenate("\nSixths: ",DoubleToStr(onesixth,Digits),"/",DoubleToStr(fivesixth,Digits),
                               "\nTop to bottom : ", valueS, 
                               "\nDistance between lines : ", sixthS, 
                               "\nTAKE PROFIT DISTANCE : ", seventhS);
 
 return;
}
//+------------------------------------------------------------------+
void CheckIndicators4()
{
 spacinglower=ArrayBsearch(spacings,Bid);
 spacingupper=spacinglower+1;
 SSpotlower=spacings[spacinglower];
 if(spacingupper<100) SSpotupper=spacings[spacingupper];
 else                 SSpotupper=NormDigits(SSpotlower+SpacingPoints);
 spacingstring=StringConcatenate("\nSweetSpots : ",DoubleToStr(SSpotlower,Digits),"/",DoubleToStr(SSpotupper,Digits));
 return;
}
//+------------------------------------------------------------------+
void GenerateSweetSpots()
{
 double newprice;
 double midprice=WindowPriceMax(0)-WindowPriceMin(0);
 midprice=NormDigits(WindowPriceMin(0)+(0.5*midprice));
 if(Digits>=4) midprice*=100.; // no need for JPY pairs
 midprice=MathFloor(midprice); 
 if(Digits>=4) midprice/=100.; // no need for JPY pairs
 
 spacings[49]=midprice;

 newprice=midprice;
 for(int i=48;i>=0;i--)
 {
  newprice=NormDigits(newprice-SpacingPoints);
  spacings[i]=newprice;
 }
 
 newprice=midprice; 
 for(i=50;i<100;i++)
 {
  newprice=NormDigits(newprice+SpacingPoints);
  spacings[i]=newprice;
 }
   
 return;
}
//+------------------------------------------------------------------+
void UpdateDataWindow()
{
 string info,dfstring,dnstring,basketSLstring,ticketstring="\nTicket #s : ";
 double value,TPPriceTarget;
 int i;
 
 if(Mode_Basket_TP==1) TPPriceTarget=BasketTPPriceTarget;
 else TPPriceTarget=Basket_TP_Price;

 if(Mode_Basket_SL==1) 
 {
  basketSLstring=StringConcatenate("\nBasket SL Target $ ",DoubleToStr(BasketSLPriceTarget,Digits));
 }
 else if(Mode_Basket_SL==2)
 {
  basketSLstring=StringConcatenate("\nBasket SL Target $ ",DoubleToStr(Basket_SL_Price,Digits));  
 }
 else
 {
  basketSLstring=StringConcatenate("\nBasket SL % Exit : ",DoubleToStr(Basket_SL_Percent,2),"%");   
 }

 for(i=0;i<PendingTotal;i++)
 {
  ticketstring=StringConcatenate(ticketstring," ",PendingTicketN[i]);
 }
 
 for(i=0;i<MarketTotal;i++)
 {
  ticketstring=StringConcatenate(ticketstring," ",MarketTicketN[i]);
 }
 
 info = StringConcatenate(IDNamePeriod,
                          entrymethodstring,
                          "\nSpread : ",DoubleToStr(MarketInfo(Symbol(),MODE_SPREAD)*precisionmultiplier,precisiondigits),
                          ticketstring,
                          "\nEA Working Balance $ ",DoubleToStr(EA_Working_Balance,2),
                          "\nBasket P/L $ ",DoubleToStr(BasketProfit,2),  
                          "\nBasket TP Target $ ",DoubleToStr(TPPriceTarget,Digits),
                          "\nBasket BE Target $ ",DoubleToStr(BasketBEPriceTarget,Digits),                          
                          basketSLstring,                          
                          "\nBasket Drawdown : ",DoubleToStr(Drawdown,2),"%",
                          commentsectionstring,
                          "\nBasket Lots : ",DoubleToStr(LotsTotal,lotsprecision),
                          "\nAcc Balance $ ",DoubleToStr(AccountBalance(),2),
                          "\nAcc Equity $ ",DoubleToStr(AccountEquity(),2),
                          "\nMargin Free $ ",DoubleToStr(AccountFreeMargin(),2),
                          "\nMargin Used $ ",DoubleToStr(AccountMargin(),2),
                          "\nUp Flags : ",flagBBands1upper," ",flagBBands2upper," ",flag56up," ",flagMACDup," ",flagSTOCHup, 
                          "\nDown Flags : ",flagBBands1lower," ",flagBBands2lower," ",flag16down," ",flagMACDdown," ",flagSTOCHdown, 
                          "\nMACD Limits : ",DoubleToStr(MACDUpperLimit,Digits),"/",DoubleToStr(MACDLowerLimit,Digits),
                          spacingstring,
                          sixthstring);
 Comment(info);
 return;
}
//+------------------------------------------------------------------+
void CheckError()
{
 int error=GetLastError(); 
 if(error!=0)
 {
  Print("Check Error: ",error);
 } 
 return;
}
//+------------------------------------------------------------------+
/*
void CheckOrders()
{
 Alert("Market: ",MarketTotal,", Pending: ",PendingTotal,", Total: ",NumberTotal);
 for(int i=0;i<MarketTotal;i++) Alert("Market: ",i," ",MarketTicketN[i]);
 for(i=0;i<PendingTotal;i++) Alert("Pending: ",i," ",PendingTicketN[i]); 
 return;
}
*/
//+------------------------------------------------------------------+
void FindOrderProfit(bool trueprofit=true) // trueprofit = true is actual points profit, = false is chart spacing profit
{
 flagSLOpenPrice=false;
 
 if(trueprofit) // actual order profit
 {
  if(OrderType()==OP_BUY)       
  {
   Order_Profit=NormDigits(Bid-OrderOpenPrice());
   if(OrderStopLoss()<OrderOpenPrice()) flagSLOpenPrice=true;
  }
  else if(OrderType()==OP_SELL) 
  {
   Order_Profit=NormDigits(OrderOpenPrice()-Ask);
   if(OrderStopLoss()>OrderOpenPrice()) flagSLOpenPrice=true;
  }
 }
 else // chart spacing profit for recovery
 {
  if(OrderType()==OP_BUY)       
  {
   Chart_Profit=NormDigits(Ask-OrderOpenPrice()); // note Ask
   if(OrderStopLoss()<OrderOpenPrice()) flagSLOpenPrice=true;
  }
  else if(OrderType()==OP_SELL) 
  {
   Chart_Profit=NormDigits(OrderOpenPrice()-Bid); // note Bid
   if(OrderStopLoss()>OrderOpenPrice()) flagSLOpenPrice=true;
  } 
 }
 return;
}
//+------------------------------------------------------------------+
void SendAlert(string message)
{
 if(!Alert_Entry_Exit) return;
 Alert(message);
 return;
}
//+------------------------------------------------------------------+
void SecondaryTradeSetup()
{
 if(!Alert_Secondary_Trade_Setup) return;
 int input=MessageBox(IDName+" \nSecondary Trade Setup \n\nYes = Use Secondary Trade Conditions \nNo  = Use Primary Trade Conditions \n\nCancel = Disable EA (Hibernate)", WindowExpertName()+" Secondary Trade Setup Confirmation", MB_YESNOCANCEL|MB_ICONQUESTION|MB_DEFBUTTON3); 
 if(input==IDYES) 
 {
  Use_Entry_1=false; //   do not use entry condition #1
  Use_Entry_2=true; //           use entry condition #2
  Use_Entry_3=false; //   do not use entry condition #3
  Use_MACDStoch=false; // do not use MACD & Stoch conditions

  flagMACDup=true;flagMACDdown=true;
  flagSTOCHup=true;flagSTOCHdown=true;    
 }
 else if(input==IDNO) 
 {
  // no changes
 }
 else if(input==IDCANCEL)
 {
  Disable=true;
  IDNamePeriod=StringConcatenate(Symbol()," ",timename," ID# ",DoubleToStr(Trade_Set_ID_Number,0)," is DISABLED.");  
 }
 return; 
}
//+------------------------------------------------------------------+


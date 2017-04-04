//+----------------------------------------------------------------------+
//|                                                       Shelvan EA.mq4 |
//|                                                         David J. Lin |
//| Shelvan EA                                                           |
//| based on a trading strategy by                                       |
//| Pannirshelvan Kannuthurai (p.kannuthurai@inukshukfoundation.org)     |
//|                                                                      |
//| Coded by David J. Lin (dave.j.lin@gmail.com)                         |
//| Evanston, IL, April 14-22, 2012                                      |
//| April 28, 2012 v1.01: increased limits from 12 to 12x4               |
//| May 12, 2012 v1.02: add RSI/HP and supporting components             |
//| May 17, 2012 v1.03: reverse logic for RSI, add RightSpace param      |
//| May 19-20, 2012 v1.04: add 3 Exit Units, 2 Exit Modes                | 
//| June 2-3, 2012 v1.05: trail, RSI8 period separation, MFI, FracZigZag,|
//|                       subsequent trades based on seconds not bars,   |
//|                       user-specified RSI-HP timeframe                |
//| June 17, 2012 v1.06: trail convergence function                      |
//| June 23, 2012 v1.07: add 2 RSI/HP, 1 MF, FirstTrailMoveToProfit      |
//| June 30, 2012 v1.08: pips-to-points, add 1 MF, MF trail, subsequent  |
//|                      order based on previous order's SL requirement  |
//| July 4, 2012: v1.09: add NewEntrySLCondition to turn on/off          |
//|                      subsequent order entry                          |
//| July 14, 2012: v1.10: change trail parm names, add volume indicator  |
//| July 30, 2012: v1.11: make Magic parameter user specified            |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2012, Pannirshelvan Kannuthurai & David J. Lin"

// External user adjustable parameters:

//===== Order parameters =====

extern double Lots=0.01; // lot size per order 
extern int Max_Orders=5; // maximum number of simultaneous orders per direction
extern int Next_Order_Seconds=60; // seconds after first entry to consider possible next entry in the same direction

//===== RSI/HP Indicator parameters =====

// RSI/HP Entry Toggle (true: use for entry criteria, false: don't use for entry criteria)

extern bool RSIHP_Entry_1=true;
extern bool RSIHP_Entry_2=true;
extern bool RSIHP_Entry_3=true;

// RSI/HP Exit Toggle (true: use for exit criteria, false: don't use for exit criteria)

extern bool RSIHP_Exit_1=true;

// RSI/HP Limits (user defined limits for entry/exit criteria)

// Long Entry

extern double RSIHP_Long_Entry_Limit_1=55;
extern double RSIHP_Long_Entry_Limit_2=65;
extern double RSIHP_Long_Entry_Limit_3=75;

// Long Exit

extern double RSIHP_Long_Exit_Limit_1=45;

// Short Entry

extern double RSIHP_Short_Entry_Limit_1=45;
extern double RSIHP_Short_Entry_Limit_2=35;
extern double RSIHP_Short_Entry_Limit_3=25;

// Short Exit

extern double RSIHP_Short_Exit_Limit_1=55;

// RSIHP: HP input parameters

// Timeframe:
extern int RSIHP_HP_Timeframe_1=PERIOD_M1; //RSI/HP: HP parameter: timeframe
extern int RSIHP_HP_Timeframe_2=PERIOD_M5; //RSI/HP: HP parameter: timeframe
extern int RSIHP_HP_Timeframe_3=PERIOD_M15; //RSI/HP: HP parameter: timeframe

// nobs:
extern int RSIHP_HP_nobs_1    =100000;     //RSI/HP: HP parameter: Number of bars to smooth
extern int RSIHP_HP_nobs_2    =100000;     //RSI/HP: HP parameter: Number of bars to smooth
extern int RSIHP_HP_nobs_3    =100000;     //RSI/HP: HP parameter: Number of bars to smooth

// FiltPer:
extern int RSIHP_HP_FiltPer_1 =7;          //RSI/HP: HP parameter: Equivalent to SMA period
extern int RSIHP_HP_FiltPer_2 =7;          //RSI/HP: HP parameter: Equivalent to SMA period
extern int RSIHP_HP_FiltPer_3 =7;          //RSI/HP: HP parameter: Equivalent to SMA period

// RSIHP: RSI input parameters

extern int RSIHP_RSI_Period_1 =10;          //RSI/HP: RSI parameter: period
extern int RSIHP_RSI_Period_2 =10;          //RSI/HP: RSI parameter: period
extern int RSIHP_RSI_Period_3 =10;          //RSI/HP: RSI parameter: period

//===== Money Flow Index (MFI) Indicator parameters =====

// MFI Entry Toggle (true: use for entry criteria, false: don't use for entry criteria)

extern bool MFI_Entry_1=true;
extern bool MFI_Entry_2=true;
extern bool MFI_Entry_3=true;

// MFI Exit Toggle (true: use for exit criteria, false: don't use for exit criteria)

extern bool MFI_Exit_1=true;

// MFI Limits (user defined limits for entry/exit criteria)

// Long Entry

extern double MFI_Long_Entry_Limit_1=55;
extern double MFI_Long_Entry_Limit_2=55;
extern double MFI_Long_Entry_Limit_3=55;

// Long Exit

extern double MFI_Long_Exit_Limit_1=45;

// Short Entry

extern double MFI_Short_Entry_Limit_1=45;
extern double MFI_Short_Entry_Limit_2=45;
extern double MFI_Short_Entry_Limit_3=45;

// Short Exit

extern double MFI_Short_Exit_Limit_1=55;

// MFI Input Parameters:

extern int MFI_Timeframe_1=PERIOD_M1;
extern int MFI_Timeframe_2=PERIOD_M5;
extern int MFI_Timeframe_3=PERIOD_M15;
extern int MFI_Period_1=14;
extern int MFI_Period_2=14;
extern int MFI_Period_3=14;

//===== Volume (VOL) Indicator parameters =====

// VOL Entry Toggle (true: use for entry criteria, false: don't use for entry criteria)

extern bool VOL_Entry_1=true;

// VOL Entry Limit

extern double VOL_Entry_Limit_1=100; // for both long and short: volume must be >= than this limit to enter order

// VOL timeframe

extern int VOL_Timeframe_1=PERIOD_M1;

//===== Fractal ZigZag (FZZ) Indicator parameters =====

// FZZ Entry Toggle (true: use for entry criteria, false: don't use for entry criteria)

extern bool FZZ_Entry_1=true;

// FZZ Exit Toggle (true: use for exit criteria, false: don't use for exit criteria)

extern bool FZZ_Exit_1=true;

// FZZ Limits (user defined limits for entry/exit criteria)

// Long Entry

extern double FZZ_Long_Entry_Limit_1=0;

// Long Exit

extern double FZZ_Long_Exit_Limit_1=0;

// Short Entry

extern double FZZ_Short_Entry_Limit_1=0;

// Short Exit

extern double FZZ_Short_Exit_Limit_1=0;

// FZZ input parameters 

extern int  FZZ_Timeframe_1=PERIOD_M1;
extern bool FZZ_CalculateOnBarClose_1 = true;
extern int  FZZ_ZZDepth_1             = 12;
extern int  FZZ_ZZDev_1               = 5;

//===== RSI Indicator parameters =====

// RSI Entry Toggles (true: use for entry criteria, false: don't use for entry criteria)

extern bool RSI_Entry_1=true;
extern bool RSI_Entry_2=true;
extern bool RSI_Entry_3=true;
extern bool RSI_Entry_4=true;
extern bool RSI_Entry_5=true;
extern bool RSI_Entry_6=true;
extern bool RSI_Entry_7=true;
extern bool RSI_Entry_8=true;

// RSI Exit Toggles (true: use for exit criteria, false: don't use for exit criteria)

extern bool RSI_Exit_1=true;
extern bool RSI_Exit_2=true;
extern bool RSI_Exit_3=true;
extern bool RSI_Exit_4=true;
extern bool RSI_Exit_5=true;
extern bool RSI_Exit_6=true;
extern bool RSI_Exit_7=true;
extern bool RSI_Exit_8=true;

// RSI Limits (user defined limits for entry/exit criteria)

// Long Entry

extern double RSI_Long_Entry_Limit_1=45;
extern double RSI_Long_Entry_Limit_2=45;
extern double RSI_Long_Entry_Limit_3=45;
extern double RSI_Long_Entry_Limit_4=45;
extern double RSI_Long_Entry_Limit_5=45;
extern double RSI_Long_Entry_Limit_6=45;
extern double RSI_Long_Entry_Limit_7=45;
extern double RSI_Long_Entry_Limit_8=45;

// Long Exit

extern double RSI_Long_Exit_Limit_1=55;
extern double RSI_Long_Exit_Limit_2=55;
extern double RSI_Long_Exit_Limit_3=55;
extern double RSI_Long_Exit_Limit_4=55;
extern double RSI_Long_Exit_Limit_5=55;
extern double RSI_Long_Exit_Limit_6=55;
extern double RSI_Long_Exit_Limit_7=55;
extern double RSI_Long_Exit_Limit_8=55;

// Short Entry

extern double RSI_Short_Entry_Limit_1=55;
extern double RSI_Short_Entry_Limit_2=55;
extern double RSI_Short_Entry_Limit_3=55;
extern double RSI_Short_Entry_Limit_4=55;
extern double RSI_Short_Entry_Limit_5=55;
extern double RSI_Short_Entry_Limit_6=55;
extern double RSI_Short_Entry_Limit_7=55;
extern double RSI_Short_Entry_Limit_8=55;

// Short Exit

extern double RSI_Short_Exit_Limit_1=45;
extern double RSI_Short_Exit_Limit_2=45;
extern double RSI_Short_Exit_Limit_3=45;
extern double RSI_Short_Exit_Limit_4=45;
extern double RSI_Short_Exit_Limit_5=45;
extern double RSI_Short_Exit_Limit_6=45;
extern double RSI_Short_Exit_Limit_7=45;
extern double RSI_Short_Exit_Limit_8=45;

// RSI timeframe in minutes (e.g. 1 for M1, 60 for H1, etc.) 

// Must be an available MT4 platform timeframe: 

// M1 (1), M5 (5), M15 (15), M30 (30), H1 (60), H4 (240), D1 (1440), W1 (10080), MN1 (43200)
// or use zero (0) for chart timeframe

extern int RSI_Timeframe_1=PERIOD_M1;
extern int RSI_Timeframe_2=PERIOD_M1;
extern int RSI_Timeframe_3=PERIOD_M1;
extern int RSI_Timeframe_4=PERIOD_M1;
extern int RSI_Timeframe_5=PERIOD_M5;
extern int RSI_Timeframe_6=PERIOD_M5;
extern int RSI_Timeframe_7=PERIOD_M5;
extern int RSI_Timeframe_8=PERIOD_M5;

// RSI period 

// Long Enter

extern int RSI_Period_Long_Enter_1=22;
extern int RSI_Period_Long_Enter_2=32;
extern int RSI_Period_Long_Enter_3=42;
extern int RSI_Period_Long_Enter_4=52;
extern int RSI_Period_Long_Enter_5=62;
extern int RSI_Period_Long_Enter_6=72;
extern int RSI_Period_Long_Enter_7=82;
extern int RSI_Period_Long_Enter_8=92;

// Long Exit

extern int RSI_Period_Long_Exit_1=92;
extern int RSI_Period_Long_Exit_2=82;
extern int RSI_Period_Long_Exit_3=72;
extern int RSI_Period_Long_Exit_4=62;
extern int RSI_Period_Long_Exit_5=52;
extern int RSI_Period_Long_Exit_6=42;
extern int RSI_Period_Long_Exit_7=32;
extern int RSI_Period_Long_Exit_8=22;

// Short Enter

extern int RSI_Period_Short_Enter_1=28;
extern int RSI_Period_Short_Enter_2=38;
extern int RSI_Period_Short_Enter_3=48;
extern int RSI_Period_Short_Enter_4=58;
extern int RSI_Period_Short_Enter_5=68;
extern int RSI_Period_Short_Enter_6=78;
extern int RSI_Period_Short_Enter_7=88;
extern int RSI_Period_Short_Enter_8=98;

// Short Exit

extern int RSI_Period_Short_Exit_1=98;
extern int RSI_Period_Short_Exit_2=88;
extern int RSI_Period_Short_Exit_3=78;
extern int RSI_Period_Short_Exit_4=68;
extern int RSI_Period_Short_Exit_5=58;
extern int RSI_Period_Short_Exit_6=48;
extern int RSI_Period_Short_Exit_7=38;
extern int RSI_Period_Short_Exit_8=28;

// RSI Applied Price 

extern int RSI_Applied_Price=0; // 0: Close, 1: Open, 2: High, 3: Low, 4: Median (H+L)/2, 5: Typical (H+L+C)/3

//===== Snake Indicator parameters =====

// Snake Entry Toggles (true: use for entry criteria, false: don't use for entry criteria)

// "L" is the long Snake parameter
// "S" is the short Snake parameter

extern bool Snake_Entry_1L=true;
extern bool Snake_Entry_1S=true;
extern bool Snake_Entry_2L=true;
extern bool Snake_Entry_2S=true;

// Snake Exit Toggles (true: use for exit criteria, false: don't use for exit criteria)

extern bool Snake_Exit_1L=true;
extern bool Snake_Exit_1S=true;
extern bool Snake_Exit_2L=true;
extern bool Snake_Exit_2S=true;

// Snake Limits (user defined limits for entry/exit criteria)

// Long Entry

extern double Snake_Long_Entry_Limit_1L=0;
extern double Snake_Long_Entry_Limit_1S=0;

extern double Snake_Long_Entry_Limit_2L=0;
extern double Snake_Long_Entry_Limit_2S=0;

// Long Exit

extern double Snake_Long_Exit_Limit_1L=0;
extern double Snake_Long_Exit_Limit_1S=0;

extern double Snake_Long_Exit_Limit_2L=0;
extern double Snake_Long_Exit_Limit_2S=0;

// Short Entry

extern double Snake_Short_Entry_Limit_1L=0;
extern double Snake_Short_Entry_Limit_1S=0;

extern double Snake_Short_Entry_Limit_2L=0;
extern double Snake_Short_Entry_Limit_2S=0;

// Short Exit

extern double Snake_Short_Exit_Limit_1L=0;
extern double Snake_Short_Exit_Limit_1S=0;

extern double Snake_Short_Exit_Limit_2L=0;
extern double Snake_Short_Exit_Limit_2S=0;

// Snake timeframe in minutes (e.g. 1 for M1, 60 for H1, etc.) 

// Must be an available MT4 platform timeframe: 

// M1 (1), M5 (5), M15 (15), M30 (30), H1 (60), H4 (240), D1 (1440), W1 (10080), MN1 (43200)
// or use zero (0) for chart timeframe

extern int Snake_Timeframe_1=PERIOD_M1;
extern int Snake_Timeframe_2=PERIOD_M5;

// Snake cPeriod

extern int Snake_cPeriod_1=24;
extern int Snake_cPeriod_2=24;

// Trailing Stop Parameters:

extern bool Trailing_Stop=true; // true: activate trailing stop, false: deactivate trailing stop
extern bool Trailing_Stop_MFI=true; // true: activate MFI trailing stop, false: deactivate MFI trailing stop
extern int TrailModifiedInSec=15; // seconds between each trail step
// Trail ATR parameters:
extern double TrailPercentageInATR=30.0; // percentage of ATR for trailing stop
extern double RapidTrailMovesATRPercentage=50.0; // percentage of TrailPercentageInATR for MFI trailing stop
extern int MinTrailATR=100; // minimum points from market for ATR-based trailing stop
extern int TrailATRTimeframe=PERIOD_H1; // timeframe of ATR for trailing stop
extern int TrailATRPeriod=20; // period of ATR for trailing stop
// Trail convergence parameters:
extern int StartTrailConvergence=100; // points profit after which to start converging trail
extern int FirstTrailMoveToProfit=50; // points profit to move SL beyond BE upon first reaching Converge_Start
extern double ConvergePercentage=10.0; // percentage to converge trail per step during convergence
extern int MinTrailConverge=100; // minimum points from market for convergence trailing stop

// Misc Parameters

extern int ExitMode=1;        // Exit Mode, 1=Complete Independence of Exit Units 1, 2, 3
                              //            2=Independence of Unit 1 and Units 23, Interdependence of Units 23
extern bool NewEntrySLCondition=true; // true: previous order's SL must be at least FirstTrailMoveToProfit before subsequent order entry, false: disable
extern bool AlertEntry=true;  // true: alert on order entry, false: don't alert on order entry
extern int RightSpace=100;    // number of spaces to shift data display on chart to the right
extern int Magic=111; // magic number identifier for EA controlled order set per pair

//---- Internal buffers
bool triggeredL,triggeredS;
string comment;
datetime ots,otl,lasttime,lasttrailtime;
double lotsmin,lotsmax;
double trailstopperc1,trailstopperc2;
double TrailMinPointsATR,minstopdistBrokerPoints;
double TrailConvergeStartPoints,trailConvergePerc,TrailConvergeInitPoints;
double minstopdist1,minstopdist2,minstopdistBroker,TrailMinPointsConverge;
int lotsprecision;
int Slippage=1;
string semaphorestring;
string teststring;
string sep;
int ra,rb,rc,rd,re;
int rf,rg,rh,ri;
int ca,cb,cc,cd;
int tri;
int orderTotN;
int entryN,exitN;
int exitNArray[];
int passArray[];
bool ArrayEE[][2];
int ArrayT[],ArrayP[][4];
int ArrayTTr[],ArrayPTr[];
double ArrayL[][4];
string ArrayPtitle1[4],ArrayPtitle2[4];
double DataValues[],DataValuesTr[];
double DataValuesRSI8Output[8][4];
string DataTitles[],DataTitlesTr[];
int maxToggle;
double ArrayRSIHP[];
int UnitTotal;
int UnitInterdepTotal;
int UnitInterdepCriteria;
int UnitTotalCriteria;
int VOL_Long_Entry_Limit_1, VOL_Short_Entry_Limit_1;

int FZZ_Period_1=0;
bool RSIHP_Exit_2=false;
bool RSIHP_Exit_3=false;
double RSIHP_Long_Exit_Limit_2=45;
double RSIHP_Long_Exit_Limit_3=45;
double RSIHP_Short_Exit_Limit_2=55;
double RSIHP_Short_Exit_Limit_3=55;
bool MFI_Exit_2=false;
bool MFI_Exit_3=false;
double MFI_Long_Exit_Limit_2=45;
double MFI_Long_Exit_Limit_3=45;
double MFI_Short_Exit_Limit_2=55;
double MFI_Short_Exit_Limit_3=55;
bool VOL_Exit_1=false;
double VOL_Long_Exit_Limit_1=45;
double VOL_Short_Exit_Limit_1=55;
double VOL_Period_1=0;

// (#MTF_SnakeForce.mq4 and SnakeForce.mq4 must present be in /experts/indicators/ directory)
string SnakeCustomIndicator="#MTF_SnakeForce"; 
// (HP_FRAC_A.mq4 must present be in /experts/indicators/ directory)
string HPCustomIndicator="HP_FRAC_A";
// (FractalZigZagNoRepaint.mq4 and ZigZag.mq4 must present be in /experts/indicators/ directory)
string FZZCustomIndicator="FractalZigZagNoRepaint";
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init() // initialize
{
//---- 
 semaphorestring="SEMAPHORE";
 teststring="TEST";

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

 comment=StringConcatenate("Shelvan EA ",timename); 
 if(IsTesting()) semaphorestring=StringConcatenate(semaphorestring,teststring); 
  
 Initialize();
 orderTotN=CheckNumberOrder();

 UpdateData();
 UpdateArrays();
 UpdateDataWindow();  
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit() // deinitialize
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
int start() // start 
{
//----
 MainEnter();
 ManageOrders();
 MainExit();
 
 UpdateData();
 UpdateDataWindow();  
  
 if(lasttime==iTime(NULL,0,0)) return(0);
 lasttime=iTime(NULL,0,0);

 UpdateArrays();
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert utility functions                                         |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void MainEnter() // main entry routine
{ 
 string td;
 int ticket;

 if(Entry(true))
 { 

  if(triggeredS) {
   if(ExitAllOrders(false)) return;
  }
  
  ticket=SendOrderLong(Symbol(),Lots,Slippage,0,0,comment,Magic);     
  
  otl=TimeCurrent();
  td=TimeToStr(otl,TIME_DATE|TIME_MINUTES);
  if(AlertEntry) Alert("Shelvan EA entered long: ",Symbol()," M",Period()," at",td);

  triggeredL=true;
  lasttrailtime=0;
 } 
 
 if(Entry(false))
 {

  if(triggeredL) {
   if(ExitAllOrders(true)) return;
  }
  
  ticket=SendOrderShort(Symbol(),Lots,Slippage,0,0,comment,Magic);   
  
  ots=TimeCurrent();
  td=TimeToStr(ots,TIME_DATE|TIME_MINUTES);
  if(AlertEntry) Alert("Shelvan EA entered short: ",Symbol()," M",Period()," at",td);

  triggeredS=true;
  lasttrailtime=0;
 } 

 return; 
}
//+------------------------------------------------------------------+
bool Entry(bool flag) // entry criteria check
{
 if(entryN==0) return(false);

 int m=0,nl=0,ns=2;
 if(flag)
 {
  if(triggeredL) 
  {
   if(CheckTriggeredCriteria(true)) return(false);
  }
  
  DataUpdate(nl,1);
  EECriteria(true,m,nl);
 }
 else
 {
  if(triggeredS)
  {
   if(CheckTriggeredCriteria(false)) return(false); 
  }

  DataUpdate(ns,1);  
  EECriteria(false,m,ns); 
 }

 return(EntryLogic());
}
//+------------------------------------------------------------------+
bool EntryLogic() // entry logic
{
 int passT=0;
 for(int i=0;i<UnitTotal;i++) passT+=passArray[i];

 if(passT==entryN) return(true);
 else              return(false);
}
//+------------------------------------------------------------------+
bool CheckTriggeredCriteria(bool flag) // criteria to check when existing orders open
{ 
 datetime entrytime;
 if(flag) entrytime=otl;
 else     entrytime=ots;
 
 datetime nowtime=TimeCurrent();
 int diff = nowtime-entrytime;
 if(diff<Next_Order_Seconds) return(true);

 int nOrders = CheckNumberOrder();
 
 if(nOrders>=Max_Orders) return(true);
 if(nOrders>0)
 {
  if(EntrySLCheck()) return(true);
 }
 
 return(false);
}
//+------------------------------------------------------------------+
bool EntrySLCheck()
{
 if(!NewEntrySLCondition) return(false);
 
 int trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderMagicNumber()!=Magic) continue;
  
  if(OrderType()==OP_BUY)
  {
   if(OrderStopLoss()<NormDigits(OrderOpenPrice()+TrailConvergeInitPoints)) return(true);
   else                                                                     return(false);
  }
  else if(OrderType()==OP_SELL)
  {
   if(OrderStopLoss()>NormDigits(OrderOpenPrice()-TrailConvergeInitPoints)) return(true);
   else                                                                     return(false);
  }
 }
 return(false);
}
//+------------------------------------------------------------------+
void MainExit() // main exit routine
{
 if(triggeredL)
 {
  if(Exit(true)) ExitAllOrders(true);
 }
 else if(triggeredS)
 {
  if(Exit(false)) ExitAllOrders(false);
 }
}
//+------------------------------------------------------------------+
bool Exit(bool flag) // check exit criteria
{
 if(exitN==0) return(false);
 
 int m=1,nl=1,ns=3;
 
 if(flag)
 {
  DataUpdate(nl,1);  
  EECriteria(false,m,nl);
 }
 else
 {
  DataUpdate(ns,1);  
  EECriteria(true,m,ns);
 }
 
 return(ExitLogic());
}
//+------------------------------------------------------------------+
bool ExitLogic() // exit logic
{
 int i,passT=0;

 switch(ExitMode)
 {
  case 1:
  
   for(i=0;i<UnitTotal;i++)
   {
    if(exitNArray[i]==0) continue;
    if(passArray[i]==exitNArray[i]) return(true);
   }
  
  break;
  
  case 2:
  
   if(exitNArray[0]!=0)
   {
    if(passArray[0]==exitNArray[0]) return(true);
   }
   
   if(UnitInterdepCriteria==0) return(false);
   
   for(i=1;i<UnitTotal;i++)
   {
    if(exitNArray[i]==0) continue;
    if(passArray[i]==exitNArray[i]) passT++; 
   }

   if(passT==UnitInterdepCriteria) return(true);

  break;

  default:

   for(i=0;i<UnitTotal;i++)
   {
    if(exitNArray[i]==0) continue;
    if(passArray[i]==exitNArray[i]) passT++; 
   }

   if(passT==UnitTotalCriteria) return(true);

  break;  

 } 
 return(false);
}
//+------------------------------------------------------------------+
void EECriteria(bool flag,int m, int n) // flag=true: + bias, flag=false: - bias
                                        // m = mode switch 0 or 1
                                        // n = limit mode 
{
 ArrayInitialize(passArray,0);
 
 if(flag)
 {
  EECoreLogic(0,3,rd%cd+1,m,n,ca%ra,ri%ca);
  EECoreLogic(3,11,rc%cc+1,m,n,1-cb%rb,ri%cb+1); 
  EECoreLogic(11,14,rd%ca+1,m,n,2-ca%ra,ri%ca);  
  EECoreLogic(14,15,ra%cd+1,m,n,3-ca%ra,ri%ca);  
  EECoreLogic(15,16,ra%cd+1,m,n,3-ca%ra,ri%ca+2);    
  EECoreLogic(16,re%rf+ri,rb%cb+2,m,n,4-cc%rc,ri%cc+2);
  EECoreLogic(17,rg%rh+ri,ra%ca+2,m,n,4-cd%rd,ri%cd);
 }
 else
 {
  EECoreLogic(0,3,cd%rd+1,m,n,ra%ca,ca%ri+1);
  EECoreLogic(3,11,cc%rc+1,m,n,1-rb%cb,cb%ri);   
  EECoreLogic(11,14,ca%re+1,m,n,2-ra%ca,ca%ri+1); 
  EECoreLogic(14,15,ca%re+1,m,n,3-ra%ca,ca%ri);   
  EECoreLogic(15,16,cd%ra+1,m,n,3-ca%ra,ri%ca+3);     
  EECoreLogic(16,rf%re+ri,cb%rb+2,m,n,4-rc%cc,cc%ri+1);
  EECoreLogic(17,rh%rg+ri,ca%ra+2,m,n,4-rd%cd,cd%ri+3);
 }
 return;
}
//+------------------------------------------------------------------+
void EECoreLogic(int istart, int iend, int iincr, int m, int n, int npass, int comp) // EE core logic
{
 for(int i=istart;i<iend;i+=iincr)
 {
  if(ArrayEE[i][m])
  {
   switch(comp)
   {
   
    case 0:
     if(DataValues[i]>=ArrayL[i][n]) passArray[npass]++;
    break;
   
    case 1:
     if(DataValues[i]<=ArrayL[i][n]) passArray[npass]++;
    break;
    
    case 2:
     if(DataValues[i]> ArrayL[i][n]) passArray[npass]++;
    break;
    
    case 3:
     if(DataValues[i]< ArrayL[i][n]) passArray[npass]++;
    break;
    
   }
  }
 }  
}
//+------------------------------------------------------------------+
void ManageOrders() // manage orders 
{ 
 orderTotN=0;
 int trade,trades=OrdersTotal(); 
 bool checkTrail=TrailTime();
 for(trade=trades-1;trade>=0;trade--)
 { 
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderMagicNumber()!=Magic) continue;
  if(checkTrail) Trail();
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
bool CloseOrderLong(int ticket, double lots, int slip, color cl=CLR_NONE) // close long
{
 bool status=false;
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
   status=false;
  }
  else 
  {
   status=true;
   break;
  }
 }
 ReleaseSemaphore();
 return(status);
} 
//+------------------------------------------------------------------+
bool CloseOrderShort(int ticket, double lots, int slip, color cl=CLR_NONE) // close short
{
 bool status=false;
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
   status=false;
  }
  else 
  {
   status=true;
   break;
  }
 }
 ReleaseSemaphore();
 return(status);
}
//+------------------------------------------------------------------+
void Trail()
{
 if(!Trailing_Stop) return;
 double trail=TrailingStopCalc();
 TrailingStop(trail);
 return;
}
//+------------------------------------------------------------------+
bool TrailTime()
{
 datetime nowtime=TimeCurrent();
 int diff = nowtime-lasttrailtime;
 if(diff<TrailModifiedInSec) return(false);
 lasttrailtime=nowtime;
 return(true);
}
//+------------------------------------------------------------------+
double TrailingStopCalc()
{
 double trail;

 if(CheckProfit()) trail=MathMax(TrailingStopConverge(),minstopdist2);
 else              trail=MathMax(trailstopperc1*DataValuesTr[tri-1],minstopdist1);
 
 if(TrailingStopMFI3()) trail=MathMin(trail,MathMax(trailstopperc2*trailstopperc1*DataValuesTr[tri-1],minstopdist1));

 return(trail);
}
//+------------------------------------------------------------------+
void TrailingStop(double TS) // trailing stop
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
 if(OrderType()==OP_SELL)
 {  
  stopcal=TrailShort(Ask,TS);
  ModifyCompShort(stopcal,stopcrnt);
 } 
 return(0);
}
//+------------------------------------------------------------------+
double TrailLong(double price,double trail) // trail long 
{
 return(NormDigits(price-trail)); 
}
//+------------------------------------------------------------------+
double TrailShort(double price,double trail) // trail short 
{
 return(NormDigits(price+trail)); 
}
//+------------------------------------------------------------------+
double TrailingStopConverge()
{
 double dist;
 if(OrderType()==OP_BUY) 
 {
  if(OrderStopLoss()<OrderOpenPrice()) dist=TrailConvergeStartPoints-TrailConvergeInitPoints;
  else                                 dist=trailConvergePerc*MathAbs(Bid-OrderStopLoss());
 }
 else if(OrderType()==OP_SELL) 
 {
  if(OrderStopLoss()>OrderOpenPrice()) dist=TrailConvergeStartPoints-TrailConvergeInitPoints;
  else                                 dist=trailConvergePerc*MathAbs(OrderStopLoss()-Ask);
 }
 return (dist);
}
//+------------------------------------------------------------------+
bool TrailingStopMFI3()
{
 if(!Trailing_Stop_MFI) return(false);
 if(OrderType()==OP_BUY)
 {
  if(MFI(MFI_Timeframe_3,MFI_Period_3)<MFI_Long_Entry_Limit_3) return(true);
 }
 else if(OrderType()==OP_SELL)
 {
  if(MFI(MFI_Timeframe_3,MFI_Period_3)>MFI_Short_Entry_Limit_3) return(true);
 }
 return (false);
}
//+------------------------------------------------------------------+
bool CheckProfit()
{
 double profit;

 double stopcrnt=OrderStopLoss();
 double profitpoint=TrailConvergeStartPoints;  
          
 if(OrderType()==OP_BUY) profit=NormDigits(Bid-OrderOpenPrice());   
 else if(OrderType()==OP_SELL) profit=NormDigits(OrderOpenPrice()-Ask);
   
 if(profit>=profitpoint) return(true);
 
 return(false);
}
//+------------------------------------------------------------------+
bool ModifyOrder(int ticket, double price, double sl, double tp, datetime exp, color cl=CLR_NONE) // modify order 
{ 
 bool flag;
 GetSemaphore();

 if(OrderModify(ticket,price,sl,tp,exp,cl)==false)
 {  
  Print("OrderModify failed, Error: ",GetLastError(), " Ticket Number: ", ticket);
  Print("Old price: ", OrderOpenPrice(), " Old S/L ", OrderStopLoss(), " Old T/P ", OrderTakeProfit(), " Ask/Bid ",Ask,", ",Bid);
  Print(" New Price: ", DoubleToStr(price,Digits), " New S/L ", DoubleToStr(sl,Digits), " New T/P ", DoubleToStr(tp,Digits), " New Expiration ", exp);
  flag=false;
 }
 else flag=true;
 ReleaseSemaphore();

 return(flag);
}
//+------------------------------------------------------------------+
bool ModifyCompLong(double stopcal, double stopcrnt) // modify compare longs
{
 bool flag;
 stopcal=NormDigits(stopcal);
 stopcrnt=NormDigits(stopcrnt);

 if (stopcal==stopcrnt) return;
 
 if(stopcal>stopcrnt)
 {
 
  if(stopcal>NormDigits(Bid-minstopdistBrokerPoints)) // check whether s/l is too close to market
   return;
                     
  flag=ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Blue); 
 }
 return(flag);
}
//+------------------------------------------------------------------+
bool ModifyCompShort(double stopcal, double stopcrnt) // modify compare shorts
{
 bool flag;
 stopcal=NormDigits(stopcal);
 stopcrnt=NormDigits(stopcrnt);

 if (stopcal==stopcrnt) return;
  
 if(stopcrnt==0)
 {

  if(stopcal<NormDigits(Ask+minstopdistBrokerPoints)) // check whether s/l is too close to market
   return; 
   
  flag=ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red);     
 }
 else if(stopcal<stopcrnt&&stopcal!=0)
 {

  if(stopcal<NormDigits(Ask+minstopdistBrokerPoints)) // check whether s/l is too close to market
   return; 
 
  flag=ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red); 
 }
 return(flag);
}
//+------------------------------------------------------------------+
bool GetSemaphore() // get semaphore
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
bool ReleaseSemaphore() // release semaphore
{
 GlobalVariableSet(semaphorestring,0);
 return(true);
}
//+------------------------------------------------------------------+
double NormDigits(double price) // normalize digits 
{
 return(NormalizeDouble(price,Digits));
}
//+------------------------------------------------------------------+
double NormPoints(int pips)
{
 return(NormDigits(pips*Point));
}
//+------------------------------------------------------------------+
double NormLots(double lots) // normalize lots
{
 if(lotsmin==0.50) // for PFG ECN
 {
  int lotmod=lots/lotsmin;
  lots=lotmod*lotsmin; // increments of 0.50 lots
 }

 return(MathMax(NormalizeDouble(lotsmin,lotsprecision),NormalizeDouble(lots,lotsprecision)));
}
//+------------------------------------------------------------------+
bool ExitOrder(bool flag_Long,bool flag_Short) // exit order 
{
 if(OrderType()==OP_BUY&&flag_Long)
  return(CloseOrderLong(OrderTicket(),OrderLots(),Slippage,Lime));
 else if(OrderType()==OP_SELL&&flag_Short)
  return(CloseOrderShort(OrderTicket(),OrderLots(),Slippage,Lime));
}
//+------------------------------------------------------------------+ 
bool ExitAllOrders(bool long) // exit all orders 
{
 int trade,trades=OrdersTotal(); 

 orderTotN=CheckNumberOrder();

 if(long)
 {
  for(trade=0;trade<trades;trade++)
  {
   OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
   if(OrderSymbol()!=Symbol()) continue;
   if(OrderMagicNumber()!=Magic) continue;
   if(ExitOrder(true,false))
   {
    orderTotN--;
    if(orderTotN>0)
    {
     trade--;
     trades--;
    }
    else
    {
     triggeredL=false;
     return(false);
    }
   }
  }
 }
 else
 {
  for(trade=0;trade<trades;trade++)
  {
   OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
   if(OrderSymbol()!=Symbol()) continue;
   if(OrderMagicNumber()!=Magic) continue;   
   if(ExitOrder(false,true))
   {
    orderTotN--;
    if(orderTotN>0)
    {
     trade--;
     trades--;
    }
    else  
    {
     triggeredS=false; 
     return(false);
    }
   }
  }
 } 
 
 return(true);
}
//+------------------------------------------------------------------+
void Initialize() // initialize variables
{
 if(StartTrailConvergence<0) StartTrailConvergence=0;
  
 if(FirstTrailMoveToProfit<0) FirstTrailMoveToProfit=0;
 else if(FirstTrailMoveToProfit>StartTrailConvergence) FirstTrailMoveToProfit=StartTrailConvergence;
 
 if(MinTrailATR<0) MinTrailATR=0;
 if(MinTrailConverge<0) MinTrailConverge=0;
  
 TrailMinPointsATR=NormPoints(MinTrailATR); 
 TrailMinPointsConverge=NormPoints(MinTrailConverge); 
 TrailConvergeStartPoints=NormPoints(StartTrailConvergence);
 TrailConvergeInitPoints=NormPoints(FirstTrailMoveToProfit);

 orderTotN=0;
 triggeredL=false;
 triggeredS=false;
 otl=0;ots=0;
 entryN=0;
 exitN=0;
 maxToggle=20;
 UnitTotal=5;
 UnitInterdepTotal=4; 
 UnitInterdepCriteria=0;
 UnitTotalCriteria=0;
 trailstopperc1=0.01*TrailPercentageInATR;
 trailstopperc2=0.01*RapidTrailMovesATRPercentage; 
 trailConvergePerc=1.0-(0.01*ConvergePercentage); 
 lasttrailtime=0;
 VOL_Long_Entry_Limit_1=VOL_Entry_Limit_1;
 VOL_Short_Entry_Limit_1=VOL_Entry_Limit_1;
 
 minstopdistBroker=MarketInfo(Symbol(),MODE_STOPLEVEL);
 minstopdistBrokerPoints=NormPoints(minstopdistBroker); 
 minstopdist1=MathMax(minstopdistBrokerPoints,TrailMinPointsATR);
 minstopdist2=MathMax(minstopdistBrokerPoints,TrailMinPointsConverge);

      if(ExitMode<1) ExitMode=1;
 else if(ExitMode>2) ExitMode=2;

 SizeArrays();
 InitArrays();
   
 string sp="";
 for(int i=0;i<RightSpace;i++) sp=StringConcatenate(sp," ");
 sep="";
 sep=StringConcatenate("\n",sp);
 

}
//+------------------------------------------------------------------+
void SizeArrays()
{
 ArrayResize(ArrayEE,maxToggle);
 ArrayResize(ArrayL,maxToggle);
 ArrayResize(ArrayT,maxToggle);
 ArrayResize(ArrayP,maxToggle); 
 ArrayResize(ArrayTTr,1);
 ArrayResize(ArrayPTr,1); 
 ArrayResize(DataValues,maxToggle);  
 ArrayResize(DataTitles,maxToggle);
 ArrayResize(DataValuesTr,1);  
 ArrayResize(DataTitlesTr,1);   
 ArrayResize(exitNArray,UnitTotal);
 ArrayResize(passArray,UnitTotal);  

 ArrayInitialize(ArrayEE,NULL);
 ArrayInitialize(ArrayL,NULL);
 ArrayInitialize(ArrayT,NULL); 
 ArrayInitialize(ArrayP,NULL); 
 ArrayInitialize(ArrayTTr,NULL); 
 ArrayInitialize(ArrayPTr,NULL);  
 ArrayInitialize(DataValues,NULL);  
 ArrayInitialize(DataValuesTr,NULL);  
 ArrayInitialize(DataValuesRSI8Output,NULL);
 ArrayInitialize(exitNArray,0);
 ArrayInitialize(passArray,0);  
}
//+------------------------------------------------------------------+
void InitArrays() // load master arrays 
{
 // Entry toggles
 ArrayEE[0][0]=RSIHP_Entry_1;  
 ArrayEE[1][0]=RSIHP_Entry_2; 
 ArrayEE[2][0]=RSIHP_Entry_3;   
 
 ArrayEE[3][0]=RSI_Entry_1;
 ArrayEE[4][0]=RSI_Entry_2;
 ArrayEE[5][0]=RSI_Entry_3;
 ArrayEE[6][0]=RSI_Entry_4;
 ArrayEE[7][0]=RSI_Entry_5;
 ArrayEE[8][0]=RSI_Entry_6;
 ArrayEE[9][0]=RSI_Entry_7;
 ArrayEE[10][0]=RSI_Entry_8;
 
 ArrayEE[11][0]=MFI_Entry_1;   
 ArrayEE[12][0]=MFI_Entry_2;
 ArrayEE[13][0]=MFI_Entry_3; 
 
 ArrayEE[14][0]=VOL_Entry_1;  
 
 ArrayEE[15][0]=FZZ_Entry_1;  
 
 ArrayEE[16][0]=Snake_Entry_1L;
 ArrayEE[17][0]=Snake_Entry_1S; 
 ArrayEE[18][0]=Snake_Entry_2L;
 ArrayEE[19][0]=Snake_Entry_2S;

 // Exit toggles
 ArrayEE[0][1]=RSIHP_Exit_1;  
 ArrayEE[1][1]=RSIHP_Exit_2;
 ArrayEE[2][1]=RSIHP_Exit_3;  
 
 ArrayEE[3][1]=RSI_Exit_1;
 ArrayEE[4][1]=RSI_Exit_2;
 ArrayEE[5][1]=RSI_Exit_3;
 ArrayEE[6][1]=RSI_Exit_4;
 ArrayEE[7][1]=RSI_Exit_5;
 ArrayEE[8][1]=RSI_Exit_6;
 ArrayEE[9][1]=RSI_Exit_7;
 ArrayEE[10][1]=RSI_Exit_8;
 
 ArrayEE[11][1]=MFI_Exit_1;  
 ArrayEE[12][1]=MFI_Exit_2;
 ArrayEE[13][1]=MFI_Exit_3;   

 ArrayEE[14][1]=VOL_Exit_1; 
 
 ArrayEE[15][1]=FZZ_Exit_1;  
 
 ArrayEE[16][1]=Snake_Exit_1L;
 ArrayEE[17][1]=Snake_Exit_1S; 
 ArrayEE[18][1]=Snake_Exit_2L;
 ArrayEE[19][1]=Snake_Exit_2S;
 
 // Timeframe values
 ArrayT[0]=RSIHP_HP_Timeframe_1; 
 ArrayT[1]=RSIHP_HP_Timeframe_2;
 ArrayT[2]=RSIHP_HP_Timeframe_3;  
   
 ArrayT[3]=RSI_Timeframe_1;
 ArrayT[4]=RSI_Timeframe_2;
 ArrayT[5]=RSI_Timeframe_3;
 ArrayT[6]=RSI_Timeframe_4;
 ArrayT[7]=RSI_Timeframe_5;
 ArrayT[8]=RSI_Timeframe_6;
 ArrayT[9]=RSI_Timeframe_7;
 ArrayT[10]=RSI_Timeframe_8;

 ArrayT[11]=MFI_Timeframe_1;  
 ArrayT[12]=MFI_Timeframe_2;
 ArrayT[13]=MFI_Timeframe_3;    

 ArrayT[14]=VOL_Timeframe_1; 

 ArrayT[15]=FZZ_Timeframe_1;  

 ArrayT[16]=Snake_Timeframe_1;
 ArrayT[17]=Snake_Timeframe_1;
 ArrayT[18]=Snake_Timeframe_2;
 ArrayT[19]=Snake_Timeframe_2;

 // Period values
 
 // RSIHP:
 ArrayP[0][0]=RSIHP_RSI_Period_1;
 ArrayP[1][0]=RSIHP_RSI_Period_2;
 ArrayP[2][0]=RSIHP_RSI_Period_3;  
 
 ArrayP[0][1]=RSIHP_HP_nobs_1;
 ArrayP[1][1]=RSIHP_HP_nobs_2;
 ArrayP[2][1]=RSIHP_HP_nobs_3;  

 ArrayP[0][2]=RSIHP_HP_FiltPer_1;
 ArrayP[1][2]=RSIHP_HP_FiltPer_2;
 ArrayP[2][2]=RSIHP_HP_FiltPer_3;  
 
 // RSI: 
 ArrayP[3][0]=RSI_Period_Long_Enter_1;
 ArrayP[4][0]=RSI_Period_Long_Enter_2;
 ArrayP[5][0]=RSI_Period_Long_Enter_3;
 ArrayP[6][0]=RSI_Period_Long_Enter_4;
 ArrayP[7][0]=RSI_Period_Long_Enter_5;
 ArrayP[8][0]=RSI_Period_Long_Enter_6;
 ArrayP[9][0]=RSI_Period_Long_Enter_7;
 ArrayP[10][0]=RSI_Period_Long_Enter_8;

 ArrayP[3][1]=RSI_Period_Long_Exit_1;
 ArrayP[4][1]=RSI_Period_Long_Exit_2;
 ArrayP[5][1]=RSI_Period_Long_Exit_3;
 ArrayP[6][1]=RSI_Period_Long_Exit_4;
 ArrayP[7][1]=RSI_Period_Long_Exit_5;
 ArrayP[8][1]=RSI_Period_Long_Exit_6;
 ArrayP[9][1]=RSI_Period_Long_Exit_7;
 ArrayP[10][1]=RSI_Period_Long_Exit_8;

 ArrayP[3][2]=RSI_Period_Short_Enter_1;
 ArrayP[4][2]=RSI_Period_Short_Enter_2;
 ArrayP[5][2]=RSI_Period_Short_Enter_3;
 ArrayP[6][2]=RSI_Period_Short_Enter_4;
 ArrayP[7][2]=RSI_Period_Short_Enter_5;
 ArrayP[8][2]=RSI_Period_Short_Enter_6;
 ArrayP[9][2]=RSI_Period_Short_Enter_7;
 ArrayP[10][2]=RSI_Period_Short_Enter_8;

 ArrayP[3][3]=RSI_Period_Short_Exit_1;
 ArrayP[4][3]=RSI_Period_Short_Exit_2;
 ArrayP[5][3]=RSI_Period_Short_Exit_3;
 ArrayP[6][3]=RSI_Period_Short_Exit_4;
 ArrayP[7][3]=RSI_Period_Short_Exit_5;
 ArrayP[8][3]=RSI_Period_Short_Exit_6;
 ArrayP[9][3]=RSI_Period_Short_Exit_7;
 ArrayP[10][3]=RSI_Period_Short_Exit_8;    

 ArrayP[11][0]=MFI_Period_1;
 ArrayP[12][0]=MFI_Period_2; 
 ArrayP[13][0]=MFI_Period_3;  

 ArrayP[14][0]=VOL_Period_1;
 
 ArrayP[15][0]=FZZ_Period_1; 

 ArrayP[16][0]=Snake_cPeriod_1;
 ArrayP[17][0]=Snake_cPeriod_1;
 ArrayP[18][0]=Snake_cPeriod_2;
 ArrayP[19][0]=Snake_cPeriod_2;
 
 // Trail Timeframe value
 ArrayTTr[0]=TrailATRTimeframe;
 
 // Trail Period value
 ArrayPTr[0]=TrailATRPeriod;
 
 // Limit values
 ArrayL[0][0]=RSIHP_Long_Entry_Limit_1;
 ArrayL[1][0]=RSIHP_Long_Entry_Limit_2;
 ArrayL[2][0]=RSIHP_Long_Entry_Limit_3;
   
 ArrayL[3][0]=RSI_Long_Entry_Limit_1;
 ArrayL[4][0]=RSI_Long_Entry_Limit_2;
 ArrayL[5][0]=RSI_Long_Entry_Limit_3;
 ArrayL[6][0]=RSI_Long_Entry_Limit_4;
 ArrayL[7][0]=RSI_Long_Entry_Limit_5;
 ArrayL[8][0]=RSI_Long_Entry_Limit_6;
 ArrayL[9][0]=RSI_Long_Entry_Limit_7;
 ArrayL[10][0]=RSI_Long_Entry_Limit_8;   

 ArrayL[11][0]=MFI_Long_Entry_Limit_1; 
 ArrayL[12][0]=MFI_Long_Entry_Limit_2;  
 ArrayL[13][0]=MFI_Long_Entry_Limit_3; 
 
 ArrayL[14][0]=VOL_Long_Entry_Limit_1;  

 ArrayL[15][0]=FZZ_Long_Entry_Limit_1;  

 ArrayL[16][0]=Snake_Long_Entry_Limit_1L;
 ArrayL[17][0]=Snake_Long_Entry_Limit_1S;
 ArrayL[18][0]=Snake_Long_Entry_Limit_2L;
 ArrayL[19][0]=Snake_Long_Entry_Limit_2S;

//
 
 ArrayL[0][1]=RSIHP_Long_Exit_Limit_1;  
 ArrayL[1][1]=RSIHP_Long_Exit_Limit_2;
 ArrayL[2][1]=RSIHP_Long_Exit_Limit_3;

 ArrayL[3][1]=RSI_Long_Exit_Limit_1;
 ArrayL[4][1]=RSI_Long_Exit_Limit_2;
 ArrayL[5][1]=RSI_Long_Exit_Limit_3;
 ArrayL[6][1]=RSI_Long_Exit_Limit_4;
 ArrayL[7][1]=RSI_Long_Exit_Limit_5;
 ArrayL[8][1]=RSI_Long_Exit_Limit_6;
 ArrayL[9][1]=RSI_Long_Exit_Limit_7;
 ArrayL[10][1]=RSI_Long_Exit_Limit_8;  

 ArrayL[11][1]=MFI_Long_Exit_Limit_1; 
 ArrayL[12][1]=MFI_Long_Exit_Limit_2;  
 ArrayL[13][1]=MFI_Long_Exit_Limit_3; 

 ArrayL[14][1]=VOL_Long_Exit_Limit_1; 

 ArrayL[15][1]=FZZ_Long_Exit_Limit_1;  

 ArrayL[16][1]=Snake_Long_Exit_Limit_1L;
 ArrayL[17][1]=Snake_Long_Exit_Limit_1S;
 ArrayL[18][1]=Snake_Long_Exit_Limit_2L;
 ArrayL[19][1]=Snake_Long_Exit_Limit_2S;

//
 
 ArrayL[0][2]=RSIHP_Short_Entry_Limit_1; 
 ArrayL[1][2]=RSIHP_Short_Entry_Limit_2; 
 ArrayL[2][2]=RSIHP_Short_Entry_Limit_3;  
 
 ArrayL[3][2]=RSI_Short_Entry_Limit_1;
 ArrayL[4][2]=RSI_Short_Entry_Limit_2;
 ArrayL[5][2]=RSI_Short_Entry_Limit_3;
 ArrayL[6][2]=RSI_Short_Entry_Limit_4;
 ArrayL[7][2]=RSI_Short_Entry_Limit_5;
 ArrayL[8][2]=RSI_Short_Entry_Limit_6;
 ArrayL[9][2]=RSI_Short_Entry_Limit_7;
 ArrayL[10][2]=RSI_Short_Entry_Limit_8;  

 ArrayL[11][2]=MFI_Short_Entry_Limit_1;  
 ArrayL[12][2]=MFI_Short_Entry_Limit_2;
 ArrayL[13][2]=MFI_Short_Entry_Limit_3; 

 ArrayL[14][2]=VOL_Short_Entry_Limit_1;  

 ArrayL[15][2]=FZZ_Short_Entry_Limit_1;   
 
 ArrayL[16][2]=Snake_Short_Entry_Limit_1L;
 ArrayL[17][2]=Snake_Short_Entry_Limit_1S;
 ArrayL[18][2]=Snake_Short_Entry_Limit_2L;
 ArrayL[19][2]=Snake_Short_Entry_Limit_2S;

//
 
 ArrayL[0][3]=RSIHP_Short_Exit_Limit_1;  
 ArrayL[1][3]=RSIHP_Short_Exit_Limit_2; 
 ArrayL[2][3]=RSIHP_Short_Exit_Limit_3; 
   
 ArrayL[3][3]=RSI_Short_Exit_Limit_1;
 ArrayL[4][3]=RSI_Short_Exit_Limit_2;
 ArrayL[5][3]=RSI_Short_Exit_Limit_3;
 ArrayL[6][3]=RSI_Short_Exit_Limit_4;
 ArrayL[7][3]=RSI_Short_Exit_Limit_5;
 ArrayL[8][3]=RSI_Short_Exit_Limit_6;
 ArrayL[9][3]=RSI_Short_Exit_Limit_7;
 ArrayL[10][3]=RSI_Short_Exit_Limit_8;  

 ArrayL[11][3]=MFI_Short_Exit_Limit_1;  
 ArrayL[12][3]=MFI_Short_Exit_Limit_2; 
 ArrayL[13][3]=MFI_Short_Exit_Limit_3; 

 ArrayL[14][3]=VOL_Short_Exit_Limit_1;  

 ArrayL[15][3]=FZZ_Short_Exit_Limit_1;  

 ArrayL[16][3]=Snake_Short_Exit_Limit_1L;
 ArrayL[17][3]=Snake_Short_Exit_Limit_1S;
 ArrayL[18][3]=Snake_Short_Exit_Limit_2L;
 ArrayL[19][3]=Snake_Short_Exit_Limit_2S;

 // Period titles:
 ArrayPtitle1[0]=" LPi: ";
 ArrayPtitle1[1]=" LPo: ";
 ArrayPtitle1[2]=" SPi: ";
 ArrayPtitle1[3]=" SPo: ";
 ArrayPtitle2[0]=" Li: ";
 ArrayPtitle2[1]=" Lo: ";
 ArrayPtitle2[2]=" Si: ";
 ArrayPtitle2[3]=" So: ";

 int i,eN; 

 // Number of entry/exit toggles
 for(i=0;i<maxToggle;i++)
 {
  if(ArrayEE[i][0]) entryN++;
  
       if(i>14) eN=UnitTotal-1;
  else if(i>13) eN=UnitTotal-2;
  else if(i>10) eN=UnitTotal-3;  
  else if(i>2)  eN=UnitTotal-4;
  else          eN=UnitTotal-5;
  
  if(ArrayEE[i][1]) 
  {
   exitNArray[eN]++;
   exitN++;
  }
 }

 for(i=0;i<UnitTotal;i++)
 {
  if(exitNArray[i]>0) UnitTotalCriteria++;
 }
 
 for(i=1;i<UnitTotal;i++)
 {
  if(exitNArray[i]>0) UnitInterdepCriteria++;
 }

 for(ra=0;ra<maxToggle;ra++){if(ArrayT[ra]!=EMPTY_VALUE)continue;break;} 
 for(rb=0;rb<maxToggle;rb++){if(ArrayP[rb][0]!=EMPTY_VALUE)continue;break;}
 for(rc=0;rc<maxToggle;rc++){if(ArrayEE[rc][0]!=EMPTY_VALUE)continue;break;} 
 for(rd=0;rd<maxToggle;rd++){if(ArrayEE[rd][1]!=EMPTY_VALUE)continue;break;}  
 for(re=0;re<maxToggle;re++){if(ArrayL[re][0]!=EMPTY_VALUE)continue;break;}
 for(rf=0;rf<maxToggle;rf++){if(ArrayL[rf][1]!=EMPTY_VALUE)continue;break;}
 for(rg=0;rg<maxToggle;rg++){if(ArrayL[rg][2]!=EMPTY_VALUE)continue;break;}
 for(rh=0;rh<maxToggle;rh++){if(ArrayL[rh][3]!=EMPTY_VALUE)continue;break;}

 ca=MathAbs(-24*(UnitTotal%UnitInterdepTotal)+UnitInterdepTotal);
 cb=MathAbs(3*((UnitTotal+UnitInterdepTotal)%UnitTotal)+UnitInterdepTotal+4);
 cc=MathAbs(2*(UnitInterdepTotal%UnitTotal)+UnitInterdepTotal+8);
 cd=MathAbs(-5*(UnitTotal%(UnitTotal-UnitInterdepTotal)+UnitTotal)+5*(UnitTotal-UnitInterdepTotal));

 // Comment titles
 
 for(i=0;i<3;i++) 
 {
  DataTitles[i]=StringConcatenate("RSI/HP(",DoubleToStr(ArrayT[i],0),",",DoubleToStr(ArrayP[i][0],0),")");
 }
 
 for(i=3;i<11;i++) 
 {
  DataTitles[i]=StringConcatenate("RSI(",DoubleToStr(ArrayT[i],0),",",ArrayPtitle1[0],DoubleToStr(ArrayP[i][0],0)," /",ArrayPtitle1[1],DoubleToStr(ArrayP[i][1],0)," /",ArrayPtitle1[2],DoubleToStr(ArrayP[i][2],0)," /",ArrayPtitle1[3],DoubleToStr(ArrayP[i][3],0),")");
 }

 for(i=11;i<14;i++) 
 {
  DataTitles[i]=StringConcatenate("MFI(",DoubleToStr(ArrayT[i],0),",",DoubleToStr(ArrayP[i][0],0),")");
 }

 i=14;
 DataTitles[i]=StringConcatenate("Volume(",DoubleToStr(ArrayT[i],0),")");
 
 i=15;
 DataTitles[i]=StringConcatenate("FZZ(",DoubleToStr(ArrayT[i],0),",",DoubleToStr(FZZ_ZZDepth_1,0),",",DoubleToStr(FZZ_ZZDev_1,0),")");
 
 int j=1;
 for(i=16;i<maxToggle;i=i+2) 
 {
  DataTitles[i]=StringConcatenate("Snake",DoubleToStr(j,0),",L(",DoubleToStr(ArrayT[i],0),",",DoubleToStr(ArrayP[i][0],0),")");
  j++;
 }
 
 j=1;
 for(i=17;i<maxToggle;i=i+2) 
 {
  DataTitles[i]=StringConcatenate("Snake",DoubleToStr(j,0),",S(",DoubleToStr(ArrayT[i],0),",",DoubleToStr(ArrayP[i][0],0),")");
  j++;
 }  

 DataTitlesTr[0]=StringConcatenate("ATR(",DoubleToStr(ArrayTTr[0],0),",",DoubleToStr(ArrayPTr[0],0),")");

}
//+------------------------------------------------------------------+
int CheckNumberOrder() // check number of orders in account
{
 int trade,trades=OrdersTotal(),total=0; 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderMagicNumber()!=Magic) continue;
  
  if(OrderType()==OP_BUY)       
  {
   if(OrderOpenTime()>otl) otl=OrderOpenTime();
   triggeredL=true;
  }
  else if(OrderType()==OP_SELL) 
  {
   if(OrderOpenTime()>ots) ots=OrderOpenTime();
   triggeredS=true;
  }
  
  total++;
 }
 return(total);
}
//+------------------------------------------------------------------+
double VOL(int timeframe)
{
 return(iVolume(NULL,timeframe,0));
}
//+------------------------------------------------------------------+
double ATR(int timeframe, int period) // ATR indicator value
{
 return(iATR(NULL,timeframe,period,0));
}
//+------------------------------------------------------------------+
double MFI(int timeframe, int period) // MFI indicator value
{
 return(iMFI(NULL,timeframe,period,0));
}
//+------------------------------------------------------------------+
double FZZ(int timeframe, int period, bool calc, int depth, int dev) // Fractal ZigZag value
{
 int bars=iBars(NULL,timeframe);
 for(int i=0;i<bars;i++)
 {
  if(iCustom(NULL,timeframe,FZZCustomIndicator,calc,depth,dev,0,i)!=EMPTY_VALUE)
   return(1);
  else if(iCustom(NULL,timeframe,FZZCustomIndicator,calc,depth,dev,1,i)!=EMPTY_VALUE)
   return(-1);
 }
 return(0);
}
//+------------------------------------------------------------------+
double RSI(int timeframe, int period) // RSI indicator value
{
 return(iRSI(NULL,timeframe,period,RSI_Applied_Price,0));
}
//+------------------------------------------------------------------+
double Snake(int timeframe, int cPeriod, int mode) // Snake indicator value
{
 return(iCustom(NULL,timeframe,SnakeCustomIndicator,timeframe,cPeriod,mode,0));
}
//+------------------------------------------------------------------+
double RSIHP(int timeframe, int periodRSI, int nobsHP, int filtperHP) // RSI/HP indicator value
{
 int i,j,b=iBars(NULL,timeframe);
 int bmo=b-1;
 int mode=0;
 int index=0;
 ArrayResize(ArrayRSIHP,b);
 //ArrayInitialize(ArrayRSIHP,0);
 for(i=0;i<b;i++)
 {
  j=bmo-i;
  ArrayRSIHP[j]=iCustom(NULL,timeframe,HPCustomIndicator,nobsHP,filtperHP,mode,i);
 }
 return(iRSIOnArray(ArrayRSIHP,b,periodRSI,index));
}
//+------------------------------------------------------------------+
void UpdateData()
{
 DataUpdate(0,0);
 for(int i=0;i<4;i++) DataUpdate(i,2);
}
//+------------------------------------------------------------------+
void DataUpdate(int m, int flag) // update data
{
 int i;
 switch (flag)
 {
  case 0:
   for(i=0;i<3;i++)            DataValues[i]=RSIHP(ArrayT[i],ArrayP[i][0],ArrayP[i][1],ArrayP[i][2]);
   for(i=11;i<14;i++)          DataValues[i]=MFI(ArrayT[i],ArrayP[i][0]);
   i=14;                       DataValues[i]=VOL(ArrayT[i]);
   i=15;                       DataValues[i]=FZZ(ArrayT[i],ArrayP[i][0],FZZ_CalculateOnBarClose_1,FZZ_ZZDepth_1,FZZ_ZZDev_1);   
   for(i=16;i<maxToggle;i=i+2) DataValues[i]=Snake(ArrayT[i],ArrayP[i][0],0);
   for(i=17;i<maxToggle;i=i+2) DataValues[i]=Snake(ArrayT[i],ArrayP[i][0],1);
 
                               DataValuesTr[0]=ATR(ArrayTTr[0],ArrayPTr[0]);
  break;
  case 1:
   for(i=3;i<11;i++)           DataValues[i]=RSI(ArrayT[i],ArrayP[i][m]);
  break;
  case 2:
  default:
   for(i=3;i<11;i++)           DataValuesRSI8Output[i-3][m]=RSI(ArrayT[i],ArrayP[i][m]);
  break;
 }
 return;
}
//+------------------------------------------------------------------+
void UpdateArrays() // update arrays
{
 for(ri=0;ri<maxToggle;ri++){if(DataValues[ri]!=EMPTY_VALUE)continue;break;}
 for(tri=0;tri<1;tri++){if(DataValuesTr[tri]!=EMPTY_VALUE)continue;break;} 
 return;
}
//+------------------------------------------------------------------+
void UpdateDataWindow() // update data window 
{
 int i;string info=sep;

 for(i=0;i<3;i++)
 {
  info = DataWindowString(info,DataTitles[i],DataValues[i],0);
 }
 info=StringConcatenate(info,sep);
 
 for(i=11;i<14;i++)
 {
  info = DataWindowString(info,DataTitles[i],DataValues[i],0); 
 }
 info=StringConcatenate(info,sep);
 
 for(i=3;i<11;i++)
 {
  info = DataWindowString(info,DataTitles[i]+" "+ArrayPtitle2[0],DataValuesRSI8Output[i-3][0],2);
  info = DataWindowString(info,ArrayPtitle2[1],DataValuesRSI8Output[i-3][1],3);
  info = DataWindowString(info,ArrayPtitle2[2],DataValuesRSI8Output[i-3][2],3);
  info = DataWindowString(info,ArrayPtitle2[3],DataValuesRSI8Output[i-3][3],3);
  info=StringConcatenate(info,sep);
 }
 
 info=StringConcatenate(info,sep);
 
 for(i=16;i<maxToggle;i++)
 {
  info = DataWindowString(info,DataTitles[i],DataValues[i],0);
 }  

 info=StringConcatenate(info,sep);
 
 info = DataWindowString(info,DataTitlesTr[0],DataValuesTr[0],0);

 info=StringConcatenate(info,sep);

 for(i=14;i<16;i++)
 {
  info = DataWindowString(info,DataTitles[i],DataValues[i],1); 
  info=StringConcatenate(info,sep);
 }
  
 Comment(info);
 return;
}
//+------------------------------------------------------------------+
string DataWindowString(string s, string dt, double dv, int flag)
{
 switch (flag)
 {
  case 0:
   return(StringConcatenate(s,dt," ",DoubleToStr(dv,Digits),sep));
  break;  
  case 1:
   return(StringConcatenate(s,dt," ",DoubleToStr(dv,0),sep));
  break;   
  case 2:
   return(StringConcatenate(s,dt,DoubleToStr(dv,0)));
  break;
  case 3:
  default:
   return(StringConcatenate(s," /",dt,DoubleToStr(dv,0)));  
  break;
 }
}
//+------------------------------------------------------------------+
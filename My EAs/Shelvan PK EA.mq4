//+----------------------------------------------------------------------+
//|                                                    Shelvan PK EA.mq4 |
//|                                                         David J. Lin |
//| Shelvan PK EA                                                        |
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
//| July 21-28, 2012: v2.00: Major change to PK version of EA            |
//| July 30, 2012: v2.01: make Magic parameter user specified            |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2012, Pannirshelvan Kannuthurai & David J. Lin"

// External user adjustable parameters:

//===== Order parameters =====

extern double Lots=0.10; // lot size per order 
extern int Max_Orders=9; // maximum number of simultaneous orders per direction
extern int Next_Order_Seconds=1; // seconds after first entry to consider possible next entry in the same direction

//===== HP-A Indicator parameters =====

// HP-A Entry Toggle (true: use for entry criteria, false: don't use for entry criteria)

extern bool HPA_Entry_1=true;
extern bool HPA_Entry_2=true;
extern bool HPA_Entry_3=true;
extern bool HPA_Entry_4=true;
extern bool HPA_Entry_5=true;
extern bool HPA_Entry_6=true;
extern bool HPA_Entry_7=true;

// HP-A Limits (user defined limits for entry criteria)

// Long Entry

extern double HPA_Long_Entry_Limit_1=1;
extern double HPA_Long_Entry_Limit_2=1;
extern double HPA_Long_Entry_Limit_3=1;
extern double HPA_Long_Entry_Limit_4=1;
extern double HPA_Long_Entry_Limit_5=1;
extern double HPA_Long_Entry_Limit_6=1;
extern double HPA_Long_Entry_Limit_7=1;

// Short Entry

extern double HPA_Short_Entry_Limit_1=1;
extern double HPA_Short_Entry_Limit_2=1;
extern double HPA_Short_Entry_Limit_3=1;
extern double HPA_Short_Entry_Limit_4=1;
extern double HPA_Short_Entry_Limit_5=1;
extern double HPA_Short_Entry_Limit_6=1;
extern double HPA_Short_Entry_Limit_7=1;

// HP-A input parameters

// Timeframe:
extern int HPA_Timeframe_1=PERIOD_M1;
extern int HPA_Timeframe_2=PERIOD_M5;
extern int HPA_Timeframe_3=PERIOD_M15; 
extern int HPA_Timeframe_4=PERIOD_M30;
extern int HPA_Timeframe_5=PERIOD_H1;
extern int HPA_Timeframe_6=PERIOD_H4; 
extern int HPA_Timeframe_7=PERIOD_D1;

// nobs:
extern int HPA_nobs_1=100000; 
extern int HPA_nobs_2=100000; 
extern int HPA_nobs_3=100000;
extern int HPA_nobs_4=100000;
extern int HPA_nobs_5=100000;
extern int HPA_nobs_6=100000;
extern int HPA_nobs_7=100000;

// FiltPer:
extern int HPA_FiltPer_1=7;
extern int HPA_FiltPer_2=7;
extern int HPA_FiltPer_3=7;
extern int HPA_FiltPer_4=7;
extern int HPA_FiltPer_5=7;
extern int HPA_FiltPer_6=7;
extern int HPA_FiltPer_7=7;

//===== HP-RSI (RSI of HP-A) Indicator parameters =====

// HP-RSI Entry Toggle (true: use for entry criteria, false: don't use for entry criteria)

extern bool HPRSI_Entry_1=true;
extern bool HPRSI_Entry_2=true;
extern bool HPRSI_Entry_3=true;
extern bool HPRSI_Entry_4=true;
extern bool HPRSI_Entry_5=true;
extern bool HPRSI_Entry_6=true;
extern bool HPRSI_Entry_7=true;

// HP-RSI Limits (user defined limits for entry criteria)

// Long Entry

extern double HPRSI_Long_Entry_Limit_1=55;
extern double HPRSI_Long_Entry_Limit_2=55;
extern double HPRSI_Long_Entry_Limit_3=55;
extern double HPRSI_Long_Entry_Limit_4=55;
extern double HPRSI_Long_Entry_Limit_5=55;
extern double HPRSI_Long_Entry_Limit_6=55;
extern double HPRSI_Long_Entry_Limit_7=55;

// Short Entry

extern double HPRSI_Short_Entry_Limit_1=45;
extern double HPRSI_Short_Entry_Limit_2=45;
extern double HPRSI_Short_Entry_Limit_3=45;
extern double HPRSI_Short_Entry_Limit_4=45;
extern double HPRSI_Short_Entry_Limit_5=45;
extern double HPRSI_Short_Entry_Limit_6=45;
extern double HPRSI_Short_Entry_Limit_7=45;

// RSIHP: RSI input parameters

extern int HPRSI_Period_1=10;
extern int HPRSI_Period_2=10;
extern int HPRSI_Period_3=10;
extern int HPRSI_Period_4=10;
extern int HPRSI_Period_5=10;
extern int HPRSI_Period_6=10;
extern int HPRSI_Period_7=10;

//===== HP-B Indicator parameters =====

// HP-B Entry Toggle (true: use for entry criteria, false: don't use for entry criteria)

extern bool HPB_Entry_1=true;
extern bool HPB_Entry_2=true;
extern bool HPB_Entry_3=true;
extern bool HPB_Entry_4=true;
extern bool HPB_Entry_5=true;
extern bool HPB_Entry_6=true;
extern bool HPB_Entry_7=true;

// HP-B Limits (user defined limits for entry criteria)

// Long Entry

extern double HPB_Long_Entry_Limit_1=1;
extern double HPB_Long_Entry_Limit_2=1;
extern double HPB_Long_Entry_Limit_3=1;
extern double HPB_Long_Entry_Limit_4=1;
extern double HPB_Long_Entry_Limit_5=1;
extern double HPB_Long_Entry_Limit_6=1;
extern double HPB_Long_Entry_Limit_7=1;

// Short Entry

extern double HPB_Short_Entry_Limit_1=1;
extern double HPB_Short_Entry_Limit_2=1;
extern double HPB_Short_Entry_Limit_3=1;
extern double HPB_Short_Entry_Limit_4=1;
extern double HPB_Short_Entry_Limit_5=1;
extern double HPB_Short_Entry_Limit_6=1;
extern double HPB_Short_Entry_Limit_7=1;

// HP-B input parameters

// Timeframe:
extern int HPB_Timeframe_1=PERIOD_M1;
extern int HPB_Timeframe_2=PERIOD_M5;
extern int HPB_Timeframe_3=PERIOD_M15;
extern int HPB_Timeframe_4=PERIOD_M30;
extern int HPB_Timeframe_5=PERIOD_H1;
extern int HPB_Timeframe_6=PERIOD_H4;
extern int HPB_Timeframe_7=PERIOD_D1;

// nobs:
extern int HPB_nobs_1=100000;
extern int HPB_nobs_2=100000;
extern int HPB_nobs_3=100000;
extern int HPB_nobs_4=100000; 
extern int HPB_nobs_5=100000;
extern int HPB_nobs_6=100000;
extern int HPB_nobs_7=100000;

// FiltPer:
extern int HPB_FiltPer_1=7; 
extern int HPB_FiltPer_2=7;
extern int HPB_FiltPer_3=7;
extern int HPB_FiltPer_4=7;
extern int HPB_FiltPer_5=7;
extern int HPB_FiltPer_6=7;
extern int HPB_FiltPer_7=7;

//===== Momentum (Momentum of HP-B) Indicator parameters =====

// Momentum Entry Toggle (true: use for entry criteria, false: don't use for entry criteria)

extern bool MOM_Entry_1=true;
extern bool MOM_Entry_2=true;
extern bool MOM_Entry_3=true;
extern bool MOM_Entry_4=true;
extern bool MOM_Entry_5=true;
extern bool MOM_Entry_6=true;
extern bool MOM_Entry_7=true;

// Long Entry

extern double MOM_Long_Entry_Limit_1=97;
extern double MOM_Long_Entry_Limit_2=97;
extern double MOM_Long_Entry_Limit_3=97;
extern double MOM_Long_Entry_Limit_4=97;
extern double MOM_Long_Entry_Limit_5=97;
extern double MOM_Long_Entry_Limit_6=97;
extern double MOM_Long_Entry_Limit_7=97;

// Short Entry

extern double MOM_Short_Entry_Limit_1=93;
extern double MOM_Short_Entry_Limit_2=93;
extern double MOM_Short_Entry_Limit_3=93;
extern double MOM_Short_Entry_Limit_4=93;
extern double MOM_Short_Entry_Limit_5=93;
extern double MOM_Short_Entry_Limit_6=93;
extern double MOM_Short_Entry_Limit_7=93;

// Momentum input parameters

// Momentum period 

extern int MOM_Period_1=10;
extern int MOM_Period_2=10;
extern int MOM_Period_3=10;
extern int MOM_Period_4=10;
extern int MOM_Period_5=10;
extern int MOM_Period_6=10;
extern int MOM_Period_7=10;

//===== RSI (RSI of Momentum of HP-B) Indicator parameters =====

// RSI Entry Toggle (true: use for entry criteria, false: don't use for entry criteria)

extern bool RSI_Entry_1=true;
extern bool RSI_Entry_2=true;
extern bool RSI_Entry_3=true;
extern bool RSI_Entry_4=true;
extern bool RSI_Entry_5=true;
extern bool RSI_Entry_6=true;
extern bool RSI_Entry_7=true;

// RSI Limits (user defined limits for entry criteria)

// Long Entry

extern double RSI_Long_Entry_Limit_1=55;
extern double RSI_Long_Entry_Limit_2=55;
extern double RSI_Long_Entry_Limit_3=55;
extern double RSI_Long_Entry_Limit_4=55;
extern double RSI_Long_Entry_Limit_5=55;
extern double RSI_Long_Entry_Limit_6=55;
extern double RSI_Long_Entry_Limit_7=55;

// Short Entry

extern double RSI_Short_Entry_Limit_1=45;
extern double RSI_Short_Entry_Limit_2=45;
extern double RSI_Short_Entry_Limit_3=45;
extern double RSI_Short_Entry_Limit_4=45;
extern double RSI_Short_Entry_Limit_5=45;
extern double RSI_Short_Entry_Limit_6=45;
extern double RSI_Short_Entry_Limit_7=45;

// RSIHP: RSI input parameters

extern int RSI_Period_1=10;
extern int RSI_Period_2=10;
extern int RSI_Period_3=10;
extern int RSI_Period_4=10;
extern int RSI_Period_5=10;
extern int RSI_Period_6=10;
extern int RSI_Period_7=10;

//===== Money Flow Index (MFI) Indicator parameters =====

// MFI Entry Toggle (true: use for entry criteria, false: don't use for entry criteria)

extern bool MFI_Entry_1=true;
extern bool MFI_Entry_2=true;
extern bool MFI_Entry_3=true;

// MFI Limits (user defined limits for entry criteria)

// Long Entry

extern double MFI_Long_Entry_Limit_1=55;
extern double MFI_Long_Entry_Limit_2=55;
extern double MFI_Long_Entry_Limit_3=55;

// Short Entry

extern double MFI_Short_Entry_Limit_1=45;
extern double MFI_Short_Entry_Limit_2=45;
extern double MFI_Short_Entry_Limit_3=45;

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

//===== Snake Indicator parameters =====

// Snake Entry Toggles (true: use for entry criteria, false: don't use for entry criteria)

// "L" is the long Snake parameter
// "S" is the short Snake parameter

extern bool Snake_Entry_1L=true;
extern bool Snake_Entry_1S=true;
extern bool Snake_Entry_2L=true;
extern bool Snake_Entry_2S=true;

// Snake Limits (user defined limits for entry criteria)

// Long Entry

extern double Snake_Long_Entry_Limit_1L=0;
extern double Snake_Long_Entry_Limit_1S=0;

extern double Snake_Long_Entry_Limit_2L=0;
extern double Snake_Long_Entry_Limit_2S=0;

// Short Entry

extern double Snake_Short_Entry_Limit_1L=0;
extern double Snake_Short_Entry_Limit_1S=0;

extern double Snake_Short_Entry_Limit_2L=0;
extern double Snake_Short_Entry_Limit_2S=0;

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
int entryN;
int passArray[];
bool ArrayEE[][1];
int ArrayT[],ArrayP[][2];
int ArrayTTr[],ArrayPTr[];
double ArrayL[][2];
double DataValues[],DataValuesTr[];
string DataTitles[];
int maxToggle;
double ArrayMOM1[],ArrayMOM2[],ArrayMOM3[],ArrayMOM4[],ArrayMOM5[],ArrayMOM6[],ArrayMOM7[];
double ArrayMOM1R[],ArrayMOM2R[],ArrayMOM3R[],ArrayMOM4R[],ArrayMOM5R[],ArrayMOM6R[],ArrayMOM7R[];
double ArrayHPA1[],ArrayHPA2[],ArrayHPA3[],ArrayHPA4[],ArrayHPA5[],ArrayHPA6[],ArrayHPA7[];
double ArrayHPB1[],ArrayHPB2[],ArrayHPB3[],ArrayHPB4[],ArrayHPB5[],ArrayHPB6[],ArrayHPB7[];
int UnitTotal;
int UnitInterdepTotal;
int VOL_Long_Entry_Limit_1, VOL_Short_Entry_Limit_1;

double VOL_Period_1=0;

// (#MTF_SnakeForce.mq4 and SnakeForce.mq4 must present be in /experts/indicators/ directory)
string SnakeCustomIndicator="#MTF_SnakeForce"; 
// (HP_FRAC_A.mq4 must present be in /experts/indicators/ directory)
string HPCustomIndicator="HP_FRAC_A";
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
  case 1:     timename="M1";
  break;
  case 5:     timename="M5";
  break;
  case 15:    timename="M15";
  break;  
  case 30:    timename="M30";
  break;  
  case 60:    timename="H1";
  break;
  case 240:   timename="H4";
  break;  
  case 1440:  timename="D1";
  break;  
  case 10080: timename="W1";
  break;  
  default:    timename="MN";
  break;  
 }

 comment=StringConcatenate("Shelvan PK EA ",timename); 
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
  if(AlertEntry) Alert("Shelvan PK EA entered long: ",Symbol()," M",Period()," at",td);

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
  if(AlertEntry) Alert("Shelvan PK EA entered short: ",Symbol()," M",Period()," at",td);

  triggeredS=true;
  lasttrailtime=0;
 } 

 return; 
}
//+------------------------------------------------------------------+
bool Entry(bool flag) // entry criteria check
{
 if(entryN==0) return(false);

 int m=0,nl=0,ns=1;
 if(flag)
 {
  if(triggeredL) 
  {
   if(CheckTriggeredCriteria(true)) return(false);
  }
  
  EECriteria(true,m,nl);
 }
 else
 {
  if(triggeredS)
  {
   if(CheckTriggeredCriteria(false)) return(false); 
  }
 
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
void EECriteria(bool flag,int m, int n) // flag=true: + bias, flag=false: - bias
                                        // m = mode switch 0 or 1
                                        // n = limit mode 
{
 ArrayInitialize(passArray,0);
 
 if(flag)
 {
  EECoreLogic(0,35,rd%cd+1,m,n,ca%ra,ri%ca);
  EECoreLogic(35,38,rd%ca+1,m,n,ca%ra,ri%ca);  
  EECoreLogic(38,39,ra%cd+1,m,n,ca%ra,ri%ca);     
  EECoreLogic(39,re%rf+ri,rb%cb+2,m,n,cc%rc,ri%cc+2);
  EECoreLogic(40,rg%rh+ri,ra%ca+2,m,n,cd%rd,ri%cd);
 }
 else
 {
  EECoreLogic(0,35,cd%rd+1,m,n,ra%ca,ca%ri+1); 
  EECoreLogic(35,38,ca%re+1,m,n,ra%ca,ca%ri+1); 
  EECoreLogic(38,39,ca%re+1,m,n,ra%ca,ca%ri);
  EECoreLogic(39,rf%re+ri,cb%rb+2,m,n,rc%cc,cc%ri+1);
  EECoreLogic(40,rh%rg+ri,ca%ra+2,m,n,rd%cd,cd%ri+3);
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
 return;
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
 return(dist);
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
 return(false);
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
 maxToggle=43;
 UnitTotal=1;
 UnitInterdepTotal=2; 
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

 SizeArrays();
 InitArrays();
   
 string sp="";
 for(int i=0;i<RightSpace;i++) sp=StringConcatenate(sp," ");
 sep="";
 sep=StringConcatenate("\n",sp);
 
 return;
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
 ArrayResize(passArray,UnitTotal);  

 ArrayInitialize(ArrayEE,NULL);
 ArrayInitialize(ArrayL,NULL);
 ArrayInitialize(ArrayT,NULL); 
 ArrayInitialize(ArrayP,NULL); 
 ArrayInitialize(ArrayTTr,NULL); 
 ArrayInitialize(ArrayPTr,NULL);  
 ArrayInitialize(DataValues,NULL);  
 ArrayInitialize(DataValuesTr,NULL);
 ArrayInitialize(passArray,0);

 return;
}
//+------------------------------------------------------------------+
void InitArrays() // load master arrays 
{
 // Entry toggles
 ArrayEE[0][0]=HPA_Entry_1;  
 ArrayEE[1][0]=HPA_Entry_2; 
 ArrayEE[2][0]=HPA_Entry_3;
 ArrayEE[3][0]=HPA_Entry_4;
 ArrayEE[4][0]=HPA_Entry_5;
 ArrayEE[5][0]=HPA_Entry_6;
 ArrayEE[6][0]=HPA_Entry_7;    

 ArrayEE[7][0] =HPB_Entry_1;  
 ArrayEE[8][0] =HPB_Entry_2; 
 ArrayEE[9][0] =HPB_Entry_3;
 ArrayEE[10][0]=HPB_Entry_4;
 ArrayEE[11][0]=HPB_Entry_5;
 ArrayEE[12][0]=HPB_Entry_6;
 ArrayEE[13][0]=HPB_Entry_7;

 ArrayEE[14][0]=HPRSI_Entry_1;  
 ArrayEE[15][0]=HPRSI_Entry_2; 
 ArrayEE[16][0]=HPRSI_Entry_3;
 ArrayEE[17][0]=HPRSI_Entry_4;
 ArrayEE[18][0]=HPRSI_Entry_5;
 ArrayEE[19][0]=HPRSI_Entry_6;
 ArrayEE[20][0]=HPRSI_Entry_7;

 ArrayEE[21][0]=MOM_Entry_1;  
 ArrayEE[22][0]=MOM_Entry_2; 
 ArrayEE[23][0]=MOM_Entry_3;
 ArrayEE[24][0]=MOM_Entry_4;
 ArrayEE[25][0]=MOM_Entry_5;
 ArrayEE[26][0]=MOM_Entry_6;
 ArrayEE[27][0]=MOM_Entry_7; 

 ArrayEE[28][0]=RSI_Entry_1;  
 ArrayEE[29][0]=RSI_Entry_2; 
 ArrayEE[30][0]=RSI_Entry_3;
 ArrayEE[31][0]=RSI_Entry_4;
 ArrayEE[32][0]=RSI_Entry_5;
 ArrayEE[33][0]=RSI_Entry_6;
 ArrayEE[34][0]=RSI_Entry_7; 
 
 ArrayEE[35][0]=MFI_Entry_1;   
 ArrayEE[36][0]=MFI_Entry_2;
 ArrayEE[37][0]=MFI_Entry_3; 
 
 ArrayEE[38][0]=VOL_Entry_1;  
 
 ArrayEE[39][0]=Snake_Entry_1L;
 ArrayEE[40][0]=Snake_Entry_1S; 
 ArrayEE[41][0]=Snake_Entry_2L;
 ArrayEE[42][0]=Snake_Entry_2S;
 
 // Timeframe values
 ArrayT[0]=HPA_Timeframe_1;  
 ArrayT[1]=HPA_Timeframe_2; 
 ArrayT[2]=HPA_Timeframe_3;
 ArrayT[3]=HPA_Timeframe_4;
 ArrayT[4]=HPA_Timeframe_5;
 ArrayT[5]=HPA_Timeframe_6;
 ArrayT[6]=HPA_Timeframe_7;    

 ArrayT[7] =HPB_Timeframe_1;  
 ArrayT[8] =HPB_Timeframe_2; 
 ArrayT[9] =HPB_Timeframe_3;
 ArrayT[10]=HPB_Timeframe_4;
 ArrayT[11]=HPB_Timeframe_5;
 ArrayT[12]=HPB_Timeframe_6;
 ArrayT[13]=HPB_Timeframe_7;

 ArrayT[14]=HPA_Timeframe_1;  
 ArrayT[15]=HPA_Timeframe_2; 
 ArrayT[16]=HPA_Timeframe_3;
 ArrayT[17]=HPA_Timeframe_4;
 ArrayT[18]=HPA_Timeframe_5;
 ArrayT[19]=HPA_Timeframe_6;
 ArrayT[20]=HPA_Timeframe_7;

 ArrayT[21]=HPB_Timeframe_1;  
 ArrayT[22]=HPB_Timeframe_2; 
 ArrayT[23]=HPB_Timeframe_3;
 ArrayT[24]=HPB_Timeframe_4;
 ArrayT[25]=HPB_Timeframe_5;
 ArrayT[26]=HPB_Timeframe_6;
 ArrayT[27]=HPB_Timeframe_7; 

 ArrayT[28]=HPB_Timeframe_1;  
 ArrayT[29]=HPB_Timeframe_2;
 ArrayT[30]=HPB_Timeframe_3;
 ArrayT[31]=HPB_Timeframe_4;
 ArrayT[32]=HPB_Timeframe_5;
 ArrayT[33]=HPB_Timeframe_6;
 ArrayT[34]=HPB_Timeframe_7;
 
 ArrayT[35]=MFI_Timeframe_1;   
 ArrayT[36]=MFI_Timeframe_2;
 ArrayT[37]=MFI_Timeframe_3;    

 ArrayT[38]=VOL_Timeframe_1;   

 ArrayT[39]=Snake_Timeframe_1;
 ArrayT[40]=Snake_Timeframe_1;
 ArrayT[41]=Snake_Timeframe_2;
 ArrayT[42]=Snake_Timeframe_2;

 // Period values
 
 // HPA
 ArrayP[0][0]=HPA_nobs_1;
 ArrayP[1][0]=HPA_nobs_2;
 ArrayP[2][0]=HPA_nobs_3;
 ArrayP[3][0]=HPA_nobs_4;
 ArrayP[4][0]=HPA_nobs_5;
 ArrayP[5][0]=HPA_nobs_6;
 ArrayP[6][0]=HPA_nobs_7;    

 ArrayP[0][1]=HPA_FiltPer_1;
 ArrayP[1][1]=HPA_FiltPer_2;
 ArrayP[2][1]=HPA_FiltPer_3;
 ArrayP[3][1]=HPA_FiltPer_4; 
 ArrayP[4][1]=HPA_FiltPer_5; 
 ArrayP[5][1]=HPA_FiltPer_6; 
 ArrayP[6][1]=HPA_FiltPer_7;      

 // HPB
 ArrayP[7][0] =HPB_nobs_1;
 ArrayP[8][0] =HPB_nobs_2;
 ArrayP[9][0] =HPB_nobs_3;
 ArrayP[10][0]=HPB_nobs_4;
 ArrayP[11][0]=HPB_nobs_5;
 ArrayP[12][0]=HPB_nobs_6;
 ArrayP[13][0]=HPB_nobs_7;    

 ArrayP[7][1] =HPB_FiltPer_1;
 ArrayP[8][1] =HPB_FiltPer_2;
 ArrayP[9][1] =HPB_FiltPer_3;
 ArrayP[10][1]=HPB_FiltPer_4; 
 ArrayP[11][1]=HPB_FiltPer_5; 
 ArrayP[12][1]=HPB_FiltPer_6; 
 ArrayP[13][1]=HPB_FiltPer_7;

 // HPRSI
 ArrayP[14][0]=HPRSI_Period_1;
 ArrayP[15][0]=HPRSI_Period_2;
 ArrayP[16][0]=HPRSI_Period_3;
 ArrayP[17][0]=HPRSI_Period_4; 
 ArrayP[18][0]=HPRSI_Period_5; 
 ArrayP[19][0]=HPRSI_Period_6; 
 ArrayP[20][0]=HPRSI_Period_7;

 // MOM
 ArrayP[21][0]=MOM_Period_1;
 ArrayP[22][0]=MOM_Period_2;
 ArrayP[23][0]=MOM_Period_3;
 ArrayP[24][0]=MOM_Period_4; 
 ArrayP[25][0]=MOM_Period_5; 
 ArrayP[26][0]=MOM_Period_6; 
 ArrayP[27][0]=MOM_Period_7; 

 // RSI
 ArrayP[28][0]=RSI_Period_1;
 ArrayP[29][0]=RSI_Period_2;
 ArrayP[30][0]=RSI_Period_3;
 ArrayP[31][0]=RSI_Period_4; 
 ArrayP[32][0]=RSI_Period_5; 
 ArrayP[33][0]=RSI_Period_6; 
 ArrayP[34][0]=RSI_Period_7;  
 
 // MFI
 ArrayP[35][0]=MFI_Period_1;
 ArrayP[36][0]=MFI_Period_2; 
 ArrayP[37][0]=MFI_Period_3;  

 // VOL
 ArrayP[38][0]=VOL_Period_1; 

 // Snake
 ArrayP[39][0]=Snake_cPeriod_1;
 ArrayP[40][0]=Snake_cPeriod_1;
 ArrayP[41][0]=Snake_cPeriod_2;
 ArrayP[42][0]=Snake_cPeriod_2;
 
 // Trail Timeframe value
 ArrayTTr[0]=TrailATRTimeframe;
 
 // Trail Period value
 ArrayPTr[0]=TrailATRPeriod;
 
 // Limit values
 // Long
 ArrayL[0][0]=HPA_Long_Entry_Limit_1;
 ArrayL[1][0]=HPA_Long_Entry_Limit_2;
 ArrayL[2][0]=HPA_Long_Entry_Limit_3;
 ArrayL[3][0]=HPA_Long_Entry_Limit_4;
 ArrayL[4][0]=HPA_Long_Entry_Limit_5;
 ArrayL[5][0]=HPA_Long_Entry_Limit_6;
 ArrayL[6][0]=HPA_Long_Entry_Limit_7;    

 ArrayL[7][0] =HPB_Long_Entry_Limit_1;
 ArrayL[8][0] =HPB_Long_Entry_Limit_2;
 ArrayL[9][0] =HPB_Long_Entry_Limit_3;
 ArrayL[10][0]=HPB_Long_Entry_Limit_4;
 ArrayL[11][0]=HPB_Long_Entry_Limit_5;
 ArrayL[12][0]=HPB_Long_Entry_Limit_6;
 ArrayL[13][0]=HPB_Long_Entry_Limit_7;

 ArrayL[14][0]=HPRSI_Long_Entry_Limit_1;
 ArrayL[15][0]=HPRSI_Long_Entry_Limit_2;
 ArrayL[16][0]=HPRSI_Long_Entry_Limit_3;
 ArrayL[17][0]=HPRSI_Long_Entry_Limit_4;
 ArrayL[18][0]=HPRSI_Long_Entry_Limit_5;
 ArrayL[19][0]=HPRSI_Long_Entry_Limit_6;
 ArrayL[20][0]=HPRSI_Long_Entry_Limit_7;

 ArrayL[21][0]=MOM_Long_Entry_Limit_1;
 ArrayL[22][0]=MOM_Long_Entry_Limit_2;
 ArrayL[23][0]=MOM_Long_Entry_Limit_3;
 ArrayL[24][0]=MOM_Long_Entry_Limit_4;
 ArrayL[25][0]=MOM_Long_Entry_Limit_5;
 ArrayL[26][0]=MOM_Long_Entry_Limit_6;
 ArrayL[27][0]=MOM_Long_Entry_Limit_7;

 ArrayL[28][0]=RSI_Long_Entry_Limit_1;
 ArrayL[29][0]=RSI_Long_Entry_Limit_2;
 ArrayL[30][0]=RSI_Long_Entry_Limit_3;
 ArrayL[31][0]=RSI_Long_Entry_Limit_4;
 ArrayL[32][0]=RSI_Long_Entry_Limit_5;
 ArrayL[33][0]=RSI_Long_Entry_Limit_6;
 ArrayL[34][0]=RSI_Long_Entry_Limit_7;

 ArrayL[35][0]=MFI_Long_Entry_Limit_1; 
 ArrayL[36][0]=MFI_Long_Entry_Limit_2;  
 ArrayL[37][0]=MFI_Long_Entry_Limit_3; 
 
 ArrayL[38][0]=VOL_Long_Entry_Limit_1;    

 ArrayL[39][0]=Snake_Long_Entry_Limit_1L;
 ArrayL[40][0]=Snake_Long_Entry_Limit_1S;
 ArrayL[41][0]=Snake_Long_Entry_Limit_2L;
 ArrayL[42][0]=Snake_Long_Entry_Limit_2S;

// Short
 ArrayL[0][1]=HPA_Short_Entry_Limit_1;
 ArrayL[1][1]=HPA_Short_Entry_Limit_2;
 ArrayL[2][1]=HPA_Short_Entry_Limit_3;
 ArrayL[3][1]=HPA_Short_Entry_Limit_4;
 ArrayL[4][1]=HPA_Short_Entry_Limit_5;
 ArrayL[5][1]=HPA_Short_Entry_Limit_6;
 ArrayL[6][1]=HPA_Short_Entry_Limit_7;    

 ArrayL[7][1] =HPB_Short_Entry_Limit_1;
 ArrayL[8][1] =HPB_Short_Entry_Limit_2;
 ArrayL[9][1] =HPB_Short_Entry_Limit_3;
 ArrayL[10][1]=HPB_Short_Entry_Limit_4;
 ArrayL[11][1]=HPB_Short_Entry_Limit_5;
 ArrayL[12][1]=HPB_Short_Entry_Limit_6;
 ArrayL[13][1]=HPB_Short_Entry_Limit_7;

 ArrayL[14][1]=HPRSI_Short_Entry_Limit_1;
 ArrayL[15][1]=HPRSI_Short_Entry_Limit_2;
 ArrayL[16][1]=HPRSI_Short_Entry_Limit_3;
 ArrayL[17][1]=HPRSI_Short_Entry_Limit_4;
 ArrayL[18][1]=HPRSI_Short_Entry_Limit_5;
 ArrayL[19][1]=HPRSI_Short_Entry_Limit_6;
 ArrayL[20][1]=HPRSI_Short_Entry_Limit_7;

 ArrayL[21][1]=MOM_Short_Entry_Limit_1;
 ArrayL[22][1]=MOM_Short_Entry_Limit_2;
 ArrayL[23][1]=MOM_Short_Entry_Limit_3;
 ArrayL[24][1]=MOM_Short_Entry_Limit_4;
 ArrayL[25][1]=MOM_Short_Entry_Limit_5;
 ArrayL[26][1]=MOM_Short_Entry_Limit_6;
 ArrayL[27][1]=MOM_Short_Entry_Limit_7;

 ArrayL[28][1]=RSI_Short_Entry_Limit_1;
 ArrayL[29][1]=RSI_Short_Entry_Limit_2;
 ArrayL[30][1]=RSI_Short_Entry_Limit_3;
 ArrayL[31][1]=RSI_Short_Entry_Limit_4;
 ArrayL[32][1]=RSI_Short_Entry_Limit_5;
 ArrayL[33][1]=RSI_Short_Entry_Limit_6;
 ArrayL[34][1]=RSI_Short_Entry_Limit_7;

 ArrayL[35][1]=MFI_Short_Entry_Limit_1; 
 ArrayL[36][1]=MFI_Short_Entry_Limit_2;  
 ArrayL[37][1]=MFI_Short_Entry_Limit_3; 
 
 ArrayL[38][1]=VOL_Short_Entry_Limit_1;    

 ArrayL[39][1]=Snake_Short_Entry_Limit_1L;
 ArrayL[40][1]=Snake_Short_Entry_Limit_1S;
 ArrayL[41][1]=Snake_Short_Entry_Limit_2L;
 ArrayL[42][1]=Snake_Short_Entry_Limit_2S;

 int i; 

 // Number of entry toggles
 for(i=0;i<maxToggle;i++)
 {
  if(ArrayEE[i][0]) entryN++;
 }

 for(ra=0;ra<maxToggle;ra++){if(ArrayT[ra]!=EMPTY_VALUE)continue;break;} 
 for(rb=0;rb<maxToggle;rb++){if(ArrayP[rb][0]!=EMPTY_VALUE)continue;break;}
 for(rc=0;rc<maxToggle;rc++){if(ArrayEE[rc][0]!=EMPTY_VALUE)continue;break;} 
 for(rd=0;rd<maxToggle;rd++){if(ArrayEE[rd][1]!=EMPTY_VALUE)continue;break;}  
 for(re=0;re<maxToggle;re++){if(ArrayL[re][0]!=EMPTY_VALUE)continue;break;}
 for(rf=0;rf<maxToggle;rf++){if(ArrayL[rf][1]!=EMPTY_VALUE)continue;break;}
 for(rg=0;rg<maxToggle;rg++){if(ArrayL[rg][0]!=EMPTY_VALUE)continue;break;}
 for(rh=0;rh<maxToggle;rh++){if(ArrayL[rh][1]!=EMPTY_VALUE)continue;break;}

 ca=MathAbs(-24*(UnitTotal%UnitInterdepTotal)-19*UnitTotal);
 cb=MathAbs(3*((UnitTotal+UnitInterdepTotal)%UnitInterdepTotal)+18*UnitInterdepTotal+4);
 cc=MathAbs(2*(UnitInterdepTotal%UnitTotal)+10*UnitInterdepTotal+23);
 cd=MathAbs(-15*(UnitTotal%(UnitTotal*UnitInterdepTotal)+UnitTotal)+13*(UnitTotal-UnitInterdepTotal));

 // Comment titles
 
 for(i=0;i<7;i++) 
 {
  DataTitles[i]=StringConcatenate("HP-A-",(i+1)%8,"(",DoubleToStr(ArrayT[i],0),",",DoubleToStr(ArrayP[i][0],0),",",DoubleToStr(ArrayP[i][1],0),")");
 }

 for(i=7;i<14;i++) 
 {
  DataTitles[i]=StringConcatenate("HP-B-",(i+2)%8,"(",DoubleToStr(ArrayT[i],0),",",DoubleToStr(ArrayP[i][0],0),",",DoubleToStr(ArrayP[i][1],0),")");
 }

 for(i=14;i<21;i++) 
 {
  DataTitles[i]=StringConcatenate("HP-RSI-",(i+3)%8,"(",DoubleToStr(ArrayP[i][0],0),")");
 }

 for(i=21;i<28;i++) 
 {
  DataTitles[i]=StringConcatenate("MOM-",(i+4)%8,"(",DoubleToStr(ArrayP[i][0],0),")");
 }

 for(i=28;i<35;i++) 
 {
  DataTitles[i]=StringConcatenate("RSI-",(i+5)%8,"(",DoubleToStr(ArrayP[i][0],0),")");
 }

 for(i=35;i<38;i++) 
 {
  DataTitles[i]=StringConcatenate("MFI-",i%34,"(",DoubleToStr(ArrayT[i],0),",",DoubleToStr(ArrayP[i][0],0),")");
 }

 i=38;
 DataTitles[i]=StringConcatenate("Volume(",DoubleToStr(ArrayT[i],0),")");
  
 int j=1;
 for(i=39;i<maxToggle;i=i+2) 
 {
  DataTitles[i]=StringConcatenate("Snake",DoubleToStr(j,0),",L(",DoubleToStr(ArrayT[i],0),",",DoubleToStr(ArrayP[i][0],0),")");
  j++;
 }
 
 j=1;
 for(i=40;i<maxToggle;i=i+2) 
 {
  DataTitles[i]=StringConcatenate("Snake",DoubleToStr(j,0),",S(",DoubleToStr(ArrayT[i],0),",",DoubleToStr(ArrayP[i][0],0),")");
  j++;
 }
 
 return;
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
double Snake(int timeframe, int cPeriod, int mode) // Snake indicator value
{
 return(iCustom(NULL,timeframe,SnakeCustomIndicator,timeframe,cPeriod,mode,0));
}
//+------------------------------------------------------------------+
double HP(int timeframe, int nobsHP, int filtperHP, int i)
{
 return(iCustom(NULL,timeframe,HPCustomIndicator,nobsHP,filtperHP,0,i));
}
//+------------------------------------------------------------------+
void HPAB() // HP-A, HP-B indicator values
{
 HPFill(ArrayHPA1,0);
 HPFill(ArrayHPA2,1);
 HPFill(ArrayHPA3,2);
 HPFill(ArrayHPA4,3);
 HPFill(ArrayHPA5,4);
 HPFill(ArrayHPA6,5);
 HPFill(ArrayHPA7,6);
 HPFill(ArrayHPB1,7);
 HPFill(ArrayHPB2,8);
 HPFill(ArrayHPB3,9);
 HPFill(ArrayHPB4,10);
 HPFill(ArrayHPB5,11);
 HPFill(ArrayHPB6,12);
 HPFill(ArrayHPB7,13);
 return;     
}
//+------------------------------------------------------------------+
void HPFill(double& array[], int m) // fill HP values
{
 int i,j,b,bmo;
 b=iBars(NULL,ArrayT[m]);
 bmo=b-1;
 ArrayResize(array,b);  
 for(i=0;i<b;i++) 
 {
  j=bmo-i; 
  array[j]=HP(ArrayT[m],ArrayP[m][0],ArrayP[m][1],i);
 }
 return;
}
//+------------------------------------------------------------------+
double RSI(double& array[], int periodRSI) // RSI indicator value
{
 int b=ArraySize(array);
 int index=0;

 return(iRSIOnArray(array,b,periodRSI,index));
}
//+------------------------------------------------------------------+
void MOMB() // Momentum array values
{
 MOMFill(ArrayMOM1,ArrayMOM1R,ArrayHPB1,21);
 MOMFill(ArrayMOM2,ArrayMOM2R,ArrayHPB2,22);
 MOMFill(ArrayMOM3,ArrayMOM3R,ArrayHPB3,23);
 MOMFill(ArrayMOM4,ArrayMOM4R,ArrayHPB4,24);
 MOMFill(ArrayMOM5,ArrayMOM5R,ArrayHPB5,25);
 MOMFill(ArrayMOM6,ArrayMOM6R,ArrayHPB6,26);
 MOMFill(ArrayMOM7,ArrayMOM7R,ArrayHPB7,27);
 return;
}
//+------------------------------------------------------------------+
void MOMFill(double& array[], double& arrayR[], double& arrayHPB[], int m) // fill MOM values
{
 int i,j,b,bmo;
 
 b=ArraySize(arrayHPB); 
 bmo=b-1;
 ArrayResize(array,b); 
 ArrayResize(arrayR,b); 
 for(i=0;i<b;i++) 
 {
  array[i]=MOM(arrayHPB,ArrayP[m][0],b,i);
  j=bmo-i;  
  arrayR[j]=array[i];
 }
 return;
}
//+------------------------------------------------------------------+
double MOM(double& array[], int periodMOM, int b, int i) // MOM indicator value
{
 return(iMomentumOnArray(array,b,periodMOM,i));
}
//+------------------------------------------------------------------+
void UpdateData()
{
 DataUpdate();
 return;
}
//+------------------------------------------------------------------+
void DataUpdate() // update data
{
 int i;

 HPAB();

 for(i=0;i<14;i++) DataValues[i]=HP(ArrayT[i],ArrayP[i][0],ArrayP[i][1],0);                             
                             
 DataValues[14]=RSI(ArrayHPA1,ArrayP[14][0]);
 DataValues[15]=RSI(ArrayHPA2,ArrayP[15][0]);
 DataValues[16]=RSI(ArrayHPA3,ArrayP[16][0]);
 DataValues[17]=RSI(ArrayHPA4,ArrayP[17][0]);
 DataValues[18]=RSI(ArrayHPA5,ArrayP[18][0]);
 DataValues[19]=RSI(ArrayHPA6,ArrayP[19][0]);
 DataValues[20]=RSI(ArrayHPA7,ArrayP[20][0]);      
 
 MOMB();
 
 DataValues[21]=ArrayMOM1[0];
 DataValues[22]=ArrayMOM2[0];
 DataValues[23]=ArrayMOM3[0];
 DataValues[24]=ArrayMOM4[0];
 DataValues[25]=ArrayMOM5[0];
 DataValues[26]=ArrayMOM6[0];
 DataValues[27]=ArrayMOM7[0];
 
 DataValues[28]=RSI(ArrayMOM1R,ArrayP[28][0]);
 DataValues[29]=RSI(ArrayMOM2R,ArrayP[29][0]);
 DataValues[30]=RSI(ArrayMOM3R,ArrayP[30][0]);
 DataValues[31]=RSI(ArrayMOM4R,ArrayP[31][0]);
 DataValues[32]=RSI(ArrayMOM5R,ArrayP[32][0]);
 DataValues[33]=RSI(ArrayMOM6R,ArrayP[33][0]);
 DataValues[34]=RSI(ArrayMOM7R,ArrayP[34][0]);   
 
 for(i=35;i<38;i++)          DataValues[i]=MFI(ArrayT[i],ArrayP[i][0]);
 i=38;                       DataValues[i]=VOL(ArrayT[i]);
 for(i=39;i<maxToggle;i=i+2) DataValues[i]=Snake(ArrayT[i],ArrayP[i][0],0);
 for(i=40;i<maxToggle;i=i+2) DataValues[i]=Snake(ArrayT[i],ArrayP[i][0],1);
 
                             DataValuesTr[0]=ATR(ArrayTTr[0],ArrayPTr[0]);
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
 int i,j;string info=sep;

 for(j=0;j<7;j++)
 {
  i=0;
  info = DataWindowString(info,DataTitles[j+(i*7)],DataValues[j+(i*7)],0); 
  i=2;
  info = DataWindowString(info,DataTitles[j+(i*7)],DataValues[j+(i*7)],0);
  i=1;
  info = DataWindowString(info,DataTitles[j+(i*7)],DataValues[j+(i*7)],0);   
  for(i=3;i<5;i++)
  {
   info = DataWindowString(info,DataTitles[j+(i*7)],DataValues[j+(i*7)],0); 
  }
  info=StringConcatenate(info,sep);  
 }
 
 for(i=35;i<43;i++)
 {
  info = DataWindowString(info,DataTitles[i],DataValues[i],0);
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
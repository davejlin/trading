//+----------------------------------------------------------------------+
//|                                                       TheOneMini.mq4 |
//|                                                         David J. Lin |
//|One Very Important EA based on the trading strategies of              |
//| Vince (forexportfolio@hotmail.com),                                  |
//|and programmed in collaboration with                                  |
//| Mike  (mike@netwin.co.nz).                                           |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|(d-lin@northwestern.edu)                                              |
//|Evanston, IL, September 13, 2006                                      |
//|                                                                      |
//|StopLong, StopShort, TakeLong, TakeShort, and TrailingAlls            |
//| based on code by Patrick (IBFX tutorial)                             |
//+----------------------------------------------------------------------+
#property copyright "David J. Lin"
#property link      ""
//=========================================================================
// Filters

bool F_ATR=false;
bool F_CCI=false;
bool F_Env=false;
bool F_Force=false;
bool F_Mom=false;
bool F_PMISD=false;
bool F_RSI1=false;
bool F_RSI2=false;
bool F_ROC=false;
bool F_SD1=false;
bool F_SD2=false;
bool F_Trix=false;

int F_ATRTimeframe=PERIOD_H1;
int F_ATRPeriod=14;
double F_ATRMax=0.0075;
double F_ATRMin=0.0025;

int F_CCITimeframe=PERIOD_H1;
int F_CCIPeriod=14;
int F_CCIPrice=PRICE_CLOSE;
double F_CCIMax=100;
double F_CCIMin=-100;

int F_EnvTimeframe=PERIOD_H1;
int F_EnvMAPeriod=20;
int F_EnvMAMethod=MODE_SMA;
int F_EnvMAShift=0;
int F_EnvMAPrice=PRICE_CLOSE;
double F_EnvDeviation=0.1;
bool F_EnvWithinRange=true;  // true=accept triggers within range, false=accept triggers outside of range

int F_ForceTimeframe=PERIOD_H1;
int F_ForcePeriod=14;
int F_ForceMAMethod=MODE_SMA;
int F_ForcePrice=PRICE_CLOSE;
double F_ForceMax=0.5;
double F_ForceMin=-0.5;

int F_MomTimeframe=PERIOD_H1;
int F_MomPeriod=14;
int F_MomPrice=PRICE_CLOSE;
double F_MomMax=100.5;
double F_MomMin=99.5;

int F_PMISDTimeframe=PERIOD_H1;
int F_PMIPeriod=20;
int F_PMIShift=0;
int F_PMIMethod=MODE_SMA;
int F_PMIPrice=PRICE_CLOSE;
int F_PMISDShift=0;
double F_PMISDMax=75;
double F_PMISDMin=25;
bool F_PMISDBull=true;  // true=accept triggers within range when bullish(white), false=when bearish(blue)

int F_RSI1Timeframe=PERIOD_H1;
int F_RSI1Period=14;
int F_RSI1Price=PRICE_CLOSE;
double F_RSI1Max=70;
double F_RSI1Min=30;

int F_RSI2Timeframe=PERIOD_H1;
int F_RSI2Period=14;
int F_RSI2Price=PRICE_CLOSE;
double F_RSI2Max=70;
double F_RSI2Min=30;

int F_ROCTimeframe=PERIOD_H1;
int F_ROCRPeriod=10;
int F_ROCMAPeriod=14;
int F_ROCMAType=1;
int F_ROCMAAppliedPrice=0;
double F_ROCDeviation=0;         
bool F_ROCUsePercent=false;
double F_ROCMax=50;
double F_ROCMin=-50;

int F_SD1Timeframe=PERIOD_H1;
int F_SD1MAPeriod=20;
int F_SD1MAShift=0;
int F_SD1MAMethod=MODE_SMA;
int F_SD1MAPrice=PRICE_CLOSE;
double F_SD1Max=0.0020;
double F_SD1Min=0.0010;

int F_SD2Timeframe=PERIOD_H1;
int F_SD2MAPeriod=20;
int F_SD2MAShift=0;
int F_SD2MAMethod=MODE_SMA;
int F_SD2MAPrice=PRICE_CLOSE;
double F_SD2Max=0.0020;
double F_SD2Min=0.0010;

int F_TrixTimeframe=PERIOD_H1;
int F_TrixDepth = 16;
double F_TrixMax=0.0100;
double F_TrixMin=-0.0100;

//=========================================================================
bool flag_Margin=true;                 // Margin (true) vs. Fixed-Lots (false)

extern bool flag_MiniShortI=true;      // Mini-Short Double Trouble I trades
extern bool flag_MiniShortII=true;     // Mini-Short Double Trouble II trades
extern bool flag_MiniShortIII=true;    // Mini-Short Reversal trades
extern bool flag_MiniLong10DayBO=true; // Mini-Long 10DayBO Daily trades
extern bool flag_MiniLongADXDay=true;  // Mini-Long ADXDay Daily trades
extern bool flag_MiniOsMAHiLo=true;    // MiniOsMAHiLo
extern bool flag_StochADX=true;        // StochADX
extern bool flag_StochKeltner=true;    // StochKeltner
extern bool flag_Vegas=true;           // Vegas
extern bool flag_RSIScalp=true;      // RSI Scalper 
extern bool flag_MAStochRSI=true;    // MAStochRSI
extern bool flag_PSARASC=true;       // PSARASC
extern bool flag_PMI30=true;           // PMI
extern bool flag_PMI60=true;           // PMI
extern bool flag_ADXTrend=true;      // ADXTrend
extern bool flag_HighProb4=true;     // HighProb H4

//Fixed Lots List: (fractional lots OK)

double Lots_fixed_MiniShortI=0.30;              // Mini-Short Double Trouble I
double Lots_fixed_MiniShortII=0.30;             // Mini-Short Double Trouble II
double Lots_fixed_MiniShortIII=0.30;            // Mini-Short Reversal
double Lots_fixed_MiniLong10DayBO=0.30;         // Mini-Long 10DayBO Daily 1
double Lots_fixed_MiniLongADXDay=0.30;          // Mini-Long ADXDay Daily 1
double Lots_fixed_MiniOsMAHiLo=0.30;            // MiniOsMAHiLo
double Lots_fixed_StochADX1=0.30;               // StochADX 1 (market immediate)
double Lots_fixed_StochADX2=0.30;               // StochADX 2 (market immediate)
double Lots_fixed_StochADX3=0.30;                // StochADX 3 (market delayed)
double Lots_fixed_StochKeltner1=0.30;           // StochKeltner 1
double Lots_fixed_StochKeltner2=0.30;           // StochKeltner 2
double Lots_fixed_StochKeltner3=0.30;           // StochKeltner 3
double Lots_fixed_Vegas1=0.30;                  // Vegas 1
double Lots_fixed_Vegas2=0.30;                  // Vegas 2
double Lots_fixed_Vegas3=0.30;                  // Vegas 3
double Lots_fixed_Vegas4=0.30;                  // Vegas 4
double Lots_fixed_RSIScalp1=0.10;            // RSI Scalper 1
double Lots_fixed_RSIScalp2=0.30;            // RSI Scalper 2
double Lots_fixed_RSIScalp3=0.30;            // RSI Scalper 3
double Lots_fixed_MAStochRSI1=0.30;          // MAStochRSI 1
double Lots_fixed_MAStochRSI2=0.30;          // MAStochRSI 2
double Lots_fixed_MAStochRSI3=0.30;          // MAStochRSI 3
double Lots_fixed_PSARASC1=0.30;             // PSARASC 1
double Lots_fixed_PMI301=0.30;               // PMI30 1
double Lots_fixed_PMI302=0.30;               // PMI30 2
double Lots_fixed_PMI601=0.30;               // PMI60 1
double Lots_fixed_PMI602=0.30;               // PMI60 2
double Lots_fixed_ADXTrend1=0.30;            // ADXTrend 1
double Lots_fixed_ADXTrend2=0.30;            // ADXTrend 2
double Lots_fixed_ADXTrend3=0.30;            // ADXTrend 3
double Lots_fixed_HighProb41=0.30;           // HighProb4 1
double Lots_fixed_HighProb42=0.30;           // HighProb4 2
double Lots_fixed_HighProb43=0.30;           // HighProb4 3

// Take Profit List:

int TakeProfit_MiniShortI=140;          // Mini-Short Double Trouble I
int TakeProfit_MiniShortII=200;         // Mini-Short Double Trouble II
int TakeProfit_MiniShortIII=200;        // Mini-Short Reversal
int TakeProfit_MiniLong10DayBO=400;     // Mini-Long 10DayBO Daily
int TakeProfit_MiniLongADXDay=280;        // Mini-Long ADXDay Daily
int TakeProfit_MiniOsMAHiLo=0;          // MiniOsMAHiLo
int TakeProfit_StochADX1=110;           // StochADX 1 (market immediate)
int TakeProfit_StochADX2=160;           // StochADX 2 (market immediate)
int TakeProfit_StochADX3=100;           // StochADX 3 (market delayed)
int TakeProfit_StochKeltner1=95;       // StochKeltner 1
int TakeProfit_StochKeltner2=65;       // StochKeltner 2
int TakeProfit_StochKeltner3=120;       // StochKeltner 3
int TakeProfit_Vegas1=100;              // Vegas 1
int TakeProfit_Vegas2=100;              // Vegas 2
int TakeProfit_Vegas3=120;              // Vegas 3
int TakeProfit_Vegas4=120;              // Vegas 4
int TakeProfit_RSIScalp1=0;          // RSI Scalper 1 
int TakeProfit_RSIScalp2=410;        // RSI Scalper 2
int TakeProfit_RSIScalp3=410;        // RSI Scalper 3
int TakeProfit_MAStochRSI1=130;      // MAStochRSI 1 
int TakeProfit_MAStochRSI2=180;      // MAStochRSI 2
int TakeProfit_MAStochRSI3=220;      // MAStochRSI 3
int TakeProfit_PSARASC1=250;         // PSARASC 1 
int TakeProfit_PMI301=85;              // PMI30 1 
int TakeProfit_PMI302=140;             // PMI30 2
int TakeProfit_PMI601=125;              // PMI60 1 
int TakeProfit_PMI602=190;             // PMI60 2
int TakeProfit_ADXTrend1=90;        // ADXTrend 1 
int TakeProfit_ADXTrend2=220;        // ADXTrend 2
int TakeProfit_ADXTrend3=460;        // ADXTrend 3
int TakeProfit_HighProb41=0;         // HighProb4 1 
int TakeProfit_HighProb42=400;       // HighProb4 2
int TakeProfit_HighProb43=400;       // HighProb4 3

//  Stop Loss List: (initial stop-losses submitted with triggered order)
//  No-greater-than stop losses are designated with "MAX," associated with methods using stop-losses behind previous highs/lows.

int StopLoss_MiniShortI=11;           // Mini-Short Double Trouble I (above high/below low)
int StopLossMAX_MiniShortI=28;        // pips MAXIMUM stop loss for Mini-Short Double Trouble I 

int StopLoss_MiniShortII=11;          // Mini-Short Double Trouble II (above high/below low)
int StopLossMAX_MiniShortII=35;       // pips MAXIMUM stop loss for Mini-Short Double Trouble II 

int StopLoss_MiniShortIII=10;         // Mini-Short Reversal (above high / below low)
int StopLossMAX_MiniShortIII=30;      // pips MAXIMUM stop loss for Mini-Short Reversal

int StopLoss_MiniLong10DayBO=25;      // Mini-Long 10DayBO Daily (above high/ below low)
int StopLossMAX_MiniLong10DayBO=45;   // pips MAXIMUM stop loss for Mini-Long 10DayBO Daily 

int StopLoss_MiniLongADXDay=50;       // Mini-Long ADXDay Daily (above high/ below low)

int StopLoss_MiniOsMAHiLo=15;         // MiniOsMAHiLo (above high / below low)
int StopLossMAX_MiniOsMAHiLo=40;    // MAX s/l MiniOsMAHiLo

int StopLoss_StochADX1=55;          // StochADX 1 (market immediate)
int StopLoss_StochADX2=45;          // StochADX 2 (market immediate)
int StopLoss_StochADX3=35;          // StochADX 3 (market delayed) 

int StopLoss_StochKeltner=40;         // StochKeltner

int StopLoss_Vegas=35;               // Vegas 1,2,3,4

int StopLossMAX_RSIScalp=40;          //  RSI Scalper

int StopLoss_MAStochRSI=35;           //  MAStochRSI
int StopLoss_PSARASC=35;              //  PSARASC 1
int StopLoss_PMI30=35;                  //  PMI30 1,2
int StopLoss_PMI60=45;                  //  PMI60 1,2
int StopLoss_ADXTrend=65;             //  ADXTrend 1,2,3
int StopLoss_HighProb4=120;           //  HighProb4 1,2,3
  
// Trailing Stop List:

int TrailingStop_MiniShortI=50;       // Mini-Short Double Trouble I 
int TrailingStop_MiniShortII=55;      // Mini-Short Double Trouble II
int TrailingStop_MiniShortIII=55;     // Mini-Short Reversal
int TrailingStop_MiniLong10DayBO=90;  // Mini-Long 10DayBO Daily
int TrailingStop_MiniLongADXDay=110;  // Mini-Long ADXDay Daily
int TrailingStop_MiniOsMAHiLo=50;    // MiniOsMAHiLo
int TrailingStop_StochADX1=50;       // StochADX 1 (market immediate)
int TrailingStop_StochADX2=50;       // StochADX 2 (market immediate)
int TrailingStop_StochADX3=60;       // StochADX 3 (market delayed)
int TrailingStop_StochKeltner1=40;   // StochKeltner 1
int TrailingStop_StochKeltner2=50;   // StochKeltner 2
int TrailingStop_StochKeltner3=55;   // StochKeltner 3
int TrailingStop_Vegas1=60;          // Vegas 1
int TrailingStop_Vegas2=60;          // Vegas 2
int TrailingStop_Vegas3=60;          // Vegas 3
int TrailingStop_Vegas4=100;          // Vegas 4
int TrailingStop_RSIScalp1=55;       //  RSIScalp 1
int TrailingStop_RSIScalp2=65;       //  RSIScalp 2
int TrailingStop_RSIScalp3=50;       //  RSIScalp 3
//int TrailingStop_MAStochRSI1=0;     //  MAStochRSI 1
//int TrailingStop_MAStochRSI2=0;     //  MAStochRSI 2
//int TrailingStop_MAStochRSI3=0;     //  MAStochRSI 3
int TrailingStop_PMI301=50;           //  PMI30 1
int TrailingStop_PMI302=60;           //  PMI30 2
int TrailingStop_PMI601=50;           //  PMI60 1
int TrailingStop_PMI602=60;           //  PMI60 2
int TrailingStop_ADXTrend1=50;      //  ADXTrend 1
int TrailingStop_ADXTrend2=85;      //  ADXTrend 2
int TrailingStop_ADXTrend3=140;      //  ADXTrend 3
//int TrailingStop_HighProb41=0;      //  HighProb4 1
int TrailingStop_HighProb42=80;      //  HighProb4 2
int TrailingStop_HighProb43=70;      //  HighProb4 3

// Dynamic Start List

int DynamicTrailMinimum=20;           // pips minimum dynamic trail (universally smallest dynamic trail achieveable)

int DynamicStart_MiniShortI=100;       // Mini-Short Double Trouble I
int DynamicStart_MiniShortII=140;     // Mini-Short Double Trouble II
int DynamicStart_MiniShortIII=70;     // Mini-Short Reversal
int DynamicStart_MiniLong10DayBO=320; // Mini-Long 10DayBO
int DynamicStart_MiniLongADXDay=100;  // Mini-Long ADXDay
int DynamicStart_MiniOsMAHiLo=50;    // MiniOsMAHiLo
int DynamicStart_StochADX1=75;       // StochADX 1 (market immediate)
int DynamicStart_StochADX2=85;       // StochADX 2 (market immediate)
int DynamicStart_StochADX3=100;       // StochADX 3 (market delayed)
int DynamicStart_StochKeltner1=60;   // StochKeltner 1
int DynamicStart_StochKeltner2=70;   // StochKeltner 2
int DynamicStart_StochKeltner3=80;   // StochKeltner 3
int DynamicStart_Vegas1=50;           // Vegas 1
int DynamicStart_Vegas2=100;          // Vegas 2
int DynamicStart_Vegas3=100;          // Vegas 3
int DynamicStart_Vegas4=200;          // Vegas 4
int DynamicStart_RSIScalp1=160;      // RSIScalp 1
int DynamicStart_RSIScalp2=265;      // RSIScalp 2
int DynamicStart_RSIScalp3=265;      // RSIScalp 3
//int DynamicStart_MAStochRSI1=0;    // MAStochRSI 1
//int DynamicStart_MAStochRSI2=0;    // MAStochRSI 2
//int DynamicStart_MAStochRSI3=0;    // MAStochRSI 3
int DynamicStart_PMI301=45;            // PMI30 1
int DynamicStart_PMI302=80;           // PMI30 2
int DynamicStart_PMI601=70;            // PMI60 1
int DynamicStart_PMI602=100;           // PMI60 2
int DynamicStart_ADXTrend1=50;       // ADXTrend 1
int DynamicStart_ADXTrend2=150;      // ADXTrend 2
int DynamicStart_ADXTrend3=270;      // ADXTrend 3
//int DynamicStart_HighProb41=0;       // HighProb4 1
int DynamicStart_HighProb42=250;      // HighProb4 2
int DynamicStart_HighProb43=150;      // HighProb4 3

// Dynamic Ratio List (distance in pips traveled vs. distance trail is shortened)

int DynamicRatio_MiniShortI=1;        // Mini-Short Double Trouble I
int DynamicRatio_MiniShortII=1;       // Mini-Short Double Trouble II
int DynamicRatio_MiniShortIII=1;      // Mini-Short Reversal
int DynamicRatio_MiniLong10DayBO=2;   // Mini-Long 10DayBO
int DynamicRatio_MiniLongADXDay=1;    // Mini-Long ADXDay
int DynamicRatio_MiniOsMAHiLo=1;      // MiniOsMAHiLo
int DynamicRatio_StochADX1=1;         // StochADX 1 (market immediate)
int DynamicRatio_StochADX2=1;         // StochADX 2 (market immediate)
int DynamicRatio_StochADX3=1;         // StochADX 3 (market delayed)
int DynamicRatio_StochKeltner1=1;     // StochKeltner 1
int DynamicRatio_StochKeltner2=1;     // StochKeltner 2
int DynamicRatio_StochKeltner3=1;     // StochKeltner 3
int DynamicRatio_Vegas1=2;            // Vegas 1
int DynamicRatio_Vegas2=2;            // Vegas 2
int DynamicRatio_Vegas3=2;            // Vegas 3
int DynamicRatio_Vegas4=2;            // Vegas 4
int DynamicRatio_RSIScalp1=1;         // RSIScalp 1
int DynamicRatio_RSIScalp2=1;         // RSIScalp 2
int DynamicRatio_RSIScalp3=1;         // RSIScalp 3
//int DynamicRatio_MAStochRSI1=0;       // MAStochRSI 1
//int DynamicRatio_MAStochRSI2=0;       // MAStochRSI 2
//int DynamicRatio_MAStochRSI3=0;       // MAStochRSI 3
int DynamicRatio_PMI301=1;              // PMI30 1
int DynamicRatio_PMI302=1;              // PMI30 2
int DynamicRatio_PMI601=1;              // PMI60 1
int DynamicRatio_PMI602=1;              // PMI60 2
int DynamicRatio_ADXTrend1=1;         // ADXTrend 1
int DynamicRatio_ADXTrend2=1;         // ADXTrend 2
int DynamicRatio_ADXTrend3=1;         // ADXTrend 3
//int DynamicRatio_HighProb41=0;         // HighProb4 1
int DynamicRatio_HighProb42=1;         // HighProb4 2
int DynamicRatio_HighProb43=1;         // HighProb4 3

// Associated Fixed-Stops Parameters List:

 // MiniShortI
int ProfitPointFS_MiniShortI1=24;      // pips PROFIT after which LockProfitFS_MiniShortI takes into effect for MiniShortI
int LockProfitFS_MiniShortI1=3;        // pips lock-in GAIN for MAScalp after ProfitPointFS_MiniShortI is hit
int ProfitPointFS_MiniShortI2=50;      // pips PROFIT after which LockProfitFS_MiniShortI2 takes into effect for MiniShortI
int LockProfitFS_MiniShortI2=19;       // pips lock-in GAIN for MAScalp after ProfitPointFS_MiniShortI2 is hit

 // MiniShortII
int ProfitPointFS_MiniShortII1=18;     // pips PROFIT after which LockProfitFS_MiniShortII takes into effect for MiniShortII
int LockProfitFS_MiniShortII1=1;       // pips lock-in GAIN for MAScalp after ProfitPointFS_MiniShortII is hit
int ProfitPointFS_MiniShortII2=55;     // pips PROFIT after which LockProfitFS_MiniShortII2 takes into effect for MiniShortII
int LockProfitFS_MiniShortII2=25;      // pips lock-in GAIN for MAScalp after ProfitPointFS_MiniShortII2 is hit

 // MiniShortIII
int ProfitPointFS_MiniShortIII=13;    // pips PROFIT after which LockProfitFS_MiniShortIII takes into effect for MiniShortIII
int LockProfitFS_MiniShortIII=1;      // pips lock-in GAIN for MAScalp after ProfitPointFS_MiniShortIII is hit

 // MiniLong10DayBO
int ProfitPointFS_MiniLong10DayBO=35; // pips PROFIT after which LockProfitFS_MiniLong10DayBO takes into effect for MiniLong10DayBO
int LockProfitFS_MiniLong10DayBO=5;   // pips lock-in GAIN for MiniLong 10DayBO

 // MiniLongADXDay
int ProfitPointFS_MiniLongADXDay=45;  // pips PROFIT after which LockProfitFS_MiniLongADXDay takes into effect for MiniLongADXDay
int LockProfitFS_MiniLongADXDay=9;    // pips lock-in GAIN for MiniLong ADXDay 

 // MiniOsMAHiLo
int ProfitPointFS_MiniOsMAHiLo1=22;   // if profit is less than this value at BB-touch, reset t/p to 
int TakeProfitNEW_MiniOsMAHiLo1=107;   // new t/p if profit is less than ProfitPointFS_MiniOsMAHiLo1 at time of BB-touch
int ProfitPointFS_MiniOsMAHiLo2=13;   // pips profit required to adjust s/l to LockProfitFS_MiniOsMAHiLo2
int LockProfitFS_MiniOsMAHiLo2=2;     // pips lock-in GAIN if ProfitPointFS_MiniOsMAHiLo2 is achieved (after BB-touch)

 // StochADX
 // StochADX Lot 1 (pending)
int ProfitPointFS_Lot1_StochADX=27;   // pips PROFIT after which LockProfitFS_Lot1_StochADX takes into effect for StochADX 1 
int LockProfitFS_Lot1_StochADX=6;     // pips lock-in GAIN for StochADX
 // StochADX Lot 2 (market immediate)
int ProfitPointFS_Lot2_StochADX=22;   // pips PROFIT after which LockProfitFS_Lot2_StochADX takes into effect for StochADX 2
int LockProfitFS_Lot2_StochADX=4;     // pips lock-in GAIN for StochADX
 // StochADX Lot 3 (market delayed)
int ProfitPointFS_Lot3_StochADX=25;   // pips PROFIT after which LockProfitFS_Lot3_StochADX takes into effect for StochADX 3
int LockProfitFS_Lot3_StochADX=4;     // pips lock-in GAIN for StochADX

 // StochKeltner
int ProfitPointFS_StochKeltner=35;   // pips PROFIT after which LockProfitFS_StochKeltner takes into effect for StochKeltner
int LockProfitFS_StochKeltner=4;     // pips lock-in GAIN for StochKeltner

 // StochKeltner
int ProfitPointFSMIN_StochKeltner=35;  // pips minimum profit to qualify s/l to be moved to LockProfitFS_StochKeltner1 after touch of Keltner centerline
  
int ProfitPointFS_StochKeltner1=35;   // pips PROFIT after which LockProfitFS_StochKeltner1 takes into effect for StochKeltner 1, 2, 3
int LockProfitFS_StochKeltner1=11;     // pips lock-in GAIN for StochKeltner 1, 2, 3 (when either LockProfitFS_StochKeltner1 hits or prices cross Keltner centerline)
int ProfitPointFS_StochKeltner2=45;   // pips PROFIT after which LockProfitFS_StochKeltner2 takes into effect for StochKeltner 1, 2, 3
int LockProfitFS_StochKeltner2=14;    // pips lock-in GAIN for StochKeltner 1, 2, 3

 // Vegas
// Vegas Lot 1
int ProfitPointFS_Lot1_Vegas=26;       // pips PROFIT after which LockProfitFS_Lot1_Vegas takes into effect for Vegas Order 1
int LockProfitFS_Lot1_Vegas=6;         // pips lock-in GAIN for Vegas Order 1 after ProfitPointFS_Lot1_Vegas is hit
 // Vegas Lot 2
int ProfitPointFS_Lot2_Vegas=42;       // pips PROFIT after which LockProfitFS_Lot2_Vegas takes into effect for Vegas Order 2
int LockProfitFS_Lot2_Vegas=12;         // pips lock-in GAIN for Vegas Order 2 after ProfitPointFS_Lot2_Vegas is hit
 // Vegas Lot 3
int ProfitPointFS_Lot3_Vegas=26;       // pips PROFIT after which LockProfitFS_Lot3_Vegas takes into effect for Vegas Order 3
int LockProfitFS_Lot3_Vegas=6;         // pips lock-in GAIN for Vegas Order 3 after ProfitPointFS_Lot3_Vegas is hit
 // Vegas Lot 4
int ProfitPointFS_Lot4_Vegas=42;       // pips PROFIT after which LockProfitFS_Lot4_Vegas takes into effect for Vegas Order 4
int LockProfitFS_Lot4_Vegas=12;         // pips lock-in GAIN for Vegas Order 4 after ProfitPointFS_Lot4_Vegas is hit

 // RSIScalp
 // RSIScalp Lot 1
int ProfitPointFS_Lot1_RSIScalp1=20;   // pips profit target after which to lock in LockProfitFS_Lot1_RSIScalp1 profits, order 1
int LockProfitFS_Lot1_RSIScalp1=4;     // pips lock-in GAIN for RSIScalp order 1 after ProfitPointFS_Lot1_RSIScalp1 is hit 
int ProfitPointFS_Lot1_RSIScalp2=60;   // pips profit target after which to lock in LockProfitFS_Lot1_RSIScalp2 profits, order 1
int LockProfitFS_Lot1_RSIScalp2=25;    // pips lock-in GAIN for RSIScalp order 1 after ProfitPointFS_Lot1_RSIScalp2 is hit 
 // RSIScalp Lot 2
int ProfitPointFS_Lot2_RSIScalp1=25;   // pips profit target after which to lock in LockProfitFS_Lot2_RSIScalp1 profits, order 2
int LockProfitFS_Lot2_RSIScalp1=9;     // pips lock-in GAIN for RSIScalp order 2 after ProfitPointFS_Lot2_RSIScalp1 is hit
int ProfitPointFS_Lot2_RSIScalp2=60;   // pips profit target after which to lock in LockProfitFS_Lot2_RSIScalp2 profits, order 2
int LockProfitFS_Lot2_RSIScalp2=25;    // pips lock-in GAIN for RSIScalp order 2 after ProfitPointFS_Lot2_RSIScalp2 is hit
 // RSIScalp Lot 3
int ProfitPointFS_Lot3_RSIScalp1=27;   // pips profit target after which to lock in LockProfitFS_Lot3_RSIScalp1 profits, order 3
int LockProfitFS_Lot3_RSIScalp1=11;     // pips lock-in GAIN for RSIScalp order 3 after ProfitPointFS_Lot3_RSIScalp1 is hit
int ProfitPointFS_Lot3_RSIScalp2=60;   // pips profit target after which to lock in LockProfitFS_Lot3_RSIScalp2 profits, order 3
int LockProfitFS_Lot3_RSIScalp2=25;    // pips lock-in GAIN for RSIScalp order 3 after ProfitPointFS_Lot3_RSIScalp2 is hit

 // MAStochRSI Lot 1
int ProfitPointFS_Lot1_MAStochRSI1=19;  // pips PROFIT after which LockProfitFS_Lot1_MAStochRSI takes into effect for MAStochRSI Order 1
int LockProfitFS_Lot1_MAStochRSI1=1;    // pips lock-in GAIN for MAStochRSI Order 1
int ProfitPointFS_Lot1_MAStochRSI2=35;  // pips PROFIT after which LockProfitFS_Lot1_MAStochRSI takes into effect for MAStochRSI
int LockProfitFS_Lot1_MAStochRSI2=8;    // pips lock-in GAIN for MAStochRSI
int ProfitPointFS_Lot1_MAStochRSI3=60;  // pips PROFIT after which LockProfitFS_Lot1_MAStochRSI takes into effect for MAStochRSI
int LockProfitFS_Lot1_MAStochRSI3=25;    // pips lock-in GAIN for MAStochRSI
 // MAStochRSI Lot 2
int ProfitPointFS_Lot2_MAStochRSI1=34;  // pips PROFIT after which LockProfitFS_Lot2_MAStochRSI takes into effect for MAStochRSI Order 2
int LockProfitFS_Lot2_MAStochRSI1=9;    // pips lock-in GAIN for MAStochRSI Order 2 
int ProfitPointFS_Lot2_MAStochRSI2=35;  // pips PROFIT after which LockProfitFS_Lot2_MAStochRSI takes into effect for MAStochRSI
int LockProfitFS_Lot2_MAStochRSI2=8;    // pips lock-in GAIN for MAStochRSI
int ProfitPointFS_Lot2_MAStochRSI3=60;  // pips PROFIT after which LockProfitFS_Lot2_MAStochRSI takes into effect for MAStochRSI
int LockProfitFS_Lot2_MAStochRSI3=25;    // pips lock-in GAIN for MAStochRSI
 // MAStochRSI Lot 3
int ProfitPointFS_Lot3_MAStochRSI1=60;  // pips PROFIT after which LockProfitFS_Lot3_MAStochRSI takes into effect for MAStochRSI Order 3
int LockProfitFS_Lot3_MAStochRSI1=15;    // pips lock-in GAIN for MAStochRSI Order 3
int ProfitPointFS_Lot3_MAStochRSI2=35;  // pips PROFIT after which LockProfitFS_Lot3_MAStochRSI takes into effect for MAStochRSI
int LockProfitFS_Lot3_MAStochRSI2=8;    // pips lock-in GAIN for MAStochRSI
int ProfitPointFS_Lot3_MAStochRSI3=60;  // pips PROFIT after which LockProfitFS_Lot3_MAStochRSI takes into effect for MAStochRSI
int LockProfitFS_Lot3_MAStochRSI3=25;    // pips lock-in GAIN for MAStochRSI

 // PSARASC
// PSARASC Lot 1
int ProfitPointFS_PSARASC1=38;       // pips PROFIT after which LockProfitFS_PSARASC takes into effect for PSARASC Orders
int LockProfitFS_PSARASC1=1;         // pips lock-in GAIN for PSARASC Orders after ProfitPointFS_PSARASC is hit
int ProfitPointFS_PSARASC2=40;       // pips PROFIT after which LockProfitFS_PSARASC takes into effect for PSARASC Orders
int LockProfitFS_PSARASC2=10;         // pips lock-in GAIN for PSARASC Orders after ProfitPointFS_PSARASC is hit

 // PMI30
 // PMI30 Lot 1
int ProfitPointFS_Lot1_PMI30=17;           // pips PROFIT after which LockProfitFS_Lot1_PMI takes into effect for PMI Order 1
int LockProfitFS_Lot1_PMI30=1;             // pips lock-in GAIN for PMI Order 1 after ProfitPointFS_Lot1_PMI is hit
 // PMI30 Lot 2
int ProfitPointFS_Lot2_PMI30=35;           // pips PROFIT after which LockProfitFS_Lot2_PMI takes into effect for PMI Order 2
int LockProfitFS_Lot2_PMI30=7;            // pips lock-in GAIN for PMI Order 2 after ProfitPointFS_Lot2_PMI is hit

 // PMI60
 // PMI60 Lot 1
int ProfitPointFS_Lot1_PMI60=21;           // pips PROFIT after which LockProfitFS_Lot1_PMI takes into effect for PMI Order 1
int LockProfitFS_Lot1_PMI60=2;             // pips lock-in GAIN for PMI Order 1 after ProfitPointFS_Lot1_PMI is hit
 // PMI60 Lot 2
int ProfitPointFS_Lot2_PMI60=32;           // pips PROFIT after which LockProfitFS_Lot2_PMI takes into effect for PMI Order 2
int LockProfitFS_Lot2_PMI60=9;            // pips lock-in GAIN for PMI Order 2 after ProfitPointFS_Lot2_PMI is hit
 
 // ADXTrend
// ADXTrend Lot 1
int ProfitPointFS_Lot1_ADXTrend=37;      // pips PROFIT after which LockProfitFS_Lot1_ADXTrend takes into effect for ADXTrend Order 1
int LockProfitFS_Lot1_ADXTrend=5;        // pips lock-in GAIN for ADXTrend Order 1 after ProfitPointFS_Lot1_ADXTrend is hit
 // ADXTrend Lot 2
int ProfitPointFS_Lot2_ADXTrend=47;      // pips PROFIT after which LockProfitFS_Lot2_ADXTrend takes into effect for ADXTrend Order 2
int LockProfitFS_Lot2_ADXTrend=12;       // pips lock-in GAIN for ADXTrend Order 2 after ProfitPointFS_Lot2_ADXTrend is hit
 // ADXTrend Lot 3
int ProfitPointFS_Lot3_ADXTrend=57;      // pips PROFIT after which LockProfitFS_Lot3_ADXTrend takes into effect for ADXTrend Order 3
int LockProfitFS_Lot3_ADXTrend=2;        // pips lock-in GAIN for ADXTrend Order 3 after ProfitPointFS_Lot3_ADXTrend is hit

 // HighProb4
// HighProb4 Lot 1
int ProfitPointFS_Lot1_HighProb4=42;      // pips PROFIT after which LockProfitFS_Lot1_HighProb takes into effect for HighProb Order 1
int LockProfitFS_Lot1_HighProb4=1;        // pips lock-in GAIN for HighProb Order 1 after ProfitPointFS_Lot1_HighProb is hit
 // HighProb4 Lot 2
int ProfitPointFS_Lot2_HighProb4=50;      // pips PROFIT after which LockProfitFS_Lot2_HighProb takes into effect for HighProb Order 2
int LockProfitFS_Lot2_HighProb4=4;        // pips lock-in GAIN for HighProb Order 2 after ProfitPointFS_Lot2_HighProb is hit
 // HighProb4 Lot 3
int ProfitPointFS_Lot3_HighProb4=50;      // pips PROFIT after which LockProfitFS_Lot3_HighProb takes into effect for HighProb Order 3
int LockProfitFS_Lot3_HighProb4=4;        // pips lock-in GAIN for HighProb Order 3 after ProfitPointFS_Lot3_HighProb is hit


//
// Other Order-related Parameters:
//

// Time Elapse Stops Variables:

int TES_delay=13;                       // hours to delay TES action.  TES begins the hour after this value. (e.g. if TES_delay=3, TES begins 4 hours after Order open).

int TES_Vegas=3;                       // pips to increment existing s/l at the beginning of the hour 
int TESMIN_Vegas=15;                   // pips smallest distance from market which TES is allowed to function

int TES_StochADX=3;                       // pips to increment existing s/l at the beginning of the hour 
int TESMIN_StochADX=15;                   // pips smallest distance from market which TES is allowed to function

int TES_RSIScalp=1;                    // pips to increment existing s/l at the beginning of the hour 
int TESMIN_RSIScalp=15;                // pips smallest distance from market which TES is allowed to function

int TES_MAStochRSI=2;                  // pips to increment existing s/l at the beginning of the hour 
int TESMIN_MAStochRSI=19;              // pips smallest distance from market which TES is allowed to function

int TES_MiniOsMAHiLo=3;                  // pips to increment existing s/l at the beginning of the hour 
int TESMIN_MiniOsMAHiLo=20;              // pips smallest distance from market which TES is allowed to function

int TES_PMI30=3;                       // pips to increment existing s/l at the beginning of the hour 
int TESMIN_PMI30=15;                   // pips smallest distance from market which TES is allowed to function

int TES_PMI60=5;                       // pips to increment existing s/l at the beginning of the hour 
int TESMIN_PMI60=15;                   // pips smallest distance from market which TES is allowed to function

int TES_ADXTrend=4;                       // pips to increment existing s/l at the beginning of the hour 
int TESMIN_ADXTrend=15;                   // pips smallest distance from market which TES is allowed to function

int TES_HighProb4=4;                       // pips to increment existing s/l at the beginning of the hour 
int TESMIN_HighProb4=78;                   // pips smallest distance from market which TES is allowed to function

// Pending Order Variables:

int PendingPip_RSIScalp=15;            // limit 
int PendingTime_RSIScalp=8;            // hours for pending order expiration

int PendingPip_HighProb4=20;           // limit 
int PendingTime_HighProb4=6;           // hours for pending order expiration

// ===================================================================================
// 
// Model Parameters:
//
// ===================================================================================

// ===================================
// Mini Short/Long Engines' Varaibles:
// ===================================

// Mini-Short Double Trouble I

int BlackOutHourBeginMiniShortI=8;       // hour to begin blackout of Mini Short I
int BlackOutHourEndMiniShortI=10;         // hour to end blackout of Mini Short I (set to -1 to turn off)

int MAMiniShortITimeframe=PERIOD_H1;      // Timeframe

int MAMiniShortIslowPeriod=12;            // SMA() acts as base line for MiniShortI
int MAMiniShortIslowShift=0;              // Shift
int MAMiniShortIslowMethod=MODE_SMA;      // Mode
int MAMiniShortIslowPrice=PRICE_CLOSE;    // Method

int MAMiniShortIveryslowPeriod=12;        // SMA() acts as exit line for MiniShortI
int MAMiniShortIveryslowShift=5;          // Shift
int MAMiniShortIveryslowMethod=MODE_SMMA;  // Mode
int MAMiniShortIveryslowPrice=PRICE_CLOSE;// Method

int TriggerPipsMiniShortPSAR=9;          // pips from opposing PSAR to execute pending order
int WindowPeriodMiniShortI=4;             // hours pending order will be valid (window-of-opportunity)

int BlackOutPeriodMiniShortI=1;           // hours to ignore future triggers after the execution of the last one
int MinimumLifetimeMiniShortI=0;           // hours minimum before a new pending order can cancel out an existing unprofitable order 

datetime OrderTimeMiniShortI=0;           // time of last MiniShortI order
bool flag_ExitOrderMiniShortIPL=false;     // true if short cross condition is met
bool flag_ExitOrderMiniShortIPS=false;     // true if long cross condition is met
bool flag_ExitOrderMiniShortIXL=false;     // true if exit MA X long exit condition is met
bool flag_ExitOrderMiniShortIXS=false;     // true if exit MA X short exit condition is met


// Mini-Short Double Trouble II

int BlackOutHourBeginMiniShortII=13;       // hour to begin blackout of MiniShort II
int BlackOutHourEndMiniShortII=18;         // hour to end blackout of MiniShort II (set to -1 to turn off)

int MAMiniShortIITimeframe=PERIOD_H1;      // Timeframe

int MAMiniShortIIslowPeriod=22;            // SMA() acts as base line for MiniShortII
int MAMiniShortIIslowShift=0;              // Shift
int MAMiniShortIIslowMethod=MODE_SMMA;      // Mode
int MAMiniShortIIslowPrice=PRICE_CLOSE;    // Method

int TriggerPipsMiniShortII=26;             // pips above SMA/price cross to execute pending order
int TriggerPipsMiniShortRSII=8;            // pips from support/resistance cross to execute pending order
int WindowPeriodMiniShortII=3;             // hours pending order will be valid (window-of-opportunity)

int BlackOutPeriodMiniShortII=1;           // hours to ignore future triggers after the execution of the last one
int MinimumLifetimeMiniShortII=1;           // hours minimum before a new pending order can cancel out an existing unprofitable order 

datetime OrderTimeMiniShortII=0;           // time of last MiniShortII order
bool flag_ExitOrderMiniShortIIPL=false;      // true if short cross condition is met
bool flag_ExitOrderMiniShortIIPS=false;      // true if long cross condition is met

// Mini-Short Reversal

int BlackOutHourBeginMiniShortIII=11;       // hour to begin blackout of MiniShort III
int BlackOutHourEndMiniShortIII=16;         // hour to end blackout of MiniShort III (set to -1 to turn off)

int PeriodMiniShortIII=80;                 // hours in scanning period to determine whether subsequent high is a maximum
int TriggerMiniShortIII=22;                // pips above/below subsequent hour's low/high to trigger order execution

int BlackOutPeriodMiniShortIII=36;          // hours after the submission of a MiniShortIII order to accept another trigger 

datetime OrderTimeMiniShortIII=0;          // stores time of last MiniShortIII order
bool flag_orderMiniShortIII=true;          // true if NO MiniShortIII order is open
bool flag_orderMiniShortIIILong=true;      // true if NO MiniShortIII long order is open
bool flag_orderMiniShortIIIShort=true;     // true if NO MiniShortIII short order is open
bool flag_ExitOrderMiniShortIIILong=false;  // true if long exit condition is met
bool flag_ExitOrderMiniShortIIIShort=false; // true if short exit condition is met


// Mini-Long 10DayBO Model's Variables

int PeriodMiniLong10DayBO=22;            // days in scanning range to determine new high/low
int TriggerMiniLong10DayBO=130;           // pips below high/ above low at which to trigger order 

int WindowPeriodMiniLong10DayBO=96;      // HOURS pending order is valid (window of opportunity)
int BlackOutPeriodMiniLong10DayBO=10;     // DAYS to prevent a new trigger after the last trigger

datetime OrderTimeMiniLong10DayBO=0;     // stores time of last Daily Reveral order
bool flag_ExitOrderMini10DayBOLong=false; // true if long exit condition is met
bool flag_ExitOrderMini10DayBOShort=false;// true if short exit condition is met

// Mini-Long ADXDay Model's Variables

int TrailBegin_MiniLongADXDay=90;   // Trails begin for ADXDay

int WindowPeriodADXDay=1;          // days in window of opportunity for ADXDay

int ADXDayOsMAfast=86;             // ADXDay OsMA EMA fast period
int ADXDayOsMAslow=12;             // ADXDay OsMA EMA slow period
int ADXDayOsMAsignal=10;            // ADXDay OsMA SMA signal period
int ADXDayOsMAprice=PRICE_CLOSE;   // ADXDay OsMA price

int ADXDayADXperiod=60;            // ADXDay ADX period
int ADXDayADXprice=PRICE_OPEN;     // ADXDay ADX price
 
int BlackoutPeriodMiniLongADXDay=2;        // days to prevent a new ADXDay OsMA order 

datetime OrderTimeMiniLongADXDay=0;        // stores time of last ADXDay order
bool flag_orderMiniLongADXDayL=true;      // true if NO MiniLongADXDay long order is open
bool flag_orderMiniLongADXDayS=true;      // true if NO MiniLongADXDay short order is open
bool flag_ExitOrderMiniADXDayLong=false;   // true if long exit conditions met
bool flag_ExitOrderMiniADXDayShort=false;  // true if long exit conditions met
bool flag_orderMiniLongADXDay=true;            // true if NO ADXDay orders

// MiniOsMAHiLo Model's Variables

int MiniOsMAHiLoTimeframe=PERIOD_H1;

int BlackOutHourBeginMiniOsMAHiLo=11;       // hour to begin blackout 
int BlackOutHourEndMiniOsMAHiLo=14;         // hour to end blackout (set to -1 to turn off)

int WindowPeriodMiniOsMAHiLo=18;           // hours in scanning range to determine new high/low

int MiniOsMAHiLoOsMAfast=36;               // OsMA EMA fast period
int MiniOsMAHiLoOsMAslow=12;               // OsMA EMA slow period
int MiniOsMAHiLoOsMAsignal=9;              // OsMA SMA signal period
int MiniOsMAHiLoOsMAprice=PRICE_CLOSE;     // OsMA price

int MiniOsMAHiLoBBPeriod=20;               // BB-Bands Period
int MiniOsMAHiLoBBBandsShift=0;            // BB-Bands Shift
double MiniOsMAHiLoBBDeviation=2.35;       // BB-Bands Deviation

double MiniOsMAHiLoSDLimit=0.2500;         // maximum value of standard deviation permitted to trigger

int MiniOsMAHiLoSDPeriod=20;               // standard deviation Period
int MiniOsMAHiLoSDShift=0;                 // standard deviation Shift
int MiniOsMAHiLoSDMethod=MODE_SMA;         // standard deviation Method
int MiniOsMAHiLoSDPrice=PRICE_LOW;         // standard deviation Price

int MiniOsMAHiLoRSIPeriod=14;              // RSI period
int MiniOsMAHiLoRSIPrice=PRICE_CLOSE;      // RSI price
double MiniOsMAHiLoRSIhighlimit=75;        // upper RSI limit above which no short orders are allowed
double MiniOsMAHiLoRSIlowlimit=25;         // lower RSI limit below which no long orders are allowed

int BlackoutPeriodMiniOsMAHiLo=3;          // hours to prevent a new trigger after the last trigger

int MiniOsMAHiLoMaxN=2;                    // maximum number of simultaneous trades
int MiniOsMAHiLoMaxNDay=3;                 // maximum number of triggered trades allowed per day

bool flag_orderMiniOsMAHiLo=true;          // true if NO MiniOsMAHiLo order is open
datetime OrderTimeMiniOsMAHiLo=0;          // stores time of last MiniOsMAHiLo order
bool flag_ExitOrderMiniOsMAHiLoLong=false; // true if long BB exit condition is met
bool flag_ExitOrderMiniOsMAHiLoShort=false;// true if short BB exit condition is met
bool flag_ExitMiniOsMAHiLoLong=false;      // true if contrary trigger exit condition is met
bool flag_ExitMiniOsMAHiLoShort=false;     // true if contrary trigger short exit condition is met
int MiniOsMAHiLoExit=0;                    // 2=check BB exit, 1=don't check BB exit (after t/p adjustment)
int N_MiniOsMAHiLo=0;                        // total number of orders
int NDay_MiniOsMAHiLo=0;                     // total number of orders in a day


// StochADX Model's Variables

int StochADXTimeframe=PERIOD_H1;

int WindowPeriodStochADX=4;                // hours in window of opportunity for triggers to be received (array max 10)
int WindowPeriodStochADX2=10;               // hours in window of opportunity for ATRStop friendliness

int StochADXOsMAfast=12;                   // OsMA EMA fast period
int StochADXOsMAslow=26;                   // OsMA EMA slow period
int StochADXOsMAsignal=12;                 // OsMA SMA signal period
int StochADXOsMAprice=PRICE_CLOSE;         // OsMA price

int StochADXPeriod=10;                     // Period for smoothed ADX
int StochADXsmPeriod=4;                    // Smoothing period for smoothed ADX

int StochADXqPeriod = 10;                  // q Period for DS_Stochastics
int StochADXrPeriod = 26;                  // r Period for DS_Stochastics
int StochADXEMAfast = 5;                   // EMA fast for DS_Stochastics
int StochADXCountBars = 400;               // Count Bars for DS_Stochastics

int StochADXEnvPeriod=20;                  // Envelopes Period (order 3 exit)
int StochADXEnvMethod=MODE_SMA;            // Envelopes Method
int StochADXEnvShift=0;                    // Envelopes Shift
int StochADXEnvPrice=PRICE_CLOSE;          // Envelopes Price 
int StochADXEnvDev=0.10;                   // Envelopes Deviation

int BlackoutPeriodStochADX=5;              // hours to prevent a new trigger after the last trigger

bool flag_orderStochADX1Long=true;         // true if NO StochADX long order is open
bool flag_orderStochADX1Short=true;        // true if NO StochADX short order is open
bool flag_orderStochADX3Long=true;         // true if NO StochADX long order is open
bool flag_orderStochADX3Short=true;        // true if NO StochADX short order is open
datetime OrderTimeStochADX1Long=0;         // stores time of last long StochADX order 1
datetime OrderTimeStochADX1Short=0;        // stores time of last long StochADX order 1
datetime OrderTimeStochADX3Long=0;         // stores time of last long StochADX order 2, 3
datetime OrderTimeStochADX3Short=0;        // stores time of last long StochADX order 2, 3
datetime StochADXLongTime=0;               // stores time of last long primary trigger
datetime StochADXShortTime=0;              // stores time of last short primaer trigger
bool flag_ExitOrderStochADX1Long=false;    // true when long exit condition hits (Order 1,2 contrary trigger)
bool flag_ExitOrderStochADX1Short=false;   // true when short exit condition hits (Order 1,2 contrary trigger)
bool flag_ExitOrderStochADX3Long=false;    // true when long exit condition hits (Order 3 Envelope touch)
bool flag_ExitOrderStochADX3Short=false;   // true when short exit condition hits (Order 3 Envelope touch)

// StochKeltner Model's Variables

int StochKeltnerTimeframe=PERIOD_H1;

int WindowPeriodStochKeltner1=4;           // hours in window of opportunity for Part 1 triggers to be received
int WindowPeriodStochKeltner3=4;           // hours in window of opportunity for Part 3 triggers to be received

int StochKeltnerMAPeriod=20;               // Period for Keltner Channels MA
int StochKeltnerMAShift=0;                 // Shift for Keltner Channels MA
int StochKeltnerMAMethod=MODE_EMA;         // Mode
int StochKeltnerMAPrice=PRICE_CLOSE;       // Method

int StochKeltnerATRPeriod=20;              // Period for Keltner Channels ATR
double StochKeltnerMultiplier=2.0;         // Multiplier for Keltner Channels

int StochKeltnerOsMAfast=12;               // OsMA EMA fast period
int StochKeltnerOsMAslow=46;               // OsMA EMA slow period
int StochKeltnerOsMAsignal=6;              // OsMA SMA signal period
int StochKeltnerOsMAprice=PRICE_CLOSE;     // OsMA price

int StochKeltnerqPeriod = 10;              // q Period for DS_Stochastics
int StochKeltnerrPeriod = 26;              // r Period for DS_Stochastics
int StochKeltnerEMAfast = 5;               // EMA fast for DS_Stochastics
int StochKeltnerCountBars = 400;           // Count Bars for DS_Stochastics

int StochKeltnerRSIFilterPeriod = 14;      // RSI period for RSI filter
int StochKeltnerRSIFilterPrice=PRICE_CLOSE;// RSI price

double StochKeltnerRSILowLimit=21;         // lower RSI limit below which to deactivate for blackout period
double StochKeltnerRSIHighLimit=79;        // higher RSI limit above which to deactivate for blackout period
int StochKeltnerRSIBlackoutPeriod=24;      // hours blackout period after RSI extreme readings

double StochKeltnerRSIShortLevel=69;       // RSI limit below which to permit shorts
double StochKeltnerRSILongLevel=31;        // RSI limit above which to permit longs
int WindowPeriodStochKeltnerRSI=2;         // hours in WoO for RSI permission levels to be reached

double StochKeltnerATRRatioMax=1.8;        // maximum ATR Ratio above which to deactivate for blackout period
int StochKeltnerATRRatioBlackout=48;       // hours blackout period after ATR Ratio extreme readings
int StochKeltnerATRratioShortPeriod=7;     // ATR ratio short period
int StochKeltnerATRratioLongPeriod=49;     // ATR ratio long period

double StochKeltnerStochLowLimit=33;       // Stoch level below which a long Part 3 trigger is validated
double StochKeltnerStochHighLimit=67;      // Stoch level above which a short Part 3 trigger is validated

int BlackoutPeriodStochKeltner=2;         // hours to prevent a new trigger after the last trigger

bool flag_orderStochKeltner1=true;         // true if NO StochKeltner order 1 is open
bool flag_orderStochKeltner2=true;         // true if NO StochKeltner order 2 is open
bool flag_orderStochKeltner3=true;         // true if NO StochKeltner order 3 is open
datetime OrderTimeStochKeltner1=0;         // stores time of last StochKeltner order 1
datetime OrderTimeStochKeltner2=0;         // stores time of last StochKeltner order 2
datetime OrderTimeStochKeltner3=0;         // stores time of last StochKeltner order 3
bool flag_FSStochKeltnerLong=false;        // true when crosses Keltner centerline for fixed-stop activation
bool flag_FSStochKeltnerShort=false;       // true when crosses Keltner centerline for fixed-stop activation
bool flag_ExitOrderStochKeltnerLong=false; // true when long exit condition hits
bool flag_ExitOrderStochKeltnerShort=false; // true when long exit condition hits
bool flag_ExitStochKeltner1Long=false;     // true when long exit condition hits
bool flag_ExitStochKeltner1Short=false;    // true when short exit condition hits
bool flag_ExitStochKeltner2Long=false;     // true when long exit condition hits
bool flag_ExitStochKeltner2Short=false;    // true when short exit condition hits
bool flag_ExitStochKeltner3Long=false;     // true when long exit condition hits
bool flag_ExitStochKeltner3Short=false;    // true when short exit condition hits


// Vegas Variables:

int VegasTimeframe=PERIOD_H1;            // Timeframe for method

int VegasMAPeriod=163;                   // MA Period
int VegasMAShift=0;                      // Shift
int VegasMAMethod=MODE_EMA;              // Mode
int VegasMAPrice=PRICE_CLOSE;            // Method

int VegasMASpan=92;                      // pips away from MA(169) line to form upper/lower Vegas lines

int BlackoutPeriodVegas=4;              // hours to blackout future same-direction Vegas orders after one has occurred

datetime OrderTimeVegasLong=0;           // stores time of latest Vegas long order
datetime OrderTimeVegasShort=0;          // stores time of latest Vegas short order
bool flag_orderVegas=true;               // true if NO Vegas Part 1 orders are open
bool flag_orderVegas2=true;              // true if NO Vegas Part 2 orders are open - needed for proper flag setting
bool flag_orderVegasLong=true;           // true if NO long Vegas orders are open
bool flag_orderVegasShort=true;          // true if NO short Vegas orders are open
bool flag_ExitOrderVegasLong=false;      // true if long exit triggered Order 2, Part 1
bool flag_ExitOrderVegasShort=false;     // true if short exit triggered Order 2, Part 1
int VegasTop=0;                          // 2=close above topline
int VegasBot=0;                          // 2=close below botline
int VegasIn=0;                           // 2=close inside lines

// RSI Sclaper Model's Variables

int RSIScalpTimeframe=PERIOD_H1;     // timeframe for RSIScalp

double RSIveryhigh=72.0;             // very high RSI value (Orders 1, 2, sell on bearish ZLMA X) (Double lots)
double RSIhigh=65.0;                 // high RSI value      (Orders 1, 2, sell on bearish ZLMA X) (Single lots)
double RSIlow=35.0;                  // low RSI value       (Orders 1, 2, buy  on bullish ZLMA X) (Single lots)
double RSIverylow=28.0;              // very low RSI value  (Orders 1, 2, buy  on bullish ZLMA X) (Double lots)

double RSIhigh3=58.0;                // high RSI value      (Order 3, buy on bullish ZLMA X)
double RSIlow3=42.0;                 // low RSI value       (Order 3, sell on bearish ZLMA X)

double RSIexitlong=76.0;             // exit RSI value for longs
double RSIexitshort=24.0;            // exit RSI value for shorts

int WindowPeriodRSIScalp=10;          // hours in WoO for secondary trigger (Zero-lag MA X) (array limit 100)

int RSIScalp1Period=6;                // fast line, Zero-lag MA for secondary trigger
int RSIScalp1Shift=0;                 // Shift
int RSIScalp1Method=MODE_EMA;         // Mode
int RSIScalp1Price=PRICE_CLOSE;       // Method
int RSIScalp1SmoothPeriod=12;          // fast smoothing period for Zero-lag MA
int RSIScalp1SmoothShift=0;           // Shift
int RSIScalp1SmoothMethod=MODE_EMA;   // Mode

int RSIScalp2Period=21;               // slow line, Zero-lag MA for secondary trigger
int RSIScalp2Shift=0;                 // Shift
int RSIScalp2Method=MODE_EMA;         // Mode
int RSIScalp2Price=PRICE_CLOSE;       // Method
int RSIScalp2SmoothPeriod=21;         // slow smoothing period for Zero-lag MA
int RSIScalp2SmoothShift=0;           // Shift
int RSIScalp2SmoothMethod=MODE_EMA;   // Mode

int RSIScalpPeriod=18;                    // RSI period
int RSIScalpPrice=PRICE_CLOSE;            // RSI price

int BlackoutPeriodRSIScalp=1;        // hours to prevent a new RSI Scalper Orders 1, 2
int BlackoutPeriodRSIScalp3=2;       // hours to prevent a new RSI Scalper Order 3

bool flag_orderRSIScalpLong=true;    // true if NO RSI Scalper long order
bool flag_orderRSIScalpShort=true;   // true if NO RSI Scalper short order
bool flag_orderRSIScalp3Long=true;   // true if NO RSI Scalper long order
bool flag_orderRSIScalp3Short=true;  // true if NO RSI Scalper short order
datetime OrderTimeRSIScalpLong=0;    // time of last RSI Scalper long order
datetime OrderTimeRSIScalpShort=0;   // time of last RSI Scalper short order
datetime OrderTimeRSIScalp3Long=0;    // time of last RSI Scalper long order 3
datetime OrderTimeRSIScalp3Short=0;   // time of last RSI Scalper short order 3
bool flag_ExitOrderRSIScalpALong=false;    // true if long exit trigger is hit
bool flag_ExitOrderRSIScalpAShort=false;   // true if short exit trigger is hit
bool flag_ExitOrderRSIScalpBLong=false;    // true if long exit trigger is hit
bool flag_ExitOrderRSIScalpBShort=false;   // true if short exit trigger is hit
int RSIScalpLongDelay=0;              // toggle to delay Order 2's SMA exit to 2nd one
int RSIScalpShortDelay=0;             // toggle to delay Order 2's SMA exit to 2nd one


// MAStochRSI Model's Variables

int MAStochRSITimeframe=PERIOD_H1;       // Timeframe

int WindowPeriodMAStochRSI=20;           // hours in WoO for ATRStop friendliness (Orders 2 & 3)
int MAStochRSItouch=1;                   // 0=every tick Touch, 1=prev Hr Close

int MAStochRSI1Period=13;                // fast line
int MAStochRSI1Shift=0;                  // Shift
int MAStochRSI1Method=MODE_EMA;          // Mode
int MAStochRSI1Price=PRICE_CLOSE;        // Method
int MAStochRSI1SmoothPeriod=13;          // fast smoothing period for Zero-lag MA
int MAStochRSI1SmoothShift=0;            // Shift
int MAStochRSI1SmoothMethod=MODE_EMA;    // Mode

int MAStochRSI2Period=19;                // slow line
int MAStochRSI2Shift=0;                  // Shift
int MAStochRSI2Method=MODE_EMA;          // Mode
int MAStochRSI2Price=PRICE_CLOSE;        // Method
int MAStochRSI2SmoothPeriod=19;          // slow smoothing period for Zero-lag MA
int MAStochRSI2SmoothShift=0;            // Shift
int MAStochRSI2SmoothMethod=MODE_EMA;    // Mode

int MAStochRSIqPeriod = 10;               // q Period for DS_Stochastics
int MAStochRSIrPeriod = 26;              // r Period for DS_Stochastics
int MAStochRSIEMAfast = 5;               // EMA fast for DS_Stochastics
int MAStochRSICountBars = 400;           // Count Bars for DS_Stochastics

double MAStochRSI_STOCHBuyLevel = 44;    // Stoch level below which to buy
double MAStochRSI_STOCHSellLevel = 54;   // Stoch level above which to sell

int MAStochRSIPeriod = 14;               // RSI period
int MAStochRSIPrice=PRICE_CLOSE;         // RSI price

double MAStochRSI_RSIBuyLevel = 34;      // RSI level above which to buy
double MAStochRSI_RSISellLevel = 66;     // RSI level below which to sell

int MAStochRSIEnvPeriod=20;              // Envelopes Period (order 3 exit)
int MAStochRSIEnvMethod=MODE_SMA;        // Envelopes Method
int MAStochRSIEnvShift=0;                // Envelopes Shift
int MAStochRSIEnvPrice=PRICE_CLOSE;      // Envelopes Price 
int MAStochRSIEnvDev=0.40;               // Envelopes Deviation

double MAStochRSIPSARStep=0.01;          // PSAR step
double MAStochRSIPSARMax=0.20;           // PSAR max

int MAStochRSIPSARMinSL=25;              // pips minimum SL if the available PSAR is less than this value (only for HiProb4)

int BlackoutPeriodMAStochRSI=1;         // hours to blackout future MAStochRSI order 1

datetime OrderTimeMAStochRSI=0;          // stores time of latest MAStochRSI orders
bool flag_orderMAStochRSI=true;          // true if no orders
bool flag_ExitOrderMAStochRSI3Long=false; // true if long exit conditions met (Order 3 Envelope touch)
bool flag_ExitOrderMAStochRSI3Short=false;// true if short exit conditions met (Order 3 Envelope touch)

// PSARASC Variables:

int PSARASCTimeframe=PERIOD_H1;           // Timeframe for method

int PSARASCRisk=3;                        // ASCTrend Risk
int PSARASCCountbars=50;                 // ASCTrend Countbars

int PSARASCSDPeriod=10;                   // standard deviation Period
int PSARASCSDShift=0;                     // standard deviation Shift
int PSARASCSDMethod=MODE_SMA;             // standard deviation Method
int PSARASCSDPrice=PRICE_CLOSE;           // standard deviation Price

                                          // SD below this -> 4xlot
double PSARASCSDLevel1=0.120;           // SD level      -> 3xlot 
double PSARASCSDLevel2=0.200;           // SD level      -> 2xlot
double PSARASCSDLevel3=0.390;           // SD above this -> 1xlot

int WindowPeriodPSARASC=3;                // hours in WoO for ASC signal and PSAR turn to agree
int BlackoutPeriodPSARASC=1;              // hours to blackout future PSARASC orders after one has occurred

datetime OrderTimePSARASCL=0;             // stores time of latest PSARASC order
datetime OrderTimePSARASCS=0;             // stores time of latest PSARASC order
bool flag_orderPSARASCL=true;             // true if NO PSARASC orders are open
bool flag_orderPSARASCS=true;             // true if NO PSARASC orders are open
bool flag_ExitPSARASCL=false;             // true if long exit triggered
bool flag_ExitPSARASCS=false;             // true if short exit triggered

// PMI30 Variables:

int PMI30Timeframe=PERIOD_M30;           // Timeframe for method

int PMI30touch=1;                        // 0=instant values, 1=confirmed (prev hr) values

int PMI30RSIPeriod=20;                   // PMI+SD RSI Period
int PMI30RSIPrice=PRICE_CLOSE;           // PMI+SD RSI Price 
int PMI30LongVshift=50;                  // PMI+SD RSI VerticalShiftTo25 for Long signals
int PMI30ShortVshift=50;                 // PMI+SD RSI VerticalShiftTo25 for Short signals

double PMI30TriggerLimit=25;             // PMI+SD trigger line, above which no orders are allowed

int BlackoutPeriodPMI30=1;               // hours to blackout future PMI orders after one has occurred

datetime OrderTimePMI30=0;               // stores time of latest PMI order
bool flag_orderPMI30=true;               // true if NO PMI orders are open
bool flag_ExitPMI30L=false;              // true if long exit triggered
bool flag_ExitPMI30S=false;              // true if short exit triggered

// PMI60 Variables:

int PMI60Timeframe=PERIOD_H1;            // Timeframe for method

int PMI60touch=1;                        // 0=instant values, 1=confirmed (prev hr) values

int PMI60RSIPeriod=20;                   // PMI+SD RSI Period
int PMI60RSIPrice=PRICE_CLOSE;           // PMI+SD RSI Price 
int PMI60LongVshift=45;                  // PMI+SD RSI VerticalShiftTo25 for Long signals
int PMI60ShortVshift=50;                 // PMI+SD RSI VerticalShiftTo25 for Short signals

double PMI60TriggerLimit=24;             // PMI+SD trigger line, above which no orders are allowed

int BlackoutPeriodPMI60=1;               // hours to blackout future PMI orders after one has occurred

datetime OrderTimePMI60=0;               // stores time of latest PMI order
bool flag_orderPMI60=true;               // true if NO PMI orders are open
bool flag_ExitPMI60L=false;              // true if long exit triggered
bool flag_ExitPMI60S=false;              // true if short exit triggered

// ADXTrend Variables:

int ADXTrendTimeframe=PERIOD_H1;            // Timeframe for method

int ADXTrendADXperiod=500;                  // ADXDay ADX period
int ADXTrendADXprice=PRICE_CLOSE;           // ADXDay ADX price

int WindowPeriod1ADXTrend=4;                // hours in mandatory delay between ADX-cross and position entry
int WindowPeriod2ADXTrend=4;                // hours in WoO for Awe to agree after mandatory delay had passed
int BlackoutPeriodADXTrend=1;               // hours to blackout future ADXTrend orders after one has occurred

datetime OrderTimeADXTrend=0;               // stores time of latest ADXTrend order
bool flag_orderADXTrend=true;               // true if NO ADXTrend orders are open
bool flag_ExitADXTrendL=false;              // true if long exit triggered
bool flag_ExitADXTrendS=false;              // true if short exit triggered

// HighProb4 Variables:

int HighProb4Timeframe=PERIOD_H4;            // Timeframe for method

int HighProb4qPeriod = 13;                   // q Period for DS_Stochastics
int HighProb4rPeriod = 32;                   // r Period for DS_Stochastics
int HighProb4EMAfast = 5;                    // EMA fast for DS_Stochastics
int HighProb4CountBars = 3000;                // Count Bars for DS_Stochastics

double HighProb4StochLowLevel=45;            // buy at or below this DS_Stochastics level
double HighProb4StochHighLevel=55;           // sell at or above this DS_Stochastics level

double HighProb4StochValueExitS=40;          // exit short at contr crosses below this value
double HighProb4StochValueExitL=60;          // exit long at contr crosses above this value

int HighProb4OsMAfast=12;                    // OsMA EMA fast period
int HighProb4OsMAslow=26;                    // OsMA EMA slow period
int HighProb4OsMAsignal=6;                   // OsMA SMA signal period
int HighProb4OsMAprice=PRICE_CLOSE;          // OsMA price

int HighProb4PMIPeriod=24;                   // PMI+SD period 
double HigProb4PMISDMaxLevel=27;             // NO trades above this PMI+SD level

int HighProb4SDPeriod=60;                    // standard deviation Period
int HighProb4SDShift=0;                      // standard deviation Shift
int HighProb4SDMethod=MODE_SMA;              // standard deviation Method
int HighProb4SDPrice=PRICE_CLOSE;            // standard deviation Price

double HighProb4SDLimit=1.2000;               // no trades above this SD level

int HighProb4PSARMinSL=25;                    // pips minimum SL if the available PSAR is less than this value (only for HiProb4)

double HighProb4PSARStep=0.03;                // PSAR step for entry & SL considerations (only for HiProb4)
double HighProb4PSARMax=0.20;                 // PSAR max for entry & SL considerations (only for HiProb4)

int WindowPeriodHighProb4=4;                 // hours for OsMA, PMI, SD to be in agreement & PMI+SD to be under max level
int WindowPeriodHighProb4PSAR=6;            // hours for PSAR to become friendly after trigger
int BlackoutPeriodHighProb4=1;               // hours to blackout future HighProb4 orders after one has occurred

datetime OrderTimeHighProb4=0;               // stores time of latest HighProb4 order
datetime HighProb4LDelay=0;                  // stores time of latest HighProb L trigger in PSAR unfriendliness
datetime HighProb4SDelay=0;                  // stores time of latest HighProb S trigger in PSAR unfriendliness
bool flag_orderHighProb4L=true;              // true if NO HighProb4 long orders are open
bool flag_orderHighProb4S=true;              // true if NO HighProb4 short orders are open
bool flag_ExitHighProb4L=false;              // true if long exit triggered
bool flag_ExitHighProb4S=false;              // true if short exit triggered
bool flag_ExitHighProb42L=false;             // true if long exit triggered for O2: contrary entry
bool flag_ExitHighProb42S=false;             // true if short exit triggered for O2: contrary entry
int HighProb4Trail=0;                        // toggle to signal O1 exit so O2 trail can begin

// ===================================================================================
// 
// Trend Parameters:
//
// ===================================================================================

// SMA(D10) Trend Determination Variables:

int MATrendPeriod=10;                     // SMA(10) acts as base line for Trend determination
int MATrendTimeframe=PERIOD_D1;           // Timeframe Period = D1
int MATrendShift=0;                       // Shift
int MATrendMethod=MODE_SMA;               // Mode
int MATrendPrice=PRICE_CLOSE;             // Method

int MAMonitorTimeframe=PERIOD_D1;         // Timeframe for monitoring of previous day's close

int EnterTrend=145;                       // pips above/below 10daySMA to trigger trend conditions
int ExitTrend=0;                          // pips above/below SMA to exit trend conditions

// Bollinger Bands Trend Determination Variables:

int BBTrendPeriod=20;                     // BB Period
int BBTrendDeviation=2;                   // BB Deviation
int BBTrendBandsShift=0;                  // BB Bands-Shift
int BBTrendTimeframe=PERIOD_D1;           // BB Timeframe
int BBTrendPrice=PRICE_CLOSE;             // BB Method

// EMA (in conjunction with Bollinger Bands)

int MABBTrendPeriod=2;                    // EMA Period (should be >= 2)
int MABBTrendShift=0;                          // Shift
int MABBTrendTimeframe=PERIOD_D1;              // Timeframe
int MABBTrendMethod=MODE_EMA;                  // Mode
int MABBTrendPrice=PRICE_CLOSE;                // Method

//===================================================================================================
// Utilities parameters
//===================================================================================================

// PMI+SD Variables ("Productivity Momentum Index w/ Standard Deviation")

int PMIPeriod=20;                    // MA Period for PMI+SD
int PMIShift=0;                      // MA Shift
int PMIMethod=MODE_SMA;              // MA Method
int PMIPrice=PRICE_CLOSE;            // MA Price
int PMISDShift=0;                    // Standard Deviation Shift

// Parabolic SAR Variables

double PSARStep=0.02;                // Parabolic SAR step
double PSARMax =0.20;                // Parabolic SAR maximum

int PSARStopLossBuffer=4;            // pips +/- from PSAR at which to define s/l levels
int PSARMinimumStopLoss=25;          // pips s/l from market if PSAR is closer than this value

int PSARBeyondPips=20;               // pips within FibATRStop at which to use PSARStop
int PSARWithinPips=25;               // pips beyond FibATRStop at which to use PSARStop

// ... for ATR Stop system & MAStochRSI
int ATRStopPeriodB=20;        // ATR-Stop Period 
int ATRStopCoefficientB=1;    // ATR-Stop Coefficient 

// Relavent Stops/Target Varaibles

int ATRStopAdjust=15;                      // ATR-Stop level value +/- pips for ATR-relavent stops
int ATRTargetAdjust=0;                     // ATR-Stop level value +/- pips for ATR-relavent targets
int ATRRange=5;                            // pip range from Fib-calculated values to switch to ATR values

int FibStopAdjust=10;                      // Fibonacci level value +/- pips for relavent stops
int FibTargetAdjust=7;                     // Fibonacci level value +/- pips for relavent targets
int FibStopFront=5;                        // pips in front of reference stop to search for relavent stop
int FibStopBack=10;                        // pips in back of reference stop to search for relavent stop
int FibTargetLimit1=50;                    // pips of reference target under which to use FibTargetRange1
int FibTargetLimit2=100;                   // pips of reference target under which to use FibTargetRange2
int FibTargetLimit3=200;                   // pips of reference target under which to use FibTargetRange3
int FibTargetRange1=10;                    // pips +/- reference target (<FibTargetLimit1 pips) to search for relavent target
int FibTargetRange2=15;                    // pips +/- reference target (FibTargetLimit1-FibTargetLimit2 pips) to search for relavent target
int FibTargetRange3=20;                    // pips +/- reference target (FibtargetLimit2-FibTargetLimit3 pips) to search for relavent target
int FibTargetRange4=30;                    // pips +/- reference target (>FibtargetLimit3 pips) to search for relavent target

// Margin Group individual percentage of margin responsibilities

double Group1=0.01;
double Group2=0.0085;
double Group3=0.0065;
double Group4=0.0045;
double Group5=0.0025;

// Productivity factors
 
int ProductivityPeriod=20;            // hours to scan 
 
double ProductivityHighLimit=5.0;     // high limit
double ProductivityLowLimit=2.5;      // low limit
double ProductivityHighFactor=1.5;    // multiplicative factor if above high limit for method A, below low limit for method B
double ProductivityNullFactor=1.0;    // multiplicative factor if between high/low limits
double ProductivityLowFactor=0.5;     // multiplicative factor if below low limit for method A, above high limit for method B

//===================================================================================================
//===================================================================================================

#include "TheOneSupport/Mini/TheOneMiniSpecsParameters.mqh"
#include "TheOneSupport/TheOneEngineVegas.mqh"
#include "TheOneSupport/TheOneEngineRSIScalp.mqh"
#include "TheOneSupport/TheOneEngineMAStochRSI.mqh"
#include "TheOneSupport/TheOneEnginePSARASC.mqh"
#include "TheOneSupport/TheOneEnginePMI30.mqh"
#include "TheOneSupport/TheOneEnginePMI60.mqh"
#include "TheOneSupport/TheOneEngineADXTrend.mqh"
#include "TheOneSupport/TheOneEngineHighProb4.mqh"
#include "TheOneSupport/TheOneDetermineTrend.mqh"
#include "TheOneSupport/TheOneUtilities.mqh"
#include "TheOneSupport/TheOneFilter.mqh"


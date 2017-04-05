//+----------------------------------------------------------------------+
//|                                                           TheOne.mq4 |
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
// Toggles for Trading Models (true=active, false=inactive)

bool flag_Trend=true;                // Trend/No-Trend Mode
bool flag_FastSlow=true;             // Fast/Slow Mode
bool flag_Margin=true;               // Margin (true) vs. Fixed-Lots (false)

extern bool flag_SecretMA=true;      // Secret MA 
extern bool flag_MACD=true;          // MACD 
extern bool flag_10hrBO=true;        // 10hrBO 
extern bool flag_10dayBO=true;       // 10dayBO 
extern bool flag_Safety=true;        // Safety 
extern bool flag_Safety2=true;       // Safety2 
extern bool flag_Safety3=true;       // Safety3 
extern bool flag_Reversal=true;      // Reversal 
extern bool flag_DoubleTops=true;    // DoubleTops 
extern bool flag_OsMA=true;          // OsMA 
extern bool flag_OsMA2=true;         // OsMA2 
extern bool flag_30MinBO=true;       // 30 Minute Breakout 
extern bool flag_RSIScalp=true;      // RSI Scalper 
extern bool flag_RSI2=true;          // RSI2 
extern bool flag_DayReversal=true;   // Daily Reversal 
extern bool flag_HrPerpetual=true;   // Hourly Perpetual 
extern bool flag_MACDSwing=true;     // MACDSwing 
extern bool flag_MAScalp=true;       // MAScalp 
extern bool flag_Sentiment=true;     // Sentiment 
extern bool flag_ADXDay=true;        // ADXDay 
extern bool flag_MADoubleX=true;     // MADoubleX 
extern bool flag_OsMAHiLo=true;      // OsMAHiLo 
extern bool flag_BBScalp=true;       // BBScalp 
extern bool flag_MAStochRSI=true;    // MAStochRSI 
extern bool flag_RangeBO=true;       // RangeBO 
extern bool flag_Phoenix=true;       // Phoenix 
extern bool flag_ATRStopScalp=true;  // ATRStopScalp 
extern bool flag_RangeTight=true;    // RangeTight 
extern bool flag_RangeMid=true;      // RangeMid 
extern bool flag_KeltnerScalp=true;  // KeltnerScalp 
extern bool flag_Vegas=true;         // Vegas
extern bool flag_PSARASC=true;       // PSARASC
extern bool flag_EnvScalp1=true;     // EnvScalp1
extern bool flag_EnvScalp2=true;     // EnvScalp2
extern bool flag_EnvScalp3=true;     // EnvScalp3
extern bool flag_PMI30=true;         // PMI
extern bool flag_PMI60=true;         // PMI
extern bool flag_AweOsMA=true;       // AweOsMA
extern bool flag_RangeTightDay=true; // RangeTightDay
extern bool flag_ADXTrend=true;      // ADXTrend
extern bool flag_HighProb=true;      // HighProb H1
extern bool flag_HighProb4=true;     // HighProb H4
extern bool flag_StochADX=true;      // StochADX
extern bool flag_MiniShortI=true;   // Mini-Short Double Trouble I trades

extern bool flag_Bonus4SMA=true;     // Bonus4SMA 
extern bool flag_Bonus4Accel=true;   // Bonus4Accel 
extern bool flag_Bonus4Extreme=true; // Bonus4Extreme 
extern bool flag_Bonus4Doji=true;    // Bonus4Doji (Doji/Keltner Reversal) 
extern bool flag_Bonus4Daily=true;   // Bonus4Daily 

int  Display_Corner=0;        // 0=top left, 1=top right, 2=bottom left, 3=bottom right
color Display_Color=Black;    // color for Display Status labels

//Fixed Lots List: (fractional lots OK)
  
double Lots_fixed_MA1=0.30;                  // Secret MA 1
double Lots_fixed_MA2=0.30;                  // Secret MA 2
double Lots_fixed_MA3=0.30;                  // Secret MA 3
double Lots_fixed_MACD1=0.30;                // MACD 1
double Lots_fixed_MACD2=0.30;                // MACD 2
double Lots_fixed_10hrBO1=0.30;              // 10hrBO 1
double Lots_fixed_10hrBO2=0.30;              // 10hrBO 2
double Lots_fixed_10dayBO1=0.30;             // 10dayBO 1
double Lots_fixed_10dayBO2=0.30;             // 10dayBO 2
double Lots_fixed_Safety1=0.30;              // Safety 1
double Lots_fixed_Safety2=0.30;              // Safety 2
double Lots_fixed_Safety3=0.30;              // Safety 3
double Lots_fixed_Safety21=0.30;             // Safety2 1
double Lots_fixed_Safety22=0.30;             // Safety2 2
double Lots_fixed_Safety23=0.30;             // Safety2 3
double Lots_fixed_Safety31=0.30;             // Safety3 1
double Lots_fixed_Safety32=0.30;             // Safety3 2
double Lots_fixed_Safety33=0.30;             // Safety3 3
double Lots_fixed_Reversal1=0.30;            // Reversal 1
double Lots_fixed_Reversal2=0.30;            // Reversal 2
double Lots_fixed_Reversal3=0.30;            // Reversal 3
double Lots_fixed_Reversal4=0.30;            // Reversal 4
double Lots_fixed_DoubleTops1=0.30;          // DoubleTops 1
double Lots_fixed_DoubleTops2=0.30;          // DoubleTops 2
double Lots_fixed_DoubleTops3=0.30;          // DoubleTops 3
double Lots_fixed_OsMA11=0.30;               // OsMA1 pt 1
double Lots_fixed_OsMA12=0.30;               // OsMA1 pt 2
double Lots_fixed_OsMA21=0.30;               // OsMA2 1 pt 1 & 2
double Lots_fixed_OsMA22=0.30;               // OsMA2 2 pt 1 & 2
double Lots_fixed_OsMA23=0.30;               // OsMA2 3 pt 3
double Lots_fixed_30MinBO1=0.30;             // 30 MinBO 1
double Lots_fixed_30MinBO2=0.30;             // 30 MinBO 2
double Lots_fixed_30MinBO3=0.30;             // 30 MinBO 3
double Lots_fixed_RSIScalp1=0.10;            // RSI Scalper 1
double Lots_fixed_RSIScalp2=0.30;            // RSI Scalper 2
double Lots_fixed_RSIScalp3=0.30;            // RSI Scalper 3
double Lots_fixed_RSI21=0.30;                // RSI2 1
double Lots_fixed_RSI22=0.30;                // RSI2 2
double Lots_fixed_DayReversal1=0.30;         // DayReversal 1
double Lots_fixed_DayReversal2=0.30;         // DayReversal 2
double Lots_fixed_DayReversal3=0.30;         // DayReversal 3
double Lots_fixed_HrPerpetual1=0.30;         // HrPerpetual 1
double Lots_fixed_HrPerpetual2=0.30;         // HrPerpetual 2
double Lots_fixed_MACDSwing1=0.30;           // MACDSwing 1
double Lots_fixed_MACDSwing2=0.30;           // MACDSwing 2
double Lots_fixed_MACDSwing3=0.30;           // MACDSwing 3
double Lots_fixed_MAScalp1=0.30;             // MA Scalp 1
double Lots_fixed_MAScalp2=0.30;             // MA Scalp 2
double Lots_fixed_MAScalp3=0.30;             // MA Scalp 3
double Lots_fixed_Sentiment1=0.30;           // Sentiment 1
double Lots_fixed_Sentiment2=0.30;           // Sentiment 2
double Lots_fixed_Sentiment3=0.30;           // Sentiment 3
double Lots_fixed_ADXDay1=0.30;              // ADXDay 1
double Lots_fixed_ADXDay2=0.30;              // ADXDay 2
double Lots_fixed_ADXDay3=0.30;              // ADXDay 3
double Lots_fixed_MADoubleX1=0.30;           // MADoubleX 1
double Lots_fixed_MADoubleX2=0.30;           // MADoubleX 2
double Lots_fixed_MADoubleX3=0.30;           // MADoubleX 3
double Lots_fixed_OsMAHiLo1=0.30;            // OsMAHiLo 1
double Lots_fixed_OsMAHiLo2=0.30;            // OsMAHiLo 2
double Lots_fixed_BBScalp1=0.30;             // BBScalp 1
double Lots_fixed_BBScalp2=0.30;             // BBScalp 2
double Lots_fixed_MAStochRSI1=0.30;          // MAStochRSI 1
double Lots_fixed_MAStochRSI2=0.30;          // MAStochRSI 2
double Lots_fixed_MAStochRSI3=0.30;          // MAStochRSI 3
double Lots_fixed_RangeBO1=0.30;             // RangeBO 1
double Lots_fixed_RangeBO2=0.30;             // RangeBO 2
double Lots_fixed_RangeBO3=0.30;             // RangeBO 3 (X re-entry)
double Lots_fixed_RangeBO4=0.30;             // RangeBO 4 (X re-entry)
double Lots_fixed_Phoenix1=0.30;             // Phoenix 1
double Lots_fixed_Phoenix2=0.30;             // Phoenix 2
double Lots_fixed_ATRStopScalp1=0.30;        // ATRStopScalp 1
double Lots_fixed_ATRStopScalp2=0.30;        // ATRStopScalp 2
double Lots_fixed_ATRStopScalp3=0.30;        // ATRStopScalp 3
double Lots_fixed_ATRStopScalp4=0.30;        // ATRStopScalp 4
double Lots_fixed_ATRStopScalp5=0.30;        // ATRStopScalp 5 re-entry for 1,2,3 if hit initial stop
double Lots_fixed_RangeTight1=0.30;          // RangeTight 1
double Lots_fixed_RangeTight2=0.30;          // RangeTight 2
double Lots_fixed_RangeMid1=0.30;            // RangeMid 1
double Lots_fixed_RangeMid2=0.30;            // RangeMid 2
double Lots_fixed_KeltnerScalp1=0.30;        // KeltnerScalp 1 (pending)
double Lots_fixed_KeltnerScalp2=0.30;        // KeltnerScalp 2 (pending)
double Lots_fixed_KeltnerScalp3=0.30;        // KeltnerScalp 3 (market)
double Lots_fixed_Vegas1=0.30;               // Vegas 1
double Lots_fixed_Vegas2=0.30;               // Vegas 2
double Lots_fixed_Vegas3=0.30;               // Vegas 3
double Lots_fixed_Vegas4=0.30;               // Vegas 4
double Lots_fixed_PSARASC1=0.30;             // PSARASC 1
double Lots_fixed_EnvScalp11=0.30;           // EnvScalp1 1
double Lots_fixed_EnvScalp12=0.30;           // EnvScalp2 2
double Lots_fixed_EnvScalp21=0.30;           // EnvScalp2 1
double Lots_fixed_EnvScalp22=0.30;           // EnvScalp2 2
double Lots_fixed_EnvScalp31=0.30;           // EnvScalp3 1
double Lots_fixed_EnvScalp32=0.30;           // EnvScalp3 2
double Lots_fixed_PMI301=0.30;               // PMI30 1
double Lots_fixed_PMI302=0.30;               // PMI30 2
double Lots_fixed_PMI601=0.30;               // PMI60 1
double Lots_fixed_PMI602=0.30;               // PMI60 2
double Lots_fixed_AweOsMA1=0.30;             // AweOsMA 1
double Lots_fixed_AweOsMA2=0.30;             // AweOsMA 2
double Lots_fixed_RangeTightDay1=0.30;       // RangeTightDay 1
double Lots_fixed_RangeTightDay2=0.30;       // RangeTightDay 2
double Lots_fixed_ADXTrend1=0.30;            // ADXTrend 1
double Lots_fixed_ADXTrend2=0.30;            // ADXTrend 2
double Lots_fixed_ADXTrend3=0.30;            // ADXTrend 3
double Lots_fixed_HighProb1=0.30;            // HighProb 1
double Lots_fixed_HighProb2=0.30;            // HighProb 2
double Lots_fixed_HighProb3=0.30;            // HighProb 3
double Lots_fixed_HighProb41=0.30;           // HighProb4 1
double Lots_fixed_HighProb42=0.30;           // HighProb4 2
double Lots_fixed_HighProb43=0.30;           // HighProb4 3
double Lots_fixed_StochADX1=0.30;            // StochADX 1
double Lots_fixed_StochADX2=0.30;            // StochADX 2 
double Lots_fixed_MiniShortI1=0.30;          // Mini-Short Double Trouble I
double Lots_fixed_MiniShortI2=0.30;          // Mini-Short Double Trouble I

double Lots_fixed_Bonus4SMA=0.30;            // Bonus4SMA
double Lots_fixed_Bonus4Accel1=0.30;         // Bonus4Accel 1
double Lots_fixed_Bonus4Accel2=0.30;         // Bonus4Accel 2
double Lots_fixed_Bonus4Extreme1=0.30;       // Bonus4Extreme 1
double Lots_fixed_Bonus4Extreme2=0.30;       // Bonus4Extreme 2
double Lots_fixed_Bonus4Doji1=0.30;          // Bonus4Doji 1
double Lots_fixed_Bonus4Doji2=0.30;          // Bonus4Doji 2
double Lots_fixed_Bonus4Daily=0.30;          // Bonus4Daily

// Take Profit List:

int TakeProfit_MA1=390;              // Secret MA 1 
int TakeProfit_MA2=460;              // Secret MA 2 
int TakeProfit_MA3=0;                // Secret MA 3 
int TakeProfit_MACD1=250;            // MACD 1 
int TakeProfit_MACD2=370;            // MACD 2
int TakeProfit_10hrBO1=210;          // 10hrBO 1
int TakeProfit_10hrBO2=280;          // 10hrBO 2
int TakeProfit_10hrBOTrend1=360;     // 10hrBO Trend 1
int TakeProfit_10hrBOTrend2=420;     // 10hrBO Trend 2
int TakeProfit_10dayBO1=100;         // 10dayBO 1
int TakeProfit_10dayBO2=0;           // 10dayBO 2
int TakeProfit_Safety1=0;            // Safety 1
int TakeProfit_Safety2=0;            // Safety 2
int TakeProfit_Safety3=0;            // Safety 3
int TakeProfit_Safety21=0;           // Safety2 1
int TakeProfit_Safety22=100;         // Safety2 2
int TakeProfit_Safety23=0;           // Safety2 3
int TakeProfit_Safety31=0;           // Safety3 1
int TakeProfit_Safety32=100;         // Safety3 2
int TakeProfit_Safety33=0;           // Safety3 3
int TakeProfit_Reversal1=95;         // Reversal 1
int TakeProfit_Reversal2=320;        // Reversal 2
int TakeProfit_Reversal3=0;          // Reversal 3
int TakeProfit_Reversal4=0;          // Reversal 4
int TakeProfit_DoubleTops1=0;        // DoubleTops 1
int TakeProfit_DoubleTops2=200;      // DoubleTops 2
int TakeProfit_DoubleTops3=0;        // DoubleTops 3
int TakeProfit_OsMA11=190;           // OsMA1 pt 1
int TakeProfit_OsMA12=270;           // OsMA1 pt 2
int TakeProfit_OsMA21=140;           // OsMA2 1 pt 1 & 2 
int TakeProfit_OsMA22=140;           // OsMA2 2 pt 1 & 2
int TakeProfit_OsMA23=140;           // OsMA2 3
int TakeProfit_30MinBO1=190;         // 30 MinBO 1
int TakeProfit_30MinBO2=240;         // 30 MinBO 2
int TakeProfit_30MinBO3=290;         // 30 MinBO 3
int TakeProfit_30MinBOTrend1=220;    // 30 MinBO Trend 1
int TakeProfit_30MinBOTrend2=290;    // 30 MinBO Trend 2
int TakeProfit_30MinBOTrend3=350;    // 30 MinBO Trend 3
int TakeProfit_RSIScalp1=0;          // RSI Scalper 1 
int TakeProfit_RSIScalp2=410;        // RSI Scalper 2
int TakeProfit_RSIScalp3=410;        // RSI Scalper 3
int TakeProfit_RSI21=210;            // RSI2 1
int TakeProfit_RSI22=370;            // RSI2 2
int TakeProfit_DayReversal1=120;     // DayReversal 1
int TakeProfit_DayReversal2=240;     // DayReversal 2
int TakeProfit_DayReversal3=400;       // DayReversal 3
int TakeProfit_HrPerpetual1=460;     // HrPerpetual 1
int TakeProfit_HrPerpetual2=0;       // HrPerpetual 2
int TakeProfit_MACDSwing1=120;       // MACDSwing 1 
int TakeProfit_MACDSwing2=300;       // MACDSwing 2
int TakeProfit_MACDSwing3=500;       // MACDSwing 3
int TakeProfit_MAScalp1=190;         // MAScalp 1 
int TakeProfit_MAScalp2=260;         // MAScalp 2
int TakeProfit_MAScalp3=350;         // MAScalp 3
int TakeProfit_MAScalpTrend1=250;    // MAScalp Trend 1 
int TakeProfit_MAScalpTrend2=300;    // MAScalp Trend 2
int TakeProfit_MAScalpTrend3=350;    // MAScalp Trend 3
int TakeProfit_Sentiment1=500;         // Sentiment 1 
int TakeProfit_Sentiment2=600;         // Sentiment 2
int TakeProfit_Sentiment3=400;         // Sentiment 3
int TakeProfit_ADXDay1=110;          // ADXDay 1 
int TakeProfit_ADXDay2=290;          // ADXDay 2
int TakeProfit_ADXDay3=0;            // ADXDay 3
int TakeProfit_MADoubleX1=90;        // MADoubleX 1 
int TakeProfit_MADoubleX2=170;       // MADoubleX 2
int TakeProfit_MADoubleX3=170;       // MADoubleX 3
int TakeProfit_OsMAHiLo1=0;          // OsMAHiLo 1 
int TakeProfit_OsMAHiLo2=0;          // OsMAHiLo 2
int TakeProfit_BBScalp1=45;          // BBScalp 1 
int TakeProfit_BBScalp2=0;           // BBScalp 2
int TakeProfit_MAStochRSI1=100;      // MAStochRSI 1 
int TakeProfit_MAStochRSI2=120;      // MAStochRSI 2
int TakeProfit_MAStochRSI3=150;      // MAStochRSI 3
int TakeProfit_RangeBO1=80;          // RangeBO 1 
int TakeProfit_RangeBO2=80;          // RangeBO 2
int TakeProfit_RangeBO3=80;          // RangeBO 3 (X reverse) 
int TakeProfit_RangeBO4=80;          // RangeBO 4 (X reverse)
int TakeProfit_Phoenix1=68;          // Phoenix 1 
int TakeProfit_Phoenix2=83;          // Phoenix 2
int TakeProfit_ATRStopScalp1=50;     // ATRStopScalp 1 
int TakeProfit_ATRStopScalp2=120;    // ATRStopScalp 2
int TakeProfit_ATRStopScalp3=140;    // ATRStopScalp 3
int TakeProfit_ATRStopScalp4=20;     // ATRStopScalp 4
int TakeProfit_ATRStopScalp5=110;    // ATRStopScalp 5 re-entry for 1,2,3 if hit initial stop
int TakeProfit_RangeTight1=0;        // RangeTight 1 
int TakeProfit_RangeTight2=0;        // RangeTight 2
int TakeProfit_RangeMid1=95;         // RangeMid 1 
int TakeProfit_RangeMid2=160;        // RangeMid 2
int TakeProfit_KeltnerScalp1=44;     // KeltnerScalp 1 (pending)
int TakeProfit_KeltnerScalp2=60;     // KeltnerScalp 2 (pending)
int TakeProfit_KeltnerScalp3=80;     // KeltnerScalp 3 (market)
int TakeProfit_Vegas1=135;           // Vegas 1 
int TakeProfit_Vegas2=0;             // Vegas 2
int TakeProfit_Vegas3=150;           // Vegas 3
int TakeProfit_Vegas4=300;           // Vegas 4
int TakeProfit_PSARASC1=250;         // PSARASC 1 
int TakeProfit_EnvScalp11=100;       // EnvScalp1 1 
int TakeProfit_EnvScalp12A=0;        // EnvScalp1 2 (when on correct side of Envelope)
int TakeProfit_EnvScalp12B=45;       // EnvScalp1 2 (when on wrong side of Envelope or not profitable when Envelope is breached)
int TakeProfit_EnvScalp21=145;       // EnvScalp2 1 
int TakeProfit_EnvScalp22=195;       // EnvScalp2 2
int TakeProfit_EnvScalp31=80;        // EnvScalp3 1 
int TakeProfit_EnvScalp32=140;       // EnvScalp3 2
int TakeProfit_PMI301=85;            // PMI30 1 
int TakeProfit_PMI302=170;           // PMI30 2
int TakeProfit_PMI601=125;           // PMI60 1 
int TakeProfit_PMI602=190;           // PMI60 2
int TakeProfit_AweOsMA1=40;          // AweOsMA 1 
int TakeProfit_AweOsMA2=100;         // AweOsMA 2
int TakeProfit_RangeTightDay1=110;   // RangeTightDay 1 
int TakeProfit_RangeTightDay2=110;   // RangeTightDay 2
int TakeProfit_ADXTrend1=120;        // ADXTrend 1 
int TakeProfit_ADXTrend2=400;        // ADXTrend 2
int TakeProfit_ADXTrend3=999;        // ADXTrend 3
int TakeProfit_HighProb1=0;          // HighProb 1 
int TakeProfit_HighProb2=400;        // HighProb 2
int TakeProfit_HighProb3=400;        // HighProb 3
int TakeProfit_HighProb41=0;         // HighProb4 1 
int TakeProfit_HighProb42=400;       // HighProb4 2
int TakeProfit_HighProb43=800;       // HighProb4 3
int TakeProfit_StochADX1=140;        // StochADX 1
int TakeProfit_StochADX2=210;        // StochADX 2
int TakeProfit_MiniShortI1=100;      // Mini-Short Double Trouble I
int TakeProfit_MiniShortI2=200;      // Mini-Short Double Trouble I

int TakeProfit_Bonus4SMA=450;        // Bonus4SMA
int TakeProfit_Bonus4Accel1=250;     // Bonus4Accel 1
int TakeProfit_Bonus4Accel2=325;     // Bonus4Accel 2
int TakeProfit_Bonus4Extreme1=290;   // Bonus4Extreme 1
int TakeProfit_Bonus4Extreme2=390;   // Bonus4Extreme 2
int TakeProfit_Bonus4Doji1=250;      // Bonus4Doji 1
int TakeProfit_Bonus4Doji2=350;      // Bonus4Doji 2
int TakeProfit_Bonus4Daily=0;        // Bonus4Daily


// Stop Loss List: (initial stop-losses submitted with triggered order)
//  No-greater-than stop losses are designated with "MAX," associated with methods using stop-losses behind previous highs/lows.
//  For these methods, using a StopLoss value of zero will make the actual stop-loss truly ZERO.

int StopLoss_MA=65; //(for lot 2 only) //  Secret MA 

int StopLoss_MACD=100;                 //  MACD

int StopLoss_10hrBO=5;                //  10hrBO (from support/resistance)
int StopLossMAX_10hrBO=55;            //  10hrBO 

int StopLoss_10hrBOTrend=15;          //  10hrBO Trend (above high / below low)
int StopLossMAX_10hrBOTrend=80;       //  10hrBO Trend 

int StopLoss_10dayBO=10;              //  10dayBO (above high / below low)
int StopLossMAX_10dayBO=150;          //  10dayBO 

int StopLossMAX_Safety=50;            //  Safety 
int StopLossMAX_Safety2=50;           //  Safety2 
int StopLossMAX_Safety3=60;           //  Safety3

int StopLossMAX_Reversal=44;          //  Reversal

int StopLoss_DoubleTops=80;           //  DoubleTops (above high / below low)
int StopLossMAX_DoubleTops=140;       //  DoubleTops

int StopLoss_OsMA=40;                 //  OsMA
int StopLoss_OsMA2=45;                //  OsMA2

int StopLoss_30MinBO=15;              //  30MinBO (behind SMA(20))
int StopLoss_30MinBOTrend=40;         //  30MinBO Trend (behind SMA(20))
int StopLossMAX_30MinBO=50;           //  30MinBO

int StopLossMAX_RSIScalp=50;          //  RSI Scalper 

int StopLoss_RSI21=55;                //  RSI2 (Order 1 Pending)
int StopLoss_RSI22=45;                //  RSI2 (Order 2 Market)

int StopLossMAX_DayReversal=95;       //  DayReversal 

int StopLoss_HrPerpetual=70;          //  Hourly Perpetual
int StopLossMAX_MACDSwing=80;         //  MACDSwing

int StopLoss_MAScalp=37;              //  MAScalp
int StopLoss_MAScalpTrend=45;         //  MAScalp Trend

int StopLoss_Sentiment1=65;           //  Sentiment (Order 1 Pending)
int StopLoss_Sentiment2=70;           //  Sentiment (Order 2 Market)
int StopLoss_Sentiment3=70;           //  Sentiment (Order 3 Market subsequent ASC trigger)

int StopLoss_ADXDay=260;              //  ADXDay

int StopLoss_MADoubleX=60;            //  MADoubleX

int StopLossMAX_OsMAHiLo=50;          //  OsMAHiLo (Max, compared with PSAR)

int StopLoss_BBScalp=35;              //  BBScalp

int StopLoss_MAStochRSI=32;           //  MAStochRSI

int StopLoss_RangeBO=35;              //  RangeBO (from support/resistance)
int StopLossMIN_RangeBO=60;           // RangeBO

int StopLoss_Phoenix1=50;             //  Phoenix 1
int StopLoss_Phoenix2=40;             //  Phoenix 2 (from pending price)

int StopLoss_ATRStopScalp=40;         //  ATRStopScalp 1, 2, 3
int StopLoss_ATRStopScalp4=35;        //  ATRStopScalp 4 
int StopLoss_ATRStopScalp5=50;        //  ATRStopScalp 5 re-entry orders (Orders 1,2,3 if hit initial stop) 

int StopLoss_RangeTight=40;           //  RangeTight 1, 2 (non-Trends)

int StopLoss_RangeMid=44;             //  RangeMid
int StopLossMAX_RangeMid=55;          //  Maximum s/l for RangeMid

int StopLoss_KeltnerScalp=40;         //  KeltnerScalp 1, 2 (Pending)
int StopLoss_KeltnerScalp3=40;        //  KeltnerScalp 3 (Market)

int StopLoss_Bonus4SMA=100;           //  Bonus4SMA 

int StopLoss_Bonus4Accel=5;           //  Bonus4Accel 1 & 2, (above high/ below low)
int StopLossMAX_Bonus4Accel=60;       //  Bonus4Accel 1 & 2, 

int StopLoss_Bonus4Extreme=15;        //  Bonus4Extreme 1, 2 (above high/ below low)
int StopLossMAX_Bonus4Extreme=50;     //  Bonus4Extreme 1, 2

int StopLoss_Bonus4Doji=50;           //  Bonus4Doji 1, 2 (above/below dogistar)
int StopLoss_Bonus4Daily=120;         //  Bonus4Daily

int StopLoss_Vegas=45;                //  Vegas 1,2,3,4
int StopLoss_PSARASC=50;              //  PSARASC 1
int StopLoss_EnvScalp1=125;           //  EnvScalp1 1,2
int StopLoss_EnvScalp2=40;            //  EnvScalp2 1,2
int StopLoss_EnvScalp3=45;            //  EnvScalp3 1,2
int StopLoss_PMI30=35;                //  PMI30 1,2
int StopLoss_PMI60=45;                //  PMI60 1,2
int StopLoss_AweOsMA=45;              //  AweOsMA 1,2
int StopLoss_RangeTightDay=70;        //  RangeTightDay 1,2
int StopLoss_ADXTrend=180;            //  ADXTrend 1,2,3
int StopLoss_HighProb=150;            //  HighProb 1,2,3
int StopLoss_HighProb4=150;           //  HighProb4 1,2,3

int StopLoss_MiniShortI=15;           // Mini-Short Double Trouble I (above high/below low)
int StopLossMAX_MiniShortI=55;      // pips MAXIMUM stop loss for Mini-Short Double Trouble I 

int StopLoss_StochADX1=55;          // StochADX 1 (market immediate)
int StopLoss_StochADX2=55;          // StochADX 2 (market immediate) 
int StopLoss_StochADX3=45;          // StochADX 3 (market delayed) 

// Trailing Stop List:
//  TrailingStop = post-fixed stop trail 
//  Minimum allowable trail = 10 pips.  If accidentally set to less than 10, a trail of 1000 pips will be used by default.

//int TrailingStop_Lot1_MA=0;        //  Secret MA 1
int TrailingStop_Lot2_MA=100;        //  Secret MA 2
//int TrailingStop_Lot3_MA=0;        //  Secret MA 3
int TrailingStopA_MACD=55;           //  MACD (pre-FS) 1, 2
int TrailingStop_MACD1=70;           //  MACD 1
int TrailingStop_MACD2=70;           //  MACD 2
int TrailingStop_10hrBO1=52;         //  10hrBO 1
int TrailingStop_10hrBO2=70;         //  10hrBO 2
//int TrailingStop_10dayBO=0;        //  10dayBO (NOT USED)
int TrailingStop_Safety1=35;         //  Safety 1
int TrailingStop_Safety2=42;         //  Safety 2
int TrailingStop_Safety3=60;         //  Safety 3
//int TrailingStop_Safety21=0;       //  Safety2 1 (NOT USED)
int TrailingStop_Safety22=60;        //  Safety2 2
int TrailingStop_Safety23=70;        //  Safety2 3
//int TrailingStop_Safety31=0;       //  Safety3 1 (NOT USED)
//int TrailingStop_Safety32=0;       //  Safety3 2 (NOT USED)
int TrailingStop_Safety33=70;        //  Safety3 3
int TrailingStop_Reversal1=50;       //  Reversal 1
int TrailingStop_Reversal2=50;       //  Reversal 2
int TrailingStop_Reversal3=50;      //  Reversal 3
int TrailingStop_Reversal4=40;      //  Reversal 4
//int TrailingStop_DoubleTops=0;     //  DoubleTops (NOT USED)
int TrailingStop_OsMA11=60;          //  OsMA1 pt 1
int TrailingStop_OsMA12=70;          //  OsMA1 pt 2
int TrailingStop_OsMA21=60;          //  OsMA2 1 pt 1 & 2
int TrailingStop_OsMA22=60;          //  OsMA2 2 pt 1 & 2
int TrailingStop_OsMA23=60;          //  OsMA2 3
int TrailingStop_30MinBO1=52;        //  30 MinBO 1
int TrailingStop_30MinBO2=70;        //  30 MinBO 2
int TrailingStop_30MinBO3=78;        //  30 MinBO 3
int TrailingStop_RSIScalp1=55;       //  RSIScalp 1
int TrailingStop_RSIScalp2=65;       //  RSIScalp 2
int TrailingStop_RSIScalp3=50;       //  RSIScalp 3
int TrailingStop_RSI21=50;           //  RSI2 1
int TrailingStop_RSI22=70;           //  RSI2 2
//int TrailingStop_DayReversal=0;    //  DayReversal (NOT USED)
int TrailingStop_HrPerpetual1=90;    //  HrPerpetual 1
int TrailingStop_HrPerpetual2=220;  //  HrPerpetual 2
//int TrailingStop_MACDSwing1=0;     //  MACDSwing 1 (NOT USED)
//int TrailingStop_MACDSwing2=0;     //  MACDSwing 2 (NOT USED)
int TrailingStop_MACDSwing3=80;      //  MACDSwing 3
int TrailingStop_MAScalp1=60;        //  MAScalp 1
int TrailingStop_MAScalp2=70;        //  MAScalp 2
int TrailingStop_MAScalp3=80;        //  MAScalp 3
int TrailingStop_Sentiment1=90;      //  Sentiment 1
int TrailingStop_Sentiment2=220;    //  Sentiment 2
int TrailingStop_Sentiment3=90;    //  Sentiment 3
int TrailingStop_ADXDay1=140;        //  ADXDay 1
int TrailingStop_ADXDay2=180;        //  ADXDay 2
//int TrailingStop_ADXDay3=0;        //  ADXDay 3 (NOT USED)
int TrailingStop_MADoubleX1=50;      //  MADoubleX 1
int TrailingStop_MADoubleX2=70;      //  MADoubleX 2
int TrailingStop_MADoubleX3=70;      //  MADoubleX 3
int TrailingStop_OsMAHiLo1=42;       //  OsMAHiLo 1
int TrailingStop_OsMAHiLo2=50;       //  OsMAHiLo 2
//int TrailingStop_BBScalp1=0;       //  BBScalp 1 (NOT USED)
//int TrailingStop_BBScalp2=0;       //  BBScalp 2 (NOT USED)
//int TrailingStop_MAStochRSI1=0;    //  MAStochRSI 1
//int TrailingStop_MAStochRSI2=0;    //  MAStochRSI 2
//int TrailingStop_MAStochRSI3=0;    //  MAStochRSI 3
//int TrailingStop_RangeBO1=0;       //  RangeBO 1 (NOT USED)
//int TrailingStop_RangeBO2=0;       //  RangeBO 2 (NOT USED)
int TrailingStop_RangeBO3=30;        //  RangeBO 3
int TrailingStop_RangeBO4=40;        //  RangeBO 4
int TrailingStop_Phoenix1=70;        //  Phoenix 1
int TrailingStop_Phoenix2=60;        //  Phoenix 2
int TrailingStop_ATRStopScalp1=50;   //  ATRStopScalp 1
int TrailingStop_ATRStopScalp2=50;   //  ATRStopScalp 2
int TrailingStop_ATRStopScalp3=60;   //  ATRStopScalp 3
int TrailingStop_ATRStopScalp4=20;   //  ATRStopScalp 4
int TrailingStop_ATRStopScalp5=70;   //  ATRStopScalp 5 re-entry for 1,2,3 if hit initial stop
int TrailingStop_RangeTight1=35;     //  RangeTight 1
int TrailingStop_RangeTight2=50;     //  RangeTight 2
int TrailingStop_RangeMid1=60;       //  RangeMid 1
int TrailingStop_RangeMid2=70;       //  RangeMid 2
int TrailingStop_KeltnerScalp1=50;   //  KeltnerScalp 1
int TrailingStop_KeltnerScalp2=60;   //  KeltnerScalp 2
//int TrailingStop_KeltnerScalp3=0;  //  KeltnerScalp 3 (NOT USED)
int TrailingStop_Vegas1=60;         //  Vegas 1
int TrailingStop_Vegas2=70;         //  Vegas 2
int TrailingStop_Vegas3=70;         //  Vegas 3
int TrailingStop_Vegas4=80;         //  Vegas 4
//int TrailingStop_PSARASC1=1000;       //  PSARASC 1
int TrailingStop_EnvScalp11=40;     //  EnvScalp1 1
int TrailingStop_EnvScalp12=50;     //  EnvScalp1 2
int TrailingStop_EnvScalp21=50;     //  EnvScalp2 1
int TrailingStop_EnvScalp22=70;     //  EnvScalp2 2
int TrailingStop_EnvScalp31=60;     //  EnvScalp3 1
int TrailingStop_EnvScalp32=70;     //  EnvScalp3 2
int TrailingStop_PMI301=60;           //  PMI30 1
int TrailingStop_PMI302=70;           //  PMI30 2
int TrailingStop_PMI601=60;           //  PMI60 1
int TrailingStop_PMI602=70;           //  PMI60 2
int TrailingStop_AweOsMA1=50;       //  AweOsMA 1
int TrailingStop_AweOsMA2=60;       //  AweOsMA 2
int TrailingStop_RangeTightDay1=100; //  RangeTightDay 1
int TrailingStop_RangeTightDay2=100; //  RangeTightDay 2
int TrailingStop_ADXTrend1=60;      //  ADXTrend 1
int TrailingStop_ADXTrend2=130;      //  ADXTrend 2
int TrailingStop_ADXTrend3=300;      //  ADXTrend 3
//int TrailingStop_HighProb1=0;      //  HighProb 1
int TrailingStop_HighProb2=70;      //  HighProb 2
int TrailingStop_HighProb3=70;      //  HighProb 3
//int TrailingStop_HighProb41=0;      //  HighProb4 1
int TrailingStop_HighProb42=90;      //  HighProb4 2
int TrailingStop_HighProb43=270;      //  HighProb4 3
int TrailingStop_StochADX1=60;       // StochADX 1 
int TrailingStop_StochADX2=70;       // StochADX 2 
int TrailingStop_MiniShortI1=35;      // Mini-Short Double Trouble I 
int TrailingStop_MiniShortI2=55;      // Mini-Short Double Trouble I 

int TrailingStop_Bonus4SMA=90;       //  Bonus4SMA 1 (mimics Safety 3)
int TrailingStop_Bonus4Accel2=70;    //  Bonus4Accel 2
int TrailingStop_Bonus4Extreme1=70;  //  Bonus4Extreme 1
int TrailingStop_Bonus4Extreme2=80;  //  Bonus4Extreme 2
int TrailingStop_Bonus4Doji1=70;     //  Bonus4Doji 1 
int TrailingStop_Bonus4Doji2=70;     //  Bonus4Doji 2 
//int TrailingStop_Bonus4Daily=0;    //  Bonus4Daily (NOT USED)

// Dynamic Start List

int DynamicTrailMinimum=20;          // pips minimum dynamic trail (universally smallest dynamic trail achieveable)

//int DynamicStart_Lot1_MA=0;        // Secret MA 1
int DynamicStart_Lot2_MA=160;        // Secret MA 2
//int DynamicStart_Lot3_MA=0;        // Secret MA 3
int DynamicStart_MACD1=110;          // MACD 1
int DynamicStart_MACD2=250;          // MACD 2
int DynamicStart_10hrBO1=155;        // 10hrBO 1
int DynamicStart_10hrBO2=195;        // 10hrBO 2
//int DynamicStart_10dayBO=0;        // 10dayBO (NOT USED)
int DynamicStart_Safety1=70;         // Safety 1
int DynamicStart_Safety2=70;         // Safety 2
int DynamicStart_Safety3=70;         // Safety 3
//int DynamicStart_Safety21=0;       // Safety2 1 (NOT USED)
int DynamicStart_Safety22=70;        // Safety2 2
int DynamicStart_Safety23=70;        // Safety2 3
//int DynamicStart_Safety31=0;       // Safety3 1 (NOT USED)
//int DynamicStart_Safety32=0;       // Safety3 2 (NOT USED)
int DynamicStart_Safety33=70;        // Safety3 3
int DynamicStart_Reversal1=70;       // Reversal 1
int DynamicStart_Reversal2=210;      // Reversal 2
int DynamicStart_Reversal3=100;      // Reversal 3
int DynamicStart_Reversal4=200;      // Reversal 4
//int DynamicStart_DoubleTops=0;     // DoubleTops (NOT USED)
int DynamicStart_OsMA11=100;         // OsMA pt 1
int DynamicStart_OsMA12=190;         // OsMA pt 2
int DynamicStart_OsMA21=70;         // OsMA2 1 pt 1 & 2
int DynamicStart_OsMA22=70;         // OsMA2 2 pt 1 & 2
int DynamicStart_OsMA23=70;         // OsMA2 3
int DynamicStart_30MinBO1=145;       // 30MinBO 1
int DynamicStart_30MinBO2=180;       // 30MinBO 2
int DynamicStart_30MinBO3=220;       // 30MinBO 3
int DynamicStart_RSIScalp1=160;      // RSIScalp 1
int DynamicStart_RSIScalp2=265;      // RSIScalp 2
int DynamicStart_RSIScalp3=265;      // RSIScalp 3
int DynamicStart_RSI21=115;          // RSI2 1
int DynamicStart_RSI22=230;          // RSI2 2
//int DynamicStart_DayReversal=0;    // DayReversal (NOT USED)
int DynamicStart_HrPerpetual1=320;   // HrPerpetual 1
int DynamicStart_HrPerpetual2=320;     // HrPerpetual 2
//int DynamicStart_MACDSwing1=0      // MACDSwing 1 (NOT USED)
//int DynamicStart_MACDSwing2=0;     // MACDSwing 2 (NOT USED)
int DynamicStart_MACDSwing3=280;     // MACDSwing 3
int DynamicStart_MAScalp1=80;       // MAScalp 1
int DynamicStart_MAScalp2=150;       // MAScalp 2
int DynamicStart_MAScalp3=200;       // MAScalp 3
int DynamicStart_Sentiment1=500;     // Sentiment 1
int DynamicStart_Sentiment2=250;     // Sentiment 2
int DynamicStart_Sentiment3=250;     // Sentiment 3
int DynamicStart_ADXDay1=100;        // ADXDay 1
int DynamicStart_ADXDay2=200;        // ADXDay 2
//int DynamicStart_ADXDay3=0;        // ADXDay 3 (NOT USED)
int DynamicStart_MADoubleX1=55;      // MADoubleX 1
int DynamicStart_MADoubleX2=130;     // MADoubleX 2 
int DynamicStart_MADoubleX3=130;     // MADoubleX 3 
int DynamicStart_OsMAHiLo1=60;       // OsMAHiLo 1
int DynamicStart_OsMAHiLo2=120;      // OsMAHiLo 2 
//int DynamicStart_BBScalp1=0;       // BBScalp 1 (NOT USED)
//int DynamicStart_BBScalp2=0;       // BBScalp 2 (NOT USED)
//int DynamicStart_MAStochRSI1=0;    // MAStochRSI 1
//int DynamicStart_MAStochRSI2=0;    // MAStochRSI 2
//int DynamicStart_MAStochRSI3=0;    // MAStochRSI 3
//int DynamicStart_RangeBO1=0;       // RangeBO 1 (NOT USED)
//int DynamicStart_RangeBO2=0;       // RangeBO 2 (NOT USED)
int DynamicStart_RangeBO3=60;        // RangeBO 3
int DynamicStart_RangeBO4=60;        // RangeBO 4
int DynamicStart_Phoenix1=72;        // Phoenix 1
int DynamicStart_Phoenix2=70;        // Phoenix 2
int DynamicStart_ATRStopScalp1=140;  // ATRStopScalp 1
int DynamicStart_ATRStopScalp2=200;  // ATRStopScalp 2
int DynamicStart_ATRStopScalp3=290;  // ATRStopScalp 3
int DynamicStart_ATRStopScalp4=290;  // ATRStopScalp 4
int DynamicStart_ATRStopScalp5=80;   // ATRStopScalp 5 re-entry for 1,2,3 if hit initial stop
int DynamicStart_RangeTight1=52;     // RangeTight 1
int DynamicStart_RangeTight2=50;     // RangeTight 2
int DynamicStart_RangeMid1=72;       // RangeMid 1
int DynamicStart_RangeMid2=100;      // RangeMid 2
int DynamicStart_KeltnerScalp1=42;   // KeltnerScalp 1
int DynamicStart_KeltnerScalp2=40;   // KeltnerScalp 2
//int DynamicStart_KeltnerScalp3=0;  // KeltnerScalp 3 (NOT USED)
int DynamicStart_Vegas1=50;          // Vegas 1
int DynamicStart_Vegas2=100;         // Vegas 2
int DynamicStart_Vegas3=100;         // Vegas 3
int DynamicStart_Vegas4=200;         // Vegas 4
//int DynamicStart_PSARASC1=50;        // PSARASC 1
int DynamicStart_EnvScalp11=60;      // EnvScalp1 1
int DynamicStart_EnvScalp12=100;     // EnvScalp1 2
int DynamicStart_EnvScalp21=90;      // EnvScalp2 1
int DynamicStart_EnvScalp22=120;     // EnvScalp2 2
int DynamicStart_EnvScalp31=50;      // EnvScalp3 1
int DynamicStart_EnvScalp32=100;     // EnvScalp3 2
int DynamicStart_PMI301=50;            // PMI30 1
int DynamicStart_PMI302=100;           // PMI30 2
int DynamicStart_PMI601=70;            // PMI60 1
int DynamicStart_PMI602=110;           // PMI60 2
int DynamicStart_AweOsMA1=50;        // AweOsMA 1
int DynamicStart_AweOsMA2=100;       // AweOsMA 2
int DynamicStart_RangeTightDay1=100;  // RangeTightDay 1
int DynamicStart_RangeTightDay2=100; // RangeTightDay 2
int DynamicStart_ADXTrend1=60;       // ADXTrend 1
int DynamicStart_ADXTrend2=240;      // ADXTrend 2
int DynamicStart_ADXTrend3=250;      // ADXTrend 3
//int DynamicStart_HighProb1=0;       // HighProb 1
int DynamicStart_HighProb2=150;      // HighProb 2
int DynamicStart_HighProb3=150;      // HighProb 3
//int DynamicStart_HighProb41=0;       // HighProb4 1
int DynamicStart_HighProb42=150;      // HighProb4 2
int DynamicStart_HighProb43=250;      // HighProb4 3
int DynamicStart_StochADX1=80;       // StochADX 1 
int DynamicStart_StochADX2=120;       // StochADX 2 
int DynamicStart_MiniShortI1=50;      // Mini-Short Double Trouble I
int DynamicStart_MiniShortI2=120;      // Mini-Short Double Trouble I

int DynamicStart_Bonus4SMA=300;      // Bonus4SMA (mimics Safety 3)
int DynamicStart_Bonus4Accel2=220;   // Bonus4Accel 2
int DynamicStart_Bonus4Extreme1=180; // Bonus4Extreme 1
int DynamicStart_Bonus4Extreme2=230; // Bonus4Extreme 2
int DynamicStart_Bonus4Doji1=210;    // Bonus4Doji 1
int DynamicStart_Bonus4Doji2=265;    // Bonus4Doji 2

// Dynamic Ratio List (distance in pips traveled vs. distance trail is shortened)

//int DynamicRatio_Lot1_MA=0;           // Secret MA 1
int DynamicRatio_Lot2_MA=2;           // Secret MA 2
//int DynamicRatio_Lot3_MA=0;           // Secret MA 3
int DynamicRatio_MACD1=1;             // MACD 1
int DynamicRatio_MACD2=2;             // MACD 2 
int DynamicRatio_10hrBO1=1;           // 10hrBO 1
int DynamicRatio_10hrBO2=1;           // 10hrBO 2
//int DynamicRatio_10dayBO=0;         // 10dayBO (NOT USED)
int DynamicRatio_Safety1=1;           // Safety 1
int DynamicRatio_Safety2=2;           // Safety 2
int DynamicRatio_Safety3=2;           // Safety 3
//int DynamicRatio_Safety21=0;        // Safety2 1 (NOT USED)
int DynamicRatio_Safety22=2;          // Safety2 2
int DynamicRatio_Safety23=2;          // Safety2 3
//int DynamicRatio_Safety31=0;        // Safety3 1 (NOT USED)
//int DynamicRatio_Safety32=0;        // Safety3 2 (NOT USED)
int DynamicRatio_Safety33=2;          // Safety3 3
int DynamicRatio_Reversal1=1;         // Reversal 1
int DynamicRatio_Reversal2=1;         // Reversal 2
int DynamicRatio_Reversal3=1;         // Reversal 3
int DynamicRatio_Reversal4=1;         // Reversal 4
//int DynamicRatio_DoubleTops=0;      // DoubleTops (NOT USED)
int DynamicRatio_OsMA11=1;            // OsMA1 pt 1
int DynamicRatio_OsMA12=1;            // OsMA1 pt 2
int DynamicRatio_OsMA21=1;            // OsMA2 1 pt 1 & 2
int DynamicRatio_OsMA22=1;            // OsMA2 2 pt 1 & 2
int DynamicRatio_OsMA23=1;            // OsMA2 3
int DynamicRatio_30MinBO1=1;          // 30MinBO 1
int DynamicRatio_30MinBO2=1;          // 30MinBO 2
int DynamicRatio_30MinBO3=1;          // 30MinBO 3
int DynamicRatio_RSIScalp1=1;         // RSIScalp 1
int DynamicRatio_RSIScalp2=1;         // RSIScalp 2
int DynamicRatio_RSIScalp3=1;         // RSIScalp 3
int DynamicRatio_RSI21=1;             // RSI2 1
int DynamicRatio_RSI22=2;             // RSI2 2
//int DynamicRatio_DayReversal=0;     // DayReversal (NOT USED)
int DynamicRatio_HrPerpetual1=2;      // HrPerpetual 1
int DynamicRatio_HrPerpetual2=1;      // HrPerpetual 2
//int DynamicRatio_MACDSwing1=0;      // MACDSwing 1 (NOT USED)
//int DynamicRatio_MACDSwing2=0;      // MACDSwing 2 (NOT USED)
int DynamicRatio_MACDSwing3=2;        // MACDSwing 3 
int DynamicRatio_MAScalp1=1;          // MAScalp 1
int DynamicRatio_MAScalp2=1;          // MAScalp 2
int DynamicRatio_MAScalp3=2;          // MAScalp 3
int DynamicRatio_Sentiment1=1;        // Sentiment 1
int DynamicRatio_Sentiment2=2;        // Sentiment 2 
int DynamicRatio_Sentiment3=1;        // Sentiment 3 
int DynamicRatio_ADXDay1=1;           // ADXDay 1
int DynamicRatio_ADXDay2=1;           // ADXDay 2
//int DynamicRatio_ADXDay3=0;         // ADXDay 3 (NOT USED)
int DynamicRatio_MADoubleX1=1;        // MADoubleX 1
int DynamicRatio_MADoubleX2=1;        // MADoubleX 2
int DynamicRatio_MADoubleX3=1;        // MADoubleX 3
int DynamicRatio_OsMAHiLo1=1;         // OsMAHiLo 1
int DynamicRatio_OsMAHiLo2=1;         // OsMAHiLo 2
//int DynamicRatio_BBScalp1=0;        // BBScalp 1 (NOT USED)
//int DynamicRatio_BBScalp2=0;        // BBScalp 2 (NOT USED)
//int DynamicRatio_MAStochRSI1=0;       // MAStochRSI 1
//int DynamicRatio_MAStochRSI2=0;       // MAStochRSI 2
//int DynamicRatio_MAStochRSI3=0;       // MAStochRSI 3
//int DynamicRatio_RangeBO1=0;        // RangeBO 1 (NOT USED)
//int DynamicRatio_RangeBO2=0;        // RangeBO 2 (NOT USED)
int DynamicRatio_RangeBO3=1;          // RangeBO 3
int DynamicRatio_RangeBO4=1;          // RangeBO 4
int DynamicRatio_Phoenix1=1;          // Phoenix 1
int DynamicRatio_Phoenix2=1;          // Phoenix 2
int DynamicRatio_ATRStopScalp1=1;     // ATRStopScalp 1
int DynamicRatio_ATRStopScalp2=1;     // ATRStopScalp 2
int DynamicRatio_ATRStopScalp3=2;     // ATRStopScalp 3
int DynamicRatio_ATRStopScalp4=2;     // ATRStopScalp 4
int DynamicRatio_ATRStopScalp5=2;     // ATRStopScalp 5 re-entry for 1,2,3 if hit initial stop
int DynamicRatio_RangeTight1=1;       // RangeTight 1
int DynamicRatio_RangeTight2=1;       // RangeTight 2
int DynamicRatio_RangeMid1=1;         // RangeMid 1
int DynamicRatio_RangeMid2=1;         // RangeMid 2
int DynamicRatio_KeltnerScalp1=1;     // KeltnerScalp 1
int DynamicRatio_KeltnerScalp2=1;     // KeltnerScalp 2
//int DynamicRatio_KeltnerScalp3=1;   // KeltnerScalp 3 (NOT USED)
int DynamicRatio_Vegas1=2;            // Vegas 1
int DynamicRatio_Vegas2=2;            // Vegas 2
int DynamicRatio_Vegas3=2;            // Vegas 3
int DynamicRatio_Vegas4=2;            // Vegas 4
//int DynamicRatio_PSARASC1=2;          // PSARASC 1
int DynamicRatio_EnvScalp11=2;        // EnvScalp1 1
int DynamicRatio_EnvScalp12=2;        // EnvScalp1 2
int DynamicRatio_EnvScalp21=2;        // EnvScalp2 1
int DynamicRatio_EnvScalp22=2;        // EnvScalp2 2
int DynamicRatio_EnvScalp31=2;        // EnvScalp3 1
int DynamicRatio_EnvScalp32=2;        // EnvScalp3 2
int DynamicRatio_PMI301=1;              // PMI30 1
int DynamicRatio_PMI302=1;              // PMI30 2
int DynamicRatio_PMI601=1;              // PMI60 1
int DynamicRatio_PMI602=1;              // PMI60 2
int DynamicRatio_AweOsMA1=2;          // AweOsMA 1
int DynamicRatio_AweOsMA2=2;          // AweOsMA 2
int DynamicRatio_RangeTightDay1=2;    // RangeTightDay 1
int DynamicRatio_RangeTightDay2=2;    // RangeTightDay 2
int DynamicRatio_ADXTrend1=1;         // ADXTrend 1
int DynamicRatio_ADXTrend2=1;         // ADXTrend 2
int DynamicRatio_ADXTrend3=2;         // ADXTrend 3
//int DynamicRatio_HighProb1=0;         // HighProb 1
int DynamicRatio_HighProb2=1;         // HighProb 2
int DynamicRatio_HighProb3=1;         // HighProb 3
//int DynamicRatio_HighProb41=0;         // HighProb4 1
int DynamicRatio_HighProb42=1;         // HighProb4 2
int DynamicRatio_HighProb43=1;         // HighProb4 3
int DynamicRatio_StochADX1=1;       // StochADX 1 
int DynamicRatio_StochADX2=2;       // StochADX 2
int DynamicRatio_MiniShortI1=1;      // Mini-Short Double Trouble I
int DynamicRatio_MiniShortI2=1;      // Mini-Short Double Trouble I

int DynamicRatio_Bonus4SMA=2;         // Bonus4SMA (mimics Safety 3)
int DynamicRatio_Bonus4Accel2=1;      // Bonus4Accel 2
int DynamicRatio_Bonus4Extreme1=2;    // Bonus4Extreme 1
int DynamicRatio_Bonus4Extreme2=1;    // Bonus4Extreme 2
int DynamicRatio_Bonus4Doji1=1;       // Bonus4Doji 1
int DynamicRatio_Bonus4Doji2=2;       // Bonus4Doji 2

// Associated Fixed-Stops Parameters List:

 // SecretMA Lot 1
int ProfitPointFS_Lot1_MA1=40;         // pips PROFIT after which StopLossFS_Lot1_MA1 takes into effect for SecretMA Order 1
int StopLossFS_Lot1_MA1=1;             // pips stop loss for SecretMA after ProfitPointFS_Lot1_MA1 is hit
 // SecretMA Lot 2
int ProfitPointFS_Lot2_MA=32;          // pips PROFIT after which StopLossFS_Lot2_MA takes into effect for SecretMA Order 2
int StopLossFS_Lot2_MA=-5;             // pips stop loss for SecretMA after ProfitPointFS_Lot2_MA1 is hit
 // SecretMA Lot 3
int ProfitPointFS_Lot3_MA=50;          // pips PROFIT after which StopLossFS_Lot2_MA takes into effect for SecretMA Order 3
int StopLossFS_Lot3_MA=-2;              // pips stop loss for SecretMA after ProfitPointFS_Lot3_MA1 is hit

 // MACD
int ProfitPointFS_MACD=27;             // pips profit target after which to lock in LockProfitFS_MACD profits, order 2
int LockProfitFS_MACD=5;               // pips lock-in GAIN for MACD order 2 after ProfitPointFS_MACD is hit

 // 10hrBO Lot 1 (Non-TREND)
int ProfitPointFS_Lot1_10hrBO1=22;     // pips PROFIT after which LockProfitFS_Lot1_10hrBO1 takes into effect for 10hrBO Order 1
int LockProfitFS_Lot1_10hrBO1=2;       // pips lock-in GAIN for 10hrBO after ProfitPointFS_Lot1_10hrBO1 is hit
int ProfitPointFS_Lot1_10hrBO2=45;     // pips PROFIT after which LockProfitFS_Lot1_10hrBO2 takes into effect for 10hrBO Order 1
int LockProfitFS_Lot1_10hrBO2=5;       // pips lock-in GAIN for 10hrBO after ProfitPointFS_Lot1_10hrBO2 is hit
int ProfitPointFS_Lot1_10hrBO3=55;     // pips PROFIT after which LockProfitFS_Lot1_10hrBO3 takes into effect for 10hrBO Order 1
int LockProfitFS_Lot1_10hrBO3=10;      // pips lock-in GAIN for 10hrBO after ProfitPointFS_Lot1_10hrBO3 is hit
int ProfitPointFS_Lot1_10hrBO4=75;     // pips PROFIT after which LockProfitFS_Lot1_10hrBO4 takes into effect for 10hrBO Order 1
int LockProfitFS_Lot1_10hrBO4=25;      // pips lock-in GAIN for 10hrBO after ProfitPointFS_Lot1_10hrBO4 is hit
 // 10hrBO Lot 2 (Non-TREND)
int ProfitPointFS_Lot2_10hrBO1=35;     // pips PROFIT after which LockProfitFS_Lot2_10hrBO1 takes into effect for 10hrBO Order 2
int StopLossFS_Lot2_10hrBO1=15;      // pips stop loss for 10hrBO after ProfitPointFS_Lot2_10hrBO1 is hit
int ProfitPointFS_Lot2_10hrBO2=44;     // pips PROFIT after which LockProfitFS_Lot2_10hrBO2 takes into effect for 10hrBO Order 2
int LockProfitFS_Lot2_10hrBO2=4;       // pips lock-in GAIN for 10hrBO after ProfitPointFS_Lot2_10hrBO2 is hit
int ProfitPointFS_Lot2_10hrBO3=60;     // pips PROFIT after which LockProfitFS_Lot2_10hrBO3 takes into effect for 10hrBO Order 2
int LockProfitFS_Lot2_10hrBO3=15;      // pips lock-in GAIN for 10hrBO after ProfitPointFS_Lot2_10hrBO3 is hit
int ProfitPointFS_Lot2_10hrBO4=75;     // pips PROFIT after which LockProfitFS_Lot1_10hrBO4 takes into effect for 10hrBO Order 1
int LockProfitFS_Lot2_10hrBO4=25;      // pips lock-in GAIN for 10hrBO after ProfitPointFS_Lot1_10hrBO4 is hit
 // 10hrBO Lot 1 (TREND)
int ProfitPointFS_Lot1_10hrBO1TREND=22;     // pips PROFIT after which LockProfitFS_Lot1_10hrBO1 takes into effect for 10hrBO Order 1
int LockProfitFS_Lot1_10hrBO1TREND=2;       // pips lock-in GAIN for 10hrBO after ProfitPointFS_Lot1_10hrBO1 is hit
int ProfitPointFS_Lot1_10hrBO2TREND=45;     // pips PROFIT after which LockProfitFS_Lot1_10hrBO2 takes into effect for 10hrBO Order 1
int LockProfitFS_Lot1_10hrBO2TREND=5;       // pips lock-in GAIN for 10hrBO after ProfitPointFS_Lot1_10hrBO2 is hit
int ProfitPointFS_Lot1_10hrBO3TREND=55;     // pips PROFIT after which LockProfitFS_Lot1_10hrBO3 takes into effect for 10hrBO Order 1
int LockProfitFS_Lot1_10hrBO3TREND=10;      // pips lock-in GAIN for 10hrBO after ProfitPointFS_Lot1_10hrBO3 is hit
int ProfitPointFS_Lot1_10hrBO4TREND=75;     // pips PROFIT after which LockProfitFS_Lot1_10hrBO4 takes into effect for 10hrBO Order 1
int LockProfitFS_Lot1_10hrBO4TREND=25;      // pips lock-in GAIN for 10hrBO after ProfitPointFS_Lot1_10hrBO4 is hit
 // 10hrBO Lot 2 (TREND)
int ProfitPointFS_Lot2_10hrBO1TREND=35;     // pips PROFIT after which LockProfitFS_Lot2_10hrBO1 takes into effect for 10hrBO Order 2
int StopLossFS_Lot2_10hrBO1TREND=15;      // pips stop loss for 10hrBO after ProfitPointFS_Lot2_10hrBO1 is hit
int ProfitPointFS_Lot2_10hrBO2TREND=44;     // pips PROFIT after which LockProfitFS_Lot2_10hrBO2 takes into effect for 10hrBO Order 2
int LockProfitFS_Lot2_10hrBO2TREND=4;       // pips lock-in GAIN for 10hrBO after ProfitPointFS_Lot2_10hrBO2 is hit
int ProfitPointFS_Lot2_10hrBO3TREND=60;     // pips PROFIT after which LockProfitFS_Lot2_10hrBO3 takes into effect for 10hrBO Order 2
int LockProfitFS_Lot2_10hrBO3TREND=15;      // pips lock-in GAIN for 10hrBO after ProfitPointFS_Lot2_10hrBO3 is hit
int ProfitPointFS_Lot2_10hrBO4TREND=75;     // pips PROFIT after which LockProfitFS_Lot1_10hrBO4 takes into effect for 10hrBO Order 1
int LockProfitFS_Lot2_10hrBO4TREND=25;      // pips lock-in GAIN for 10hrBO after ProfitPointFS_Lot1_10hrBO4 is hit

 // Safety Non-Trend:
int LockProfitFS_Safety=4;             // pips lock-in GAIN for Safety for Orders 2&3 after Order 1 t/p (non-trend)
int ProfitPointFS_SafetyA=19;          // pips PROFIT after which StopLossFS_SafetyA takes into effect (Only for primary trigger orders) (non-trend)
int StopLossFS_SafetyA=4;              // pips stop loss for Safety after ProfitPointFS_SafetyA is reached  (Only for primary trigger orders) (non-trend)
int ProfitPointFS_SafetyB=45;          // pips PROFIT after which LockProfitFS_SafetyB takes into effect (non-trend)
int LockProfitFS_SafetyB=22;           // pips lock-in GAIN for Safety after ProfitPointFS_SafetyB is reached (non-trend)

 // Safety2:
int LockProfitFS_Safety21=4;           // pips lock-in GAIN for Safety2 for Orders 2&3 after Order 1 t/p 
int LockProfitFS_Safety22=30;          // pips lock-in GAIN for Safety2 for Orders 1&3 after Order 2 t/p 
int ProfitPointFS_Safety2=30;          // pips PROFIT after which StopLossFS_Safety2 takes into effect for Orders 1&2 
int LockProfitFS_Safety2=8;            // pips lock-in GAIN for Safety2 after ProfitPointFS_Safety2 is reached for Orders 1&2 

 // Safety3:
 // Safety3 Lot1
int ProfitPointFS_Lot1_Safety3=19;     // pips PROFIT after which StopLossFS_Lot1_Safety3 takes into effect
int LockProfitFS_Lot1_Safety3=1;       // pips lock-in GAIN for Safety3 for Order 1 
 // Safety3 Lot2
int ProfitPointFS_Lot2_Safety3=21;     // pips PROFIT after which StopLossFS_Lot2_Safety3 takes into effect
int LockProfitFS_Lot2_Safety3=3;       // pips lock-in GAIN for Safety3 for Order 2
 // Safety3 Lot3
int ProfitPointFS_Lot3_Safety3=32;     // pips PROFIT after which StopLossFS_Lot3_Safety3 takes into effect
int LockProfitFS_Lot3_Safety3=17;      // pips lock-in GAIN for Safety3 for Order 3

 // Reversal
int ProfitPointFS_Lot1_Reversal=18;    // pips PROFIT after which LockProfitFS_Lot1_Reversal takes into effect for Reversal Order 2
int LockProfitFS_Lot1_Reversal=4;      // pips lock-in GAIN for Reversal after ProfitPointFS_Lot1_Reversal is hit
int ProfitPointFS_Lot2_Reversal=39;    //  pips PROFIT after which LockProfitFS_Lot2_Reversal takes into effect for Reversal Order 2
int LockProfitFS_Lot2_Reversal=10;     // pips lock-in GAIN for Reversal after ProfitPointFS_Lot2_Reversal is hit
int ProfitPointFS_Lot4_Reversal=7;     //  pips PROFIT minimum after which LockProfitFS_Lot4_Reversal takes into effect for Reversal Order 4 after Order 3 t/p at BB centerline
int LockProfitFS_Lot4_Reversal=4;      // pips lock-in GAIN for Reversal after Order 3 t/p at BB centerline

 // Double Tops
int LockProfitFS_DoubleTops=25;        // pips lock-in GAIN for DoubleTops orders 2 AND 3 from original entry price AFTER order 1 hits t/p

 // OsMA1
int ProfitPointFS_OsMA=35;             // pips profit target after which to adjust stop-loss to StopLossFS_OsMA for ALL OsMA orders 1,2
int StopLossFS_OsMA=20;                // pips profit target after which to adjust stop-loss to StopLossFS_OsMA for ALL OsMA orders 1,2
 // OsMA Lot1 (Part 1)
int ProfitPointFS_Lot1_OsMA1=21;       // pips PROFIT after which LockProfitFS_Lot1_OsMA1 takes into effect for OsMA Order 1
int StopLossFS_Lot1_OsMA1=2;         // pips lock-in GAIN for OsMA after ProfitPointFS_Lot1_OsMA1 is hit
int ProfitPointFS_Lot1_OsMA2=55;       // pips PROFIT after which LockProfitFS_Lot1_OsMA2 takes into effect for OsMA Order 1
int LockProfitFS_Lot1_OsMA2=5;         // pips lock-in GAIN for OsMA after ProfitPointFS_Lot1_OsMA2 is hit
 // OsMA Lot 2 (Part 2)
int ProfitPointFS_Lot2_OsMA1=25;       // pips PROFIT after which LockProfitFS_Lot2_OsMA1 takes into effect for OsMA Order 2
int StopLossFS_Lot2_OsMA1=10;          // pips stop loss for OsMA after ProfitPointFS_Lot2_OsMA1 is hit
int ProfitPointFS_Lot2_OsMA2=60;       // pips PROFIT after which LockProfitFS_Lot2_OsMA2 takes into effect for OsMA Order 2
int LockProfitFS_Lot2_OsMA2=15;        // pips lock-in GAIN for OsMA after ProfitPointFS_Lot2_OsMA2 is hit

 // OsMA2
int ProfitPointFS_OsMA2=15;            // pips profit target after which to adjust stop-loss to StopLossFS_OsMA2 for ALL OsMA2 orders 1,2,3
int StopLossFS_OsMA2=20;               // pips profit target after which to adjust stop-loss to StopLossFS_OsMA2 for ALL OsMA2 orders 1,2,3
 // OsMA2 Lot1
int ProfitPointFS_Lot1_OsMA21=26;      // pips PROFIT after which LockProfitFS_Lot1_OsMA21 takes into effect for OsMA2 Order 1
int LockProfitFS_Lot1_OsMA21=2;        // pips lock-in GAIN for OsMA2 after ProfitPointFS_Lot1_OsMA21 is hit
int ProfitPointFS_Lot1_OsMA22=55;      // pips PROFIT after which LockProfitFS_Lot1_OsMA22 takes into effect for OsMA2 Order 1
int LockProfitFS_Lot1_OsMA22=5;        // pips lock-in GAIN for OsMA2 after ProfitPointFS_Lot1_OsMA22 is hit
int ProfitPointFS_Lot1_OsMA23=75;      // pips PROFIT after which LockProfitFS_Lot1_OsMA23 takes into effect for OsMA2 Order 1
int LockProfitFS_Lot1_OsMA23=25;        // pips lock-in GAIN for OsMA2 after ProfitPointFS_Lot1_OsMA23 is hit
 // OsMA2 Lot 2
int ProfitPointFS_Lot2_OsMA21=25;      // pips PROFIT after which LockProfitFS_Lot2_OsMA21 takes into effect for OsMA2 Order 2
int StopLossFS_Lot2_OsMA21=5;          // pips stop loss for OsMA2 after ProfitPointFS_Lot2_OsMA21 is hit
int ProfitPointFS_Lot2_OsMA22=60;      // pips PROFIT after which LockProfitFS_Lot2_OsMA22 takes into effect for OsMA2 Order 2
int LockProfitFS_Lot2_OsMA22=15;       // pips lock-in GAIN for OsMA2 after ProfitPointFS_Lot2_OsMA22 is hit
int ProfitPointFS_Lot2_OsMA23=75;      // pips PROFIT after which LockProfitFS_Lot2_OsMA23 takes into effect for OsMA2 Order 2
int LockProfitFS_Lot2_OsMA23=25;       // pips lock-in GAIN for OsMA2 after ProfitPointFS_Lot2_OsMA23 is hit
 // OsMA2 Lot 3
int ProfitPointFS_Lot3_OsMA21=26;      // pips PROFIT after which LockProfitFS_Lot3_OsMA21 takes into effect for OsMA2 Order 3
int LockProfitFS_Lot3_OsMA21=2;        // pips lock-in GAIN for OsMA2 after ProfitPointFS_Lot3_OsMA21 is hit
int ProfitPointFS_Lot3_OsMA22=55;      // pips PROFIT after which LockProfitFS_Lot3_OsMA22 takes into effect for OsMA2 Order 3
int LockProfitFS_Lot3_OsMA22=15;       // pips lock-in GAIN for OsMA2 after ProfitPointFS_Lot3_OsMA22 is hit
int ProfitPointFS_Lot3_OsMA23=75;      // pips PROFIT after which LockProfitFS_Lot3_OsMA23 takes into effect for OsMA2 Order 3
int LockProfitFS_Lot3_OsMA23=25;       // pips lock-in GAIN for OsMA2 after ProfitPointFS_Lot3_OsMA23 is hit

 // 30MinBO (Non-TREND)                // For 30MinBO FS (Non-TREND)
int ProfitPointFS_30MinBO=20;          // pips profit target after which to adjust stop-loss to LockProfitFS_30MinBO1
int LockProfitFS_30MinBO=1;            // pips lock-in GAIN for all 30MinBO orders from original entry price AFTER ProfitPointFS_30MinBO is hit
int ProfitPointFS_30MinBO4=55;         // pips profit target after which to adjust stop-loss to LockProfitFS_30MinBO4
int LockProfitFS_30MinBO4=25;          // pips lock-in GAIN for all 30MinBO orders from original entry price AFTER ProfitPointFS_30MinBO4 is hit

int LockProfitFS_30MinBO2=105;         // pips lock-in GAIN for 30MinBO orders 2 AND 3 from original entry price AFTER order 1 hits t/p
int LockProfitFS_30MinBO3=155;         // pips lock-in GAIN for 30MinBO order 3 from original entry price AFTER order 2 hits t/p

 // 30MinBO (TREND)                    // For 30MinBO FS (TREND)
int ProfitPointFS_30MinBOTREND=20;          // pips profit target after which to adjust stop-loss to LockProfitFS_30MinBO1
int LockProfitFS_30MinBOTREND=1;            // pips lock-in GAIN for all 30MinBO orders from original entry price AFTER ProfitPointFS_30MinBO is hit
int ProfitPointFS_30MinBO4TREND=55;         // pips profit target after which to adjust stop-loss to LockProfitFS_30MinBO4
int LockProfitFS_30MinBO4TREND=25;          // pips lock-in GAIN for all 30MinBO orders from original entry price AFTER ProfitPointFS_30MinBO4 is hit

int LockProfitFS_30MinBO2TREND=105;         // pips lock-in GAIN for 30MinBO orders 2 AND 3 from original entry price AFTER order 1 hits t/p
int LockProfitFS_30MinBO3TREND=155;         // pips lock-in GAIN for 30MinBO order 3 from original entry price AFTER order 2 hits t/p

 // RSIScalp Lot 1
int ProfitPointFS_Lot1_RSIScalp1=20;   // pips profit target after which to lock in LockProfitFS_Lot1_RSIScalp1 profits, order 1
int LockProfitFS_Lot1_RSIScalp1=4;     // pips lock-in GAIN for RSIScalp order 1 after ProfitPointFS_Lot1_RSIScalp1 is hit 
int ProfitPointFS_Lot1_RSIScalp2=60;   // pips profit target after which to lock in LockProfitFS_Lot1_RSIScalp2 profits, order 1
int LockProfitFS_Lot1_RSIScalp2=25;    // pips lock-in GAIN for RSIScalp order 1 after ProfitPointFS_Lot1_RSIScalp2 is hit 
 // RSIScalp Lot 2
int ProfitPointFS_Lot2_RSIScalp1=24;   // pips profit target after which to lock in LockProfitFS_Lot2_RSIScalp1 profits, order 2
int LockProfitFS_Lot2_RSIScalp1=9;     // pips lock-in GAIN for RSIScalp order 2 after ProfitPointFS_Lot2_RSIScalp1 is hit
int ProfitPointFS_Lot2_RSIScalp2=60;   // pips profit target after which to lock in LockProfitFS_Lot2_RSIScalp2 profits, order 2
int LockProfitFS_Lot2_RSIScalp2=25;    // pips lock-in GAIN for RSIScalp order 2 after ProfitPointFS_Lot2_RSIScalp2 is hit
 // RSIScalp Lot 3
int ProfitPointFS_Lot3_RSIScalp1=33;   // pips profit target after which to lock in LockProfitFS_Lot3_RSIScalp1 profits, order 3
int LockProfitFS_Lot3_RSIScalp1=10;     // pips lock-in GAIN for RSIScalp order 3 after ProfitPointFS_Lot3_RSIScalp1 is hit
int ProfitPointFS_Lot3_RSIScalp2=60;   // pips profit target after which to lock in LockProfitFS_Lot3_RSIScalp2 profits, order 3
int LockProfitFS_Lot3_RSIScalp2=25;    // pips lock-in GAIN for RSIScalp order 3 after ProfitPointFS_Lot3_RSIScalp2 is hit

 // RSI2 Lot 1 (the pending order)
int ProfitPointFS_Lot1_RSI2=22;        // pips profit target after which to lock in LockProfitFS_Lot1_RSI2 profits, order 1 (the pending order)
int LockProfitFS_Lot1_RSI2=2;          // pips lock-in GAIN for RSI2 order 1 (the pending order) after ProfitPointFS_Lot1_RSI2 is hit 
 // RSI2 Lot 2 (the market order)
int ProfitPointFS_Lot2_RSI2=22;        // pips profit target after which to lock in LockProfitFS_Lot2_RSI2 profits, order 2 (the market order)
int LockProfitFS_Lot2_RSI2=2;          // pips lock-in GAIN for RSI2 order 2 (the pending order) after ProfitPointFS_Lot2_RSI2 is hit 

 // Day Reversal
int ProfitPointFS_DayReversal2=50;     // pips profit target after which to lock in LockProfitFS_DayReversal profits, order 2 (triggered in ATR area 3/4)
int LockProfitFS_DayReversal2=25;      // pips lock-in GAIN for DayReversal order 2 triggered in ATR areas 3/4 (AFTER order 1 hits t/p)

 // HrPerpetual
int ProfitPointFS_Lot1_HrPerpetual=45; // pips profit target after which to lock in LockProfitFS_Lot1_HrPerpetual profits, Order 1
int LockProfitFS_Lot1_HrPerpetual=5;   // pips lock-in GAIN for HrPerpetual Order 1 once ProfitPointFS_Lot1_HrPerpetual is reached
int ProfitPointFS_Lot2_HrPerpetual=110; // pips profit target after which to stop loss StopLoss_Lot2_HrPerpetual profits, Order 2
int StopLossFS_Lot2_HrPerpetual=-5;    // pips stop loss for HrPerpetual Order 2 once ProfitPointFS_Lot2_HrPerpetual is reached

 // MACDSwing
int ProfitPointFS_MACDSwing2=30;       // pips profit target after which to lock in LockProfitFS_MACDSWing2 for MACDSWing order 2 (triggered in ATR area 3/4), once order 1 t/p.
int LockProfitFS_MACDSwing2=10;        // pips lock-in GAIN for MACDSWing order 2 (triggered in ATR area 3/4), once order 1 t/p.
int ProfitPointFS_MACDSwing3=50;       // pips profit target after which to lock in LockProfitFS_MACDSWing3 for MACDSWing order 3, once order 1 t/p.
int LockProfitFS_MACDSwing3=10;        // pips lock-in GAIN for MACDSWing order 3, once order 1 t/p.

 // Sentiment
int ProfitPointFS_Lot1_Sentiment1=45;       // pips PROFIT after which StopLossFS_Sentiment1 takes into effect for Sentiment  
int StopLossFS_Lot1_Sentiment1=1;           // pips stop loss for Sentiment 
int ProfitPointFS_Lot1_Sentiment2=75;       // pips PROFIT after which LockProfitFS_Sentiment2 takes into effect for Sentiment 
int LockProfitFS_Lot1_Sentiment2=19;        // pips lock-in GAIN for Sentiment 
int ProfitPointFS_Lot1_Sentiment3=110;      // pips PROFIT after which LockProfitFS_Sentiment3 takes into effect for Sentiment  
int LockProfitFS_Lot1_Sentiment3=55;        // pips lock-in GAIN for Sentiment  

int ProfitPointFS_Lot2_Sentiment1=55;       // pips PROFIT after which StopLossFS_Sentiment1 takes into effect for Sentiment  
int StopLossFS_Lot2_Sentiment1=1;           // pips stop loss for Sentiment 
int ProfitPointFS_Lot2_Sentiment2=75;       // pips PROFIT after which LockProfitFS_Sentiment2 takes into effect for Sentiment 
int LockProfitFS_Lot2_Sentiment2=19;        // pips lock-in GAIN for Sentiment 
int ProfitPointFS_Lot2_Sentiment3=110;      // pips PROFIT after which LockProfitFS_Sentiment3 takes into effect for Sentiment  
int LockProfitFS_Lot2_Sentiment3=55;        // pips lock-in GAIN for Sentiment  

int ProfitPointFS_Lot3_Sentiment1=75;       // pips PROFIT after which StopLossFS_Sentiment1 takes into effect for Sentiment  
int StopLossFS_Lot3_Sentiment1=1;           // pips stop loss for Sentiment  
int ProfitPointFS_Lot3_Sentiment2=90;       // pips PROFIT after which LockProfitFS_Sentiment2 takes into effect for Sentiment  
int LockProfitFS_Lot3_Sentiment2=10;        // pips lock-in GAIN for Sentiment  
int ProfitPointFS_Lot3_Sentiment3=140;      // pips PROFIT after which LockProfitFS_Sentiment3 takes into effect for Sentiment  
int LockProfitFS_Lot3_Sentiment3=55;        // pips lock-in GAIN for Sentiment  


 // ADXDay Lot 1
int ProfitPointFS_Lot1_ADXDay=65;      // pips PROFIT after which LockProfitFS_Lot1_ADXDay takes into effect for ADXDay Order 1
int LockProfitFS_Lot1_ADXDay=5;        // pips lock-in GAIN after ProfitPointFS_Lot1_ADXDay is hit
 // ADXDay Lot 2
int ProfitPointFS_Lot2_ADXDay=50;      // pips PROFIT after which LockProfitFS_Lot2_ADXDay takes into effect for ADXDay Order 2
int StopLossFS_Lot2_ADXDay=35;         // pips stop loss after ProfitPointFS_Lot2_ADXDay is hit
int LockProfitFS_Lot2_ADXDay=40;       // pips lock-in GAIN after Order 1 t/p's
 // ADXDay Lot 3
int LockProfitFS_Lot3_ADXDay1=10;      // pips stop loss after Order 1 t/p's
int LockProfitFS_Lot3_ADXDay2=100;     // pips lock-in GAIN after Order 2 t/p's

 // MAScalp Lot 1
int ProfitPointFS_Lot1_MAScalp1=24;    // pips PROFIT after which LockProfitFS_Lot1_MAScalp1 takes into effect for MAScalp Order 1
int LockProfitFS_Lot1_MAScalp1=2;      // pips lock-in GAIN for MAScalp after ProfitPointFS_Lot1_MAScalp1 is hit
int ProfitPointFS_Lot1_MAScalp2=44;    // pips PROFIT after which LockProfitFS_Lot1_MAScalp2 takes into effect for MAScalp Order 1
int LockProfitFS_Lot1_MAScalp2=5;      // pips lock-in GAIN for MAScalp after ProfitPointFS_Lot1_MAScalp2 is hit
int ProfitPointFS_Lot1_MAScalp3=84;    // pips PROFIT after which LockProfitFS_Lot1_MAScalp3 takes into effect for MAScalp Order 1
int LockProfitFS_Lot1_MAScalp3=40;     // pips lock-in GAIN for MAScalp after ProfitPointFS_Lot1_MAScalp3 is hit
 // MAScalp Lot 2
int ProfitPointFS_Lot2_MAScalp1=20;    // pips PROFIT after which LockProfitFS_Lot2_MAScalp1 takes into effect for MAScalp Order 2
int StopLossFS_Lot2_MAScalp1=15;       // pips stop loss for MAScalp after ProfitPointFS_Lot2_MAScalp1 is hit
int ProfitPointFS_Lot2_MAScalp2=40;    // pips PROFIT after which LockProfitFS_Lot2_MAScalp2 takes into effect for MAScalp Order 2
int LockProfitFS_Lot2_MAScalp2=4;      // pips lock-in GAIN for MAScalp after ProfitPointFS_Lot2_MAScalp2 is hit
int ProfitPointFS_Lot2_MAScalp3=60;    // pips PROFIT after which LockProfitFS_Lot2_MAScalp3 takes into effect for MAScalp Order 2
int LockProfitFS_Lot2_MAScalp3=15;     // pips lock-in GAIN for MAScalp after ProfitPointFS_Lot2_MAScalp3 is hit
 // MAScalp Lot 3
int ProfitPointFS_Lot3_MAScalp1=20;    // pips PROFIT after which LockProfitFS_Lot3_MAScalp1 takes into effect for MAScalp Order 3
int StopLossFS_Lot3_MAScalp1=-5;       // pips stop loss for MAScalp after ProfitPointFS_Lot3_MAScalp1 is hit
int ProfitPointFS_Lot3_MAScalp2=40;    // pips PROFIT after which LockProfitFS_Lot3_MAScalp2 takes into effect for MAScalp Order 3
int LockProfitFS_Lot3_MAScalp2=14;      // pips lock-in GAIN for MAScalp after ProfitPointFS_Lot3_MAScalp2 is hit
int ProfitPointFS_Lot3_MAScalp3=60;    // pips PROFIT after which LockProfitFS_Lot3_MAScalp3 takes into effect for MAScalp Order 3
int LockProfitFS_Lot3_MAScalp3=25;     // pips lock-in GAIN for MAScalp after ProfitPointFS_Lot3_MAScalp3 is hit

 // MADoubleX Lot 1
int ProfitPointFS_Lot1_MADoubleX1=25;  // pips PROFIT after which LockProfitFS_Lot1_MADoubleX1 takes into effect for MADoubleX Order 1
int LockProfitFS_Lot1_MADoubleX1=2;    // pips lock-in GAIN for MADoubleX Order 1
 // MADoubleX Lot 2
int ProfitPointFS_Lot2_MADoubleX1=26;  // pips PROFIT after which LockProfitFS_Lot2_MADoubleX1 takes into effect for MADoubleX Order 2
int LockProfitFS_Lot2_MADoubleX1=6;    // pips lock-in GAIN for MADoubleX Order 2
 // MADoubleX Lot 3
int ProfitPointFS_Lot3_MADoubleX1=40;  // pips PROFIT after which LockProfitFS_Lot3_MADoubleX1 takes into effect for MADoubleX Order 3
int LockProfitFS_Lot3_MADoubleX1=14;    // pips lock-in GAIN for MADoubleX Order 3

 // OsMAHiLo Lot 1
int ProfitPointFS_Lot1_OsMAHiLo=24;    // pips PROFIT after which LockProfitFS_Lot1_OsMAHiLo takes into effect for OsMAHiLo Order 1
int LockProfitFS_Lot1_OsMAHiLo=2;      // pips lock-in GAIN for OsMAHiLo after ProfitPointFS_Lot1_OsMAHiLo is hit
 // OsMAHiLo Lot 2
int ProfitPointFS_Lot2_OsMAHiLo=24;    // pips PROFIT after which LockProfitFS_Lot2_OsMAHiLo takes into effect for OsMAHiLo Order 2
int LockProfitFS_Lot2_OsMAHiLo=2;      // pips lock-in GAIN for OsMAHiLo after ProfitPointFS_Lot2_OsMAHiLo is hit
int LockProfitFS_Lot2_OsMAHiLoA=10;    // pips lock-in GAIN for OsMAHiLo Order 2 after Order 1 t/p's.

 // BBScalp Lot 1
int ProfitPointFS_Lot1_BBScalp1=13;     // pips PROFIT after which LockProfitFS_Lot1_BBScalp takes into effect for BBScalp Order 1
int LockProfitFS_Lot1_BBScalp1=1;       // pips lock-in GAIN for BBScalp Order 1
int ProfitPointFS_Lot1_BBScalp2=30;     // pips PROFIT after which LockProfitFS_Lot1_BBScalp takes into effect for BBScalp Order 1
int LockProfitFS_Lot1_BBScalp2=12;      // pips lock-in GAIN for BBScalp Order 1
 // BBScalp Lot 2
int ProfitPointFS_Lot2_BBScalp1=21;     // pips PROFIT after which LockProfitFS_Lot2_BBScalp takes into effect for BBScalp Order 2
int LockProfitFS_Lot2_BBScalp1=5;       // pips lock-in GAIN for BBScalp Order 2 
int ProfitPointFS_Lot2_BBScalp2=30;     // pips PROFIT after which LockProfitFS_Lot2_BBScalp takes into effect for BBScalp Order 2
int LockProfitFS_Lot2_BBScalp2=12;      // pips lock-in GAIN for BBScalp Order 2 

 // MAStochRSI Lot 1
int ProfitPointFS_Lot1_MAStochRSI1=12;  // pips PROFIT after which LockProfitFS_Lot1_MAStochRSI takes into effect for MAStochRSI Order 1
int LockProfitFS_Lot1_MAStochRSI1=1;    // pips lock-in GAIN for MAStochRSI Order 1
int ProfitPointFS_Lot1_MAStochRSI2=35;  // pips PROFIT after which LockProfitFS_Lot1_MAStochRSI takes into effect for MAStochRSI
int LockProfitFS_Lot1_MAStochRSI2=8;    // pips lock-in GAIN for MAStochRSI
int ProfitPointFS_Lot1_MAStochRSI3=60;  // pips PROFIT after which LockProfitFS_Lot1_MAStochRSI takes into effect for MAStochRSI
int LockProfitFS_Lot1_MAStochRSI3=25;    // pips lock-in GAIN for MAStochRSI
 // MAStochRSI Lot 2
int ProfitPointFS_Lot2_MAStochRSI1=18;  // pips PROFIT after which LockProfitFS_Lot2_MAStochRSI takes into effect for MAStochRSI Order 2
int LockProfitFS_Lot2_MAStochRSI1=3;    // pips lock-in GAIN for MAStochRSI Order 2 
int ProfitPointFS_Lot2_MAStochRSI2=35;  // pips PROFIT after which LockProfitFS_Lot2_MAStochRSI takes into effect for MAStochRSI
int LockProfitFS_Lot2_MAStochRSI2=8;    // pips lock-in GAIN for MAStochRSI
int ProfitPointFS_Lot2_MAStochRSI3=60;  // pips PROFIT after which LockProfitFS_Lot2_MAStochRSI takes into effect for MAStochRSI
int LockProfitFS_Lot2_MAStochRSI3=25;    // pips lock-in GAIN for MAStochRSI
 // MAStochRSI Lot 3
int ProfitPointFS_Lot3_MAStochRSI1=23;  // pips PROFIT after which LockProfitFS_Lot3_MAStochRSI takes into effect for MAStochRSI Order 3
int LockProfitFS_Lot3_MAStochRSI1=5;    // pips lock-in GAIN for MAStochRSI Order 3
int ProfitPointFS_Lot3_MAStochRSI2=35;  // pips PROFIT after which LockProfitFS_Lot3_MAStochRSI takes into effect for MAStochRSI
int LockProfitFS_Lot3_MAStochRSI2=8;    // pips lock-in GAIN for MAStochRSI
int ProfitPointFS_Lot3_MAStochRSI3=60;  // pips PROFIT after which LockProfitFS_Lot3_MAStochRSI takes into effect for MAStochRSI
int LockProfitFS_Lot3_MAStochRSI3=25;    // pips lock-in GAIN for MAStochRSI


 // RangeBO
 // RangeBO Lot 1
int ProfitPointFS_Lot1_RangeBO=25;    // pips PROFIT after which LockProfitFS_Lot1_RangeBO takes into effect for RangeBO Order 1
int LockProfitFS_Lot1_RangeBO=1;      // pips lock-in GAIN for RangeBO Order 1
 // RangeBO Lot 2
int ProfitPointFS_Lot2_RangeBO=25;    // pips PROFIT after which LockProfitFS_Lot2_RangeBO takes into effect for RangeBO Order 2
int LockProfitFS_Lot2_RangeBO=1;      // pips lock-in GAIN for RangeBO Order 2
  // RangeBO Lot 3 (for X reverse orders)
int ProfitPointFS_Lot3_RangeBO=40;    // pips PROFIT after which LockProfitFS_Lot1_RangeBO takes into effect for RangeBO Order 3
int LockProfitFS_Lot3_RangeBO=4;      // pips lock-in GAIN for RangeBO Order 3
 // RangeBO Lot 4
int ProfitPointFS_Lot4_RangeBO=40;    // pips PROFIT after which LockProfitFS_Lot2_RangeBO takes into effect for RangeBO Order 4
int LockProfitFS_Lot4_RangeBO=4;      // pips lock-in GAIN for RangeBO Order 4

 // Phoenix
 // Phoenix Lot 1
int ProfitPointFS_Lot1_Phoenix1=36;    // pips PROFIT after which LockProfitFS_Lot1_Phoenix takes into effect for Phoenix Order 1
int LockProfitFS_Lot1_Phoenix1=2;      // pips lock-in GAIN for Phoenix Order 1 
int ProfitPointFS_Lot1_Phoenix2=46;    // pips PROFIT after which LockProfitFS_Lot1_Phoenix takes into effect for Phoenix Order 1
int LockProfitFS_Lot1_Phoenix2=26;      // pips lock-in GAIN for Phoenix Order 1 
  // Phoenix Lot 2
int ProfitPointFS_Lot2_Phoenix1=28;    // pips PROFIT after which LockProfitFS_Lot2_Phoenix takes into effect for Phoenix Order 2
int LockProfitFS_Lot2_Phoenix1=4;     // pips lock-in GAIN for Phoenix Order 2 
int ProfitPointFS_Lot2_Phoenix2=46;    // pips PROFIT after which LockProfitFS_Lot2_Phoenix takes into effect for Phoenix Order 2
int LockProfitFS_Lot2_Phoenix2=26;     // pips lock-in GAIN for Phoenix Order 2 

 // ATRStopScalp
int ProfitPointFS_ATRStopScalp=19;    // pips PROFIT after which LockProfitFS_Lot1(2,3)_ATRStopScalp takes into effect for ATRStopScalp Orders 1, 2, 3
 // ATRStopScalp Lot 1
int LockProfitFS_Lot1_ATRStopScalp=6; // pips lock-in GAIN for ATRStopScalp Order 1after ProfitPointFS_ATRStopScalp is hit
 // ATRStopScalp Lot 2
int LockProfitFS_Lot2_ATRStopScalp1=9; // pips lock-in GAIN for ATRStopScalp Order 2 after ProfitPointFS_ATRStopScalp is hit
int LockProfitFS_Lot2_ATRStopScalp2=25;// pips lock-in GAIN for ATRStopScalp Order 2 after Order 1 t/p
 // ATRStopScalp Lot 3
int LockProfitFS_Lot3_ATRStopScalp=9;  // pips stop-loss for ATRStopScalp Order 3 after ProfitPointFS_ATRStopScalp is hit
 // ATRStopScalp Lot 5 (re-entry for 1,2,3 if hit initial stop)
int LockProfitFS_Lot5_ATRStopScalp=6;  // pips lock-in GAIN for ATRStopScalp Order 5 (re-entry) after ProfitPointFS_ATRStopScalp is hit

 // RangeTight Lot 1,2
int ProfitPointFS_RangeTight=11;       // pips from opposite Envelope after which LockProfitFS_RangeTight takes into effect for RangeTight Orders 1, 2
int LockProfitFS_RangeTight=3;         // pips lock-in GAIN for RangeTight Order 1, 2 

 // RangeMid Lot 1,2
int ProfitPointFS_Lot1_RangeMid=52;    // pips PROFIT after which LockProfitFS_RangeMid takes into effect for RangeMid Orders 1
int LockProfitFS_Lot1_RangeMid=7;     // pips lock-in GAIN for RangeMid Order 1
int ProfitPointFS_Lot2_RangeMid=22;    // pips PROFIT after which LockProfitFS_RangeMid takes into effect for RangeMid Orders 2
int LockProfitFS_Lot2_RangeMid=1;     // pips lock-in GAIN for RangeMid Order 2 

 // KeltnerScalp Lot 1,2
int ProfitPointFS_KeltnerScalp=21;     // pips PROFIT after which LockProfitFS_KeltnerScalp takes into effect for KeltnerScalp Orders 1, 2
int LockProfitFS_KeltnerScalp=2;       // pips lock-in GAIN for KeltnerScalp Order 1, 2 

 // Vegas
// Vegas Lot 1
int ProfitPointFS_Lot1_Vegas=32;       // pips PROFIT after which LockProfitFS_Lot1_Vegas takes into effect for Vegas Order 1
int LockProfitFS_Lot1_Vegas=5;         // pips lock-in GAIN for Vegas Order 1 after ProfitPointFS_Lot1_Vegas is hit
 // Vegas Lot 2
int ProfitPointFS_Lot2_Vegas=42;       // pips PROFIT after which LockProfitFS_Lot2_Vegas takes into effect for Vegas Order 2
int LockProfitFS_Lot2_Vegas=12;         // pips lock-in GAIN for Vegas Order 2 after ProfitPointFS_Lot2_Vegas is hit
 // Vegas Lot 3
int ProfitPointFS_Lot3_Vegas=32;       // pips PROFIT after which LockProfitFS_Lot3_Vegas takes into effect for Vegas Order 3
int LockProfitFS_Lot3_Vegas=3;         // pips lock-in GAIN for Vegas Order 3 after ProfitPointFS_Lot3_Vegas is hit
 // Vegas Lot 4
int ProfitPointFS_Lot4_Vegas=42;       // pips PROFIT after which LockProfitFS_Lot4_Vegas takes into effect for Vegas Order 4
int LockProfitFS_Lot4_Vegas=10;         // pips lock-in GAIN for Vegas Order 4 after ProfitPointFS_Lot4_Vegas is hit

 // PSARASC
// PSARASC Lot 1
int ProfitPointFS_PSARASC1=35;       // pips PROFIT after which LockProfitFS_PSARASC takes into effect for PSARASC Orders
int LockProfitFS_PSARASC1=1;         // pips lock-in GAIN for PSARASC Orders after ProfitPointFS_PSARASC is hit
int ProfitPointFS_PSARASC2=45;       // pips PROFIT after which LockProfitFS_PSARASC takes into effect for PSARASC Orders
int LockProfitFS_PSARASC2=10;         // pips lock-in GAIN for PSARASC Orders after ProfitPointFS_PSARASC is hit

 // EnvScalp1
// EnvScalp1 Lot 1
int ProfitPointFS_Lot1_EnvScalp1=47;     // pips PROFIT after which LockProfitFS_Lot1_EnvScalp1 takes into effect for EnvScalp1 Order 1
int LockProfitFS_Lot1_EnvScalp1=13;       // pips lock-in GAIN for EnvScalp1 Order 1 after ProfitPointFS_Lot1_EnvScalp1 is hit
 // EnvScalp1 Lot 2
int ProfitPointFS_Lot2_EnvScalp1=24;     // pips PROFIT after which LockProfitFS_Lot2_EnvScalp1 takes into effect for EnvScalp1 Order 2
int LockProfitFS_Lot2_EnvScalp1=8;       // pips lock-in GAIN for EnvScalp1 Order 2 after ProfitPointFS_Lot2_EnvScalp1 is hit
 // EnvScalp1 Time-delay stops, Lots 1,2
int TimeDelayFS_EnvScalp1=4;             // hours to delay moving stops to StopLossFS_EnvScalps (activates at the top of the new bar)
int StopLossFS_EnvScalp1=40;             // pips stop loss after TimeDelayFS_EnvScalp1 hours

 // EnvScalp2
// EnvScalp2 Lot 1
int ProfitPointFS_Lot1_EnvScalp2=25;     // pips PROFIT after which LockProfitFS_Lot1_EnvScalp2 takes into effect for EnvScalp2 Order 1
int LockProfitFS_Lot1_EnvScalp2=5;      // pips lock-in GAIN for EnvScalp2 Order 1 after ProfitPointFS_Lot1_EnvScalp2 is hit
 // EnvScalp2 Lot 2
int ProfitPointFS_Lot2_EnvScalp2=15;     // pips PROFIT after which LockProfitFS_Lot2_EnvScalp2 takes into effect for EnvScalp2 Order 2
int LockProfitFS_Lot2_EnvScalp2=1;       // pips lock-in GAIN for EnvScalp2 Order 2 after ProfitPointFS_Lot2_EnvScalp2 is hit

 // EnvScalp3
// EnvScalp3 Lot 1
int ProfitPointFS_Lot1_EnvScalp3=23;     // pips PROFIT after which LockProfitFS_Lot1_EnvScalp3 takes into effect for EnvScalp3 Order 1
int LockProfitFS_Lot1_EnvScalp3=5;       // pips lock-in GAIN for EnvScalp2 Order 1 after ProfitPointFS_Lot1_EnvScalp is hit
 // EnvScalp3 Lot 2
int ProfitPointFS_Lot2_EnvScalp3=42;     // pips PROFIT after which LockProfitFS_Lot2_EnvScalp3 takes into effect for EnvScalp3 Order 2
int LockProfitFS_Lot2_EnvScalp3=12;      // pips lock-in GAIN for EnvScalp2 Order 2 after ProfitPointFS_Lot2_EnvScalp3 is hit
 
 // PMI30
 // PMI30 Lot 1
int ProfitPointFS_Lot1_PMI30=27;           // pips PROFIT after which LockProfitFS_Lot1_PMI takes into effect for PMI Order 1
int LockProfitFS_Lot1_PMI30=5;             // pips lock-in GAIN for PMI Order 1 after ProfitPointFS_Lot1_PMI is hit
 // PMI30 Lot 2
int ProfitPointFS_Lot2_PMI30=32;           // pips PROFIT after which LockProfitFS_Lot2_PMI takes into effect for PMI Order 2
int LockProfitFS_Lot2_PMI30=12;            // pips lock-in GAIN for PMI Order 2 after ProfitPointFS_Lot2_PMI is hit

 // PMI60
 // PMI60 Lot 1
int ProfitPointFS_Lot1_PMI60=28;           // pips PROFIT after which LockProfitFS_Lot1_PMI takes into effect for PMI Order 1
int LockProfitFS_Lot1_PMI60=2;             // pips lock-in GAIN for PMI Order 1 after ProfitPointFS_Lot1_PMI is hit
 // PMI60 Lot 2
int ProfitPointFS_Lot2_PMI60=35;           // pips PROFIT after which LockProfitFS_Lot2_PMI takes into effect for PMI Order 2
int LockProfitFS_Lot2_PMI60=12;            // pips lock-in GAIN for PMI Order 2 after ProfitPointFS_Lot2_PMI is hit
 
 // AweOsMA
// AweOsMA Lot 1
int ProfitPointFS_Lot1_AweOsMA1=15;       // pips PROFIT after which LockProfitFS_Lot1_AweOsMA takes into effect for AweOsMA Order 1
int StopLossFS_Lot1_AweOsMA1=25;          // pips s/l for AweOsMA Order 1 after ProfitPointFS_Lot1_AweOsMA is hit
int ProfitPointFS_Lot1_AweOsMA2=25;       // pips PROFIT after which LockProfitFS_Lot1_AweOsMA takes into effect for AweOsMA Order 1
int LockProfitFS_Lot1_AweOsMA2=7;         // pips lock-in GAIN for AweOsMA Order 1 after ProfitPointFS_Lot1_AweOsMA is hit
int ProfitPointFS_Lot1_AweOsMA3=35;       // pips PROFIT after which LockProfitFS_Lot1_AweOsMA takes into effect for AweOsMA Order 1
int LockProfitFS_Lot1_AweOsMA3=23;        // pips lock-in GAIN for AweOsMA Order 1 after ProfitPointFS_Lot1_AweOsMA is hit
 // AweOsMA Lot 2
int ProfitPointFS_Lot2_AweOsMA1=15;       // pips PROFIT after which LockProfitFS_Lot2_AweOsMA takes into effect for AweOsMA Order 2
int StopLossFS_Lot2_AweOsMA1=25;          // pips s/l for AweOsMA Order 2 after ProfitPointFS_Lot2_AweOsMA is hit
int ProfitPointFS_Lot2_AweOsMA2=25;       // pips PROFIT after which LockProfitFS_Lot2_AweOsMA takes into effect for AweOsMA Order 2
int LockProfitFS_Lot2_AweOsMA2=7;         // pips lock-in GAIN for AweOsMA Order 2 after ProfitPointFS_Lot2_AweOsMA is hit
int ProfitPointFS_Lot2_AweOsMA3=35;       // pips PROFIT after which LockProfitFS_Lot2_AweOsMA takes into effect for AweOsMA Order 2
int LockProfitFS_Lot2_AweOsMA3=23;        // pips lock-in GAIN for AweOsMA Order 2 after ProfitPointFS_Lot2_AweOsMA is hit
  
 // RangeTightDay
// RangeTightDay Lot 1
int ProfitPointFS_Lot1_RangeTightD=90;   // pips PROFIT after which LockProfitFS_Lot1_RangeTightDay takes into effect for RangeTightDay Order 1
int LockProfitFS_Lot1_RangeTightD=35;     // pips lock-in GAIN for RangeTightDay Order 1 after ProfitPointFS_Lot1_RangeTightDay is hit
 // RangeTightDay Lot 2
int ProfitPointFS_Lot2_RangeTightD=80;   // pips PROFIT after which LockProfitFS_Lot2_RangeTightDay takes into effect for RangeTightDay Order 2
int LockProfitFS_Lot2_RangeTightD=30;    // pips lock-in GAIN for RangeTightDay Order 2 after ProfitPointFS_Lot2_RangeTightDay is hit

 // ADXTrend
// ADXTrend Lot 1
int ProfitPointFS_Lot1_ADXTrend=55;      // pips PROFIT after which LockProfitFS_Lot1_ADXTrend takes into effect for ADXTrend Order 1
int LockProfitFS_Lot1_ADXTrend=7;        // pips lock-in GAIN for ADXTrend Order 1 after ProfitPointFS_Lot1_ADXTrend is hit
 // ADXTrend Lot 2
int ProfitPointFS_Lot2_ADXTrend=75;      // pips PROFIT after which LockProfitFS_Lot2_ADXTrend takes into effect for ADXTrend Order 2
int LockProfitFS_Lot2_ADXTrend=15;       // pips lock-in GAIN for ADXTrend Order 2 after ProfitPointFS_Lot2_ADXTrend is hit
 // ADXTrend Lot 3
int ProfitPointFS_Lot3_ADXTrend=75;      // pips PROFIT after which LockProfitFS_Lot3_ADXTrend takes into effect for ADXTrend Order 3
int LockProfitFS_Lot3_ADXTrend=5;       // pips lock-in GAIN for ADXTrend Order 3 after ProfitPointFS_Lot3_ADXTrend is hit

 // HighProb
// HighProb Lot 1
int ProfitPointFS_Lot1_HighProb=32;      // pips PROFIT after which LockProfitFS_Lot1_HighProb takes into effect for HighProb Order 1
int LockProfitFS_Lot1_HighProb=1;        // pips lock-in GAIN for HighProb Order 1 after ProfitPointFS_Lot1_HighProb is hit
 // HighProb Lot 2
int ProfitPointFS_Lot2_HighProb=50;      // pips PROFIT after which LockProfitFS_Lot2_HighProb takes into effect for HighProb Order 2
int LockProfitFS_Lot2_HighProb=4;        // pips lock-in GAIN for HighProb Order 2 after ProfitPointFS_Lot2_HighProb is hit
 // HighProb Lot 3
int ProfitPointFS_Lot3_HighProb=24;      // pips PROFIT after which LockProfitFS_Lot3_HighProb takes into effect for HighProb Order 3
int LockProfitFS_Lot3_HighProb=4;        // pips lock-in GAIN for HighProb Order 3 after ProfitPointFS_Lot3_HighProb is hit

 // HighProb4
// HighProb4 Lot 1
int ProfitPointFS_Lot1_HighProb4=42;      // pips PROFIT after which LockProfitFS_Lot1_HighProb takes into effect for HighProb Order 1
int LockProfitFS_Lot1_HighProb4=1;        // pips lock-in GAIN for HighProb Order 1 after ProfitPointFS_Lot1_HighProb is hit
 // HighProb4 Lot 2
int ProfitPointFS_Lot2_HighProb4=60;      // pips PROFIT after which LockProfitFS_Lot2_HighProb takes into effect for HighProb Order 2
int LockProfitFS_Lot2_HighProb4=4;        // pips lock-in GAIN for HighProb Order 2 after ProfitPointFS_Lot2_HighProb is hit
 // HighProb4 Lot 3
int ProfitPointFS_Lot3_HighProb4=28;      // pips PROFIT after which LockProfitFS_Lot3_HighProb takes into effect for HighProb Order 3
int LockProfitFS_Lot3_HighProb4=4;        // pips lock-in GAIN for HighProb Order 3 after ProfitPointFS_Lot3_HighProb is hit

 // StochADX
 // StochADX Lot 1 (pending)
int ProfitPointFS_Lot1_StochADX=25;   // pips PROFIT after which LockProfitFS_Lot1_StochADX takes into effect for StochADX 1 
int LockProfitFS_Lot1_StochADX=4;     // pips lock-in GAIN for StochADX
 // StochADX Lot 2 (market immediate)
int ProfitPointFS_Lot2_StochADX=25;   // pips PROFIT after which LockProfitFS_Lot2_StochADX takes into effect for StochADX 2
int LockProfitFS_Lot2_StochADX=4;     // pips lock-in GAIN for StochADX

 // MiniShortI
 // MiniShortI Lot 1 
int ProfitPointFS_Lot1_MiniShortI1=15;      // pips PROFIT after which LockProfitFS_MiniShortI1 takes into effect for MiniShortI
int LockProfitFS_Lot1_MiniShortI1=1;        // pips lock-in GAIN for MAScalp after ProfitPointFS_MiniShortI1 is hit
int ProfitPointFS_Lot1_MiniShortI2=45;      // pips PROFIT after which LockProfitFS_MiniShortI2 takes into effect for MiniShortI
int LockProfitFS_Lot1_MiniShortI2=25;       // pips lock-in GAIN for MAScalp after ProfitPointFS_MiniShortI2 is hit
 // MiniShortI Lot 2 
int ProfitPointFS_Lot2_MiniShortI1=19;      // pips PROFIT after which LockProfitFS_MiniShortI1 takes into effect for MiniShortI
int LockProfitFS_Lot2_MiniShortI1=3;        // pips lock-in GAIN for MAScalp after ProfitPointFS_MiniShortI1 is hit
int ProfitPointFS_Lot2_MiniShortI2=55;      // pips PROFIT after which LockProfitFS_MiniShortI2 takes into effect for MiniShortI
int LockProfitFS_Lot2_MiniShortI2=20;       // pips lock-in GAIN for MAScalp after ProfitPointFS_MiniShortI2 is hit

 // Bonus4Doji
int ProfitPointFS_Bonus4Doji=45;       // pips profit target after which to lock in LockProfitFS_Bonus4Doji profits, Order 1
int LockProfitFS_Bonus4Doji=5;         // pips lock-in GAIN for HrPerpetual order 1 once ProfitPointFS_Bonus4Doji is reached

//
// Other Order-related Parameters:
//

// Time Elapse Stops Variables:

int TES_delay=13;                       // hours to delay TES action.  TES begins the hour after this value. (e.g. if TES_delay=3, TES begins 4 hours after Order open).
int TES_delay2=1; // Safety,RangeTight // hours to delay TES action.  TES begins the hour after this value. (e.g. if TES_delay=1, TES begins 2 hours after Order open).
int TES_delay3=5; // EnvScalp2 lot 2   // hours to delay TES action.  TES begins the hour after this value. (e.g. if TES_delay=3, TES begins 4 hours after Order open).

int TES_MADoubleX=5;                   // pips to increment existing s/l at the beginning of the hour 
int TESMIN_MADoubleX=12;               // pips smallest distance from market which TES is allowed to function

int TES_BBScalp=6;                     // pips to increment existing s/l at the beginning of the hour 
int TESMIN_BBScalp=15;                 // pips smallest distance from market which TES is allowed to function

int TES_MAStochRSI=3;                  // pips to increment existing s/l at the beginning of the hour 
int TESMIN_MAStochRSI=19;              // pips smallest distance from market which TES is allowed to function

int TES_SecretMA=3;                    // pips to increment existing s/l at the beginning of the hour 
int TESMIN_SecretMA=15;                // pips smallest distance from market which TES is allowed to function

int TES_Reversal=2;                    // pips to increment existing s/l at the beginning of the hour 
int TESMIN_Reversal=20;                // pips smallest distance from market which TES is allowed to function

int TES_OsMA2=3;                       // pips to increment existing s/l at the beginning of the hour 
int TESMIN_OsMA2=20;                   // pips smallest distance from market which TES is allowed to function

int TES_RSI2=2;                        // pips to increment existing s/l at the beginning of the hour 
int TESMIN_RSI2=20;                    // pips smallest distance from market which TES is allowed to function

int TES_OsMAHiLo=3;                    // pips to increment existing s/l at the beginning of the hour 
int TESMIN_OsMAHiLo=20;                // pips smallest distance from market which TES is allowed to function

int TES_Bonus4SMA=0;                   // pips to increment existing s/l at the beginning of the hour 
int TESMIN_Bonus4SMA=15;               // pips smallest distance from market which TES is allowed to function

int TES_RangeBO=5;                     // pips to increment existing s/l at the beginning of the hour 
int TESMIN_RangeBO=15;                 // pips smallest distance from market which TES is allowed to function

int TES_ATRStopScalp=1;                // pips to increment existing s/l at the beginning of the hour 
int TESMIN_ATRStopScalp=15;            // pips smallest distance from market which TES is allowed to function

int TES_RangeMid=1;                     // pips to increment existing s/l at the beginning of the hour 
int TESMIN_RangeMid=20;                 // pips smallest distance from market which TES is allowed to function


 // KeltnerScalp Orders 1, 2 (pt 1, pending)
int TES_KeltnerScalp=3;                // pips to increment existing s/l at the beginning of the hour 
int TESMIN_KeltnerScalp=15;            // pips smallest distance from market which TES is allowed to function
 // KeltnerScalp Order 3 (pt 2, market)
int TES_KeltnerScalp3=3;               // pips to increment existing s/l at the beginning of the hour 
int TESMIN_KeltnerScalp3=15;           // waits 1 hr when this distance is hit, and then TES continues afterward

int TES_RangeTight=3;                  // pips to increment existing s/l at the beginning of the hour 
int TESMIN_RangeTight=9;              // pips smallest distance from market which TES is allowed to function

int TES_Safety=5;                      // pips to increment existing s/l at the beginning of the hour 
int TESMIN_Safety=15;                  // pips smallest distance from market which TES is allowed to function

int TES_Safety2=4;                     // pips to increment existing s/l at the beginning of the hour 
int TESMIN_Safety2=20;                 // pips smallest distance from market which TES is allowed to function

int TES_Safety3=4;                     // pips to increment existing s/l at the beginning of the hour 
int TESMIN_Safety3=20;                 // pips smallest distance from market which TES is allowed to function

int TES_RSIScalp=1;                    // pips to increment existing s/l at the beginning of the hour 
int TESMIN_RSIScalp=15;                // pips smallest distance from market which TES is allowed to function

int TES_Vegas=3;                       // pips to increment existing s/l at the beginning of the hour 
int TESMIN_Vegas=15;                   // pips smallest distance from market which TES is allowed to function

int TES_HrPerpetual=3;                       // pips to increment existing s/l at the beginning of the hour 
int TESMIN_HrPerpetual=15;                   // pips smallest distance from market which TES is allowed to function

int TES_Phoenix=1;                       // pips to increment existing s/l at the beginning of the hour 
int TESMIN_Phoenix=15;                   // pips smallest distance from market which TES is allowed to function

int TES_OsMA=1;                       // pips to increment existing s/l at the beginning of the hour 
int TESMIN_OsMA=15;                   // pips smallest distance from market which TES is allowed to function

int TES_30MinBO=1;                       // pips to increment existing s/l at the beginning of the hour 
int TESMIN_30MinBO=15;                   // pips smallest distance from market which TES is allowed to function

int TES_MACD=1;                       // pips to increment existing s/l at the beginning of the hour 
int TESMIN_MACD=15;                   // pips smallest distance from market which TES is allowed to function

int TES_EnvScalp1=5;                  // pips to increment existing s/l at the beginning of the hour 
int TESMIN_EnvScalp1=15;              // pips smallest distance from market which TES is allowed to function

int TES_Lot1_EnvScalp2=5;             // pips to increment existing s/l at the beginning of the hour 
int TESMIN_Lot1_EnvScalp2=15;         // pips smallest distance from market which TES is allowed to function
int TES_Lot2_EnvScalp2=2;             // pips to increment existing s/l at the beginning of the hour 
int TESMIN_Lot2_EnvScalp2=15;         // pips smallest distance from market which TES is allowed to function

int TES_EnvScalp3=3;                       // pips to increment existing s/l at the beginning of the hour 
int TESMIN_EnvScalp3=15;                   // pips smallest distance from market which TES is allowed to function

int TES_PMI30=2;                       // pips to increment existing s/l at the beginning of the hour 
int TESMIN_PMI30=15;                   // pips smallest distance from market which TES is allowed to function

int TES_PMI60=3;                       // pips to increment existing s/l at the beginning of the hour 
int TESMIN_PMI60=15;                   // pips smallest distance from market which TES is allowed to function

int TES_AweOsMA=1;                       // pips to increment existing s/l at the beginning of the hour 
int TESMIN_AweOsMA=15;                   // pips smallest distance from market which TES is allowed to function

int TES_RangeTightDay=1;              // pips to increment existing s/l at the beginning of the hour 
int TESMIN_RangeTightDay=15;          // pips smallest distance from market which TES is allowed to function

int TES_ADXTrend=2;                       // pips to increment existing s/l at the beginning of the hour 
int TESMIN_ADXTrend=15;                   // pips smallest distance from market which TES is allowed to function

int TES_HighProb=4;                       // pips to increment existing s/l at the beginning of the hour 
int TESMIN_HighProb=78;                   // pips smallest distance from market which TES is allowed to function

int TES_HighProb4=4;                       // pips to increment existing s/l at the beginning of the hour 
int TESMIN_HighProb4=78;                   // pips smallest distance from market which TES is allowed to function

int TES_StochADX=3;                       // pips to increment existing s/l at the beginning of the hour 
int TESMIN_StochADX=15;                   // pips smallest distance from market which TES is allowed to function

// Time Elapse Targets Variables:

int TET_AweOsMA=5;                     // pips to increment existing t/p at the beginning of the hour

// Pending Order Variables:

int PendingPip_MACD=20;                // stop
int PendingTime_MACD=18;               // hours for pending order expiration

int PendingPip_RSIScalp=15;            // limit 
int PendingTime_RSIScalp=4;            // hours for pending order expiration

int PendingPip_EnvScalp1=15;           // limit 
int PendingTime_EnvScalp1=6;           // hours for pending order expiration

int PendingPip_EnvScalp2=15;           // limit 
int PendingTime_EnvScalp2=6;           // hours for pending order expiration

int PendingPip_EnvScalp3=20;           // limit 
int PendingTime_EnvScalp3=6;           // hours for pending order expiration

int PendingPip_RangeTight1=15;         // stop
int PendingPip_RangeTight2=20;         // stop 
int PendingTime_RangeTight=6;          // hours for pending order expiration

int PendingPip_HighProb=35;            // limit 
int PendingTime_HighProb=12;            // hours for pending order expiration

int PendingPip_HighProb4=55;           // limit 
int PendingTime_HighProb4=6;           // hours for pending order expiration

 // -- 2nd Chance Models: --
int PendingPip_RSI2=19;                // limit 
int PendingTime_RSI2=11;               // hours for pending order expiration

int PendingPip_Sentiment=40;           // limit 
int PendingTime_Sentiment=2;           // hours for pending order expiration

 // -- 2nd Chance Models: --

// 10hrBO pending values are in 10hrBO section below
// RangeBO pending values are in RangeBO section below
// Phoenix pending values are in Phoenix section below
// ATRStopScalp pending values are in ATRStopScalp section below
// KeltnerScalp pending values are in KeltnerScalp section below

// D1 ATR Stops

int ATR_D1_Stops=71;                   // pips behind most recent ATR line for ATR D1 traling stops

// ===================================================================================
// 
// Model Parameters:
//
// ===================================================================================

// Secret MA Variables:

int MA1Period=1;                     // fast line (if MA1Period=1, Close will be used instead of MA)
int MA1Shift=0;                      // Shift
int MA1Timeframe=PERIOD_H1;          // Timeframe
int MA1Method=MODE_EMA;              // Mode
int MA1Price=PRICE_CLOSE;            // Method

int MA2Period=5;                     // slow line
int MA2Shift=25;                     // Shift ... *** Secret *** ... Shhh ...
int MA2Timeframe=PERIOD_H1;          // Timeframe
int MA2Method=MODE_LWMA;             // Mode
int MA2Price=PRICE_CLOSE;            // Method

int SecretMAATRstopWindowPeriod=7;  // hours in window of opportunity for ATR-Stop secondary trigger (array max 50)

int SecretMARSIPeriod=24;            // chop filter RSI period
int SecretMARSIPrice=PRICE_CLOSE;    // chop filter RSI price
double SecretMARSIhighlimit=75;      // upper RSI limit above which no orders are allowed
double SecretMARSIlowlimit=25;       // lower RSI limit below which no orders are allowed

int SecretMAEnvPeriod=40;            // Envelopes Period (order 3 exit)
int SecretMAEnvMethod=MODE_SMA;      // Envelopes Method
int SecretMAEnvShift=0;              // Envelopes Shift
int SecretMAEnvPrice=PRICE_CLOSE;    // Envelopes Price 
double SecretMAEnvDev=0.38;             // Envelopes Deviation

int BlackoutPeriodSecretMA=1;        // hours to blackout future SecretMA orders after one has occurred

datetime OrderTimeSecretMA=0;        // stores time of latest SecretMA order
int checktimeSecretMA=0;             // stores time remaining in SecretMA blackout
bool flag_orderSecretMA=true;        // true if NO Secret MA orders are open
bool flag_ExitOrderSecretMALong=false;  // true if long exit triggered
bool flag_ExitOrderSecretMAShort=false; // true if short exit triggered
bool flag_ExitOrderSecretMA3Long=false; // true if long exit triggered (Envelopes order 3)
bool flag_ExitOrderSecretMA3Short=false;// true if short exit triggered (Envelopes order 3)
int SecretMAskipLong=0;         // true if long secondary trigger failed
int SecretMAskipShort=0;        // true if short secondary trigger failed
int SecretMANumber=0;                     // number of orders (for ATRStop chop reducer which limits 1 order per ATRStop)

// MACD Variables:

int ATRWindowMACD=10;                // hours in MACD ATR-window-of-opportunity
int ExitATR_MACD=99;                 // pips from following line for ATR exit
int EnterATR_MACD=7;                 // pips from next line for ATR entrance trigger

int MACDfast=12;                     // MACD ema fast period
int MACDslow=30;                     // MACD ema slow period
int MACDsignal=17;                   // MACD sma signal period
int MACDTimeframe=PERIOD_H1;         // Timeframe

int BlackOutPeriodMACD=3;            // number of periods after MACD trigger to ignore additional signals
int BlackOutPeriodPendMACD=3;        // number of periods after pending MACD trigger to ignore additional signals

double TriggerMACD=0.0010;           // Value for MACD trigger
double DivisionLineMACD=0.0;         // Value for MACD division line separating bull/bear territories
datetime OrderTimeMACDLong;          // stores time of last MACD long order
datetime OrderTimeMACDShort;         // stores time of  MACD short order
datetime OrderTimeMACDPendLong=0;    // stores time of last MACD long pending order
datetime OrderTimeMACDPendShort=0;   // stores time of last MACD short pending order
int checktimeMACD=0;                 // stores time remaining in MACD blackout
bool flag_orderMACD=true;            // true if NO MACD orders
bool flag_ExitOrderMACDLong=false;   // true if long exit conditions met
bool flag_ExitOrderMACDShort=false;  // true if short exit conditions met

// 10hrBO Variables:

int BlackOutHourBegin10hrBO=2;       // hour to begin blackout of 10hrBO
int BlackOutHourEnd10hrBO=7;         // hour to end blackout of 10hrBO (set to -1 to turn off)

int MA10hrBOTimeframe=PERIOD_H1;      // Timeframe

int MA10hrBOslowPeriod=10;            // SMA(10) acts as base line for 10hrBO
int MA10hrBOslowShift=9;              // Shift
int MA10hrBOslowMethod=MODE_SMA;      // Mode
int MA10hrBOslowPrice=PRICE_TYPICAL;  // Method
int MA10hrBOslowSmoothPeriod=5;       // smoothing period for Zero-lag MA
int MA10hrBOslowSmoothShift=0;        // Shift
int MA10hrBOslowSmoothMethod=MODE_EMA;// Mode

int MA10hrBOveryslowPeriod=10;         // SMA(25) acts as exit line for 10hrBO (non-trend, Order 2)
int MA10hrBOveryslowShift=4;           // Shift
int MA10hrBOveryslowMethod=MODE_SMMA;  // Mode
int MA10hrBOveryslowPrice=PRICE_CLOSE; // Method

int TriggerPips10hrBO=29;              // pips above 10hrSMA/price cross to execute order (trigger) (pending price)
int TriggerPips10hrBORS=5;             // pips from support/resistance cross to execute pending order (pending price) (farthest price is chosen)
int WindowPeriod10hrBO=2;              // number of periods after 10hrBO trigger for window of opportunity (array max 10)

int BlackOutPeriod10hrBO=2;            // hours to ignore future triggers after order execution (pending expiration)
int MinimumLifetime10hrBO=3;           // hours minimum before a new pending order can cancel out an existing unprofitable order 

int ADX10hrBOTimeframe=PERIOD_H1;      // Timeframe ADX (for Order 1 non-trend exits)
int ADX10hrBOPeriod=70;                // Period ADX
int ADX10hrBOPrice=PRICE_OPEN;         // Method ADX

datetime OrderTime10hrBO=0;            // time of last 10hrBO order
bool flag_ExitOrder10hrBOPL=false;     // true if short cross condition is met
bool flag_ExitOrder10hrBOPS=false;     // true if long cross condition is met
bool flag_ExitOrder10hrBOXL=false;     // true if exit MA X long exit condition is met
bool flag_ExitOrder10hrBOXS=false;     // true if exit MA X short exit condition is met
bool flag_ExitOrder10hrBOADXL=false;   // true if exit MA X long exit condition is met
bool flag_ExitOrder10hrBOADXS=false;   // true if exit MA X short exit condition is met
bool flag_order10hrBO=true;            // true if NO 10hrBO order in play


// 10 day BO Variables:

int MA10dayBOslowPeriod=10;           // SMA(10) acts as base line for 10 day BO
int MA10dayBOslowTimeframe=PERIOD_D1; // Timeframe Period = D1
int MA10dayBOslowShift=0;             // Shift
int MA10dayBOslowMethod=MODE_SMA;     // Mode
int MA10dayBOslowPrice=PRICE_CLOSE;   // Method

int MA10dayBOMonitorTimeframe=PERIOD_D1; // Timeframe for monitoring of previous day's close

int SD10dayBOTimeframe=PERIOD_D1;     // Timeframe for SD filter
int SD10dayBOPeriod=20;               // standard deviation Period
int SD10dayBOShift=0;                 // standard deviation Shift
int SD10dayBOMethod=MODE_SMA;         // standard deviation Method
int SD10dayBOPrice=PRICE_CLOSE;       // standard deviation Price

double SD10dayBOLevel=0.0150;         // minimum SD level permitted to trigger

int TriggerPips10dayBO=230;           // pips above 10daySMA to execute 10 day cross method
int ExitPips10dayBO=20;               // pips above/below 10day SMA to exit 10 day cross orders
int BlackOutPeriod10dayBO=2;          // days after an order is executed during which to ignore future signals in the same direction
bool flag_order10dayBO=true;          // true if NO 10dayBO order is open
datetime LongOrderTime10dayBO=0;      // time of most recent long 10 day BO order 
datetime ShortOrderTime10dayBO=0;     // time of most recent short 10 day BO order
int checktime10dayBOLong=0;           // stores time remaining in 10dayBO long blackout 
int checktime10dayBOShort=0;          // stores time remaining in 10dayBO short blackout 
bool crossup;                         // TRUE if prices are above SMA(10)

// Safety Model's Variables

double SafetySDPrimaryTrigger=0.0010;   // maximum value of standard deviation for Primary trigger
double SafetySDSecondaryTrigger=0.0025; // maximum value of standard devitaion for Secondary trigger

int SafetySDPeriod=20;                // standard deviation Period
int SafetySDShift=0;                  // standard deviation Shift
int SafetySDMethod=MODE_SMA;          // standard deviation Method
int SafetySDPrice=PRICE_LOW;        // standard deviation Price

double SafetyOsMALimitLong= -0.000850;    // no long orders for OsMA more negative than this
double SafetyOsMALimitShort= 0.000850;    // no short orders for OsMA more positive than this

int SafetyOsMAfastPeriod=16;          // OsMA fast Period
int SafetyOsMAslowPeriod=38;          // OsMA slow Period
int SafetyOsMAsignalPeriod=9;         // OsMA signal Period
int SafetyOsMAPrice=PRICE_CLOSE;      // OsMA applied Price

int SafetyATRPeriod=10;               // hours to scan for a touch of lines 2/6 to qualify for primary non-trend entrance
int SafetyATRTrendPeriod=3;           // hours to scan for a confirmed cross of lines 2/6 to qualify for primary trend entrance

int SafetyATRLongEnterLine=3;         // ATR line to trigger longs (non-trend)
int SafetyATRShortEnterLine=5;        // ATR line to trigger shorts (non-trend)

int SafetyTrigger1=4;                 // pips above/below Safety ATR Long/Short Enter Lines to activate method
int SafetyTrigger2=4;                 // pips outside of Safety ATR Long/Short Exit Lines to change contrary positions' s/l to b/e

int SafetyATRLongExitLine1=4;         // ATR line to exit Order 1 longs (non-trend, trend)
int SafetyATRLongExitLine2=5;         // ATR line to exit Order 2 & 3 longs (non-trend, trend-Order 2)

int SafetyATRShortExitLine1=4;        // ATR line to exit Order 1 shorts (non-trend, trend)
int SafetyATRShortExitLine2=3;        // ATR line to exit Order 2 & 3 shorts (non-trend, trend-Order 2)

int SafetyTimeframe=PERIOD_H1;        // Timeframe Period = H1

int BlackoutPeriodSafety=5;          // hours in which to ignore further Safety orders after an order is submitted

int ATR_Safety_Period=18;             // ATR period for Safety
int ATR_Safety_MAPeriod=48;           // ATR MA period for Safety
int ATR_Safety_MAShift=0;             // ATR MA shift for Safety
int ATR_Safety_MAMethod=MODE_LWMA;    // ATR MA method for Safety
int ATR_Safety_MAPrice=PRICE_TYPICAL; // ATR MA price for Safety

bool flag_orderSafety=true;           // true if NO Safety order is open
bool flag_orderSafetyLong=true;       // true if NO Safety long order is open
bool flag_orderSafetyShort=true;      // true if NO Safety short order is open
bool flag_orderSafety2Long=true;      // true if NO Safety 2 long order is open (needed for extra Order 3 exit consideration at ATR lines 2/6)
bool flag_orderSafety2Short=true;     // true if NO Safety 2 short order is open (needed for extra Order 3 exit consideration at ATR lines 2/6)
bool flag_ExitOrderSafety1Long=false; // true if long exit trigger hit
bool flag_ExitOrderSafety1Short=false;// true if short exit trigger hit
bool flag_ExitOrderSafety2Long=false; // true if long exit trigger hit
bool flag_ExitOrderSafety2Short=false;// true if short exit trigger hit
datetime OrderTimeSafetyLong=0;       // stores Safety long order's open time
datetime OrderTimeSafetyShort=0;      // stores Safety short order's open time 
int checktimeSafety=0;                // stores time remaining in Safety blackout
int ExitTimeSafetyLong=0;             // stores time of short re-entrance (to signal end of hour exits)
int ExitTimeSafetyShort=0;            // stores time of long re-entrance (to signal end of hour exits)
int SafetyPrimary=0;                  // stroes switch to indicate whether primary or touch entratnce has occured (needed for Fixed Stop A condition)
int SafetyCounter=0;                  // stroes switch to indicate whether main or counter entratnce has occured (needed for Safety Order 2 Line 4 exit)
int Safety2Line4Exit=0;               // stroes switch to indicate Safety Order 2 Line 4 exit

// Safety2 Model's Variables

int Safety2Trigger=2;                 // pips close above ATR lines 2/6 which trigger Safety2 orders

int Safety2Timeframe=PERIOD_H1;       // Timeframe Period = H1

int BlackoutPeriodSafety2=5;          // hours in which to ignore further Safety2 orders after an order is submitted

bool flag_orderSafety2=true;          // true if NO Safety2 order is open
bool flag_ExitOrderSafety21Long=false; // true if long exit trigger hit
bool flag_ExitOrderSafety21Short=false;// true if short exit trigger hit
datetime OrderTimeSafety2=0;           // stores Safety2 order's open time
int Safety2AllowLong=0;                // flags to signal ATR Line 4 passage (to ensure only 1 order per Line 4 passage)
int Safety2AllowShort=0;               // flags to signal ATR Line 4 passage (to ensure only 1 order per Line 4 passage) 

// Safety3 Model's Variables

int Safety3Timeframe=PERIOD_H1;        // Timeframe Period = H1

int WindowPeriodSafety3=4;            // Window of opportunity for Area 1/6 close

int Safety3ATRLongExitLine=1;          // ATR line emergency exit all longs
int Safety3ATRLongExitLine1=4;         // ATR line to exit Order 1 longs 
int Safety3ATRLongExitLine2=5;         // ATR line to exit Order 2 longs 
int Safety3ATRLongExitLine3=6;         // ATR line to exit Order 3 longs 

int Safety3ATRShortExitLine=7;         // ATR line emergency exit all shorts
int Safety3ATRShortExitLine1=4;        // ATR line to exit Order 1 shorts 
int Safety3ATRShortExitLine2=3;        // ATR line to exit Order 2 shorts
int Safety3ATRShortExitLine3=2;        // ATR line to exit Order 3 shorts

int BlackoutPeriodSafety3=5;          // hours in which to ignore further Safety3 orders after an order is submitted

int ATR_Safety3_Period=18;             // ATR period for Safety3
int ATR_Safety3_MAPeriod=48;           // ATR MA period for Safety3
int ATR_Safety3_MAShift=0;             // ATR MA shift for Safety3
int ATR_Safety3_MAMethod=MODE_LWMA;    // ATR MA method for Safety3
int ATR_Safety3_MAPrice=PRICE_TYPICAL; // ATR MA price for Safety3

double Safety3SDMAX =0.00650;           // standard deviation maximum value, above which to deactivate order entries

int Safety3SDPeriod=20;                 // standard deviation Period
int Safety3SDShift=0;                   // standard deviation Shift
int Safety3SDMethod=MODE_SMA;           // standard deviation Method
int Safety3SDPrice=PRICE_LOW;           // standard deviation Price

bool flag_orderSafety3=true;           // true if NO Safety3 order is open
bool flag_orderSafety3Long=true;       // true if NO Safety3 long order is open (needed for extra Order 3 exit consideration at ATR lines 2/6)
bool flag_orderSafety3Short=true;      // true if NO Safety3 short order is open (needed for extra Order 3 exit consideration at ATR lines 2/6)
bool flag_ExitOrderSafety31Long=false; // true if long exit trigger hit
bool flag_ExitOrderSafety31Short=false;// true if short exit trigger hit
bool flag_ExitOrderSafety32Long=false; // true if long exit trigger hit
bool flag_ExitOrderSafety32Short=false;// true if short exit trigger hit
bool flag_ExitOrderSafety33Long=false; // true if long exit trigger hit
bool flag_ExitOrderSafety33Short=false;// true if short exit trigger hit
bool flag_ExitOrderSafety3Long=false;  // true if long exit trigger hit - emergency area 1 exits
bool flag_ExitOrderSafety3Short=false; // true if short exit trigger hit - emergency area 6 exits
datetime OrderTimeSafety3=0;           // stores Safety3 order open time

// Reversal Model's Variables

int ReversalTimeframe=PERIOD_H1;     // BB Timeframe

int ATRWindowReversal=3;            // hours in Reversal ATR-window-of-opportunity
int ExitATR_Reversal=15;             // pips from "following" line for ATR exit
int EnterATR_Reversal=8;             // pips from next line for ATR entrance trigger

int PeriodReversal=24;               // hours in scanning period to determine whether subsequent high is a maximum
int TriggerReversal=20;              // pips above/below subsequent hour's low/high to trigger order execution
int BlackoutPeriodReversal=6;        // hours after the submission of a Reversal order to avoid sending another order

int ReversalMA1Period=5;             // fast line for Reversal chop-reducer
int ReversalMA1Shift=0;              // Shift
int ReversalMA1Timeframe=PERIOD_H1;  // Timeframe
int ReversalMA1Method=MODE_EMA;      // Mode
int ReversalMA1Price=PRICE_CLOSE;    // Method

int ReversalMA2Period=29;            // slow line for Reversal chop-reducer
int ReversalMA2Shift=0;              // Shift
int ReversalMA2Timeframe=PERIOD_H1;  // Timeframe
int ReversalMA2Method=MODE_EMA;      // Mode
int ReversalMA2Price=PRICE_CLOSE;    // Method

int ReversalBBPeriod=20;               // BB Period for Part 2 trigger
int ReversalBBDeviation=2;             // BB Deviation
int ReversalBBBandsShift=0;            // BB Bands-Shift
int ReversalBBPrice=PRICE_CLOSE;       // BB Method

datetime OrderTimeReversal1Long;      // stores time of last Reversal long order
datetime OrderTimeReversal1Short;     // stores time of last Reversal short order
datetime OrderTimeReversal2Long;      // stores time of last Reversal long order
datetime OrderTimeReversal2Short;     // stores time of last Reversal short order
datetime OrderTimeReversal3;          // stores time of last Reversal Order 3, 4
bool flag_orderReversal=true;         // stores true if NO Reversal order is open
bool flag_orderReversal3=true;        // stores true if NO Reversal Order 3, 4 is open
bool flag_orderReversal1Long=true;    // stores true if NO Reversal long order is open
bool flag_orderReversal1Short=true;   // true if NO Reversal short order is open
bool flag_orderReversal2Long=true;    // stores true if NO Reversal long order is open
bool flag_orderReversal2Short=true;   // true if NO Reversal short order is open
int checktimeReversal=0;             // stores time remaining in Reversal blackout
bool flag_ExitOrderReversal1Long=false;   // true if long exit conditions met
bool flag_ExitOrderReversal1Short=false;  // true if short exit conditions met
bool flag_ExitOrderReversal3Long=false;   // true if long exit conditions met
bool flag_ExitOrderReversal3Short=false;  // true if short exit conditions met
bool flag_ExitOrderReversal4Long=false;   // true if long exit conditions met
bool flag_ExitOrderReversal4Short=false;  // true if short exit conditions met

// DoubleTops Model's Variables

int PeriodDoubleTops=16;             // days to scan for daily high/low 
int TriggerDoubleTops=75;            // pips range within high/low of a new 15 day high/low 

bool flag_orderDoubleTops=true;      // true if NO DoubleTops order is open
int BlackoutPeriodDoubleTops=1;      // days to prevent a new DoubleTop order from the time of the last one
datetime OrderTimeDoubleTopsLong=0;  // time of last DoubleTops long order
datetime OrderTimeDoubleTopsShort=0; // time of last DoubleTops short order
int checktimeDoubleTops=0;           // stores time remaining in DoubleTops blackout

// OsMA1 Model's Variables

int OsMATimeframe=PERIOD_H1;       // OsMA Timeframe

int BlackOutHourBeginOsMA=20;      // hour to begin blackout of OsMA
int BlackOutHourEndOsMA=23;        // hour to end blackout of OsMA (set to -1 to turn off)

int WindowPeriodOsMA11=36;          // hours in window of opportunity for OsMA Part 1
int WindowPeriodOsMA12=10;           // hours in window of opportunity for OsMA Part 2

int EmergencyExitPeriodOsMA=2;     // hours in exit window to check for contrary close Part 1 & 2

int OsMAfast=135;                   // OsMA EMA fast period
int OsMAslow=30;                    // OsMA EMA slow period
int OsMAsignal=12;                  // OsMA SMA signal period
int OsMAprice=PRICE_CLOSE;          // OsMA price

double LimitOsMA1Long = -0.00020;   // Limit for OsMA long trigger Part 1
double LimitOsMA1Short=  0.00020;   // Limit for OsMA short trigger Part 1

double LimitOsMA2Long =  0.00110;   // Limit for OsMA long trigger Part 2
double LimitOsMA2Short= -0.00110;   // Limit for OsMA short trigger Part 2

int OsMAADXperiod=1;               // ADX period
int OsMAADXprice=PRICE_OPEN;        // ADX price
 
double DivisionLineOsMA=0.0;        // Value for OsMA bull/bear line

int BlackoutPeriodOsMA=0;           // hours to prevent a new OsMA order 

bool flag_orderOsMA11=true;          // true if NO OsMA order Part 1
bool flag_orderOsMA11Long=true;      // true if NO OsMA long order Part 1
bool flag_orderOsMA11Short=true;     // true if NO OsMA short order Part 1
bool flag_orderOsMA12=true;          // true if NO OsMA order Part 2
bool flag_orderOsMA12Long=true;      // true if NO OsMA long order Part 2
bool flag_orderOsMA12Short=true;     // true if NO OsMA short order Part 2
datetime OrderTimeOsMA11=0;          // stores time of last OsMA order Part 1
datetime OrderTimeOsMA12=0;          // stores time of last OsMA order Part 2
int checktimeOsMA11=0;               // stores time remaining in OsMA blackout Part 1
int checktimeOsMA12=0;               // stores time remaining in OsMA blackout Part 2
bool flag_ExitOrderOsMALong11=false;   // true if long exit conditions met Part 1
bool flag_ExitOrderOsMALong12=false;   // true if long exit conditions met Part 2
bool flag_ExitOrderOsMAShort11=false;  // true if short exit conditions met Part 1
bool flag_ExitOrderOsMAShort12=false;  // true if short exit conditions met Part 2

// OsMA2 Model's Variables

int BlackOutHourBeginOsMA2=7;      // hour to begin blackout of OsMA2
int BlackOutHourEndOsMA2=11;        // hour to end blackout of OsMA2 (set to -1 to turn off)

int WindowPeriodOsMA21=32;          // hours in window of opportunity for OsMA2 Part 1
int WindowPeriodOsMA22=8;           // hours in window of opportunity for OsMA2 Part 2
int WindowPeriodOsMA23=2;           // hours in window of opportunity for OsMA2 Part 3

int EmergencyExitPeriodOsMA2=2;     // hours in exit window to check for contrary close Part 1 & 2

int OsMA2Timeframe=PERIOD_H1;       // OsMA2 Timeframe

int OsMA2fast=13;                   // OsMA2 EMA fast period
int OsMA2slow=19;                   // OsMA2 EMA slow period
int OsMA2signal=6;                  // OsMA2 SMA signal period
int OsMA2price=PRICE_CLOSE;      // OsMA2 price

double LimitOsMA21Long = -0.00020;   // Limit for OsMA2 long trigger Part 1
double LimitOsMA21Short=  0.00020;   // Limit for OsMA2 short trigger Part 1

double LimitOsMA22Long =  0.00010;   // Limit for OsMA2 long trigger Part 2
double LimitOsMA22Short= -0.00010;   // Limit for OsMA2 short trigger Part 2

int OsMA2ADXperiod=14;               // ADX period
int OsMA2ADXprice=PRICE_OPEN;        // ADX price

int OsMA2qPeriod = 4;                // q Period for DS_Stochastics
int OsMA2rPeriod = 28;               // r Period for DS_Stochastics
int OsMA2EMAfast = 7;                // EMA fast for DS_Stochastics
int OsMA2CountBars = 400;            // Count Bars for DS_Stochastics
 
double DivisionLineOsMA2=0.0;        // Value for OsMA2 bull/bear line

int BlackoutPeriodOsMA2=0;           // hours to prevent a new OsMA2 order 

bool flag_orderOsMA21=true;          // true if NO OsMA2 order Part 1
bool flag_orderOsMA21Long=true;      // true if NO OsMA2 long order Part 1
bool flag_orderOsMA21Short=true;     // true if NO OsMA2 short order Part 1
bool flag_orderOsMA22=true;          // true if NO OsMA2 order Part 2
bool flag_orderOsMA22Long=true;      // true if NO OsMA2 long order Part 2
bool flag_orderOsMA22Short=true;     // true if NO OsMA2 short order Part 2
bool flag_orderOsMA23=true;          // true if NO OsMA2 order Part 3
bool flag_orderOsMA23Long=true;      // true if NO OsMA2 order Part 3 ADX extra order
bool flag_orderOsMA23Short=true;     // true if NO OsMA2 order Part 3 ADX extra order
datetime OrderTimeOsMA21=0;          // stores time of last OsMA2 order Part 1
datetime OrderTimeOsMA22=0;          // stores time of last OsMA2 order Part 2
datetime OrderTimeOsMA23=0;          // stores time of last OsMA2 order Part 3
int checktimeOsMA21=0;               // stores time remaining in OsMA2 blackout Part 1
int checktimeOsMA22=0;               // stores time remaining in OsMA2 blackout Part 2
int checktimeOsMA23=0;               // stores time remaining in OsMA2 blackout Part 3
bool flag_ExitOrderOsMA2Long1=false;   // true if long exit conditions met Part 1
bool flag_ExitOrderOsMA2Long2=false;   // true if long exit conditions met Part 2
bool flag_ExitOrderOsMA2Short1=false;  // true if short exit conditions met Part 1
bool flag_ExitOrderOsMA2Short2=false;  // true if short exit conditions met Part 2

// 30 Minute Breakout Model's Variables

int BlackOutHourBegin30MinBO=2;     // hour to begin blackout of 30MinBC
int BlackOutHourEnd30MinBO=8;       // hour to end blackout of 30MinBC (set to -1 to turn off)

int Timeframe30MinBO=PERIOD_M30;     // Timeframe for 30MinBO
int Trigger30MinBO=39;               // pips to trigger 30MinBO

int MA30MinBOchop1Period=12;           // fast chop-reducer line for 30MinBO
int MA30MinBOchop1Shift=0;            // Shift
int MA30MinBOchop1Method=MODE_EMA;    // Mode
int MA30MinBOchop1Price=PRICE_CLOSE;  // Method

int MA30MinBOchop2Period=19;          // slow chop-reducer line for 30MinBO
int MA30MinBOchop2Shift=0;            // Shift
int MA30MinBOchop2Method=MODE_SMA;    // Mode
int MA30MinBOchop2Price=PRICE_CLOSE;  // Method

bool flag_order30MinBO=true;         // true if NO 30MinBO order

int BlackoutPeriod30MinBO=28;        // M30 periods to prevent a new 30MinBO order
datetime OrderTime30MinBO=0;         // time of last 30MinBO order
int checktime30MinBO=0;              // stores time remaining in 30MinBO blackout

// RSI Sclaper Model's Variables

int RSIScalpTimeframe=PERIOD_H1;     // timeframe for RSIScalp

double RSIveryhigh=73.0;             // very high RSI value (Orders 1, 2, sell on bearish ZLMA X) (Double lots)
double RSIhigh=65.0;                 // high RSI value      (Orders 1, 2, sell on bearish ZLMA X) (Single lots)
double RSIlow=35.0;                  // low RSI value       (Orders 1, 2, buy  on bullish ZLMA X) (Single lots)
double RSIverylow=27.0;              // very low RSI value  (Orders 1, 2, buy  on bullish ZLMA X) (Double lots)

double RSIhigh3=60.0;                // high RSI value      (Order 3, buy on bullish ZLMA X)
double RSIlow3=40.0;                 // low RSI value       (Order 3, sell on bearish ZLMA X)

double RSIexitlong=76.0;             // exit RSI value for longs
double RSIexitshort=28.0;            // exit RSI value for shorts

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

// RSI2 (Descending Highs, Ascending Lows) Sclaper Model's Variables

int WindowPeriod1RSI2=17;             // hours in window of opportunity for RSI2 order trigger
int WindowPeriod2RSI2=25;             // hours in window of opportunity for RSI2 DH/AL formation

double RSI2high=62;                   // upper RSI trigger line
double RSI2low=38;                    // lower RSI trigger line

double RSI2rangeMin=0.20;              // RSI2 minimum range for movements
double RSI2rangeMax=3.5;              // RSI2 maximum range for movements

double RSI2rangeReturn1=0.20;          // RSI2 return range for movements between RSIrangeMin and RSIrangeMax
double RSI2rangeReturn2=1.25;          // RSI2 return range for movements exceeding RSIrangeMax

int RSI2Timeframe=PERIOD_H1;          // RSI2 timeframe
int RSI2Period=16;                    // RSI2 period
int RSI2Price=PRICE_CLOSE;            // RSI2 price

bool flag_orderRSI2=true;             // true if NO RSI2 Scalper order
int BlackoutPeriodRSI2=15;             // hours to prevent a new RSI2 Scalper order
datetime OrderTimeRSI2=0;             // time of last RSI2 Scalper order
int checktimeRSI2=0;                  // stores time remaining in RSI2 Scalper's blackout
bool flag_ExitOrderRSI2PLong=false;    // true if long exit trigger for pending order cancelation
bool flag_ExitOrderRSI2PShort=false;   // true if short exit trigger for pending order cancelation

// Daily Reversal Model's Variables

int PeriodDayReversal=12;              // days in scanning range to determine new high
int TriggerDayReversal=110;            // pips below high/ above low at which to trigger primary order 
int ATRTriggerDayReversal=89;          // pips in front of next line to trigger secondary order

int WindowPeriodDayReversal=2;         // days of window of opportunity for Daily Reversal primary trigger
int ATRWindowDayReversal=6;            // days of window of opportunity for ATR secondary trigger
int BlackOutPeriodDayReversal=16;      // days to prevent a new Daily Reversal order (1&2 independent of 3)
int BlackOutPeriodDayReversalExit=1;   // days to prevent a Daily Reversal exit after order initiation

bool flag_orderDayReversal=true;       // true if NO Daily Reversal order
bool flag_orderDayReversal1Long=true;  // true if NO Daily Reversal long order 1,2
bool flag_orderDayReversal1Short=true; // true if NO Daily Reversal short order 1,2
bool flag_orderDayReversal3Long=true;  // true if NO Daily Reversal long order 3
bool flag_orderDayReversal3Short=true; // true if NO Daily Reversal short order 3
bool flag_ExitOrderDayReversal1Long=false;  // lot 1 long exit
bool flag_ExitOrderDayReversal1Short=false; // lot 1 short exit
bool flag_ExitOrderDayReversal2Long=false;  // lot 2 long exit
bool flag_ExitOrderDayReversal2Short=false; // lot 2 short exit
bool flag_ExitOrderDayReversal3Long=false;  // lot 3 long exit
bool flag_ExitOrderDayReversal3Short=false; // lot 3 short exit 
datetime OrderTimeDayReversal1Long=0;  // stores time of last Daily Reveral order 1,2
datetime OrderTimeDayReversal1Short=0; // stores time of last Daily Reveral order 1,2
datetime OrderTimeDayReversal3Long=0;  // stores time of last Daily Reveral order 3
datetime OrderTimeDayReversal3Short=0; // stores time of last Daily Reveral order 3

// HrPerpetual Variables:

int HrPerpetualTimeframe=PERIOD_H1;      // Timeframe

int HrPerpetual1Period=12;               // fast line
int HrPerpetual1Shift=4;                 // Shift
int HrPerpetual1Method=MODE_SMA;         // Mode
int HrPerpetual1Price=PRICE_CLOSE;       // Method
int HrPerpetual1SmoothPeriod=21;         // fast smoothing period for Zero-lag MA
int HrPerpetual1SmoothShift=0;           // Shift
int HrPerpetual1SmoothMethod=MODE_SMMA;   // Mode

int HrPerpetual2Period=200;               // slow line
int HrPerpetual2Shift=0;                 // Shift
int HrPerpetual2Method=MODE_EMA;         // Mode
int HrPerpetual2Price=PRICE_CLOSE;       // Method
int HrPerpetual2SmoothPeriod=400;         // slow smoothing period for Zero-lag MA
int HrPerpetual2SmoothShift=0;           // Shift
int HrPerpetual2SmoothMethod=MODE_EMA;   // Mode

int BlackoutPeriodHrPerpetual=1;         // hours to blackout future HrPerpetual orders after one has occurred

int checktimeHrPerpetual=0;                // stores time remaining in HrPerpetual blackout
datetime OrderTimeHrPerpetual=0;           // stores time of latest HrPerpetual order
bool flag_orderHrPerpetual=true;           // true if NO HrPerpetual orders are open
bool flag_ExitOrderHrPerpetualLong=false;  //true if exit long triggered
bool flag_ExitOrderHrPerpetualShort=false; //true if exit short triggered

// MACDSwing (Daily) Variables

int ATRTriggerMACDSwing=81;          // pips in front of next line to trigger secondary order

int MACDSwingfast=11;                // MACDSwing ema fast period
int MACDSwingslow=24;                // MACDSwing ema slow period
int MACDSwingsignal=9;               // MACDSwing sma signal period
int MACDSwingTimeframe=PERIOD_D1;    // Timeframe

double DivisionLineMACDSwing=0.0;    // Value for MACDSwing division line separating bull/bear territories

int ATRWindowMACDSwing=5;           // days of window of opportunity for ATR secondary trigger
int BlackOutPeriodMACDSwing=2;       // number of days after MACDSwing trigger to ignore additional signals

bool flag_orderMACDSwing=true;       // true if NO MACDSwing order
bool flag_orderMACDSwing1Long=true;  // true if NO MACDSwing long order 1,2
bool flag_orderMACDSwing1Short=true; // true if NO MACDSwing short order 1,2
bool flag_orderMACDSwing3Long=true;  // true if NO MACDSwing long order 3
bool flag_orderMACDSwing3Short=true; // true if NO MACDSwing short order 3
bool flag_ExitOrderMACDSwing1Long=false;  // lot 1 long exit
bool flag_ExitOrderMACDSwing1Short=false; // lot 1 short exit
bool flag_ExitOrderMACDSwing2Long=false;  // lot 2 long exit
bool flag_ExitOrderMACDSwing2Short=false; // lot 2 short exit
//bool flag_ExitOrderMACDSwing3Long=false;  // lot 3 long exit
//bool flag_ExitOrderMACDSwing3Short=false; // lot 3 short exit 
datetime OrderTimeMACDSwing1Long=0;  // stores time of last Daily Reveral order 1,2
datetime OrderTimeMACDSwing1Short=0; // stores time of last Daily Reveral order 1,2
datetime OrderTimeMACDSwing3Long=0;  // stores time of last Daily Reveral order 3
datetime OrderTimeMACDSwing3Short=0; // stores time of last Daily Reveral order 3

// MA Scalp Model

int MAScalpTimeframe=PERIOD_H1;      // Timeframe

int MAScalp1Period=9;               // fast line
int MAScalp1Shift=0;                 // Shift
int MAScalp1Method=MODE_EMA;         // Mode
int MAScalp1Price=PRICE_CLOSE;       // Method
int MAScalp1SmoothPeriod=1;          // fast smoothing period for Zero-lag MA
int MAScalp1SmoothShift=0;           // Shift
int MAScalp1SmoothMethod=MODE_EMA;   // Mode

int MAScalp2Period=27;               // slow line
int MAScalp2Shift=0;                 // Shift
int MAScalp2Method=MODE_EMA;         // Mode
int MAScalp2Price=PRICE_CLOSE;       // Method
int MAScalp2SmoothPeriod=6;          // slow smoothing period for Zero-lag MA
int MAScalp2SmoothShift=0;           // Shift
int MAScalp2SmoothMethod=MODE_EMA;   // Mode

int WindowPeriodMAScalp=1;            // hours in window-of-opportunity for Triggerlines to become friendly (array max 10)

int MAScalpRPeriod=3;                 // R period for Triggerlines custom indicator
int MAScalpLSMAPeriod=2;              // LSMA period for Triggerlines custom indicator

int BlackoutPeriodMAScalp=7;          // hours to prevent a new MAScalp order
datetime OrderTimeMAScalp=0;          // stores time of last MAScalp order
int checktimeMAScalp=0;               // stores time remaining in MAScalp blackout
bool flag_orderMAScalpLong=true;      // true if MAScalp long order
bool flag_orderMAScalpShort=true;     // true if MAScalp short order
bool flag_ExitOrderMAScalpLong=false; //true if exit long triggered
bool flag_ExitOrderMAScalpShort=false;//true if exit short triggered

// Sentiment Variables:

int SentimentTimeframe=PERIOD_H4;    // timeframe

int SentimentOsMAfast=10;             // OsMA fast period
int SentimentOsMAslow=46;            // OsMA slow period 
int SentimentOsMAsignal=12;           // OsMA signal period
int SentimentOsMAPrice=PRICE_CLOSE;  // OsMA price

int SentimentASCTrendRisk=3;         // ASCTrend (H4) Risk

int WindowPeriodSentiment=14;         // H4 periods in window-of-opportunity for primary triggers 
int BlackoutPeriodSentiment=1;       // H4 periods after last order to ignore additional signals

bool flag_orderSentiment=true;       // true if NO Sentiment orders
bool flag_orderSentimentL=true;       // true if NO Sentiment 1,2 long orders
bool flag_orderSentimentS=true;       // true if NO Sentiment 1,2 short orders
datetime OrderTimeSentiment=0;       // stores time of last Sentiment order 1, 2
datetime OrderTimeSentiment3=0;       // stores time of last Sentiment order 3
bool flag_ExitOrderSentimentLong=false;   // true if long exit conditions met
bool flag_ExitOrderSentimentShort=false;  // true if short exit conditions met

// ADXDay Model's Variables

int WindowPeriodADXDay=1;          // days in window of opportunity for ADXDay

int ADXDayOsMAfast=12;             // ADXDay OsMA EMA fast period
int ADXDayOsMAslow=18;             // ADXDay OsMA EMA slow period
int ADXDayOsMAsignal=9;            // ADXDay OsMA SMA signal period
int ADXDayOsMAprice=PRICE_CLOSE;   // ADXDay OsMA price

int ADXDayADXperiod=16;            // ADXDay ADX period
int ADXDayADXprice=PRICE_OPEN;     // ADXDay ADX price
 
int BlackoutPeriodADXDay=2;           // days to prevent a new ADXDay order 

datetime OrderTimeADXDay=0;            // stores time of last ADXDay order
bool flag_ExitOrderADXDayLong=false;   // true if long exit conditions met
bool flag_ExitOrderADXDayShort=false;  // true if long exit conditions met
bool flag_orderADXDay=true;            // true if NO ADXDay orders

// MADoubleX Model

int MADoubleXTimeframe=PERIOD_H1;      // Timeframe

int MADoubleXPeriod=21;               // Period Zero-lag MA
int MADoubleXShift=0;                 // Shift
int MADoubleXMethod=MODE_EMA;         // Mode
int MADoubleXPrice=PRICE_CLOSE;       // Method
int MADoubleXSmoothPeriod=19;          // fast smoothing period for Zero-lag MA
int MADoubleXSmoothShift=0;           // Shift
int MADoubleXSmoothMethod=MODE_EMA;   // Mode

int MADoubleXslowPeriod=5;                // slow line
int MADoubleXslowShift=25;                // Shift ... *** Secret *** ... Shhh ...
int MADoubleXslowTimeframe=PERIOD_H1;     // Timeframe
int MADoubleXslowMethod=MODE_LWMA;        // Mode
int MADoubleXslowPrice=PRICE_CLOSE;       // Method

int WindowPeriodMADoubleX=48;          // hours in window of opportunity for MA double cross to occur (array max 100)
int WindowPeriodMADoubleX2=3;          // hours in window of opportunity for PSAR friendliness
int BlackoutPeriodMADoubleX=1;         // hours to blackout future MADoubleX orders after one has occurred

datetime OrderTimeMADoubleXL=0;         // stores time of latest MADoubleX order
datetime OrderTimeMADoubleXS=0;         // stores time of latest MADoubleX order
bool flag_orderMADoubleX=true;          // true if NO MADoubleX orders are open
bool flag_ExitOrderMADoubleXLong=false; // true if long exit triggered
bool flag_ExitOrderMADoubleXShort=false;// true if short exit triggered

// OsMAHiLo Model's Variables

int OsMAHiLoTimeframe=PERIOD_H1;       // OsMAHiLo Timeframe

int OsMAHiLofast=12;                   // OsMAHiLo EMA fast period
int OsMAHiLoslow=52;                   // OsMAHiLo EMA slow period
int OsMAHiLosignal=9;                  // OsMAHiLo SMA signal period
int OsMAHiLoprice=PRICE_CLOSE;         // OsMAHiLo price

int OsMAHiLoBBPeriod=18;               // BB Period
int OsMAHiLoBBDeviation=2;             // BB Deviation
int OsMAHiLoBBBandsShift=0;            // BB Bands-Shift
int OsMAHiLoBBTimeframe=PERIOD_H1;     // BB Timeframe
int OsMAHiLoBBPrice=PRICE_CLOSE;       // BB Method

double DivisionLineOsMAHiLo=0.0;       // Value for OsMAHiLo bull/bear line

int WindowPeriodOsMAHiLo1=24;          // H1 periods to determing price high/low 
int WindowPeriodOsMAHiLo2=8;           // hours in window of opportunity for OsMAHiLo flip
int BlackoutPeriodOsMAHiLo=2;          // hours to prevent a new OsMAHiLo order 

bool flag_orderOsMAHiLo=true;          // true if NO OsMAHiLo order Part 1
datetime OrderTimeOsMAHiLo=0;          // stores time of last OsMAHiLo order Part 1
bool flag_ExitOrderOsMAHiLoLong1=false;   // true if long exit conditions met Part 1
bool flag_ExitOrderOsMAHiLoShort1=false;  // true if short exit conditions met Part 1


// BBScalp Model's Variables

int BBScalpTimeframe=PERIOD_H1;       // BBScalp Timeframe

int BBScalpBBPeriod=20;               // BB Period
int BBScalpBBDeviation=2;             // BB Deviation
int BBScalpBBBandsShift=0;            // BB Bands-Shift
int BBScalpBBTimeframe=PERIOD_H1;     // BB Timeframe
int BBScalpBBPrice=PRICE_CLOSE;       // BB Method

double BBScalpSDHigh=0.00450;            // standard deviation high value
double BBScalpSDLow =0.00350;            // standard deviation low value

int BBScalpSDPeriod=40;                 // standard deviation Period
int BBScalpSDShift=0;                   // standard deviation Shift
int BBScalpSDMethod=MODE_SMA;           // standard deviation Method
int BBScalpSDPrice=PRICE_LOW;           // standard deviation Price

int WindowPeriodBBScalpSD=10;         // hours in window of opportunity within which standard deviation must move from over high to below low value
int BlackoutPeriodBBScalp=6;          // hours to prevent a new BBScalp order

bool flag_orderBBScalp=true;          // true if NO BBScalp order
datetime OrderTimeBBScalp=0;          // stores time of last BBScalp order
bool flag_ExitOrderBBScalpLong1=false;   // true if long exit conditions met
bool flag_ExitOrderBBScalpShort1=false;  // true if short exit conditions met
bool flag_ExitOrderBBScalpLong2=false;   // true if long exit conditions met
bool flag_ExitOrderBBScalpShort2=false;  // true if short exit conditions met
int BBScalpTrigger=0;                 // primary trigger variable (1=inactive, 2=active)
int BBScalpLongExitTime=0;               // stores time when long exit signal is received, so Order 2 can exit in following hour
int BBScalpShortExitTime=0;              // stores time when short exit signal is received, so Order 2 can exit in following hour


// MAStochRSI Model's Variables

int MAStochRSITimeframe=PERIOD_M30;       // Timeframe

int WindowPeriodMAStochRSI=6;           // hours in WoO for ATRStop friendliness (all orders
int MAStochRSItouch=1;                   // 0=every tick Touch, 1=prev Hr Close

int MAStochRSI1Period=2;                // fast line
int MAStochRSI1Shift=0;                  // Shift
int MAStochRSI1Method=MODE_EMA;          // Mode
int MAStochRSI1Price=PRICE_CLOSE;        // Method
int MAStochRSI1SmoothPeriod=2;          // fast smoothing period for Zero-lag MA
int MAStochRSI1SmoothShift=0;            // Shift
int MAStochRSI1SmoothMethod=MODE_EMA;    // Mode

int MAStochRSI2Period=10;                // slow line
int MAStochRSI2Shift=0;                  // Shift
int MAStochRSI2Method=MODE_EMA;          // Mode
int MAStochRSI2Price=PRICE_CLOSE;        // Method
int MAStochRSI2SmoothPeriod=10;          // slow smoothing period for Zero-lag MA
int MAStochRSI2SmoothShift=0;            // Shift
int MAStochRSI2SmoothMethod=MODE_EMA;    // Mode

int MAStochRSIqPeriod = 4;               // q Period for DS_Stochastics
int MAStochRSIrPeriod = 28;              // r Period for DS_Stochastics
int MAStochRSIEMAfast = 14;               // EMA fast for DS_Stochastics
int MAStochRSICountBars = 3000;           // Count Bars for DS_Stochastics

double MAStochRSI_STOCHBuyLevel = 64;    // Stoch level below which to buy
double MAStochRSI_STOCHSellLevel = 34;   // Stoch level above which to sell

int MAStochRSIPeriod = 14;               // RSI period
int MAStochRSIPrice=PRICE_CLOSE;         // RSI price

double MAStochRSI_RSIBuyLevel = 39;      // RSI level above which to buy
double MAStochRSI_RSISellLevel = 61;     // RSI level below which to sell

int MAStochRSIEnvPeriod=20;              // Envelopes Period (order 3 exit)
int MAStochRSIEnvMethod=MODE_SMA;        // Envelopes Method
int MAStochRSIEnvShift=0;                // Envelopes Shift
int MAStochRSIEnvPrice=PRICE_CLOSE;      // Envelopes Price 
double MAStochRSIEnvDev=0.40;            // Envelopes Deviation

double MAStochRSIPSARStep=0.01;          // PSAR step
double MAStochRSIPSARMax=0.20;           // PSAR max

int MAStochRSIPSARMinSL=25;              // pips minimum SL if the available PSAR is less than this value (only for HiProb4)

int BlackoutPeriodMAStochRSI=1;         // hours to blackout future MAStochRSI orders

datetime OrderTimeMAStochRSI=0;          // stores time of latest MAStochRSI orders
bool flag_orderMAStochRSI=true;          // true if no orders
bool flag_ExitOrderMAStochRSI3Long=false; // true if long exit conditions met (Order 3 Envelope touch)
bool flag_ExitOrderMAStochRSI3Short=false;// true if short exit conditions met (Order 3 Envelope touch)

// RangeBO Model's Variables

int BlackOutHourBeginRangeBO=-1;       // hour to begin blackout of RangeBO (non-trend)
int BlackOutHourEndRangeBO=-1;         // hour to end blackout of RangeBO (set to -1 to turn off)(non-trend)

int RangeBOTimeframe=PERIOD_H1;       // RangeBO Timeframe

int PendingPip_RangeBO=40;            // pips from market for RangeBO pending orders 
int PendingTime_RangeBO=24;           // hours for pending order expiration
int PendingPip_RangeBO_SellSMA=7;     // pips from SMA for short orders (closest price is taken)
int RangeBOBBDeviationLong=4;         // BB Deviation for pending long price (closest price is taken)

int RangeBOBBPeriod=20;               // BB Period
int RangeBOBBDeviation=2.0;             // BB Deviation
int RangeBOBBBandsShift=0;            // BB Bands-Shift
int RangeBOBBTimeframe=PERIOD_H1;     // BB Timeframe
int RangeBOBBPrice=PRICE_CLOSE;       // BB Method

double RangeBOSDMinLevel=0.0029;     // standard deviation minimum trigger limit (orders possible above this value)

int RangeBOSDPeriod=20;               // standard deviation Period
int RangeBOSDShift=0;                 // standard deviation Shift
int RangeBOSDMethod=MODE_SMA;         // standard deviation Method
int RangeBOSDPrice=PRICE_LOW;      // standard deviation Price

int RangeBOMAPeriod=10;               // MA Period (for short price determination)
int RangeBOMAShift=0;                 // Shift
int RangeBOMAMethod=MODE_SMA;         // Mode
int RangeBOMAPrice=PRICE_CLOSE;       // Method

int BlackoutPeriodRangeBO=1;          // hours to prevent a new RangeBO trigger

bool flag_orderRangeBO=true;          // true if NO RangeBO order
datetime OrderTimeRangeBO=0;          // stores time of last RangeBO order
bool flag_ExitOrderRangeBOLong=false; // true if long exit conditions met (X reverse BBCenter exit)
bool flag_ExitOrderRangeBOShort=false;// true if short exit conditions met (X reverse BBCenter exit)
bool flag_ExitOrderRangeBO1Long=false; // true if long exit conditions met (order 1 BBCenter exit)
bool flag_ExitOrderRangeBO1Short=false;// true if short exit conditions met (order 1 BBCenter exit)
bool flag_ExitOrderRangeBOPLong=false; // true if long exit conditions met (pending order cancelation)
bool flag_ExitOrderRangeBOPShort=false;// true if short exit conditions met (pending order cancelation)
double RangeBOLongSL=0;                // stores RangeBO long SL (for manual exit & reversal)
double RangeBOShortSL=0;               // stores RangeBO short SL (for manual exit & reversal)

// Phoenix

int BlackOutHourBeginPhoenix=7;       // hour to begin blackout
int BlackOutHourEndPhoenix=11;         // hour to end blackout

int PhoenixTimeframe=PERIOD_M15;        // Phoenix Timeframe

int PendingPip_Phoenix=15;             // pips from market for Phoenix limit pending for Order 2
int PendingTime_Phoenix=10;            // hours for pending order expiration

 bool       UseSignal1       = true;   // ORIGINAL PHOENIX PARAMETER LIST
 bool       UseSignal2       = true;
 bool       UseSignal3       = true;
 bool       UseSignal4       = true;
 bool       UseSignal5       = true;

 int        SMAPeriod        = 7;
 int        SMA2Bars         = 21;
 double     Percent          = 0.0032;
 int        EnvelopePeriod   = 30;
 int        OSMAFast         = 16;
 int        OSMASlow         = 40;
 double     OSMASignal       = 4;

 int        TradeFrom1       = 0;
 int        TradeUntil1      = 24;
 int        TradeFrom2       = 0;
 int        TradeUntil2      = 0;
 int        TradeFrom3       = 0;
 int        TradeUntil3      = 0;
 int        TradeFrom4       = 0;
 int        TradeUntil4      = 0;

 int        Fast_Period      = 21;
 int        Fast_Price       = PRICE_OPEN;
 int        Slow_Period      = 11;
 int        Slow_Price       = PRICE_OPEN;
 double     DVBuySell        = 0.0034;
 double     DVStayOut        = 0.0084;

int BlackOutPeriodPhoenix=1;           // hours to prevent a new Phoenix trigger

bool flag_orderPhoenix=true;           // true if NO Phoenix order
datetime OrderTimePhoenix=0;           // stores time of last Phoenix order
bool flag_ExitOrderPhoenixPLong=false; // true if long exit conditions met (pending order cancelation)
bool flag_ExitOrderPhoenixPShort=false;// true if short exit conditions met (pending order cancelation)

// ATRStopScalp

int ATRStopScalpTimeframe=PERIOD_H1;   // ATRStopScalp Timeframe

int PendingPip_ATRStopScalp=19;         // pips inside of ATR stop Orders 1,2,3
int PendingTime_ATRStopScalp=2;        // hours for pending order expiration Orders 1,2,3
int PendingPip_ATRStopScalp4=12;       // pips inside of ATR stop Order 4
int PendingTime_ATRStopScalp4=1;       // hours for pending order expiration Order 4

int ATRStopScalpTrigger4=10;           // pips breach of ATR stop to trigger Order 4 (part 2 of triggers)

int ATRStopScalpEnvPeriod=20;          // Envelope Period
int ATRStopScalpEnvMethod=MODE_SMA;    // Envelope Method
int ATRStopScalpEnvShift=0;            // Envelope Shift
int ATRStopScalpEnvPrice=PRICE_CLOSE;  // Envelope Price 
double ATRStopScalpEnvDeviation=0.10;  // Envelope Deviation

int BlackoutPeriodATRStopScalp=12;      // hours to blackout future ATRStopScalp Orders 1, 2, 3 after one has occurred
int BlackoutPeriodATRStopScalp4=12;     // hours to blackout future ATRStopScalp Order 4 after one has occurred

bool flag_orderATRStopScalp=true;      // true if NO ATRStopScalp order
bool flag_orderATRStopScalp4=true;     // true if NO ATRStopScalp order 4
datetime OrderTimeATRStopScalp=0;      // stores time of last ATRStopScalp order
datetime OrderTimeATRStopScalp4=0;     // stores time of last ATRStopScalp order 4
double ATRStopScalpLongSL=0;           // stores ATRStopScalp long SL (for manual exit & reversal)
double ATRStopScalpShortSL=0;          // stores ATRStopScalp short SL (for manual exit & reversal)
bool flag_ExitATRStopScalpLong1=false; // true if long exit trigger
bool flag_ExitATRStopScalpShort1=false;// true if short exit trigger

// RangeTight Model's Variables

int RangeTightTimeframe=PERIOD_H1;       // RangeTight Timeframe

int RangeTightOrder2ExitGoal=40;         // pips beyond Envelopes for immediate Order 2 exit

int WindowPeriodRangeTight1=3;           // hours WoO for SMA to exceed Envelope (Primary trigger)
int WindowPeriodRangeTight2=8;           // hours WoO for Envelope touch (Secondary trigger)

int RangeTightEnvPeriod=20;              // Envelope Period
int RangeTightEnvMethod=MODE_SMA;        // Envelope Method
int RangeTightEnvShift=0;                // Envelope Shift
int RangeTightEnvPrice=PRICE_CLOSE;      // Envelope Price 
double RangeTightEnvDeviation=0.10;      // Envelope Deviation (non Trends)

int RangeTightSDPeriod=20;               // standard deviation Period
int RangeTightSDShift=0;                 // standard deviation Shift
int RangeTightSDMethod=MODE_SMA;         // standard deviation Method
int RangeTightSDPrice=PRICE_HIGH;      // standard deviation Price

double RangeTightSDMaxLevel=0.0034;      // maximum SD level permitted to trigger

int RangeTightMAPeriod=8;               // MA Period
int RangeTightMAShift=0;                 // Shift
int RangeTightMAMethod=MODE_SMA;         // Mode
int RangeTightMAPrice=PRICE_CLOSE;       // Method

int RangeTightMACDTimeframe=PERIOD_M30;   // MACD timeframe
int RangeTightMACDfast=11;                // MACD ema fast period
int RangeTightMACDslow=24;                // MACD ema slow period
int RangeTightMACDsignal=9;               // MACD sma signal period
int RangeTightMACDprice=PRICE_CLOSE;      // MACD sma price

int BlackOutPeriodRangeTight=1;          // hours to prevent a new order 

bool flag_orderRangeTight=true;           // true if NO RangeTight orders
datetime OrderTimeRangeTight=0;           // stores time of last RangeTight order
bool flag_ExitOrderRangeTightLong1=false; // true if long exit trigger hits
bool flag_ExitOrderRangeTightShort1=false;// true if short exit trigger hits
bool flag_ExitOrderRangeTightLong2=false; // true if long exit trigger hits
bool flag_ExitOrderRangeTightShort2=false;// true if short exit trigger hits
bool flag_RangeTightLongFS=false;         // true if fixed-stop trigger hits
bool flag_RangeTightShortFS=false;        // true if fixed-stop trigger hits

// RangeMid Model's Variables

int RangeMidTimeframe=PERIOD_H1;         // RangeMid Timeframe

int WindowPeriodRangeMid=3;              // hours in WoO for OsMA to be in friendly territory (array limit 10)
int WindowPeriodRangeMid2=5;             // hours in WoO for PSAR to be in friendly territory

int RangeMidADXPeriod=8;                 // Period for smoothed ADX
int RangeMidADXsmPeriod=16;               // Smoothing period for smoothed ADX

int RangeMidOsMAfast=12;                 // OsMA EMA fast period
int RangeMidOsMAslow=46;                 // OsMA EMA slow period
int RangeMidOsMAsignal=10;               // OsMA SMA signal period
int RangeMidOsMAprice=PRICE_CLOSE;       // OsMA price

int RangeMidSDPeriod=20;                 // standard deviation Period
int RangeMidSDShift=0;                   // standard deviation Shift
int RangeMidSDMethod=MODE_SMA;           // standard deviation Method
int RangeMidSDPrice=PRICE_MEDIAN;        // standard deviation Price

double RangeMidSDMaxLevel=0.0055;        // maximum SD level permitted at time of OsMA flip

int RangeMidMAPeriod=20;                 // Period for Keltner Channels MA (Exit triggers)
int RangeMidMAShift=0;                   // Shift for Keltner Channels MA
int RangeMidMAMethod=MODE_EMA;           // Mode
int RangeMidMAPrice=PRICE_CLOSE;         // Method
int RangeMidATRPeriod=20;                // Period for Keltner Channels ATR
double RangeMid1Multiplier=2.5;          // Multiplier for Keltner Channels (Lot 1 exit)
double RangeMid2Multiplier=3.5;          // Multiplier for Keltner Channels (Lot 2 exit)

int BlackOutPeriodRangeMid=1;            // hours to prevent a new order 

bool flag_orderRangeMid=true;            // true if NO RangeMid orders
datetime OrderTimeRangeMidL=0;           // stores time of last long RangeMid order
datetime OrderTimeRangeMidS=0;           // stores time of last short RangeMid order
bool flag_ExitOrderRangeMidLong=false;   // true if long exit trigger hits
bool flag_ExitOrderRangeMidShort=false;  // true if short exit trigger hits
bool flag_ExitOrderRangeMid1Long=false;   // true if long exit trigger hits
bool flag_ExitOrderRangeMid1Short=false;  // true if short exit trigger hits
bool flag_ExitOrderRangeMid2Long=false;   // true if long exit trigger hits
bool flag_ExitOrderRangeMid2Short=false;  // true if short exit trigger hits

// KeltnerScalp Model's Variables

int KeltnerScalpTimeframe=PERIOD_H1;     // KeltnerScalp Timeframe

int WindowPeriodKeltnerScalp=4;          // hours after primary triggers to accept secondary trigger (favorable ZLagStoch cross) 

int PendingPip_KeltnerScalp=6;           // pips inside the Keltner channel for pending-stop order
int PendingTime_KeltnerScalp=8;          // hours for pending order expiration

int KeltnerScalpSpikeTrigger=6;          // pips outside of Keltner channel for Part 2 trigger

int KeltnerScalpMAPeriod=20;             // Period for Keltner Channels MA
int KeltnerScalpMAShift=0;               // Shift for Keltner Channels MA
int KeltnerScalpMAMethod=MODE_EMA;       // Mode
int KeltnerScalpMAPrice=PRICE_CLOSE;     // Method

int KeltnerScalpATRPeriod=20;            // Period for Keltner Channels ATR
double KeltnerScalpMultiplier=2.0;       // Multiplier for Keltner Channels 

int KeltnerScalpqPeriod = 6;              // q Period for DS_Stochastics
int KeltnerScalprPeriod = 20;              // r Period for DS_Stochastics
int KeltnerScalpEMAfast = 5;               // EMA fast for DS_Stochastics
int KeltnerScalpCountBars = 400;           // Count Bars for DS_Stochastics

int KeltnerScalpRSIFilterPeriod = 14;      // RSI period for RSI filter
int KeltnerScalpRSIFilterPrice=PRICE_CLOSE;// RSI price
double KeltnerScalpRSILowLimit=21;         // lower RSI limit below which to deactivate for blackout period
double KeltnerScalpRSIHighLimit=79;        // higher RSI limit above which to deactivate for blackout period

int KeltnerScalpRSIBlackoutPeriod=36;      // hours blackout period after RSI extreme readings

int KeltnerScalpATRratioShortPeriod=7;     // ATR ratio short period
int KeltnerScalpATRratioLongPeriod=49;     // ATR ratio long period
double KeltnerScalpATRRatioMax=2.0;        // maximum ATR Ratio above which to deactivate for blackout period
int KeltnerScalpATRRatioBlackout=48;       // hours blackout period after ATR Ratio extreme readings

int BlackOutPeriodKeltnerScalp=12;       // hours to prevent a new order after one is in play

bool flag_orderKeltnerScalp=true;        // true if NO KeltnerScalp orders
bool flag_orderKeltnerScalpP=true;       // true if NO KeltnerScalp pending orders
int KeltnerScalpTESDelay=0;              // internal toggle to control TES 1hr delay of Order 3's TES when MIN is hit
datetime OrderTimeKeltnerScalp=0;        // stores time of last KeltnerScalp order

// Vegas Variables:

int VegasTimeframe=PERIOD_H1;            // Timeframe for method

int VegasMAPeriod=169;                   // MA Period
int VegasMAShift=0;                      // Shift
int VegasMAMethod=MODE_EMA;              // Mode
int VegasMAPrice=PRICE_CLOSE;            // Method

int VegasMASpan=89;                      // pips away from MA(169) line to form upper/lower Vegas lines

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

// PSARASC Variables:

int PSARASCTimeframe=PERIOD_H1;           // Timeframe for method

int PSARASCRisk=3;                        // ASCTrend Risk

int PSARASCSDPeriod=10;                   // standard deviation Period
int PSARASCSDShift=0;                     // standard deviation Shift
int PSARASCSDMethod=MODE_SMA;             // standard deviation Method
int PSARASCSDPrice=PRICE_CLOSE;           // standard deviation Price

                                          // SD below this -> 4xlot
double PSARASCSDLevel1=0.00120;           // SD level      -> 3xlot 
double PSARASCSDLevel2=0.00200;           // SD level      -> 2xlot
double PSARASCSDLevel3=0.00390;           // SD above this -> 1xlot

int WindowPeriodPSARASC=3;                // hours in WoO for ASC signal and PSAR turn to agree (array limit 10)
int BlackoutPeriodPSARASC=1;              // hours to blackout future PSARASC orders after one has occurred

datetime OrderTimePSARASCL=0;             // stores time of latest PSARASC order
datetime OrderTimePSARASCS=0;             // stores time of latest PSARASC order
bool flag_orderPSARASCL=true;             // true if NO PSARASC orders are open
bool flag_orderPSARASCS=true;             // true if NO PSARASC orders are open
bool flag_ExitPSARASCL=false;             // true if long exit triggered
bool flag_ExitPSARASCS=false;             // true if short exit triggered

// EnvScalp1 Variables:

int EnvScalp1Timeframe=PERIOD_H1;            // Timeframe for method

int EnvScalp1EnvPeriod=40;                   // Envelopes Period
int EnvScalp1EnvMethod=MODE_SMA;             // Envelopes Method
int EnvScalp1EnvShift=0;                     // Envelopes Shift
int EnvScalp1EnvPrice=PRICE_CLOSE;           // Envelopes Price 
double EnvScalp1EnvDev=0.40;                 // Envelopes Deviation

int EnvScalp1SDTimeframe=PERIOD_D1;          // Timeframe for SD filter
int EnvScalp1SDPeriod=20;                    // standard deviation Period
int EnvScalp1SDShift=0;                      // standard deviation Shift
int EnvScalp1SDMethod=MODE_SMA;              // standard deviation Method
int EnvScalp1SDPrice=PRICE_CLOSE;            // standard deviation Price

double EnvScalp1SDLevel1=0.0200;             // maximum SD level permitted to trigger
double EnvScalp1SDLevel2=0.0040;             // SD over-ride RSI: if below this, RSI filer is ignored

int EnvScalp1RSIPeriod = 14;                 // RSI period for RSI filter
int EnvScalp1RSIPrice=PRICE_CLOSE;           // RSI price
double EnvScalp1RSILowLimit=30;              // lower RSI limit - no trades below
double EnvScalp1RSIHighLimit=70;             // higher RSI limit - no trades above

int EnvScalp1RVIPeriod=14;                    // RVI period

double EnvScalp1PMILevel1=27;                // PMI+SD level 1, maximum, above which no orders are taken
double EnvScalp1PMILevel2=20;                // PMI+SD level 2, between which to submit market + pending orders
                                             //             ... below which to submit both market orders

int WindowPeriodEnvScalp1A=9;               // hours in WoO for RVI cross after Env-close condition is met
int WindowPeriodEnvScalp1B=2;               // hours in WoO for PMI to drop below maximum
int WindowPeriodEnvScalp1C=16;              // hours in WoO for PSAR to become friendly

int BlackoutPeriodEnvScalp1=1;               // hours to blackout future EnvScalp1 orders after one has occurred

datetime OrderTimeEnvScalp1=0;               // stores time of latest EnvScalp1 order
datetime EnvScalp1TimeL=0;                   // stores excessive PMI times for longs
datetime EnvScalp1TimeS=0;                   // stores excessive PMI times for shorts
bool flag_orderEnvScalp1=true;               // true if NO EnvScalp1 orders are open
bool flag_ExitEnvScalp1L=false;              // true if long exit triggered (upper Env breach)
bool flag_ExitEnvScalp1S=false;              // true if short exit triggered (lower Env breach)
bool flag_ExitEnvScalp1LStop=false;          // true if long stop exit (lower Env breach) triggered
bool flag_ExitEnvScalp1SStop=false;          // true if short stop exit (upper Env breah) triggered

// EnvScalp2 Variables:

int EnvScalp2Timeframe=PERIOD_H1;            // Timeframe for method

int EnvScalp2SDTimeframe=PERIOD_D1;          // Timeframe for SD filter
int EnvScalp2SDPeriod=20;                    // standard deviation Period
int EnvScalp2SDShift=0;                      // standard deviation Shift
int EnvScalp2SDMethod=MODE_SMA;              // standard deviation Method
int EnvScalp2SDPrice=PRICE_CLOSE;            // standard deviation Price

double EnvScalp2SDLevel=0.0200;              // maximum SD level permitted to trigger

int EnvScalp2RVIPeriod=3;                   // RVI period
double EnvScalp2RVILimit1=0.1500;            // RVI signal limit (negative for longs, positive for shorts)
double EnvScalp2RVILimit2=0.4500;            // RVI signal limit (negative for longs, positive for shorts)

double EnvScalp2RVIExit1=-0.2000;            // RVI exit signal limit (exit upon contrary cross below this value)
double EnvScalp2RVIExit2= 0.2000;            // RVI exit signal limit (exit upon contrary cross above this value)

int EnvScalp2qPeriod = 5;                    // q Period for DS_Stochastics 
int EnvScalp2rPeriod = 3;                    // r Period for DS_Stochastics
int EnvScalp2EMAfast = 2;                    // EMA fast for DS_Stochastics
int EnvScalp2CountBars = 400;                // Count Bars for DS_Stochastics

double EnvScalp2StochLongLimit=45;           // DS_Stoch filter value above which not to buy
double EnvScalp2StochShortLimit=43;          // DS_Stoch filter value below which not to sell

double EnvScalp2PMILevel1=30;                // PMI+SD level 1, maximum, above which no orders are taken
double EnvScalp2PMILevel2=25;                // PMI+SD level 2, between which to submit market + pending orders
                                             //             ... below which to submit both market orders

int WindowPeriodEnvScalp2B=4;                // hours in WoO for PMI to drop below maximum
int WindowPeriodEnvScalp2C=24;               // hours in WoO for PSAR to become friendly
                     
int BlackoutPeriodEnvScalp2=1;               // hours to blackout future EnvScalp2 orders after one has occurred

datetime OrderTimeEnvScalp2=0;               // stores time of latest EnvScalp2 order
datetime EnvScalp2TimeL=0;                   // stores excessive PMI times for longs
datetime EnvScalp2TimeS=0;                   // stores excessive PMI times for shorts
bool flag_orderEnvScalp2=true;               // true if NO EnvScalp2 orders are open
bool flag_ExitEnvScalp2L=false;              // true if long exit triggered
bool flag_ExitEnvScalp2S=false;              // true if short exit triggered

// EnvScalp3 Variables:

int EnvScalp3Timeframe=PERIOD_H1;            // Timeframe for method

int EnvScalp3SDTimeframe=PERIOD_H1;          // Timeframe for SD filter
int EnvScalp3SDPeriod=60;                    // standard deviation Period
int EnvScalp3SDShift=0;                      // standard deviation Shift
int EnvScalp3SDMethod=MODE_SMA;              // standard deviation Method
int EnvScalp3SDPrice=PRICE_CLOSE;            // standard deviation Price

double EnvScalp3SDLevel=0.0070;              // maximum SD level permitted to trigger

int EnvScalp3EnvPeriod=40;                   // Envelopes Period
int EnvScalp3EnvMethod=MODE_SMA;             // Envelopes Method
int EnvScalp3EnvShift=0;                     // Envelopes Shift
int EnvScalp3EnvPrice=PRICE_CLOSE;           // Envelopes Price 
double EnvScalp3EnvDev=0.40;                 // Envelopes Deviation

double EnvScalp3PMILevelEnter=27;            // PMI+SD level, below which to enter the market
double EnvScalp3PMILevelExit=35;             // PMI+SD level, above which to exit in EnvScalp3ExitHours
int EnvScalp3ExitHours=4;                    // hours within which to exit if PMI+SD exceeds EnvScalp3PMILevelExit

int EnvScalp3OsMAfast=36;                    // OsMA EMA fast period
int EnvScalp3OsMAslow=52;                    // OsMA EMA slow period
int EnvScalp3OsMAsignal=6;                  // OsMA SMA signal period
int EnvScalp3OsMAprice=PRICE_CLOSE;          // OsMA price

int EnvScalp3NRTRAvePeriod=40;               // NRTRWATR Average Period
int EnvScalp3NRTRVariant=3;                  // NRTRWATR Variant
int EnvScalp3NRTRCountBars=50;               // NRTRWATR CountBars

int WindowPeriodEnvScalp3=20;                // hours in WoO for OsMA, SD, and PMI+SD to become friendly
int BlackoutPeriodEnvScalp3=12;               // hours to blackout future EnvScalp3 orders after one has occurred

datetime OrderTimeEnvScalp3=0;               // stores time of latest EnvScalp3 order
bool flag_orderEnvScalp3=true;               // true if NO EnvScalp3 orders are open
bool flag_ExitEnvScalp3L=false;              // true if long exit triggered
bool flag_ExitEnvScalp3S=false;              // true if short exit triggered
bool flag_ExitEnvScalp3PMIL=false;           // true if long PMI exit triggered
bool flag_ExitEnvScalp3PMIS=false;           // true if short PMI exit triggered

// PMI30 Variables:

int PMI30Timeframe=PERIOD_M30;           // Timeframe for method

int PMI30touch=1;                        // 0=instant values, 1=confirmed (prev hr) values

int PMI30RSIPeriod=20;                   // PMI+SD RSI Period
int PMI30RSIPrice=PRICE_CLOSE;           // PMI+SD RSI Price 
int PMI30LongVshift=55;                  // PMI+SD RSI VerticalShiftTo25 for Long signals
int PMI30ShortVshift=45;                 // PMI+SD RSI VerticalShiftTo25 for Short signals

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
int PMI60LongVshift=55;                  // PMI+SD RSI VerticalShiftTo25 for Long signals
int PMI60ShortVshift=50;                 // PMI+SD RSI VerticalShiftTo25 for Short signals

double PMI60TriggerLimit=30;             // PMI+SD trigger line, above which no orders are allowed

int BlackoutPeriodPMI60=1;               // hours to blackout future PMI orders after one has occurred

datetime OrderTimePMI60=0;               // stores time of latest PMI order
bool flag_orderPMI60=true;               // true if NO PMI orders are open
bool flag_ExitPMI60L=false;              // true if long exit triggered
bool flag_ExitPMI60S=false;              // true if short exit triggered

// AweOsMA Variables:

int AweOsMATimeframe=PERIOD_H1;            // Timeframe for method

int AweOsMAfastPeriod=12;                  // OsMA fast Period
int AweOsMAslowPeriod=26;                  // OsMA slow Period
int AweOsMAsignalPeriod=9;                 // OsMA signal Period
int AweOsMAPrice=PRICE_CLOSE;              // OsMA applied Price

double AweOsMADisagree=0.00500;             // Disagreement minimum for primary activation
double AweOsMALimitA1 =0.00100;             // Awesome minimum value for Trigger A - to fade the flip
double AweOsMALimitA2 =0.00400;             // OsMA minimum value for Trigger A - to follow the flip
double AweOsMALimitB  =0.00125;             // OsMA minimum value for Trigger B - to follow the flip

int AweOsMARSIPeriod=14;                   // RSI Period
int AweOsMARSIPrice=PRICE_CLOSE;           // RSI Price 
double AweOsMARSILowLimit=45;              // lower RSI limit below which not to submit longs
double AweOsMARSIHighLimit=45;             // higher RSI limit above which not to submit shorts

int WindowPeriodAweOsMATrigger=100;        // hours in WoO beween disagreement activation and trigger
int WindowPeriodAweOsMAEntryA=3;           // hours in WoO beween trigger and entry A 
int WindowPeriodAweOsMAEntryB=6;           // hours in WoO beween trigger and entry B
int BlackoutPeriodAweOsMA=1;               // hours to blackout future AweOsMA orders after one has occurred

datetime OrderTimeAweOsMA=0;               // stores time of latest AweOsMA order
bool flag_orderAweOsMA=true;               // true if NO AweOsMA orders are open
bool flag_ExitAweOsMAL=false;              // true if long exit triggered
bool flag_ExitAweOsMAS=false;              // true if short exit triggered

// RangeTightDay Variables:

int RangeTightDayTimeframe=PERIOD_D1;      // Timeframe for method

double RangeTightDaySDTrigger1=0.0135;     // standard deviation for Primary trigger
double RangeTightDaySDTrigger2=0.0130;     // standard devitaion for Secondary trigger

int RangeTightDaySDPeriod=20;              // standard deviation Period
int RangeTightDaySDShift=0;                // standard deviation Shift
int RangeTightDaySDMethod=MODE_SMA;        // standard deviation Method
int RangeTightDaySDPrice=PRICE_LOW;      // standard deviation Price

int RangeTightDayBBPeriod=20;          // BB-Bands Period
int RangeTightDayBBBandsShift=0;           // BB-Bands Shift
double RangeTightDayBBDeviation=2.2;      // BB-Bands Deviation

int WindowPeriodRangeTightDay=30;          // days in WoO for SD to drop to 
int BlackoutPeriodRangeTightDay=1;         // days to blackout future RangeTightDay orders after one has occurred

datetime OrderTimeRangeTightDayL=0;         // stores time of latest RangeTightDay order
datetime OrderTimeRangeTightDayS=0;         // stores time of latest RangeTightDay order
bool flag_orderRangeTightDay=true;         // true if NO RangeTightDay orders are open
bool flag_ExitRangeTightDayL=false;        // true if long exit triggered
bool flag_ExitRangeTightDayS=false;        // true if short exit triggered
double RangeTightDayLongSL;                // stores buffered long SL for manual exit/reverse
double RangeTightDayShortSL;               // stores buffered short SL for manual exit/reverse

// ADXTrend Variables:

int ADXTrendTimeframe=PERIOD_H4;            // Timeframe for method

int ADXTrendADXperiod=200;                  // ADXDay ADX period
int ADXTrendADXprice=PRICE_CLOSE;           // ADXDay ADX price

int WindowPeriod1ADXTrend=4;                // hours in mandatory delay between ADX-cross and position entry
int WindowPeriod2ADXTrend=6;                // hours in WoO for Awe to agree after mandatory delay had passed
int BlackoutPeriodADXTrend=1;               // hours to blackout future ADXTrend orders after one has occurred

datetime OrderTimeADXTrend=0;               // stores time of latest ADXTrend order
bool flag_orderADXTrend=true;               // true if NO ADXTrend orders are open
bool flag_ExitADXTrendL=false;              // true if long exit triggered
bool flag_ExitADXTrendS=false;              // true if short exit triggered

// HighProb Variables:

int HighProbTimeframe=PERIOD_H1;            // Timeframe for method

int HighProbqPeriod = 13;                   // q Period for DS_Stochastics
int HighProbrPeriod = 32;                   // r Period for DS_Stochastics
int HighProbEMAfast = 5;                    // EMA fast for DS_Stochastics
int HighProbCountBars = 3000;                // Count Bars for DS_Stochastics

double HighProbStochLowLevel=31;            // buy at or below this DS_Stochastics level
double HighProbStochHighLevel=69;           // sell at or above this DS_Stochastics level

double HighProbStochValueExitS=40;          // exit short at contr crosses below this value
double HighProbStochValueExitL=60;          // exit long at contr crosses above this value

int HighProbOsMAfast=12;                    // OsMA EMA fast period
int HighProbOsMAslow=26;                    // OsMA EMA slow period
int HighProbOsMAsignal=9;                   // OsMA SMA signal period
int HighProbOsMAprice=PRICE_CLOSE;          // OsMA price

int HighProbPMIPeriod=24;                   // PMI+SD period 
double HigProbPMISDMaxLevel=35;             // NO trades above this PMI+SD level

int HighProbSDPeriod=60;                    // standard deviation Period
int HighProbSDShift=0;                      // standard deviation Shift
int HighProbSDMethod=MODE_SMA;              // standard deviation Method
int HighProbSDPrice=PRICE_CLOSE;            // standard deviation Price

double HighProbSDLimit=0.0095;               // no trades above this SD level

int WindowPeriodHighProb=6;                 // hours for OsMA, PMI, SD to be in agreement & PMI+SD to be under max level
int WindowPeriodHighProbPSAR=16;            // hours for PSAR to become friendly after trigger
int BlackoutPeriodHighProb=1;               // hours to blackout future HighProb orders after one has occurred

datetime OrderTimeHighProb=0;               // stores time of latest HighProb order
datetime HighProbLDelay=0;                  // stores time of latest HighProb L trigger in PSAR unfriendliness
datetime HighProbSDelay=0;                  // stores time of latest HighProb S trigger in PSAR unfriendliness
bool flag_orderHighProbL=true;              // true if NO HighProb long orders are open
bool flag_orderHighProbS=true;              // true if NO HighProb short orders are open
bool flag_ExitHighProbL=false;              // true if long exit triggered for O1,3: acceptible contrary cross
bool flag_ExitHighProbS=false;              // true if short exit triggered for O1,3: acceptible contrary cross
bool flag_ExitHighProb2L=false;             // true if long exit triggered for O2: contrary entry
bool flag_ExitHighProb2S=false;             // true if short exit triggered for O2: contrary entry
int HighProbTrail=0;                        // toggle which signals O1 exit so O2 trail can begin

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
double HigProb4PMISDMaxLevel=52;             // NO trades above this PMI+SD level

int HighProb4SDPeriod=60;                    // standard deviation Period
int HighProb4SDShift=0;                      // standard deviation Shift
int HighProb4SDMethod=MODE_SMA;              // standard deviation Method
int HighProb4SDPrice=PRICE_CLOSE;            // standard deviation Price

double HighProb4SDLimit=0.0188;              // no trades above this SD level

int HighProb4PSARMinSL=25;                    // pips minimum SL if the available PSAR is less than this value (only for HiProb4)

double HighProb4PSARStep=0.03;                // PSAR step for entry & SL considerations (only for HiProb4)
double HighProb4PSARMax=0.20;                 // PSAR max for entry & SL considerations (only for HiProb4)

int WindowPeriodHighProb4=4;                 // hours for OsMA, PMI, SD to be in agreement & PMI+SD to be under max level
int WindowPeriodHighProb4PSAR=6;             // hours for PSAR to become friendly after trigger
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

// StochADX Model's Variables

int StochADXTimeframe=PERIOD_H1;

int WindowPeriodStochADX=7;                // hours in window of opportunity for triggers to be received (array max 10)

int StochADXOsMAfast=12;                   // OsMA EMA fast period
int StochADXOsMAslow=26;                   // OsMA EMA slow period
int StochADXOsMAsignal=12;                 // OsMA SMA signal period
int StochADXOsMAprice=PRICE_CLOSE;         // OsMA price

int StochADXPeriod=8;                     // Period for smoothed ADX
int StochADXsmPeriod=16;                    // Smoothing period for smoothed ADX

int StochADXqPeriod = 10;                  // q Period for DS_Stochastics
int StochADXrPeriod = 26;                  // r Period for DS_Stochastics
int StochADXEMAfast = 5;                   // EMA fast for DS_Stochastics
int StochADXCountBars = 400;               // Count Bars for DS_Stochastics

int BlackoutPeriodStochADX=1;              // hours to prevent a new trigger after the last trigger

bool flag_orderStochADX1Long=true;         // true if NO StochADX long order is open
bool flag_orderStochADX1Short=true;        // true if NO StochADX short order is open
datetime OrderTimeStochADX1Long=0;         // stores time of last long StochADX order 1, 2
datetime OrderTimeStochADX1Short=0;        // stores time of last long StochADX order 1, 2
datetime StochADXLongTime=0;               // stores time of last long primary trigger
datetime StochADXShortTime=0;              // stores time of last short primaer trigger
bool flag_ExitOrderStochADX1Long=false;    // true when long exit condition hits (Order 1,2 contrary trigger)
bool flag_ExitOrderStochADX1Short=false;   // true when short exit condition hits (Order 1,2 contrary trigger)

// Mini-Short Double Trouble I

int BlackOutHourBeginMiniShortI=22;       // hour to begin blackout of Mini Short I
int BlackOutHourEndMiniShortI=3;         // hour to end blackout of Mini Short I (set to -1 to turn off)

int MAMiniShortITimeframe=PERIOD_H1;      // Timeframe

int MAMiniShortIslowPeriod=10;            // SMA() acts as base line for MiniShortI
int MAMiniShortIslowShift=2;              // Shift
int MAMiniShortIslowMethod=MODE_SMA;      // Mode
int MAMiniShortIslowPrice=PRICE_CLOSE;    // Method

int MAMiniShortIveryslowPeriod=25;        // SMA() acts as exit line for MiniShortI
int MAMiniShortIveryslowShift=2;          // Shift
int MAMiniShortIveryslowMethod=MODE_SMA;  // Mode
int MAMiniShortIveryslowPrice=PRICE_CLOSE;// Method

int TriggerPipsMiniShortPSAR=9;          // pips from opposing PSAR to execute pending order
int WindowPeriodMiniShortI=3;             // hours pending order will be valid (window-of-opportunity)

int BlackOutPeriodMiniShortI=1;           // hours to ignore future triggers after the execution of the last one
int MinimumLifetimeMiniShortI=2;           // hours minimum before a new pending order can cancel out an existing unprofitable order 

datetime OrderTimeMiniShortI=0;           // time of last MiniShortI order
bool flag_ExitOrderMiniShortIPL=false;     // true if short cross condition is met
bool flag_ExitOrderMiniShortIPS=false;     // true if long cross condition is met
bool flag_ExitOrderMiniShortIXL=false;     // true if exit MA X long exit condition is met
bool flag_ExitOrderMiniShortIXS=false;     // true if exit MA X short exit condition is met

// =========================
// Bonus4 Engine Variables
// =========================

int WindowSpanBonus4SMA=7;                  // hours within which all 3 SMA methods enter in same direction to trigger Bonus4SMA order 
int WindowSpanBonus4Accel=2;                // hours within which EMA(H2) closes outside BB(H 20,2) to trigger Bonus4Accel order 
int WindowSpanBonus4Extreme=6;              // hours within (either side) which MACD||RSI triggers Bonus4Extreme order 
int WindowSpanBonus4Daily=5;                // days within (either side) which 10dayBO & BB(D 20,2) triggers Bonus4Daily order 

int BlackoutPeriodBonus4SMA=10;             // hours
int BlackoutPeriodBonus4Accel=1;            // hours
int BlackoutPeriodBonus4Extreme=18;         // hours
int BlackoutPeriodBonus4Doji=1;             // hours
int BlackoutPeriodBonus4Daily=2;            // days

                                     // Bonus4Daily SD filter 

int Bonus4DailySDTimeframe=PERIOD_D1;          // Timeframe for SD filter
int Bonus4DailySDPeriod=20;                    // standard deviation Period
int Bonus4DailySDShift=0;                      // standard deviation Shift
int Bonus4DailySDMethod=MODE_SMA;              // standard deviation Method
int Bonus4DailySDPrice=PRICE_CLOSE;            // standard deviation Price

double Bonus4DailySDLevel=0.0150;              // minimum SD level permitted to trigger

                                     // Bonus4SMA (old Safety) variables 

int TriggerSafety=34;                // pips above/below SMA(40) to trigger close of open Safety orders

int MASafetyfastTimeframe=PERIOD_H1; // Timeframe Period = H1

int MASafetyslowPeriod=32;           // SMA(40)acts as main base line for Safety
int MASafetyslowTimeframe=PERIOD_H1; // Timeframe Period = H1
int MASafetyslowShift=1;             // Shift
int MASafetyslowMethod=MODE_SMA;     // Mode
int MASafetyslowPrice=PRICE_CLOSE;   // Method

                                           // Bonus4Accel variables 
int TriggerAlertTime=0;                    // 10hrBO trigger alert times 

int BBTimeframe=PERIOD_H1;                 // BB Time-frame: HOURLY BB
int BBPeriod=20;                           // BB Period
int BBDeviation=2;                         // BB Deviation
int BBBandsShift=0;                        // BB Bands-Shift
int BBPrice=PRICE_CLOSE;                   // BB Method

int MABBTimeframe=PERIOD_H1;               // EMA Time-frame
int MABBPeriod=2;                          // EMA Period (should be >= 2)
int MABBShift=0;                           // Shift
int MABBMethod=MODE_SMA;                   // Mode
int MABBPrice=PRICE_CLOSE;                 // Method

                                           // Bonus4Doji variables

int DojiTimeframe=PERIOD_H1;               // Timeframe
int DojiKeltnerMAPeriod=20;                // Period for Keltner Channels MA
int DojiKeltnerMAShift=0;                  // Shift for Keltner Channels MA
int DojiKeltnerMAMethod=MODE_EMA;          // Mode
int DojiKeltnerMAPrice=PRICE_CLOSE;        // Method

int DojiKeltnerATRPeriod=20;               // Period for Keltner Channels ATR
double DojiKeltnerMultiplier=1.38;         // Multiplier for Keltner Channels  
int DojiStarPips=4;                        // pips above high/below low for Doji star value

int NDojiMAX=3;                            // maximum number of Doji orders in the same direction
int NDojiLong;                             // stores number of long Doji orders
int NDojiShort;                            // stores number of short Doji orders

bool flag_ExitOrderDojiLong=false;         // true if long exit conditions met
bool flag_ExitOrderDojiShort=false;        // true if short exit conditions met

datetime OrderTimeBonus4SMA;
datetime OrderTimeBonus4Accel;
datetime OrderTimeBonus4Extreme;
datetime OrderTimeBonus4Doji;
datetime OrderTimeBonus4Daily;

bool flag_orderBonus4SMA=true;
bool flag_orderBonus4Accel=true;
bool flag_orderBonus4Extreme=true;
bool flag_orderBonus4Doji=true;
bool flag_orderBonus4Daily=true;

bool flag_ExitOrderBonus4SMALong=false;
bool flag_ExitOrderBonus4SMAShort=false;
bool flag_ExitOrderBonus4AccelLong=false;
bool flag_ExitOrderBonus4AccelShort=false;
bool flag_ExitOrderBonus4DailyLong=false;
bool flag_ExitOrderBonus4DailyShort=false;

// Bonus4 Extreme Reversal & RSIScalp trigger flags/times
bool BEReversalLongTrigger=false;
bool BEReversalShortTrigger=false;
datetime BEReversalLongTime=0;
datetime BEReversalShortTime=0;
bool BERSIScalpLongTrigger=false;
bool BERSIScalpShortTrigger=false;
datetime BERSIScalpLongTime=0;
datetime BERSIScalpShortTime=0;

//===================================================================================================
// Trend Parameters
//===================================================================================================

// SMA(D10) Trend Determination Variables:

int MATrendPeriod=10;                     // SMA(10) acts as base line for Trend determination
int MATrendTimeframe=PERIOD_D1;           // Timeframe Period = D1
int MATrendShift=0;                       // Shift
int MATrendMethod=MODE_SMA;               // Mode
int MATrendPrice=PRICE_CLOSE;             // Method

int MAMonitorTimeframe=PERIOD_D1;         // Timeframe for monitoring of previous day's close

int EnterTrend=195;                       // pips above/below 10daySMA to trigger trend conditions
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
// Fast/Slow Parameters
//===================================================================================================

// Fast/Slow Parameters:

double FastTrigger=60;     // pips (high to low) market moves above which Fast climate is trigered
double SlowTrigger=39;     // pips (high to low) market moves below which Slow climate is trigered

int FastSlowPeriod=200;    // minutes in Fast/Slow climate determination period

//===================================================================================================
// Utilities parameters
//===================================================================================================

// PMI+SD Variables ("Productivity Momentum Index w/ Standard Deviation")

int PMIPeriod=20;                    // MA Period for PMI+SD
int PMIShift=0;                      // MA Shift
int PMIMethod=MODE_SMA;              // MA Method
int PMIPrice=PRICE_LOW;            // MA Price
int PMISDShift=0;                    // Standard Deviation Shift

// Parabolic SAR Variables

double PSARStep=0.02;                // Parabolic SAR step
double PSARMax =0.20;                // Parabolic SAR maximum

int PSARStopLossBuffer=4;            // pips +/- from PSAR at which to define s/l levels
int PSARMinimumStopLoss=25;          // pips s/l from market if PSAR is closer than this value

int PSARBeyondPips=20;               // pips within FibATRStop at which to use PSARStop
int PSARWithinPips=25;               // pips beyond FibATRStop at which to use PSARStop

// ATR Channels Variables (for MACD & Reversal) { Safety's ATR parameters are in the Safety section)

int ATRTimeframe=PERIOD_H1;          // ATR H1 timeframe
int ATRTimeframeH4=PERIOD_H4;        // ATR H4 timeframe
int ATRTimeframeD1=PERIOD_D1;        // ATR D1 timeframe
int ATRPeriod=18;                    // ATR period 
int ATRMAPeriod=49;                  // ATR MA period
int ATRMAShift=0;                    // ATR MA shift
int ATRMAMethod=MODE_LWMA;           // ATR MA method
int ATRMAPrice=PRICE_TYPICAL;        // ATR MA price 

double ATRmultiplier=1.6;


// ATR Stop Variables 

// ... for ONLY SecretMA & ATRStopScalp
int ATRStopPeriodA=20;        // ATR-Stop Period 
int ATRStopCoefficientA=2;    // ATR-Stop Coefficient 

// ... for ATR Stop system & MAStochRSI
int ATRStopPeriodB=20;        // ATR-Stop Period 
int ATRStopCoefficientB=1;    // ATR-Stop Coefficient 

// ... for Sentiment (H4)
int ATRStopPeriodH4=20;       // ATR-Stop Period
int ATRStopCoefficientH4=1;   // ATR-Stop Coefficient


// Relavent Stops/Target Varaibles

int ATRLevelsPeriod=10;                    // ATR-Level ATR Period (for 30MinBO Order 1 t/p)
int ATRLevelsMinimum=40;                   // ATR-Level minimum pips in order for ATR-Level to be used as t/p

int ATRStopAdjust=15;                      // ATR-Stop level value +/- pips for ATR-relavent stops
int ATRTargetAdjust=0;                     // ATR-Stop level value +/- pips for ATR-relavent targets
int ATRRange=5;                            // pip range from initial stops to switch to ATR values

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
 
int ProductivityPeriod=50;            // hours to scan 
 
double ProductivityHighLimit=5.0;    // high limit
double ProductivityLowLimit=2.5;      // low limit
double ProductivityHighFactor=1.5;    // multiplicative factor if above high limit for method A, below low limit for method B
double ProductivityNullFactor=1.0;    // multiplicative factor if between high/low limits
double ProductivityLowFactor=0.5;     // multiplicative factor if below low limit for method A, above high limit for method B


//===================================================================================================

#include "TheOneSupport/TheOneSpecsParameters.mqh"


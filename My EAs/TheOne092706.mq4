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

// Toggles for Trading Models (true=active, false=inactive)

extern bool flag_SecretMA=true;      // toggle for Secret MA trades
extern bool flag_MACD=true;          // toggle for MACD trades
extern bool flag_10hrX=true;         // toggle for 10hrX trades
extern bool flag_10dayX=true;        // toggle for 10dayX trades
extern bool flag_Stoch=true;         // toggle for Stochastics trades
extern bool flag_Safety=true;        // toggle for Safety trades
extern bool flag_Reversal=true;      // toggle for Reversal trades
extern bool flag_DoubleTops=true;    // toggle for DoubleTops trades

extern int  Display_Corner=0;        // 0=top left, 1=top right, 2=bottom left, 3=bottom right
extern color Display_Color=Black;      // color for Display Status labels
//Fixed Lots List:
  
double LotsMA=3.0;                   // lots to trade Secret MA (fractional values ok)
double LotsMAUnload=2.0;             // lots to unload at TakeProfit_MAUnload (fractional values ok)
double LotsMACD=1.0;                 // lots to trade MACD (fractional values ok)
double LotsMACDUnload=0.5;           // lots to unload MACD at TakeProfit_MACDUnload (fractional values ok)
double Lots10hrX=2.0;                // lots to trade 10hrX (fractional values ok)
double Lots10hrXUnload=1.0;          // lots to unload 10hrX at TakeProfit_10hrXUnload (fractional values ok)
double Lots10dayX=2.0;               // lots to trade 10dayX (fractional values ok)
double Lots10dayXUnload=1.0;         // lots to unload 10dayX at TakeProfit_10dayXUnload (fractional values ok)
double LotsStoch=1.0;                // lots to trade Stochastics (fractional values ok)
double LotsStochUnload=1.0;          // lots to unload Stochastics TakeProfit_10dayXUnload (fractional values ok)
double LotsSafety=1.5;               // lots to trade Safety (fractional values ok)
double LotsSafety1Unload=0.5;        // lots to unload Safety TakeProfit_SafetyUnload1 (fractional values ok)
double LotsSafety2Unload=0.5;        // lots to unload Safety TakeProfit_SafetyUnload2 (fractional values ok)
double LotsReversal=2.0;             // lots to trade Reversal (fractional values ok)
double LotsReversalUnload=1.0;       // lots to unload Reversal TakeProfit_Reversal (fractional values ok)
double LotsDoubleTops=1.5;           // lots to trade Safety (fractional values ok)
double LotsDoubleTops1Unload=0.5;    // lots to unload Safety TakeProfit_SafetyUnload1 (fractional values ok)
double LotsDoubleTops2Unload=0.5;    // lots to unload Safety TakeProfit_SafetyUnload2 (fractional values ok)


// Take Profit List:

int TakeProfit_MAMain=0;             // pips take profit Secret MA main order
int TakeProfit_MAUnload=0;           // pips take profit Secret MA unload
int TakeProfit_MACDMain=120;         // pips take profit MACD main order
int TakeProfit_MACDUnload=80;        // pips take profit MACD unload
int TakeProfit_10hrXMain=0;          // pips take profit 10hrX main order
int TakeProfit_10hrXUnload=30;       // pips take profit 10hrX unload
int TakeProfit_10dayXMain=50;        // pips take profit 10dayX main order
int TakeProfit_10dayXUnload=0;       // pips take profit 10dayX unload
int TakeProfit_Stoch=200;            // pips take profit Stochastics main order
int TakeProfit_StochUnload=70;       // pips take profit Stochastics unload
int TakeProfit_Safety=90;            // pips take profit Safety main order
int TakeProfit_Safety1Unload=30;     // pips take profit Safety 1 unload
int TakeProfit_Safety2Unload=60;     // pips take profit Safety 2 unload
int TakeProfit_Reversal=50;          // pips take profit Reversal main order
int TakeProfit_ReversalUnload=20;    // pips take profit Reversal unload
int TakeProfit_DoubleTops=220;       // pips take profit DoubleTops main
int TakeProfit_DoubleTops1Unload=50; // pips take profit DoubleTops 1 unload
int TakeProfit_DoubleTops2Unload=100;// pips take profit DoubleTops 2 unload

// Stop Loss List:

int StopLoss_MA=40;                  // pips stop loss for Secret MA main order
int StopLoss_MACD=60;                // pips stop loss for MACD main order
int StopLoss_10hrX=0;                // pips stop loss for 10hrX main order
int StopLoss_10dayX=0;               // pips stop loss for 10dayX main order
int StopLoss_Stoch=75;               // pips stop loss for Stochastics main order
int StopLoss_Safety=0;               // pips stop loss for Safety main order
int StopLoss_Reversal=5;            // pips stop loss for Reversal (above/below high/low for stoploss)
int StopLoss_DoubleTops=55;          // pips stop loss for DoubleTops (from highest/lowest price)

// Trailing Stop List:

int TrailingStop_MA=0;               // pips trailing stop loss for Secret MA main order
int TrailingStop_MACD=0;             // pips trailing stop loss for MACD main order
int TrailingStop_10hrX=40;           // pips trailing stop loss for 10hrX main order
int TrailingStop_10dayX=40;          // pips trailing stop loss for 10dayX main order (activated only after order is unloaded)
int TrailingStop_10dayXUnload=0;     // pips trailing stop loss for 10dayX unloaded order 
int TrailingStop_Stoch=40;           // pips trailing stop loss for Stochastics main order (activated only after order is unloaded)
int TrailingStop_StochUnload=40;     // pips trailing stop loss for Stochastics unloaded order
int TrailingStop_Safety=45;          // pips trailing stop loss for Safety main order
int TrailingStop_Reversal=40;        // pips trailing stop loss for Reversal (activated only after order is unloaded)
int TrailingStop_ReversalUnload=0;  // pips trailing stop loss for Reversal unloaded order
int TrailingStop_DoubleTops=80;      // pips trailing stop loss for DoubleTops (activated only after order is unloaded)
int TrailingStop_DoubleTopsUnload=0; // pips trailing stop loss for DoubleTops unloaded order

// Secret MA Variables:

int MA1Period=100;                   // EMA(1) acts as trigger line to gauge immediate price action 
int MA1Timeframe=PERIOD_H1;          // Timeframe
int MA1Shift=10;                     // Shift
int MA1Method=MODE_EMA;              // Mode
int MA1Price=PRICE_CLOSE;            // Method

int MA2Period=30;                    // SMA(10) acts as base line
int MA2Shift=10;                     // Shift ... *** Secret *** ... Shhh ...
int MA2Timeframe=PERIOD_H1;          // Timeframe
int MA2Method=MODE_SMA;              // Mode
int MA2Price=PRICE_CLOSE;            // Method

int BlackoutPeriodSecretMA=1;        // hours to blackout future SecretMA orders after one has occurred
datetime OrderTimeSecretMA=0;        // time of latest SecretMA order
bool flag_orderSecretMA=true;        // true if NO Secret MA orders are open
int checktimeSecretMA=0;             // stores time remaining in SecretMA blackout

// MACD Variables:

int MACDfast=12;                     // MACD ema fast period
int MACDslow=26;                     // MACD ema slow period
int MACDsignal=9;                    // MACD sma signal period
int OrderTimeMACDframe=PERIOD_H1;    // Timeframe

double TriggerMACD=0.0010;           // Value for MACD trigger

int BlackOutPeriodMACD=5;            // number of periods after MACD trigger to ignore additional signals

datetime OrderTimeMACD=0;            // stores time of most recent MACD order
int checktimeMACD=0;                 // stores time remaining in MACD blackout
bool flag_orderMACD=false;           // true if NO MACD orders

// 10hrX Variables:

int MA10hrXTimeframe=PERIOD_H1;      // Timeframe

int MA10hrXslowPeriod=10;            // SMA(10) acts as base line for 10hrX
int MA10hrXslowShift=0;              // Shift
int MA10hrXslowMethod=MODE_SMA;      // Mode
int MA10hrXslowPrice=PRICE_CLOSE;    // Method

int MA10hrXveryslowPeriod=25;        // SMA(25) acts as exit line for 10hrX
int MA10hrXveryslowShift=0;          // Shift
int MA10hrXveryslowMethod=MODE_SMA;  // Mode
int MA10hrXveryslowPrice=PRICE_CLOSE;// Method

int TriggerPips10hrX=20;             // pips above 10hrSMA/price cross to execute order (trigger)
int Timeframe10HrXMonitor=PERIOD_H1; // Timeframe of monitoring 10HrX orders

double TriggerPrice10hrX=0.0;        // price of 10hrX trigger, calculated from TriggerPips10hrX at cross
double Time10hrX=0.0;                // time of 10hrSMA/price cross
double Price10hrX=0.0;               // price at 10hrSMA/price cross
int BlackOutPeriod10hrX=60;          // minutes to ignore future triggers 
datetime OrderTime10hrX=0;           // time of last 10hrX order
bool flag_order10hrX=true;           // true if NO 10hrX order is open
bool flag_10hrXLong=true;            // true if 10hrX up, therefore go long
bool flag_close10hrXLong=false;      // true if exit signal is triggered for long 
bool flag_close10hrXShort=false;     // true if exit signal is triggered for short 

int WindowPeriod10hrX=2;             // number of periods after 10hrX trigger for window of opportunity
int windowtime10hrX=0;               // stores time remaining in 10hrX window of opportunity
int checktime10hrX=0;                // stores time remaining in 10hrX blackout

// 10 day X Variables:

int MA10dayXslowPeriod=10;           // SMA(10) acts as base line for 10 day X
int MA10dayXslowTimeframe=PERIOD_D1; // Timeframe Period = D1
int MA10dayXslowShift=0;             // Shift
int MA10dayXslowMethod=MODE_SMA;     // Mode
int MA10dayXslowPrice=PRICE_CLOSE;   // Method

int MA10dayXMonitorTimeframe=PERIOD_D1; // Timeframe for monitoring of previous day's close

int TriggerPips10dayX=145;           // pips above 10daySMA to execute 10 day cross method
int ExitPips10dayX=21;               // pips above/below 10day SMA to exit 10 day cross orders
int BlackOutPeriod10dayX=2;          // days after an order is executed during which to ignore future signals in the same direction
bool flag_order10dayX=true;          // true if NO 10dayX order is open
datetime LongOrderTime10dayX=0;      // time of most recent long 10 day X order 
datetime ShortOrderTime10dayX=0;     // time of most recent short 10 day X order
int checktime10dayXLong=0;           // stores time remaining in 10dayX long blackout 
int checktime10dayXShort=0;          // stores time remaining in 10dayX short blackout 
bool crossup;                        // TRUE if prices are above SMA(10)

// Stochastics Variables:

double StochTriggerHigh=78.0;        // Upper Stochastic trigger level
double StochTriggerLow=22.0;         // Lower Stochastic trigger level
int StochTimeframe=PERIOD_H4;        // Stochastic timeframe 
int StochK=5;                        // Stochastic %K period
int StochD=5;                        // Stochastic %D Period
int StochSlow=5;                     // Stochastic slowing
int StochMethod=MODE_SMA;            // Stochastic method
int StochPrice=1;                    // Stochastic price field, 0=Low/High, 1=Close/Close
int BlackoutPeriodStoch=4;           // hours to prevent a new Stoch order
datetime OrderTimeStoch=0;           // Stochastic order open Time
bool flag_orderStoch=true;           // true if NO Stochastic order is open
int checktimeStoch=0;                // stores time remaining in Stoch blackout 

// Safety Model's Variables

int TriggerSafety=26;                // pips above/below SMA(40) to trigger close of open Safety orders

int MASafetyfastPeriod=1;            // EMA(1) acts as immediate price action for Safety
int MASafetyfastTimeframe=PERIOD_H1; // Timeframe Period = H1
int MASafetyfastShift=0;             // Shift
int MASafetyfastMethod=MODE_EMA;     // Mode
int MASafetyfastPrice=PRICE_CLOSE;   // Method

int MASafetyslowPeriod=40;           // SMA(40) acts as base line for Safety
int MASafetyslowTimeframe=PERIOD_H1; // Timeframe Period = H1
int MASafetyslowShift=0;             // Shift
int MASafetyslowMethod=MODE_SMA;     // Mode
int MASafetyslowPrice=PRICE_CLOSE;   // Method

bool flag_orderSafety=true;          // true if NO Safety order is open
bool flag_SafetyLong=true;           // true if SafetyOrder is long
datetime OrderTimeSafety=0;          // Safety order's open time 
int BlackoutPeriodSafety=1;          // hours in which to ignore further Safety orders
int checktimeSafety=0;               // stores time remaining in Safety blackout

// Reversal Model's Variables

int PeriodReversal=20;               // hours in scanning period to determine whether current high is a maximum
int TriggerReversal=20;              // pips above/below hour's low/high to trigger order execution
int BlackoutPeriodReversal=60;       // minutes after the submission of a Reversal order to avoid sending another order
datetime OrderTimeReversal=0;        // time of last reversal order
bool flag_orderReversal=true;        // true if NO Reversal order is open
int checktimeReversal=0;             // stores time remaining in Reversal blackout

// DoubleTops Model's Variables

int PeriodDoubleTops=15;             // days to scan for daily high/low 
int TriggerDoubleTops=20;             // pips range within high/low of a new 15 day high/low 
int StopLossAdjustDoubleTop=1;       // pips from day high/low to adjust stop loss after 1st unload
bool flag_orderDoubleTops=true;      // true if NO DoubleTops order is open
bool flag_DoubleTopsLong=false;      // true if long DoubleTops (for stop-loss adjustment)
bool flag_DoubleTopsShort=false;     // true if short DoubleTops (for stop-loss adjustment)
bool flag_DoubleTopsAdjust=false;    // true if we should adjust DoubleTops stop-loss after unload
int BlackoutPeriodDoubleTops=1;      // days to prevent a new DoubleTop order from the time of the last one
datetime OrderTimeDoubleTops=0;      // time of last DoubleTops order
double DayHigh;                      // stores the most recent high
double DayLow;                       // stores the most recent low
int checktimeDoubleTops=0;           // stores time remaining in DoubleTops blackout

// Misc Variables

int Slippage=3;                      // pips slippage allowed

datetime lasthour=99;                // current bar's time to trigger hourly-based MA calculations
datetime lastday=99;                 // current bar's day to trigger DoubleTops method

// Flags which indicate partial takeprofit unloading

bool flag_dump1=false;               // true if TakeProfit_MAUnload-ed
bool flag_dump2=false;               // true if TakeProfit_MACDUnload-ed
bool flag_dump3=false;               // true if TakeProfit_10hrXUnload-ed
bool flag_dump4=false;               // true if TakeProfit_10dayXUnload-ed
bool flag_dump5=false;               // true if TakeProfit_StochUnload-ed
bool flag_dump6a=false;              // true if TakeProfit_Safety1Unload-ed
bool flag_dump6b=false;              // true if TakeProfit_Safety2Unload-ed
bool flag_dump7=false;               // true if TakeProfit_ReversalUnload-ed
bool flag_dump8a=false;              // true if TakeProfit_DoubleTopsUnload-ed
bool flag_dump8b=false;              // true if TakeProfit_DoubleTopsUnload-ed

// Magic numbers (to identify which orders belong to which models)

int magic1=1234;                     // Secret MA order's magic number base
int magic2=2345;                     // MACD order's magic number base
int magic3=3456;                     // 10hrX order's magic number base
int magic4=4567;                     // 10dayX order's magic number base
int magic5=5678;                     // Stochastics order's magic number base
int magic6=6789;                     // Safety order's magic number base
int magic7=7890;                     // Reversal order's magic number base
int magic8=8901;                     // DoubleTops order's magic number base

// Strings 

string commentSecretMA="SecretMA";
string commentMACD="MACD";
string comment10hrX="10hrX";
string comment10dayX="10dayX";
string commentStoch="Stoch";
string commentSafety="Safety";
string commentReversal="Reversal";
string commentDoubleTops="DoubleTops";

// Buffers for Status Display
double ExtMapBuffer1[];
int    xpos=10;                      // pixels from left to show Display Status
int    ypos=10;                      // pixels from top to show Display Status
color  ColorSecretMA=Red;            // colors for Display Status labels
color  ColorMACD=Red;
color  Color10hrX=Red;
color  Color10dayX=Red;
color  ColorStoch=Red;
color  ColorSafety=Red;
color  ColorReversal=Red;
color  ColorDoubleTops=Red;
color  ColorNoOrder=Red;            // color for Inactive method status
color  ColorOrder=Green;            // color for Active method status

//===========================================================================================
//===========================================================================================

int start()                          // main cycle
{
 OrderStatus();                      // check order status to establish open orders and time
 DisplayStatus();                    // display current status of methods
 Main();                             // order execution and maintenance
}

//===========================================================================================
//===========================================================================================

void Main()                          // Main Cycle
{
                                     // The following need every tick info:  
 if(flag_10hrX)
  Monitor10hrX();
  
 if(flag_DoubleTops)
  MonitorDoubleTops();             
  
 TakeProfitUnload();                 // Unload for partial profits
 TrailStop();                        // Trailing Stop

// if(lasthour==Hour())                // The following don't need every tick info,
//  return(0);                         // but only the past hour's close info
// lasthour=Hour();

 if(flag_SecretMA)
  MainSecretMA();

 if(flag_MACD)
  MainMACD();   

 if(flag_10hrX)
  Main10hrX();

 if(flag_Stoch)                      
  MainStoch();

 if(flag_Safety)
  MainSafety();

 if(flag_Reversal)                   
  MainReversal();

// if(lastday==Day())                  // The following only needs to be checked once/day
//  return(0);
// lastday=Day(); 

 if(flag_10dayX)
  Main10dayX();

 if(flag_DoubleTops)
  MainDoubleTops();
 
  return(0);
}

//===========================================================================================
//===========================================================================================

void MainSecretMA()
{
//Calculate Secret MA Indicators
 double fast1=iMA(NULL,MA1Timeframe,MA1Period,MA1Shift,MA1Method,MA1Price,1); 
 double fast2=iMA(NULL,MA1Timeframe,MA1Period,MA1Shift,MA1Method,MA1Price,2);
 double slow1=iMA(NULL,MA2Timeframe,MA2Period,MA2Shift,MA2Method,MA2Price,1); 
 double slow2=iMA(NULL,MA2Timeframe,MA2Period,MA2Shift,MA2Method,MA2Price,2);

 checktimeSecretMA=(BlackoutPeriodSecretMA*3600)-(CurTime()-OrderTimeSecretMA); // need to monitor time in case of EA re-start

//Secret MA Enter Long, Close Shorts
//      
  if(fast1>slow1&&fast2<slow2&&checktimeSecretMA<0)
  {
   CloseShorts(magic1);
   SendOrderLong(Symbol(),LotsMA,Slippage,StopLong(Ask,StopLoss_MA),TakeLong(Ask,TakeProfit_MAMain),commentSecretMA,magic1,0,Blue);
   flag_dump1=true;
   OrderTimeSecretMA=CurTime();
  }//Long
  
//
//Secret MA Enter Short, Close Longs
//
  if(fast1<slow1&&fast2>slow2&&checktimeSecretMA<0)
  {
   CloseLongs(magic1);
   SendOrderShort(Symbol(),LotsMA,Slippage,StopShort(Bid,StopLoss_MA),TakeShort(Bid,TakeProfit_MAMain),commentSecretMA,magic1,0,Red);
   flag_dump1=true;
   OrderTimeSecretMA=CurTime();   
  }//Shrt   
  
 return(0);
}

//===========================================================================================
//===========================================================================================

void MainMACD()
{
 int ticketNumber;

//Calculate MACD Indicators
 double base1=iMACD(NULL,OrderTimeMACDframe,MACDfast,MACDslow,MACDsignal,PRICE_CLOSE,MODE_BASE,1);
 double base2=iMACD(NULL,OrderTimeMACDframe,MACDfast,MACDslow,MACDsignal,PRICE_CLOSE,MODE_BASE,2);
 double signal1=iMACD(NULL,OrderTimeMACDframe,MACDfast,MACDslow,MACDsignal,PRICE_CLOSE,MODE_SIGNAL,1);
 double signal2=iMACD(NULL,OrderTimeMACDframe,MACDfast,MACDslow,MACDsignal,PRICE_CLOSE,MODE_SIGNAL,2);  

 double crosspoint=0.5*(signal1+signal2); // 2 point average for price at crossover

// Determine number of seconds from most recent MACD trigger
 checktimeMACD=(BlackOutPeriodMACD*3600)-(CurTime()-OrderTimeMACD);
  
//
//Enter MACD Long, Exit Short/Long 
//    
 if(base1>signal1 && base2<signal2 && crosspoint<-TriggerMACD && checktimeMACD<0)
 {
  CloseShorts(magic2);

  ticketNumber = GetLong(magic2); // check whether to modify existing longs
  if(ticketNumber >=0)
   ModifyMACDLongs(ticketNumber);
  else
  {  
   SendOrderLong(Symbol(),LotsMACD,Slippage,StopLong(Ask,StopLoss_MACD),TakeLong(Ask,TakeProfit_MACDMain),commentMACD,magic2,0,Blue);
   flag_dump2=true;
  }   
  OrderTimeMACD=CurTime();
 }//Long 
 
//
//Enter MACD Short, Exit Long/Short
//
 if(base1<signal1 && base2>signal2 && crosspoint>TriggerMACD && checktimeMACD<0)
 {
  CloseLongs(magic2);
   
  ticketNumber = GetShort(magic2); // check whether to modify existing short
  if(ticketNumber >=0)
   ModifyMACDShorts(ticketNumber);
  else
  {
   SendOrderShort(Symbol(),LotsMACD,Slippage,StopShort(Bid,StopLoss_MACD),TakeShort(Bid,TakeProfit_MACDMain),commentMACD,magic2,0,Red);
   flag_dump2=true;
  }
  OrderTimeMACD=CurTime();
 }//Short 
 
 return(0);
}

//===========================================================================================
//===========================================================================================

void Main10hrX()
{
//Calculate Indicators
 double fast1=iClose(NULL,MA10hrXTimeframe,1);
 double fast2=iClose(NULL,MA10hrXTimeframe,2);
 double fast3=iClose(NULL,MA10hrXTimeframe,3);
 double slow1=iMA(NULL,MA10hrXTimeframe,MA10hrXslowPeriod,MA10hrXslowShift,MA10hrXslowMethod,MA10hrXslowPrice,1); 
 double slow2=iMA(NULL,MA10hrXTimeframe,MA10hrXslowPeriod,MA10hrXslowShift,MA10hrXslowMethod,MA10hrXslowPrice,2);
 double slow3=iMA(NULL,MA10hrXTimeframe,MA10hrXslowPeriod,MA10hrXslowShift,MA10hrXslowMethod,MA10hrXslowPrice,3);
 double veryslow=iMA(NULL,MA10hrXTimeframe,MA10hrXveryslowPeriod,MA10hrXveryslowShift,MA10hrXveryslowMethod,MA10hrXveryslowPrice,1);

//Check for MA cross
 if(fast1>slow1 && fast2<slow2) // cross UP 1 hour ago
 {
  flag_10hrXLong=true;
  flag_close10hrXLong=false;
  Price10hrX=(slow1+slow2)/2.0;
  Time10hrX=iTime(NULL,MA10hrXTimeframe,1);     
  TriggerPrice10hrX=Price10hrX+(TriggerPips10hrX*Point);
 }
 else if(fast2>slow2 && fast3<slow3) // cross UP 2 hours ago
 {
  flag_10hrXLong=true;
  flag_close10hrXLong=false;
  Price10hrX=(slow2+slow3)/2.0; 
  Time10hrX=iTime(NULL,MA10hrXTimeframe,2);
  TriggerPrice10hrX=Price10hrX+(TriggerPips10hrX*Point);
 }
   
 if(fast1<slow1 && fast2>slow2) // cross DOWN 1 bar ago
 {
  flag_10hrXLong=false;
  flag_close10hrXShort=false;
  Price10hrX=(slow1+slow2)/2.0;
  Time10hrX=iTime(NULL,MA10hrXTimeframe,1);
  TriggerPrice10hrX=Price10hrX-(TriggerPips10hrX*Point);
 }
 else if(fast2<slow2 && fast3>slow3) // cross DOWN 2 bars ago
 {
  flag_10hrXLong=false;
  flag_close10hrXShort=false;
  Price10hrX=(slow2+slow3)/2.0;  
  Time10hrX=iTime(NULL,MA10hrXTimeframe,2);
  TriggerPrice10hrX=Price10hrX-(TriggerPips10hrX*Point);
 }

// check exit signals for main 10hrX order:
 
 if(fast1<veryslow&&flag_order10hrX==false)
  flag_close10hrXLong=true;
 
 if(fast1>veryslow&&flag_order10hrX==false)
  flag_close10hrXShort=true;
 
 return(0);
}

//===========================================================================================
//===========================================================================================

void Monitor10hrX()
{
// Add 1 to WindowPeriod10hrX because crossover determination is delayed 1 full period
// The following gives a 2 hour window, if WindowPeriod10hrX=2:  
  windowtime10hrX = ((WindowPeriod10hrX+1)*3600)- (CurTime()-Time10hrX);
  checktime10hrX   = (BlackOutPeriod10hrX*60)-(CurTime()-OrderTime10hrX);

 if(flag_order10hrX)
 {
  double SL=0.0;

//Enter Long 
//      
  if(Ask>=TriggerPrice10hrX&&flag_10hrXLong==true&&windowtime10hrX>=0&&checktime10hrX<0)
  {
   if(StopLoss_10hrX==0)
//   SL=iLow(NULL,Timeframe10HrXMonitor,1);
//   SL=Price10hrX;
    SL=0.0;
   else
    SL=StopLong(Ask,StopLoss_10hrX);
   
   SendOrderLong(Symbol(),Lots10hrX,Slippage,SL,TakeLong(Ask,TakeProfit_10hrXMain),comment10hrX,magic3,0,Blue);
   OrderTime10hrX=CurTime();
   flag_dump3=true;
 }//Long 
//
//Enter Short 
//
  if(Bid<=TriggerPrice10hrX&&flag_10hrXLong==false&&windowtime10hrX>=0&&checktime10hrX<0)
  {
   if(StopLoss_10hrX==0)
//   SL=iHigh(NULL,Timeframe10HrXMonitor,1);
//   SL=Price10hrX;
   SL=0.0;
   else
    SL=StopShort(Bid,StopLoss_10hrX);  
   
   SendOrderShort(Symbol(),Lots10hrX,Slippage,SL,TakeShort(Bid,TakeProfit_10hrXMain),comment10hrX,magic3,0,Red);
   OrderTime10hrX=CurTime();
   flag_dump3=true;
  }//Shrt
 }
 else
 {
  if(flag_close10hrXLong)
  {
   CloseLongs(magic3);
   flag_close10hrXLong=false;
  }
  
  if(flag_close10hrXShort)
  {
   CloseShorts(magic3);
   flag_close10hrXShort=false;
  }
 }
 return(0);
}

//===========================================================================================
//===========================================================================================

void Main10dayX()
{
 double SL=0.0;

//Calculate 10 Day Cross Indicators 

 double signal=iMA(NULL,MA10dayXslowTimeframe,MA10dayXslowPeriod,MA10dayXslowShift,MA10dayXslowMethod,MA10dayXslowPrice,1); // previous SMA(10 day)'s value
 double closeDay=iClose(NULL,MA10dayXMonitorTimeframe,1); // previous day's close

 if(closeDay>signal)
  crossup=true;
 else
  crossup=false;

  checktime10dayXLong=(BlackOutPeriod10dayX*3600*24)-(CurTime()-LongOrderTime10dayX); // prevent new orders within BlackOutPeriod10dayX number of DAYS 
  checktime10dayXShort=(BlackOutPeriod10dayX*3600*24)-(CurTime()-ShortOrderTime10dayX);

 if(flag_order10dayX) 
 {
//
//10 Day Cross Enter Long
//
  if(closeDay>signal+(TriggerPips10dayX*Point)&&crossup&&checktime10dayXLong<0)         // of most recent order in the same direction
  {
   if(StopLoss_10dayX==0)
    SL=iLow(NULL,PERIOD_D1,1);
   else
    SL=StopLong(Ask,StopLoss_10dayX);
   
   SendOrderLong(Symbol(),Lots10dayX,Slippage,SL,TakeLong(Ask,TakeProfit_10dayXMain),comment10dayX,magic4,0,Blue);
   LongOrderTime10dayX=CurTime();
   flag_dump4=true;
  }//Long
  
//
//10 Day Cross Enter Short
//

  if(closeDay<signal-(TriggerPips10dayX*Point)&&!crossup&&checktime10dayXShort<0)         // of most recent order in the same direction
  {
   if(StopLoss_10dayX==0)
    SL=iHigh(NULL,PERIOD_D1,1);
   else
    SL=StopLong(Bid,StopLoss_10dayX); 
 
   SendOrderShort(Symbol(),Lots10dayX,Slippage,SL,TakeShort(Bid,TakeProfit_10dayXMain),comment10dayX,magic4,0,Red);
   ShortOrderTime10dayX=CurTime();
   flag_dump4=true;
  }//Shrt
 } 
 else
 {
//
//10 Day Cross Exit Long 
// 
  if(closeDay<signal-(ExitPips10dayX*Point)&&!crossup)
   CloseLongs(magic4);
  
//
//10 Day Cross Exit Short 
// 
  if(closeDay>signal+(ExitPips10dayX*Point)&&crossup)
   CloseShorts(magic4);  
 }
 return(0);
}

//===========================================================================================
//===========================================================================================

void MainStoch()
{
 double base1=iStochastic(NULL,StochTimeframe,StochK,StochD,StochSlow,StochMethod,StochPrice,0,1);
 double signal1=iStochastic(NULL,StochTimeframe,StochK,StochD,StochSlow,StochMethod,StochPrice,1,1);
 double base2=iStochastic(NULL,StochTimeframe,StochK,StochD,StochSlow,StochMethod,StochPrice,0,2);
 double signal2=iStochastic(NULL,StochTimeframe,StochK,StochD,StochSlow,StochMethod,StochPrice,1,2);

 double crosspoint=0.5*(signal1+signal2); // 2 point average of slower signal for price at crossover

 checktimeStoch=(BlackoutPeriodStoch*3600)-(CurTime()-OrderTimeStoch);

 if(flag_orderStoch&&checktimeStoch<0) // need to check this because the indicator is based on H4, while the check is every H1
 {
// cross up, go Long
  if(base1>signal1&&base2<signal2&&crosspoint<=StochTriggerLow)
  {
   SendOrderLong(Symbol(),LotsStoch,Slippage,StopLong(Ask,StopLoss_Stoch),TakeLong(Ask,TakeProfit_Stoch),commentStoch,magic5,0,Blue); 
   OrderTimeStoch=CurTime();
   flag_dump5=true;
  }

// cross down, go Short
  if(base1<signal1&&base2>signal2&&crosspoint>=StochTriggerHigh)  
  {
   SendOrderShort(Symbol(),LotsStoch,Slippage,StopShort(Bid,StopLoss_Stoch),TakeShort(Bid,TakeProfit_Stoch),commentStoch,magic5,0,Red); 
   OrderTimeStoch=CurTime();  
   flag_dump5=true;
  }
 } 
 else if(!flag_orderStoch&&checktimeStoch<0)
 {
// cross up, exit Short, enter Long (need to do this here to avoid an hour delay in new order)
  if(base1>signal1&&base2<signal2&&crosspoint<=StochTriggerLow)
  {
   CloseShorts(magic5);
   SendOrderLong(Symbol(),LotsStoch,Slippage,StopLong(Ask,StopLoss_Stoch),TakeLong(Ask,TakeProfit_Stoch),commentStoch,magic5,0,Blue); 
   OrderTimeStoch=CurTime();
   flag_dump5=true;   
  }
// cross down, exit Long, enter Short (need to do this here to avoid an hour delay in new order)
  if(base1<signal1&&base2>signal2&&crosspoint>=StochTriggerHigh)
  {
   CloseLongs(magic5); 
   SendOrderShort(Symbol(),LotsStoch,Slippage,StopShort(Bid,StopLoss_Stoch),TakeShort(Bid,TakeProfit_Stoch),commentStoch,magic5,0,Red); 
   OrderTimeStoch=CurTime(); 
   flag_dump5=true;   
  }
 }  
 return(0);
}

//===========================================================================================
//===========================================================================================

void MainSafety()
{
 double crossprice;
 double triggerprice;

 double fast1=iClose(NULL,MASafetyfastTimeframe,1);
 double fast2=iClose(NULL,MASafetyfastTimeframe,2);
 double slow1=iMA(NULL,MASafetyslowTimeframe,MASafetyslowPeriod,MASafetyslowShift,MASafetyslowMethod,MASafetyslowPrice,1);
 double slow2=iMA(NULL,MASafetyslowTimeframe,MASafetyslowPeriod,MASafetyslowShift,MASafetyslowMethod,MASafetyslowPrice,2);

 checktimeSafety = (BlackoutPeriodSafety*3600)-(CurTime()-OrderTimeSafety);
  
 if(flag_orderSafety==true&&checktimeSafety<0)
 {
  if(fast1>slow1&&fast2<slow2)  // Cross UP Long trigger 
  {
   SendOrderLong(Symbol(),LotsSafety,Slippage,StopLong(Ask,StopLoss_Safety),TakeLong(Ask,TakeProfit_Safety),commentSafety,magic6,0,Blue);
   OrderTimeSafety=CurTime();
   flag_dump6a=true;
   flag_dump6b=false;
  }
  if(fast1<slow1&&fast2>slow2)  // Short trigger
  {
   SendOrderShort(Symbol(),LotsSafety,Slippage,StopShort(Bid,StopLoss_Safety),TakeShort(Bid,TakeProfit_Safety),commentSafety,magic6,0,Red); 
   OrderTimeSafety=CurTime();
   flag_dump6a=true;
   flag_dump6b=false;
  }      
 }
  
 if(flag_orderSafety==false)
 {
  crossprice=slow1;
  triggerprice=crossprice-(TriggerSafety*Point);
  
  if(fast1<triggerprice&&flag_SafetyLong)  // Close Long trigger, Enter Short 
  {
   CloseLongs(magic6);
   SendOrderShort(Symbol(),LotsSafety,Slippage,StopShort(Bid,StopLoss_Safety),TakeShort(Bid,TakeProfit_Safety),commentSafety,magic6,0,Red); 
   OrderTimeSafety=CurTime();
   flag_dump6a=true;
   flag_dump6b=false;
  }
  
  triggerprice=crossprice+(TriggerSafety*Point);
  if(fast1>triggerprice&&!flag_SafetyLong)  // Close Short trigger, Enter Long
  {
   CloseShorts(magic6);
   SendOrderLong(Symbol(),LotsSafety,Slippage,StopLong(Ask,StopLoss_Safety),TakeLong(Ask,TakeProfit_Safety),commentSafety,magic6,0,Blue); 
   OrderTimeSafety=CurTime();
   flag_dump6a=true;
   flag_dump6b=false;
  }      
 }    
 return(0);
}

//===========================================================================================
//===========================================================================================

void MainReversal()
{
 double SL;
 
 checktimeReversal=(BlackoutPeriodReversal*60)-(CurTime()-OrderTimeReversal); 

 if(flag_orderReversal&&checktimeReversal<0)
 { 
  double HrHigh=iHigh(NULL,PERIOD_H1,1);                               // the just completed hour's high
  double pastHrHigh=iHigh(NULL,PERIOD_H1,Highest(NULL,PERIOD_H1,MODE_HIGH,PeriodReversal,1)); // past PeriodReversal hours high
  double HrClose=iClose(NULL,PERIOD_H1,1);
 
  if(HrHigh>=pastHrHigh&&HrClose<=(HrHigh-(TriggerReversal*Point))) // we are at a high, so check conditions for sell
  {
   SL=HrHigh+(StopLoss_Reversal*Point);
   SendOrderShort(Symbol(),LotsReversal,Slippage,SL,TakeShort(Bid,TakeProfit_Reversal),commentReversal,magic7,0,Red); 
   flag_dump7=true;
   OrderTimeReversal=CurTime();
  }

  double HrLow=iLow(NULL,PERIOD_H1,1);                                // this current hour's low
  double pastHrLow=iLow(NULL,PERIOD_H1,Lowest(NULL,PERIOD_H1,MODE_LOW,PeriodReversal,1));    // past PeriodReversal hours low

  if(HrLow<=pastHrLow&&HrClose>=(HrLow+(TriggerReversal*Point)))  // we are at a low, so check conditions for buy
  {
   SL=HrLow-(StopLoss_Reversal*Point);
   SendOrderLong(Symbol(),LotsReversal,Slippage,SL,TakeLong(Ask,TakeProfit_Reversal),commentReversal,magic7,0,Blue); 
   flag_dump7=true;
   OrderTimeReversal=CurTime();
  }  
  
 }
 return(0);
}

//===========================================================================================
//===========================================================================================
void MainDoubleTops()
{
 double SL;

  checktimeDoubleTops=(BlackoutPeriodDoubleTops*24*3600)-(CurTime()-OrderTimeDoubleTops);
   
 if(flag_orderDoubleTops)
 {
  double Day1High=iHigh(NULL,PERIOD_D1,1);          // the previous day's high
  double Day2High=iHigh(NULL,PERIOD_D1,2);          // the 2nd to last day's high
  double previousHighs=iHigh(NULL,PERIOD_D1,Highest(NULL,PERIOD_D1,MODE_HIGH,PeriodDoubleTops,2)); // past PeriodDoubleTops days' high
 
  if(Day2High>=previousHighs&&MathAbs(Day1High-Day2High)<=(TriggerDoubleTops*Point)&&checktimeDoubleTops<0) // if 2-day old top and previous day's high is within the trigger band, execute order
  {
   if(Day1High>Day2High)                            // which day's high is higher?
   {
    DayHigh=Day1High;                               // for later stop-loss adjustment
    SL=Day1High+(StopLoss_DoubleTops*Point);        // assign stop losses according to the higher of the two highs
   }
   else
   {
    DayHigh=Day2High;                               // for later stop-loss adjustment
    SL=Day2High+(StopLoss_DoubleTops*Point);
   } 
     
   SendOrderShort(Symbol(),LotsDoubleTops,Slippage,SL,TakeShort(Bid,TakeProfit_DoubleTops),commentDoubleTops,magic8,0,Red); 
   OrderTimeDoubleTops=CurTime();
   flag_DoubleTopsShort=true;
   flag_DoubleTopsLong=false;
   flag_DoubleTopsAdjust=false;
   flag_dump8a=true;
   flag_dump8b=false;     
  }
   
  double Day1Low=iLow(NULL,PERIOD_D1,1);            // the previous day's low
  double Day2Low=iLow(NULL,PERIOD_D1,2);            // the 2nd to last day's low
  double previousLows=iLow(NULL,PERIOD_D1,Lowest(NULL,PERIOD_D1,MODE_LOW,PeriodDoubleTops,2)); // past PeriodDoubleTops days' high

  if(Day2Low<=previousLows&&MathAbs(Day1Low-Day2Low)<=(TriggerDoubleTops*Point)&&checktimeDoubleTops<0)  // if if 2-day old low and previous day's low is within the trigger band, execute order
  {
   if(Day1Low<Day2Low)                             // which day's low is lower?
   {
    DayLow=Day1Low;                                // for later stop-loss adjustment
    SL=Day1Low-(StopLoss_DoubleTops*Point);        // assign stop-losses according to the lower of the two lows
   }
   else
   {
    DayLow=Day2Low;                                // for later stop-loss adjustment
    SL=Day2Low-(StopLoss_DoubleTops*Point);
   }
     
   SendOrderLong(Symbol(),LotsDoubleTops,Slippage,SL,TakeLong(Ask,TakeProfit_DoubleTops),commentDoubleTops,magic8,0,Blue); 
   OrderTimeDoubleTops=CurTime();
   flag_DoubleTopsLong=true;
   flag_DoubleTopsShort=false;
   flag_DoubleTopsAdjust=false;
   flag_dump8a=true;
   flag_dump8b=false;   
  }
 } 
 return(0);
}

//===========================================================================================
//===========================================================================================

void MonitorDoubleTops()
{
 int ticketnumber;
 if(!flag_dump8a&&flag_DoubleTopsAdjust)
 {
  double SL;
  if(flag_DoubleTopsLong)
  {
   SL=DayLow-(StopLossAdjustDoubleTop*Point);  // adjust stop loss
   ticketnumber=GetLong(magic8);
  }  
  else if(flag_DoubleTopsShort)
  {
   SL=DayHigh+(StopLossAdjustDoubleTop*Point);  // adjust stop loss
   ticketnumber=GetShort(magic8);
  }
  ModifyOrder(ticketnumber,OrderOpenPrice(),SL,OrderTakeProfit(),0,Blue); // modify with new stop-loss
  flag_DoubleTopsAdjust=false;                  // deactivate flag to prevent another adjustment 
  }
}
//===========================================================================================
//===========================================================================================

void ModifyMACDLongs(int ticketNumber) // by Mike
{
// If long(s) already open, modify so we don't have to repay the spread. 
// If there is a long open and it has lots==LotsMACD we can just modify. If its already been unloaded we can modify the
// exiting one and order a new one to cover the difference. If we have already been through this process and have two
// outstanding orders we modify both.

// Coded by Mike

 int ticketNumber2; 
 double lotsToOrder;
 double profitTarget;

 if(OrderLots() == LotsMACD)
 {  
  ModifyOrder(ticketNumber,OrderOpenPrice(),StopLong(Ask,StopLoss_MACD),TakeLong(Ask,TakeProfit_MACDMain),0,Blue);
  flag_dump2=true;
 }
 else
 {  
  if(OrderLots() == LotsMACDUnload)
  {  
   ModifyOrder(ticketNumber,OrderOpenPrice(),StopLong(Ask,StopLoss_MACD),TakeLong(Ask,TakeProfit_MACDUnload),0,Blue);
   lotsToOrder = LotsMACD - LotsMACDUnload;
   profitTarget = TakeLong(Ask,TakeProfit_MACDMain);
  }
  else
  {  
   ModifyOrder(ticketNumber,OrderOpenPrice(),StopLong(Ask,StopLoss_MACD),TakeLong(Ask,TakeProfit_MACDMain),0,Blue);
   lotsToOrder = LotsMACDUnload;
   profitTarget = TakeLong(Ask,TakeProfit_MACDUnload);
  }
         
  ticketNumber2 = GetLong(magic2,ticketNumber); 
  if(ticketNumber2 >= 0)
   ModifyOrder(ticketNumber2,OrderOpenPrice(),StopLong(Ask,StopLoss_MACD),profitTarget,0,Blue);
  else
   SendOrderLong(Symbol(),lotsToOrder,Slippage,StopLong(Ask,StopLoss_MACD),profitTarget,NULL,magic2,0,Blue);  
 }
 
 return(0);
}

//===========================================================================================
//===========================================================================================

void ModifyMACDShorts(int ticketNumber)  // by Mike
{
 int ticketNumber2; 
 double lotsToOrder;
 double profitTarget;
 
 if(OrderLots() == LotsMACD)
 {  
  ModifyOrder(ticketNumber,OrderOpenPrice(),StopShort(Bid,StopLoss_MACD),TakeShort(Bid,TakeProfit_MACDMain),0,Red);
  flag_dump2=true;
 }
 else
 {  
  if(OrderLots() == LotsMACDUnload)
  {  
   ModifyOrder(ticketNumber,OrderOpenPrice(),StopShort(Bid,StopLoss_MACD),TakeShort(Bid,TakeProfit_MACDUnload),0,Red);
   lotsToOrder = LotsMACD - LotsMACDUnload;
   profitTarget = TakeShort(Bid,TakeProfit_MACDMain);
  }
  else
  {  
   ModifyOrder(ticketNumber,OrderOpenPrice(),StopShort(Bid,StopLoss_MACD),TakeShort(Bid,TakeProfit_MACDMain),0,Red);
   lotsToOrder = LotsMACDUnload;
   profitTarget = TakeShort(Bid,TakeProfit_MACDUnload);
  }
         
 ticketNumber2 = GetShort(magic2,ticketNumber); 
 if(ticketNumber2 >= 0)
  ModifyOrder(ticketNumber2,OrderOpenPrice(),StopShort(Bid,StopLoss_MACD),profitTarget,0,Red);
 else
  SendOrderShort(Symbol(),lotsToOrder,Slippage,StopShort(Bid,StopLoss_MACD),profitTarget,NULL,magic2,0,Red);  
 }
 
 return(0);
}

//===========================================================================================
//===========================================================================================

int GetLong(int magic, int prevTicket=-1)  // by Mike
{
 int trade;
 int trades=OrdersTotal();
 for(trade=trades-1;trade>=0;trade--)
 {  
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()==Symbol()&&OrderMagicNumber()==magic&&OrderType()==OP_BUY && OrderTicket()!=prevTicket)
   return(OrderTicket());
 }
 return(-1);
}
//===========================================================================================
//===========================================================================================

int GetShort(int magic, int prevTicket=-1)  // by Mike
{
 int trade;
 int trades=OrdersTotal();
 for(trade=trades-1;trade>=0;trade--)
 {  
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()==Symbol()&&OrderMagicNumber()==magic&&OrderType()==OP_SELL && OrderTicket()!=prevTicket)
   return(OrderTicket());
 }
 return(-1);
}
//===========================================================================================
//===========================================================================================

void CloseLongs(int magic)  // by Patrick (w/Mike's loop fix)
{
 int trade;
 int trades=OrdersTotal();
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()==Symbol()&&OrderMagicNumber()==magic&&OrderType()==OP_BUY)
   CloseOrderLong(OrderTicket(),OrderLots(),Slippage,Blue); 
 } //for
 return(0);
}

//===========================================================================================
//===========================================================================================

void CloseShorts(int magic)  // by Patrick (w/Mike's loop fix)
{
 int trade;
 int trades=OrdersTotal();
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()==Symbol()&&OrderMagicNumber()==magic&&OrderType()==OP_SELL)
   CloseOrderShort(OrderTicket(),OrderLots(),Slippage,Red); 
 } //for
 return(0);
}

//===========================================================================================
//===========================================================================================

double TakeLong(double price,int take)  // function to calculate takeprofit if long (by Patrick)
{
 if(take==0)
  return(0.0); // if no take profit
 return(price+(take*Point)); 
             // plus, since the take profit is above us for long positions
}

//===========================================================================================
//===========================================================================================

double TakeShort(double price,int take)  // function to calculate takeprofit if short (by Patrick)
{
 if(take==0)
  return(0.0); // if no take profit
 return(price-(take*Point)); 
             // minus, since the take profit is below us for short positions
}

//===========================================================================================
//===========================================================================================

double StopLong(double price,int stop) // function to calculate stoploss if long (by Patrick)
{
 if(stop==0)
  return(0.0); // if no stop loss
 return(price-(stop*Point)); 
             // minus, since the stop loss is below us for long positions
             // Point is 0.01 or 0.001 depending on currency, so stop*POINT is a way to convert pips into price with multiplication 
}

//===========================================================================================
//===========================================================================================

double StopShort(double price,int stop) // function to calculate stoploss if short (by Patrick)
{
 if(stop==0)
  return(0.0); // if no stop loss
 return(price+(stop*Point)); 
             // plus, since the stop loss is above us for short positions
}

//===========================================================================================
//===========================================================================================

void TakeProfitUnload() // Unload LotsUnload at TakeProfit_MACDUnload and/or LotsUnloadMACD at TakeProfit_MACDUnload
{
 if(flag_dump1) 
 {
  if(TakeProfit_MAUnload!=0) 
   flag_dump1=TakeProfitCycle(flag_dump1,LotsMAUnload,magic1,TakeProfit_MAUnload);
 }
 
 if(flag_dump2) 
 {
  if(TakeProfit_MACDUnload!=0)
   flag_dump2=TakeProfitCycle(flag_dump2,LotsMACDUnload,magic2,TakeProfit_MACDUnload);
 }
  
  if(flag_dump3) 
 {
  if(TakeProfit_10hrXUnload!=0)
   flag_dump3=TakeProfitCycle(flag_dump3,Lots10hrXUnload,magic3,TakeProfit_10hrXUnload);
 }
 
 if(flag_dump4) 
 {
  if(TakeProfit_10dayXUnload!=0)  
   flag_dump4=TakeProfitCycle(flag_dump4,Lots10dayXUnload,magic4,TakeProfit_10dayXUnload);
 }

 if(flag_dump5) 
 {
  if(TakeProfit_StochUnload!=0)  
   flag_dump5=TakeProfitCycle(flag_dump5,LotsStochUnload,magic5,TakeProfit_StochUnload);
 }
 
 if(flag_dump6a)
 {
  if(TakeProfit_Safety1Unload!=0)
   flag_dump6a=TakeProfitCycle(flag_dump6a,LotsSafety1Unload,magic6,TakeProfit_Safety1Unload);
   
  if(!flag_dump6a)
   flag_dump6b=true;
 }

 if(flag_dump6b)
 {
  if(TakeProfit_Safety2Unload!=0)
   flag_dump6b=TakeProfitCycle(flag_dump6b,LotsSafety2Unload,magic6,TakeProfit_Safety2Unload);
 } 
 
 if(flag_dump7)
 {
  if(TakeProfit_ReversalUnload!=0)
   flag_dump7=TakeProfitCycle(flag_dump7,LotsReversalUnload,magic7,TakeProfit_ReversalUnload);
 }
 
 if(flag_dump8a)
 {
  if(TakeProfit_DoubleTops1Unload!=0)
   flag_dump8a=TakeProfitCycle(flag_dump8a,LotsDoubleTops1Unload,magic8,TakeProfit_DoubleTops1Unload);

  if(!flag_dump8a)
  {
   flag_dump8b=true;
   flag_DoubleTopsAdjust=true;
  }
 }    

 if(flag_dump8b)
 {
  if(TakeProfit_DoubleTops2Unload!=0)
   flag_dump8b=TakeProfitCycle(flag_dump8b,LotsDoubleTops2Unload,magic8,TakeProfit_DoubleTops2Unload);
 }  
 
 return(0); 
}

//===========================================================================================
//===========================================================================================

bool TakeProfitCycle(bool flag, double lots, int magic, int takeprofit) // cycles through proper orders to take profit
{  
 double stopcrnt;
 double stopcal;
  
 int trade;
 int trades=OrdersTotal();
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()!=Symbol())
   continue;

//Long 
  if(OrderType()==OP_BUY&&OrderMagicNumber()==magic)
  {
   if(Bid-OrderOpenPrice()>=takeprofit*Point)
   {
    CloseOrderLong(OrderTicket(),lots,Slippage,Blue);
    flag=false;
   }
   else flag=true;  
  }//Long 
  
//Short 
   if(OrderType()==OP_SELL&&OrderMagicNumber()==magic)
   {
    if(OrderOpenPrice()-Ask>=takeprofit*Point)
    {
     CloseOrderShort(OrderTicket(),lots,Slippage,Red);
     flag=false; 
    }
    else flag=true;  
   }//Short   
  } //for
 return(flag);
}

//===========================================================================================
//===========================================================================================

void TrailStop() // Unload LotsUnload at TakeProfit_MACDUnload and/or LotsUnloadMACD at TakeProfit_MACDUnload
{
 if(flag_SecretMA) 
 {
  if(TrailingStop_MA!=0) 
   TrailingAlls(magic1,TrailingStop_MA);
 }
 
 if(flag_MACD) 
 {
  if(TrailingStop_MACD!=0) 
   TrailingAlls(magic2,TrailingStop_MACD);
 }
 
  if(flag_10hrX) 
 {
  if(TrailingStop_10hrX!=0) 
   TrailingAlls(magic3,TrailingStop_10hrX);
 }
 
  if(flag_10dayX) 
 {
  if(TrailingStop_10dayX!=0) 
   TrailingAlls(magic4,TrailingStop_10dayX,TrailingStop_10dayXUnload,Lots10dayX,Lots10dayXUnload);
 } 
 
  if(flag_Stoch) 
 {
  if(TrailingStop_Stoch!=0) 
   TrailingAlls(magic5,TrailingStop_Stoch,TrailingStop_StochUnload,LotsStoch,LotsStochUnload);
 } 

  if(flag_Safety) 
 {
  if(TrailingStop_Safety!=0) 
   TrailingAlls(magic6,TrailingStop_Safety);
 }
 
 if(flag_Reversal) 
 {
  if(TrailingStop_Reversal!=0) 
   TrailingAlls(magic7,TrailingStop_Reversal,TrailingStop_ReversalUnload,LotsReversal,LotsReversalUnload);
 }
 
 if(flag_DoubleTops)
 {
  if(TrailingStop_DoubleTops!=0)
   TrailingAlls(magic8,TrailingStop_DoubleTops,TrailingStop_DoubleTopsUnload,LotsDoubleTops,LotsDoubleTops1Unload);   
 }

 return(0); 
}

//===========================================================================================
//===========================================================================================

// Accomodates multiple trails ... if unloaded, used trailing stop associated with main order 
// otherwise, use the trailing stop associated with TrailingStop_MethodUnload.

void TrailingAlls(int magic,int trail,int trail2=-1,double lots1=0,double lots2=0)  // client-side trailing stop (by Patrick, modified by David)
{  
 double stopcrnt;
 double stopcal;

 int trade;
 int trades=OrdersTotal();
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()!=Symbol())
   continue;

//Long 
  if(OrderType()==OP_BUY && OrderMagicNumber()==magic)
  { 
  if(trail2==-1)
   stopcal=Bid-(trail*Point);  
  else
  {
   if(OrderLots()==lots1-lots2) // unloaded, so use trail
    stopcal=Bid-(trail*Point); 
   else
    stopcal=Bid-(trail2*Point); // not yet unloaded, so use TrailingStop_MethodUnload
  }
  
   stopcrnt=OrderStopLoss();

   if(stopcrnt==0)
    ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Blue);
   else if(stopcal>stopcrnt)
    ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Blue);
  }//Long 
  
//Short 
  if(OrderType()==OP_SELL && OrderMagicNumber()==magic)
  {
   if(trail2==-1)
    stopcal=Ask+(trail*Point);  
   else
   {
    if(OrderLots()==lots1-lots2) // unloaded, so use trail
     stopcal=Ask+(trail*Point); 
    else
     stopcal=Ask+(trail2*Point); // not yet unloaded, so use TrailingStop_MethodUnload
   }
   
    stopcrnt=OrderStopLoss();
 
    if(stopcrnt==0)
     ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red);
    else if(stopcal<stopcrnt)
     ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red);
  }//Short   
 } //for
 return(0);
}

//===========================================================================================
//===========================================================================================

void OrderStatus()                   // Check order status
{
 int trade;                          // dummy variable to cycle through trades
 int trades=OrdersTotal();           // total number of open orders
 
 flag_orderSecretMA=true;            // first assume we have no open SecretMA orders
 flag_orderMACD=true;                // first assume we have no open MACD orders
 flag_order10hrX=true;               // first assume we have no open 10hrX orders
 flag_order10dayX=true;              // first assume we have no open 10dayX orders
 flag_orderStoch=true;               // first assume we have no open Stoch orders 
 flag_orderSafety=true;              // first assume we have no open Safety orders
 flag_orderReversal=true;            // first assume we have no open Reversal orders
 flag_orderDoubleTops=true;          // first assume we have no open DoubleTops orders
 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
   
  if(OrderSymbol()!=Symbol())
   continue;
   
  switch(OrderMagicNumber())
  {
   case 1234:
    flag_orderSecretMA=false;         // false if there are open SecretMA orders
    break;
   case 2345:
    flag_orderMACD=false;             // false if there are open MACD orders 
    break;    
   case 3456:
    flag_order10hrX=false;            // false if there are open 10hrX orders
    break;
   case 4567:
    flag_order10dayX=false;           // false if there are open 10dayX orders
    break;
   case 5678:
    flag_orderStoch=false;            // false if there are open Stoch orders
    break;
   case 6789:
    flag_orderSafety=false;           // false if there are open Safety orders
    if(OrderType()==OP_BUY)
     flag_SafetyLong=true;
    else
     flag_SafetyLong=false; 
    break;  
   case 7890:
    flag_orderReversal=false;         // false if there are open Reversal orders
    break;
   case 8901:
    flag_orderDoubleTops=false;       // false if there are open DoubleTops orders
    break;
  }
 }
return(0);
}
  
//===========================================================================================
//===========================================================================================

int init()
{
// hello world
// Set semaphore for multiple threads
 if(!GlobalVariableCheck("SEMAPHORE"))
  GlobalVariableSet("SEMAPHORE",0);

// In case EA becomes disabled/re-activated during trading:
// 1. Redetermine most recent order open times to re-establish proper blackout/opportunity windows.
// 2. Redetermine if a main order has been unloaded.

// In case EA becomes disabled/re-activated during trading,
// re-determine most recent order close times to prevent re-submission before a full period (hour or day) has elapsed

// First check closed trades
 int trade;                         
 int trades=HistoryTotal();           
 for(trade=trades-1;trade>=0;trade--)   // The most recent closed order has the largest position number, so this works backward from the most recent closed orders
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_HISTORY);

  if(OrderSymbol()!=Symbol())
   continue;

  double timediff=(CurTime()-OrderCloseTime())/3600;  // time difference in hours

  if(timediff >= 24) // only interested in closed trades on this day
   continue;

  switch(OrderMagicNumber())
  {
   case 4567:                                 // for 10dayX trades
    if(OrderType()==OP_BUY)
     LongOrderTime10dayX=OrderOpenTime();
    else if(OrderType()==OP_SELL)
     ShortOrderTime10dayX=OrderOpenTime();
    continue; 
   case 8901:                                 // for DoubleTops trades
     OrderTimeDoubleTops=OrderOpenTime(); 
    continue;
  }
  
  if(timediff >= 1) // only interested in closed trades in this hour
   continue;

  switch(OrderMagicNumber())
  {
   case 1234: 
    OrderTimeSecretMA=OrderOpenTime();
    continue;
   case 2345:
    OrderTimeMACD=OrderOpenTime();
    continue;
   case 3456:
    OrderTime10hrX=OrderOpenTime();
    continue;
   case 5678:
    OrderTimeStoch=OrderOpenTime();
    continue;
   case 6789:
    OrderTimeSafety=OrderOpenTime();
    continue;
   case 7890:
    OrderTimeReversal=OrderOpenTime();
    continue;
  }   
 } 

// Now check open orders
                       
 trades=OrdersTotal();           
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()!=Symbol())
   continue;

  switch(OrderMagicNumber())
  {
   case 1234: 
    OrderTimeSecretMA=OrderOpenTime();
    if(OrderLots()==LotsMA)
     flag_dump1=true;
    continue;
   case 2345:
    OrderTimeMACD=OrderOpenTime();
    if(OrderLots()==LotsMACD)
     flag_dump2=true;
    continue;
   case 3456:
    OrderTime10hrX=OrderOpenTime();
    if(OrderLots()==Lots10hrX)
     flag_dump3=true;
    continue;
   case 4567:
    if(OrderType()==OP_BUY)
     LongOrderTime10dayX=OrderOpenTime();
    else if(OrderType()==OP_SELL)
     ShortOrderTime10dayX=OrderOpenTime();
    if(OrderLots()==Lots10dayX)
     flag_dump4=true;
    continue; 
   case 5678:
    OrderTimeStoch=OrderOpenTime();
    if(OrderLots()==LotsStoch)
     flag_dump5=true;
    continue;
   case 6789:
    OrderTimeSafety=OrderOpenTime();
    if(OrderLots()==LotsSafety)
    {
     flag_dump6a=true;
     flag_dump6b=false;
    }
    else if(OrderLots()==LotsSafety1Unload+LotsSafety2Unload)
    {
     flag_dump6a=false;
     flag_dump6b=true;
    }
    else
    {
     flag_dump6a=false;
     flag_dump6b=false;    
    }
    continue;
   case 7890:
    OrderTimeReversal=OrderOpenTime();
    if(OrderLots()==LotsReversal)
     flag_dump7=true;
    continue;
   case 8901:
    if(OrderType()==OP_BUY)
    {
     flag_DoubleTopsLong=true;
     flag_DoubleTopsShort=false; // redundant
    }
    if(OrderType()==OP_SELL)
    {
     flag_DoubleTopsShort=true;
     flag_DoubleTopsLong=false; // redundant
    }
    OrderTimeDoubleTops=OrderOpenTime();
    // Need High/Low for DoubleTops stop-loss adjustment    
    DayHigh=iHigh(NULL,PERIOD_D1,Highest(NULL,PERIOD_D1,MODE_HIGH,PeriodDoubleTops,0)); // past PeriodDoubleTops days' high
    DayLow=iLow(NULL,PERIOD_D1,Lowest(NULL,PERIOD_D1,MODE_LOW,PeriodDoubleTops,0)); // past PeriodDoubleTops days' high
    // Check to see if the order has been adjusted
    if(OrderLots()==LotsDoubleTops)
    {
     flag_dump8a=true;
     flag_dump8b=false;
     flag_DoubleTopsAdjust=false;
    }
    else if(OrderLots()==LotsDoubleTops1Unload+LotsDoubleTops2Unload)
    {
     flag_dump8a=false;
     flag_dump8b=true;
     flag_DoubleTopsAdjust=true;
    }
    else
    {
     flag_dump8a=false;
     flag_dump8b=false;
     flag_DoubleTopsAdjust=false;
    }    
    continue;
  }
 } 
 DisplayStatusInit();
 return(0); 
}

//===========================================================================================
//===========================================================================================

int deinit()
{
// goodbye world
 ObjectDelete( "SecretMA" );
 ObjectDelete( "MACD" );
 ObjectDelete( "10hrX" );
 ObjectDelete( "10dayX" );
 ObjectDelete( "Stoch" );
 ObjectDelete( "Safety" );
 ObjectDelete( "Reversal" );
 ObjectDelete( "DoubleTops" ); 
 
 ObjectDelete( "SecretMAv" );
 ObjectDelete( "MACDv" );
 ObjectDelete( "10hrXv" );
 ObjectDelete( "10dayXv" );
 ObjectDelete( "Stochv" );
 ObjectDelete( "Safetyv" );
 ObjectDelete( "Reversalv" );
 ObjectDelete( "DoubleTopsv" );  
 return(0);
}

//===========================================================================================
//===========================================================================================

int SendOrderLong(string sym, double vol, int slip, double sl, double tp, string comment="", int magic=0, datetime exp=0, color cl=CLR_NONE)
{  
 int err;
 GetSemaphore();
 for(int z=0;z<5;z++)
 {  
  if(OrderSend(sym,OP_BUY,vol,Ask,slip,sl,tp,comment,magic,exp,cl)<0)
  {  
   err = GetLastError();
   Print("OrderClose long failed, Error: ", err, " Magic Number: ", magic);
   if(err>4000) break;
   RefreshRates();
  }
  else
   break;
 }
 ReleaseSemaphore();
}

//===========================================================================================
//===========================================================================================

int SendOrderShort(string sym, double vol, int slip, double sl, double tp, string comment="", int magic=0, datetime exp=0, color cl=CLR_NONE)
{  
 int err;
 GetSemaphore();
 for(int z=0;z<5;z++)
 {  
  if(OrderSend(sym,OP_SELL,vol,Bid,slip,sl,tp,comment,magic,exp,cl)<0)
  {  
   err = GetLastError();
   Print("OrderClose short failed, Error: ", err, " Magic Number: ", magic);
   if(err>4000) break;
   RefreshRates();
  }
  else
   break;
 }
 ReleaseSemaphore();
}

//===========================================================================================
//===========================================================================================

bool CloseOrderLong(int ticket, double lots, int slip, color cl=CLR_NONE)
{
 int err;

 GetSemaphore();
 for(int z=0;z<10;z++)
 {
  if(!OrderClose(ticket,lots,Bid,slip,cl))
  {  
   err = GetLastError();
   Print("OrderClose long failed, Error: ", err, " Ticket #: ", ticket);
   if(err>4000) 
    break;
   RefreshRates();
  }
  else
  break;
 }
 ReleaseSemaphore();
} 

//===========================================================================================
//===========================================================================================

bool CloseOrderShort(int ticket, double lots, int slip, color cl=CLR_NONE)
{
 int err;

 GetSemaphore();
 for(int z=0;z<10;z++)
 {
  if(!OrderClose(ticket,lots,Ask,slip,cl))
  {  
   err = GetLastError();
   Print("OrderClose short failed, Error: ", err, " Ticket #: ", ticket);
   if(err>4000) 
    break;
   RefreshRates();
  }
  else
  break;
 }
 ReleaseSemaphore();
} 

//===========================================================================================
//===========================================================================================

bool ModifyOrder(int ticket, double price, double sl, double tp, datetime exp, color cl=CLR_NONE) // by Mike
{
 GetSemaphore();
 OrderModify(ticket,price,sl,tp,exp,cl);
 ReleaseSemaphore();
}

//===========================================================================================
//===========================================================================================

bool GetSemaphore()  // by Mike
{  
 while(!IsStopped())
 {  
  if(GlobalVariableSetOnCondition("SEMAPHORE",1,0)==true)  
   break;
  Sleep(500);
 }
 return(true);
}

//===========================================================================================
//===========================================================================================

bool ReleaseSemaphore()  // by Mike
{  GlobalVariableSet("SEMAPHORE",0);
   return(true);
}

//===========================================================================================
//===========================================================================================

int ObjectMakeLabel( string n, int xoff, int yoff ) 
{
 ObjectCreate( n, OBJ_LABEL, 0, 0, 0 );
 ObjectSet( n, OBJPROP_CORNER, Display_Corner );
 ObjectSet( n, OBJPROP_XDISTANCE, xoff );
 ObjectSet( n, OBJPROP_YDISTANCE, yoff );
 ObjectSet( n, OBJPROP_BACK, true );
}

//===========================================================================================
//===========================================================================================

void DisplayStatus()
{
 int timecheck;
 string statusSecretMA;
 string statusMACD;
 string status10hrX;
 string status10dayX;
 string statusStoch;
 string statusSafety;
 string statusReversal;
 string statusDoubleTops;       

 if(flag_SecretMA)
 {
  statusSecretMA="Active";
  if(flag_orderSecretMA)
   ColorSecretMA=ColorNoOrder;
  else 
  {
   ColorSecretMA=ColorOrder;
   if(checktimeSecretMA>0)
   {
    timecheck=checktimeSecretMA/60;
    statusSecretMA=StringConcatenate("Black-out period = ",timecheck," minutes remaining.");
   }
   else
    statusSecretMA=("Open SecretMA order");
  }  
 } 
 else
  statusSecretMA="Inactive";

 if(flag_MACD)
 {
  statusMACD="Active";
  if(flag_orderMACD)
   ColorMACD=ColorNoOrder;
  else 
  {
   ColorMACD=ColorOrder;
   if(checktimeMACD>0)
   {
    timecheck=checktimeMACD/60;
    statusMACD=StringConcatenate("Black-out period = ",timecheck," minutes remaining.");
   }
   else
    statusMACD=("Open MACD order");
  }  
 } 
 else
  statusMACD="Inactive";
  
 if(flag_10hrX)
 {
  status10hrX="Active";
  if(flag_order10hrX)
  {
   Color10hrX=ColorNoOrder;
   if(windowtime10hrX>0)
   {
    timecheck=windowtime10hrX/60;   
    status10hrX=StringConcatenate("Crossed!! Opp. Window = ",timecheck," minutes remaining."); 
   }
  }
  else 
  {
   Color10hrX=ColorOrder;
   if(checktime10hrX>0)
   {
    timecheck=checktime10hrX/60;
    status10hrX=StringConcatenate("Black-out period = ",timecheck," minutes remaining.");
   }
   else
    status10hrX=("Open 10hrX order");
  }  
 } 
 else
  status10hrX="Inactive";

 if(flag_10dayX)
 {
  status10dayX="Active";
  if(flag_order10dayX)
   Color10dayX=ColorNoOrder;
  else 
  {
   Color10dayX=ColorOrder;
   if(crossup)
   {
    if(checktime10dayXLong>0)
    {
     timecheck=checktime10dayXLong/60;
     status10dayX=StringConcatenate("Black-out period = ",timecheck," minutes remaining.");
    }
    else
     status10dayX=("Open 10dayX long order");
   } 
   else
   {
    if(checktime10dayXShort>0)
    {
     timecheck=checktime10dayXShort/60;
     status10dayX=StringConcatenate("Black-out period = ",timecheck," minutes remaining.");
    }
    else
     status10dayX=("Open 10dayX short order");  
   }
  }  
 } 
 else
  status10dayX="Inactive";          
          
 if(flag_Stoch)
 {
  statusStoch="Active";
  if(flag_orderStoch)
   ColorStoch=ColorNoOrder;
  else 
  {
   ColorStoch=ColorOrder;
   if(checktimeStoch>0)
   {
    timecheck=checktimeStoch/60;
    statusStoch=StringConcatenate("Black-out period = ",timecheck," minutes remaining.");
   }
   else
    statusStoch=("Open Stoch order");
  }  
 } 
 else
  statusStoch="Inactive";

 if(flag_Safety)
 {
  statusSafety="Active";
  if(flag_orderSafety)
   ColorSafety=ColorNoOrder;
  else 
  {
   ColorSafety=ColorOrder;
   if(checktimeSafety>0)
   {
    timecheck=checktimeSafety/60;   
    statusSafety=StringConcatenate("Black-out period = ",timecheck," minutes remaining.");
   }
   else
    statusSafety=("Open Safety order");
  }  
 } 
 else
  statusSafety="Inactive";  
  
 if(flag_Reversal)
 {
  statusReversal="Active";
  if(flag_orderReversal)
   ColorReversal=ColorNoOrder;
  else 
  {
   ColorReversal=ColorOrder;
   if(checktimeReversal>0)
   {
    timecheck=checktimeReversal/60;
    statusReversal=StringConcatenate("Black-out period = ",timecheck," minutes remaining.");
   }
   else
    statusReversal=("Open Reversal order");
  }  
 } 
 else
  statusReversal="Inactive"; 

 if(flag_DoubleTops)
 {
  statusDoubleTops="Active";
  if(flag_orderDoubleTops)
   ColorDoubleTops=ColorNoOrder;
  else 
  {
   ColorDoubleTops=ColorOrder;
   if(checktimeDoubleTops>0)
   {
    timecheck=checktimeDoubleTops/60;
    statusDoubleTops=StringConcatenate("Black-out period = ",timecheck," minutes remaining.");
   }
   else
    statusDoubleTops=("Open DoubleTops order");
  }  
 } 
 else
  statusDoubleTops="Inactive";    

 ObjectSetText( "SecretMA", "SecretMA", 9, "Arial", ColorSecretMA );
 ObjectSetText( "MACD", "MACD", 9, "Arial", ColorMACD );
 ObjectSetText( "10hrX", "10hrX", 9, "Arial", Color10hrX );
 ObjectSetText( "10dayX", "10dayX", 9, "Arial", Color10dayX );
 ObjectSetText( "Stoch", "Stoch", 9, "Arial", ColorStoch );
 ObjectSetText( "Safety", "Safety", 9, "Arial", ColorSafety ); 
 ObjectSetText( "Reversal", "Reversal", 9, "Arial", ColorReversal );
 ObjectSetText( "DoubleTops", "DoubleTops", 9, "Arial", ColorDoubleTops );

          
 ObjectSetText( "SecretMAv", statusSecretMA, 9, "Times", Display_Color );
 ObjectSetText( "MACDv", statusMACD, 9, "Times", Display_Color );
 ObjectSetText( "10hrXv", status10hrX, 9, "Times", Display_Color);
 ObjectSetText( "10dayXv", status10dayX, 9, "Times", Display_Color );
 ObjectSetText( "Stochv", statusStoch, 9, "Times", Display_Color );
 ObjectSetText( "Safetyv", statusSafety, 9, "Times", Display_Color); 
 ObjectSetText( "Reversalv", statusReversal, 9, "Times", Display_Color);
 ObjectSetText( "DoubleTopsv", statusDoubleTops, 9, "Times", Display_Color ); 
     
// ObjectsRedraw();
 return(0);
}

//===========================================================================================
//===========================================================================================

void DisplayStatusInit()
{
 int xoffset=75; // pixel offset between labels and values
// Status Display
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,ExtMapBuffer1);
   
 ObjectMakeLabel( "SecretMA", xpos, ypos );
 ObjectMakeLabel( "MACD", xpos, ypos+12 );
 ObjectMakeLabel( "10hrX", xpos, ypos+24 );
 ObjectMakeLabel( "10dayX", xpos, ypos+36 );
 ObjectMakeLabel( "Stoch", xpos, ypos+48 );
 ObjectMakeLabel( "Safety", xpos, ypos+60 );
 ObjectMakeLabel( "Reversal", xpos, ypos+72 );
 ObjectMakeLabel( "DoubleTops", xpos, ypos+84 );

 ObjectMakeLabel( "SecretMAv", xpos+xoffset, ypos );
 ObjectMakeLabel( "MACDv", xpos+xoffset, ypos+12 );
 ObjectMakeLabel( "10hrXv", xpos+xoffset, ypos+24 );
 ObjectMakeLabel( "10dayXv", xpos+xoffset, ypos+36 );
 ObjectMakeLabel( "Stochv", xpos+xoffset, ypos+48 );
 ObjectMakeLabel( "Safetyv", xpos+xoffset, ypos+60 );
 ObjectMakeLabel( "Reversalv", xpos+xoffset, ypos+72 );
 ObjectMakeLabel( "DoubleTopsv", xpos+xoffset, ypos+84 ); 

 ObjectSetText( "SecretMA", "SecretMA", 9, "Arial", Blue );
 ObjectSetText( "MACD", "MACD", 9, "Arial", Blue );
 ObjectSetText( "10hrX", "10hrX", 9, "Arial", Blue );
 ObjectSetText( "10dayX", "10dayX", 9, "Arial", Blue );
 ObjectSetText( "Stoch", "Stoch", 9, "Arial", Blue );
 ObjectSetText( "Safety", "Safety", 9, "Arial", Blue ); 
 ObjectSetText( "Reversal", "Reversal", 9, "Arial", Blue );
 ObjectSetText( "DoubleTops", "DoubleTops", 9, "Arial", Blue ); 

 ObjectSetText( "SecretMAv", "Initializing", 9, "Times", Display_Color );
 ObjectSetText( "MACDv", "Initializing", 9, "Times", Display_Color );
 ObjectSetText( "10hrXv", "Initializing", 9, "Times", Display_Color);
 ObjectSetText( "10dayXv", "Initializing", 9, "Times", Display_Color );
 ObjectSetText( "Stochv", "Initializing", 9, "Times", Display_Color );
 ObjectSetText( "Safetyv", "Initializing", 9, "Times", Display_Color); 
 ObjectSetText( "Reversalv", "Initializing", 9, "Times", Display_Color);
 ObjectSetText( "DoubleTopsv", "Initializing", 9, "Times", Display_Color );  
 
}
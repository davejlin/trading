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

extern bool flag_SecretMA=true;            // toggle for Secret MA trades
extern bool flag_MACD=true;          // toggle for MACD trades
extern bool flag_10hrX=true;         // toggle for 10hrX trades
extern bool flag_10dayX=true;        // toggle for 10dayX trades
extern bool flag_Stoch=true;         // toggle for Stochastics trades
extern bool flag_Safety=true;        // toggle for Safety trades

extern bool dynamic_lots=true;       // toggle to use dynamic lot calculation

//Fixed Lots List:
  
double LotsMA=20.0;                  // lots to trade Secret MA (fractional values ok)
double LotsMAUnload=10.0;            // lots to unload at TakeProfit_MAUnload (fractional values ok)
double LotsMACD=20.0;                // lots to trade MACD (fractional values ok)
double LotsMACDUnload=10.0;          // lots to unload MACD at TakeProfit_MACDUnload (fractional values ok)
double Lots10hrX=20.0;               // lots to trade 10hrX (fractional values ok)
double Lots10hrXUnload=10.0;         // lots to unload 10hrX at TakeProfit_10hrXUnload (fractional values ok)
double Lots10dayX=20.0;              // lots to trade 10dayX (fractional values ok)
double Lots10dayXUnload=10.0;        // lots to unload 10dayX at TakeProfit_10dayXUnload (fractional values ok)
double LotsStoch=20.0;               // lots to trade Stochastics (fractional values ok)
double LotsStochUnload=10.0;         // lots to unload Stochastics TakeProfit_10dayXUnload (fractional values ok)
double LotsSafety=30.0;              // lots to trade Safety (fractional values ok)
double LotsSafety1Unload=10.0;       // lots to unload Safety TakeProfit_SafetyUnload1 (fractional values ok)
double LotsSafety2Unload=10.0;       // lots to unload Safety TakeProfit_SafetyUnload2 (fractional values ok)

// Take Profit List:

int TakeProfit_MAMain=0;             // pips take profit Secret MA main order
int TakeProfit_MAUnload=30;          // pips take profit Secret MA unload
int TakeProfit_MACDMain=120;         // pips take profit MACD main order
int TakeProfit_MACDUnload=60;        // pips take profit MACD unload
int TakeProfit_10hrXMain=0;          // pips take profit 10hrX main order
int TakeProfit_10hrXUnload=30;       // pips take profit 10hrX unload
int TakeProfit_10dayXMain=0;         // pips take profit 10dayX main order
int TakeProfit_10dayXUnload=50;      // pips take profit 10dayX unload
int TakeProfit_Stoch=0;              // pips take profit Stochastics main order
int TakeProfit_StochUnload=50;       // pips take profit Stochastics unload
int TakeProfit_Safety=120;           // pips take profit Stochastics main order
int TakeProfit_Safety1Unload=20;     // pips take profit Safety 1 unload
int TakeProfit_Safety2Unload=50;     // pips take profit Safety 2 unload

// Stop Loss List:

int StopLoss_MA=0;                   // pips stop loss for Secret MA main order
int StopLoss_MACD=70;                // pips stop loss for MACD main order
int StopLoss_10hrX=0;                // pips stop loss for 10hrX main order
int StopLoss_10dayX=0;               // pips stop loss for 10dayX main order
int StopLoss_Stoch=0;                // pips stop loss for Stochastics main order
int StopLoss_Safety=0;               // pips stop loss for Stochastics main order

// Trailing Stop List:

int TrailingStop_MA=45;              // pips stop loss for Secret MA main order
int TrailingStop_MACD=0;             // pips stop loss for MACD main order
int TrailingStop_10hrX=0;            // pips stop loss for 10hrX main order
int TrailingStop_10dayX=45;          // pips stop loss for 10dayX main order
int TrailingStop_Stoch=45;           // pips stop loss for Stochastics main order
int TrailingStop_Safety=45;           // pips stop loss for Stochastics main order

// Secret MA Variables:

int MA1Period=1;                     // EMA(1) acts as trigger line to gauge immediate price action 
int MA1Timeframe=PERIOD_H1;          // Timeframe
int MA1Shift=0;                      // Shift
int MA1Method=MODE_EMA;              // Mode
int MA1Price=PRICE_CLOSE;            // Method

int MA2Period=10;                    // SMA(10) acts as base line
int MA2Shift=20;                     // Shift ... *** Secret *** ... Shhh ...
int MA2Timeframe=PERIOD_H1;          // Timeframe
int MA2Method=MODE_SMA;              // Mode
int MA2Price=PRICE_CLOSE;            // Method

// MACD Variables:

int MACDfast=12;                     // MACD ema fast period
int MACDslow=26;                     // MACD ema slow period
int MACDsignal=9;                    // MACD sma signal period
int MACDTimeframe=PERIOD_H1;         // Timeframe

int BlackOutPeriodMACD=5;            // number of periods after MACD trigger to ignore additional signals

datetime MACDtime=0;                 // stores time of most recent MACD order
int timeleftMACD=0;                  // stores time remaining in MACD blackout

// 10hrX Variables:

int MA10hrXTimeframe=PERIOD_H1;      // Timeframe
int MA10hrXfastPeriod=1;             // EMA(1) acts as trigger line for 10hrX
int MA10hrXfastShift=0;              // Shift
int MA10hrXfastMethod=MODE_EMA;      // Mode
int MA10hrXfastPrice=PRICE_CLOSE;    // Method

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
bool flag_order10hrX=true;           // true if NO 10hrX order is open
bool flag_10hrXLong=true;            // true if 10hrX up, therefore go long
bool flag_close10hrXLong=false;      // true if exit signal is triggered for long 
bool flag_close10hrXShort=false;     // true if exit signal is triggered for short 

int WindowPeriod10hrX=2;             // number of periods after 10hrX trigger for window of opportunity

// 10 day X Variables:

int MA10dayXPeriod=10;               // SMA(10) acts as base line for 10dayX
int MA10dayXTimeframe=PERIOD_D1;     // Timeframe Period = D1
int MA10dayXShift=0;                 // Shift
int MA10dayXMethod=MODE_SMA;         // Mode
int MA10dayXPrice=PRICE_CLOSE;       // Method

int MA10dayXMonitorTimeframe=PERIOD_H1; // Timeframe for monitoring of previous hourly close

int TriggerPips10dayX=130;           // pips above 10daySMA to execute 10 day cross method
bool flag_order10dayX=true;          // true if NO 10dayX order is open

// Stochastics Variables:

double StochTriggerHigh=78.0;        // Upper Stochastic trigger level
double StochTriggerLow=22.0;         // Lower Stochastic trigger level
int StochTimeframe=PERIOD_H4;        // Stochastic timeframe 
int StochK=5;                        // Stochastic %K period
int StochD=5;                        // Stochastic %D Period
int StochSlow=5;                     // Stochastic slowing
int StochMethod=MODE_SMA;            // Stochastic method
int StochPrice=1;                    // Stochastic price field, 0=Low/High, 1=Close/Close
bool flag_orderStoch=true;           // true if NO Stochastic order is open

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

// Misc Variables

int Slippage=3;                      // pips slippage allowed

datetime lasthour=0;                 // current bar's time to trigger MA calculations
int fourthhour=0;                    // track 4 hour intervals

// Flags which indicate partial takeprofit unloading

bool flag_dump1=false;               // true if TakeProfit_MAUnload-ed
bool flag_dump2=false;               // true if TakeProfit_MACDUnload-ed
bool flag_dump3=false;               // true if TakeProfit_10hrXUnload-ed
bool flag_dump4=false;               // true if TakeProfit_10dayXUnload-ed
bool flag_dump5=false;               // true if TakeProfit_StochUnload-ed
bool flag_dump6a=false;              // true if TakeProfit_Safety1Unload-ed
bool flag_dump6b=false;              // true if TakeProfit_Safety2Unload-ed

// Magic numbers (to identify which orders belong to which models)

int magic1=2345;                     // Secret MA order's magic number base
int magic2=3456;                     // MACD order's magic number base
int magic3=4567;                     // 10hrX order's magic number base
int magic4=5678;                     // 10dayX order's magic number base
int magic5=6789;                     // Stochastics order's magic number base
int magic6=7890;                     // Safety order's magic number base

int init()
{
// hello world

 int adjustment=60;
 magic1=magic1+adjustment;           // adjust magic number (optional)
 magic2=magic2+adjustment;             
 magic3=magic3+adjustment;
 magic4=magic4+adjustment;
 magic5=magic5+adjustment;

// In case EA becomes disabled/re-activated during trading,
// we re-determine most recent MACD order open time to re-establish proper blackout window

 int trade;                           
 int trades=OrdersTotal();           
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()!=Symbol())
   continue;

  if(OrderMagicNumber()==magic2)     
   MACDtime=OrderOpenTime();
  else
   MACDtime=0; 

 }
 return(0); 
}

int deinit()
{
// goodbye world
 return(0);
}

//===========================================================================================
//===========================================================================================

int start()                          // main cycle
{
 OrderStatus();                      // check order status to establish open orders and time
 Main();                             // order execution and maintenance
}

//===========================================================================================
//===========================================================================================

void OrderStatus()                   // Check order status
{
 int trade;                          // dummy variable to cycle through trades
 int trades=OrdersTotal();           // total number of open orders
 
 flag_order10hrX=true;               // first assume we have no open 10hrX orders
 flag_order10dayX=true;              // first assume we have no open 10dayX orders
 flag_orderStoch=true;               // first assume we have no open Stoch orders 
 flag_orderSafety=true;              // first assume we have no open Safety orders
 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
   
  if(OrderSymbol()!=Symbol())
   continue;
   
  if(OrderMagicNumber()==magic3)
   flag_order10hrX=false;            // false if there are open 10hrX orders

  if(OrderMagicNumber()==magic4)
   flag_order10dayX=false;           // false if there are open 10dayX orders

  if(OrderMagicNumber()==magic5)
   flag_orderStoch=false;            // false if there are open Stoch orders

  if(OrderMagicNumber()==magic6)
  { 
   flag_orderSafety=false;           // false if there are open Safety orders
   if(OrderType()==OP_BUY)
    flag_SafetyLong=true;
   else
    flag_SafetyLong=false; 
  }
 }
return(0);
}

//===========================================================================================
//===========================================================================================

void Main()                          // Main Cycle
{
 if(dynamic_lots)                    // Calculate dynamic number of lots
  DynamicLots();

 if(flag_10hrX)
 {
  if(flag_order10hrX)                // Trigger/Monitor 10hrX orders
   Order10hrX();
  else
   Monitor10hrX();
 } 
       
 TakeProfitUnload();                 // Unload for partial profits
 TrailStop();                        // Trailing Stop

 if(lasthour==Hour())                // Only need to trigger MA and MACD orders at the start of each bar
  return(0);                         // Only need to calculate MA information at the start of each bar
 lasthour=Hour();
 fourthhour++;

 if(flag_SecretMA)
  MainSecretMA();

 if(flag_MACD)
  MainMACD();
  
 if(flag_10hrX)
  Main10hrX();
  
 if(flag_10dayX)
  Main10dayX();

 if(flag_Safety)
  MainSafety();

 if(fourthhour==4)  
 {
  if(flag_Stoch)                      // Trigger/Monitor Stochastic orders
   MainStoch();
   fourthhour=0;  
 }
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
  
//
//Secret MA Enter Long, Exit Short 
//      
 if(fast1>slow1 && fast2<slow2)
 {
  CloseShorts(magic1);
  OrderSend(Symbol(),OP_BUY,LotsMA,Ask,Slippage,StopLong(Ask,StopLoss_MA),TakeLong(Ask,TakeProfit_MAMain),NULL,magic1,0,Blue);
  flag_dump1=true;
 }//Long
  
//
//Secret MA Enter Short, Exit Long 
//
 if(fast1<slow1 && fast2>slow2)
 {
  CloseLongs(magic1); 
  OrderSend(Symbol(),OP_SELL,LotsMA,Bid,Slippage,StopShort(Bid,StopLoss_MA),TakeShort(Bid,TakeProfit_MAMain),NULL,magic1,0,Red);
  flag_dump1=true;
 }//Shrt
 
 return(0);
}

//===========================================================================================
//===========================================================================================

void MainMACD()
{
 int ticketNumber;

//Calculate MACD Indicators
 double base1=iMACD(NULL,MACDTimeframe,MACDfast,MACDslow,MACDsignal,PRICE_CLOSE,MODE_BASE,1);
 double base2=iMACD(NULL,MACDTimeframe,MACDfast,MACDslow,MACDsignal,PRICE_CLOSE,MODE_BASE,2);
 double signal1=iMACD(NULL,MACDTimeframe,MACDfast,MACDslow,MACDsignal,PRICE_CLOSE,MODE_SIGNAL,1);
 double signal2=iMACD(NULL,MACDTimeframe,MACDfast,MACDslow,MACDsignal,PRICE_CLOSE,MODE_SIGNAL,2);  

 double crosspoint=(base1+base2+signal1+signal2)/4.0; // 4 point average for price at crossover

// Determine number of seconds from most recent MACD trigger
 timeleftMACD=(BlackOutPeriodMACD*60*60)-(CurTime()-MACDtime);
  
//
//Enter MACD Long, Exit Short/Long 
//    
 if(base1>signal1 && base2<signal2 && crosspoint<-0.0010 && timeleftMACD<=0)
 {
  CloseShorts(magic2);

  ticketNumber = GetLong(magic2); // check whether to modify existing longs
  if(ticketNumber >=0)
   ModifyMACDLongs(ticketNumber);
  else
  {  
   OrderSend(Symbol(),OP_BUY,LotsMACD,Ask,Slippage,StopLong(Ask,StopLoss_MACD),TakeLong(Ask,TakeProfit_MACDMain),NULL,magic2,0,Blue);
   flag_dump2=true;
  }   
  MACDtime=CurTime();
 }//Long 
 
//
//Enter MACD Short, Exit Long/Short
//
 if(base1<signal1 && base2>signal2 && crosspoint>0.0010 && timeleftMACD<=0)
 {
  CloseLongs(magic2);
   
  ticketNumber = GetShort(magic2); // check whether to modify existing short
  if(ticketNumber >=0)
   ModifyMACDShorts(ticketNumber);
  else
  {
   OrderSend(Symbol(),OP_SELL,LotsMACD,Bid,Slippage,StopShort(Bid,StopLoss_MACD),TakeShort(Bid,TakeProfit_MACDMain),NULL,magic2,0,Red);
   flag_dump2=true;
  }
  MACDtime=CurTime();
 }//Short 
 
 return(0);
}

//===========================================================================================
//===========================================================================================

void Main10hrX()
{
 
//Calculate Indicators
// up to 3 completed bars ago:
 double fast1=iMA(NULL,MA10hrXTimeframe,MA10hrXfastPeriod,MA10hrXfastShift,MA10hrXfastMethod,MA10hrXfastPrice,1); 
 double fast2=iMA(NULL,MA10hrXTimeframe,MA10hrXfastPeriod,MA10hrXfastShift,MA10hrXfastMethod,MA10hrXfastPrice,2);
 double fast3=iMA(NULL,MA10hrXTimeframe,MA10hrXfastPeriod,MA10hrXfastShift,MA10hrXfastMethod,MA10hrXfastPrice,3);  
 double slow1=iMA(NULL,MA10hrXTimeframe,MA10hrXslowPeriod,MA10hrXslowShift,MA10hrXslowMethod,MA10hrXslowPrice,1); 
 double slow2=iMA(NULL,MA10hrXTimeframe,MA10hrXslowPeriod,MA10hrXslowShift,MA10hrXslowMethod,MA10hrXslowPrice,2);
 double slow3=iMA(NULL,MA10hrXTimeframe,MA10hrXslowPeriod,MA10hrXslowShift,MA10hrXslowMethod,MA10hrXslowPrice,3);
 double veryslow=iMA(NULL,MA10hrXTimeframe,MA10hrXveryslowPeriod,MA10hrXveryslowShift,MA10hrXveryslowMethod,MA10hrXveryslowPrice,1);

//Check for MA cross
 if(fast1>slow1 && fast2<slow2) // cross UP 1 hour ago
 {
  flag_10hrXLong=true;
  flag_close10hrXLong=false;
//  Price10hrX=(fast1+fast2+slow1+slow2)/4.0;
  Price10hrX=(slow1+slow2)/2.0;
  Time10hrX=CurTime()-3600.; 
  TriggerPrice10hrX=Price10hrX+(TriggerPips10hrX*Point);
 }
 else if(fast2>slow2 && fast3<slow3) // cross UP 2 hours ago
 {
  flag_10hrXLong=true;
  flag_close10hrXLong=false;
//  Price10hrX=(fast2+fast3+slow2+slow3)/4.0;
  Price10hrX=(slow2+slow3)/2.0; 
  Time10hrX=CurTime()-7200.;
  TriggerPrice10hrX=Price10hrX+(TriggerPips10hrX*Point);
 }
   
 if(fast1<slow1 && fast2>slow2) // cross DOWN 1 bar ago
 {
  flag_10hrXLong=false;
  flag_close10hrXShort=false;
//  Price10hrX=(fast1+fast2+slow1+slow2)/4.0;
  Price10hrX=(slow1+slow2)/2.0;
  Time10hrX=CurTime()-3600.;
  TriggerPrice10hrX=Price10hrX-(TriggerPips10hrX*Point);
 }
 else if(fast2<slow2 && fast3>slow3) // cross DOWN 2 bars ago
 {
  flag_10hrXLong=false;
  flag_close10hrXShort=false;
//  Price10hrX=(fast2+fast3+slow2+slow3)/4.0;
  Price10hrX=(slow2+slow3)/2.0;  
  Time10hrX=CurTime()-7200.;
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

void Order10hrX()
{
 double SL=0.0;
// Add 1 to WindowPeriod10hrX because crossover determination is delayed 1 full period
// The following gives a 2 hour window:
 int Window10hrX = ((WindowPeriod10hrX+1)*60*60)-(CurTime()-Time10hrX);

//Enter Long 
//      
 if(Ask>=TriggerPrice10hrX&&flag_10hrXLong==true&&Window10hrX>=0)
 {
  if(StopLoss_10hrX==0)
//   SL=iLow(NULL,Timeframe10HrXMonitor,1);
   SL=Price10hrX;
  else
   SL=StopLong(Ask,StopLoss_10hrX);
   
  OrderSend(Symbol(),OP_BUY,Lots10hrX,Ask,Slippage,SL,TakeLong(Ask,TakeProfit_10hrXMain),NULL,magic3,0,Blue);
  flag_dump3=true;
 }//Long 
//
//Enter Short 
//
 if(Bid<=TriggerPrice10hrX&&flag_10hrXLong==false&&Window10hrX>=0)
 {
  if(StopLoss_10hrX==0)
//   SL=iHigh(NULL,Timeframe10HrXMonitor,1);
   SL=Price10hrX;
  else
   SL=StopShort(Bid,StopLoss_10hrX);  
   
  OrderSend(Symbol(),OP_SELL,Lots10hrX,Bid,Slippage,SL,TakeShort(Bid,TakeProfit_10hrXMain),NULL,magic3,0,Red);
  flag_dump3=true;
 }//Shrt

 return(0);
}

//===========================================================================================
//===========================================================================================

void Monitor10hrX()
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
 
 return(0);
}

//===========================================================================================
//===========================================================================================

void Main10dayX()
{
 double SL=0.0;
//Calculate 10 Day Cross Indicators
 double closeHour=iClose(NULL,MA10dayXMonitorTimeframe,1); 
 double signal=iMA(NULL,MA10dayXTimeframe,MA10dayXPeriod,MA10dayXShift,MA10dayXMethod,MA10dayXPrice,1); 
  
//
//10 Day Cross Enter Long
//      
 if(closeHour>signal+(TriggerPips10dayX*Point)&&flag_order10dayX==true)
 {
  if(StopLoss_10dayX==0)
   SL=iLow(NULL,PERIOD_D1,1);
  else
   SL=StopLong(Ask,StopLoss_10dayX);
   
  OrderSend(Symbol(),OP_BUY,Lots10dayX,Ask,Slippage,SL,TakeLong(Ask,TakeProfit_10dayXMain),NULL,magic4,0,Blue);
  flag_dump4=true;
 }//Long
  
//
//10 Day Cross Enter Short
//
 if(closeHour<signal-(TriggerPips10dayX*Point)&&flag_order10dayX==true)
 {
  if(StopLoss_10dayX==0)
   SL=iHigh(NULL,PERIOD_D1,1);
  else
   SL=StopLong(Bid,StopLoss_10dayX); 
 
  OrderSend(Symbol(),OP_SELL,Lots10dayX,Bid,Slippage,SL,TakeShort(Bid,TakeProfit_10dayXMain),NULL,magic4,0,Red);
  flag_dump4=true;
 }//Shrt
 
//
//10 Day Cross Exit Long 
// 
 if(closeHour<signal&&flag_order10dayX==false)
  CloseLongs(magic4);
  
//
//10 Day Cross Exit Short 
// 
 if(closeHour>signal&&flag_order10dayX==false)
  CloseShorts(magic4);  
 
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

 double crosspoint=(signal1+signal2)/2.0; // 2 point average of slower signal for price at crossover

// cross up, go Long
 if(base1>signal1&&base2<signal2&&crosspoint<=StochTriggerLow)
 {
  CloseShorts(magic5);
  OrderSend(Symbol(),OP_BUY,LotsStoch,Ask,Slippage,StopLong(Ask,StopLoss_Stoch),TakeLong(Ask,TakeProfit_Stoch),NULL,magic5,0,Blue); 
  flag_dump5=true;
 }

// cross down, go Short
 if(base1<signal1&&base2>signal2&&crosspoint>=StochTriggerHigh)  
 {
  CloseLongs(magic5);
  OrderSend(Symbol(),OP_SELL,LotsStoch,Bid,Slippage,StopShort(Bid,StopLoss_Stoch),TakeShort(Bid,TakeProfit_Stoch),NULL,magic5,0,Red); 
  flag_dump5=true;
 }

 return(0);
}

//===========================================================================================
//===========================================================================================

void MainSafety()
{
 double crossprice;
 double triggerprice;

 double fast1=iMA(NULL,MASafetyfastTimeframe,MASafetyfastPeriod,MASafetyfastShift,MASafetyfastMethod,MASafetyfastPrice,1);
 double fast2=iMA(NULL,MASafetyfastTimeframe,MASafetyfastPeriod,MASafetyfastShift,MASafetyfastMethod,MASafetyfastPrice,2);
 double slow1=iMA(NULL,MASafetyslowTimeframe,MASafetyslowPeriod,MASafetyslowShift,MASafetyslowMethod,MASafetyslowPrice,1);
 double slow2=iMA(NULL,MASafetyslowTimeframe,MASafetyslowPeriod,MASafetyslowShift,MASafetyslowMethod,MASafetyslowPrice,2);
  
 if(flag_orderSafety==true)
 {
  if(fast1>slow1&&fast2<slow2)  // Cross UP Long trigger 
  {
   OrderSend(Symbol(),OP_BUY,LotsSafety,Ask,Slippage,StopLong(Ask,StopLoss_Safety),TakeLong(Ask,TakeProfit_Safety),NULL,magic6,0,Blue);
   flag_dump6a=true;
   flag_dump6b=true;
  }
  if(fast1<slow1&&fast2>slow2)  // Short trigger
  {
   OrderSend(Symbol(),OP_SELL,LotsSafety,Bid,Slippage,StopShort(Bid,StopLoss_Safety),TakeShort(Bid,TakeProfit_Safety),NULL,magic6,0,Red); 
   flag_dump6a=true;
   flag_dump6b=true;
  }      
 }
  
 if(flag_orderSafety==false)
 {
  crossprice=0.5*(slow1+slow2);
  triggerprice=crossprice-(TriggerSafety*Point);
  
  if(fast1<triggerprice&&flag_SafetyLong)  // Close Long trigger, Enter Short 
  {
   CloseLongs(magic6);
   OrderSend(Symbol(),OP_SELL,LotsSafety,Bid,Slippage,StopShort(Bid,StopLoss_Safety),TakeShort(Bid,TakeProfit_Safety),NULL,magic6,0,Red); 
   flag_dump6a=true;
   flag_dump6b=true;
  }
  
  triggerprice=crossprice+(TriggerSafety*Point);
  if(fast1>triggerprice&&!flag_SafetyLong)  // Close Short trigger, Enter Long
  {
   CloseShorts(magic6);
   OrderSend(Symbol(),OP_BUY,LotsSafety,Ask,Slippage,StopLong(Ask,StopLoss_Safety),TakeLong(Ask,TakeProfit_Safety),NULL,magic6,0,Blue); 
   flag_dump6a=true;
   flag_dump6b=true;
  }      
 }    
 return(0);
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
  OrderModify(ticketNumber,OrderOpenPrice(),StopLong(Ask,StopLoss_MACD),TakeLong(Ask,TakeProfit_MACDMain),0,Blue);
  flag_dump2=true;
 }
 else
 {  
  if(OrderLots() == LotsMACDUnload)
  {  
   OrderModify(ticketNumber,OrderOpenPrice(),StopLong(Ask,StopLoss_MACD),TakeLong(Ask,TakeProfit_MACDUnload),0,Blue);
   lotsToOrder = LotsMACD - LotsMACDUnload;
   profitTarget = TakeLong(Ask,TakeProfit_MACDMain);
  }
  else
  {  
   OrderModify(ticketNumber,OrderOpenPrice(),StopLong(Ask,StopLoss_MACD),TakeLong(Ask,TakeProfit_MACDMain),0,Blue);
   lotsToOrder = LotsMACDUnload;
   profitTarget = TakeLong(Ask,TakeProfit_MACDUnload);
  }
         
  ticketNumber2 = GetLong(magic2,ticketNumber); 
  if(ticketNumber2 >= 0)
   OrderModify(ticketNumber2,OrderOpenPrice(),StopLong(Ask,StopLoss_MACD),profitTarget,0,Blue);
  else
   OrderSend(Symbol(),OP_BUY,lotsToOrder,Ask,Slippage,StopLong(Ask,StopLoss_MACD),profitTarget,NULL,magic2,0,Blue);  
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
  OrderModify(ticketNumber,OrderOpenPrice(),StopShort(Bid,StopLoss_MACD),TakeShort(Bid,TakeProfit_MACDMain),0,Red);
  flag_dump2=true;
 }
 else
 {  
  if(OrderLots() == LotsMACDUnload)
  {  
   OrderModify(ticketNumber,OrderOpenPrice(),StopShort(Bid,StopLoss_MACD),TakeShort(Bid,TakeProfit_MACDUnload),0,Red);
   lotsToOrder = LotsMACD - LotsMACDUnload;
   profitTarget = TakeShort(Bid,TakeProfit_MACDMain);
  }
  else
  {  
   OrderModify(ticketNumber,OrderOpenPrice(),StopShort(Bid,StopLoss_MACD),TakeShort(Bid,TakeProfit_MACDMain),0,Red);
   lotsToOrder = LotsMACDUnload;
   profitTarget = TakeShort(Bid,TakeProfit_MACDUnload);
  }
         
 ticketNumber2 = GetShort(magic2,ticketNumber); 
 if(ticketNumber2 >= 0)
  OrderModify(ticketNumber2,OrderOpenPrice(),StopShort(Bid,StopLoss_MACD),profitTarget,0,Red);
 else
  OrderSend(Symbol(),OP_SELL,lotsToOrder,Bid,Slippage,StopShort(Bid,StopLoss_MACD),profitTarget,NULL,magic2,0,Red);  
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
   OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Blue); 
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
   OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Red); 
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
 
 return(0); 
}

//===========================================================================================
//===========================================================================================

bool TakeProfitCycle(bool flag, int lots, int magic, int takeprofit) // cycles through proper orders to take profit
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
    OrderClose(OrderTicket(),lots,Bid,Slippage,Blue);
    flag=false;
   }  
  }//Long 
  
//Short 
   if(OrderType()==OP_SELL&&OrderMagicNumber()==magic)
   {
    if(OrderOpenPrice()-Ask>=takeprofit*Point)
    {
     OrderClose(OrderTicket(),lots,Ask,Slippage,Red);
     flag=false; 
    } 
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
   TrailingAlls(TrailingStop_MA,magic1);
 }
 
 if(flag_MACD) 
 {
  if(TrailingStop_MACD!=0) 
   TrailingAlls(TrailingStop_MACD,magic2);
 }
 
  if(flag_10hrX) 
 {
  if(TrailingStop_10hrX!=0) 
   TrailingAlls(TrailingStop_10hrX,magic3);
 }
 
  if(flag_10dayX) 
 {
  if(TrailingStop_10dayX!=0) 
   TrailingAlls(TrailingStop_10dayX,magic4);
 } 
 
  if(flag_Stoch) 
 {
  if(TrailingStop_Stoch!=0) 
   TrailingAlls(TrailingStop_Stoch,magic5);
 } 

  if(flag_Safety) 
 {
  if(TrailingStop_Safety!=0) 
   TrailingAlls(TrailingStop_Safety,magic6);
 }

 return(0); 
}

//===========================================================================================
//===========================================================================================

void TrailingAlls(int trail, int magic)  // client-side trailing stop (by Patrick)
{
 if(trail==0)
  return;
  
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
   stopcrnt=OrderStopLoss();
   stopcal=Bid-(trail*Point); 
   if(stopcrnt==0)
    OrderModify(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Blue);
   else if(stopcal>stopcrnt)
    OrderModify(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Blue);
  }//Long 
  
//Short 
  if(OrderType()==OP_SELL && OrderMagicNumber()==magic)
  {
   stopcrnt=OrderStopLoss();
   stopcal=Ask+(trail*Point); 
   if(stopcrnt==0)
    OrderModify(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red);
   else if(stopcal<stopcrnt)
    OrderModify(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red);
  }//Short   
 } //for
 return(0);
}

//===========================================================================================
//===========================================================================================
// This routine dynamically allocates lottage per order so that 
// as the account balance increases, so does the lots per order.  
// Assuming consistent gains, this function results in 
// exponential growth, instead of linear growth.
// If there are losses, this function automatically downsizes 
// subsequent orders to help minimize drawdowns.
//
// Note: there is a 100 lot per order trading limit!

void DynamicLots()
{
 int divisor;
 int N=0;
 if(flag_SecretMA) N++;            // for Secret MA trades
 if(flag_MACD) N++;          // for MACD trades
 if(flag_10hrX) N++;         // for 10hrX trades
 if(flag_10dayX) N++;        // for 10dayX trades
 if(flag_Stoch) N++;         // for Stochastics trades
 if(flag_Safety) N++;        // for Safety trades

// determine divisor to make sure lottage begins at 10 (mini) for $10,000 balance
 if(N==1) divisor=1000;
 if(N==2) divisor=500;
 if(N==3) divisor=333;
 if(N==4) divisor=250;
 if(N==5) divisor=200;
 if(N==6) divisor=167;
 
 int lots=AccountBalance()/(N*divisor);
 
 if(lots>100) lots=100;
 
 int halflots=0.5*lots;
 int thirdlots=lots/3.0;
 
 LotsMA=lots;
 LotsMAUnload=halflots;
 LotsMACD=lots;
 LotsMACDUnload=halflots;
 Lots10hrX=lots; 
 Lots10hrXUnload=halflots;
 Lots10dayX=lots;
 Lots10dayXUnload=halflots;
 LotsStoch=lots;
 LotsStochUnload=halflots;
 LotsSafety=lots;
 LotsSafety1Unload=thirdlots;
 LotsSafety2Unload=thirdlots;

 return(0);
}
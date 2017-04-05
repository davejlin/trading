//+----------------------------------------------------------------------+
//|                                                    TrifectaScalp.mq4 |
//|                                                         David J. Lin |
//|Three MA cross methods based on the trading strategies of             |
//| Vince (forexportfolio@hotmail.com),                                  |
//|and programmed in collaboration with                                  |
//| Mike  (mike@netwin.co.nz).                                           |
//|                                                                      |
//|Modified to be a scalper by Vince                                     |
//|                                                                      |
//|Includes 10hrX and Reversal models from TheOne                        |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|(d-lin@northwestern.edu)                                              |
//|Evanston, IL, September 27, 2006                                      |
//|                                                                      |
//|StopLong, StopShort, TakeLong, TakeShort, and TrailingAlls            |
//| based on code by Patrick (IBFX tutorial)                             |
//+----------------------------------------------------------------------+
#property copyright "David J. Lin"
#property link      ""

// Toggles for Trading Models (true=active, false=inactive)

extern bool flag_40_200=true;      // toggle for 40/200 MA trades
extern bool flag_7_20  =true;      // toggle for 7/20 MA trades
extern bool flag_10_100=true;      // toggle for 10/100 MA trades
extern bool flag_10hrX=true;       // toggle for 10hrX trades
extern bool flag_Reversal=true;    // toggle for Reversal trades

extern int  Display_Corner=0;        // 0=top left, 1=top right, 2=bottom left, 3=bottom right
extern color Display_Color=Black;      // color for Display Status labels

//Fixed Lots List:
  
double Lots1=2.0;                  // lots to trade 40/200 MA (fractional values ok)
double Lots1Unload=1.5;            // lots to unload 40/200   (fractional values ok)
double Lots2=2.0;                  // lots to trade 7/20 MA (fractional values ok)
double Lots2Unload=1.5;            // lots to unload 7/20 (fractional values ok)
double Lots3=2.0;                  // lots to trade 10/100 MA (fractional values ok)
double Lots3Unload=1.5;            // lots to unload 10/100 MA (fractional values ok)
double Lots10hrX=2.0;              // lots to trade 10hrX (fractional values ok)
double Lots10hrXUnload=1.0;        // lots to unload 10hrX at TakeProfit_10hrXUnload (fractional values ok)
double LotsReversal=2.0;             // lots to trade Reversal (fractional values ok)
double LotsReversalUnload=0.7;       // lots to unload Reversal TakeProfit_Reversal (fractional values ok)


// Take Profit List:

int TakeProfit_1=0;                  // pips take profit 40/200
int TakeProfit_1Unload=90;           // pips take profit 40/200 unload
int TakeProfit_2=0;                  // pips take profit 7/20
int TakeProfit_2Unload=90;           // pips take profit 7/20 unload
int TakeProfit_3=0;                  // pips take profit 10/100
int TakeProfit_3Unload=35;           // pips take profit 10/100 unload
int TakeProfit_10hrXMain=0;          // pips take profit 10hrX main order
int TakeProfit_10hrXUnload=0;        // pips take profit 10hrX unload
int TakeProfit_Reversal=150;         // pips take profit Reversal main order
int TakeProfit_ReversalUnload=20;    // pips take profit Reversal unload


// Stop Loss List:

int StopLoss_1=30;                   // pips stop loss for 40/200
int StopLoss_2=40;                   // pips stop loss for 7/20
int StopLoss_3=30;                   // pips stop loss for 10/100
int StopLoss_10hrX=0;                // pips stop loss for 10hrX main order
int StopLoss_Reversal=5;             // pips stop loss for Reversal (above/below high/low for stoploss)


// Trailing Stop List:

int TrailingStop_1=50;               // pips trailing stop loss for 40/200
int TrailingStop_2=50;               // pips trailing stop loss for 7/20
int TrailingStop_3=35;               // pips trailing stop loss for 10/100
int TrailingStop_10hrX=50;           // pips trailing stop loss for 10hrX main order
int TrailingStop_Reversal=60;        // pips trailing stop loss for Reversal 

// 40/200 Variables:

int MA1fastPeriod=40;               // Period
int MA1fastTimeframe=PERIOD_M30;    // Timeframe
int MA1fastShift=0;                 // Shift
int MA1fastMethod=MODE_SMA;         // Mode
int MA1fastPrice=PRICE_CLOSE;       // Method

int MA1slowPeriod=200;              // Period
int MA1slowTimeframe=PERIOD_M30;    // Timeframe
int MA1slowShift=0;                 // Shift
int MA1slowMethod=MODE_SMA;         // Mode
int MA1slowPrice=PRICE_CLOSE;       // Method

int BlackoutPeriod1=30;             // minutes to blackout future 40/200 orders after one has occurred
datetime OrderTime1=0;              // time of latest 40/200 order
bool flag_order1=true;              // true if NO 40/200 MA orders are open
int checktime1=0;                   // stores time remaining in 40/200 blackout

// 7/20 Variables:

int MA2fastPeriod=7;                // Period
int MA2fastTimeframe=PERIOD_H1;     // Timeframe
int MA2fastShift=0;                 // Shift
int MA2fastMethod=MODE_SMA;         // Mode
int MA2fastPrice=PRICE_CLOSE;       // Method

int MA2slowPeriod=21;               // Period
int MA2slowTimeframe=PERIOD_H1;     // Timeframe
int MA2slowShift=0;                 // Shift
int MA2slowMethod=MODE_SMA;         // Mode
int MA2slowPrice=PRICE_CLOSE;       // Method

int BlackoutPeriod2=60;             // minutes to blackout future 7/20 orders after one has occurred
datetime OrderTime2=0;              // time of latest 7/20 order
bool flag_order2=true;              // true if NO 7/20 MA orders are open
int checktime2=0;                   // stores time remaining in 7/20 blackout

// 10/100 Variables:

int MA3fastPeriod=10;               // Period
int MA3fastTimeframe=PERIOD_H1;     // Timeframe
int MA3fastShift=0;                 // Shift
int MA3fastMethod=MODE_SMA;         // Mode
int MA3fastPrice=PRICE_CLOSE;       // Method

int MA3slowPeriod=100;              // Period
int MA3slowTimeframe=PERIOD_H1;     // Timeframe
int MA3slowShift=0;                 // Shift
int MA3slowMethod=MODE_SMA;         // Mode
int MA3slowPrice=PRICE_CLOSE;       // Method

int BlackoutPeriod3=60;             // minutes to blackout future 10/100 orders after one has occurred
datetime OrderTime3=0;              // time of latest 10/100 order
bool flag_order3=true;              // true if NO 10/100 MA orders are open
int checktime3=0;                   // stores time remaining in 10/100 blackout


// 10hrX Variables:

int MA10hrXTimeframe=PERIOD_H1;      // Timeframe

int MA10hrXslowPeriod=10;            // SMA(10) acts as base line for 10hrX
int MA10hrXslowShift=7;              // Shift
int MA10hrXslowMethod=MODE_SMA;      // Mode
int MA10hrXslowPrice=PRICE_CLOSE;    // Method

int MA10hrXveryslowPeriod=25;        // SMA(25) acts as exit line for 10hrX
int MA10hrXveryslowShift=0;          // Shift
int MA10hrXveryslowMethod=MODE_SMA;  // Mode
int MA10hrXveryslowPrice=PRICE_CLOSE;// Method

int TriggerPips10hrX=22;             // pips above 10hrSMA/price cross to execute order (trigger)
int Timeframe10HrXMonitor=PERIOD_H1; // Timeframe of monitoring 10HrX orders

double TriggerPrice10hrX=0.0;        // price of 10hrX trigger, calculated from TriggerPips10hrX at cross
double Time10hrX=0.0;                // time of 10hrSMA/price cross
double Price10hrX=0.0;               // price at 10hrSMA/price cross
int BlackOutPeriod10hrX=60;          // minutes to ignore future triggers 
datetime OrderTime10hrX=0;           // time of last 10hrX order
bool flag_order10hrX=true;           // true if NO 10hrX order is open
bool flag_10hrXLong=false;           // true if 10hrX up, therefore go long
bool flag_10hrXShort=false;          // true if 10hrX up, therefore go long
bool flag_close10hrXLong=false;      // true if exit signal is triggered for long 
bool flag_close10hrXShort=false;     // true if exit signal is triggered for short 

int WindowPeriod10hrX=2;             // number of periods after 10hrX trigger for window of opportunity
int windowtime10hrX=0;               // stores time remaining in 10hrX window of opportunity
int checktime10hrX=0;                // stores time remaining in 10hrX blackout

// Reversal Model's Variables

int PeriodReversal=20;               // hours in scanning period to determine whether current high is a maximum
int TriggerReversal=20;              // pips above/below hour's low/high to trigger order execution
int BlackoutPeriodReversal=60;       // minutes after the submission of a Reversal order to avoid sending another order
datetime OrderTimeReversal=0;        // time of last reversal order
bool flag_orderReversal=true;        // true if NO Reversal order is open
int checktimeReversal=0;             // stores time remaining in Reversal blackout


// Misc Variables

int Slippage=3;                      // pips slippage allowed

// Flags which indicate partial takeprofit unloading

bool flag_dump1=false;               // true if 40/200 Unload-ed
bool flag_dump2=false;               // true if 7/20 Unload-ed
bool flag_dump3=false;               // true if 10/100 Unload-ed
bool flag_dump4=false;               // true if 10hrX Unload-ed
bool flag_dump5=false;               // true if Reversal Unload-ed

// Magic numbers (to identify which orders belong to which models)

int magic1=40200;                    // 40/200 magic number base
int magic2=720;                      // 7/20 magic number base
int magic3=10100;                    // 10/100 magic number base
int magic4=107;                      // 10hrX magic number base
int magic5=701;                      // Reversal magic number base

// Strings 

string comment1="40_200_Scalp";
string comment2="7_20_Scalp";
string comment3="10_100_Scalp";
string comment4="10hrX_Scalp";
string comment5="Reversal_Scalp";

// Buffers for Status Display
int    xpos=10;                      // pixels from left to show Display Status
int    ypos=10;                      // pixels from top to show Display Status
color  Color1=Red;            // colors for Display Status labels
color  Color2=Red;
color  Color3=Red;
color  Color10hrX=Red;
color  ColorReversal=Red;
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
 DisplayStatus();   
 
 if(flag_40_200)
  Main1();

 if(flag_7_20)
  Main2();   

 if(flag_10_100)
  Main3();
  
 if(flag_10hrX)
 {
  Monitor10hrX(); 
  Main10hrX();   
 } 
 
 if(flag_Reversal)
  MainReversal();
                                         
 TakeProfitUnload();                 // Unload for partial profits
 TrailStop();                        // Trailing Stop
   
 return(0);
}

//===========================================================================================
//===========================================================================================

void Main1()
{
//Calculate Secret MA Indicators
 double fast1=iMA(NULL,MA1fastTimeframe,MA1fastPeriod,MA1fastShift,MA1fastMethod,MA1fastPrice,1); 
 double fast2=iMA(NULL,MA1fastTimeframe,MA1fastPeriod,MA1fastShift,MA1fastMethod,MA1fastPrice,2);
 double slow1=iMA(NULL,MA1slowTimeframe,MA1slowPeriod,MA1slowShift,MA1slowMethod,MA1slowPrice,1); 
 double slow2=iMA(NULL,MA1slowTimeframe,MA1slowPeriod,MA1slowShift,MA1slowMethod,MA1slowPrice,2);

 checktime1=(BlackoutPeriod1*60)-(CurTime()-OrderTime1); // need to monitor time in case of EA re-start

//40/200 MA Enter Long, Close Shorts
//      
  if(fast1>slow1&&fast2<slow2&&checktime1<0)
  {
   CloseShorts(magic1);
   SendOrderLong(Symbol(),Lots1,Slippage,StopLong(Ask,StopLoss_1),TakeLong(Ask,TakeProfit_1),comment1,magic1,0,Blue);
   flag_dump1=true;
   OrderTime1=CurTime();
  }//Long
  
//
//40/200 MA Enter Short, Close Longs
//
  if(fast1<slow1&&fast2>slow2&&checktime1<0)
  {
   CloseLongs(magic1);
   SendOrderShort(Symbol(),Lots1,Slippage,StopShort(Bid,StopLoss_1),TakeShort(Bid,TakeProfit_1),comment1,magic1,0,Red);
   flag_dump1=true;
   OrderTime1=CurTime();   
  }//Shrt   
  
 return(0);
}

//===========================================================================================
//===========================================================================================

void Main2()
{
//Calculate Secret MA Indicators
 double fast1=iMA(NULL,MA2fastTimeframe,MA2fastPeriod,MA2fastShift,MA2fastMethod,MA2fastPrice,1); 
 double fast2=iMA(NULL,MA2fastTimeframe,MA2fastPeriod,MA2fastShift,MA2fastMethod,MA2fastPrice,2);
 double slow1=iMA(NULL,MA2slowTimeframe,MA2slowPeriod,MA2slowShift,MA2slowMethod,MA2slowPrice,1); 
 double slow2=iMA(NULL,MA2slowTimeframe,MA2slowPeriod,MA2slowShift,MA2slowMethod,MA2slowPrice,2);

 checktime2=(BlackoutPeriod2*60)-(CurTime()-OrderTime2); // need to monitor time in case of EA re-start

//7/20 MA Enter Long, Close Shorts
//      
  if(fast1>slow1&&fast2<slow2&&checktime2<0)
  {
   CloseShorts(magic2);
   SendOrderLong(Symbol(),Lots2,Slippage,StopLong(Ask,StopLoss_2),TakeLong(Ask,TakeProfit_2),comment2,magic2,0,Blue);
   flag_dump2=true;
   OrderTime2=CurTime();
  }//Long
  
//
//7/20 MA Enter Short, Close Longs
//
  if(fast1<slow1&&fast2>slow2&&checktime2<0)
  {
   CloseLongs(magic2);
   SendOrderShort(Symbol(),Lots2,Slippage,StopShort(Bid,StopLoss_2),TakeShort(Bid,TakeProfit_2),comment2,magic2,0,Red);
   flag_dump2=true;
   OrderTime2=CurTime();   
  }//Shrt   
  
 return(0);
}

//===========================================================================================
//===========================================================================================

void Main3()
{
//Calculate Secret MA Indicators
 double fast1=iMA(NULL,MA3fastTimeframe,MA3fastPeriod,MA3fastShift,MA3fastMethod,MA3fastPrice,1); 
 double fast2=iMA(NULL,MA3fastTimeframe,MA3fastPeriod,MA3fastShift,MA3fastMethod,MA3fastPrice,2);
 double slow1=iMA(NULL,MA3slowTimeframe,MA3slowPeriod,MA3slowShift,MA3slowMethod,MA3slowPrice,1); 
 double slow2=iMA(NULL,MA3slowTimeframe,MA3slowPeriod,MA3slowShift,MA3slowMethod,MA3slowPrice,2);

 checktime3=(BlackoutPeriod3*60)-(CurTime()-OrderTime3); // need to monitor time in case of EA re-start

//10/100 MA Enter Long, Close Shorts
//      
  if(fast1>slow1&&fast2<slow2&&checktime3<0)
  {
   CloseShorts(magic3);
   SendOrderLong(Symbol(),Lots3,Slippage,StopLong(Ask,StopLoss_3),TakeLong(Ask,TakeProfit_3),comment3,magic3,0,Blue);
   flag_dump3=true;
   OrderTime3=CurTime();
  }//Long
  
//
//40/200 MA Enter Short, Close Longs
//
  if(fast1<slow1&&fast2>slow2&&checktime3<0)
  {
   CloseLongs(magic3);
   SendOrderShort(Symbol(),Lots3,Slippage,StopShort(Bid,StopLoss_3),TakeShort(Bid,TakeProfit_3),comment3,magic3,0,Red);
   flag_dump3=true;
   OrderTime3=CurTime();   
  }//Shrt   
  
 return(0);
}

//===========================================================================================
//===========================================================================================

void Main10hrX()
{
 for(int i=1;i<=2;i++) // Examine whether confirmed crosses occured up to 2 hours ago
 {
//Calculate Indicators
  double fast1=iClose(NULL,MA10hrXTimeframe,i);
  double fast2=iClose(NULL,MA10hrXTimeframe,i+1);
  double slow1=iMA(NULL,MA10hrXTimeframe,MA10hrXslowPeriod,MA10hrXslowShift,MA10hrXslowMethod,MA10hrXslowPrice,i); 
  double slow2=iMA(NULL,MA10hrXTimeframe,MA10hrXslowPeriod,MA10hrXslowShift,MA10hrXslowMethod,MA10hrXslowPrice,i+1);

  flag_10hrXLong=false;
  flag_10hrXShort=false;

//Check for MA cross
  if(fast1>slow1 && fast2<slow2) // cross UP i hour ago
  {
   flag_10hrXLong=true;
   flag_10hrXShort=false;   
   flag_close10hrXLong=false;
   Price10hrX=(slow1+slow2)/2.0;
   Time10hrX=iTime(NULL,MA10hrXTimeframe,i);     
   TriggerPrice10hrX=Price10hrX+(TriggerPips10hrX*Point);
   break;
  }
    
  if(fast1<slow1 && fast2>slow2) // cross DOWN i bar ago
  {
   flag_10hrXLong=false;
   flag_10hrXShort=true;     
   flag_close10hrXShort=false;
   Price10hrX=(slow1+slow2)/2.0;
   Time10hrX=iTime(NULL,MA10hrXTimeframe,i);
   TriggerPrice10hrX=Price10hrX-(TriggerPips10hrX*Point);
   break;
  }
 }

 fast1=iClose(NULL,MA10hrXTimeframe,1);
 fast2=iClose(NULL,MA10hrXTimeframe,2); 
 double veryslow1=iMA(NULL,MA10hrXTimeframe,MA10hrXveryslowPeriod,MA10hrXveryslowShift,MA10hrXveryslowMethod,MA10hrXveryslowPrice,1);
 double veryslow2=iMA(NULL,MA10hrXTimeframe,MA10hrXveryslowPeriod,MA10hrXveryslowShift,MA10hrXveryslowMethod,MA10hrXveryslowPrice,2);

// check exit signals for main 10hrX order:
 
 if(flag_order10hrX==false)
 {
  if(fast1<veryslow1&&fast2>veryslow2)
   flag_close10hrXLong=true;
 
  if(fast1>veryslow1&&fast2<veryslow2)
   flag_close10hrXShort=true;
 }
 return(0);
}

//===========================================================================================
//===========================================================================================

void Monitor10hrX()
{
// Add 1 to WindowPeriod10hrX because crossover determination is delayed 1 full period
// The following gives a 2 hour window, if WindowPeriod10hrX=2:  
 windowtime10hrX = ((WindowPeriod10hrX+1)*3600)- (CurTime()-Time10hrX);  // no longer used as a submission criteria, flags are sufficient
 checktime10hrX   = (BlackOutPeriod10hrX*60)-(CurTime()-OrderTime10hrX);

 if(flag_order10hrX)
 {
  if(checktime10hrX<0)
  {
   double SL=0.0;
//Enter Long 
//      
   if(Ask>=TriggerPrice10hrX&&flag_10hrXLong==true)
   {
    if(StopLoss_10hrX==0)
//   SL=iLow(NULL,Timeframe10HrXMonitor,1);
//   SL=Price10hrX;
     SL=0.0;
    else
     SL=StopLong(Ask,StopLoss_10hrX);
   
    SendOrderLong(Symbol(),Lots10hrX,Slippage,SL,TakeLong(Ask,TakeProfit_10hrXMain),comment4,magic4,0,Blue);
    OrderTime10hrX=CurTime();
    flag_dump4=true;
   }//Long 
//
//Enter Short 
//
   if(Bid<=TriggerPrice10hrX&&flag_10hrXShort==true)
   {
    if(StopLoss_10hrX==0)
//   SL=iHigh(NULL,Timeframe10HrXMonitor,1);
//   SL=Price10hrX;
    SL=0.0;
    else
     SL=StopShort(Bid,StopLoss_10hrX);  
   
    SendOrderShort(Symbol(),Lots10hrX,Slippage,SL,TakeShort(Bid,TakeProfit_10hrXMain),comment4,magic4,0,Red);
    OrderTime10hrX=CurTime();
    flag_dump4=true;
   }//Shrt
  } 
 }
 else
 {
  if(checktime10hrX<0)
  {
   if(flag_close10hrXLong)
   {
    CloseLongs(magic4);
    flag_close10hrXLong=false;
   }
  
   if(flag_close10hrXShort)
   {
    CloseShorts(magic4);
    flag_close10hrXShort=false;
   }
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
  double HrHigh=iHigh(NULL,PERIOD_H1,2);                              // the high BEFRORE the previously completed hour's high
  double pastHrHigh=iHigh(NULL,PERIOD_H1,Highest(NULL,PERIOD_H1,MODE_HIGH,PeriodReversal,3)); // past PeriodReversal hours high 
  double HrClose=iClose(NULL,PERIOD_H1,1);                            // the previously completed hour's high (which is equivalently the "subsequent" hour)
 
  if(HrHigh>=pastHrHigh&&HrClose<=(HrHigh-(TriggerReversal*Point))) // we are at a high, so check conditions for sell
  {
   SL=HrHigh+(StopLoss_Reversal*Point);
   SendOrderShort(Symbol(),LotsReversal,Slippage,SL,TakeShort(Bid,TakeProfit_Reversal),comment5,magic5,0,Red); 
   flag_dump5=true;
   OrderTimeReversal=CurTime();
  }

  double HrLow=iLow(NULL,PERIOD_H1,2);                                // the low BEFRORE the previously completed hour's low
  double pastHrLow=iLow(NULL,PERIOD_H1,Lowest(NULL,PERIOD_H1,MODE_LOW,PeriodReversal,3));    // past PeriodReversal hours low

  if(HrLow<=pastHrLow&&HrClose>=(HrLow+(TriggerReversal*Point)))  // we are at a low, so check conditions for buy
  {
   SL=HrLow-(StopLoss_Reversal*Point);
   SendOrderLong(Symbol(),LotsReversal,Slippage,SL,TakeLong(Ask,TakeProfit_Reversal),comment5,magic5,0,Blue); 
   flag_dump5=true;
   OrderTimeReversal=CurTime();
  }  
  
 }
 return(0);
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

void TakeProfitUnload() // Unload 
{
 if(flag_dump1) 
 {
  if(TakeProfit_1Unload!=0) 
   flag_dump1=TakeProfitCycle(flag_dump1,Lots1Unload,magic1,TakeProfit_1Unload);
 }
 
 if(flag_dump2) 
 {
  if(TakeProfit_2Unload!=0)
   flag_dump2=TakeProfitCycle(flag_dump2,Lots2Unload,magic2,TakeProfit_2Unload);
 }
  
  if(flag_dump3) 
 {
  if(TakeProfit_3Unload!=0)
   flag_dump3=TakeProfitCycle(flag_dump3,Lots3Unload,magic3,TakeProfit_3Unload);
 }
 
  if(flag_dump4) 
 {
  if(TakeProfit_10hrXUnload!=0)
   flag_dump4=TakeProfitCycle(flag_dump4,Lots10hrXUnload,magic4,TakeProfit_10hrXUnload);
 } 

  if(flag_dump5) 
 {
  if(TakeProfit_ReversalUnload!=0)
   flag_dump5=TakeProfitCycle(flag_dump5,LotsReversalUnload,magic5,TakeProfit_ReversalUnload);
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

void TrailStop() 
{
 if(flag_40_200) 
 {
  if(TrailingStop_1!=0) 
   TrailingAlls(magic1,TrailingStop_1);
 }
 
 if(flag_7_20) 
 {
  if(TrailingStop_2!=0) 
   TrailingAlls(magic2,TrailingStop_2);
 }
 
  if(flag_10_100) 
 {
  if(TrailingStop_3!=0) 
   TrailingAlls(magic3,TrailingStop_3);
 }
 
  if(flag_10hrX) 
 {
  if(TrailingStop_10hrX!=0) 
   TrailingAlls(magic4,TrailingStop_10hrX);
 } 
 
  if(flag_Reversal) 
 {
  if(TrailingStop_Reversal!=0) 
   TrailingAlls(magic5,TrailingStop_Reversal);
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
 
 flag_order1=true;                   // first assume we have no open 40/200 orders
 flag_order2=true;                   // first assume we have no open 7/20 orders
 flag_order3=true;                   // first assume we have no open 10/100 orders
 flag_order10hrX=true;               // first assume we have no open 10hrX orders
 flag_orderReversal=true;            // first assume we have no open Reversal orders


 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
   
  if(OrderSymbol()!=Symbol())
   continue;
   
  switch(OrderMagicNumber())
  {
   case 40200:
    flag_order1=false;              // false if there are open 40/200 orders
    continue;
   case 720:
    flag_order2=false;              // false if there are open 7/20 orders
    continue;
   case 10100:
    flag_order3=false;              // false if there are open 10/100 orders
    continue;
   case 107:
    flag_order10hrX=false;           // false if there are open 10hrX orders
    continue;    
   case 701:
    flag_orderReversal=false;        // false if there are open 10hrX orders
    continue;      
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

// First check closed trades
 int trade;                         
 int trades=HistoryTotal();           
 for(trade=trades-1;trade>=0;trade--)   // The most recent closed order has the largest position number, so this works backward from the most recent closed orders
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_HISTORY);

  if(OrderSymbol()!=Symbol())
   continue;

  double timediff=(CurTime()-OrderCloseTime())/3600;  // time difference in hours
  
  if(timediff >= 1) // only interested in closed trades in this hour
   continue;

  switch(OrderMagicNumber())
  {
   case 40200: 
    OrderTime1=OrderOpenTime();
    continue;
   case 720:
    OrderTime2=OrderOpenTime();
    continue;
   case 10100:
    OrderTime3=OrderOpenTime();
    continue;
   case 107:
    OrderTime10hrX=OrderOpenTime();
    continue;
   case 701:
    OrderTimeReversal=OrderOpenTime();
    continue;
  }   
 } 

// Now check open trades:
                          
 trades=OrdersTotal();           
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()!=Symbol())
   continue;

  switch(OrderMagicNumber())
  {
   case 40200: 
    OrderTime1=OrderOpenTime();
    if(OrderLots()==Lots1)
     flag_dump1=true;
    continue;
   case 720:
    OrderTime2=OrderOpenTime();
    if(OrderLots()==Lots2)
     flag_dump2=true;
    continue;
   case 10100:
    OrderTime3=OrderOpenTime();
    if(OrderLots()==Lots3)
     flag_dump3=true;
    continue;
   case 107:
    OrderTime10hrX=OrderOpenTime();
    if(OrderLots()==Lots10hrX)
     flag_dump4=true;
    continue;
   case 701:
    OrderTimeReversal=OrderOpenTime();
    if(OrderLots()==LotsReversal)
     flag_dump5=true;
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
 ObjectDelete( "1" );
 ObjectDelete( "2" );
 ObjectDelete( "3" );
 ObjectDelete( "10hrX" );
 ObjectDelete( "Reversal" );

 
 ObjectDelete( "1v" );
 ObjectDelete( "2v" );
 ObjectDelete( "3v" );
 ObjectDelete( "10hrXv" );
 ObjectDelete( "Reversalv" );
  
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
 string status1;
 string status2;
 string status3; 
 string status10hrX;
 string statusReversal;       

 if(flag_40_200)
 {
  status1="Active";
  if(flag_order1)
   Color1=ColorNoOrder;
  else 
  {
   Color1=ColorOrder;
   if(checktime1>0)
   {
    timecheck=checktime1/60;
    status1=StringConcatenate("Black-out period = ",timecheck," minutes remaining.");
   }
   else
    status1=("Open 40/200 order");
  }  
 } 
 else
  status1="Inactive";

 if(flag_7_20)
 {
  status2="Active";
  if(flag_order2)
   Color2=ColorNoOrder;
  else 
  {
   Color2=ColorOrder;
   if(checktime2>0)
   {
    timecheck=checktime2/60;
    status2=StringConcatenate("Black-out period = ",timecheck," minutes remaining.");
   }
   else
    status2=("Open 7/20 order");
  }  
 } 
 else
  status2="Inactive";

 if(flag_10_100)
 {
  status3="Active";
  if(flag_order3)
   Color3=ColorNoOrder;
  else 
  {
   Color3=ColorOrder;
   if(checktime3>0)
   {
    timecheck=checktime3/60;
    status3=StringConcatenate("Black-out period = ",timecheck," minutes remaining.");
   }
   else
    status3=("Open 10/100 order");
  }  
 } 
 else
  status3="Inactive";
  
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

 ObjectSetText( "1", "40/200", 9, "Arial", Color1 );
 ObjectSetText( "2", "7/20", 9, "Arial", Color2 );
 ObjectSetText( "3", "10/100", 9, "Arial", Color3 ); 
 ObjectSetText( "10hrX", "10hrX", 9, "Arial", Color10hrX );
 ObjectSetText( "Reversal", "Reversal", 9, "Arial", ColorReversal );
          
 ObjectSetText( "1v", status1, 9, "Times", Display_Color );
 ObjectSetText( "2v", status2, 9, "Times", Display_Color );
 ObjectSetText( "3v", status3, 9, "Times", Display_Color ); 
 ObjectSetText( "10hrXv", status10hrX, 9, "Times", Display_Color);
 ObjectSetText( "Reversalv", statusReversal, 9, "Times", Display_Color); 
     
// ObjectsRedraw();
 return(0);
}

//===========================================================================================
//===========================================================================================

void DisplayStatusInit()
{
 int xoffset=75; // pixel offset between labels and values
// Status Display
   
 ObjectMakeLabel( "1", xpos, ypos );
 ObjectMakeLabel( "2", xpos, ypos+12 );
 ObjectMakeLabel( "3", xpos, ypos+24 );
 ObjectMakeLabel( "10hrX", xpos, ypos+36 );
 ObjectMakeLabel( "Reversal", xpos, ypos+48 );

 ObjectMakeLabel( "1v", xpos+xoffset, ypos );
 ObjectMakeLabel( "2v", xpos+xoffset, ypos+12 );
 ObjectMakeLabel( "3v", xpos+xoffset, ypos+24 );
 ObjectMakeLabel( "10hrXv", xpos+xoffset, ypos+36 );
 ObjectMakeLabel( "Reversalv", xpos+xoffset, ypos+48 );

 ObjectSetText( "1", "40/200", 9, "Arial", Blue );
 ObjectSetText( "2", "7/20", 9, "Arial", Blue );
 ObjectSetText( "3", "10/100", 9, "Arial", Blue );
 ObjectSetText( "10hrX", "10hrX", 9, "Arial", Blue );
 ObjectSetText( "Reversal", "Reversal", 9, "Arial", Blue ); 

 ObjectSetText( "1v", "Initializing", 9, "Times", Display_Color );
 ObjectSetText( "2v", "Initializing", 9, "Times", Display_Color );
 ObjectSetText( "3v", "Initializing", 9, "Times", Display_Color ); 
 ObjectSetText( "10hrXv", "Initializing", 9, "Times", Display_Color);
 ObjectSetText( "Reversalv", "Initializing", 9, "Times", Display_Color); 
 
}
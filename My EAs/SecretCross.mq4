//+----------------------------------------------------------------------+
//|                                                      SecretCross.mq4 |
//|                                                         David J. Lin |
//|                                                                      |
//|Based on a 10-period crossover strategy by something_witty IBFX forum |
//|      Vince ( forexportfolio@hotmail.com )                            |  
//|                                                                      |
//|  - Trigger = crossover of current price action an secret MA.         |
//|  - Stop Loss = optional                                              |
//|  - Take Profit = you can takeprofit w/ 1/2 order                     |
//|  - Trailing stop = optional                                          |
//|  - Timeframe = recommended: H1 or longer, but this EA can be applied |
//|     to any timeframe.                                                |
//|  - Pairs = Any, but with current parameters                          |
//|  - Money Management = none or stoploss.                              |
//|     WARNING:  this EA does NOT take margin into account,             |
//|               so beware of margin.                                   |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|d-lin@northwestern.edu                                                |
//|Evanston, IL, September 13, 2006                                      |
//|                                                                      |
//|TakeLong, TakeShort, and TrailingAlls coded by Patrick (IBFX tutorial)|
//+----------------------------------------------------------------------+
#property copyright "David J. Lin"
#property link      ""

extern double Lots=10.0;          // lots to trade (fractional values ok)
extern double LotsUnload=5.0;     // lots to unload at takeprofit2 (fractional values ok)
extern int Slippage=3;            // pips slippage allowed
extern int TrailingStop=0;        // pips to trail both orders 
extern int TakeProfit1=0;         // pips take profit main order
extern int TakeProfit2=30;        // pips take profit unload
extern int StopLoss=0;
 
extern int MA1Period=1;           // EMA(1) acts as trigger line to gauge immediate price action 
extern int MA1Shift=0;            // Shift
extern int MA1Method=MODE_EMA;    // Mode
extern int MA1Price=PRICE_CLOSE;  // Method

extern int MA2Period=10;          // SMA(10) acts as base line
extern int MA2Shift=25;           // Shift
extern int MA2Method=MODE_SMA;    // Mode
extern int MA2Price=PRICE_CLOSE;  // Method

bool flag_dump=false;             // flag to gauge whether to check takeprofit2                     
int magic=5678;                   // order's magic number
datetime lasttime=0;              // stores current bar's time to trigger MA calculation
double fast1;                     // stores MA values up to 3 completed bars ago
double fast2;                     // fast = current price action, approximated by EMA(1)
                                  // slow = base line, SMA(10)
double slow1;
double slow2;

int init()
{
// hello world
 magic = magic+Period();
 return(0);
}

int deinit()
{
// goodbye world
 return(0);
}

//===========================================================================================
//===========================================================================================

int start()         // main cycle
{
 Main();            // Order execution and maintenance
}

//===========================================================================================
//===========================================================================================

void Main()         // Trigger order execution
{
 if(flag_dump)
  TakeProfitUnload();
 
 TrailingAlls(TrailingStop);   //Trailing Stop

 if(lasttime==Time[0])      // only need to calculate MA values at the start of each bar
  return(0);
  lasttime=Time[0];
//Calculate Indicators
  fast1=iMA(NULL,0,MA1Period,MA1Shift,MA1Method,MA1Price,1); 
  fast2=iMA(NULL,0,MA1Period,MA1Shift,MA1Method,MA1Price,2);
  slow1=iMA(NULL,0,MA2Period,MA2Shift,MA2Method,MA2Price,1); 
  slow2=iMA(NULL,0,MA2Period,MA2Shift,MA2Method,MA2Price,2);
//
//Enter Long, Exit Short 
//      
 if(fast1>slow1 && fast2<slow2)
 {
  CloseShorts();        
  OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,StopLoss,TakeLong(Ask,TakeProfit1),NULL,magic,0,Blue);
  flag_dump=true;
 }//Long 
//
//Enter Short, Exit Short 
//
 if(fast1<slow1 && fast2>slow2)
 {
  CloseLongs(); 
  OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,StopLoss,TakeShort(Bid,TakeProfit1),NULL,magic,0,Red);
  flag_dump=true;
 }//Shrt
return(0);
}

//===========================================================================================
//===========================================================================================

void CloseLongs()
{
 int trade;
 int trades=OrdersTotal();
 for(trade=0;trade<trades;trade++)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()==Symbol()&&OrderMagicNumber()==magic&&OrderType()==OP_BUY)
   OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Blue); 

 } //for
}

//===========================================================================================
//===========================================================================================

void CloseShorts()
{
 int trade;
 int trades=OrdersTotal();
 for(trade=0;trade<trades;trade++)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()==Symbol()&&OrderType()==OP_SELL)
   OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Red); 
 } //for
}

//===========================================================================================
//===========================================================================================

double TakeLong(double price,int take)  // function to calculate takeprofit if long
{
 if(take==0)
  return(0.0); // if no take profit
 return(price+(take*Point)); 
             // plus, since the take profit is above us for long positions
}

//===========================================================================================
//===========================================================================================

double TakeShort(double price,int take)  // function to calculate takeprofit if short
{
 if(take==0)
  return(0.0); // if no take profit
 return(price-(take*Point)); 
             // minus, since the take profit is below us for short positions
}

//===========================================================================================
//===========================================================================================

void TakeProfitUnload()             // Unload LotsUnload at takeprofit2
{
 if(TakeProfit2==0||LotsUnload==0.0)
  return;
  
 double stopcrnt;
 double stopcal;
  
 int trade;
 int trades=OrdersTotal();
 for(trade=0;trade<trades;trade++)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()!=Symbol())
   continue;

//Long 
  if(OrderType()==OP_BUY&&OrderMagicNumber()==magic)
  {
   if(Bid-OrderOpenPrice()>=TakeProfit2*Point)
   {
    OrderClose(OrderTicket(),LotsUnload,Bid,Slippage,Blue);
    flag_dump=false;
   }  
  }//Long 
  
//Short 
  if(OrderType()==OP_SELL&&OrderMagicNumber()==magic)
  {
   if(OrderOpenPrice()-Ask>=TakeProfit2*Point)
   {
    OrderClose(OrderTicket(),LotsUnload,Ask,Slippage,Red);
    flag_dump=false; 
   } 
  }//Short   
 } //for
}

//===========================================================================================
//===========================================================================================

void TrailingAlls(int trail)             // client-side trailing stop
{
 if(trail==0)
  return;
  
 double stopcrnt;
 double stopcal;
  
 int trade;
 int trades=OrdersTotal();
 for(trade=0;trade<trades;trade++)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()!=Symbol())
   continue;

//Long 
  if(OrderType()==OP_BUY&&OrderMagicNumber()==magic)
  {
   stopcrnt=OrderStopLoss();
   stopcal=Bid-(trail*Point); 
   if(stopcrnt==0)
   {
    OrderModify(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Blue);
   }
   else
   {
    if(stopcal>stopcrnt)
    {
     OrderModify(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Blue);
    }
   }
  }//Long 
  
//Short 
  if(OrderType()==OP_SELL&&OrderMagicNumber()==magic)
  {
   stopcrnt=OrderStopLoss();
   stopcal=Ask+(trail*Point); 
   if(stopcrnt==0)
   {
    OrderModify(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red);
   }
   else
   {
    if(stopcal<stopcrnt)
    {
     OrderModify(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red);
    }
   }
  }//Short   
 } //for
}



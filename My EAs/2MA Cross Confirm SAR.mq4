//+------------------------------------------------------------------+
//|                                                  2MA Confirm.mq4 |
//|                                                     David J. Lin |
//|strategy from babypips.com                                        |
//| uses stochastics and RSI to confirm 2MA crossover                |
//+------------------------------------------------------------------+
#property copyright "David J. Lin"
#property link      ""

extern int MACDdiff=0;
extern int MAFastPeriod=3;
extern int MASlowPeriod=18;
extern int stoch1=10;
extern int stoch2=3;
extern int stoch3=3;
extern double SARstep=0.02;
extern double SARmax=0.2;
extern int rsiPeriod=14;
//extern int HrStart=10;
//extern int HrEnd=15;

extern double stochLow=30.0;
extern double stochHigh=70.0;
extern int today1=0;
extern int today2=5;
extern double Lots=1.0;

extern int Account=0;
extern int Slippage=3;
extern int StopLoss=0;
extern int TrailingStop=0;
extern int TakeProfit=0;

extern int MAFastShift=0;
extern int MAFastMethod=MODE_SMA;
extern int MAFastPrice=PRICE_CLOSE;

extern int MASlowShift=0;
extern int MASlowMethod=MODE_SMA;
extern int MASlowPrice=PRICE_CLOSE;

extern int stochMethod=MODE_SMA;

bool runnable=true;
bool init=true;

datetime timeprev=0;

int init()
{
 return(0);
}

int deinit()
{
 return(0);
}

//===========================================================================================
//===========================================================================================

int start()
{
//Runnable
 if(runnable!=true)
  return(-1);
  
//Init
 if(init==true)
 {
  init=false;
//  if(!InterbankFXServer())
//  {
//  runnable=false;
//  Alert("*** WARNING: Please use InterbankFX Server ***");
//  return(-1);
//  }
  if(IsTesting()==false&&Account!=AccountNumber())
  {
   runnable=false;
   Alert("*** WARNING: Please check Account Number! ***");
   return(-1);
  }
 }//Init


//Trailing Stop
 TrailingAlls(TrailingStop);
 
//Close/Open
  if(timeprev==Time[0]) //Time[0] is the time at close/open of a bar
   return(0);
  timeprev=Time[0]; 
  
//Calculate Indicators
 double fast1=iMA(NULL,0,MAFastPeriod,MAFastShift,MAFastMethod,MAFastPrice,1); 
 double fast2=iMA(NULL,0,MAFastPeriod,MAFastShift,MAFastMethod,MAFastPrice,2);
 // use information from bars 1 and 2, which are the most recently completely formed bars   
 double slow1=iMA(NULL,0,MASlowPeriod,MASlowShift,MASlowMethod,MASlowPrice,1); 
 double slow2=iMA(NULL,0,MASlowPeriod,MASlowShift,MASlowMethod,MASlowPrice,2);
 // stochastics
 double stochasticBase1=iStochastic(NULL,0,stoch1,stoch2,stoch3,stochMethod,0,MODE_BASE,1);
 double stochasticBase2=iStochastic(NULL,0,stoch1,stoch2,stoch3,stochMethod,0,MODE_BASE,2);
 double stochasticSign1=iStochastic(NULL,0,stoch1,stoch2,stoch3,stochMethod,0,MODE_SIGNAL,1);
 double stochasticSign2=iStochastic(NULL,0,stoch1,stoch2,stoch3,stochMethod,0,MODE_SIGNAL,2);
 // RSI
 double rsi=iRSI(NULL,0,rsiPeriod,PRICE_CLOSE,0);
 // SAR
 double SAR1=iSAR(NULL,0,SARstep,SARmax,1);
 double SAR2=iSAR(NULL,0,SARstep,SARmax,2);
 
 int total;

  total=OrdersTotal();
//  Print("Total number of orders is ", total);
  if(total<1)
  {
  
//Don't enter trades certain days & times:
   if(DayOfWeek()!=today1 && DayOfWeek()!=today2) // && Hour()>=HrStart && Hour()<=HrEnd)
   {   
//
//Enter Long 
//
    if(fast1>slow1&&fast2<slow2&&MathAbs(fast1-slow1)>=(MACDdiff*Point))
    {
     if(stochasticBase1>stochasticBase2&&stochasticSign1>stochasticSign2)
     {
      if(stochasticBase1<stochHigh&&rsi>50.0)
      {
       OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,StopLong(Ask,StopLoss),TakeLong(Ask,TakeProfit),NULL,0,0,Blue);
      }  
     }   
    }//Long 
//
//Enter Short 
//
    if(fast1<slow1&&fast2>slow2&&MathAbs(fast1-slow1)>=(MACDdiff*Point))
    {
     if(stochasticBase1<stochasticBase2&&stochasticSign1<stochasticSign2)
     {
      if(stochasticBase1>stochLow&&rsi<50.0)
      { 
       OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,StopShort(Bid,StopLoss),TakeShort(Bid,TakeProfit),NULL,0,0,Red);
      } 
     }
    }//Shrt
      
   }//day

 }
 else
 {
 
// Find closing price 
   OrderSelect(0,SELECT_BY_POS,MODE_TRADES);
   double closeprice = OrderClosePrice();
 
//
//Exit Long 
// 
//   if((fast1<SAR1&&fast2>SAR2)||rsi<50.0) // for SAR cross
   if (closeprice<=SAR1) // for close price 
   {
    CloseLongs();
   }
//
//Exit Short 
//
//   if((fast1>SAR1&&fast2<SAR2)||rsi>50.0) // for SAR cross
   if (closeprice>=SAR1) // for close price
   {
    CloseShorts();
   }
}
return(0);
}


//===========================================================================================
//===========================================================================================

bool InterbankFXServer()
{
 if(ServerAddress()=="InterbankFX"||ServerAddress()=="InterbankFX-Demo"||ServerAddress()=="66.114.105.89")
  return(true);
 else
  return(false);
}

double StopLong(double price,int stop)
{
 if(stop==0)
  return(0.0); // if no stop loss
 return(price-(stop*Point)); 
             // minus, since the stop loss is below us for long positions
             // Point is 0.01 or 0.0001 depending on currency, so stop*POINT is a way to convert pips into price with multiplication 
}

double StopShort(double price,int stop)
{
 if(stop==0)
  return(0.0); // if no stop loss
 return(price+(stop*Point)); 
             // plus, since the stop loss is above us for short positions
}

double TakeLong(double price,int take)
{
 if(take==0)
  return(0.0); // if no take profit
 return(price+(take*Point)); 
             // plus, since the take profit is above us for long positions
}

double TakeShort(double price,int take)
{
 if(take==0)
  return(0.0); // if no take profit
 return(price-(take*Point)); 
             // minus, since the take profit is below us for short positions
}

void CloseLongs()
{
 int trade;
 int trades=OrdersTotal();
 for(trade=0;trade<trades;trade++)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()!=Symbol())
   continue;
   
  if(OrderType()==OP_BUY)
   OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Blue); 
 } //for
}

void CloseShorts()
{
 int trade;
 int trades=OrdersTotal();
 for(trade=0;trade<trades;trade++)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()!=Symbol())
   continue;
   
  if(OrderType()==OP_SELL)
   OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Red); 
 } //for
}

void TrailingAlls(int trail)
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
  if(OrderType()==OP_BUY)
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
  if(OrderType()==OP_SELL)
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
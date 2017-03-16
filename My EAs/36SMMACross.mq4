//+------------------------------------------------------------------+
//|                                                  36SMMACross.mq4 |
//|                                                     David J. Lin |
//|                                           d-lin@northwestern.edu |
//+------------------------------------------------------------------+
#property copyright "David J. Lin"
#property link      ""

extern int Account=0;
extern double Lots=1.0;
extern int Slippage=3;
extern int StopLoss=0;
extern int TrailingStop=0;
extern int TakeProfit=0;

extern int MAFastPeriod=3;
extern int MAFastShift=0;
extern int MAFastMethod=MODE_SMMA;
extern int MAFastPrice=PRICE_CLOSE;

extern int MASlowPeriod=6;
extern int MASlowShift=0;
extern int MASlowMethod=MODE_SMMA;
extern int MASlowPrice=PRICE_CLOSE;

datetime timeprev=0;

int init()
{
 return(0);
}

int deinit()
{
 return(0);
}

int start()
{

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

//
//Long 
//
 if(fast1>slow1&&fast2<slow2)
 {
  CloseShorts();
  OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,StopLong(Ask,StopLoss),TakeLong(Ask,TakeProfit),NULL,0,0,Blue);
 }//Long 
 
//
//Short 
//
 if(fast1<slow1&&fast2>slow2)
 {
  CloseLongs();
  OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,StopShort(Bid,StopLoss),TakeShort(Bid,TakeProfit),NULL,0,0,Red);
 }//Shrt
 
return(0);
}

double StopLong(double price,int stop)
{
 if(stop==0)
  return(0.0); // if no stop loss
 return(price-(stop*Point)); 
             // minus, since the stop loss is below us for long positions
             // Point is 0.01 or 0.001 depending on currency, so stop*POINT is a way to convert pips into price with multiplication 
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

// NewsMatthewNyguen.mq4 
               
// based on a straddle strategy created by Matthew Nguyen (matthew@activeone.com)
// coded by David J. Lin (d-lin@northwestern.edu), Evanston, IL, August 13, 2006 

#property copyright "David J. Lin, 2006"

extern int hour=12;
extern int minute=28;
extern int expire=660;
extern int Account=17046;
extern int Buy = 7;
extern int Sell = 7;
extern double Lots=1.0;
extern int Slippage=0;
extern int StopLoss=0;
extern int TrailingStop=0;
extern int TakeProfit=0;

bool runnable=true;
bool init=true;
bool orders=false;

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

  if(IsTesting()==false&&Account!=AccountNumber())
  {
   runnable=false;
   Alert("*** WARNING: Please check Account Number! ***");
   return(-1);
  }
 }//Init

//Trailing Stop
 TrailingAlls(TrailingStop); 
    
// Trade at only certain times (before news releases)
// place the straddle 2 minutes before the hour:

 if (orders==false)
 {
  if(Hour()==hour&&Minute()==minute)
  {
// determine expiration
   datetime expiration = Time[0]+expire;

//Immediately straddle the trade:
  double entry = Ask+(Buy*Point);
  OrderSend(Symbol(),OP_BUYSTOP,Lots,entry,Slippage,StopLong(entry,StopLoss),TakeLong(entry,TakeProfit),NULL,1,expiration,Blue);
      entry = Bid-(Sell*Point);
  OrderSend(Symbol(),OP_SELLSTOP,Lots,entry,Slippage,StopShort(entry,StopLoss),TakeShort(entry,TakeProfit),NULL,2,expiration,Red); 
   orders=true;
  }
 }
 else
 {
  if (OrdersTotal()==0)
   orders=false;
 }
return(0);
}

//===========================================================================================
//===========================================================================================


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
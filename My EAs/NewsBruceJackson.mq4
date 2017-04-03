
// NewsBruceJackson.mq4 
               
// based on a straddle/hedge strategy created by Bruce Jackson (wmbjackson@verizon.net)
// coded by David J. Lin (d-lin@northwestern.edu), Evanston, IL, August 9, 2006 

#property copyright "David J. Lin, 2006"

extern int hour=13;
extern int minute=55;
extern int Account=0;
extern double Lots=1.0;
extern int Slippage=99;
extern int StopLoss=10;
extern int TrailingStop=0;
extern int TakeProfit=60;

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

  if(IsTesting()==false&&Account!=AccountNumber())
  {
   runnable=false;
   Alert("*** WARNING: Please check Account Number! ***");
   return(-1);
  }
 }//Init

//Trailing Stop
 TrailingAlls(TrailingStop); 
  
  if (OrdersTotal()==0) 
  {
// Trade at only certain times (before news releases)
// place the straddle 5 minutes before the hour:
   if(TimeHour(CurTime())==hour&&TimeMinute(CurTime())==minute)
   {
//
//Immediately straddle the trade:
// Enter Long: 
     OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,StopLong(Ask,StopLoss),TakeLong(Ask,TakeProfit),NULL,0,0,Blue);
     OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,StopShort(Bid,StopLoss),TakeShort(Bid,TakeProfit),NULL,0,0,Red); 
    }
   } 
  else 
//
//Exit all trades 23:59 after entry, if any trades are still open
//
  {
   OrderSelect(0,SELECT_BY_POS);
   
   int exitday = TimeDayOfWeek(OrderOpenTime())+1;
   if(exitday == 6)
      exitday = 0; 
         
   if(DayOfWeek()==exitday&&TimeHour(CurTime())==hour&&TimeMinute(CurTime())==(minute-1))
   {
    CloseLongs();
    CloseShorts(); 
   }
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
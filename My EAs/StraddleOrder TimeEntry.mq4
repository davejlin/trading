
// StraddleOrder.mq4 

// This "initiator" EA applies a straddle buy-sell stops upon application.
// Double straddle applied if Lots2 is set to non-zero values.

// coded by David J. Lin (dave.j.lin@sbcglobal.net), Evanston, IL, August 19, 2006 

#property copyright "David J. Lin, 2006"

//extern int Account=0;

extern int hour=13;
extern int minute=55;

extern int Buy1 = 15;
extern int Sell1 = 15;

extern int Buy2 = 30;
extern int Sell2 = 30;

extern double Lots1=10.0;
extern double Lots2= 0.0;
extern int StopLoss1=0;
extern int StopLoss2=0;
extern int TakeProfit1=25;
extern int TakeProfit2=25;

extern int Slippage=0;

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
 if(!runnable)
  return(-1);
  
//Init
 if(init==true)
 {
  init=false;

//  if(IsTesting()==false&&Account!=AccountNumber())
//  {
//   runnable=false;
//   Alert("*** WARNING: Please check Account Number! ***");
//   return(-1);
//  }

 }//Init
 
 if (!orders)
 { 

// Trade at only certain times (before news releases)
// place the straddle 5 minutes before the hour:
   if(TimeHour(CurTime())==hour&&TimeMinute(CurTime())==minute)
   {

//Immediately straddle the trade:
   double entry = Ask+(Buy1*Point);
   OrderSend(Symbol(),OP_BUYSTOP,Lots1,entry,Slippage,StopLong(entry,StopLoss1),TakeLong(entry,TakeProfit1),NULL,1,0,Blue);
          entry = Bid-(Sell1*Point);
   OrderSend(Symbol(),OP_SELLSTOP,Lots1,entry,Slippage,StopShort(entry,StopLoss1),TakeShort(entry,TakeProfit1),NULL,2,0,Red); 
  
   if (Lots2!=0.0)
   {
       entry = Ask+(Buy2*Point);
    OrderSend(Symbol(),OP_BUYSTOP,Lots2,entry,Slippage,StopLong(entry,StopLoss2),TakeLong(entry,TakeProfit2),NULL,3,0,Green);
       entry = Bid-(Sell2*Point);
    OrderSend(Symbol(),OP_SELLSTOP,Lots2,entry,Slippage,StopShort(entry,StopLoss2),TakeShort(entry,TakeProfit2),NULL,4,0,Orange); 
   }

   orders=true;
  }
 }

return(-1);
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


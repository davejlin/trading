//+------------------------------------------------------------------+
//|                                                  OrderSubmit.mq4 |
//|                                                     David J. Lin |
//| Submits orders at a specific date/time (GMT)                     |
//| Written for Mark A. Schlman maschulman@msn.com                   |
//|                                                                  |
//| Coded by David J. Lin                                            |
//| d-lin@northwestern.edu                                           |
//| December 23, 2006                                                |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "David J. Lin"
#property link      ""

//---- input parameters
extern datetime  DateTimeGMT=D'2007.01.01 14:00'; // date-time to trigger order
extern double    FreeMarginMin=100.00;            // free-margin above which to trade
extern int       BuySell=0;                       // 0=buy, 1=sell
extern double    Lots=1.00;                       // number of lots
extern int       TakeProfit=0;                    // pips take-profit, 0=none
extern int       StopLoss=0;                      // pips stop-loss, 0=none
extern int       Slippage=3;                      // pips slippage allowed
double price,SL,TP;
bool sent=false;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
     
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
   if(TimeCurrent()<DateTimeGMT||AccountFreeMargin()<FreeMarginMin||sent)
    return(0);

   switch(BuySell)
   {
    case 0:
     price = Ask;
     SL = StopLong(price,StopLoss);
     TP = TakeLong(price,TakeProfit);
     break;
    case 1:
     price = Bid;
     SL = StopShort(price,StopLoss);
     TP = TakeShort(price,TakeProfit);
     break;
   }
    
   OrderSend(Symbol(),BuySell,NormalizeDouble(Lots,2),NormalizeDouble(price,Digits),Slippage,NormalizeDouble(SL,Digits),NormalizeDouble(TP,Digits));
   sent=true;

//----
   return(0);
  }
//+------------------------------------------------------------------+

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


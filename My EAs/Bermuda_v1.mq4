
// Bermuda_v1.mq4 

// This EA executes the simplest Bermuda method, version 1.

// coded by David J. Lin (d-lin@northwestern.edu), Evanston, IL, September 6, 2006 

#property copyright "David J. Lin, 2006"

extern double N=8;         // pips to trigger alert
extern double Lots=25.0;    // lots to trade
extern double TP=5;         // pips take profit (no minimum)
extern double SL=7;        // pips stop loss (no minimum)
extern double Safety=3;     // pips minimum profit (once the trade is profitable by Safety+1)
extern double Buffer=5;     // pips above/below Bid at time of trigger to determine whether prices are still moving in impulse direction
extern int Slippage=2;      // pips slippage (recommended > 2)
extern int WaitTime=10000;  // milliseconds to pause after trigger to access post-impulse price direction
extern int CutTime=180;     // seconds after which to cancel/close orders

bool flag_check=true;       // flag to check whether or not to place orders
bool flag_safety=true;      // flag to check safety (to take minimum profit once in green)

int magic = 2345;           // magic number to keep track of order by this EA

int init()
{
 return(0);
}

int deinit()
{
// int trade;                  // dummy variable to cycle through trades
// int trades=OrdersTotal();  // total number of pending/open orders
// for(trade=0;trade<trades;trade++)
// {
//  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES); 
//  if(OrderSymbol()!=Symbol())
//  continue;

//  if(OrderType()==OP_BUYSTOP || OrderType()==OP_SELLSTOP)
//  {
//    OrderDelete(OrderTicket()); // CutTime time limit to this Limit order
//    Comment("Pending order deleted due to EA exit");
//  }
// } 
 return(0);
}

//===========================================================================================
//===========================================================================================

int start()
{
 OrderStatus(); 
 if(flag_check) 
  CheckTrigger();
 else // Monitor Open Orders  
  MonitorOrders();
}

//===========================================================================================
//===========================================================================================

void OrderStatus()
{
 int trade;                  // dummy variable to cycle through trades
 int trades=OrdersTotal();  // total number of pending/open orders
 flag_check=true; // first assume we have no open/pending orders
 for(trade=0;trade<trades;trade++)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES); 
  if(OrderSymbol()==Symbol()&&OrderMagicNumber()==magic)
   flag_check=false; // deselect flag_check if there are open/pending orders for this pair
 }
return(0);
}

//===========================================================================================
//===========================================================================================

void CheckTrigger()
{
  double takeprofit;                    // dummy variable to calculate ticket takeprofit
  double TPO;                           // dummy variable=TP+1.0 (backup takeprofit associated with ticket) 
  double price;                         // dummy variable to calculate order prices
  double prevclose = iClose(NULL,0,1);  // reference baseline to compare current Bid
  double Bidp = Bid;                    // keep track of triggered Bid to gage price direction
  double Askp = Ask;                    // keep track of triggered Ask
  double diff = (Bidp-prevclose)/Point; // pip difference which is monitored for the trigger
  double spread = (Ask-Bid)/Point;      // current spread

//  Comment("Prev Close: ",prevclose," Current Bid: ",Bid," Pip Diff: ",diff);

  Comment(" Spread: ",spread, ", Pip Diff: ",diff);

  if(MathAbs(diff) > N) 
  { 
   Alert("BERMUDA ALERT!! for ",Symbol()," at ",TimeToStr(CurTime())," Pip Diff: ",diff);
   Sleep(WaitTime);
   RefreshRates();
   TPO=TP+1.0;
   
   if(diff < 0.0)  // prices spiking down
   {
    price = Bidp-(Buffer*Point);
    if(Bid < price) // prices still 5 pips below trigger price
    {
     price=Askp;
//     takeprofit=price+(TPO*Point); // as a backup for manual t/p below
     takeprofit=0.0;
     OrderSend(Symbol(),OP_BUYSTOP,Lots,price,Slippage,0.0,takeprofit,NULL,magic,0,Blue);     
    }
    else // prices retracing
    {
     price = Ask;
//     takeprofit=price+(TPO*Point); // as a backup for manual t/p below 
     takeprofit=0.0;
     OrderSend(Symbol(),OP_BUY,Lots,price,Slippage,0.0,takeprofit,NULL,magic,0,Blue);
    }
   }
   else // prices spiking up
   {
    price=Bidp+(Buffer*Point);
    if(Bid > price) // prices still rising
    {
     price = Bidp;
//     takeprofit=price-(TPO*Point); // as a backup for manual t/p below
     takeprofit=0.0;
     OrderSend(Symbol(),OP_SELLSTOP,Lots,price,Slippage,0.0,takeprofit,NULL,magic,0,Red);
    }
    else // prices retracing
    {
     price = Bid; 
//     takeprofit=price-(TPO*Point); // as a backup for manual t/p below
     takeprofit=0.0;
     OrderSend(Symbol(),OP_SELL,Lots,price,Slippage,0.0,takeprofit,NULL,magic,0,Red);
    }
   } 
// PlaySound("trumpets.wav");
  }
  flag_safety=true;
return(0);
}

//===========================================================================================
//===========================================================================================

void MonitorOrders()
{
 int trade;                  // dummy variable to cycle through trades
 int trades=OrdersTotal();  // total number of pending/open orders
 int TradeTime;              // number of seconds remaining before cancel order
 double price;               // dummy variable to calculate order prices
 datetime OrderTime;         // time order is submitted
 double OrderPrice;          // price of order
 
 for(trade=0;trade<trades;trade++)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES); 
  if(OrderSymbol()==Symbol()||OrderMagicNumber()==magic)
  {

   OrderTime=OrderOpenTime();
  
   if(OrderType()==OP_BUYSTOP || OrderType()==OP_SELLSTOP)
   {
    TradeTime=CutTime-(CurTime()-OrderTime);  
    if(TradeTime<0)
    {
     OrderDelete(OrderTicket()); // CutTime time limit to this Limit order
     Comment("Pending order deleted due to timeout");
    }
    Comment("Bermuda Alert!! PEND. Time remaining: ", TradeTime);
   } 
   
   if(OrderType()==OP_BUY)
   {
    TradeTime=CurTime()-OrderTime;
    Comment("Bermuda Alert!! BUY.  Order open for ",TradeTime, " sec.");
   
    OrderPrice = OrderOpenPrice();
    price=(Bid-OrderPrice);
   
    if(price<=(-SL*Point))  // manual stop loss
    {
     OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Blue); // close out order to ensure Safety pips profit
     Comment("Manual Stop-Loss hit!!  Order was open for ",TradeTime, " sec.");
    }
   
    if(flag_safety)
    {
     if(price>=((Safety+1)*Point))
      flag_safety=false; // trip flag once profitable by Safety+1 pips
    } 
    else
    {
     if(price<(Safety*Point) || price>=(TP*Point))
     {
      OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Blue); // close out order to ensure Safety pips profit
     } 
     Comment("Bermuda Alert!! BUY-Safety. Order open for ",TradeTime, " sec.");
    }
  
//   if(TradeTime<0)
//   {
//    OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Blue); // CutTime time limit to this Limit order
//    Comment("Buy order closed due to timeout!!");
//   }
   }
   
   if(OrderType()==OP_SELL)
   {
    TradeTime=CurTime()-OrderTime;
    Comment("Bermuda Alert!! SELL.  Order open for ",TradeTime, " sec.");

    OrderPrice = OrderOpenPrice();
    price=(OrderPrice-Ask);
   
    if(price<=(-SL*Point))  // manual stop loss 
    {
     OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Red);  // close out order to satisfy stop/loss 
     Comment("Manual Stop-Loss hit!! Order was open for ",TradeTime, " sec.");   
    }

    if(flag_safety)
    {
     if(price>=((Safety+1)*Point))
      flag_safety=false; // trip flag once profitable 
    } 
    else
    {
     if(price<(Safety*Point)|| price>=(TP*Point))
     {
      OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Red);  // close out order to ensure Safety pips profit
     }
     Comment("Bermuda Alert!! SELL-Safety.  Order open for ",TradeTime, " sec.");
    }

//   if(TradeTime<0)
//   {
//    OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Red); // CutTime time limit to this Limit order
//    Comment("Sell order closed due to timeout");
//   }
   }
  }  
 }
 return(0);
}

//===========================================================================================
//===========================================================================================


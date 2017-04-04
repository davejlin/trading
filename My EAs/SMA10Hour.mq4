//+------------------------------------------------------------------+
//|                                                    SMA10Hour.mq4 |
//|                                     Wittys 10hour SMA hypothosis |
//|                                         code by Zonker the Troll |
//|                                        http://www.greenpeace.org |
//+------------------------------------------------------------------+
#property copyright "General Public License"
#property link      "http://www.greenpeace.org"//You can't sink a rainbow!


int init() { return(0);}
int deinit() { return(0);}
  
//+ User Variables ++++++++++++++++++++++++++++++++++++++++++++++++++++

double Lots = 1;//Number of lots to buy/sell on each trade
double halfLot = 0.5; //Amount to sell when takeProfit is reached.
int slippage = 1;
double trailingStop = 30; //Trailing stop for selling second half of trade
double takeProfit = 30;  //Take Profit for first half of trade
int buyIn = 25;

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


datetime tradeTime=0;   
bool blockBuy = false;
bool blockSell = false;

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
   double SMA2;
   double SMA1;
   double current;
   double stoploss;
   
   ManageOpenTrades();  

   //block buying a second trade in the same direction until 3hours has passed.
   if(CurTime() - tradeTime > 10800)
   {  blockBuy = false;
      blockSell = false;
   }
   
   //Blocking trading at 14:00gmt seems to improve things..
  // if(TimeHour(CurTime()) == 14) return(0);
   
   //Don't trade if we run out of money!
   if(AccountFreeMargin()<(1000*Lots)) return(0);          
 
   SMA2 = iMA(NULL,0,10,0,MODE_SMA, PRICE_CLOSE,2);
   SMA1 = iMA(NULL,0,10,0,MODE_SMA, PRICE_CLOSE,1);
   current = iMA(NULL,0,10,0,MODE_SMA, PRICE_CLOSE,0);

   //Open trade if entry signal is present     
   if((SMA2 < Close[2] || SMA1 < Close[1]) && (SMA1 - Close[0]) >= buyIn*Point && blockSell==false)
   {  if(SMA1 < Close[1]) stoploss = Close[1];
      else stoploss = Close[2];
      if(High[0] > stoploss) stoploss = High[0];
      if(OrderSend(Symbol(),OP_SELL,Lots,Bid,slippage,stoploss,0,"In Witty we trust",123,0,Red)!=-1)
      {  tradeTime = CurTime();
         blockBuy = false;
         blockSell = true;
      }
   } 
   if((SMA2 > Close[2] || SMA1 > Close[1]) && (Close[0] - SMA1) >= buyIn*Point && blockBuy==false)
   {  if(SMA1 > Close[1]) stoploss = Close[1];
      else stoploss = Close[2];
      if(Low[0] < stoploss) stoploss = Low[0];
      if(OrderSend(Symbol(),OP_BUY,Lots,Ask,slippage,stoploss,0,"In Witty we trust",123,0,Blue)!=-1)
      {  tradeTime = CurTime();
         blockBuy = true;
         blockSell = false;
      }
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+
// Sell first half of trade and sets trailing stop for second half
int ManageOpenTrades()
{  int cnt,totalOrders;  

   totalOrders = OrdersTotal();
   for(cnt = 0; cnt < totalOrders; cnt++) 
   {  OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);  

      //Sell first half of trade if take profit is reached   
      if(OrderLots() == Lots && halfLot > 0.0)
      {  if(OrderType() == OP_SELL)
         { if((OrderOpenPrice() - Ask) >=takeProfit*Point)
              OrderClose(OrderTicket(),halfLot,Ask,slippage,Red);   
         }
         else
         { if((Bid - OrderOpenPrice()) >=takeProfit*Point)
              OrderClose(OrderTicket(),halfLot,Bid,slippage,Blue); 
         } 
      }
     
      //Set trailing stop for second half of trade
      if(OrderLots() < Lots || halfLot == 0.0)
      {  if(OrderType() == OP_SELL)
         {  if((OrderOpenPrice()-Ask) > (trailingStop*Point) && (OrderStopLoss()-Ask) > (trailingStop*Point))
               OrderModify(OrderTicket(),OrderOpenPrice(),Ask+trailingStop*Point,OrderTakeProfit(),0,Red);
         }
         else
         {  if((Bid-OrderOpenPrice()) > (trailingStop*Point) && (Bid-OrderStopLoss()) > (trailingStop*Point))
               OrderModify(OrderTicket(),OrderOpenPrice(),Bid-trailingStop*Point,OrderTakeProfit(),0,Blue);
         }
      }
   }
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                    SMA10Hour.mq4 |
//|                                     Wittys 10hour SMA hypothosis |
//|                                         code by Zonker the Troll |
//|                                        http://www.greenpeace.org |
//+------------------------------------------------------------------+
#property copyright "General Public License"
#property link      "http://www.greenpeace.org"


int init() { return(0);}
int deinit() { return(0);}
  
//+ User Variables ++++++++++++++++++++++++++++++++++++++++++++++++++++

double Lots = 2;//Number of lots to buy/sell on each trade
double halfLot = 1; //Amount to sell when takeProfit is reached.
int slippage = 1;
//double trailingStop = 30; //Trailing stop for selling second half of trade
double takeProfit = 50;  //Take Profit for first half of trade
int buyIn = 145;

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

int myMagic = 439281;
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
   double stoploss;
   
   double Price2hr;
   double Price1hr;   
   double PriceHigh;
   double PriceLow;
   int i;
   int totalBars;
   bool crossFound;
   double crossPrice;

   int cnt,totalOrders;  

   
   ManageOpenTrades();  

   //block buying a second trade in the same direction until 3days has passed.
   if(CurTime() - tradeTime > 3600*24*3)
   {  blockBuy = false;
      blockSell = false;
      tradeTime = 0;
   }
   
   //Blocking trading at 14:00gmt seems to improve things..
  // if(TimeHour(CurTime()) == 14) return(0);
   
   //Don't trade if we run out of money!
   if(AccountFreeMargin()<(1000*Lots)) return(0);          
 
     


   totalOrders = OrdersTotal();
   for(cnt = 0; cnt < totalOrders; cnt++) 
   {  OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);  
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == myMagic) return(0);
   }

 totalBars = Bars;
   crossFound = false;
   
   if(Close[0] > iMA(NULL,PERIOD_D1,10,0,MODE_SMA, PRICE_CLOSE,0))
   {  for(i=1;i<totalBars;i++)
      {  
         if(iClose(NULL,PERIOD_D1,i) < iMA(NULL,PERIOD_D1,10,0,MODE_SMA, PRICE_CLOSE,i))
         {  crossFound = true;
            break;
         }
      }
      if(crossFound == false) return(0);
     
      crossPrice = (iMA(NULL,PERIOD_D1,10,0,MODE_SMA, PRICE_CLOSE,i)+ iMA(NULL,PERIOD_D1,10,0,MODE_SMA, PRICE_CLOSE,i-1))/2.0;
      stoploss = iLow(NULL,PERIOD_D1,i);
      //Print("close: ",Close[0]," cross: ",crossPrice, " diff: ",Close[0]-crossPrice);
      if(Close[0] - crossPrice >= buyIn*Point)   
      {  if(OrderSend(Symbol(),OP_BUY,Lots,Ask,slippage,stoploss,0,"In Witty we trust",myMagic,0,Blue)!=-1)
           tradeTime = CurTime();
      }     
   }
   else
   {  for(i=1;i<totalBars;i++)
      {  
         if(iClose(NULL,PERIOD_D1,i) > iMA(NULL,PERIOD_D1,10,0,MODE_SMA, PRICE_CLOSE,i))
         {  crossFound = true;
            break;
         }
      }
      if(crossFound == false) return(0);
      crossPrice = (iMA(NULL,PERIOD_D1,10,0,MODE_SMA, PRICE_CLOSE,i)+ iMA(NULL,PERIOD_D1,10,0,MODE_SMA, PRICE_CLOSE,i-1))/2;
      stoploss = iHigh(NULL,PERIOD_D1,i);
  
      
      if(crossPrice - Close[0] >= buyIn*Point)   
      {  if(OrderSend(Symbol(),OP_SELL,Lots,Bid,slippage,stoploss,0,"In Witty we trust",myMagic,0,Red)!=-1)
           tradeTime = CurTime();
         Print(crossPrice," ",stoploss," ",buyIn," ",Close[0]," ",i);   
         Print(iMA(NULL,PERIOD_D1,10,0,MODE_SMA, PRICE_CLOSE,i));
      }     
   } 
 
   return(0);
  }
//+------------------------------------------------------------------+
// Sell first half of trade and sets trailing stop for second half
int ManageOpenTrades()
{  int cnt,totalOrders;  

   totalOrders = OrdersTotal();
   for(cnt = 0; cnt < totalOrders; cnt++) 
   {  OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);  
      
      if(OrderSymbol() != Symbol()) continue;
      if(OrderMagicNumber() != myMagic) continue;
      
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
         {  if(iMA(NULL,PERIOD_D1,10,0,MODE_SMA, PRICE_CLOSE,1)<iClose(NULL,PERIOD_D1,1))
               OrderClose(OrderTicket(),OrderLots(),Ask,slippage,Red);
         }
         else
         {  if(iMA(NULL,PERIOD_D1,10,0,MODE_SMA, PRICE_CLOSE,1)>iClose(NULL,PERIOD_D1,1))
               OrderClose(OrderTicket(),OrderLots(),Bid,slippage,Red); 
         }
      }
   }
}
//+------------------------------------------------------------------+
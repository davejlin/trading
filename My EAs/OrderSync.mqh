//+------------------------------------------------------------------+
//|                                                    OrderSync.mqh |
//|                                                     David J. Lin |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "David J. Lin"
#property link      ""

string synch="SYNCH";
//===========================================================================================
//===========================================================================================

int OrderSendSync(string sym, int type, double vol, double price, int slip, double sl, double tp, string comment="", int magic=0, datetime exp=0, color cl=CLR_NONE)
{  
 GetSynch();
 for(int s=0;s<5;s++)
 {  
  if(OrderSend(sym,type,NormalizeDouble(vol,2),NormalizeDouble(price,Digits),slip,NormalizeDouble(sl,Digits),NormalizeDouble(tp,Digits),comment,magic,exp,cl)<0)
  {  
   Print("OrderSend Long failed, Error: ", GetLastError(), " Magic Number: ", magic);
   Print("Price: ", price, " S/L ", sl, " T/P ", tp);
   if(GetLastError()>4000) break;
   RefreshRates();
  }
  else break;
 }
 ReleaseSynch();
}

//===========================================================================================
//===========================================================================================

bool OrderCloseSync(int ticket, double lots, double price, int slip, color cl=CLR_NONE)
{
 GetSynch();
 for(int c=0;c<10;c++)
 {
  if(!OrderClose(ticket,NormalizeDouble(lots,2),NormalizeDouble(price,Digits),slip,cl))
  {  
   Print("OrderClose long failed, Error: ", GetLastError(), " Ticket #: ", ticket);
   Print("Price: ", price);   
   if(GetLastError()>4000) break;
   RefreshRates();
  }
  else break;
 }
 ReleaseSynch();
} 

//===========================================================================================
//===========================================================================================

bool OrderModifySync(int ticket, double price, double sl, double tp, datetime exp, color cl=CLR_NONE)
{ 
 GetSynch();
 if(OrderModify(ticket,price,sl,tp,exp,cl)==false)
 {  
  Print("OrderModify Error: ",GetLastError(), " Ticket: ", ticket);
  Print("Old price: ", OrderOpenPrice(), " Old S/L ", OrderStopLoss(), " Old T/P ", OrderTakeProfit(), " Ask/Bid ",Ask,", ",Bid);
  Print(" New Price: ", price, " New S/L ", sl, " New T/P ", tp, " New Expiration ", exp);
 }
 ReleaseSynch();
}

//===========================================================================================
//===========================================================================================

bool GetSynch()
{  
 while(!IsStopped())
 {  
  if(GlobalVariableSetOnCondition(synch,1,0)==true) break;
  Sleep(1000);
 }
 return(true);
}
//===========================================================================================
//===========================================================================================

bool ReleaseSynch()
{  
 GlobalVariableSet(synch,0);
 return(true);
}

//===========================================================================================
//===========================================================================================
void HalfExit(int target, double fraction, double origLots)
{
  double profit;
  double halflots=fraction*OrderLots();
  double targetpoints=NormalizeDouble(target*Point,Digits);

 for(int i=OrdersTotal();i>=0;i--)
 {

  OrderSelect(i,SELECT_BY_POS);

  if(OrderSymbol() != Symbol())
   continue;

  if(OrderLots()!=origLots)
   continue;
   
  if(OrderType()==OP_BUY)
  {
   profit=(Bid-OrderOpenPrice());
   if(profit>=targetpoints)
    OrderCloseSync(OrderTicket(), halflots, Bid, Slippage, White);
  } 
  else if(OrderType()==OP_SELL)
  {
   profit=(OrderOpenPrice()-Ask);
   if(profit>=targetpoints)
    OrderCloseSync(OrderTicket(), halflots, Ask, Slippage, White);
  } 
  
 }
 return;
}
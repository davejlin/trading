//+----------------------------------------------------------------------+
//|                                                        2ndSkiesA.mq4 |
//|                                                         David J. Lin |
//|Based on an Ichimoku strategy                                         |
//|by Chris Capre, 2ndSkies.com (Info@2ndSkies.com)                      |
//|Coded by David J. Lin (dave.j.lin@sbcglobal.net)                      |
//|Evanston, IL, November 29, 2008                                       |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2008, Chris Capre & David J. Lin"
#property link      "2ndSkies.com"

// Internal usage parameters:
extern double LotsPerPosition=1.0; // fixed-lots per position
//double LotsPercentage=0.01; // lottage based on percentage of equity per position 
int    Break=120;            // pips beyond cloud to trigger 
int    StopLoss=120;         // pips beyond cloud SL
int    TakeProfit1=350;      // M30 TP
int    TakeProfit2=450;      // H1  TP
int    Trail=150;            // pips trail behind kijun
int    FixedStop=0;         // move SL 2nd order

int    lotlimit1=1500;       // if SL more than this, cut lottage to 1/2
int    lotlimit2=2000;       // if SL more than this, cut lottage to 1/3

double EquityMax=0.05;      // maximum equity percentage exposure

int tenkan=9;               // Ichimoku tenkan period
int kijun=26;               // Ichimoku kijun period
int senkou=52;              // Ichimoku senkou period

double lotsmin,lotsmax;
int lotsprecision,TakeProfit;
bool orderlong,ordershort;
int Slippage=2;
int Magic1,Magic2;
datetime ots,otl,lasttime,lastM1,starttime,lastLong,lastShort;
string comment1,comment2;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//---- 
 starttime=TimeCurrent();
 lotsmin=MarketInfo(Symbol(),MODE_MINLOT); 
 lotsmax=MarketInfo(Symbol(),MODE_MAXLOT); 
 
 comment1=StringConcatenate("2SA1 ",DoubleToStr(Period(),0)," ",Symbol());
 comment2=StringConcatenate("2SA2 ",DoubleToStr(Period(),0)," ",Symbol());
 
 Magic1=71+Period();
 Magic2=72+Period();
 
 if(lotsmin==1)         lotsprecision=0;
 else if(lotsmin==0.50) lotsprecision=1; // for PFG ECN
 else if(lotsmin==0.10) lotsprecision=1;
 else if(lotsmin==0.01) lotsprecision=2;
 else                   lotsprecision=1;

 if(Period()<=30) TakeProfit=TakeProfit1;
 else             TakeProfit=TakeProfit2;
 
// First check closed trades
 int trade;                         
 int trades=OrdersHistoryTotal();           
 for(trade=0;trade<trades;trade++)   // The most recent closed order has the largest position number, so this works forward
                                     // to allow the values of the most recent closed orders to be the ones which are recorded
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_HISTORY);

  if(OrderSymbol()!=Symbol()) continue;
  if(OrderMagicNumber()==Magic1||OrderMagicNumber()==Magic2)
  {
//  int D1bars=iBarShift(NULL,PERIOD_D1,OrderCloseTime(),false);  // time difference in days
//  if(D1bars>60) // = only interested in recently closed trades
//   continue;
   Status(OrderMagicNumber());
   DrawCross(false);
  }
 }

// Now check open orders
 orderlong=false; ordershort=false; //reset flags
     
 trades=OrdersTotal();           
 for(trade=0;trade<trades;trade++)// The most recent closed order has the largest position number, so this works forward
                                  // to allow the values of the most recent closed orders to be the ones which are recorded

 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderMagicNumber()==Magic1||OrderMagicNumber()==Magic2)
  {
   Status(OrderMagicNumber());
   DrawCross(true);
  }
 }
 
// HideTestIndicators(true);  
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
 Main();
 ManageOrders(); 
 lasttime=iTime(NULL,0,0);
 lastM1=iTime(NULL,PERIOD_M1,0);
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert utility functions                                         |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void Main()
{ 
// if(orderlong||ordershort) return;
// if(lastM1==iTime(NULL,PERIOD_M1,0)) return;
 double Lots,SL,TP,senkouA,senkouB,cloudhi,cloudlo;
 string td;
 
 senkouA=iIchimoku(NULL,0,tenkan,kijun,senkou,MODE_SENKOUSPANA,0);
 senkouB=iIchimoku(NULL,0,tenkan,kijun,senkou,MODE_SENKOUSPANB,0);
 
 cloudhi=MathMax(senkouA,senkouB);
 cloudlo=MathMin(senkouA,senkouB);

 if(Bid>=NormDigits(cloudhi+NormPoints(Break)))
 { 
  if(iBarShift(NULL,0,otl,false)>0)
  {
   if(filter(true))
   {
    SL=StopLong(cloudlo,StopLoss);
    TP=TakeLong(Ask,TakeProfit);  
    
    //Lots=DetermineLots(Ask,SL,2,LotsPercentage); // equity-based lots
    Lots=LotsPerPosition;
    Lots=AdjustLots(Ask,SL,Lots);

    SendOrderLong(Symbol(),Lots,Slippage,0,0,comment1,Magic1);
    SendOrderLong(Symbol(),Lots,Slippage,0,0,comment2,Magic2);    
    otl=TimeCurrent();
    td=TimeToStr(otl,TIME_DATE|TIME_MINUTES);
    Alert("2ndSkiesA enter long: ",Symbol()," M",Period()," at",td);
    AddSLTP(SL,TP);
   }
  }
 }
 else if(Bid<=NormDigits(cloudlo-NormPoints(Break)))
 { 
  if(iBarShift(NULL,0,ots,false)>0)
  { 
   if(filter(false))
   {
    SL=StopShort(cloudhi,StopLoss);
    TP=TakeShort(Bid,TakeProfit);

    //Lots=DetermineLots(SL,Bid,2,LotsPercentage); // equity-based lots
    Lots=LotsPerPosition;
    Lots=AdjustLots(SL,Bid,Lots);
   
    SendOrderShort(Symbol(),Lots,Slippage,0,0,comment1,Magic1);
    SendOrderShort(Symbol(),Lots,Slippage,0,0,comment2,Magic2);    
    ots=TimeCurrent();
    td=TimeToStr(ots,TIME_DATE|TIME_MINUTES);
    Alert("2ndSkiesA enter short: ",Symbol()," M",Period()," at",td);
    AddSLTP(SL,TP);   
   }
  }
 }

 return; 
}
//+------------------------------------------------------------------+

bool filter(bool long)
{
 int Trigger[3], totN=3,i,j,k,trig;
 double value1,senkouA,senkouB,tenkan1,tenkan2,kijun1,kijun2,cloudhi,cloudlo,low,high;
  
 for(i=0;i<totN;i++) Trigger[i]=-1;

 if(long) // long filters
 {
  for(i=0;i<totN;i++)
  {
   switch(i)
   {
    case 0:   
     for(j=0;j<=5000;j++)
     {
      tenkan1=iIchimoku(NULL,0,tenkan,kijun,senkou,MODE_TENKANSEN,j);
      tenkan2=iIchimoku(NULL,0,tenkan,kijun,senkou,MODE_TENKANSEN,j+1);

      kijun1=iIchimoku(NULL,0,tenkan,kijun,senkou,MODE_KIJUNSEN,j);
      kijun2=iIchimoku(NULL,0,tenkan,kijun,senkou,MODE_KIJUNSEN,j+1);     
     
      if(tenkan1<kijun1 && tenkan2>=kijun2) return(false); // negate upon contrary cross since
     
      if(tenkan1>kijun1 && tenkan2<=kijun2)
      { 
       senkouA=NormDigits(0.5*(iIchimoku(NULL,0,tenkan,kijun,senkou,MODE_SENKOUSPANA,j)+iIchimoku(NULL,0,tenkan,kijun,senkou,MODE_SENKOUSPANA,j+1)));
       senkouB=NormDigits(0.5*(iIchimoku(NULL,0,tenkan,kijun,senkou,MODE_SENKOUSPANB,j)+iIchimoku(NULL,0,tenkan,kijun,senkou,MODE_SENKOUSPANB,j+1)));    
          
       cloudlo=MathMin(senkouA,senkouB);       
       
       tenkan1=NormDigits(0.5*(tenkan1+tenkan2));
       kijun1=NormDigits(0.5*(kijun1+kijun2));       
       
       if(tenkan1>cloudlo && kijun1>cloudlo) 
       {
        if(iTime(NULL,0,j)>otl && iTime(NULL,0,j)>starttime ) // take trigger upon new cross only & after start
        {
         Trigger[i]=1;
         trig=j;
         break;
        }
        else return(false); 
       }
      }
     }
    break;
    case 1: // if break below cloud first, negate long trigger
     for(k=0;k<=trig;k++)
     {
      low=iLow(NULL,0,k);
      senkouA=iIchimoku(NULL,0,tenkan,kijun,senkou,MODE_SENKOUSPANA,k);
      senkouB=iIchimoku(NULL,0,tenkan,kijun,senkou,MODE_SENKOUSPANB,k);    
       
      cloudlo=MathMin(senkouA,senkouB);
      if(low<cloudlo) return(false);
     }
     Trigger[i]=1;
    break;   
    case 2:
     CheckClosedOrders();
     if(iTime(NULL,0,trig)>lastLong) Trigger[i]=1;
    break;    
//    case 3:
//     value1=EquityCheck();
//     if(value1>EquityMax) 
//     {
//      Alert("Failed entry: Total exposure ",value1," exceeds percentage equity maximum ",EquityMax);
//      return(false);
//     }
//     Trigger[i]=1;     
//    break;
   }
   if(Trigger[i]<0) return(false);       
  } 
 }
 else // short filters
 {
  for(i=0;i<totN;i++)
  {
   switch(i)
   { 
    case 0:   
     for(j=0;j<=5000;j++)
     {
      tenkan1=iIchimoku(NULL,0,tenkan,kijun,senkou,MODE_TENKANSEN,j);
      tenkan2=iIchimoku(NULL,0,tenkan,kijun,senkou,MODE_TENKANSEN,j+1);

      kijun1=iIchimoku(NULL,0,tenkan,kijun,senkou,MODE_KIJUNSEN,j);
      kijun2=iIchimoku(NULL,0,tenkan,kijun,senkou,MODE_KIJUNSEN,j+1);     

      if(tenkan1>kijun1 && tenkan2<=kijun2) return(false); // negate upon contrary cross since
     
      if(tenkan1<kijun1 && tenkan2>=kijun2)
      { 
       senkouA=NormDigits(0.5*(iIchimoku(NULL,0,tenkan,kijun,senkou,MODE_SENKOUSPANA,j)+iIchimoku(NULL,0,tenkan,kijun,senkou,MODE_SENKOUSPANA,j+1)));
       senkouB=NormDigits(0.5*(iIchimoku(NULL,0,tenkan,kijun,senkou,MODE_SENKOUSPANB,j)+iIchimoku(NULL,0,tenkan,kijun,senkou,MODE_SENKOUSPANB,j+1)));    
       
       cloudhi=MathMax(senkouA,senkouB);       

       tenkan1=NormDigits(0.5*(tenkan1+tenkan2));
       kijun1=NormDigits(0.5*(kijun1+kijun2)); 
       
       if(tenkan1<cloudhi && kijun1<cloudhi) 
       {
        if(iTime(NULL,0,j)>ots && iTime(NULL,0,j)>starttime ) // take trigger upon new cross only & after start
        {
         Trigger[i]=1;
         trig=j;
         break;
        }
        else return(false);  
       }
      }
     }
    break;  
    case 1: // if break above cloud first, negate short trigger
     for(k=0;k<=trig;k++)
     {
      high=iHigh(NULL,0,k);
      senkouA=iIchimoku(NULL,0,tenkan,kijun,senkou,MODE_SENKOUSPANA,k);
      senkouB=iIchimoku(NULL,0,tenkan,kijun,senkou,MODE_SENKOUSPANB,k);    
       
      cloudhi=MathMax(senkouA,senkouB);
      if(high>cloudhi) return(false);
     }
     Trigger[i]=1;
    break;  
    case 2:
     CheckClosedOrders();
     if(iTime(NULL,0,trig)>lastShort) Trigger[i]=1;
    break;       
//    case 3:
//     value1=EquityCheck();
//     if(value1>EquityMax) 
//     {
//      Alert("Failed entry: Total exposure ",value1," exceeds percentage equity maximum ",EquityMax);
//      return(false);
//     }
//     Trigger[i]=1;     
//    break;    
   }
   if(Trigger[i]<0) return(false);    
  }
 }

 return(true);  // no anti-trigger:  so, return true (to order)
}

//+------------------------------------------------------------------+ 

void ManageOrders()
{
 orderlong=false;ordershort=false;
 int magic,trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;

  magic=OrderMagicNumber();
  if(magic==Magic1)
  {
   if(OrderType()==OP_BUY)       orderlong=true; 
   else if(OrderType()==OP_SELL) ordershort=true;

   if(iBarShift(NULL,0,OrderOpenTime(),false)<1) continue;
//    if(lastM1==iTime(NULL,PERIOD_M1,0)) continue;
   IchimokuExit();
    
  }
  else if(magic==Magic2)
  {
   if(OrderType()==OP_BUY)       orderlong=true;     
   else if(OrderType()==OP_SELL) ordershort=true;    

   if(CheckSL()<0)
   {
    FixedStopsB(TakeProfit,FixedStop);
   }
   else 
   {
    KijunTrail();
   }
    
   if(iBarShift(NULL,0,OrderOpenTime(),false)<1) continue;
//   if(lastM1==iTime(NULL,PERIOD_M1,0)) continue;
   IchimokuExit();
  }
 } 
 return;
}

//+------------------------------------------------------------------+
bool ModifyOrder(int ticket, double price, double sl, double tp, datetime exp, color cl=CLR_NONE)
{ 
 GetSemaphore();

 if(OrderModify(ticket,price,sl,tp,exp,cl)==false)
 {  
  Print("OrderModify failed, Error: ",GetLastError(), " Ticket Number: ", ticket);
  Print("Old price: ", OrderOpenPrice(), " Old S/L ", OrderStopLoss(), " Old T/P ", OrderTakeProfit(), " Ask/Bid ",Ask,", ",Bid);
  Print(" New Price: ", price, " New S/L ", sl, " New T/P ", tp, " New Expiration ", exp);
 }
 ReleaseSemaphore();
}
//+------------------------------------------------------------------+
int SendOrderLong(string sym, double vol, int slip, double sl, double tp, string comment="", int magic=0, datetime exp=0, color cl=Blue)
{ 
 int err;
 GetSemaphore();
 for(int z=0;z<5;z++)
 {  
  if(OrderSend(sym,OP_BUY,NormLots(vol),Ask,slip,NormDigits(sl),NormDigits(tp),comment,magic,exp,cl)<0)
  {  
   err = GetLastError();
   Print("OrderSend Long failed, Error: ", err, " Magic Number: ", magic);
   Print("Ask: ", Ask, " S/L ", sl, " T/P ", tp);
   if(err>4000) break;
   RefreshRates();
  }
  else
   break;
 }
 ReleaseSemaphore();
}
//+------------------------------------------------------------------+
int SendOrderShort(string sym, double vol, int slip, double sl, double tp, string comment="", int magic=0, datetime exp=0, color cl=Red)
{  
 int err;
 GetSemaphore();
 for(int z=0;z<5;z++)
 {  
  if(OrderSend(sym,OP_SELL,NormLots(vol),Bid,slip,NormDigits(sl),NormDigits(tp),comment,magic,exp,cl)<0)
  {  
   err = GetLastError();
   Print("OrderSend Short failed, Error: ", err, " Magic Number: ", magic);
   Print("Bid: ", Bid, " S/L ", sl, " T/P ", tp);   
   if(err>4000) break;
   RefreshRates();
  }
  else
   break;
 }
 ReleaseSemaphore();
}
//+------------------------------------------------------------------+
bool CloseOrderLong(int ticket, double lots, int slip, color cl=CLR_NONE)
{
 GetSemaphore();
 for(int z=0;z<10;z++)
 {
  if(!OrderClose(ticket,NormLots(lots),Bid,slip,cl))
  {  
   int err = GetLastError();
   Print("OrderClose Long failed, Error: ", err, " Ticket #: ", ticket);
   Print("Bid: ", Bid);   
   if(err>4000) break;
   RefreshRates();
  }
  else break;
 }
 ReleaseSemaphore();
} 
//+------------------------------------------------------------------+
bool CloseOrderShort(int ticket, double lots, int slip, color cl=CLR_NONE)
{
 GetSemaphore();
 for(int z=0;z<10;z++)
 {
  if(!OrderClose(ticket,NormLots(lots),Ask,slip,cl))
  {  
   int err = GetLastError();
   Print("OrderClose Short failed, Error: ", err, " Ticket #: ", ticket);
   Print("Ask: ", Ask);   
   if(err>4000) break;
   RefreshRates();
  }
  else break;
 }
 ReleaseSemaphore();
} 
//+------------------------------------------------------------------+
bool GetSemaphore()
{  
 if(!GlobalVariableCheck("SEMAPHORE")) GlobalVariableSet("SEMAPHORE",0);
 while(!IsStopped())
 {  
  if(GlobalVariableSetOnCondition("SEMAPHORE",1,0)==true) break;
  Sleep(500);
 }
 return(true);
}
//+------------------------------------------------------------------+
bool ReleaseSemaphore()
{
 GlobalVariableSet("SEMAPHORE",0);
 return(true);
}
//+------------------------------------------------------------------+
double NormPoints(int pips)
{
 return(NormDigits(pips*Point));
}
//+------------------------------------------------------------------+
double NormDigits(double price)
{
 return(NormalizeDouble(price,Digits));
}
//+------------------------------------------------------------------+
double NormLots(double lots)
{
 if(lotsmin==0.50) // for PFG ECN
 {
  int lotmod=lots/lotsmin;
  lots=lotmod*lotsmin; // increments of 0.50 lots
 }
 
 return(MathMax(NormalizeDouble(lotsmin,lotsprecision),NormalizeDouble(lots,lotsprecision)));
}
//+------------------------------------------------------------------+
double AdjustLots(double value1, double value2, double lots)
{
 double SLdiff=NormDigits(value1-value2);
 
 if(SLdiff<=NormPoints(lotlimit1))      return(lots);
 else if(SLdiff<=NormPoints(lotlimit2)) return(NormLots(0.500000*lots));
 else                                   return(NormLots(0.333333*lots));
 
 return(lots);
}
//+------------------------------------------------------------------+
void ExitOrder(bool flag_Long,bool flag_Short,int cancelpending=1)
{
 switch(cancelpending)
 {
  case 1:
   if(OrderType()==OP_BUY&&flag_Long)
    CloseOrderLong(OrderTicket(),OrderLots(),Slippage,Lime);
   else if(OrderType()==OP_SELL&&flag_Short)
    CloseOrderShort(OrderTicket(),OrderLots(),Slippage,Lime);
   break;
  case 2:
   if((OrderType()==OP_BUYSTOP)&&flag_Long)
    OrderDelete(OrderTicket());
   else if((OrderType()==OP_SELLSTOP)&&flag_Short)
    OrderDelete(OrderTicket());
   break;  
 }
 return;
}
//+------------------------------------------------------------------+
void FixedStopsB(int PP,int PFS)
{
 if(PFS<0) return;

 double stopcal;
 double stopcrnt=OrderStopLoss();
 double profitpoint=NormPoints(PP);  
 double profit=DetermineProfit();
//Long               
 if(OrderType()==OP_BUY)
 {
  if(profit>=profitpoint)
  {
   stopcal=TakeLong(OrderOpenPrice(),PFS);
   ModifyCompLong(stopcal,stopcrnt);   
  }
 }    
//Short 
 if(OrderType()==OP_SELL)
 {  
  if(profit>=profitpoint)
  {
   stopcal=TakeShort(OrderOpenPrice(),PFS);
   ModifyCompShort(stopcal,stopcrnt);
  }
 }  
 return(0);
} 
//+------------------------------------------------------------------+
double DetermineProfit()
{
 if(OrderType()==OP_BUY)  
  return(NormDigits(Bid-OrderOpenPrice()));
 else if(OrderType()==OP_SELL)
  return(NormDigits(OrderOpenPrice()-Ask)); 
 
 return(0); 
}
//+------------------------------------------------------------------+
double TakeLong(double price,int take)  // function to calculate takeprofit if long
{
 return(NormDigits(price+NormPoints(take))); 
             // plus, since the take profit is above us for long positions
}
//+------------------------------------------------------------------+
double TakeShort(double price,int take)  // function to calculate takeprofit if short
{
 return(NormDigits(price-NormPoints(take))); 
             // minus, since the take profit is below us for short positions
}
//+------------------------------------------------------------------+
double StopShort(double price,int stop) // function to calculate normal stoploss if short
{
 return(NormDigits(price+NormPoints(stop))); 
             // plus, since the stop loss is above us for short positions
}
//+------------------------------------------------------------------+
double StopLong(double price,int stop) // function to calculate normal stoploss if long
{
 return(NormDigits(price-NormPoints(stop))); 
             // minus, since the stop loss is below us for long positions
             // Point is 0.01 or 0.001 depending on currency, so stop*POINT is a way to convert pips into price with multiplication 
}
//+------------------------------------------------------------------+
double CheckSL()
{
 int type=OrderType();
 
      if(type==OP_BUY)  return( NormDigits(OrderStopLoss()-OrderOpenPrice()) );
 else if(type==OP_SELL) return( NormDigits(OrderOpenPrice()-OrderStopLoss()) );

 return(0.0);
}
//+------------------------------------------------------------------+
void ModifyCompLong(double stopcal, double stopcrnt)
{
 stopcal=NormDigits(stopcal);
 stopcrnt=NormDigits(stopcrnt);

 if (stopcal==stopcrnt) return;
 
 if(stopcal>stopcrnt)
 {
 
  if(stopcal>=Bid) // check whether s/l is too close to market
   return;
                     
  ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Blue); 
 }
 return;
}
//+------------------------------------------------------------------+
void ModifyCompShort(double stopcal, double stopcrnt)
{
 stopcal=NormDigits(stopcal);
 stopcrnt=NormDigits(stopcrnt);

 if (stopcal==stopcrnt) return;
  
 if(stopcrnt==0)
 {

  if(stopcal<=Ask) // check whether s/l is too close to market
   return; 
   
  ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red);     
 }
 else if(stopcal<stopcrnt&&stopcal!=0)
 {

  if(stopcal<=Ask) // check whether s/l is too close to market
   return; 
 
  ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red); 
 }
 return;
}
//+------------------------------------------------------------------+
void Status(int magic)
{
 if(magic==Magic1)
 {
  if(OrderType()==OP_BUY)       
  {
   otl=OrderOpenTime();
   orderlong=true;
  }
  else if(OrderType()==OP_SELL) 
  {
   ots=OrderOpenTime(); 
   ordershort=true;
  }
 }
 else if(magic==Magic2)
 {
  if(OrderType()==OP_BUY)       
  {
   otl=OrderOpenTime();
   orderlong=true;
  }
  else if(OrderType()==OP_SELL) 
  {
   ots=OrderOpenTime(); 
   ordershort=true;
  }  
 }
 return(0);  
}
//+------------------------------------------------------------------+
void CheckClosedOrders() // check most recently closed for time ... don't enter until new cross occurs after a close  
{
 lastLong=0;lastShort=0; 
 int trade;                         
 int trades=OrdersHistoryTotal();           
 for(trade=trades-1;trade>=0;trade--)   // The most recent closed order has the largest position number, so this works backward 
                                     // to find the most recently closed order 
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_HISTORY);

  if(OrderSymbol()!=Symbol()) continue;
  if(OrderType()==OP_BUY)
  {
   if(OrderMagicNumber()==Magic1||OrderMagicNumber()==Magic2)
   {
    lastLong=OrderCloseTime();
    break;
   }
  }
 }
 
 for(trade=trades-1;trade>=0;trade--)   // The most recent closed order has the largest position number, so this works backward 
                                     // to find the most recently closed order 
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_HISTORY);

  if(OrderSymbol()!=Symbol()) continue;
  if(OrderType()==OP_SELL)
  {
   if(OrderMagicNumber()==Magic1||OrderMagicNumber()==Magic2)
   {
    lastShort=OrderCloseTime();
    break;
   }
  }
 } 
 
 return;
} 
//+------------------------------------------------------------------+
void DrawCross(bool flag)
{
 color clr;
 string name;
 double price=OrderOpenPrice();
 datetime time=OrderOpenTime();
 string comment=OrderComment();
 int ticket=OrderTicket();
 int type=OrderType();

      if(type==OP_BUY||type==OP_BUYLIMIT||type==OP_BUYSTOP)    clr=Blue;
 else if(type==OP_SELL||type==OP_SELLLIMIT||type==OP_SELLSTOP) clr=Red;

 if(flag)
 {
  name=StringConcatenate(comment," #",ticket," ",TimeToStr(time)," ",price);

  ObjectDelete(name);  
  ObjectCreate(name,OBJ_ARROW,0,time,price);
  ObjectSet(name,OBJPROP_COLOR,clr);
  ObjectSet(name,OBJPROP_ARROWCODE,1); 
  ObjectSet(name,OBJPROP_WIDTH,1);
 }
 else
 {
//  if(type!=OP_BUY||type!=OP_SELL) comment=FindComment(OrderMagicNumber()); // expired pendings don't have method name for comment, must match up w/ list
 
  name=StringConcatenate(comment," #",ticket," ",TimeToStr(time)," ",price);

  ObjectDelete(name);  
  ObjectCreate(name,OBJ_ARROW,0,time,price);
  ObjectSet(name,OBJPROP_COLOR,clr);
  ObjectSet(name,OBJPROP_ARROWCODE,1); 
  ObjectSet(name,OBJPROP_WIDTH,1);
  
  double closeprice;
  if(type==OP_BUY||type==OP_SELL) closeprice=OrderClosePrice();
  else closeprice=OrderOpenPrice();
  datetime closetime=OrderCloseTime();
  
  name=StringConcatenate(comment,": ",price,"-->",closeprice);

  if(type==OP_BUYLIMIT||type==OP_BUYSTOP||type==OP_SELLLIMIT||type==OP_SELLSTOP) clr=Black;
  
  ObjectDelete(name);
  ObjectCreate(name,OBJ_TREND,0,time,price,closetime,closeprice);
  ObjectSet(name,OBJPROP_STYLE,STYLE_DOT);
  ObjectSet(name,OBJPROP_COLOR,clr);  
  ObjectSet(name,OBJPROP_RAY,false);

  if(type==OP_BUY||type==OP_SELL)
  {
   if(OrderStopLoss()!=OrderClosePrice()) clr=LimeGreen;
  }
  
  name=StringConcatenate(comment," #",ticket," ",TimeToStr(closetime)," ",closeprice);

  ObjectDelete(name);
  ObjectCreate(name,OBJ_ARROW,0,closetime,closeprice);
  ObjectSet(name,OBJPROP_ARROWCODE,3);
  ObjectSet(name,OBJPROP_COLOR,clr);   
 }
 return;
}
//+------------------------------------------------------------------+
void IchimokuExit()
{ 
 double tenkan1=iIchimoku(NULL,0,tenkan,kijun,senkou,MODE_TENKANSEN,0);
 double tenkan2=iIchimoku(NULL,0,tenkan,kijun,senkou,MODE_TENKANSEN,1);

 double kijun1=iIchimoku(NULL,0,tenkan,kijun,senkou,MODE_KIJUNSEN,0);
 double kijun2=iIchimoku(NULL,0,tenkan,kijun,senkou,MODE_KIJUNSEN,1);
 
 if(OrderType()==OP_BUY)       
 { 
  if(tenkan1<kijun1&&tenkan2>=kijun2)
  {
   ExitOrder(true,false);
   Alert("2ndSkiesA2 cross-exit long: ",Symbol()," M",Period()," at",TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES));   
  }
 }
 else if(OrderType()==OP_SELL)       
 { 
  if(tenkan1>kijun1&&tenkan2<=kijun2)
  {
   ExitOrder(false,true);
   Alert("2ndSkiesA2 cross-exit short: ",Symbol()," M",Period()," at",TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES));   
  }
 }
   
 return;
}
//+------------------------------------------------------------------+
void KijunTrail()
{  
// if(lasttime==iTime(NULL,0,0)) return;
 double stopcal;
 double stopcrnt=OrderStopLoss();
 double kijun1=iIchimoku(NULL,0,tenkan,kijun,senkou,MODE_KIJUNSEN,0);

 if(OrderType()==OP_BUY)       
 {
  stopcal=NormDigits(kijun1-NormPoints(Trail));
//  Alert(kijun1," ",stopcal," ",stopcrnt);
  ModifyCompLong(stopcal,stopcrnt);
 }
 else if(OrderType()==OP_SELL)       
 {   
  stopcal=NormDigits(kijun1+NormPoints(Trail));
//  Alert(kijun1," ",stopcal," ",stopcrnt);
  ModifyCompShort(stopcal,stopcrnt); 
 }
 return;
}
//+------------------------------------------------------------------+ 

void AddSLTP(double sl, double tp)
{
 int magic,trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;

  if(OrderStopLoss()==0)
  {
   magic=OrderMagicNumber();
        if(magic==Magic1) ModifyOrder(OrderTicket(),OrderOpenPrice(),sl,tp,0,CLR_NONE);
   else if(magic==Magic2) ModifyOrder(OrderTicket(),OrderOpenPrice(),sl,0, 0,CLR_NONE); 
  }
 } 
 return;
}

//+------------------------------------------------------------------+ 
/*
double EquityCheck()
{
 int trade,trades=OrdersTotal(); 
 double exposure,stopvalue,stoptotal=0,lottotal=0;
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
//  if(OrderSymbol()!=Symbol()) continue; // check across ALL pairs

  if(OrderMagicNumber()==Magic1||OrderMagicNumber()==Magic2)
  {
   if(OrderType()==OP_BUY)       
   {
    stopvalue=NormDigits(OrderOpenPrice()-OrderStopLoss());
    if(stopvalue<=0) continue; // SL already adjusted beyond BE: don't count
    stoptotal+=stopvalue;
    lottotal+=OrderLots();
   }
   else if(OrderType()==OP_SELL)       
   {  
    stopvalue=NormDigits(OrderStopLoss()-OrderOpenPrice());
    if(stopvalue<=0) continue; // SL already adjusted beyond BE: don't count
    stoptotal+=stopvalue; 
    lottotal+=OrderLots();       
   }   
  }
 } 
 
 exposure=(stoptotal/Point)*MarketInfo(Symbol(),MODE_TICKVALUE)*lottotal;
 
 return(exposure/AccountEquity());
}
//+------------------------------------------------------------------+
double DetermineLots(double value1, double value2, int number, double factor)  // function to determine lot sizes based on available free margin
{
 double permitLoss=factor*AccountEquity();
 double pipSL=(value1-value2)/Point;
 double valueSL=pipSL*MarketInfo(Symbol(),MODE_TICKVALUE);
 
 double lots=permitLoss/valueSL;
 lots=lots/number;
 
 if(lots<lotsmin) return(lotsmin);
 else if(lots>lotsmax) return(lotsmax);
 
 return(lots);
}
*/
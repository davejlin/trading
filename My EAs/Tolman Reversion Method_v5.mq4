//+----------------------------------------------------------------------+
//|                                          Tolman Reversion Method.mq4 |
//|                                                         David J. Lin |
//| Based on a reversion method by Todd Tolman                           |
//| written for Todd Tolman (ttolman@prodigix.com)                       |
//|                                                                      |
//| Coded by David J. Lin (dave.j.lin@sbcglobal.net)                     |
//| Evanston, IL, August 20, 2009                                        |
//| September 8, 2009 - lottage based on autocalculation                 |
//| September 25, 2009 - handled zero-divide possibly related errors     |
//| March 16, 2011 - Limit number of trades in entire account            |
//| May 31, 2011 - v4: reforumate let-it-ride function to act on ticket #|
//| March 11, 2012 - v5: average entry price and stop loss               |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2009, Todd Tolman & David J. Lin"

// Internal usage parameters:
//---- input parameters
extern int Bias=0;              // 0=both long/short, positive=long only, negative=short only
//extern double LotInit=1.0;    // initial number of lots to submit
extern double Risk=2;           // total percentage drawdown allowed for all open orders based on average entry price 
extern int TakeProfit=0;        // pips initial TP, set to 0 to not use a take profit
extern int StopLoss=0;          // pips initial SL, set to 0 to not use a stop loss
extern int MATrail=0;           // pips from MA line to exit 
                                // set to 0 to exit at MA line
                                // set to a negative number to not exit at MA line
extern int LetItRide=0;         // set to 0 to exit all positions at MA line
                                // set to a positive number to exit all positions at MA line except the most profitable one
                                // set to a negative number to exit all positions at MA line except the least profitable one
extern int StopLossRide=0;      // pips from price (Ask for longs, Bid for shorts) for stoploss for riding order
                                // set to 0 to not use a stop loss

extern int MAPeriod=800;        // period for MA
extern int MAMethod=MODE_SMA;   // MA method
extern int EnvPeriod=800;       // period for Envelopes
extern int EnvMethod=MODE_SMA;  // Envelopes method
extern double EnvDev=2.0;       // deviation for Envelopes
extern int Offset=5;            // bars to ignore after 1st cross before considering 2nd cross 
extern color TitleColor=Red;    // color of text titles
extern color ValueColor=Yellow; // color of numerical values
extern int Corner=1;            // position of information placement on chart: 
                                // 0=upper-left, 1=upper-right, 2=lower-left, 3=lower-right 
extern int MaxNumberTrades=5;   // maximum number of trades allowed in account, if exceeded, all EAs prohibited from submitting new trades 
//---- buffers
int top=100;
int handle;
double mult,lotsi;
double tickvalue;
bool init1,init2;
double HeightArr[],TimeArr[];
int NElements;

bool orderlong,ordershort,triggered;
int Magic;
string comment="Tolman Reversion Method";
datetime ots,otl,lasttime;
double lotsmin,lotsmax,MATrailPoints,StopLossPoints,TakeProfitPoints,StopLossRidePoints;
int lotsprecision;
int Slippage=5;
int NTradesGlobal;

double totalLotsXPrice,totalLots,aveEntry,aveSL;
bool direction;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//---- 

 lotsmin=MarketInfo(Symbol(),MODE_MINLOT); 
 lotsmax=MarketInfo(Symbol(),MODE_MAXLOT); 

 if(lotsmin==1)         lotsprecision=0;
 else if(lotsmin==0.50) lotsprecision=1; // for PFG ECN
 else if(lotsmin==0.10) lotsprecision=1;
 else if(lotsmin==0.01) lotsprecision=2;
 else                   lotsprecision=1; 

 tickvalue=MarketInfo(Symbol(),MODE_TICKVALUE);

 if(StringFind(Symbol(),"JPY")>0) 
 {
  if(Digits==3)
  {
   StopLossPoints=NormPoints(StopLoss*10);
   TakeProfitPoints=NormPoints(TakeProfit*10);  
   StopLossRidePoints=NormPoints(StopLossRide*10);
  }
  else
  {
   StopLossPoints=NormPoints(StopLoss);
   TakeProfitPoints=NormPoints(TakeProfit);  
   StopLossRidePoints=NormPoints(StopLossRide);   
  }  
 }
 else
 {
  if(Digits==5)
  {
   StopLossPoints=NormPoints(StopLoss*10);
   TakeProfitPoints=NormPoints(TakeProfit*10);  
   StopLossRidePoints=NormPoints(StopLossRide*10);   
  }
  else
  {
   StopLossPoints=NormPoints(StopLoss);
   TakeProfitPoints=NormPoints(TakeProfit);  
   StopLossRidePoints=NormPoints(StopLossRide);   
  }  
 } 

 if(Corner==1)
 {
  MakeLabel( "time1t", 75, top-75 );
  MakeLabel( "time1v", 10, top-75 );
  MakeLabel( "time2t", 75, top-60 );
  MakeLabel( "time2v", 10, top-60 ); 
  MakeLabel( "price1t", 75, top-45 );  
  MakeLabel( "price1v", 10, top-45 );  
  MakeLabel( "price2t", 75, top-30 );  
  MakeLabel( "price2v", 10, top-30 );
  MakeLabel( "price3t", 75, top-15 );  
  MakeLabel( "price3v", 10, top-15 );
 
  MakeLabel( "EnvAvet", 75, top+10 );   
  MakeLabel( "EnvAvev", 10, top+10 );
  MakeLabel( "Env75t", 75, top+25 );    
  MakeLabel( "Env75v", 10, top+25 );
  MakeLabel( "Env95t", 75, top+40 );    
  MakeLabel( "Env95v", 10, top+40 );
  MakeLabel( "DayAvet", 75, top+65 );  
  MakeLabel( "DayAvev", 10, top+65 );
  MakeLabel( "Day75t", 75, top+80 );  
  MakeLabel( "Day75v", 10, top+80 );
  MakeLabel( "Day95t", 75, top+95 );  
  MakeLabel( "Day95v", 10, top+95 );
  MakeLabel( "LotsInitt", 75, top+120 );  
  MakeLabel( "LotsInitv", 10, top+120 );
  MakeLabel( "LotsNot", 75, top+135 );  
  MakeLabel( "LotsNov", 10, top+135 ); 
  MakeLabel( "AveEntryt", 75, top+160 );  
  MakeLabel( "AveEntryv", 10, top+160 );
  MakeLabel( "AveSLt", 75, top+175 );  
  MakeLabel( "AveSLv", 10, top+175 );             
 }
 else if(Corner==2)
 {
  MakeLabel( "time1t", 10, top-15 );
  MakeLabel( "time1v", 90, top-15 );
  MakeLabel( "time2t", 10, top-30 );
  MakeLabel( "time2v", 90, top-30 ); 
  MakeLabel( "price1t", 10, top-45 );  
  MakeLabel( "price1v", 90, top-45 );  
  MakeLabel( "price2t", 10, top-60 );  
  MakeLabel( "price2v", 90, top-60 );
  MakeLabel( "price3t", 10, top-75 );  
  MakeLabel( "price3v", 90, top-75 );  
 }
 else if(Corner==3)
 {
  MakeLabel( "time1t", 75, top-15 );
  MakeLabel( "time1v", 10, top-15 );
  MakeLabel( "time2t", 75, top-30 );
  MakeLabel( "time2v", 10, top-30 ); 
  MakeLabel( "price1t", 75, top-45 );  
  MakeLabel( "price1v", 10, top-45 );  
  MakeLabel( "price2t", 75, top-60 );  
  MakeLabel( "price2v", 10, top-60 );
  MakeLabel( "price3t", 75, top-75 );  
  MakeLabel( "price3v", 10, top-75 );
 } 
 else
 {
  MakeLabel( "time1t", 10, top-75 );
  MakeLabel( "time1v", 90, top-75 );
  MakeLabel( "time2t", 10, top-60 );
  MakeLabel( "time2v", 90, top-60 );
  MakeLabel( "price1t", 10, top-45 );  
  MakeLabel( "price1v", 90, top-45 );  
  MakeLabel( "price2t", 10, top-30 );  
  MakeLabel( "price2v", 90, top-30 );
  MakeLabel( "price3t", 10, top-15 );  
  MakeLabel( "price3v", 90, top-15 );   
 } 
 
 ObjectSetText( "time1t",  "Time1:", 10, "Arial", TitleColor );
 ObjectSetText( "time2t",  "Time2:", 10, "Arial", TitleColor );
 ObjectSetText( "price1t", "OpnPL:", 10, "Arial", TitleColor );
 ObjectSetText( "price2t", "PrjPL:", 10, "Arial", TitleColor );
 ObjectSetText( "price3t", "PipMA:", 10, "Arial", TitleColor );

 ObjectSetText( "EnvAvet", "EnvAve:", 10, "Arial", TitleColor );
 ObjectSetText( "Env75t",   "Env75:", 10, "Arial", TitleColor );
 ObjectSetText( "Env95t",   "Env95:", 10, "Arial", TitleColor );
 ObjectSetText( "DayAvet", "DayAve:", 10, "Arial", TitleColor );
 ObjectSetText( "Day75t",   "Day75:", 10, "Arial", TitleColor );
 ObjectSetText( "Day95t",   "Day95:", 10, "Arial", TitleColor );
 ObjectSetText( "LotsInitt","Lots Init:", 10, "Arial", TitleColor );
 ObjectSetText( "LotsNot",  "Lots No:", 10, "Arial", TitleColor );
 
 ObjectSetText( "AveEntryt",  "Ave Entry:", 10, "Arial", TitleColor );     
 ObjectSetText( "AveSLt",  "Ave SL:", 10, "Arial", TitleColor ); 
 
 mult=Period()/1440.0;
 
 string timename;
 switch(Period())
 {
  case 1: timename="M1";
  break;
  case 5: timename="M5";
  break;
  case 15: timename="M15";
  break;  
  case 30: timename="M30";
  break;  
  case 60: timename="H1";
  break;
  case 240: timename="H4";
  break;  
  case 1440: timename="D1";
  break;  
  case 10080: timename="W1";
  break;  
  default: timename="MN";
  break;  
 }
 
 reinit();
 lasttime=iTime(NULL,0,0);
 
 MATrailPoints=NormPoints(MATrail);
 triggered=false;

 NTradesGlobal=0;
 if(CheckNumberOrder()>0) triggered=true; 
 
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
//---- 
 ObjectDelete( "time1t" );
 ObjectDelete( "time1v" );
 ObjectDelete( "time2t" );
 ObjectDelete( "time2v" );
 ObjectDelete( "price1t" );
 ObjectDelete( "price1v" ); 
 ObjectDelete( "price2t" );
 ObjectDelete( "price2v" );
 ObjectDelete( "price3t" );
 ObjectDelete( "price3v" ); 
 
 ObjectDelete("EnvAvet");
 ObjectDelete("EnvAvev");
 ObjectDelete("Env75t");   
 ObjectDelete("Env75v");   
 ObjectDelete("Env95t");
 ObjectDelete("Env95v");
 ObjectDelete("DayAvet");
 ObjectDelete("DayAvev");
 ObjectDelete("Day75t");
 ObjectDelete("Day75v");
 ObjectDelete("Day95t");
 ObjectDelete("Day95v");
 ObjectDelete("LotsInitt");
 ObjectDelete("LotsInitv");
 ObjectDelete("LotsNot");
 ObjectDelete("LotsNov");
 
 ObjectDelete("AveEntryt"); 
 ObjectDelete("AveEntryv");
 ObjectDelete("AveSLt"); 
 ObjectDelete("AveSLv");   
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
//----   
 DisplayUpdate();
 Main();
 ManageOrders();
  
 if(lasttime==iTime(NULL,0,0)) return(0);
 lasttime=iTime(NULL,0,0);
 reinit();
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert utility functions                                         |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void Main()
{ 
 if(triggered) return;
 if(NTradesGlobal>=MaxNumberTrades) return;
 
 double SL,TP;
 string td;

 double uEnv=iEnvelopes(NULL,0,EnvPeriod,EnvMethod,0,0,EnvDev,MODE_UPPER,0);
 double lEnv=iEnvelopes(NULL,0,EnvPeriod,EnvMethod,0,0,EnvDev,MODE_LOWER,0);
 double open=iOpen(NULL,0,0);

 if(open>lEnv && Bid<lEnv && Bias>=0)
 {
  SL=StopLong(Ask,StopLossPoints);
  TP=TakeLong(Ask,TakeProfitPoints);  

  SendOrderLong(Symbol(),lotsi,Slippage,0,0,comment,Magic);       
  
  otl=TimeCurrent();
  td=TimeToStr(otl,TIME_DATE|TIME_MINUTES);
  Alert("Tolman Reversion entered long: ",Symbol()," M",Period()," at",td);
  AddSLTP(SL,TP);
  triggered=true;  
 } 
 
 if(open<uEnv && Bid>uEnv && Bias<=0)
 {
  SL=StopShort(Bid,StopLossPoints);
  TP=TakeShort(Bid,TakeProfitPoints);  

  SendOrderShort(Symbol(),lotsi,Slippage,0,0,comment,Magic); 
  
  ots=TimeCurrent();
  td=TimeToStr(ots,TIME_DATE|TIME_MINUTES);
  Alert("Tolman Reversion entered short: ",Symbol()," M",Period()," at",td);
  AddSLTP(SL,TP);
  triggered=true;
 } 

 return; 
}
//+------------------------------------------------------------------+

void ManageOrders()
{ 
 NTradesGlobal=0;
 if(CheckNumberOrder()==0) triggered=false; // allow new orders if exit or stopped out

 int trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 { 
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
   
  if(LetItRide==0)
  {
   if(MATrail>=0) MAExit(); // for all orders in account 
  } 
  else
  {
   if(MATrail>=0) MAExitLetItRide(); // for all orders in account  
  }
 
  EnvExit(); // bail all opposite biased orders when other envelope is reached
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
void ExitAllOrders(bool long)
{
 int trade,trades=OrdersTotal(); 
 if(long)
 {
  for(trade=trades-1;trade>=0;trade--)
  {
   OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
   if(OrderSymbol()!=Symbol()) continue;
   ExitOrder(true,false);
  }
 }
 else
 {
  for(trade=trades-1;trade>=0;trade--)
  {
   OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
   if(OrderSymbol()!=Symbol()) continue;
   ExitOrder(false,true);
  }
 } 
 
 triggered=false;

 return;
}
//+------------------------------------------------------------------+ 
void ExitAllOrdersLetItRide(bool long) // let most or least profitable order ride
{
 double sl,profit;
 int trade,trades=OrdersTotal(); 
 int targetticket=0;
  
 if(LetItRide<0) profit=9999999;
 else if(LetItRide>0) profit=-9999999;
  
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;

  if(LetItRide<0)
  {
   if(OrderProfit()<profit) 
   {
    profit=OrderProfit();
    targetticket=OrderTicket();
   }
  }
  else if(LetItRide>0)
  {
   if(OrderProfit()>profit) 
   {
    profit=OrderProfit();
    targetticket=OrderTicket();
   }  
  }
 }
 
 if(long)
 {
  for(trade=trades-1;trade>=0;trade--)
  {
   OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
   if(OrderSymbol()!=Symbol()) continue;  
   if(OrderTicket()!=targetticket) ExitOrder(true,false); 
   else 
   {
    if(StopLossRide>0)
    {
     sl=StopLong(Ask,StopLossRidePoints);
     ModifyCompLong(sl,OrderStopLoss());
    }
   }
  }
 }
 else
 {
  for(trade=trades-1;trade>=0;trade--)
  {
   OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
   if(OrderSymbol()!=Symbol()) continue;  
   if(OrderTicket()!=targetticket) ExitOrder(false,true); 
   {
    if(StopLossRide>0)
    {
     sl=StopShort(Bid,StopLossRidePoints);
     ModifyCompShort(sl,OrderStopLoss());
    }
   }   
  }  
 }
 
 triggered=false; 

 return;
}
//+------------------------------------------------------------------+
double TakeLong(double price,double take)  // function to calculate takeprofit if long
{
 if(take==0) return(0);
 return(NormDigits(price+take)); 
             // plus, since the take profit is above us for long positions
}
//+------------------------------------------------------------------+
double TakeShort(double price,double take)  // function to calculate takeprofit if short
{
 if(take==0) return(0);
 return(NormDigits(price-take)); 
             // minus, since the take profit is below us for short positions
}
//+------------------------------------------------------------------+
double StopShort(double price,double stop) // function to calculate normal stoploss if short
{
 if(stop==0) return(0);
 return(NormDigits(price+stop)); 
             // plus, since the stop loss is above us for short positions
}
//+------------------------------------------------------------------+
double StopLong(double price,double stop) // function to calculate normal stoploss if long
{
 if(stop==0) return(0);
 return(NormDigits(price-stop)); 
             // minus, since the stop loss is below us for long positions
             // Point is 0.01 or 0.001 depending on currency, so stop*POINT is a way to convert pips into price with multiplication 
}
//+------------------------------------------------------------------+
void MAExit()
{  
// if(lasttime==iTime(NULL,0,0)) return;
 double price;
 double MA=iMA(NULL,0,MAPeriod,0,MAMethod,0,0);
 double open=iOpen(NULL,0,0);

 if(OrderType()==OP_BUY)       
 {
  price=NormDigits(MA-MATrailPoints); 
  if(open<price && Bid>price) ExitAllOrders(true);
 }
 else if(OrderType()==OP_SELL)       
 {   
  price=NormDigits(MA+MATrailPoints);
  if(open>price && Bid<price) ExitAllOrders(false);  
 }
 return;
}
//+------------------------------------------------------------------+
void MAExitLetItRide() // let most or least profitable order ride
{  
// if(lasttime==iTime(NULL,0,0)) return;
 double price;
 double MA=iMA(NULL,0,MAPeriod,0,MAMethod,0,0);
 double open=iOpen(NULL,0,0);

 if(OrderType()==OP_BUY)       
 {
  price=NormDigits(MA-MATrailPoints); 
  if(open<=price && Bid>=price) ExitAllOrdersLetItRide(true);
 }
 else if(OrderType()==OP_SELL)       
 {   
  price=NormDigits(MA+MATrailPoints);
  if(open>=price && Bid<=price) ExitAllOrdersLetItRide(false);  
 }
 return;
}
//+------------------------------------------------------------------+
void EnvExit()
{  
// if(lasttime==iTime(NULL,0,0)) return;
 double uEnv=iEnvelopes(NULL,0,EnvPeriod,EnvMethod,0,0,EnvDev,MODE_UPPER,0);
 double lEnv=iEnvelopes(NULL,0,EnvPeriod,EnvMethod,0,0,EnvDev,MODE_LOWER,0);
 double open=iOpen(NULL,0,0);

 if(OrderType()==OP_BUY)       
 {
  if(open<uEnv && Bid>uEnv) ExitAllOrders(true);
 }
 else if(OrderType()==OP_SELL)       
 {   
  if(open>lEnv && Bid<lEnv) ExitAllOrders(false); 
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
   if(OrderStopLoss()!=sl || OrderTakeProfit()!=tp)
   {
    magic=OrderMagicNumber();
    if(magic==Magic) ModifyOrder(OrderTicket(),OrderOpenPrice(),sl,tp,0,CLR_NONE);
   }
  }
 } 
 return;
}

//+------------------------------------------------------------------+ 
void DisplayUpdate()
{   
 if(IsTesting()) return;

 ObjectSetText( "AveEntryv", DoubleToStr(aveEntry,Digits), 10, "Arial", ValueColor ); 
 ObjectSetText( "AveSLv", DoubleToStr(aveSL,Digits), 10, "Arial", ValueColor ); 

 double PP;
 if (Digits == 3 || Digits == 5) PP = 10.0 * Point;
 else PP = Point; 
  
 int i,j,k,lastj,offseti,limit, counted_bars = IndicatorCounted();
 double time1,time2,time3,price1,price2,price3,high,low,uEnv,lEnv,height,env,ma;
 bool upper,lower;
 
 if(counted_bars>0) counted_bars--;
 limit=Bars-counted_bars;

 if(!init1)
 {
  for(i=0;i<Bars-1;i++)
  {
   ma=iMA(NULL,0,MAPeriod,0,MAMethod,0,i);
   if(iHigh(NULL,0,i)>ma && iLow(NULL,0,i)<ma)
   {
    time1=NormalizeDouble(mult*i,2);
    for(j=i+Offset;j<Bars-1;j++)
    {
     ma=iMA(NULL,0,MAPeriod,0,MAMethod,0,j);    
     if(iHigh(NULL,0,j)>ma && iLow(NULL,0,j)<ma)
     {
      time2=NormalizeDouble(mult*j,2);
      break;
     }
    }
    break;
   }   
  }
  ObjectSetText( "time1v", DoubleToStr(time1,2), 10, "Arial", ValueColor );
  ObjectSetText( "time2v", DoubleToStr(time2,2), 10, "Arial", ValueColor );

  price1=0;price2=0;price3=0;

  ma=iMA(NULL,0,MAPeriod,0,MAMethod,0,0);
  price3=MathAbs((Bid-ma))/PP;

  for(int trade=OrdersTotal()-1;trade>=0;trade--)
  {
   OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
   if(OrderSymbol()!=Symbol()) continue;
   price1+=OrderProfit();

   if(OrderType()==OP_BUY)       price2+=OrderLots()*(ma-OrderOpenPrice())*tickvalue/Point;
   else if(OrderType()==OP_SELL) price2+=OrderLots()*(OrderOpenPrice()-ma)*tickvalue/Point;
  }

  ObjectSetText( "price1v", DoubleToStr(price1,2), 10, "Arial", ValueColor );
  ObjectSetText( "price2v", DoubleToStr(price2,2), 10, "Arial", ValueColor );
  ObjectSetText( "price3v", DoubleToStr(price3,0), 10, "Arial", ValueColor );

  // Mean, percentile, lottage info:
  
  double value, value75, value95, lotsn; 
  int perc75=MathRound(3.*NElements/4.);
  int perc95=MathRound(95.*NElements/100.);
  
  if(perc75==0) perc75=1;
  if(perc95==0) perc95=1;
  
  if(!init2) // dynamic update of lots 7/18/09 
  {
   value=HeightArr[perc95-1];    

   if(NElements!=0) lotsi=AccountEquity()*0.01/value;
   else lotsi=0;
  
   value75=TimeArr[perc75-1];
  
   ObjectSetText( "Day75v", DoubleToStr(value75,2), 10, "Arial", ValueColor );  

   value95=TimeArr[perc95-1];  
        
   ObjectSetText( "Day95v", DoubleToStr(value95,2), 10, "Arial", ValueColor );  
  
   if(time1>=value95)       lotsn=4;
   else if (time1>=value75) lotsn=2;
   else                     lotsn=1;
  
   ObjectSetText( "LotsInitv", DoubleToStr(lotsi,2), 10, "Arial", ValueColor );  
   ObjectSetText( "LotsNov", DoubleToStr(lotsn,2), 10, "Arial", ValueColor );
  
   return(0);
  }
  
  // first-time calculation of info
  
  for(i=1;i<=NElements;i++)
  {
   value+=HeightArr[i-1];
  }
  
  if(NElements==0) value=0;
  else value/=NElements;

  ObjectSetText( "EnvAvev", DoubleToStr(value,2), 10, "Arial", ValueColor );
  
  value=HeightArr[perc75-1];
    
  ObjectSetText( "Env75v", DoubleToStr(value,2), 10, "Arial", ValueColor );

  value=HeightArr[perc95-1];  
  
  ObjectSetText( "Env95v", DoubleToStr(value,2), 10, "Arial", ValueColor );

  if(NElements!=0) lotsi=AccountEquity()*0.01/value;
  else lotsi=0;
  
  value=0;
  for(i=1;i<=NElements;i++)
  {
   value+=TimeArr[i-1];
  }
  
  if(NElements==0) value=0;
  else value/=NElements;
  
  ObjectSetText( "DayAvev", DoubleToStr(value,2), 10, "Arial", ValueColor );

  value75=TimeArr[perc75-1];
  
  ObjectSetText( "Day75v", DoubleToStr(value75,2), 10, "Arial", ValueColor );  

  value95=TimeArr[perc95-1];  
        
  ObjectSetText( "Day95v", DoubleToStr(value95,2), 10, "Arial", ValueColor );  
  
  if(time1>=value95)       lotsn=4;
  else if (time1>=value75) lotsn=2;
  else                     lotsn=1;
  
  ObjectSetText( "LotsInitv", DoubleToStr(lotsi,2), 10, "Arial", ValueColor );  
  ObjectSetText( "LotsNov", DoubleToStr(lotsn,2), 10, "Arial", ValueColor );
  
  init2=false;
  
 }
 else
 {

  lastj=Bars;
  
  for(i=Bars-1;i>0;i--)
  {
   if(i>lastj) continue;  

   ma=iMA(NULL,0,MAPeriod,0,MAMethod,0,i);    
   if(iHigh(NULL,0,i)>ma && iLow(NULL,0,i)<ma)
   {

    offseti=i-Offset;
    
    for(j=offseti;j>0;j--)
    {

     lastj=j;
     ma=iMA(NULL,0,MAPeriod,0,MAMethod,0,j);      
     if(iHigh(NULL,0,j)>ma && iLow(NULL,0,j)<ma)
     {
      time3=NormalizeDouble(mult*(offseti-j),2);

      upper=false;lower=false;
      
      for(k=offseti;k>=j;k--)
      {
       high=iHigh(NULL,0,k);
       low=iLow(NULL,0,k);
       
       uEnv=iEnvelopes(NULL,0,EnvPeriod,EnvMethod,0,0,EnvDev,MODE_UPPER,k);
       lEnv=iEnvelopes(NULL,0,EnvPeriod,EnvMethod,0,0,EnvDev,MODE_LOWER,k);
       
       if(high>=uEnv&&low<=uEnv)      upper=true;
       else if(high>=lEnv&&low<=lEnv) lower=true;
 
       if(upper||lower)
       {
       
        if(upper)
        {
         height=iHigh(NULL,0,iHighest(NULL,0,MODE_HIGH,offseti-j,j));
         height=NormalizeDouble((height-uEnv)/PP,0);
         env=uEnv;
        }
        else
        {
         height=iLow(NULL,0,iLowest(NULL,0,MODE_LOW,offseti-j,j));
         height=NormalizeDouble((lEnv-height)/PP,0);
         env=lEnv;
        }
        
        LogData(height,env,time3,i,j,k);
        break;
       } // if(upper||lower)
       
      } // k-loop

      break;       
     } // if 2nd MA cross
     
    } // j-loop
     
   } // if 1st MA cross

  } // i-loop 

  init1=false;

  if(NElements!=0)
  {  
   ArraySort(HeightArr);
   ArraySort(TimeArr);  
  }
  
// Print-out to examine arrays 
/*  
  Print(NElements);
  for(i=1;i<=NElements;i++)
  {
   Print(HeightArr[i-1]);
   Print(TimeArr[i-1]);
   Print("--------");
  }
*/
  
 } // initial
 return;
}
//+------------------------------------------------------------------+
int MakeLabel( string str, int a, int b ) 
{
 ObjectCreate( str, OBJ_LABEL, 0, 0, 0 );
 ObjectSet( str, OBJPROP_CORNER, Corner );
 ObjectSet( str, OBJPROP_XDISTANCE, a );
 ObjectSet( str, OBJPROP_YDISTANCE, b );
 ObjectSet( str, OBJPROP_BACK, true );
 return(0);
}
//+------------------------------------------------------------------+
void LogData(double height, double env, double time, int i, int j, int k)
{

 NElements++;
 
 ArrayResize(HeightArr,NElements);
 ArrayResize(TimeArr,NElements);
 
 HeightArr[NElements-1]=height;
 TimeArr[NElements-1]=time; 
 
 return;
}
//+------------------------------------------------------------------+
int CheckNumberOrder() // check number of orders in account regardless of origin
{
 NTradesGlobal=0;
 totalLotsXPrice=0;
 totalLots=0;
 aveEntry=0;
 aveSL=0; 
 direction=true;
 int trade,trades=OrdersTotal(),total=0; 
 for(trade=trades-1;trade>=0;trade--)
 {
  NTradesGlobal++;
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  totalLotsXPrice+=OrderLots()*OrderOpenPrice();
  totalLots+=OrderLots();
  total++;
  
  if(OrderType()==OP_BUY)       direction=true;
  else if(OrderType()==OP_SELL) direction=false;
  
 }

 if(totalLots>0) aveEntry=totalLotsXPrice/totalLots; // becomes average price
 CalcAveSL(); // find average SL

 return(total);
}
//+------------------------------------------------------------------+
void reinit()
{
 init1=true;
 init2=true;
 NElements=0;
 return;
}
//+------------------------------------------------------------------+
void CalcAveSL()
{
 double permitLoss=Risk*0.01*AccountBalance();
 if(totalLots>0) 
 {
  double pointsSL=NormDigits(permitLoss*Point/(totalLots*MarketInfo(Symbol(),MODE_TICKVALUE)));
  if(direction) aveSL=NormDigits(aveEntry-pointsSL);
  else          aveSL=NormDigits(aveEntry+pointsSL);
 }
 else           aveSL=0;
 return;
}
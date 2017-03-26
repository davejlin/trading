//+----------------------------------------------------------------------+
//|                                                  ATC_Divergence2.mq4 |
//|                                                         David J. Lin |
//|ATC Divergence2 model                                                 |
//|by Vinson Wells                                                       |
//|                                                                      |
//|_____________ submission                                              |
//|                                                                      |
//|Coded by David J. Lin (dave.j.lin@sbcglobal.net)                      |
//|Evanston, IL, September 9, 2007                                       |
//|                                                                      |
//|Copyright © 2007, David J. Lin                                        |
//+----------------------------------------------------------------------+
#property copyright ""
#property link      ""

// User adjustable parameters:

// double Lots=1.0;               // number of lots (must be multiples of 0.1)

int    ATRPeriod = 18;         // ATR
int    ATRMA_Periods = 49;
int    ATRMA_type = MODE_LWMA;
double ATRMult_Factor1 = 1.6;
double ATRMult_Factor2 = 3.2;
double ATRMult_Factor3 = 4.8;

int OsMAfastH1=12;             // H1 OsMA
int OsMAslowH1=26;
int OsMAsignalH1=9; 
int OsMAPriceH1=PRICE_CLOSE;

// bool mini=false;                 // true=mini-account, false=standard-account

int FS=3;                       // fixed-stop value (BE+fs)
int SL=60;                      // pips additional beyond ATR lines for initial SL
int bo=1;                       // bars black-out after order entry
 
// Trend Determination (supplementary condition to WPR D1 condition)

int Tr_MAPeriod=72;             // D1 MA Trend condition
int Tr_Shift=0;
int Tr_Method=MODE_EMA;
int Tr_Price=PRICE_CLOSE;

                                 // EURUSD
int WPRD1Period1=16;             // D1 WPR filter (Group C)
double WPRD1filterLong1=-80;     // above which to allow longs
double WPRD1filterShort1=-20;    // below which to allow shorts
                                 // USDJPY
int WPRD1Period2=18;             // D1 WPR filter (Group C)
double WPRD1filterLong2=-80;     // above which to allow longs
double WPRD1filterShort2=-20;    // below which to allow shorts
                                 // GBPUSD
int WPRD1Period3=18;             // D1 WPR filter (Group C)
double WPRD1filterLong3=-80;     // above which to allow longs
double WPRD1filterShort3=-20;    // below which to allow shorts
                                 // AUDUSD
int WPRD1Period4=18;             // D1 WPR filter (Group C)
double WPRD1filterLong4=-80;     // above which to allow longs
double WPRD1filterShort4=-20;    // below which to allow shorts
                                 // USDCHF
int WPRD1Period5=18;             // D1 WPR filter (Group C)
double WPRD1filterLong5=-80;     // above which to allow longs
double WPRD1filterShort5=-20;    // below which to allow shorts
                                 // USDCAD
int WPRD1Period6=18;             // D1 WPR filter (Group C)
double WPRD1filterLong6=-80;     // above which to allow longs
double WPRD1filterShort6=-20;    // below which to allow shorts
                                 // GBPJPY
int WPRD1Period7=18;             // D1 WPR filter (Group C)
double WPRD1filterLong7=-80;     // above which to allow longs
double WPRD1filterShort7=-20;    // below which to allow shorts
                                 // EURJPY
int WPRD1Period8=18;             // D1 WPR filter (Group C)
double WPRD1filterLong8=-80;     // above which to allow longs
double WPRD1filterShort8=-20;    // below which to allow shorts
                                 // EURCHF
int WPRD1Period9=18;             // D1 WPR filter (Group C)
double WPRD1filterLong9=-80;     // above which to allow longs
double WPRD1filterShort9=-20;    // below which to allow shorts
                                 // all others                                 
int WPRD1Period10=18;            // D1 WPR filter (Group C)
double WPRD1filterLong10=-80;    // above which to allow longs
double WPRD1filterShort10=-20;   // below which to allow shorts

// Internal usage parameters:
int Slippage=3;
int lotsprecision=1;
int SLMin=32;                  // minimum universal SL
int Max=3;                     // maximum number of simultaneous orders

double lotsmin,lotsmax;
string comment="ATC Divergence2";
string symbol[];
double ot[],WPRD1Period[],WPRD1filterLong[],WPRD1filterShort[];
bool short[],long[];
int lastH1[];
int Nsymbol=19; 
int Norders;
int TimeFrame=PERIOD_H1;       // main timeframe of EA
int magic=1111111115;
string ciATRChannels="ATR_Channels";
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//----

 if(!GlobalVariableCheck("SEMAPHORE")) GlobalVariableSet("SEMAPHORE",0);

 if(IsTesting()) Nsymbol=1;

 ArrayResize(symbol,Nsymbol);
 ArrayResize(ot,Nsymbol);   
 ArrayResize(short,Nsymbol); 
 ArrayResize(long,Nsymbol);  
 ArrayResize(lastH1,Nsymbol);  
 ArrayResize(WPRD1Period,Nsymbol);
 ArrayResize(WPRD1filterLong,Nsymbol); 
 ArrayResize(WPRD1filterShort,Nsymbol);  

 if(IsTesting())
 {
  symbol[0]=Symbol(); 
  WPRD1Period[0]=WPRD1Period1;
  WPRD1filterLong[0]=WPRD1filterLong1;  
  WPRD1filterShort[0]=WPRD1filterShort1;  
 }
 else
 {
  bool mini;
  if(StringFind(Symbol(),"m")>0) mini=true;
  else mini=false;

  if(mini)
  {
   symbol[0]="EURUSDm";
   symbol[1]="USDJPYm";  
   symbol[2]="GBPUSDm";   
   symbol[3]="AUDUSDm"; 
   symbol[4]="USDCHFm";  
   symbol[5]="USDCADm";   
   symbol[6]="GBPJPYm";
   symbol[7]="EURJPYm";
   symbol[8]="EURCHFm";  
   symbol[9]="EURGBPm"; 
   symbol[10]="AUDNZDm"; 
   symbol[11]="GBPCHFm";
   symbol[12]="NZDJPYm"; 
   symbol[13]="CHFJPYm";
   symbol[14]="EURAUDm";
   symbol[15]="AUDCADm";
   symbol[16]="EURCADm"; 
   symbol[17]="NZDUSDm";  
   symbol[18]="AUDJPYm";  
  }
  else
  {
   symbol[0]="EURUSD";
   symbol[1]="USDJPY";  
   symbol[2]="GBPUSD";   
   symbol[3]="AUDUSD"; 
   symbol[4]="USDCHF";  
   symbol[5]="USDCAD";   
   symbol[6]="GBPJPY";
   symbol[7]="EURJPY";
   symbol[8]="EURCHF";    
   symbol[9]="EURGBP";   
   symbol[10]="AUDNZD"; 
   symbol[11]="GBPCHF";
   symbol[12]="NZDJPY"; 
   symbol[13]="CHFJPY";
   symbol[14]="EURAUD";
   symbol[15]="AUDCAD";
   symbol[16]="EURCAD"; 
   symbol[17]="NZDUSD";  
   symbol[18]="AUDJPY";  
  }  

  WPRD1Period[0]=WPRD1Period1;
  WPRD1Period[1]=WPRD1Period2; 
  WPRD1Period[2]=WPRD1Period3;
  WPRD1Period[3]=WPRD1Period4;
  WPRD1Period[4]=WPRD1Period5;
  WPRD1Period[5]=WPRD1Period6; 
  WPRD1Period[6]=WPRD1Period7;
  WPRD1Period[7]=WPRD1Period8; 
  WPRD1Period[8]=WPRD1Period9; 
  WPRD1Period[9]=WPRD1Period10; 
  WPRD1Period[10]=WPRD1Period10;
  WPRD1Period[11]=WPRD1Period10;
  WPRD1Period[12]=WPRD1Period10;
  WPRD1Period[13]=WPRD1Period10; 
  WPRD1Period[14]=WPRD1Period10;
  WPRD1Period[15]=WPRD1Period10; 
  WPRD1Period[16]=WPRD1Period10; 
  WPRD1Period[17]=WPRD1Period10;
  WPRD1Period[18]=WPRD1Period10; 
 
  WPRD1filterLong[0]=WPRD1filterLong1;
  WPRD1filterLong[1]=WPRD1filterLong2; 
  WPRD1filterLong[2]=WPRD1filterLong3;
  WPRD1filterLong[3]=WPRD1filterLong4;
  WPRD1filterLong[4]=WPRD1filterLong5;
  WPRD1filterLong[5]=WPRD1filterLong6; 
  WPRD1filterLong[6]=WPRD1filterLong7;
  WPRD1filterLong[7]=WPRD1filterLong8; 
  WPRD1filterLong[8]=WPRD1filterLong9; 
  WPRD1filterLong[9]=WPRD1filterLong10; 
  WPRD1filterLong[10]=WPRD1filterLong10;
  WPRD1filterLong[11]=WPRD1filterLong10;
  WPRD1filterLong[12]=WPRD1filterLong10;
  WPRD1filterLong[13]=WPRD1filterLong10; 
  WPRD1filterLong[14]=WPRD1filterLong10;
  WPRD1filterLong[15]=WPRD1filterLong10; 
  WPRD1filterLong[16]=WPRD1filterLong10; 
  WPRD1filterLong[17]=WPRD1filterLong10;
  WPRD1filterLong[18]=WPRD1filterLong10;  

  WPRD1filterShort[0]=WPRD1filterShort1;
  WPRD1filterShort[1]=WPRD1filterShort2; 
  WPRD1filterShort[2]=WPRD1filterShort3;
  WPRD1filterShort[3]=WPRD1filterShort4;
  WPRD1filterShort[4]=WPRD1filterShort5;
  WPRD1filterShort[5]=WPRD1filterShort6; 
  WPRD1filterShort[6]=WPRD1filterShort7;
  WPRD1filterShort[7]=WPRD1filterShort8; 
  WPRD1filterShort[8]=WPRD1filterShort9;
  WPRD1filterShort[9]=WPRD1filterShort10; 
  WPRD1filterShort[10]=WPRD1filterShort10;
  WPRD1filterShort[11]=WPRD1filterShort10;
  WPRD1filterShort[12]=WPRD1filterShort10;
  WPRD1filterShort[13]=WPRD1filterShort10; 
  WPRD1filterShort[14]=WPRD1filterShort10;
  WPRD1filterShort[15]=WPRD1filterShort10; 
  WPRD1filterShort[16]=WPRD1filterShort10; 
  WPRD1filterShort[17]=WPRD1filterShort10;
  WPRD1filterShort[18]=WPRD1filterShort10; 
 }

 lotsmin=0.10; 
 lotsmax=5.00;

// First check closed trades
 int trade,s;string sym;                      
 int trades=OrdersHistoryTotal();           
 for(trade=0;trade<trades;trade++)   // The most recent closed order has the largest position number, so this works forward
                                     // to allow the values of the most recent closed orders to be the ones which are recorded
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_HISTORY);

  if(OrderMagicNumber()!=magic) continue;
 
  sym=OrderSymbol();

  int D1bars=iBarShift(sym,PERIOD_D1,OrderCloseTime(),false);  // time difference in days
  if(D1bars>30) // = only interested in closed trades within the past month
   continue;
   
  for(s=0;s<Nsymbol;s++)
  {
   if(sym==symbol[s]) break;
  }
  
  ot[s]=OrderOpenTime();
  
 }

// Now check open orders
                       
 trades=OrdersTotal();           
 for(trade=0;trade<trades;trade++)// The most recent closed order has the largest position number, so this works forward
                                  // to allow the values of the most recent closed orders to be the ones which are recorded

 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderMagicNumber()!=magic) continue;

  sym=OrderSymbol();

  for(s=0;s<Nsymbol;s++)
  {
   if(sym==symbol[s]) break;
  }
  
  ot[s]=OrderOpenTime();
  
 } 
 
// HideTestIndicators(true);
 ManageOrders();
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
 if(DayOfWeek()!=0) SubmitOrders(); 
 ManageOrders();
 
 for(int s=0;s<Nsymbol;s++)
 {
  lastH1[s]=iTime(symbol[s],TimeFrame,0);
 }
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert utility functions                                         |
//+------------------------------------------------------------------+

void SubmitOrders()
{
 if(Norders>=Max) return;

 double atra,atrb,bid,ask,low,high,close,SL,TP,lots;string sym;
 int i;
 
 for(int s=0;s<Nsymbol;s++)
 {
  if(Norders>=Max) return; // in case new orders are submitted within the same loop
 
  sym=symbol[s];
  if(lastH1[s]==iTime(sym,TimeFrame,0)) continue;
   
  int checktime=iBarShift(sym,TimeFrame,ot[s],false); 
  if(checktime<bo) continue;

  bid=MarketInfo(sym,MODE_BID);
         
  if(!long[s])
  {   
   atra=iCustom(sym,TimeFrame,ciATRChannels,ATRPeriod,ATRMA_Periods,ATRMA_type,ATRMult_Factor1,ATRMult_Factor2,ATRMult_Factor3,1,1); 
   atrb=iCustom(sym,TimeFrame,ciATRChannels,ATRPeriod,ATRMA_Periods,ATRMA_type,ATRMult_Factor1,ATRMult_Factor2,ATRMult_Factor3,1,2); 
   high=iHigh(sym,TimeFrame,2);    
   close=iClose(sym,TimeFrame,1);
   if(high>=atrb && close<=atra)
   {  
    if(Filter(sym,true,bid,s))
    {   
     lots=CalculateLots();

     SL=iCustom(sym,TimeFrame,ciATRChannels,ATRPeriod,ATRMA_Periods,ATRMA_type,ATRMult_Factor1,ATRMult_Factor2,ATRMult_Factor3,0,1)-NormPoints(sym,SL); 
     TP=0.00;
   
     SendOrderLong(sym,lots,Slippage,SL,TP,comment,magic,0,Blue);
     ot[s]=TimeCurrent(); 
     Norders++;
     continue;
    }
   }
  }
  
  if(!short[s])
  {   
   atra=iCustom(sym,TimeFrame,ciATRChannels,ATRPeriod,ATRMA_Periods,ATRMA_type,ATRMult_Factor1,ATRMult_Factor2,ATRMult_Factor3,5,1); 
   atrb=iCustom(sym,TimeFrame,ciATRChannels,ATRPeriod,ATRMA_Periods,ATRMA_type,ATRMult_Factor1,ATRMult_Factor2,ATRMult_Factor3,5,2); 
   low=iLow(sym,TimeFrame,2);    
   close=iClose(sym,TimeFrame,1);
   if(low<=atrb && close>=atra)
   { 
    if(Filter(sym,false,bid,s))
    {  
     lots=CalculateLots();  

     SL=iCustom(sym,TimeFrame,ciATRChannels,ATRPeriod,ATRMA_Periods,ATRMA_type,ATRMult_Factor1,ATRMult_Factor2,ATRMult_Factor3,6,1)+NormPoints(sym,SL); 
     TP=0.00;

     SendOrderShort(sym,lots,Slippage,SL,TP,comment,magic,0,Red);
     ot[s]=TimeCurrent();
     Norders++;      
     continue;
    }
   }
  } 
 }
 
 return;
}
//+------------------------------------------------------------------+

void ManageOrders()
{
 Norders=0; 
 
 for(int s=0;s<Nsymbol;s++)
 {
  long[s]=false;
  short[s]=false;
 }
 
 double point,profit,atr1,atr2,bid;string sym;
 int pipstop,type,trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderMagicNumber()!=magic) continue;
  
  Norders++;
  type=OrderType();
  sym=OrderSymbol();
  
  for(s=0;s<Nsymbol;s++)
  {
   if(sym==symbol[s]) break;
  }

  if(type==OP_BUY) long[s]=true;
  if(type==OP_SELL) short[s]=true;

  profit=DetermineProfit(sym);  
  if(profit<=0) continue;

  bid=MarketInfo(sym,MODE_BID);

  if(type==OP_BUY)
  {
   atr1=iCustom(sym,TimeFrame,ciATRChannels,ATRPeriod,ATRMA_Periods,ATRMA_type,ATRMult_Factor1,ATRMult_Factor2,ATRMult_Factor3,3,1); 
   atr2=iCustom(sym,TimeFrame,ciATRChannels,ATRPeriod,ATRMA_Periods,ATRMA_type,ATRMult_Factor1,ATRMult_Factor2,ATRMult_Factor3,4,1); 
   
   if(bid>=atr2) ExitOrder(sym,true,false);
   if(bid>=atr1) FixedStopsB(sym,0,FS);
  }
  else if(type==OP_SELL)
  {    
   atr1=iCustom(sym,TimeFrame,ciATRChannels,ATRPeriod,ATRMA_Periods,ATRMA_type,ATRMult_Factor1,ATRMult_Factor2,ATRMult_Factor3,3,1); 
   atr2=iCustom(sym,TimeFrame,ciATRChannels,ATRPeriod,ATRMA_Periods,ATRMA_type,ATRMult_Factor1,ATRMult_Factor2,ATRMult_Factor3,2,1); 
   
   if(bid<=atr2) ExitOrder(sym,false,true); 
   if(bid<=atr1) FixedStopsB(sym,0,FS);
  }
 } 
 
 return;
}

//+------------------------------------------------------------------+
bool Filter(string sym, bool long, double bid, int s)
{
 int Trigger[2], totN=2, i;
 double value1,value2;

 for(i=0;i<totN;i++) Trigger[i]=-1;

 if(long) // long filters
 {
  for(i=0;i<totN;i++)
  {
   switch(i)
   {    
    case 0:
      Trigger[i]=TrendC(sym,true,s);
     break;
    case 1:
     value1=iOsMA(sym,PERIOD_H1,OsMAfastH1,OsMAslowH1,OsMAsignalH1,OsMAPriceH1,1); 
     if(value1>0) Trigger[i]=1;    
     break;                  
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
      Trigger[i]=TrendC(sym,false,s);
     break; 
    case 1:
     value1=iOsMA(sym,PERIOD_H1,OsMAfastH1,OsMAslowH1,OsMAsignalH1,OsMAPriceH1,1); 
     if(value1<0) Trigger[i]=1;    
     break;     
   } 
   if(Trigger[i]<0) return(false);       
  }
 }
  
// for(i=0;i<totN;i++) 
//  if(Trigger[i]<0) return(false); // one anti-trigger is sufficient to not trigger at all, so return false (to order)

 return(true);  // no anti-trigger:  so, return true (to order)
}
//+------------------------------------------------------------------+
void SendOrderLong(string sym, double vol, int slip, double sl, double tp, string comment="", int magic=0, datetime exp=0, color cl=CLR_NONE)
{
 double ask=MarketInfo(sym,MODE_ASK);
 int digits=MarketInfo(sym,MODE_DIGITS);
 sl=UniversalSLMin(sym,true,ask,sl);
 int err;
 GetSemaphore();
 for(int z=0;z<20;z++)
 {  
  if(OrderSend(sym,OP_BUY,NormLots(vol),ask,slip,NormalizeDouble(sl,digits),NormalizeDouble(tp,digits),comment,magic,exp,cl)<0)
  {  
   err = GetLastError();
   Print("OrderSend Long failed for ", sym);
   Print("Error: ", err, " Magic Number: ", magic);
   Print("Price: ", ask, " S/L ", sl, " T/P ", tp);
   if(err>4000) break;
   RefreshRates();
  }
  else
   break;
 }
 ReleaseSemaphore();
 return;
}
//+------------------------------------------------------------------+
void SendOrderShort(string sym, double vol, int slip, double sl, double tp, string comment="", int magic=0, datetime exp=0, color cl=CLR_NONE)
{  
 double bid=MarketInfo(sym,MODE_BID);
 int digits=MarketInfo(sym,MODE_DIGITS);
 sl=UniversalSLMin(sym,false,bid,sl);
 int err;
 GetSemaphore();
 for(int z=0;z<20;z++)
 {  
  if(OrderSend(sym,OP_SELL,NormLots(vol),bid,slip,NormalizeDouble(sl,digits),NormalizeDouble(tp,digits),comment,magic,exp,cl)<0)
  {  
   err = GetLastError();
   Print("OrderSend Short failed for ", sym);
   Print("Error: ", err, " Magic Number: ", magic);
   Print("Price: ", bid, " S/L ", sl, " T/P ", tp);   
   if(err>4000) break;
   RefreshRates();
  }
  else
   break;
 }
 ReleaseSemaphore();
 return;
}
//+------------------------------------------------------------------+
void CloseOrderLong(string sym, int ticket, double lots, int slip, color cl=CLR_NONE)
{
 int err;
 double bid=MarketInfo(sym,MODE_BID);

 GetSemaphore();
 for(int z=0;z<20;z++)
 {
  if(!OrderClose(ticket,NormLots(lots),bid,slip,cl))
  {  
   err = GetLastError();
   Print("OrderClose long failed for ", sym);
   Print("Error: ", err, " Ticket #: ", ticket);
   Print("Price: ", bid);   
   if(err>4000) 
    break;
   RefreshRates();
  }
  else
  break;
 }
 ReleaseSemaphore();
 return;
} 
//+------------------------------------------------------------------+

void CloseOrderShort(string sym,int ticket, double lots, int slip, color cl=CLR_NONE)
{
 int err;
 double ask=MarketInfo(sym,MODE_ASK);

 GetSemaphore();
 for(int z=0;z<20;z++)
 {
  if(!OrderClose(ticket,NormLots(lots),ask,slip,cl))
  {  
   err = GetLastError();
   Print("OrderClose long failed for ", sym);
   Print("Error: ", err, " Ticket #: ", ticket);
   Print("Price: ", ask);    
   if(err>4000) 
    break;
   RefreshRates();
  }
  else
  break;
 }
 ReleaseSemaphore();
 return;
} 
//+------------------------------------------------------------------+
void ModifyCompLong(string sym,double stopcal, double stopcrnt)
{
 stopcal=NormDigits(sym,stopcal);
 stopcrnt=NormDigits(sym,stopcrnt);

 if (stopcal==stopcrnt) return;
 
 if(stopcal>stopcrnt)
 {
  double bid=MarketInfo(sym,MODE_BID);
  double StopLevel=MarketInfo(sym,MODE_STOPLEVEL);
 
  if(stopcal>=bid-StopLevel) // check whether s/l is too close to market
   return;
                     
  ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Blue); 
 }
 return;
}
//+------------------------------------------------------------------+
void ModifyCompShort(string sym,double stopcal, double stopcrnt)
{
 stopcal=NormDigits(sym,stopcal);
 stopcrnt=NormDigits(sym,stopcrnt);

 if (stopcal==stopcrnt) return;

 double ask=MarketInfo(sym,MODE_ASK);
 double StopLevel=MarketInfo(sym,MODE_STOPLEVEL);
  
 if(stopcrnt==0)
 {

  if(stopcal<=ask+StopLevel) // check whether s/l is too close to market
   return; 
   
  ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red);     
 }
 else if(stopcal<stopcrnt&&stopcal!=0)
 {

  if(stopcal<=ask+StopLevel) // check whether s/l is too close to market
   return; 
 
  ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red); 
 }
 return;
}
//+------------------------------------------------------------------+
void ModifyOrder(int ticket, double price, double sl, double tp, datetime exp, color cl=CLR_NONE) // by Mike
{ 
 GetSemaphore();

 if(OrderModify(ticket,price,sl,tp,exp,cl)==false)
 {  
  Print("OrderModify failed, Error: ",GetLastError(), " Ticket Number: ", ticket);
  Print("Old price: ", OrderOpenPrice(), " Old S/L ", OrderStopLoss(), " Old T/P ", OrderTakeProfit(), " Ask/Bid ",Ask,", ",Bid);
  Print(" New Price: ", price, " New S/L ", sl, " New T/P ", tp, " New Expiration ", exp);
 }
 ReleaseSemaphore();
 return;
}

//+------------------------------------------------------------------+

void FixedStopsB(string sym,int PP,int PFS)
{
  if(PFS<=0) return;

  double stopcrnt,stopcal;
  double profit,profitpoint;

  stopcrnt=OrderStopLoss();
  profitpoint=NormPoints(sym,PP);  

//Long               

  if(OrderType()==OP_BUY)
  {
   double bid=MarketInfo(sym,MODE_BID);  
   profit=bid-OrderOpenPrice();
   
   if(profit>=profitpoint)
   {
    stopcal=TakeLong(sym,OrderOpenPrice(),PFS);
    ModifyCompLong(sym,stopcal,stopcrnt);   
   }
  }    
//Short 
  if(OrderType()==OP_SELL)
  {  
   double ask=MarketInfo(sym,MODE_ASK);  
   profit=OrderOpenPrice()-ask;
   
   if(profit>=profitpoint)
   {
    stopcal=TakeShort(sym,OrderOpenPrice(),PFS);
    ModifyCompShort(sym,stopcal,stopcrnt);
   }
  }  
 return(0);
} 
//+------------------------------------------------------------------+
double TakeLong(string sym,double price,int take)  // function to calculate takeprofit if long
{
 if(take<=0) return(0.0);

 return(NormDigits(sym,price+NormPoints(sym,take))); 
}
//+------------------------------------------------------------------+
double TakeShort(string sym,double price,int take)  // function to calculate takeprofit if short
{
 if(take<=0) return(0.0); // if no take profit
 return(NormDigits(sym,price-NormPoints(sym,take))); 
}
//+------------------------------------------------------------------+
double NormDigits(string sym,double price)
{
 int digits=MarketInfo(sym,MODE_DIGITS);
 return(NormalizeDouble(price,digits));
}
//+------------------------------------------------------------------+
double NormPoints(string sym,int pips)
{
 int digits=MarketInfo(sym,MODE_DIGITS);
 double point=MarketInfo(sym,MODE_POINT);
 return(NormalizeDouble(pips*point,digits));
}
//+------------------------------------------------------------------+
double NormLots(double lots)
{
 return(MathMax(NormalizeDouble(lotsmin,lotsprecision),NormalizeDouble(lots,lotsprecision)));
}
//+------------------------------------------------------------------+
void ExitOrder(string sym,bool flag_Long,bool flag_Short)
{
 if(OrderType()==OP_BUY&&flag_Long)
  CloseOrderLong(sym,OrderTicket(),OrderLots(),Slippage,Lime);
 else if(OrderType()==OP_SELL&&flag_Short)
  CloseOrderShort(sym,OrderTicket(),OrderLots(),Slippage,Lime);
 return;
}
//+------------------------------------------------------------------+
double UniversalSLMin(string sym,bool flag, double price, double sl)
{
 double slmin;
 if(flag)
 {
  slmin=NormDigits(sym,price-NormPoints(sym,SLMin));  
  return(MathMin(sl,slmin));
 }
 else
 {
  slmin=NormDigits(sym,price+NormPoints(sym,SLMin));  
  return(MathMax(sl,slmin)); 
 }
 return(sl);
}
//+------------------------------------------------------------------+
double DetermineProfit(string sym)
{
 double price;

 if(OrderType()==OP_BUY)  
 {
  price=MarketInfo(sym,MODE_BID);
  return(price-OrderOpenPrice());
 } 
 else if(OrderType()==OP_SELL)
 {
  price=MarketInfo(sym,MODE_ASK); 
  return(OrderOpenPrice()-price); 
 }
 return(0);
}
//+------------------------------------------------------------------+
int TrendC(string sym, bool flag, int s)
{
 double bid=MarketInfo(sym,MODE_BID);
 double value1=iWPR(sym,PERIOD_D1,WPRD1Period[s],0);
 double value2=iMA(sym,PERIOD_D1,Tr_MAPeriod,Tr_Shift,Tr_Method,Tr_Price,0);
 if(flag)
 {
  if(value1>WPRD1filterLong[s]&&bid>value2) return(1);
  else return(-1);
 }
 else
 {
  if(value1<WPRD1filterShort[s]&&bid<value2) return(1);
  else return(-1);
 }

 return(1);
}
//+------------------------------------------------------------------+
double CalculateLots()
{
 double equity=AccountEquity();

 if(equity<2500.)       return(0.1);
 else if(equity<5000.)  return(0.3);
 else if(equity<7500.)  return(0.5);
 else if(equity<12500.) return(1.0);
 else if(equity<15000.) return(2.0);
 else if(equity<17500.) return(3.0);
 else if(equity<20000.) return(4.0);
 else return(5.00);
 
 return(0);
}
//+------------------------------------------------------------------+
bool GetSemaphore()
{  
 if(!GlobalVariableCheck("SEMAPHORE")) GlobalVariableSet("SEMAPHORE",0);
 while(!IsStopped())
 {  
  if(GlobalVariableSetOnCondition("SEMAPHORE",1,0)==true)  
   break;
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


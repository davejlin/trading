//+----------------------------------------------------------------------+
//|                                                     ATC_template.mq4 |
//|                                                         David J. Lin |
//|ATC  model                                                    |
//|by Vinson Wells                                                       |
//|                                                                      |
//|_____________ submission                                              |
//|                                                                      |
//|Coded by David J. Lin (dave.j.lin@sbcglobal.net)                      |
//|Evanston, IL, September 8, 2007                                       |
//|                                                                      |
//|Copyright © 2007, David J. Lin                                        |
//+----------------------------------------------------------------------+
#property copyright ""
#property link      ""

// User adjustable parameters:

double Lots=1.0;               // number of lots (must be multiples of 0.1)

int OsMAfastH1=12;             // H1 OsMA
int OsMAslowH1=26;
int OsMAsignalH1=9; 
int OsMAPriceH1=PRICE_CLOSE;

int OsMAfastH4=12;             // H4 OsMA
int OsMAslowH4=26;
int OsMAsignalH4=9; 
int OsMAPriceH4=PRICE_CLOSE; 

int OsMAfastD1=12;             // D1 OsMA
int OsMAslowD1=26;
int OsMAsignalD1=9; 
int OsMAPriceD1=PRICE_CLOSE;

int    EnvPeriod=20;           // H1 Envelopes parameters (SL,TP,FS)
int    EnvMethod=MODE_SMA;        
int    EnvShift=0;
int    EnvPrice=PRICE_CLOSE; 
double EnvDev=0.20;

int    EnvPeriodD1=72;           // D1 Envelopes parameters (filter)
int    EnvMethodD1=MODE_EMA;        
int    EnvShiftD1=0;
int    EnvPriceD1=PRICE_CLOSE; 
double EnvDevD1=0.40;

int MAPeriod=10;               // H1 SMA 
int MAShift=0;
int MAMethod=MODE_SMA;
int MAPrice=PRICE_CLOSE;

int MAPeriod2=30;               // H1 SMMA for Order Exit
int MAShift2=0;
int MAMethod2=MODE_SMMA;
int MAPrice2=PRICE_CLOSE;

int CCIPeriod=17;               // H4 CCI 
int CCIPrice=PRICE_TYPICAL;
double CCIfilter=190;           // no trades if above(+) or below(-)

                                // EURUSD
double tpEnv1=2.00;             // fraction of Envelope height for initial TP 
double fsEnv1=0.20;             // fraction of Envelope height to activate fixed-stop 
                                // AUDUSD
double tpEnv2=1.80;             // fraction of Envelope height for initial TP 
double fsEnv2=1.00;             // fraction of Envelope height to activate fixed-stop 
                                // GBPJPY
double tpEnv3=2.00;             // fraction of Envelope height for initial TP 
double fsEnv3=0.50;             // fraction of Envelope height to activate fixed-stop 
                                // USDCAD
double tpEnv4=2.00;             // fraction of Envelope height for initial TP 
double fsEnv4=0.40;             // fraction of Envelope height to activate fixed-stop 
                                // all else (for testing)
double tpEnv5=1.00;             // fraction of Envelope height for initial TP 
double fsEnv5=0.50;             // fraction of Envelope height to activate fixed-stop 

bool mini=true;                 // true=mini-account, false=standard-account

int    FS=1;                    // fixed-stop value (BE+fs)

int wo=3;                       // hours window of opportunity (no triggers past this many consequtive closes above/below Fractal limits)
int bo=9;                       // bars black-out after order entry
 
// Trend Determination (supplementary condition to WPR D1 condition)

int Tr_MAPeriod=72;             // D1 MA Trend condition
int Tr_Shift=0;
int Tr_Method=MODE_EMA;
int Tr_Price=PRICE_CLOSE;

int WPRD1Period=18;             // D1 WPR filter (Group C)
double WPRD1filterLong=-26;     // above which to allow longs
double WPRD1filterShort=-74;    // below which to allow shorts

// Internal usage parameters:
int Slippage=3;
int lotsprecision=1;
int SLMin=32;                  // minimum universal SL
int Max=3;                     // maximum number of simultaneous orders

double lotsmin,lotsmax;
string comment="ATC BO";
string symbol[];
double ot[],tpEnv[],fsEnv[];
bool short[],long[];
int lastH1[];
int Nsymbol=1;
int Norders;
int TimeFrame=PERIOD_H1;       // main timeframe of EA
int magic=1111111114;
string ciProductivity ="Productivity";
string ciWaddahCamarilla ="Waddah_Attar_Dayly_CAMARILLA";
string ciDeltaforce ="Deltaforce";
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//----

 if(!GlobalVariableCheck("SEMAPHORE")) GlobalVariableSet("SEMAPHORE",0);

 ArrayResize(symbol,Nsymbol);
 ArrayResize(ot,Nsymbol);   
 ArrayResize(short,Nsymbol); 
 ArrayResize(long,Nsymbol);  
 ArrayResize(lastH1,Nsymbol);  
 ArrayResize(tpEnv,Nsymbol);
 ArrayResize(fsEnv,Nsymbol); 

 symbol[0]=Symbol();
/*
 if(mini)
 {
  symbol[0]="EURUSDm";
  symbol[1]="AUDUSDm"; 
  symbol[2]="GBPJPYm";
  symbol[3]="USDCADm"; 
  symbol[4]="EURJPYm";
  symbol[5]="EURGBPm"; 
  symbol[6]="EURCHFm";
  symbol[7]="USDJPYm";
  symbol[8]="USDCHFm";
  symbol[9]="AUDNZDm"; 
  symbol[10]="GBPCHFm";
  symbol[11]="NZDJPYm"; 
  symbol[12]="CHFJPYm";
  symbol[13]="GBPUSDm"; 
  symbol[14]="EURAUDm";
  symbol[15]="AUDCADm";
  symbol[16]="EURCADm"; 
  symbol[17]="NZDUSDm";  
  symbol[18]="AUDJPYm";  
 }
 else
 {
  symbol[0]="EURUSD";
  symbol[1]="AUDUSD"; 
  symbol[2]="GBPJPY";
  symbol[3]="USDCAD"; 
  symbol[4]="EURJPY";
  symbol[5]="EURGBP"; 
  symbol[6]="EURCHF";
  symbol[7]="USDJPY";
  symbol[8]="USDCHF";
  symbol[9]="AUDNZD"; 
  symbol[10]="GBPCHF";
  symbol[11]="NZDJPY"; 
  symbol[12]="CHFJPY";
  symbol[13]="GBPUSD"; 
  symbol[14]="EURAUD";
  symbol[15]="AUDCAD";
  symbol[16]="EURCAD"; 
  symbol[17]="NZDUSD";  
  symbol[18]="AUDJPY";  
 }  
*/

 tpEnv[0]=tpEnv1;
/*
 tpEnv[1]=tpEnv2; 
 tpEnv[2]=tpEnv3;
 tpEnv[3]=tpEnv4;
 tpEnv[4]=tpEnv5;
 tpEnv[5]=tpEnv5; 
 tpEnv[6]=tpEnv5;
 tpEnv[7]=tpEnv5; 
 tpEnv[8]=tpEnv5;
 tpEnv[9]=tpEnv5; 
 tpEnv[10]=tpEnv5;
 tpEnv[11]=tpEnv5;
 tpEnv[12]=tpEnv5;
 tpEnv[13]=tpEnv5; 
 tpEnv[14]=tpEnv5;
 tpEnv[15]=tpEnv5; 
 tpEnv[16]=tpEnv5; 
 tpEnv[17]=tpEnv5;
 tpEnv[18]=tpEnv5; 
*/
 fsEnv[0]=fsEnv1;
/*
 fsEnv[1]=fsEnv2; 
 fsEnv[2]=fsEnv3;
 fsEnv[3]=fsEnv4;
 fsEnv[4]=fsEnv5;
 fsEnv[5]=fsEnv5; 
 fsEnv[6]=fsEnv5;
 fsEnv[7]=fsEnv5; 
 fsEnv[8]=fsEnv5;
 fsEnv[9]=fsEnv5; 
 fsEnv[10]=fsEnv5;
 fsEnv[11]=fsEnv5;
 fsEnv[12]=fsEnv5;
 fsEnv[13]=fsEnv5; 
 fsEnv[14]=fsEnv5;
 fsEnv[15]=fsEnv5; 
 fsEnv[16]=fsEnv5; 
 fsEnv[17]=fsEnv5;
 fsEnv[18]=fsEnv5;  
*/
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
 
 HideTestIndicators(true);
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

 double range,bid,ask,low,high,close,EnvUp,EnvDn,EnvDiff,SL,TP,lots;string sym;
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
   if(1<=1)
   { 
    low=iLow(sym,TimeFrame,1);
    
    if(1==1)   
    {
     if(Filter(sym,true,bid))
     {
      EnvUp=iEnvelopes(sym,TimeFrame,EnvPeriod,EnvMethod,EnvShift,EnvPrice,EnvDev,MODE_UPPER,0);
      EnvDn=iEnvelopes(sym,TimeFrame,EnvPeriod,EnvMethod,EnvShift,EnvPrice,EnvDev,MODE_LOWER,0);
      EnvDiff=EnvUp-EnvDn;
   
      ask=MarketInfo(sym,MODE_ASK);
      high=iHigh(sym,TimeFrame,1);
  
      range=high-low;
      SL=NormDigits(sym,range);
      
      lots=Lots;
    
      TP=NormDigits(sym,ask+tpEnv[s]*EnvDiff);
   
      SendOrderLong(sym,lots,Slippage,SL,TP,comment,magic,0,Blue);
      ot[s]=TimeCurrent(); 
      Norders++;
      continue;
     }
    }
   }
  }
  
  if(!short[s])
  {     
   if(1<=1)
   { 
    high=iHigh(sym,TimeFrame,1);
    
    if(1==1)   
    {
     if(Filter(sym,false,bid))
     {  
      EnvUp=iEnvelopes(sym,TimeFrame,EnvPeriod,EnvMethod,EnvShift,EnvPrice,EnvDev,MODE_UPPER,0);
      EnvDn=iEnvelopes(sym,TimeFrame,EnvPeriod,EnvMethod,EnvShift,EnvPrice,EnvDev,MODE_LOWER,0);
      EnvDiff=EnvUp-EnvDn;

      low=iLow(sym,TimeFrame,1);
      range=high-low;
      
      SL=NormDigits(sym,range);
      lots=Lots;  

      TP=NormDigits(sym,bid-tpEnv[s]*EnvDiff);   

      SendOrderShort(sym,lots,Slippage,SL,TP,comment,magic,0,Red);
      ot[s]=TimeCurrent();
      Norders++;      
      continue;
     }
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
 
 double point,profit;string sym;
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

  int target=EnvTarget(sym,fsEnv[s],TimeFrame,EnvPeriod,EnvMethod,EnvShift,EnvPrice,EnvDev);
  FixedStopsB(sym,target,FS);

  if(lastH1[s]==iTime(sym,TimeFrame,0)) continue;

  point=MarketInfo(sym,MODE_POINT);

  if(type==OP_BUY)
  {
  
   
  }
  else if(type==OP_SELL)
  {    

  }

 } 
 
 return;
}

//+------------------------------------------------------------------+
bool Filter(string sym, bool long, double bid)
{
 int Trigger[1], totN=1, i;
 double value1,value2;

 for(i=0;i<totN;i++) Trigger[i]=-1;

 if(long) // long filters
 {
  for(i=0;i<totN;i++)
  {
   switch(i)
   {    
    case 0:
      Trigger[i]=TrendC(sym,true,WPRD1Period,WPRD1filterLong);
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
      Trigger[i]=TrendC(sym,false,WPRD1Period,WPRD1filterShort);
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
int EnvTarget(string sym,double factor,int tf, int period,int method,int shift,int price,double dev) // return pip height of Envelope
{
 double point=MarketInfo(sym,MODE_POINT);
 double EnvUp=iEnvelopes(sym,tf,period,method,shift,price,dev,MODE_UPPER,0);
 double EnvDn=iEnvelopes(sym,tf,period,method,shift,price,dev,MODE_LOWER,0);

 return(factor*(EnvUp-EnvDn)/point);
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
int TrendC(string sym, bool flag, int period, double limit) // Group C - trades only in direction of trend ONLY
{
 double bid=MarketInfo(sym,MODE_BID);
 double value1=iWPR(sym,PERIOD_D1,period,0);
 double value2=iMA(sym,PERIOD_D1,Tr_MAPeriod,Tr_Shift,Tr_Method,Tr_Price,0);
 if(flag)
 {
  if(value1>limit&&bid>value2) return(1);
  else return(-1);
 }
 else
 {
  if(value1<limit&&bid<value2) return(1);
  else return(-1);
 }

 return(1);
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


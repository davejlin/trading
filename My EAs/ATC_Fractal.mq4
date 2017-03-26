//+----------------------------------------------------------------------+
//|                                                      ATC_Fractal.mq4 |
//|                                                         David J. Lin |
//|ATC Fractal model                                                     |
//|by Vinson Wells                                                       |
//|                                                                      |
//|Vinson Wells' submission                                              |
//|                                                                      |
//|Coded by David J. Lin (dave.j.lin@sbcglobal.net)                      |
//|Evanston, IL, August 29, 2007                                         |
//|                                                                      |
//|Copyright © 2007, David J. Lin                                        |
//+----------------------------------------------------------------------+
#property copyright ""
#property link      ""

// User adjustable parameters:

// double Lots=1.0;               // number of basic lots (must be multiples of 0.1)

double PSARStep=0.003;         // H4 PSAR step
double PSARMax=0.2;            // PSAR max

int SchaffMAShort=18;          // H4 Schaff Trend filter
int SchaffMALong=36;
int SchaffCycle=10;
int SchaffBarsCount=300;
double SchafffilterLong=50;    // above which to allow longs
double SchafffilterShort=50;   // below which to allow shorts

int OsMAfastH4=16;             // H4 OsMA
int OsMAslowH4=32;
int OsMAsignalH4=12; 
int OsMAPriceH4=PRICE_CLOSE; 

int OsMAfastD1=12;             // D1 OsMA
int OsMAslowD1=26;
int OsMAsignalD1=6; 
int OsMAPriceD1=PRICE_CLOSE;

int OsMAfastW1=12;             // W1 OsMA
int OsMAslowW1=26;
int OsMAsignalW1=6; 
int OsMAPriceW1=PRICE_CLOSE;

// D1 OsMA Ascending/Descending filter
                                           // D1 OsMA filter
int OsMAAcc_OsMAfast=12;                   // OsMA fast period
int OsMAAcc_OsMAslow=26;                   // OsMA slow period 
int OsMAAcc_OsMAsignal=9;                  // OsMA signal period
int OsMAAcc_OsMAPrice=PRICE_CLOSE;         // OsMA price

int    EnvPeriod=20;           // Envelopes parameters (SL,TP,FS)
int    EnvMethod=MODE_SMA;        
int    EnvShift=0;
int    EnvPrice=PRICE_CLOSE; 
double EnvDev=0.30;

int MAPeriod=24;               // H4 EMA for Order Exit
int MAShift=0;
int MAMethod=MODE_EMA;
int MAPrice=PRICE_CLOSE;

int MAPeriod2=72;              // H4 EMA for filter
int MAShift2=0;
int MAMethod2=MODE_EMA;
int MAPrice2=PRICE_CLOSE;

int MAPeriod3=72;              // D1 EMA for filter
int MAShift3=0;
int MAMethod3=MODE_EMA;
int MAPrice3=PRICE_CLOSE;

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
                                // EURGBP
double tpEnv5=0.60;             // fraction of Envelope height for initial TP 
double fsEnv5=0.20;             // fraction of Envelope height to activate fixed-stop 
                                // USDJPY
double tpEnv6=0.60;             // fraction of Envelope height for initial TP 
double fsEnv6=0.20;             // fraction of Envelope height to activate fixed-stop 

                                // all else (for testing)
double tpEnv7=1.00;             // fraction of Envelope height for initial TP 
double fsEnv7=0.50;             // fraction of Envelope height to activate fixed-stop 

//bool mini=false;                // true=mini-account, false=standard-account

int    FS=1;                   // fixed-stop value (BE+fs)

int wo=3;                      // hours window of opportunity (no triggers past this many consequtive closes above/below Fractal limits)
int bo=9;                      // bars black-out after order entry

// H1 CCI filter 

int CCIPeriod=18;              // H1 CCI 
int CCIPrice=PRICE_TYPICAL;
double CCIfilter=330;          // above(+)=no longs; below(-)=no shorts
int CCIblackout=4;             // hours blackout after extreme CCI readings 

// Internal usage parameters:
int Slippage=3;
int lotsprecision=1;
int SLMin=32;                  // minimum universal SL
int Max=3;                     // maximum number of simultaneous orders

double lotsmin,lotsmax;
string comment="ATC Fractal";
string symbol[];
double ot[],FrChUp[],FrChDn[],tpEnv[],fsEnv[];
bool short[],long[];
int lastH4[];
int Nsymbol=6;
int Norders;
int TimeFrame=PERIOD_H4;       // main timeframe of EA
int magic=1111111111;
string ciSchaffTrend ="Schaff_Trend";
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
 ArrayResize(FrChUp,Nsymbol); 
 ArrayResize(FrChDn,Nsymbol);   
 ArrayResize(short,Nsymbol); 
 ArrayResize(long,Nsymbol);  
 ArrayResize(lastH4,Nsymbol);  
 ArrayResize(tpEnv,Nsymbol);
 ArrayResize(fsEnv,Nsymbol); 

 if(IsTesting())
 {
  symbol[0]=Symbol(); 
  tpEnv[0]=tpEnv1; 
  fsEnv[0]=fsEnv1;   
 }
 else
 {
  bool mini;
  if(StringFind(Symbol(),"m")>0) mini=true;
  else mini=false; 

  if(mini)
  {
   symbol[0]="EURUSDm";
   symbol[1]="AUDUSDm"; 
   symbol[2]="GBPJPYm";
   symbol[3]="USDCADm"; 
   symbol[4]="EURGBPm"; 
   symbol[5]="USDJPYm";  
   symbol[6]="EURJPYm";
   symbol[7]="EURCHFm";
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
   symbol[4]="EURGBP"; 
   symbol[5]="USDJPY";    
   symbol[6]="EURJPY";
   symbol[7]="EURCHF";
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
 
  tpEnv[0]=tpEnv1;
  tpEnv[1]=tpEnv2; 
  tpEnv[2]=tpEnv3;
  tpEnv[3]=tpEnv4;
  tpEnv[4]=tpEnv5;
  tpEnv[5]=tpEnv6;  
  tpEnv[6]=tpEnv7;
  tpEnv[7]=tpEnv7; 
  tpEnv[8]=tpEnv7;
  tpEnv[9]=tpEnv7; 
  tpEnv[10]=tpEnv7;
  tpEnv[11]=tpEnv7;
  tpEnv[12]=tpEnv7;
  tpEnv[13]=tpEnv7; 
  tpEnv[14]=tpEnv7;
  tpEnv[15]=tpEnv7; 
  tpEnv[16]=tpEnv7; 
  tpEnv[17]=tpEnv7;
  tpEnv[18]=tpEnv7;  

  fsEnv[0]=fsEnv1;
  fsEnv[1]=fsEnv2; 
  fsEnv[2]=fsEnv3;
  fsEnv[3]=fsEnv4;
  fsEnv[4]=fsEnv5;
  fsEnv[5]=fsEnv6; 
  fsEnv[6]=fsEnv7;
  fsEnv[7]=fsEnv7; 
  fsEnv[8]=fsEnv7;
  fsEnv[9]=fsEnv7; 
  fsEnv[10]=fsEnv7;
  fsEnv[11]=fsEnv7;
  fsEnv[12]=fsEnv7;
  fsEnv[13]=fsEnv7; 
  fsEnv[14]=fsEnv7;
  fsEnv[15]=fsEnv7; 
  fsEnv[16]=fsEnv7; 
  fsEnv[17]=fsEnv7;
  fsEnv[18]=fsEnv7;   
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
 
 HideTestIndicators(true);
 FractalChannel();
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
  lastH4[s]=iTime(symbol[s],TimeFrame,0);
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
 int Nup,Ndn,i;
 
 for(int s=0;s<Nsymbol;s++)
 {
  if(Norders>=Max) return; // in case new orders are submitted within the same loop
 
  sym=symbol[s];
  if(lastH4[s]==iTime(sym,TimeFrame,0)) continue;

  FractalChannel(); // needed here to ensure most recent FC values
   
  int checktime=iBarShift(sym,TimeFrame,ot[s],false); 
  if(checktime<bo) continue;

  Nup=0; Ndn=0;
  for(i=1;i<=100;i++)
  {
   close=iClose(sym,TimeFrame,i);
   if (close>FrChUp[s]) Nup++;
   else break;
  }

  for(i=1;i<=100;i++)
  {
   close=iClose(sym,TimeFrame,i);  
   if (close<FrChDn[s]) Ndn++;
   else break;   
  }

  bid=MarketInfo(sym,MODE_BID);
   
  if(!long[s])
  {     
   if(Nup<=wo)
   { 
    low=iLow(sym,TimeFrame,1);
    if(low>FrChUp[s] && bid>FrChUp[s])   
    {
     if(Filter(sym,true,bid))
     {
      EnvUp=iEnvelopes(sym,TimeFrame,EnvPeriod,EnvMethod,EnvShift,EnvPrice,EnvDev,MODE_UPPER,0);
      EnvDn=iEnvelopes(sym,TimeFrame,EnvPeriod,EnvMethod,EnvShift,EnvPrice,EnvDev,MODE_LOWER,0);
      EnvDiff=EnvUp-EnvDn;
   
      ask=MarketInfo(sym,MODE_ASK);
      high=iHigh(sym,TimeFrame,1);
  
      range=high-low;
      SL=NormDigits(sym,FrChUp[s]-range);
      
      lots=CalculateLots();
    
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
   if(Ndn<=wo)
   { 
    high=iHigh(sym,TimeFrame,1);
    
    if(high<FrChDn[s]&& bid<FrChDn[s])   
    {
     if(Filter(sym,false,bid))
     {  
      EnvUp=iEnvelopes(sym,TimeFrame,EnvPeriod,EnvMethod,EnvShift,EnvPrice,EnvDev,MODE_UPPER,0);
      EnvDn=iEnvelopes(sym,TimeFrame,EnvPeriod,EnvMethod,EnvShift,EnvPrice,EnvDev,MODE_LOWER,0);
      EnvDiff=EnvUp-EnvDn;

      low=iLow(sym,TimeFrame,1);
      range=high-low;
      
      SL=NormDigits(sym,FrChDn[s]+range);
      lots=CalculateLots();  

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
 
 double close,ma,point,profit;string sym;
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

  if(lastH4[s]==iTime(sym,TimeFrame,0)) continue;

  close=iClose(sym,TimeFrame,1); 
  ma=iMA(sym,TimeFrame,MAPeriod,MAShift,MAMethod,MAPrice,1); 
  point=MarketInfo(sym,MODE_POINT);

  if(type==OP_BUY)
  {
  
   if(close<ma) 
   {
    ExitOrder(sym,true,false);
    long[s]=false;
   }
   
   if(close<FrChUp[s])
   {   
    pipstop=0.5*profit/point;
    FixedStopsB(sym,0,pipstop);
   }
   
  }
  else if(type==OP_SELL)
  {    

   if(close>ma) 
   {
    ExitOrder(sym,false,true);  
    short[s]=false;
   }
   
   if(close>FrChDn[s])
   {
    pipstop=0.5*profit/point;
    FixedStopsB(sym,0,pipstop);      
   }

  }

 } 
 
 return;
}

//+------------------------------------------------------------------+
bool Filter(string sym, bool long, double bid)
{
 int Trigger[9], totN=9, i;
 double value1,value2;

 for(i=0;i<totN;i++) Trigger[i]=-1;

 if(long) // long filters
 {
  for(i=0;i<totN;i++)
  {
   switch(i)
   {    
    case 0:
     value1=iCustom(sym,TimeFrame,ciSchaffTrend,SchaffMAShort,SchaffMALong,SchaffCycle,SchaffBarsCount,0,0);
     if(value1>SchafffilterLong) Trigger[i]=1;
     break;     
    case 1:
     value1=iSAR(sym,TimeFrame,PSARStep,PSARMax,0);
     if(bid>value1) Trigger[i]=1;
     break;   
    case 2:
     value1=iOsMA(sym,TimeFrame,OsMAfastH4,OsMAslowH4,OsMAsignalH4,OsMAPriceH4,1); 
     if(value1>0) Trigger[i]=1;    
     break;  
    case 3:
     value1=iOsMA(sym,PERIOD_D1,OsMAfastD1,OsMAslowD1,OsMAsignalD1,OsMAPriceD1,0); 
     if(value1>0) Trigger[i]=1;    
     break;     
    case 4:
     value1=iOsMA(sym,PERIOD_W1,OsMAfastW1,OsMAslowW1,OsMAsignalW1,OsMAPriceW1,0); 
     if(value1>0) Trigger[i]=1;    
     break;     
    case 5:
     value1=iMA(sym,TimeFrame,MAPeriod2,MAShift2,MAMethod2,MAPrice2,1);      
     value2=iClose(sym,TimeFrame,1);     
     if(value2>value1) Trigger[i]=1;
     break;
    case 6:
     value1=iMA(sym,PERIOD_D1,MAPeriod3,MAShift3,MAMethod3,MAPrice3,1);      
     value2=iClose(sym,PERIOD_D1,1);
     if(value2>value1) Trigger[i]=1;
     break;   
    case 7:
     if(FilterCCIH1(sym,true)) Trigger[i]=1;    
     break;
    case 8:
     if(FilterOsMAAcc(true)) Trigger[i]=1;
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
     value1=iCustom(sym,TimeFrame,ciSchaffTrend,SchaffMAShort,SchaffMALong,SchaffCycle,SchaffBarsCount,0,0);
     if(value1<SchafffilterShort) Trigger[i]=1;
     break;  
    case 1:
     value1=iSAR(sym,TimeFrame,PSARStep,PSARMax,0);
     if(bid<value1) Trigger[i]=1;
     break;  
    case 2:
     value1=iOsMA(sym,TimeFrame,OsMAfastH4,OsMAslowH4,OsMAsignalH4,OsMAPriceH4,1); 
     if(value1<0) Trigger[i]=1;    
     break;  
    case 3:
     value1=iOsMA(sym,PERIOD_D1,OsMAfastD1,OsMAslowD1,OsMAsignalD1,OsMAPriceD1,0); 
     if(value1<0) Trigger[i]=1; 
     break; 
    case 4:
     value1=iOsMA(sym,PERIOD_W1,OsMAfastW1,OsMAslowW1,OsMAsignalW1,OsMAPriceW1,0); 
     if(value1<0) Trigger[i]=1;    
     break;         
    case 5:
     value1=iMA(sym,TimeFrame,MAPeriod2,MAShift2,MAMethod2,MAPrice2,1);      
     value2=iClose(sym,TimeFrame,1);     
     if(value2<value1) Trigger[i]=1;
     break;   
    case 6:
     value1=iMA(sym,PERIOD_D1,MAPeriod3,MAShift3,MAMethod3,MAPrice3,1);      
     value2=iClose(sym,PERIOD_D1,1);
     if(value2<value1) Trigger[i]=1;
     break;                                                 
    case 7:
     if(FilterCCIH1(sym,false)) Trigger[i]=1;    
     break;
    case 8:
     if(FilterOsMAAcc(false)) Trigger[i]=1;
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
void FractalChannel()
{
 int i,s;
 for(s=0;s<Nsymbol;s++)
 {
  for(i=1;i<1000;i++)
  {
   if(iFractals(symbol[s],TimeFrame, MODE_UPPER, i)<=0) continue;
   FrChUp[s]=iHigh(symbol[s],TimeFrame,i);
   break;
  }

  for(i=1;i<1000;i++)
  {
   if(iFractals(symbol[s],TimeFrame, MODE_LOWER, i)<=0) continue;
   FrChDn[s]=iLow(symbol[s],TimeFrame,i);
   break;
  }  
 }
 return;
} 
//+------------------------------------------------------------------+
bool FilterCCIH1(string sym, bool flag) // H1 CCI Filter
{
 double value1; int i;

 if(flag)
 {
  for(i=1;i<=CCIblackout;i++)
  {
   value1=iCCI(sym,PERIOD_H1,CCIPeriod,CCIPrice,i);  
   if(value1>CCIfilter) return(false); 
  }
 }
 else
 {
  for(i=1;i<=CCIblackout;i++)
  {
   value1=iCCI(sym,PERIOD_H1,CCIPeriod,CCIPrice,i);  
   if(value1<-CCIfilter) return(false); 
  }
 }
 return(true);
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

bool FilterOsMAAcc(bool long) // D1 OsMA filter
{
 double osma1=iOsMA(NULL,PERIOD_D1,OsMAAcc_OsMAfast,OsMAAcc_OsMAslow,OsMAAcc_OsMAsignal,OsMAAcc_OsMAPrice,1); 
 double osma2=iOsMA(NULL,PERIOD_D1,OsMAAcc_OsMAfast,OsMAAcc_OsMAslow,OsMAAcc_OsMAsignal,OsMAAcc_OsMAPrice,2); 

 if(long)
 {
  if(osma1>osma2) return(true);
  else return(false);
 }
 else
 {
  if(osma1<osma2) return(true);
  else return(false); 
 }
 return(true);
}
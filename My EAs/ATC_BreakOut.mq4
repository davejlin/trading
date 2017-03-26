//+----------------------------------------------------------------------+
//|                                                     ATC_BreakOut.mq4 |
//|                                                         David J. Lin |
//|ATC BreakOut model                                                    |
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

// double Lots=1.0;                // number of lots (must be multiples of 0.1)

int MAPeriod=10;                // H1 SMA (trigger)
int MAShift=0;
int MAMethod=MODE_SMA;
int MAPrice=PRICE_CLOSE;

int trig=5;                     // pips additional beyond trigEnv for trigger 
int wo=6;                       // hours window of opportunity after MA cross

int MAPeriod2=30;               // H1 SMMA for Order Exit
int MAShift2=0;
int MAMethod2=MODE_SMMA;
int MAPrice2=PRICE_CLOSE;

int OsMAfastH1=12;              // H1 OsMA
int OsMAslowH1=26;
int OsMAsignalH1=9; 
int OsMAPriceH1=PRICE_CLOSE;

int OsMAfastH4=12;              // H4 OsMA
int OsMAslowH4=26;
int OsMAsignalH4=9; 
int OsMAPriceH4=PRICE_CLOSE; 

int OsMAfastD1=12;              // D1 OsMA
int OsMAslowD1=26;
int OsMAsignalD1=9; 
int OsMAPriceD1=PRICE_CLOSE;

// D1 OsMA Ascending/Descending filter
                                           // D1 OsMA filter
int OsMAAcc_OsMAfast=12;                   // OsMA fast period
int OsMAAcc_OsMAslow=26;                   // OsMA slow period 
int OsMAAcc_OsMAsignal=9;                  // OsMA signal period
int OsMAAcc_OsMAPrice=PRICE_CLOSE;         // OsMA price

int    EnvPeriod=20;            // H1 Envelopes parameters (SL,TP,FS)
int    EnvMethod=MODE_SMA;        
int    EnvShift=0;
int    EnvPrice=PRICE_CLOSE; 
double EnvDev=0.20;

int    EnvPeriodD1=72;          // D1 Envelopes parameters (filter)
int    EnvMethodD1=MODE_EMA;        
int    EnvShiftD1=0;
int    EnvPriceD1=PRICE_CLOSE; 
double EnvDevD1=0.40;

int CCIPeriod=17;               // H4 CCI 
int CCIPrice=PRICE_TYPICAL;
double CCIfilter=190;           // no trades if above(+) or below(-)

int ProductivityH1=20;          // H1 Productivity period
int ProductivityH4=20;          // H4 Productivity period
int ProductivityD1=20;          // D1 Productivity period

// Trend Determination (supplementary condition to WPR D1 condition)

int Tr_MAPeriod=72;             // D1 MA Trend condition
int Tr_Shift=0;
int Tr_Method=MODE_EMA;
int Tr_Price=PRICE_CLOSE;

int WPRD1Period=18;             // D1 WPR filter (Group C)
int WPRH4Period=36;             // H4 WPR filter (Group C)
int WPRH1Period=60;             // H1 WPR filter (Group C)
double WPRfilterLong=-20;       // above which to allow longs
double WPRfilterShort=-70;      // below which to allow shorts

double tpEnv=4.00;              // fraction of Envelope height for initial TP 
double fsEnv=0.75;              // fraction of Envelope height to activate fixed-stop 

                                // AUDUSD
double trigEnv1=0.20;           // fraction of Envelope for trigger, "triggerpips"
double DFfilter1=0.00100;       // Deltaforce value above which to enter (auto adjusted for JPY pairs)
double PLimit1=6.0;             // combined total above which to allow triggers

                                // USDCAD
double trigEnv2=0.60;           // fraction of Envelope for trigger, "triggerpips"
double DFfilter2=0.00200;       // Deltaforce value above which to enter (auto adjusted for JPY pairs)
double PLimit2=7.0;             // combined total above which to allow triggers

                                // EURAUD
double trigEnv3=0.40;           // fraction of Envelope for trigger, "triggerpips"
double DFfilter3=0.00200;       // Deltaforce value above which to enter (auto adjusted for JPY pairs)
double PLimit3=6.0;             // combined total above which to allow triggers

                                // EURUSD
double trigEnv4=0.50;           // fraction of Envelope for trigger, "triggerpips"
double DFfilter4=0.00200;       // Deltaforce value above which to enter (auto adjusted for JPY pairs)
double PLimit4=7.0;             // combined total above which to allow triggers

                                // USDCHF
double trigEnv5=0.70;           // fraction of Envelope for trigger, "triggerpips"
double DFfilter5=0.00200;       // Deltaforce value above which to enter (auto adjusted for JPY pairs)
double PLimit5=7.0;             // combined total above which to allow triggers

                                // USDJPY
double trigEnv6=0.50;           // fraction of Envelope for trigger, "triggerpips"
double DFfilter6=0.20000;       // Deltaforce value above which to enter (auto adjusted for JPY pairs)
double PLimit6=7.0;             // combined total above which to allow triggers

                                // EURJPY
double trigEnv7=0.40;           // fraction of Envelope for trigger, "triggerpips"
double DFfilter7=0.70000;       // Deltaforce value above which to enter (auto adjusted for JPY pairs)
double PLimit7=7.0;             // combined total above which to allow triggers

                                // GBPJPY
double trigEnv8=0.70;           // fraction of Envelope for trigger, "triggerpips"
double DFfilter8=0.20000;       // Deltaforce value above which to enter (auto adjusted for JPY pairs)
double PLimit8=5.0;             // combined total above which to allow triggers

                                // GBPCHF
double trigEnv9=1.00;           // fraction of Envelope for trigger, "triggerpips"
double DFfilter9=0.00200;       // Deltaforce value above which to enter (auto adjusted for JPY pairs)
double PLimit9=3.0;             // combined total above which to allow triggers

                                // all others
double trigEnv10=0.25;          // fraction of Envelope for trigger, "triggerpips"
double DFfilter10=0.00200;      // Deltaforce value above which to enter (auto adjusted for JPY pairs)
double PLimit10=7.0;            // combined total above which to allow triggers

// bool mini=false;                 // true=mini-account, false=standard-account

int FS=5;                       // fixed-stop value (BE+fs)
int SL=40;                      // pips above/below Envelope bands for initial SL
int bo=1;                       // bars black-out after order entry
 
// Internal usage parameters:
int Slippage=3;
int lotsprecision=1;
int SLMin=32;                  // minimum universal SL
int Max=3;                     // maximum number of simultaneous orders

double lotsmin,lotsmax;
string comment="ATC BreakOut";
string symbol[];
double ot[],trigEnv[],DFfilter[],PLimit[];
bool short[],long[];
int lastH1[];
int Nsymbol=19;
int Norders;
int TimeFrame=PERIOD_H1;       // main timeframe of EA
int TimeFrameFrCh=PERIOD_H4;   // FractalChannel H4 filter
int magic=1111111114;

string ciWaddahCamarilla ="Waddah_Attar_Dayly_CAMARILLA";
string ciDeltaforce ="Deltaforce";
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
 ArrayResize(trigEnv,Nsymbol);
 ArrayResize(DFfilter,Nsymbol); 
 ArrayResize(PLimit,Nsymbol);    

 if(IsTesting())
 {
  symbol[0]=Symbol(); 
  trigEnv[0]=trigEnv1; 
  DFfilter[0]=DFfilter1;
  PLimit[0]=PLimit1;  
 }
 else
 {
  bool mini;
  if(StringFind(Symbol(),"m")>0) mini=true;
  else mini=false; 
  
  if(mini)
  {
   symbol[0]="AUDUSDm"; 
   symbol[1]="USDCADm";
   symbol[2]="EURAUDm";
   symbol[3]="EURUSDm";
   symbol[4]="USDCHFm";  
   symbol[5]="USDJPYm";
   symbol[6]="EURJPYm";  
   symbol[7]="GBPJPYm";
   symbol[8]="GBPCHFm";  
   symbol[9]="EURCADm"; 
   symbol[10]="EURGBPm"; 
   symbol[11]="EURCHFm";
   symbol[12]="AUDNZDm"; 
   symbol[13]="NZDJPYm"; 
   symbol[14]="CHFJPYm";
   symbol[15]="GBPUSDm"; 
   symbol[16]="AUDCADm";
   symbol[17]="NZDUSDm";  
   symbol[18]="AUDJPYm";  
  }
  else
  {
   symbol[0]="AUDUSD"; 
   symbol[1]="USDCAD";
   symbol[2]="EURAUD";
   symbol[3]="EURUSD";
   symbol[4]="USDCHF";  
   symbol[5]="USDJPY";
   symbol[6]="EURJPY";  
   symbol[7]="GBPJPY";
   symbol[8]="GBPCHF";   
   symbol[9]="EURCAD";   
   symbol[10]="EURGBP"; 
   symbol[11]="EURCHF";
   symbol[12]="AUDNZD";
   symbol[13]="NZDJPY"; 
   symbol[14]="CHFJPY";
   symbol[15]="GBPUSD"; 
   symbol[16]="AUDCAD";
   symbol[17]="NZDUSD";  
   symbol[18]="AUDJPY";  
  }  

  trigEnv[0]=trigEnv1;
  trigEnv[1]=trigEnv2; 
  trigEnv[2]=trigEnv3;
  trigEnv[3]=trigEnv4;
  trigEnv[4]=trigEnv5;
  trigEnv[5]=trigEnv6; 
  trigEnv[6]=trigEnv7;
  trigEnv[7]=trigEnv8; 
  trigEnv[8]=trigEnv9; 
  trigEnv[9]=trigEnv10; 
  trigEnv[10]=trigEnv10;
  trigEnv[11]=trigEnv10;
  trigEnv[12]=trigEnv10;
  trigEnv[13]=trigEnv10; 
  trigEnv[14]=trigEnv10;
  trigEnv[15]=trigEnv10; 
  trigEnv[16]=trigEnv10; 
  trigEnv[17]=trigEnv10;
  trigEnv[18]=trigEnv10; 

  DFfilter[0]=DFfilter1;
  DFfilter[1]=DFfilter2; 
  DFfilter[2]=DFfilter3;
  DFfilter[3]=DFfilter4;
  DFfilter[4]=DFfilter5;
  DFfilter[5]=DFfilter6; 
  DFfilter[6]=DFfilter7;
  DFfilter[7]=DFfilter8; 
  DFfilter[8]=DFfilter9; 
  DFfilter[9]=DFfilter10; 
  DFfilter[10]=DFfilter10;
  DFfilter[11]=DFfilter10;
  DFfilter[12]=DFfilter10;
  DFfilter[13]=DFfilter10; 
  DFfilter[14]=DFfilter10;
  DFfilter[15]=DFfilter10; 
  DFfilter[16]=DFfilter10; 
  DFfilter[17]=DFfilter10;
  DFfilter[18]=DFfilter10;  
 
  PLimit[0]=PLimit1;
  PLimit[1]=PLimit2; 
  PLimit[2]=PLimit3;
  PLimit[3]=PLimit4;
  PLimit[4]=PLimit5;
  PLimit[5]=PLimit6; 
  PLimit[6]=PLimit7;
  PLimit[7]=PLimit8; 
  PLimit[8]=PLimit9;
  PLimit[9]=PLimit9; 
  PLimit[10]=PLimit9;
  PLimit[11]=PLimit9;
  PLimit[12]=PLimit9;
  PLimit[13]=PLimit9; 
  PLimit[14]=PLimit9;
  PLimit[15]=PLimit9; 
  PLimit[16]=PLimit9; 
  PLimit[17]=PLimit9;
  PLimit[18]=PLimit9;  
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

 double trigger,range,bid,ask,ma,ma1,ma2,high,low,close;
 double EnvUp,EnvDn,EnvDiff,SL,TP,lots;string sym;
 int i;
 
 for(int s=0;s<Nsymbol;s++)
 {
  if(Norders>=Max) return; // in case new orders are submitted within the same loop
 
  sym=symbol[s];
  if(lastH1[s]==iTime(sym,TimeFrame,0)) continue;
   
  int checktime=iBarShift(sym,TimeFrame,ot[s],false); 
  if(checktime<bo) continue;

  close=iClose(sym,TimeFrame,1);
  ma=iMA(sym,TimeFrame,MAPeriod,MAShift,MAMethod,MAPrice,1); 
  EnvUp=iEnvelopes(sym,TimeFrame,EnvPeriod,EnvMethod,EnvShift,EnvPrice,EnvDev,MODE_UPPER,1);
  EnvDn=iEnvelopes(sym,TimeFrame,EnvPeriod,EnvMethod,EnvShift,EnvPrice,EnvDev,MODE_LOWER,1);
  EnvDiff=EnvUp-EnvDn;  
  trigger=NormDigits(sym,trigEnv[s]*EnvDiff+NormPoints(sym,trig));

  if(!long[s])
  {
   if(close>NormDigits(sym,ma+trigger))
   {
    for(i=1;i<=wo;i++)
    {
     high=iHigh(sym,TimeFrame,i);    
     low=iLow(sym,TimeFrame,i+1);
     ma1=iMA(sym,TimeFrame,MAPeriod,MAShift,MAMethod,MAPrice,i);   
     ma2=iMA(sym,TimeFrame,MAPeriod,MAShift,MAMethod,MAPrice,i+1);      
     if(low<ma2&&high>ma1)
     {
      bid=MarketInfo(sym,MODE_BID);

      if(Filter(sym,true,bid,s))
      {
       if(iTime(sym,TimeFrame,i)>ot[s])
       {
        EnvUp=iEnvelopes(sym,TimeFrame,EnvPeriod,EnvMethod,EnvShift,EnvPrice,EnvDev,MODE_UPPER,0);
        EnvDn=iEnvelopes(sym,TimeFrame,EnvPeriod,EnvMethod,EnvShift,EnvPrice,EnvDev,MODE_LOWER,0);
        EnvDiff=EnvUp-EnvDn;
   
        ask=MarketInfo(sym,MODE_ASK);
      
        lots=CalculateLots();
        SL=NormDigits(sym,EnvDn-NormPoints(sym,SL));
        TP=NormDigits(sym,ask+tpEnv*EnvDiff);
   
        SendOrderLong(sym,lots,Slippage,SL,TP,comment,magic,0,Blue);
        ot[s]=TimeCurrent(); 
        Norders++;
        continue;
       }
      }
     }
    }
   }
  }
  
  if(!short[s])
  {     
   if(close<NormDigits(sym,ma-trigger))
   {
    for(i=1;i<=wo;i++)
    {
     high=iHigh(sym,TimeFrame,i+1);    
     low=iLow(sym,TimeFrame,i);
     ma1=iMA(sym,TimeFrame,MAPeriod,MAShift,MAMethod,MAPrice,i);   
     ma2=iMA(sym,TimeFrame,MAPeriod,MAShift,MAMethod,MAPrice,i+1);      
     if(high>ma2&&low<ma1)
     {
      bid=MarketInfo(sym,MODE_BID);
      
      if(Filter(sym,false,bid,s))
      {
       if(iTime(sym,TimeFrame,i)>ot[s])
       {        
        EnvUp=iEnvelopes(sym,TimeFrame,EnvPeriod,EnvMethod,EnvShift,EnvPrice,EnvDev,MODE_UPPER,0);
        EnvDn=iEnvelopes(sym,TimeFrame,EnvPeriod,EnvMethod,EnvShift,EnvPrice,EnvDev,MODE_LOWER,0);
        EnvDiff=EnvUp-EnvDn;

        lots=CalculateLots();
        SL=NormDigits(sym,EnvUp+NormPoints(sym,SL));
        TP=NormDigits(sym,bid-tpEnv*EnvDiff);   

        SendOrderShort(sym,lots,Slippage,SL,TP,comment,magic,0,Red);
        ot[s]=TimeCurrent();
        Norders++;      
        continue;
       }
      }
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

  int target=EnvTarget(sym,fsEnv,TimeFrame,EnvPeriod,EnvMethod,EnvShift,EnvPrice,EnvDev);
  FixedStopsB(sym,target,FS);

  if(lastH1[s]==iTime(sym,TimeFrame,0)) continue;

  close=iClose(sym,TimeFrame,1); 
  ma=iMA(sym,TimeFrame,MAPeriod2,MAShift2,MAMethod2,MAPrice2,1); 

  point=MarketInfo(sym,MODE_POINT);

  if(type==OP_BUY)
  {
   if(close<ma) 
   {
    ExitOrder(sym,true,false);
    long[s]=false;
   }  
  }
  else if(type==OP_SELL)
  {    
   if(close>ma) 
   {
    ExitOrder(sym,false,true);  
    short[s]=false;
   }
  }

 } 
 
 return;
}

//+------------------------------------------------------------------+
bool Filter(string sym, bool long, double bid, int s)
{
 int Trigger[12], totN=12, i;
 double value1,value2,value3,EnvUp,EnvDn,close;

 for(i=0;i<totN;i++) Trigger[i]=-1;

 if(long) // long filters
 {
  for(i=0;i<totN;i++)
  {
   switch(i)
   {    
    case 0:
      Trigger[i]=TrendC(sym,true);
     break;  
    case 1:
     value1=iOsMA(sym,PERIOD_H1,OsMAfastH1,OsMAslowH1,OsMAsignalH1,OsMAPriceH1,1); 
     if(value1>0) Trigger[i]=1;    
     break;    
    case 2:
     value1=iOsMA(sym,PERIOD_H4,OsMAfastH4,OsMAslowH4,OsMAsignalH4,OsMAPriceH4,1); 
     if(value1>0) Trigger[i]=1;    
     break;  
    case 3:
     value1=iOsMA(sym,PERIOD_D1,OsMAfastD1,OsMAslowD1,OsMAsignalD1,OsMAPriceD1,1); 
     if(value1>0) Trigger[i]=1;    
     break; 
    case 4:
     EnvUp=iEnvelopes(sym,PERIOD_H1,EnvPeriod,EnvMethod,EnvShift,EnvPrice,EnvDev,MODE_UPPER,1);
     close=iClose(sym,PERIOD_H1,1);
     if(close>EnvUp) Trigger[i]=1;
     break;     
    case 5:
     EnvUp=iEnvelopes(sym,PERIOD_D1,EnvPeriodD1,EnvMethodD1,EnvShiftD1,EnvPriceD1,EnvDevD1,MODE_UPPER,1);
     close=iClose(sym,PERIOD_D1,1);
     if(close>EnvUp) Trigger[i]=1;
     break; 
    case 6:
     value1=MathAbs(iCCI(sym,PERIOD_H4,CCIPeriod,CCIPrice,1));
     if(value1<CCIfilter) Trigger[i]=1;  
     break; 
    case 7:
     value1=Productivity(sym,PERIOD_H1,ProductivityH1,1);
     value2=Productivity(sym,PERIOD_H4,ProductivityH4,1);
     value3=Productivity(sym,PERIOD_D1,ProductivityD1,1);
     if(value1+value2+value3>PLimit[s]) Trigger[i]=1;          
     break;
    case 8:    
     value1=iCustom(sym,PERIOD_H1,ciDeltaforce,0,0);
     if(value1>DFfilter[s]) Trigger[i]=1; // DF is a positive number
     break;       
    case 9:
     value1=iCustom(sym,PERIOD_D1,ciWaddahCamarilla,6,1);  // D1 here
     close=iClose(sym,PERIOD_H1,1);  // H1 here
     if(close>value1) Trigger[i]=1;
     break;
    case 10:
     if(FilterOsMAAcc(true)) Trigger[i]=1;
     break;   
    case 11:
     if(bid>FractalChannel(sym,true)) Trigger[i]=1;
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
      Trigger[i]=TrendC(sym,false);
     break;
    case 1:
     value1=iOsMA(sym,TimeFrame,OsMAfastH1,OsMAslowH1,OsMAsignalH1,OsMAPriceH1,1); 
     if(value1<0) Trigger[i]=1;    
     break;
    case 2:
     value1=iOsMA(sym,PERIOD_H4,OsMAfastH4,OsMAslowH4,OsMAsignalH4,OsMAPriceH4,1); 
     if(value1<0) Trigger[i]=1;    
     break;  
    case 3:
     value1=iOsMA(sym,PERIOD_D1,OsMAfastD1,OsMAslowD1,OsMAsignalD1,OsMAPriceD1,1); 
     if(value1<0) Trigger[i]=1;    
     break;
    case 4:
     EnvDn=iEnvelopes(sym,PERIOD_H1,EnvPeriod,EnvMethod,EnvShift,EnvPrice,EnvDev,MODE_LOWER,1);
     close=iClose(sym,PERIOD_H1,1);
     if(close<EnvDn) Trigger[i]=1;
     break;     
    case 5:
     EnvDn=iEnvelopes(sym,PERIOD_D1,EnvPeriodD1,EnvMethodD1,EnvShiftD1,EnvPriceD1,EnvDevD1,MODE_LOWER,1);
     close=iClose(sym,PERIOD_D1,1);
     if(close<EnvDn) Trigger[i]=1;
     break;
    case 6:
     value1=MathAbs(iCCI(sym,PERIOD_H4,CCIPeriod,CCIPrice,1));
     if(value1<CCIfilter) Trigger[i]=1;  
     break;
    case 7:
     value1=Productivity(sym,PERIOD_H1,ProductivityH1,1);
     value2=Productivity(sym,PERIOD_H4,ProductivityH4,1);
     value3=Productivity(sym,PERIOD_D1,ProductivityD1,1);
     if(value1+value2+value3>PLimit[s]) Trigger[i]=1;          
     break;     
    case 8:
     value1=iCustom(sym,PERIOD_H1,ciDeltaforce,1,0);
     if(value1>DFfilter[s]) Trigger[i]=1; // DF is a positive number
     break;            
    case 9:
     value1=iCustom(sym,PERIOD_D1,ciWaddahCamarilla,7,1);  // D1 here
     close=iClose(sym,PERIOD_H1,1); // H1 here
     if(close<value1) Trigger[i]=1;
     break;
    case 10:
     if(FilterOsMAAcc(false)) Trigger[i]=1;
     break;
    case 11:
     if(bid<FractalChannel(sym,false)) Trigger[i]=1;
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
int TrendC(string sym, bool flag)
{
 double bid=MarketInfo(sym,MODE_BID);
 double valueD1=iWPR(sym,PERIOD_D1,WPRD1Period,0);
 double valueH1=iWPR(sym,PERIOD_H1,WPRH1Period,0);
 double valueH4=iWPR(sym,PERIOD_H4,WPRH4Period,0);  
 double ma=iMA(sym,PERIOD_D1,Tr_MAPeriod,Tr_Shift,Tr_Method,Tr_Price,0);
 if(flag)
 {
  if(valueD1>WPRfilterLong&&valueH1>WPRfilterLong&&valueH4>WPRfilterLong&&bid>ma) return(1);
  else return(-1);
 }
 else
 {
  if(valueD1<WPRfilterShort&&valueH1<WPRfilterShort&&valueH4<WPRfilterShort&&bid<ma) return(1);
  else return(-1);
 }

 return(1);
}
//+------------------------------------------------------------------+
double Productivity(string sym,int timeframe, int period, int i)
{
 int j,ipp=i+period;
 double speed,spread;
 speed=0;
 for (j=i;j<=ipp;j++)
  speed = speed +(iHigh(sym,timeframe,j)-iLow(sym,timeframe,j));

 speed=speed/period;
 spread=MathAbs(iOpen(sym,timeframe,ipp)-iClose(sym,timeframe,i));
 return(spread/speed);
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
double FractalChannel(string sym, bool long)
{
 int i;
 
 if(long)
 {
  for(i=1;i<1000;i++)
  {
   if(iFractals(sym,TimeFrameFrCh, MODE_UPPER, i)<=0) continue;
   return(iHigh(sym,TimeFrameFrCh,i));
  }
 }
 else
 {
  for(i=1;i<1000;i++)
  {
   if(iFractals(sym,TimeFrameFrCh, MODE_LOWER, i)<=0) continue;
   return(iLow(sym,TimeFrameFrCh,i));
  }  
 }
 
 return(0);
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
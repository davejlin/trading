//+----------------------------------------------------------------------+
//|                                                      ATC_MA test.mq4 |
//|                                                         David J. Lin |
//|ATC MA cross                                                          |
//|by David J. Lin                                                       |
//|                                                                      |
//|Coded by David J. Lin (dave.j.lin@sbcglobal.net)                      |
//|Evanston, IL, September 2, 2007                                       |
//|                                                                      |
//|Copyright © 2007, David J. Lin                                        |
//+----------------------------------------------------------------------+
#property copyright ""
#property link      ""

// User adjustable parameters:

double Lots=1.0;               // number of lots (must be multiples of 0.1)

// MACD Trend parameters:

int TimeFrameMA1=PERIOD_M1;   // main timeframe of EA

int MAPeriod=10;               // M1 EMA 
int MAShift=0;
int MAMethod=MODE_EMA;
int MAPrice=PRICE_CLOSE;

int MAPeriod2=30;             // M1 EMA
int MAShift2=0;
int MAMethod2=MODE_EMA;
int MAPrice2=PRICE_CLOSE;

int    EnvPeriod=20;           // H4 Envelopes parameters (filter,SL,TP,FS,TS)
int    EnvMethod=MODE_EMA;        
int    EnvShift=0;
int    EnvPrice=PRICE_CLOSE; 
double EnvDev=0.10;

int bo1=1;                     // bars black-out after order entry

                                // USDCAD
double tpEnv11=1.50;             // fraction of Envelope height for initial TP 
double fsEnv11=0.35;             // fraction of Envelope height to activate fixed-stop 
                                // USDCHF
double tpEnv12=1.50;             // fraction of Envelope height for initial TP 
double fsEnv12=0.25;             // fraction of Envelope height to activate fixed-stop 
                                // GBPJPY
double tpEnv13=2.00;             // fraction of Envelope height for initial TP 
double fsEnv13=0.50;             // fraction of Envelope height to activate fixed-stop 
                                // AUDUSD
double tpEnv14=1.50;             // fraction of Envelope height for initial TP 
double fsEnv14=0.40;             // fraction of Envelope height to activate fixed-stop 
                                // all else (for testing)
double tpEnv15=1.00;             // fraction of Envelope height for initial TP 
double fsEnv15=0.50;             // fraction of Envelope height to activate fixed-stop 

// RSI2 Sclaper Model's Variables

int TimeFrameMA2=PERIOD_M5;          // RSI2 timeframe

int MAPeriod3=10;               // M5 EMA 
int MAShift3=0;
int MAMethod3=MODE_EMA;
int MAPrice3=PRICE_CLOSE;

int MAPeriod4=20;             // M5 EMA
int MAShift4=0;
int MAMethod4=MODE_EMA;
int MAPrice4=PRICE_CLOSE;

int    EnvPeriod2=20;                 // H1 Envelopes parameters (filter,SL,TP,FS,TS)
int    EnvMethod2=MODE_EMA;        
int    EnvShift2=0;
int    EnvPrice2=PRICE_CLOSE; 
double EnvDev2=0.10;

int bo2=1;                     // hours to prevent a new RSI2 Scalper order

                                // USDJPY
double tpEnv21=1.75;     // fraction of Envelope height for initial TP 
double fsEnv21=0.50;     // fraction of Envelope height to activate fixed-stop 
                                // GBPUSD
double tpEnv22=2.00;            // fraction of Envelope height for initial TP 
double fsEnv22=0.50;            // fraction of Envelope height to activate fixed-stop 
                                // EURJPY
double tpEnv23=1.50;            // fraction of Envelope height for initial TP 
double fsEnv23=0.60;            // fraction of Envelope height to activate fixed-stop 
                                // AUDUSD
double tpEnv24=1.60;            // fraction of Envelope height for initial TP 
double fsEnv24=0.70;            // fraction of Envelope height to activate fixed-stop 
                                // all else (for testing)
double tpEnv25=1.00;            // fraction of Envelope height for initial TP 
double fsEnv25=0.50;            // fraction of Envelope height to activate fixed-stop 

bool mini=true;                 // true=mini-account, false=standard-account

// Universal parameters:

int sl=10;               // pips above/below upper/lower Envelope for initial SL
int    FS=1;                    // fixed-stop value (BE+fs)
double tsEnv=0.50;              // fraction of Envelope height to trail stop

// Internal usage parameters:
int Slippage=3;
int lotsprecision=1;
int SLMin=32;                  // minimum universal SL
int Max=10;                    // maximum number of simultaneous orders

double lotsmin,lotsmax;
string comment1="ATC MA 1";
string comment2="ATC MA 2";
string symbol1[],symbol2[];
double ot1[],ot2[],tpEnv1[],fsEnv1[],tpEnv2[],fsEnv2[];
bool short1[],long1[],short2[],long2[];
int lastH1[],lastH4[];
int Nsymbol=19;
int Norders;
int magic1=1111111122;
int magic2=1111111123;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//----

 if(!GlobalVariableCheck("SEMAPHORE")) GlobalVariableSet("SEMAPHORE",0);

 ArrayResize(symbol1,Nsymbol);
 ArrayResize(symbol2,Nsymbol); 
 ArrayResize(ot1,Nsymbol);    
 ArrayResize(ot2,Nsymbol);  
 ArrayResize(short1,Nsymbol); 
 ArrayResize(long1,Nsymbol);  
 ArrayResize(short2,Nsymbol); 
 ArrayResize(long2,Nsymbol); 
 ArrayResize(lastH4,Nsymbol);  
 ArrayResize(lastH1,Nsymbol);  
 ArrayResize(tpEnv1,Nsymbol);
 ArrayResize(fsEnv1,Nsymbol); 
 ArrayResize(tpEnv2,Nsymbol);
 ArrayResize(fsEnv2,Nsymbol); 

// symbol1[0]=Symbol();


 if(mini)
 {
  symbol1[0]="USDCADm"; 
  symbol1[1]="USDCHFm";  
  symbol1[2]="GBPJPYm";  
  symbol1[3]="AUDUSDm"; 
  symbol1[4]="EURUSDm";
  symbol1[5]="EURJPYm";
  symbol1[6]="EURGBPm"; 
  symbol1[7]="USDJPYm";
  symbol1[8]="EURCHFm"; 
  symbol1[9]="AUDNZDm"; 
  symbol1[10]="GBPCHFm";
  symbol1[11]="NZDJPYm"; 
  symbol1[12]="CHFJPYm";
  symbol1[13]="GBPUSDm"; 
  symbol1[14]="EURAUDm";
  symbol1[15]="AUDCADm";
  symbol1[16]="EURCADm"; 
  symbol1[17]="NZDUSDm";  
  symbol1[18]="AUDJPYm";  
 }
 else
 {
  symbol1[0]="USDCAD"; 
  symbol1[1]="USDCHF";  
  symbol1[2]="GBPJPY";  
  symbol1[3]="AUDUSD"; 
  symbol1[4]="EURUSD";
  symbol1[5]="EURJPY";
  symbol1[6]="EURGBP"; 
  symbol1[7]="USDJPY";
  symbol1[8]="EURCHF"; 
  symbol1[9]="AUDNZD"; 
  symbol1[10]="GBPCHF";
  symbol1[11]="NZDJPY"; 
  symbol1[12]="CHFJPY";
  symbol1[13]="GBPUSD"; 
  symbol1[14]="EURAUD";
  symbol1[15]="AUDCAD";
  symbol1[16]="EURCAD"; 
  symbol1[17]="NZDUSD";  
  symbol1[18]="AUDJPY";  
 }  

 tpEnv1[0]=tpEnv11;
 tpEnv1[1]=tpEnv12; 
 tpEnv1[2]=tpEnv13;
 tpEnv1[3]=tpEnv14;
 tpEnv1[4]=tpEnv15;
 tpEnv1[5]=tpEnv15; 
 tpEnv1[6]=tpEnv15;
 tpEnv1[7]=tpEnv15; 
 tpEnv1[8]=tpEnv15;
 tpEnv1[9]=tpEnv15; 
 tpEnv1[10]=tpEnv15;
 tpEnv1[11]=tpEnv15;
 tpEnv1[12]=tpEnv15;
 tpEnv1[13]=tpEnv15; 
 tpEnv1[14]=tpEnv15;
 tpEnv1[15]=tpEnv15; 
 tpEnv1[16]=tpEnv15; 
 tpEnv1[17]=tpEnv15;
 tpEnv1[18]=tpEnv15; 
 
 fsEnv1[0]=fsEnv11;
 fsEnv1[1]=fsEnv12; 
 fsEnv1[2]=fsEnv13;
 fsEnv1[3]=fsEnv14;
 fsEnv1[4]=fsEnv15;
 fsEnv1[5]=fsEnv15; 
 fsEnv1[6]=fsEnv15;
 fsEnv1[7]=fsEnv15; 
 fsEnv1[8]=fsEnv15;
 fsEnv1[9]=fsEnv15; 
 fsEnv1[10]=fsEnv15;
 fsEnv1[11]=fsEnv15;
 fsEnv1[12]=fsEnv15;
 fsEnv1[13]=fsEnv15; 
 fsEnv1[14]=fsEnv15;
 fsEnv1[15]=fsEnv15; 
 fsEnv1[16]=fsEnv15; 
 fsEnv1[17]=fsEnv15;
 fsEnv1[18]=fsEnv15;  

// symbol2[0]=Symbol();

 if(mini)
 {
  symbol2[0]="USDJPYm";
  symbol2[1]="GBPUSDm"; 
  symbol2[2]="EURJPYm";    
  symbol2[3]="AUDUSDm"; 
  symbol2[4]="EURUSDm";  
  symbol2[5]="GBPJPYm";
  symbol2[6]="USDCADm"; 
  symbol2[7]="EURGBPm"; 
  symbol2[8]="EURCHFm";
  symbol2[9]="USDCHFm";
  symbol2[10]="AUDNZDm"; 
  symbol2[11]="GBPCHFm";
  symbol2[12]="NZDJPYm"; 
  symbol2[13]="CHFJPYm";
  symbol2[14]="EURAUDm";
  symbol2[15]="AUDCADm";
  symbol2[16]="EURCADm"; 
  symbol2[17]="NZDUSDm";  
  symbol2[18]="AUDJPYm";  
 }
 else
 {
  symbol2[0]="USDJPY";
  symbol2[1]="GBPUSD"; 
  symbol2[2]="EURJPY";    
  symbol2[3]="AUDUSD"; 
  symbol2[4]="EURUSD";  
  symbol2[5]="GBPJPY";
  symbol2[6]="USDCAD"; 
  symbol2[7]="EURGBP"; 
  symbol2[8]="EURCHF";
  symbol2[9]="USDCHF";
  symbol2[10]="AUDNZD"; 
  symbol2[11]="GBPCHF";
  symbol2[12]="NZDJPY"; 
  symbol2[13]="CHFJPY";
  symbol2[14]="EURAUD";
  symbol2[15]="AUDCAD";
  symbol2[16]="EURCAD"; 
  symbol2[17]="NZDUSD";  
  symbol2[18]="AUDJPY";  
 }  

 tpEnv2[0]=tpEnv21;
 tpEnv2[1]=tpEnv22; 
 tpEnv2[2]=tpEnv23;
 tpEnv2[3]=tpEnv24;
 tpEnv2[4]=tpEnv25;
 tpEnv2[5]=tpEnv25; 
 tpEnv2[6]=tpEnv25;
 tpEnv2[7]=tpEnv25; 
 tpEnv2[8]=tpEnv25;
 tpEnv2[9]=tpEnv25; 
 tpEnv2[10]=tpEnv25;
 tpEnv2[11]=tpEnv25;
 tpEnv2[12]=tpEnv25;
 tpEnv2[13]=tpEnv25; 
 tpEnv2[14]=tpEnv25;
 tpEnv2[15]=tpEnv25; 
 tpEnv2[16]=tpEnv25; 
 tpEnv2[17]=tpEnv25;
 tpEnv2[18]=tpEnv25; 

 fsEnv2[0]=fsEnv21;
 fsEnv2[1]=fsEnv22; 
 fsEnv2[2]=fsEnv23;
 fsEnv2[3]=fsEnv24;
 fsEnv2[4]=fsEnv25;
 fsEnv2[5]=fsEnv25; 
 fsEnv2[6]=fsEnv25;
 fsEnv2[7]=fsEnv25; 
 fsEnv2[8]=fsEnv25;
 fsEnv2[9]=fsEnv25; 
 fsEnv2[10]=fsEnv25;
 fsEnv2[11]=fsEnv25;
 fsEnv2[12]=fsEnv25;
 fsEnv2[13]=fsEnv25; 
 fsEnv2[14]=fsEnv25;
 fsEnv2[15]=fsEnv25; 
 fsEnv2[16]=fsEnv25; 
 fsEnv2[17]=fsEnv25;
 fsEnv2[18]=fsEnv25;  

 lotsmin=0.10; 
 lotsmax=5.00;

// First check closed trades
 int trade,s;string sym;                      
 int trades=OrdersHistoryTotal();           
 for(trade=0;trade<trades;trade++)   // The most recent closed order has the largest position number, so this works forward
                                     // to allow the values of the most recent closed orders to be the ones which are recorded
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_HISTORY);

  int D1bars=iBarShift(sym,PERIOD_D1,OrderCloseTime(),false);  // time difference in days
  if(D1bars>30) // = only interested in closed trades within the past month
   continue;
    
  if(OrderMagicNumber()==magic1)
  {
 
   sym=OrderSymbol();
   
   for(s=0;s<Nsymbol;s++)
   {
    if(sym==symbol1[s]) break;
   }
  
   ot1[s]=OrderOpenTime();
  }
  else if(OrderMagicNumber()==magic2)
  {
 
   sym=OrderSymbol();
   
   for(s=0;s<Nsymbol;s++)
   {
    if(sym==symbol2[s]) break;
   }
  
   ot2[s]=OrderOpenTime();
  }  
  
 }

// Now check open orders
                       
 trades=OrdersTotal();           
 for(trade=0;trade<trades;trade++)// The most recent closed order has the largest position number, so this works forward
                                  // to allow the values of the most recent closed orders to be the ones which are recorded

 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderMagicNumber()==magic1)
  {
   sym=OrderSymbol();

   for(s=0;s<Nsymbol;s++)
   {
    if(sym==symbol1[s]) break;
   }
  
   ot1[s]=OrderOpenTime();
  }
  else if(OrderMagicNumber()==magic2)
  {
   sym=OrderSymbol();

   for(s=0;s<Nsymbol;s++)
   {
    if(sym==symbol2[s]) break;
   }
  
   ot2[s]=OrderOpenTime();
  }  
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
 if(DayOfWeek()!=0) 
 {
  SubmitOrdersMA1(); 
  SubmitOrdersMA2();
 }
 ManageOrders();

 for(int s=0;s<Nsymbol;s++)
 {
  lastH1[s]=iTime(symbol2[s],TimeFrameMA2,0); 
  lastH4[s]=iTime(symbol1[s],TimeFrameMA1,0);
 }
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert utility functions                                         |
//+------------------------------------------------------------------+

void SubmitOrdersMA1()
{
 if(Norders>=Max) return;

 double bid,ask,close,EnvUp,EnvDn,EnvDiff,value1f,value2f,value1s,value2s,SL,TP,lots;
 string sym;
 int i;
 
 for(int s=0;s<Nsymbol;s++)
 {

  if(Norders>=Max) return; // in case new orders are submitted within the same loop
  
  sym=symbol1[s];
  if(lastH4[s]==iTime(sym,TimeFrameMA1,0)) continue;
   
  int checktime=iBarShift(sym,TimeFrameMA1,ot1[s],false); 
  if(checktime<bo1) continue;

  bid=MarketInfo(sym,MODE_BID);

  value1f=iMA(sym,TimeFrameMA1,MAPeriod,MAShift,MAMethod,MAPrice,1);
  value1s=iMA(sym,TimeFrameMA1,MAPeriod2,MAShift2,MAMethod2,MAPrice2,1);  

  value2f=iMA(sym,TimeFrameMA1,MAPeriod,MAShift,MAMethod,MAPrice,2);
  value2s=iMA(sym,TimeFrameMA1,MAPeriod2,MAShift2,MAMethod2,MAPrice2,2);                

  if(!long1[s])
  {     
   if(value1f>value1s&&value2f<value2s)   
   {  
    EnvUp=iEnvelopes(sym,TimeFrameMA1,EnvPeriod,EnvMethod,EnvShift,EnvPrice,EnvDev,MODE_UPPER,1);
    close=iClose(sym,TimeFrameMA1,1); 
        
//    if(close>EnvUp)
    { 
     if(FilterMA1(sym,true,bid))
     {
      EnvUp=iEnvelopes(sym,TimeFrameMA1,EnvPeriod,EnvMethod,EnvShift,EnvPrice,EnvDev,MODE_UPPER,0);
      EnvDn=iEnvelopes(sym,TimeFrameMA1,EnvPeriod,EnvMethod,EnvShift,EnvPrice,EnvDev,MODE_LOWER,0);
      EnvDiff=EnvUp-EnvDn;
   
      ask=MarketInfo(sym,MODE_ASK);
  
      SL=NormDigits(sym,EnvDn-NormPoints(sym,sl));
      
      lots=Lots;
    
      TP=NormDigits(sym,ask+tpEnv1[s]*EnvDiff);
   
      SendOrderLong(sym,lots,Slippage,SL,TP,comment1,magic1,0,Blue);
      ot1[s]=TimeCurrent(); 
      Norders++;
      continue; 
     }
    }
   }
  }
  
  if(!short1[s])
  { 
   if(value1f<value1s&&value2f>value2s)  
   {   
    EnvDn=iEnvelopes(sym,TimeFrameMA1,EnvPeriod,EnvMethod,EnvShift,EnvPrice,EnvDev,MODE_LOWER,1);
    close=iClose(sym,TimeFrameMA1,1);     
      
//    if(close<EnvDn)
    {     
     if(FilterMA1(sym,false,bid))
     {  
      EnvUp=iEnvelopes(sym,TimeFrameMA1,EnvPeriod,EnvMethod,EnvShift,EnvPrice,EnvDev,MODE_UPPER,0);
      EnvDn=iEnvelopes(sym,TimeFrameMA1,EnvPeriod,EnvMethod,EnvShift,EnvPrice,EnvDev,MODE_LOWER,0);
      EnvDiff=EnvUp-EnvDn;
      
      SL=NormDigits(sym,EnvUp+NormPoints(sym,sl));

      lots=Lots;  

      TP=NormDigits(sym,bid-tpEnv1[s]*EnvDiff);   

      SendOrderShort(sym,lots,Slippage,SL,TP,comment1,magic1,0,Red);
      ot1[s]=TimeCurrent();
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
void SubmitOrdersMA2()
{
 if(Norders>=Max) return;
 
 double bid,ask,close,EnvUp,EnvDn,EnvDiff,value1f,value2f,value1s,value2s,SL,TP,lots;
 string sym;
 
 for(int s=0;s<Nsymbol;s++)
 {
  if(Norders>=Max) return; // in case new orders are submitted within the same loop
 
  sym=symbol2[s];
  if(lastH1[s]==iTime(sym,TimeFrameMA2,0)) continue;
   
  int checktime=iBarShift(sym,TimeFrameMA2,ot2[s],false); 
  if(checktime<bo2) continue;

  bid=MarketInfo(sym,MODE_BID);
  
  value1f=iMA(sym,TimeFrameMA2,MAPeriod3,MAShift3,MAMethod3,MAPrice3,1);
  value1s=iMA(sym,TimeFrameMA2,MAPeriod4,MAShift4,MAMethod4,MAPrice4,1);  

  value2f=iMA(sym,TimeFrameMA2,MAPeriod3,MAShift3,MAMethod3,MAPrice3,2);
  value2s=iMA(sym,TimeFrameMA2,MAPeriod4,MAShift4,MAMethod4,MAPrice4,2);  

  if(!long2[s])
  {     
   if(value1f>value1s&&value2f<value2s)   
   {  
    EnvUp=iEnvelopes(sym,TimeFrameMA2,EnvPeriod2,EnvMethod2,EnvShift2,EnvPrice2,EnvDev2,MODE_UPPER,1);
    close=iClose(sym,TimeFrameMA1,1); 
        
//    if(close>EnvUp)
    { 
     if(FilterMA2(sym,true,bid))
     {
      EnvUp=iEnvelopes(sym,TimeFrameMA2,EnvPeriod2,EnvMethod2,EnvShift2,EnvPrice2,EnvDev2,MODE_UPPER,0);
      EnvDn=iEnvelopes(sym,TimeFrameMA2,EnvPeriod2,EnvMethod2,EnvShift2,EnvPrice2,EnvDev2,MODE_LOWER,0);
      EnvDiff=EnvUp-EnvDn;
   
      ask=MarketInfo(sym,MODE_ASK);
  
      SL=NormDigits(sym,EnvDn-NormPoints(sym,sl));
      
      lots=Lots;
    
      TP=NormDigits(sym,ask+tpEnv1[s]*EnvDiff);
   
      SendOrderLong(sym,lots,Slippage,SL,TP,comment2,magic2,0,Blue);
      ot2[s]=TimeCurrent(); 
      Norders++;
      continue; 
     }
    }
   }
  }
  
  if(!short2[s])
  { 
   if(value1f<value1s&&value2f>value2s)  
   {   
    EnvDn=iEnvelopes(sym,TimeFrameMA2,EnvPeriod2,EnvMethod2,EnvShift2,EnvPrice2,EnvDev2,MODE_LOWER,1);
    close=iClose(sym,TimeFrameMA1,1);     
      
//    if(close<EnvDn)
    {     
     if(FilterMA2(sym,false,bid))
     {  
      EnvUp=iEnvelopes(sym,TimeFrameMA2,EnvPeriod2,EnvMethod2,EnvShift2,EnvPrice2,EnvDev2,MODE_UPPER,0);
      EnvDn=iEnvelopes(sym,TimeFrameMA2,EnvPeriod2,EnvMethod2,EnvShift2,EnvPrice2,EnvDev2,MODE_LOWER,0);
      EnvDiff=EnvUp-EnvDn;
      
      SL=NormDigits(sym,EnvUp+NormPoints(sym,sl));

      lots=Lots;  

      TP=NormDigits(sym,bid-tpEnv1[s]*EnvDiff);   

      SendOrderShort(sym,lots,Slippage,SL,TP,comment2,magic2,0,Red);
      ot2[s]=TimeCurrent();
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
  long1[s]=false;
  short1[s]=false;
  long2[s]=false;
  short2[s]=false;  
 }
 
 double high,low,close,ma,point,profit;string sym;
 int pipstop,type,trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  type=OrderType();
  sym=OrderSymbol();
  
  int trail,target;
  if(OrderMagicNumber()==magic1)
  {
   Norders++;  
   for(s=0;s<Nsymbol;s++)
   {
    if(sym==symbol1[s]) break;
   }
  
   if(type==OP_BUY) long1[s]=true;
   if(type==OP_SELL) short1[s]=true;  

   profit=DetermineProfit(sym);  
   if(profit<=0) continue;

   target=EnvTarget(sym,fsEnv1[s],TimeFrameMA1,EnvPeriod,EnvMethod,EnvShift,EnvPrice,EnvDev);
   if(profit>NormPoints(sym,target))
   {
    FixedStopsB(sym,target,FS);
    trail=EnvTarget(sym,tsEnv,TimeFrameMA1,EnvPeriod,EnvMethod,EnvShift,EnvPrice,EnvDev);
    TrailingStop(sym,trail);
   }
  }
  else if(OrderMagicNumber()==magic2)
  {
   Norders++;  
   for(s=0;s<Nsymbol;s++)
   {
    if(sym==symbol2[s]) break;
   }
  
   if(type==OP_BUY) long2[s]=true;
   if(type==OP_SELL) short2[s]=true;  

   profit=DetermineProfit(sym);  
   if(profit<=0) continue;

   target=EnvTarget(sym,fsEnv2[s],TimeFrameMA2,EnvPeriod2,EnvMethod2,EnvShift2,EnvPrice2,EnvDev2);
   if(profit>NormPoints(sym,target))
   {
    FixedStopsB(sym,target,FS);
    trail=EnvTarget(sym,tsEnv,TimeFrameMA2,EnvPeriod2,EnvMethod2,EnvShift2,EnvPrice2,EnvDev2);
    TrailingStop(sym,trail);
   }
  }  

//  if(lastH4[s]==iTime(sym,TimeFrameMA1,0)) continue;
 
//  point=MarketInfo(sym,MODE_POINT);

//  if(type==OP_BUY)
//  {
//  }
//  else if(type==OP_SELL)
//  {    
//  }

 } 
 
 return;
}

//+------------------------------------------------------------------+
bool FilterMA1(string sym, bool long, double bid)
{
 int Trigger[0], totN=0, i;
 double value1,value2;

 for(i=0;i<totN;i++) Trigger[i]=-1;

 if(long) // long filters
 {
  for(i=0;i<totN;i++)
  {
   switch(i)
   {        
    case 0:
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
bool FilterMA2(string sym, bool long, double bid)
{
 int Trigger[0], totN=0, i;
 double value1,value2;

 for(i=0;i<totN;i++) Trigger[i]=-1;

 if(long) // long filters
 {
  for(i=0;i<totN;i++)
  {
   switch(i)
   {        
    case 0:
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
/*
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
*/
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
void TrailingStop(string sym, int TS)
{
 if(TS<=0) return;
 
 double stopcrnt,stopcal; 
 double profit;

 stopcrnt=NormDigits(sym,OrderStopLoss());
             
 if(OrderType()==OP_BUY)
 {
  double bid=MarketInfo(sym,MODE_BID); 
  stopcal=TrailLong(sym,bid,TS);
  if (stopcal==stopcrnt) return;
  ModifyCompLong(sym,stopcal,stopcrnt);  
 }    

 if(OrderType()==OP_SELL)
 {  
  double ask=MarketInfo(sym,MODE_ASK); 
  stopcal=TrailShort(sym,ask,TS);
  if (stopcal==stopcrnt) return;  
  ModifyCompShort(sym,stopcal,stopcrnt); 
 } 
 
 return(0);
}
//+------------------------------------------------------------------+
double TrailLong(string sym,double price,int trail)
{
 return(NormDigits(sym,price-NormPoints(sym,trail))); 
}
//+------------------------------------------------------------------+
double TrailShort(string sym,double price,int trail)
{
 return(NormDigits(sym,price+NormPoints(sym,trail))); 
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
//void ExitOrder(string sym,bool flag_Long,bool flag_Short)
//{
// if(OrderType()==OP_BUY&&flag_Long)
//  CloseOrderLong(sym,OrderTicket(),OrderLots(),Slippage,Lime);
// else if(OrderType()==OP_SELL&&flag_Short)
//  CloseOrderShort(sym,OrderTicket(),OrderLots(),Slippage,Lime);
// return;
//}
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


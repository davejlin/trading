//+----------------------------------------------------------------------+
//|                                                     ATC_MACDRSI2.mq4 |
//|                                                         David J. Lin |
//|ATC MACD/RSI2 Trend/Scalper model                                     |
//|by Vinson Wells                                                       |
//|                                                                      |
//|David Lin's submission                                                |
//|                                                                      |
//|Coded by David J. Lin (dave.j.lin@sbcglobal.net)                      |
//|Evanston, IL, August 30, 2007                                         |
//|                                                                      |
//|Copyright © 2007, David J. Lin                                        |
//+----------------------------------------------------------------------+
#property copyright ""
#property link      ""

// User adjustable parameters:

// double Lots=1.0;               // number of lots (must be multiples of 0.1)

// MACD Trend parameters:

int TimeFrameMACD=PERIOD_H4;       // main timeframe of EA

int MACDfast=10;               // H4 MACD
int MACDslow=24;
int MACDsignal=8;
int MACDprice=PRICE_CLOSE; 

int    EnvPeriod=72;           // H4 Envelopes parameters (filter,SL,TP,FS,TS)
int    EnvMethod=MODE_EMA;        
int    EnvShift=0;
int    EnvPrice=PRICE_CLOSE; 
double EnvDev=0.55;

int MAPeriod=72;               // H4 EMA 
int MAShift=0;
int MAMethod=MODE_EMA;
int MAPrice=PRICE_CLOSE;

int MAPeriod2=144;             // H4 EMA
int MAShift2=0;
int MAMethod2=MODE_EMA;
int MAPrice2=PRICE_CLOSE;

int MAPeriod3=72;              // D1 EMA for filter
int MAShift3=0;
int MAMethod3=MODE_EMA;
int MAPrice3=PRICE_CLOSE;

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

int TimeFrameRSI2=PERIOD_H1;          // RSI2 timeframe

int WindowPeriod1RSI2=17;             // hours in window of opportunity for RSI2 order trigger
int WindowPeriod2RSI2=25;             // hours in window of opportunity for RSI2 DH/AL formation

double RSI2high=62;                   // upper RSI trigger line
double RSI2low=38;                    // lower RSI trigger line

double RSI2rangeMin=0.20;             // RSI2 minimum range for movements
double RSI2rangeMax=3.5;              // RSI2 maximum range for movements

double RSI2rangeReturn1=0.20;         // RSI2 return range for movements between RSIrangeMin and RSIrangeMax
double RSI2rangeReturn2=1.25;         // RSI2 return range for movements exceeding RSIrangeMax

int RSI2Period=16;                    // RSI2 period
int RSI2Price=PRICE_CLOSE;            // RSI2 price

int    EnvPeriod2=20;                 // H1 Envelopes parameters (filter,SL,TP,FS,TS)
int    EnvMethod2=MODE_SMA;        
int    EnvShift2=0;
int    EnvPrice2=PRICE_CLOSE; 
double EnvDev2=0.30;

int RSI2_MACDfast1=12;               // H1 MACD filter
int RSI2_MACDslow1=26;
int RSI2_MACDsignal1=9;
int RSI2_MACDprice1=PRICE_CLOSE; 

int RSI2_MACDfast2=12;               // H4 MACD filter
int RSI2_MACDslow2=26;
int RSI2_MACDsignal2=9;
int RSI2_MACDprice2=PRICE_CLOSE; 

// Trend Determination (supplementary condition to WPR D1 condition)

int Tr_MAPeriod=72;             // D1 MA Trend condition
int Tr_Shift=0;
int Tr_Method=MODE_EMA;
int Tr_Price=PRICE_CLOSE;

int RSI2_WPRD1Period=18;             // D1 WPR filter (Group B)
double RSI2_WPRD1filterLong=-75;     // above which to allow longs
double RSI2_WPRD1filterShort=-25;    // below which to allow shorts

int bo2=15;                     // hours to prevent a new RSI2 Scalper order

                                // USDJPY
double tpEnv21=1.75;            // fraction of Envelope height for initial TP 
double fsEnv21=0.50;            // fraction of Envelope height to activate fixed-stop 
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

//bool mini=false;                 // true=mini-account, false=standard-account

// Universal parameters:

int sl=10;                      // pips above/below upper/lower Envelope for initial SL
int    FS=1;                    // fixed-stop value (BE+fs)
double tsEnv=0.50;              // fraction of Envelope height to trail stop

// Internal usage parameters:
int Slippage=3;
int lotsprecision=1;
int SLMin=32;                   // minimum universal SL
int Max=3;                      // maximum number of simultaneous orders

double lotsmin,lotsmax;
string comment1="ATC MACD";
string comment2="ATC RSI2";
string symbol1[],symbol2[];
double ot1[],ot2[],tpEnv1[],fsEnv1[],tpEnv2[],fsEnv2[];
bool short1[],long1[],short2[],long2[];
int lastH1[],lastH4[];
int Nsymbol=19;
int Norders;
int magic1=1111111112;
int magic2=1111111113;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//----

 if(!GlobalVariableCheck("SEMAPHORE")) GlobalVariableSet("SEMAPHORE",0);

 if(IsTesting()) Nsymbol=1;

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

 if(IsTesting())
 {
  symbol1[0]=Symbol(); 
  tpEnv1[0]=tpEnv11;  
  fsEnv1[0]=fsEnv11;  
  symbol2[0]=Symbol();  
  tpEnv2[0]=tpEnv21; 
  fsEnv2[0]=fsEnv21;  
 }
 else
 {
  bool mini;
  if(StringFind(Symbol(),"m")>0) mini=true;
  else mini=false;

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
 }
 
 lotsmin=0.10; 
 lotsmax=5.00;

// First check closed trades
 int trade,s;string sym;                      
 int trades=OrdersHistoryTotal();           
 for(trade=0;trade<trades;trade++) 
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_HISTORY);

  int D1bars=iBarShift(sym,PERIOD_D1,OrderCloseTime(),false);  
  if(D1bars>30)  
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
 for(trade=0;trade<trades;trade++) 
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
  SubmitOrdersMACD(); 
  SubmitOrdersRSI2();
 }
 ManageOrders();

 for(int s=0;s<Nsymbol;s++)
 {
  lastH1[s]=iTime(symbol2[s],TimeFrameRSI2,0); 
  lastH4[s]=iTime(symbol1[s],TimeFrameMACD,0);
 }
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert utility functions                                         |
//+------------------------------------------------------------------+

void SubmitOrdersMACD()
{
 if(Norders>=Max) return;

 double bid,ask,close,EnvUp,EnvDn,EnvDiff,macd1,macd2,SL,TP,lots;string sym;
 int i;
 
 for(int s=0;s<Nsymbol;s++)
 {

  if(Norders>=Max) return;  
  
  sym=symbol1[s];
  if(lastH4[s]==iTime(sym,TimeFrameMACD,0)) continue;
   
  int checktime=iBarShift(sym,TimeFrameMACD,ot1[s],false); 
  if(checktime<bo1) continue;

  bid=MarketInfo(sym,MODE_BID);

  macd1=iMACD(sym,TimeFrameMACD,MACDfast,MACDslow,MACDsignal,MACDprice,MODE_SIGNAL,0);
  macd2=iMACD(sym,TimeFrameMACD,MACDfast,MACDslow,MACDsignal,MACDprice,MODE_SIGNAL,1);  

  if(!long1[s])
  {     
   if(macd1>0&&macd2<0)   
   {  
    EnvUp=iEnvelopes(sym,TimeFrameMACD,EnvPeriod,EnvMethod,EnvShift,EnvPrice,EnvDev,MODE_UPPER,1);
    close=iClose(sym,TimeFrameMACD,1); 
        
    if(close>EnvUp)
    { 
     if(FilterMACD(sym,true,bid))
     {
      EnvUp=iEnvelopes(sym,TimeFrameMACD,EnvPeriod,EnvMethod,EnvShift,EnvPrice,EnvDev,MODE_UPPER,0);
      EnvDn=iEnvelopes(sym,TimeFrameMACD,EnvPeriod,EnvMethod,EnvShift,EnvPrice,EnvDev,MODE_LOWER,0);
      EnvDiff=EnvUp-EnvDn;
   
      ask=MarketInfo(sym,MODE_ASK);
  
      SL=NormDigits(sym,EnvDn-NormPoints(sym,sl));
      
      lots=CalculateLots();
    
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
   if(macd1<0&&macd2>0)   
   {   
    EnvDn=iEnvelopes(sym,TimeFrameMACD,EnvPeriod,EnvMethod,EnvShift,EnvPrice,EnvDev,MODE_LOWER,1);
    close=iClose(sym,TimeFrameMACD,1);     
      
    if(close<EnvDn)
    {     
     if(FilterMACD(sym,false,bid))
     {  
      EnvUp=iEnvelopes(sym,TimeFrameMACD,EnvPeriod,EnvMethod,EnvShift,EnvPrice,EnvDev,MODE_UPPER,0);
      EnvDn=iEnvelopes(sym,TimeFrameMACD,EnvPeriod,EnvMethod,EnvShift,EnvPrice,EnvDev,MODE_LOWER,0);
      EnvDiff=EnvUp-EnvDn;
      
      SL=NormDigits(sym,EnvUp+NormPoints(sym,sl));

      lots=CalculateLots();  

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
void SubmitOrdersRSI2()
{
 if(Norders>=Max) return;
 
 double bid,ask,close,EnvUp,EnvDn,EnvDiff,SL,TP,lots;string sym;
 int i, indexH1=0,indexL1=0,indexH2=0,indexL2=0,indexIMH=0,indexIML=0;
 double H1=0,L1=100,H2,L2=100,IMH=100,IML=0,val=0,diff1=0,diff2=0,now=0;
 int window1=WindowPeriod1RSI2, window2=0;
 
 for(int s=0;s<Nsymbol;s++)
 {
  if(Norders>=Max) return; 
  sym=symbol2[s];
  if(lastH1[s]==iTime(sym,TimeFrameRSI2,0)) continue;
  int checktime=iBarShift(sym,TimeFrameRSI2,ot2[s],false); 
  if(checktime<bo2) continue;

  bid=MarketInfo(sym,MODE_BID);
  
  indexH1=0;indexL1=0;indexH2=0;indexL2=0;indexIMH=0;indexIML=0;
  H1=0;L1=100;H2=0;L2=100;IMH=100;IML=0;val=0;diff1=0;diff2=0;now=0;
  window1=WindowPeriod1RSI2;window2=0;

  now=iRSI(sym,TimeFrameRSI2,RSI2Period,RSI2Price,1);
  for(i=4;i<=window1;i++)
  {
   val=iRSI(sym,TimeFrameRSI2,RSI2Period,RSI2Price,i);
   if(val>H1)
   {
    H1=val;
    indexH1=i;
   } 
   if(val<L1)
   {
    L1=val;
    indexL1=i;
   }
  }
 
  if(H1<RSI2high&&L1>RSI2low)  
   continue;
   
  if(H1>=RSI2high) 
  { 
   for(i=2;i<indexH1-1;i++)   
   {
    val=iRSI(sym,TimeFrameRSI2,RSI2Period,RSI2Price,i);
    if(val>H2)   
    {
     H2=val;
     indexH2=i;
    }    
   }

   window2=WindowPeriod2RSI2-(indexH1-indexH2);
   if(now>H2||window2<0)  
    continue;   
   
   for(i=indexH2;i<indexH1;i++)  
   {
    val=iRSI(sym,TimeFrameRSI2,RSI2Period,RSI2Price,i);
    if(val<IMH)   
    {
     IMH=val;
     indexIMH=i;
    }    
   }
   
   diff1=H1-IMH;
   diff2=H1-H2;
  
   if(!short2[s])
   { 
    if(FilterRSI2(sym,false,bid))
    {
     if(diff1>RSI2rangeMax&&diff2>=0&&diff2<=RSI2rangeReturn2)
     {   
      EnvUp=iEnvelopes(sym,TimeFrameRSI2,EnvPeriod2,EnvMethod2,EnvShift2,EnvPrice2,EnvDev2,MODE_UPPER,0);
      EnvDn=iEnvelopes(sym,TimeFrameRSI2,EnvPeriod2,EnvMethod2,EnvShift2,EnvPrice2,EnvDev2,MODE_LOWER,0);
      EnvDiff=EnvUp-EnvDn;
      
      if(sym=="GBPUSD"||sym=="GBPUSDm")
       SL=NormDigits(sym,EnvUp+NormPoints(sym,sl+5));      
      else
       SL=NormDigits(sym,EnvUp+NormPoints(sym,sl));

      lots=CalculateLots();  

      TP=NormDigits(sym,bid-tpEnv2[s]*EnvDiff);     
      SendOrderShort(sym,lots,Slippage,SL,TP,comment2,magic2,0,Red);

      ot2[s]=TimeCurrent(); 
      Norders++;      
      continue;            
     } 
     else if(diff1>=RSI2rangeMin&&diff1<=RSI2rangeMax&&diff2>=0&&diff2<=RSI2rangeReturn1)
     {    
      EnvUp=iEnvelopes(sym,TimeFrameRSI2,EnvPeriod2,EnvMethod2,EnvShift2,EnvPrice2,EnvDev2,MODE_UPPER,0);
      EnvDn=iEnvelopes(sym,TimeFrameRSI2,EnvPeriod2,EnvMethod2,EnvShift2,EnvPrice2,EnvDev2,MODE_LOWER,0);
      EnvDiff=EnvUp-EnvDn;

      if(sym=="GBPUSD"||sym=="GBPUSDm")
       SL=NormDigits(sym,EnvUp+NormPoints(sym,sl+5));      
      else
       SL=NormDigits(sym,EnvUp+NormPoints(sym,sl));
 
      lots=CalculateLots();  

      TP=NormDigits(sym,bid-tpEnv2[s]*EnvDiff);     
      SendOrderShort(sym,lots,Slippage,SL,TP,comment2,magic2,0,Red);

      ot2[s]=TimeCurrent(); 
      Norders++;
      continue;          
     }
    }
   }
  } 
 
  if(L1<=RSI2low) 
  {
   for(i=2;i<indexL1-1;i++)  
   {
    val=iRSI(sym,TimeFrameRSI2,RSI2Period,RSI2Price,i);
    if(val<L2)   
    {
     L2=val;
     indexL2=i;
    }    
   } 

   window2=WindowPeriod2RSI2-(indexL1-indexL2);
   if(now<L2||window2<0)  
    continue; 
    
   for(i=indexL2;i<indexL1;i++)  
   {
    val=iRSI(sym,TimeFrameRSI2,RSI2Period,RSI2Price,i);
    if(val>IML)   
    {
     IML=val;
     indexIML=i;
    }    
   }

   diff1=IML-L1;
   diff2=L2-L1;
   
   if(!long2[s])
   {
    if(FilterRSI2(sym,true,bid))
    {
     if(diff1>RSI2rangeMax&&diff2>=0&&diff2<=RSI2rangeReturn2)
     {        
      EnvUp=iEnvelopes(sym,TimeFrameRSI2,EnvPeriod2,EnvMethod2,EnvShift2,EnvPrice2,EnvDev2,MODE_UPPER,0);
      EnvDn=iEnvelopes(sym,TimeFrameRSI2,EnvPeriod2,EnvMethod2,EnvShift2,EnvPrice2,EnvDev2,MODE_LOWER,0);
      EnvDiff=EnvUp-EnvDn;
   
      ask=MarketInfo(sym,MODE_ASK);

      if(sym=="GBPUSD"||sym=="GBPUSDm")
       SL=NormDigits(sym,EnvDn-NormPoints(sym,sl+5));      
      else  
       SL=NormDigits(sym,EnvDn-NormPoints(sym,sl));
      
      lots=CalculateLots();
    
      TP=NormDigits(sym,ask+tpEnv2[s]*EnvDiff); 
         
      SendOrderLong(sym,lots,Slippage,SL,TP,comment2,magic2,0,Blue);
      ot2[s]=TimeCurrent();
      Norders++;
      continue;   
     }
     else if(diff1>=RSI2rangeMin&&diff1<=RSI2rangeMax&&diff2>=0&&diff2<=RSI2rangeReturn1)
     {
      EnvUp=iEnvelopes(sym,TimeFrameRSI2,EnvPeriod2,EnvMethod2,EnvShift2,EnvPrice2,EnvDev2,MODE_UPPER,0);
      EnvDn=iEnvelopes(sym,TimeFrameRSI2,EnvPeriod2,EnvMethod2,EnvShift2,EnvPrice2,EnvDev2,MODE_LOWER,0);
      EnvDiff=EnvUp-EnvDn;
   
      ask=MarketInfo(sym,MODE_ASK);
      
      if(sym=="GBPUSD"||sym=="GBPUSDm")
       SL=NormDigits(sym,EnvDn-NormPoints(sym,sl+5));      
      else  
       SL=NormDigits(sym,EnvDn-NormPoints(sym,sl));
      
      lots=CalculateLots();
    
      TP=NormDigits(sym,ask+tpEnv2[s]*EnvDiff);
     
      SendOrderLong(sym,lots,Slippage,SL,TP,comment2,magic2,0,Blue);
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
 
 double profit;string sym;
 int type,trade,trades=OrdersTotal(); 
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

   target=EnvTarget(sym,fsEnv1[s],TimeFrameMACD,EnvPeriod,EnvMethod,EnvShift,EnvPrice,EnvDev);
   if(profit>NormPoints(sym,target))
   {
    FixedStopsB(sym,target,FS);
    trail=EnvTarget(sym,tsEnv,TimeFrameMACD,EnvPeriod,EnvMethod,EnvShift,EnvPrice,EnvDev);
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

   target=EnvTarget(sym,fsEnv2[s],TimeFrameRSI2,EnvPeriod2,EnvMethod2,EnvShift2,EnvPrice2,EnvDev2);
   if(profit>NormPoints(sym,target))
   {
    FixedStopsB(sym,target,FS);
    trail=EnvTarget(sym,tsEnv,TimeFrameRSI2,EnvPeriod2,EnvMethod2,EnvShift2,EnvPrice2,EnvDev2);
    TrailingStop(sym,trail);
   }
  }  

//  if(lastH4[s]==iTime(sym,TimeFrameMACD,0)) continue;
 
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
bool FilterMACD(string sym, bool long, double bid)
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
     value1=iMA(sym,TimeFrameMACD,MAPeriod,MAShift,MAMethod,MAPrice,1);
     value2=iMA(sym,PERIOD_D1,MAPeriod3,MAShift3,MAMethod3,MAPrice3,1);                
     if(bid>value1&&bid>value2) Trigger[i]=1;
     break;
    case 1:
     value1=iMA(sym,TimeFrameMACD,MAPeriod,MAShift,MAMethod,MAPrice,1);      
     value2=iMA(sym,TimeFrameMACD,MAPeriod2,MAShift2,MAMethod2,MAPrice2,1); 
     if(value1>value2) Trigger[i]=1;
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
     value1=iMA(sym,TimeFrameMACD,MAPeriod,MAShift,MAMethod,MAPrice,1);
     value2=iMA(sym,PERIOD_D1,MAPeriod3,MAShift3,MAMethod3,MAPrice3,1);                
     if(bid<value1&&bid<value2) Trigger[i]=1;
     break;
    case 1:
     value1=iMA(sym,TimeFrameMACD,MAPeriod,MAShift,MAMethod,MAPrice,1);      
     value2=iMA(sym,TimeFrameMACD,MAPeriod2,MAShift2,MAMethod2,MAPrice2,1); 
     if(value1<value2) Trigger[i]=1;
     break;                                                 
   } 
   if(Trigger[i]<0) return(false);       
  }
 }
  
 
 return(true);   
}
//+------------------------------------------------------------------+
bool FilterRSI2(string sym, bool long, double bid)
{
 int Trigger[3], totN=3, i;
 double value1,value2;

 for(i=0;i<totN;i++) Trigger[i]=-1;

 if(long) // long filters
 {
  for(i=0;i<totN;i++)
  {
   switch(i)
   {        
    case 0:
      Trigger[i]=TrendB(sym,true);
     break;
    case 1:
     value1=iMACD(sym,TimeFrameRSI2,RSI2_MACDfast1,RSI2_MACDslow1,RSI2_MACDsignal1,RSI2_MACDprice1,MODE_MAIN,1);
     value2=iMACD(sym,TimeFrameRSI2,RSI2_MACDfast1,RSI2_MACDslow1,RSI2_MACDsignal1,RSI2_MACDprice1,MODE_SIGNAL,2);  
     if(value1>value2) Trigger[i]=1;
     break;      
    case 2:
     value1=iMACD(sym,PERIOD_H4,RSI2_MACDfast2,RSI2_MACDslow2,RSI2_MACDsignal2,RSI2_MACDprice2,MODE_MAIN,1);
     value2=iMACD(sym,PERIOD_H4,RSI2_MACDfast2,RSI2_MACDslow2,RSI2_MACDsignal2,RSI2_MACDprice2,MODE_SIGNAL,2);  
     if(value1>value2) Trigger[i]=1;
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
      Trigger[i]=TrendB(sym,false);
     break;
    case 1:
     value1=iMACD(sym,TimeFrameRSI2,RSI2_MACDfast1,RSI2_MACDslow1,RSI2_MACDsignal1,RSI2_MACDprice1,MODE_MAIN,1);
     value2=iMACD(sym,TimeFrameRSI2,RSI2_MACDfast1,RSI2_MACDslow1,RSI2_MACDsignal1,RSI2_MACDprice1,MODE_SIGNAL,2);  
     if(value1<value2) Trigger[i]=1;
     break; 
    case 2:
     value1=iMACD(sym,PERIOD_H4,RSI2_MACDfast2,RSI2_MACDslow2,RSI2_MACDsignal2,RSI2_MACDprice2,MODE_MAIN,1);
     value2=iMACD(sym,PERIOD_H4,RSI2_MACDfast2,RSI2_MACDslow2,RSI2_MACDsignal2,RSI2_MACDprice2,MODE_SIGNAL,2);  
     if(value1<value2) Trigger[i]=1;
     break;                                                      
   } 
   if(Trigger[i]<0) return(false);       
  }
 }
  
 
 return(true);  
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
int TrendB(string sym, bool flag)
{ 
 double bid=MarketInfo(sym,MODE_BID);   
 double value1=iWPR(sym,PERIOD_D1,RSI2_WPRD1Period,0);
 double value2=iMA(sym,PERIOD_D1,Tr_MAPeriod,Tr_Shift,Tr_Method,Tr_Price,0);
 if(flag)
 {
  if(value1<RSI2_WPRD1filterLong&&bid<value2) return(-1);
  else return(1);
 }
 else
 {
  if(value1>RSI2_WPRD1filterShort&&bid>value2) return(-1);
  else return(1); 
 }
 return(1);
}
//+------------------------------------------------------------------+
double CalculateLots()
{
 return(0.01);
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


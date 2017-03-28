//+----------------------------------------------------------------------+
//|                                           Complex Fractal Trader.mq4 |
//|                                                         David J. Lin |
//|Based on a strategy using VT Complex System & Fractals                |
//| written for John Stathers <stathersj@hotmail.com>                    |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|dave.j.lin@sbcglobal.net                                              |
//|Evanston, IL, November 27, 2007                                       |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2007-2008 John Stathers & David J. Lin"
#property link      ""

// User adjustable parameters:
extern int TimeFrame=0;               // Timeframe (use zero for current chart frame)
extern bool ProportionateLots=true;   // true => Lots based on equity, false => Lots fixed value
extern double Lots=0.3;               // lottage per trade (0.30 per $10000 equity, scaled proportionately if ProportionateLots is set to true, fixed value if set to false)
extern double MinimumEquity=1000;     // minimum equity, below which not to trade
extern double PercentTrigger=0.15;    // % of Fractal Channel breach to trigger breakout status
extern int MinimumFractalDepth=7;     // pips minimum Fractal Channel depth to permit trade
extern bool ConfirmFractal=false;     // true = use confirmed fractals, false = use unconfirmed fractals 
extern bool ImmediateFractal=true;    // true = = use most recent fractal as base, false = use previous fractal before directional arrow as base
extern bool FilterMA=false;           // true = use instantaneous MA filter
extern bool FilterMACD=false;         // true = use instantaneous MACD filter
extern bool FilterRSI=true;           // true = use instantaneous RSI filter
extern int FilterMin=1;               // minimum number of permissable filters (among MA, MACD, RSI) to qualify entry
extern int FilterSlopeMax=-1;         // fractals to consider for numerical slope filter (use negative number if not desired)
extern int FilterMinSlope=-1;         // mimimum slope in pips for numerical slope filter (use negative number if not desired)
extern int FilterSlopeMax2=-1;        // fractals to consider for positional slope filter (use negative number if not desired)
extern double RSILimitLong=48;        // RSI filter value above which to allow longs  (instantaneous value)
extern double RSILimitShort=52;       // RSI filter value below which to allow shorts (instantaneous value)

extern int BlackOutArrow1=1;          // trade only after this number of bars after confirmed directional arrow
extern int BlackOutArrow2=8;          // do not trade after this number of bars after confirmed directional arrow
extern int MaxOrdersPerArrow=1;       // maximum number of orders per arrow (per sub-type)
extern int MaxPastFirstEntry=5;       // maximum number of bars after 1st entry to allow more entries per confirmed directional arrow

extern int BlackoutStart=-1;          // GMT inclusive (use negative value to turn off)
extern int BlackoutEnd=-1;            // GMT inclusive (use negative value to turn off)

extern int StopLossA=90;              // pips from entry for initial SL (for breakouts) (use negative number if no SL is desired)
extern int StopLossB=35;              // pips from entry for initial SL (for non-breakouts) (use negative number if no SL is desired)
extern int SLProfit=20;               // pips profit after which to move SL  (use negative number if not desired)
extern int SLMove=5;                  // pips to move SL to BE+SLMove after SLProfit is reached 
extern int TrailStop=15;              // pips desired trailing stop, engages after SLProfit is hit (use negative number if no trail is desired)
extern int FrTrailStopLimit=-1;       // number of bars after which to apply Fractal Trail (use negative number if no trail is desired)

extern double Entry1A=0.80;           // (O1) (breakout)
extern double Entry2A=0.90;           // (O2) (breakout)
extern double Entry3A=1.00;           // (O3) (breakout)
extern double Entry4A=1.00;           // (O4) (breakout)
extern double Entry5A=1.00;           // (O5) (breakout)
extern double Entry6A=1.00;           // (O6) (breakout)
                                      // % of Fractal Channel retracement at which to enter order 
extern double Entry1B=0.80;           // (O1) (non-breakout)
extern double Entry2B=0.84;           // (O2) (non-breakout)
extern double Entry3B=0.88;           // (O3) (non-breakout)
extern double Entry4B=0.92;           // (O4) (non-breakout)
extern double Entry5B=0.96;           // (O5) (non-breakout)
extern double Entry6B=1.00;           // (O6) (non-breakout)

extern double MinDepth1=-1;         // % of Fractal Channel that price must've visited to allow O1 (use negative value to deactivate)
extern double MinDepth2=-1;         // % of Fractal Channel that price must've visited to allow O2 (use negative value to deactivate)
extern double MinDepth3=-1;         // % of Fractal Channel that price must've visited to allow O3 (use negative value to deactivate)
extern double MinDepth4=-1;         // % of Fractal Channel that price must've visited to allow O4 (use negative value to deactivate)
extern double MinDepth5=-1;         // % of Fractal Channel that price must've visited to allow O5 (use negative value to deactivate)
extern double MinDepth6=-1;         // % of Fractal Channel that price must've visited to allow O6 (use negative value to deactivate)

extern bool TakeProfitPipsA=true;     // Set A TP toggle: true = use number of pips, false = use percentage of Fractal Channel
                                      // pips TP or % of Fractal Channel at which to TP (use negative value for TP beyond Fractal Channel)
extern double TakeProfit1A=16;        // (O1) (breakout)  
extern double TakeProfit2A=18;        // (O2) (breakout) 
extern double TakeProfit3A=19;        // (O3) (breakout) 
extern double TakeProfit4A=21;        // (O4) (breakout) 
extern double TakeProfit5A=23;        // (O5) (breakout) 
extern double TakeProfit6A=25;        // (O6) (breakout) 

extern bool TakeProfitPipsB=true;     // Set B TP toggle: true = use number of pips, false = use percentage of Fractal Channel
                                      // pips TP or % of Fractal Channel at which to TP (use negative value for TP beyond Fractal Channel)
extern double TakeProfit1B=15;        // (O1) (non-breakout) 
extern double TakeProfit2B=17;        // (O2) (non-breakout) 
extern double TakeProfit3B=19;        // (O3) (non-breakout) 
extern double TakeProfit4B=21;        // (O4) (non-breakout) 
extern double TakeProfit5B=23;        // (O5) (non-breakout) 
extern double TakeProfit6B=25;        // (O6) (non-breakout) 

extern int StartFriA=-1;              // 2nd Friday blackout after this day of month (inclusive)   (use negative value to deactivate)
extern int EndFriA=-1;                // 2nd Friday blackout before this day of month (inclusive)  (use negative value to deactivate)
extern int StartFriB=-1;              // final Friday blackout after this day of month (inclusive) (use negative value to deactivate)
extern int EndFriB=-1;                // final Friday blackout before this day of month (inclusive)(use negative value to deactivate)
extern int LastDay=-1;                // begin end of month blackout days (inclusive)              (use negative value to deactivate)

int TPMinPips=1;                      // minimum TP
int FractalSL=3;                      // number of previous Fractal levels to consider for Fractal SL trail

// VT Complex System parameters
int MAperiod1=5;
int MAperiod2=10;
int MAshift1=0;
int MAshift2=0;
int MAmethod1=MODE_SMA;
int MAmethod2=MODE_SMA;
int MAprice1=PRICE_CLOSE;
int MAprice2=PRICE_CLOSE;
int MACDfast=12;
int MACDslow=26;
int MACDsignal=9;
int MACDprice=PRICE_CLOSE;
int RSIperiod=14; 
int RSIprice=PRICE_CLOSE;

// Internal usage parameters:
int Slippage=3,bo=1;
int lotsprecision=2;
double lotsmin,lotsmax;
double TPMinPoints;
bool First;
bool LongExit,ShortExit;
bool LongTrigger,ShortTrigger,LongArrow,ShortArrow;
datetime LongArrowTime,ShortArrowTime,FirstEntryTime;
color clrL=Blue,clrS=Red;
string strL="Long",strS="Short";
int code=1;
datetime lasttime;
string ciComplexFractal="Complex Fractal";
double FUp,FDn,FDiff;
int NArrow=0;
bool BreakUp,BreakDn;
double Entry[2,6],TakeProfit[2,6],MinDepth[6];
string comment[2,6];
int magic[2,6];
datetime otL[2,6],otS[2,6];
double LongTarget[2,6],ShortTarget[2,6];
bool LongOrder[2,6],ShortOrder[2,6],TakeProfitPips[2];
bool AlertAlarm=true,AlertEmail=true;
int NOrdersPerArrow[2,6];
int StopLoss[2];
double ProfitLong,ProfitShort;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//----
 First=true;
 if(TimeFrame==0) TimeFrame=Period();

 lotsmin=MarketInfo(Symbol(),MODE_MINLOT); 
 lotsmax=MarketInfo(Symbol(),MODE_MAXLOT);

 if(lotsmin==0.10) lotsprecision=1;

 magic[0,0]  =110000+TimeFrame; 
 magic[0,1]  =120000+TimeFrame;
 magic[0,2]  =130000+TimeFrame;
 magic[0,3]  =140000+TimeFrame;
 magic[0,4]  =150000+TimeFrame;
 magic[0,5]  =160000+TimeFrame;    

 magic[1,0]  =210000+TimeFrame; 
 magic[1,1]  =220000+TimeFrame;
 magic[1,2]  =230000+TimeFrame;
 magic[1,3]  =240000+TimeFrame;
 magic[1,4]  =250000+TimeFrame;
 magic[1,5]  =260000+TimeFrame;  
 
 string pd;
 switch(TimeFrame)
 {
  case 1:     pd="M1"; break;
  case 5:     pd="M5"; break;
  case 15:    pd="M15";break;
  case 30:    pd="M30";break;
  case 60:    pd="H1"; break;
  case 120:   pd="H2"; break;
  case 240:   pd="H4"; break;
  case 1440:  pd="D1"; break;
  case 10080: pd="W1"; break;
  case 40320: pd="M1"; break;
  default:    pd="Unknown";break;
 }
 comment[0,0]  =StringConcatenate(pd," CompFract 1A"); 
 comment[0,1]  =StringConcatenate(pd," CompFract 2A");
 comment[0,2]  =StringConcatenate(pd," CompFract 3A");
 comment[0,3]  =StringConcatenate(pd," CompFract 4A");
 comment[0,4]  =StringConcatenate(pd," CompFract 5A");
 comment[0,5]  =StringConcatenate(pd," CompFract 6A");     

 comment[1,0]  =StringConcatenate(pd," CompFract 1B"); 
 comment[1,1]  =StringConcatenate(pd," CompFract 2B");
 comment[1,2]  =StringConcatenate(pd," CompFract 3B");
 comment[1,3]  =StringConcatenate(pd," CompFract 4B");
 comment[1,4]  =StringConcatenate(pd," CompFract 5B");
 comment[1,5]  =StringConcatenate(pd," CompFract 6B");

 Entry[0,0]=Entry1A;
 Entry[0,1]=Entry2A;
 Entry[0,2]=Entry3A;
 Entry[0,3]=Entry4A;
 Entry[0,4]=Entry5A;
 Entry[0,5]=Entry6A;     

 Entry[1,0]=Entry1B;
 Entry[1,1]=Entry2B;
 Entry[1,2]=Entry3B;
 Entry[1,3]=Entry4B;
 Entry[1,4]=Entry5B;
 Entry[1,5]=Entry6B; 

 MinDepth[0]=MinDepth1;
 MinDepth[1]=MinDepth2;
 MinDepth[2]=MinDepth3;
 MinDepth[3]=MinDepth4;
 MinDepth[4]=MinDepth5;
 MinDepth[5]=MinDepth6;

 TakeProfitPips[0]=TakeProfitPipsA;
 TakeProfitPips[1]=TakeProfitPipsB;
 
 TakeProfit[0,0]=TakeProfit1A; 
 TakeProfit[0,1]=TakeProfit2A; 
 TakeProfit[0,2]=TakeProfit3A; 
 TakeProfit[0,3]=TakeProfit4A; 
 TakeProfit[0,4]=TakeProfit5A; 
 TakeProfit[0,5]=TakeProfit6A; 
 
 TakeProfit[1,0]=TakeProfit1B; 
 TakeProfit[1,1]=TakeProfit2B; 
 TakeProfit[1,2]=TakeProfit3B; 
 TakeProfit[1,3]=TakeProfit4B; 
 TakeProfit[1,4]=TakeProfit5B; 
 TakeProfit[1,5]=TakeProfit6B; 
 
// First check closed trades
 int trade;                         
 int trades=OrdersHistoryTotal();           
 for(trade=0;trade<trades;trade++)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_HISTORY);

  if(OrderSymbol()!=Symbol())
   continue;

  int D1bars=iBarShift(NULL,PERIOD_D1,OrderCloseTime(),false);
  if(D1bars>30)
   continue;
   
  Status(OrderMagicNumber());
 }

// Now check open orders
                       
 trades=OrdersTotal();           
 for(trade=0;trade<trades;trade++)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()!=Symbol())
   continue;

  Status(OrderMagicNumber());
  if(OrderType()==OP_BUY)       DrawCross(OrderOpenPrice(),OrderOpenTime(),strL,clrL,code);
  else if(OrderType()==OP_SELL) DrawCross(OrderOpenPrice(),OrderOpenTime(),strS,clrS,code);
 }
 
 HideTestIndicators(true);
 ManageOrders(); 

 TPMinPoints=NormPoints(TPMinPips);
 StopLoss[0]=StopLossA;
 StopLoss[1]=StopLossB;
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
 if(lasttime!=iTime(NULL,TimeFrame,0)) 
 {
  TriggerOrders();
 }
 lasttime=iTime(NULL,TimeFrame,0);  
 SubmitOrders(); 
 ManageOrders();
 BailOrders(); 
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert utility functions                                         |
//+------------------------------------------------------------------+

void SubmitOrders()
{
 LongExit=false; ShortExit=false;

 if(First) return;
 if(BlackOuts()) return;
// if(BreakUp||BreakDn) return;
 
 int checktime;
 if(FirstEntryTime!=0) // limit entries to be within a certain maximum bars past the first entry
 {
  checktime=iBarShift(NULL,TimeFrame,FirstEntryTime,false);
  if(checktime>MaxPastFirstEntry) return;
 }
      
 double lots,SL,TP,value; 
 int i,j;
 string message;

 if(LongTrigger)
 {
  if(BreakUp) i=0;
  else        i=1;
  if(Bid<=LongTarget[i,0])
  {
   for(j=0;j<6;j++)
   {  
    if(Bid<=LongTarget[i,j])
    {   
     if(LongOrder[i,j])
     {
      if(NOrdersPerArrow[i,j]<MaxOrdersPerArrow)
      {
       checktime=iBarShift(NULL,TimeFrame,otL[i,j],false);

       if(checktime>=bo)
       {
        if(Filter(true,j))
        {   
         lots=CalcLottage(); 
         SL=StopLong(Ask,StopLoss[i]);

         if(TakeProfitPips[i])
          TP=TakeLong(Ask,TakeProfit[i,j]);        
         else
         {
          value=NormDigits(FUp+(Ask-Bid)); // adjust for spread
          TP=TakeShort(value,TakeProfit[i,j]*FDiff/Point); // use reversed TP cal for % TP retracements
         }
         SendOrderLong(Symbol(),lots,Slippage,SL,TP,comment[i,j],magic[i,j],0,Blue);
         NOrdersPerArrow[i,j]=NOrdersPerArrow[i,j]+1;
         if (AlertAlarm||AlertEmail)
         {
          message=StringConcatenate(Symbol()," ",comment[i,j]," Long Entry at Ask=",DoubleToStr(Ask,Digits),", SL=",DoubleToStr(SL,Digits)," TP=",DoubleToStr(TP,Digits)," at ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES));
          SendMessage(message);
         } 
    
//    ShortExit=true;
         otL[i,j]=TimeCurrent();
         if(FirstEntryTime==0) FirstEntryTime=TimeCurrent(); 
        }
       }
      }
     }
    }
   }
  }  
 }
 else if(ShortTrigger)
 { 
  if(BreakDn) i=0;
  else        i=1; 
  if(Bid>=ShortTarget[i,0])
  { 
   for(j=0;j<6;j++)
   {  
    if(Bid>=ShortTarget[i,j])
    {   
     if(ShortOrder[i,j])
     {  
      if(NOrdersPerArrow[i,j]<MaxOrdersPerArrow)
      {   
       checktime=iBarShift(NULL,TimeFrame,otS[i,j],false);
       if(checktime>=bo)
       {
        if(Filter(false,j))
        {  
         lots=CalcLottage();
        //value=NormDigits(FUp+(Ask-Bid)); // adjust for spread (for relative SL) 
         SL=StopShort(Bid,StopLoss[i]); // (for absolulte SL)

         if(TakeProfitPips[i]) 
          TP=TakeShort(Bid,TakeProfit[i,j]);               
         else
          TP=TakeLong(FDn,TakeProfit[i,j]*FDiff/Point); // use reversed TP cal for % TP retracements
         SendOrderShort(Symbol(),lots,Slippage,SL,TP,comment[i,j],magic[i,j],0,Red);  
         NOrdersPerArrow[i,j]=NOrdersPerArrow[i,j]+1; 

         if (AlertAlarm||AlertEmail)
         {
          message=StringConcatenate(Symbol()," ",comment[i,j]," Short Entry at Bid=",DoubleToStr(Bid,Digits),", SL=",DoubleToStr(SL,Digits)," TP=",DoubleToStr(TP,Digits)," at ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES));
          SendMessage(message);
         } 

//    LongExit=true;         
         otS[i,j]=TimeCurrent();
         if(FirstEntryTime==0) FirstEntryTime=TimeCurrent();        
        }
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
void TriggerOrders()
{
 VTComplexFractal();

// Print(TimeFrame," FUp ",FUp," FDn ",FDn," LTime ",TimeToStr(LongArrowTime,TIME_DATE|TIME_MINUTES)," STime ",TimeToStr(ShortArrowTime,TIME_DATE|TIME_MINUTES)," LArrow ",LongArrow," SArrow ",ShortArrow);

 LongTrigger=false;
 ShortTrigger=false;
 int i,j,checktime,shift;
 double fup,fdn,fdiff;

 if(LongArrow)
 {
  checktime=iBarShift(NULL,TimeFrame,LongArrowTime,false);
  if(checktime>=BlackOutArrow1 && checktime<=BlackOutArrow2)
  {
   LongTrigger=true; 
   if(BreakUp) i=0;
   else        i=1;

   if(ImmediateFractal)
   {
    for(i=0;i<2;i++)
    {
     for(j=0;j<6;j++)
     { 
      if(Entry[i,j]>0) LongTarget[i,j]=NormDigits(FUp-NormDigits(Entry[i,j]*FDiff));
      else             LongTarget[i,j]=-1;
     }
    }
   }
   else
   {
    for(i=0;i<2;i++)
    {
     for(j=0;j<6;j++)
     { 
      fdn=iCustom(NULL,TimeFrame,ciComplexFractal,MAperiod1,MAperiod2,MAshift1,MAshift2,MAmethod1,MAmethod2,MAprice1,MAprice2,MACDfast,MACDslow,MACDsignal,MACDprice,RSIperiod,RSIprice,5,NArrow);
      fdiff=FUp-fdn;
      if(fdiff>0)
      {      
       if(Entry[i,j]>0) LongTarget[i,j]=NormDigits(FUp-NormDigits(Entry[i,j]*fdiff));
       else             LongTarget[i,j]=-1;
      }
     }
    }
   }           
  }
 }
 else if(ShortArrow)
 {
  checktime=iBarShift(NULL,TimeFrame,ShortArrowTime,false);
  if(checktime>=BlackOutArrow1 && checktime<=BlackOutArrow2)
  {
   ShortTrigger=true;   
   if(BreakDn) i=0;
   else        i=1;
   
   if(ImmediateFractal)
   { 
    for(i=0;i<2;i++)
    {
     for(j=0;j<6;j++)
     {    
      if(Entry[i,j]>0) ShortTarget[i,j]=NormDigits(FDn+NormDigits(Entry[i,j]*FDiff));
      else             ShortTarget[i,j]=-1; 
     }
    }  
   }
   else
   {
    for(i=0;i<2;i++)
    {
     for(j=0;j<6;j++)
     { 
      fup=iCustom(NULL,TimeFrame,ciComplexFractal,MAperiod1,MAperiod2,MAshift1,MAshift2,MAmethod1,MAmethod2,MAprice1,MAprice2,MACDfast,MACDslow,MACDsignal,MACDprice,RSIperiod,RSIprice,4,NArrow);
      fdiff=fup-FDn;
      if(fdiff>0)
      {
       if(Entry[i,j]>0) ShortTarget[i,j]=NormDigits(FDn+NormDigits(Entry[i,j]*fdiff));
       else             ShortTarget[i,j]=-1;
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
 LongOrder[0,0]=true; // faster without for looping
 LongOrder[0,1]=true;
 LongOrder[0,2]=true;
 LongOrder[0,3]=true;
 LongOrder[0,4]=true;
 LongOrder[0,5]=true;
 LongOrder[1,0]=true;
 LongOrder[1,1]=true;
 LongOrder[1,2]=true;
 LongOrder[1,3]=true;
 LongOrder[1,4]=true;
 LongOrder[1,5]=true;       
         
 ShortOrder[0,0]=true;
 ShortOrder[0,1]=true;
 ShortOrder[0,2]=true;
 ShortOrder[0,3]=true;
 ShortOrder[0,4]=true;
 ShortOrder[0,5]=true;
 ShortOrder[1,0]=true;
 ShortOrder[1,1]=true;
 ShortOrder[1,2]=true;
 ShortOrder[1,3]=true;
 ShortOrder[1,4]=true;
 ShortOrder[1,5]=true;
 
 ProfitLong=0;ProfitShort=0;

 int mn,trail,trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;

  mn=OrderMagicNumber();
  
       if(mn==magic[0,0]) Order1A();
  else if(mn==magic[0,1]) Order2A();
  else if(mn==magic[0,2]) Order3A();  
  else if(mn==magic[0,3]) Order4A();
  else if(mn==magic[0,4]) Order5A();
  else if(mn==magic[0,5]) Order6A();
  else if(mn==magic[1,0]) Order1B();
  else if(mn==magic[1,1]) Order2B();
  else if(mn==magic[1,2]) Order3B();  
  else if(mn==magic[1,3]) Order4B();
  else if(mn==magic[1,4]) Order5B();
  else if(mn==magic[1,5]) Order6B();
 }
 return;
}
//+------------------------------------------------------------------+
void Order1A()
{ 
 LogProfit();
 OrderStatus(0,0);
 ExitOrder(LongExit,ShortExit);
 MoveTrailStops();
 return;
}
//+------------------------------------------------------------------+
void Order2A()
{ 
 LogProfit();
 OrderStatus(0,1);
 ExitOrder(LongExit,ShortExit);
 MoveTrailStops();
 return;
}
//+------------------------------------------------------------------+
void Order3A()
{ 
 LogProfit();
 OrderStatus(0,2);
 ExitOrder(LongExit,ShortExit);
 MoveTrailStops();
 return;
}
//+------------------------------------------------------------------+
void Order4A()
{ 
 LogProfit();
 OrderStatus(0,3);
 ExitOrder(LongExit,ShortExit);
 MoveTrailStops();
 return;
}
//+------------------------------------------------------------------+
void Order5A()
{ 
 LogProfit();
 OrderStatus(0,4);
 ExitOrder(LongExit,ShortExit);
 MoveTrailStops();
 return;
}
//+------------------------------------------------------------------+
void Order6A()
{ 
 LogProfit();
 OrderStatus(0,5);
 ExitOrder(LongExit,ShortExit);
 MoveTrailStops();
 return;
}
//+------------------------------------------------------------------+
void Order1B()
{ 
 LogProfit(); 
 OrderStatus(1,0);
 ExitOrder(LongExit,ShortExit);
 MoveTrailStops(); 
 return;
}
//+------------------------------------------------------------------+
void Order2B()
{ 
 LogProfit();
 OrderStatus(1,1);
 ExitOrder(LongExit,ShortExit);
 MoveTrailStops();
 return;
}
//+------------------------------------------------------------------+
void Order3B()
{ 
 LogProfit();
 OrderStatus(1,2);
 ExitOrder(LongExit,ShortExit);
 MoveTrailStops();
 return;
}
//+------------------------------------------------------------------+
void Order4B()
{ 
 LogProfit();
 OrderStatus(1,3);
 ExitOrder(LongExit,ShortExit);
 MoveTrailStops();
 return;
}
//+------------------------------------------------------------------+
void Order5B()
{ 
 LogProfit();
 OrderStatus(1,4);
 ExitOrder(LongExit,ShortExit);
 MoveTrailStops();
 return;
}
//+------------------------------------------------------------------+
void Order6B()
{ 
 LogProfit();
 OrderStatus(1,5);
 ExitOrder(LongExit,ShortExit);
 MoveTrailStops(); 
 return;
}
//+------------------------------------------------------------------+
void OrderStatus(int i,int j)
{
 if(OrderType()==OP_BUY)       
 {
  if(OrderOpenTime()>=LongArrowTime) LongOrder[i,j]=false;   // allows multiple orders after a directional arrow change
 }
 else if(OrderType()==OP_SELL) 
 {
  if(OrderOpenTime()>=ShortArrowTime) ShortOrder[i,j]=false; // allows multiple orders after a directional arrow change
 } 
 return;
}
//+------------------------------------------------------------------+
void LogProfit()
{
 datetime opentime=OrderOpenTime();
 if(opentime>=ShortArrowTime&&opentime>=LongArrowTime) return; // only for previous-set orders
  
 if(OrderType()==OP_BUY)       
 {
  ProfitLong+=DetermineProfit();
 }
 else if(OrderType()==OP_SELL) 
 {
  ProfitShort+=DetermineProfit();
 } 
 return;
}
//+------------------------------------------------------------------+
bool Filter(bool long, int orderindex)
{
 int Trigger[5],totN=5, i,j,k,N,shift;
 double value1,value2,fup,fdn,value[10],index[10],slope;
 bool trig;
 
 for(i=0;i<totN;i++) Trigger[i]=-1;

 if(long) // long filters
 {
  for(i=0;i<totN;i++)
  {
   switch(i)
   { 
    case 0:
     if(FDiff>=NormPoints(MinimumFractalDepth)) Trigger[i]=1;
     break;
    case 1:
     if(FilterSlopeMax>=0)
     {
      N=0;
      for(j=3;j<1000;j++)
      {
       if(iFractals(NULL,TimeFrame, MODE_LOWER, j)<=0) continue;
       value[N]=iLow(NULL,TimeFrame,j);
       index[N]=j;
       N++;
       if(N==FilterSlopeMax) break;
      }
      slope=0;
      for(j=0;j<FilterSlopeMax-1;j++)
      {
       slope+=NormDigits(value[j]-value[FilterSlopeMax-1]);
      }
      slope/=FilterSlopeMax-1;
      if(slope>NormPoints(FilterMinSlope)) Trigger[i]=1;  
     }
     else Trigger[i]=1;
     break;
    case 2:
     if(FilterSlopeMax2>=0)
     {     
      N=0;
      for(j=3;j<1000;j++)
      {
       if(iFractals(NULL,TimeFrame, MODE_LOWER, j)<=0) continue;
       value[N]=iLow(NULL,TimeFrame,j);
       index[N]=j;
       N++;
       if(N>FilterSlopeMax2) break;
      }    
      trig=true;
      for(j=0;j<FilterSlopeMax2;j++)
      {   
       if(value[j]<value[j+1]) 
       { 
        trig=false;
        break;
       }
      }
      if(trig) Trigger[i]=1;
     }
     else Trigger[i]=1;
     break;       
    case 3: // MAs, MACD, RSI
     N=0;
     if(FilterMA)
     {
      value1=iMA(NULL,TimeFrame,MAperiod1,MAshift1,MAmethod1,MAprice1,0);
      value2=iMA(NULL,TimeFrame,MAperiod2,MAshift2,MAmethod2,MAprice2,0);
      if(value1>value2) N++;
     }

     if(FilterMACD)
     {     
      value1=iMACD(NULL,TimeFrame,MACDfast,MACDslow,MACDsignal,MACDprice,MODE_MAIN,0);
      value2=iMACD(NULL,TimeFrame,MACDfast,MACDslow,MACDsignal,MACDprice,MODE_SIGNAL,0);
      if(value1>value2) N++;   
     }
     
     if(FilterRSI)
     {
      value1=iRSI(NULL,TimeFrame,RSIperiod,RSIprice,0);
      if(value1>=RSILimitLong) N++;
     }

     if(N>=FilterMin) Trigger[i]=1;
     if(!FilterMA&&!FilterMACD&&!FilterRSI) Trigger[i]=1;     
     break;
    case 4: // fractal channel depth filter
     if(MinDepth[orderindex]>0)
     {    
      shift=iHighest(NULL,TimeFrame,MODE_HIGH,NArrow+1,0);
      value1=iHigh(NULL,TimeFrame,shift);
      fup=iCustom(NULL,TimeFrame,ciComplexFractal,MAperiod1,MAperiod2,MAshift1,MAshift2,MAmethod1,MAmethod2,MAprice1,MAprice2,MACDfast,MACDslow,MACDsignal,MACDprice,RSIperiod,RSIprice,4,NArrow);
      fdn=iCustom(NULL,TimeFrame,ciComplexFractal,MAperiod1,MAperiod2,MAshift1,MAshift2,MAmethod1,MAmethod2,MAprice1,MAprice2,MACDfast,MACDslow,MACDsignal,MACDprice,RSIperiod,RSIprice,5,NArrow);
      value2=NormDigits(fdn+MinDepth[orderindex]*(fup-fdn));
      if(value1>=value2) Trigger[i]=1;
     }
     else Trigger[i]=1;
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
     if(FDiff>=NormPoints(MinimumFractalDepth)) Trigger[i]=1;
     break;   
    case 1:
     if(FilterSlopeMax>=0)
     {    
      N=0;
      for(j=3;j<1000;j++)
      {
       if(iFractals(NULL,TimeFrame, MODE_UPPER, j)<=0) continue;
       value[N]=iHigh(NULL,TimeFrame,j);
       index[N]=j;     
       N++;
       if(N==FilterSlopeMax) break;
      }
      slope=0;
      for(j=0;j<FilterSlopeMax-1;j++)
      {
       slope+=NormDigits(value[j]-value[FilterSlopeMax-1]);
      }
      slope/=FilterSlopeMax-1;
      if(slope<-NormPoints(FilterMinSlope)) Trigger[i]=1; 
     }
     else Trigger[i]=1;
     break;
    case 2:
     if(FilterSlopeMax2>=0)
     {     
      N=0;
      for(j=3;j<1000;j++)
      {
       if(iFractals(NULL,TimeFrame, MODE_UPPER, j)<=0) continue;
       value[N]=iHigh(NULL,TimeFrame,j);
       index[N]=j;     
       N++;
       if(N>FilterSlopeMax2) break;
      }    
      trig=true;
      for(j=0;j<FilterSlopeMax2;j++)
      {   
       if(value[j]>value[j+1]) 
       { 
        trig=false;
        break;
       }
      }
      if(trig) Trigger[i]=1;     
     }
     else Trigger[i]=1;
     break;      
    case 3: // MAs, MACD, RSI
     N=0;
     if(FilterMA)
     {
      value1=iMA(NULL,TimeFrame,MAperiod1,MAshift1,MAmethod1,MAprice1,0);
      value2=iMA(NULL,TimeFrame,MAperiod2,MAshift2,MAmethod2,MAprice2,0);
      if(value1<value2) N++;
     }
     
     if(FilterMACD)
     {
      value1=iMACD(NULL,TimeFrame,MACDfast,MACDslow,MACDsignal,MACDprice,MODE_MAIN,0);
      value2=iMACD(NULL,TimeFrame,MACDfast,MACDslow,MACDsignal,MACDprice,MODE_SIGNAL,0);
      if(value1<value2) N++;
     }
     
     if(FilterRSI)
     {
      value1=iRSI(NULL,TimeFrame,RSIperiod,RSIprice,0);    
      if(value1<=RSILimitShort) N++;
     }
     
     if(N>=FilterMin) Trigger[i]=1;
     if(!FilterMA&&!FilterMACD&&!FilterRSI) Trigger[i]=1;
     break;
    case 4: // fractal channel depth filter
     if(MinDepth[orderindex]>0)
     {
      shift=iLowest(NULL,TimeFrame,MODE_LOW,NArrow+1,0);
      value1=iLow(NULL,TimeFrame,shift);
      fup=iCustom(NULL,TimeFrame,ciComplexFractal,MAperiod1,MAperiod2,MAshift1,MAshift2,MAmethod1,MAmethod2,MAprice1,MAprice2,MACDfast,MACDslow,MACDsignal,MACDprice,RSIperiod,RSIprice,4,NArrow);
      fdn=iCustom(NULL,TimeFrame,ciComplexFractal,MAperiod1,MAperiod2,MAshift1,MAshift2,MAmethod1,MAmethod2,MAprice1,MAprice2,MACDfast,MACDslow,MACDsignal,MACDprice,RSIperiod,RSIprice,5,NArrow);
      value2=NormDigits(fup-MinDepth[orderindex]*(fup-fdn));
      if(value1<=value2) Trigger[i]=1;
     }
     else Trigger[i]=1;
     break;     
   } 
   if(Trigger[i]<0) return(false);    
  }
 }
  
 return(true);  // no anti-trigger:  so, return true (to order)
}

//+------------------------------------------------------------------+

int SendOrderLong(string sym, double vol, int slip, double sl, double tp, string comment="", int m=0, datetime exp=0, color cl=CLR_NONE)
{  
 if(vol==0.00) return;

 int err;
 bool attempt=true;
 while(attempt)
 {
  if(IsTradeAllowed())
  {
   for(int z=0;z<5;z++)
   {  
    tp=UniversalTPMin(Ask,tp,true);   
    if(OrderSend(sym,OP_BUY,NormLots(vol),Ask,slip,NormDigits(sl),NormDigits(tp),comment,m,exp,cl)<0)
    {  
     err = GetLastError();
     Print("OrderSend Long failed, Error: ", err);
     Print("Ask: ", Ask, " S/L ", sl, " T/P ", tp);
     if(err>4000)
     { 
      attempt=false;
      break;
     }     
     RefreshRates();
     UniversalTPMin(Ask,tp,true);
    }
    else 
    {
     attempt=false;
     break;
    }
   }
  }
 }
 return(0);
}
//+------------------------------------------------------------------+

int SendOrderShort(string sym, double vol, int slip, double sl, double tp, string comment="", int m=0, datetime exp=0, color cl=CLR_NONE)
{  
 if(vol==0.00) return;

 int err;
 bool attempt=true;
 while(attempt)
 {
  if(IsTradeAllowed())
  {
   for(int z=0;z<5;z++)
   {  
    tp=UniversalTPMin(Bid,tp,false);   
    if(OrderSend(sym,OP_SELL,NormLots(vol),Bid,slip,NormDigits(sl),NormDigits(tp),comment,m,exp,cl)<0)
    {  
     err = GetLastError();
     Print("OrderSend Short failed, Error: ", err);
     Print("Bid: ", Bid, " S/L ", sl, " T/P ", tp);   
     if(err>4000)
     { 
      attempt=false;
      break;
     }     
     RefreshRates();
     UniversalTPMin(Bid,tp,false);     
    }
    else 
    {
     attempt=false;
     break;
    }
   }
  }
 }
 return(0);
}

//+------------------------------------------------------------------+
bool CloseOrderLong(int ticket, double lots, int slip, color cl=CLR_NONE)
{ 
 bool attempt=true;
 while(attempt)
 {
  if(IsTradeAllowed())
  {
   for(int z=0;z<10;z++)
   {
    if(!OrderClose(ticket,NormLots(lots),Bid,slip,cl))
    {  
     int err = GetLastError();
     Print("OrderClose Long failed, Error: ", err, " Ticket #: ", ticket);
     Print("Bid: ", Bid);   
     if(err>4000)
     { 
      attempt=false;
      break;
     }     
     RefreshRates();
    }
    else
    {
     attempt=false;
     break;
    }
   }
  }
 }
 return(true);
} 
//+------------------------------------------------------------------+
bool CloseOrderShort(int ticket, double lots, int slip, color cl=CLR_NONE)
{
 bool attempt=true;
 while(attempt)
 {
  if(IsTradeAllowed())
  {
   for(int z=0;z<10;z++)
   {
    if(!OrderClose(ticket,NormLots(lots),Ask,slip,cl))
    {  
     int err = GetLastError();
     Print("OrderClose Short failed, Error: ", err, " Ticket #: ", ticket);
     Print("Ask: ", Ask);   
     if(err>4000)
     { 
      attempt=false;
      break;
     }     
     RefreshRates();
    }
    else
    {
     attempt=false;
     break;
    }
   }
  }
 }
 return(true);
} 
//+------------------------------------------------------------------+
void BailOrders()
{
 if(ShortArrow&&ProfitLong>0)
 {
  ExitAggregate(1);
 }
 else if(LongArrow&&ProfitShort>0)
 {
  ExitAggregate(2);
 }
 return;
}
//+------------------------------------------------------------------+
void MoveTrailStops()
{
 double profit=DetermineProfit();
 
 if(FrTrailStopLimit>=0) FractalTrail();
 
 if(SLProfit>0) 
 {
  FixedStopsB(SLProfit,SLMove);
  if(profit>NormPoints(SLProfit))
  {
   if(TrailStop>0) TrailingStop(TrailStop);
  }
 } 
 return;
}
//+------------------------------------------------------------------+

void FixedStopsB(int PP,int PFS)
{
  if(PFS<0) return;

  double stopcrnt,stopcal;
  double profit,profitpoint;

  stopcrnt=OrderStopLoss();
  profitpoint=NormPoints(PP);  

//Long               

  if(OrderType()==OP_BUY)
  {
   profit=Bid-OrderOpenPrice();
   
   if(profit>=profitpoint)
   {
    stopcal=NormDigits(OrderOpenPrice()+NormPoints(PFS));
    ModifyCompLong(stopcal,stopcrnt);   
   }
  }    
//Short 
  if(OrderType()==OP_SELL)
  {  
   profit=OrderOpenPrice()-Ask;
   
   if(profit>=profitpoint)
   {
    stopcal=NormDigits(OrderOpenPrice()-NormPoints(PFS));
    ModifyCompShort(stopcal,stopcrnt);
   }
  }  
 return(0);
} 
//+------------------------------------------------------------------+

void ModifyCompLong(double stopcal, double stopcrnt)
{
 stopcal=NormDigits(stopcal);
 stopcrnt=NormDigits(stopcrnt);

 if (stopcal==stopcrnt) return;
 
 if(stopcal>stopcrnt)
 {                     
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
  ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red);     
 }
 else if(stopcal<stopcrnt&&stopcal!=0)
 {
  ModifyOrder(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red); 
 }
 return;
}
//+------------------------------------------------------------------+
double StopLong(double price,int stop) // function to calculate normal stoploss if long
{
 if(stop<=0) return(0.0);
 return(NormDigits(price-NormPoints(stop))); 
}
//+------------------------------------------------------------------+
double StopShort(double price,int stop) // function to calculate normal stoploss if short
{
 if(stop<=0) return(0.0);
 return(NormDigits(price+NormPoints(stop))); 
}
//+------------------------------------------------------------------+
double TakeLong(double price,int take)  // function to calculate takeprofit if long
{
 return(NormDigits(price+NormPoints(take)));
}
//+------------------------------------------------------------------+
double TakeShort(double price,int take)  // function to calculate takeprofit if short
{
 return(NormDigits(price-NormPoints(take)));
}
//+------------------------------------------------------------------+
double UniversalTPMin(double price, double tp, bool long)
{
 if(long)
 {
  if(NormDigits(tp-price)<TPMinPoints) 
   return(NormDigits(price+TPMinPoints));
  else 
   return(tp);
 }
 else
 {
  if(NormDigits(price-tp)<TPMinPoints) 
   return(NormDigits(price-TPMinPoints));
  else
   return(tp);
 }

 return(tp);
}
//+------------------------------------------------------------------+
void TrailingStop(int TS)
{
 if(TS<=0) return;
 
 double stopcrnt,stopcal; 
 double profit;
 
 stopcrnt=NormDigits(OrderStopLoss());
             
 if(OrderType()==OP_BUY)
 {
  stopcal=TrailLong(Bid,TS);
  if (stopcal==stopcrnt) return;
  ModifyCompLong(stopcal,stopcrnt);  
 }    

 if(OrderType()==OP_SELL)
 {  
  stopcal=TrailShort(Ask,TS);
  if (stopcal==stopcrnt) return;  
  ModifyCompShort(stopcal,stopcrnt); 
 } 
 
 return(0);
}
//+------------------------------------------------------------------+
double TrailLong(double price,int trail)
{
 return(NormDigits(price-NormPoints(trail))); 
}
//+------------------------------------------------------------------+
double TrailShort(double price,int trail)
{
 return(NormDigits(price+NormPoints(trail))); 
}
//+------------------------------------------------------------------+
void FractalTrail()
{
 int checktime=iBarShift(NULL,TimeFrame,OrderOpenTime(),false);
 if(checktime<1) return;
 if(checktime<FrTrailStopLimit) return; 

 double close=iClose(NULL,TimeFrame,1); 
 int i,N;double fup,fdn,FUpSL,FDnSL;

//Long               

 if(OrderType()==OP_BUY)
 {
  N=0;FDnSL=9999;
  for(i=checktime;i<=1000;i++)
  { 
   if(i<3) continue; // only confirmed fractals 
   fdn=iFractals(NULL,TimeFrame,MODE_LOWER,i);
   if(fdn!=0) 
   {
    if(fdn<FDnSL) FDnSL=fdn;    
    N++;
    if(N==FractalSL) break;   
   }    
  } 

  if(close<FDnSL)
  {
   ExitOrder(true,false);
  }
 }    
//Short 
 else if(OrderType()==OP_SELL)
 {   
  N=0;FUpSL=0;
  for(i=checktime;i<=1000;i++)
  { 
   if(i<3) continue; // only confirmed fractals
   fup=iFractals(NULL,TimeFrame,MODE_UPPER,i);
   if(fup!=0) 
   {
    if(fup>FUpSL) FUpSL=fup;
    N++;
    if(N==FractalSL) break;
   } 
  } 
 
  if(close>FUpSL)
  {
   ExitOrder(false,true);
  }
 } 
 return;
}
//+------------------------------------------------------------------+

bool ModifyOrder(int ticket, double price, double sl, double tp, datetime exp, color cl=CLR_NONE)
{ 
 bool attempt=true;
 while(attempt)
 {
  if(IsTradeAllowed())
  {
   if(OrderModify(ticket,price,sl,tp,exp,cl)==false)
   {  
    Print("OrderModify failed, Error: ",GetLastError(), " Ticket Number: ", ticket);
    Print("Old price: ", OrderOpenPrice(), " Old S/L ", OrderStopLoss(), " Old T/P ", OrderTakeProfit(), " Ask/Bid ",Ask,", ",Bid);
    Print(" New Price: ", price, " New S/L ", sl, " New T/P ", tp, " New Expiration ", exp);
   }
   attempt=false;
  }
 }
 return(true);
}
//+------------------------------------------------------------------+
double NormDigits(double price)
{
 return(NormalizeDouble(price,Digits));
}
//+------------------------------------------------------------------+
double NormPoints(int pips)
{
 return(NormalizeDouble(pips*Point,Digits));
}
//+------------------------------------------------------------------+
double NormLots(double lots)
{
 double l1=MathMax(NormalizeDouble(lotsmin,lotsprecision),NormalizeDouble(lots,lotsprecision));
 double l2=MathMin(NormalizeDouble(lotsmax,lotsprecision),NormalizeDouble(l1  ,lotsprecision));
 return(l2);
}
//+------------------------------------------------------------------+
double DetermineProfit()
{
 if(OrderType()==OP_BUY)  
 {
  return(Bid-OrderOpenPrice());
 } 
 else if(OrderType()==OP_SELL)
 { 
  return(OrderOpenPrice()-Ask); 
 }
 return(0);
}
//+------------------------------------------------------------------+
void ExitOrder(bool flag_Long,bool flag_Short)
{
 if(OrderType()==OP_BUY&&flag_Long)
  CloseOrderLong(OrderTicket(),OrderLots(),Slippage,Lime);
 else if(OrderType()==OP_SELL&&flag_Short)
  CloseOrderShort(OrderTicket(),OrderLots(),Slippage,Lime);
 return;
}
//+------------------------------------------------------------------+
void ExitAggregate(int flag)
{
 int type;
 datetime opentime;
 switch(flag)
 {
  case 1:
   type=OP_BUY;
  break;
  case 2:
   type=OP_SELL;
  break;
 }
 
 int mn,time,trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderType()!=type) continue;
  opentime=OrderOpenTime();
  if(opentime>=ShortArrowTime&&opentime>=LongArrowTime) continue; // only for previous-set orders

  mn=OrderMagicNumber();
  
       if(mn==magic[0,0]) ExitOrder(true,true);
  else if(mn==magic[0,1]) ExitOrder(true,true);
  else if(mn==magic[0,2]) ExitOrder(true,true);  
  else if(mn==magic[0,3]) ExitOrder(true,true);
  else if(mn==magic[0,4]) ExitOrder(true,true);
  else if(mn==magic[0,5]) ExitOrder(true,true);
  else if(mn==magic[1,0]) ExitOrder(true,true);
  else if(mn==magic[1,1]) ExitOrder(true,true);
  else if(mn==magic[1,2]) ExitOrder(true,true);  
  else if(mn==magic[1,3]) ExitOrder(true,true);
  else if(mn==magic[1,4]) ExitOrder(true,true);
  else if(mn==magic[1,5]) ExitOrder(true,true);
 }
 
 return;
}
//+------------------------------------------------------------------+
void Status(int mn)
{
 int i,j;
 for(i=0;i<2;i++)
 {
  for(j=0;j<6;j++)
  {   
   if(mn==magic[i,j]) 
   {
    if(OrderType()==OP_BUY)  otL[i,j]=OrderOpenTime();
    if(OrderType()==OP_SELL) otS[i,j]=OrderOpenTime();
   }
  }
 }
 return;
}
//+------------------------------------------------------------------+
void DrawCross(double price, int time1, string str, color clr, int code)
{
 string name=StringConcatenate(str,time1);
 ObjectDelete(name);  
 ObjectCreate(name,OBJ_ARROW,0,time1,price);
 ObjectSet(name,OBJPROP_COLOR,clr);
 ObjectSet(name,OBJPROP_ARROWCODE,code); 
 ObjectSet(name,OBJPROP_WIDTH,1);
 return;
}
//+------------------------------------------------------------------+
void VTComplexFractal()
{
 NArrow=0;
 int i,j,k;
 double Aup,Adn;
 for(i=1;i<=1000;i++)
 {
  Aup=iCustom(NULL,TimeFrame,ciComplexFractal,MAperiod1,MAperiod2,MAshift1,MAshift2,MAmethod1,MAmethod2,MAprice1,MAprice2,MACDfast,MACDslow,MACDsignal,MACDprice,RSIperiod,RSIprice,0,i);
  Adn=iCustom(NULL,TimeFrame,ciComplexFractal,MAperiod1,MAperiod2,MAshift1,MAshift2,MAmethod1,MAmethod2,MAprice1,MAprice2,MACDfast,MACDslow,MACDsignal,MACDprice,RSIperiod,RSIprice,1,i);
  if(Aup!=EMPTY_VALUE)
  {
   if(ShortArrow) 
   {
    First=false;
    FirstEntryTime=0;   
    for(j=0;j<2;j++)
    {
     for(k=0;k<6;k++)
     {
      NOrdersPerArrow[j,k]=0; // reset arrow only on flip
     }
    }
   }
   LongArrow=true;
   ShortArrow=false;
   LongArrowTime=iTime(NULL,TimeFrame,i);  
   NArrow=i;
   break;
  }
  else if(Adn!=EMPTY_VALUE)
  {
   if(LongArrow) 
   {
    First=false;
    FirstEntryTime=0;    
    for(j=0;j<2;j++)
    {
     for(k=0;k<6;k++)
     {
      NOrdersPerArrow[j,k]=0; // reset arrow only on flip
     }
    } 
   }   
   LongArrow=false;
   ShortArrow=true;
   ShortArrowTime=iTime(NULL,TimeFrame,i);     
   NArrow=i;
   break;
  }
 }
 
 int index;
 if(ConfirmFractal) index=3;
 else index=1;
 
 FUp=iCustom(NULL,TimeFrame,ciComplexFractal,MAperiod1,MAperiod2,MAshift1,MAshift2,MAmethod1,MAmethod2,MAprice1,MAprice2,MACDfast,MACDslow,MACDsignal,MACDprice,RSIperiod,RSIprice,4,index);
 FDn=iCustom(NULL,TimeFrame,ciComplexFractal,MAperiod1,MAperiod2,MAshift1,MAshift2,MAmethod1,MAmethod2,MAprice1,MAprice2,MACDfast,MACDslow,MACDsignal,MACDprice,RSIperiod,RSIprice,5,index);
 FDiff=NormDigits(FUp-FDn);
 
 double fup,fdn,fup2,fdn2,fdiff,high,low,target;
 int NBreakOutUp=0,NBreakOutDn=0;
 
 fup=iCustom(NULL,TimeFrame,ciComplexFractal,MAperiod1,MAperiod2,MAshift1,MAshift2,MAmethod1,MAmethod2,MAprice1,MAprice2,MACDfast,MACDslow,MACDsignal,MACDprice,RSIperiod,RSIprice,4,NArrow+1); //+1 previous fractal set
 fdn=iCustom(NULL,TimeFrame,ciComplexFractal,MAperiod1,MAperiod2,MAshift1,MAshift2,MAmethod1,MAmethod2,MAprice1,MAprice2,MACDfast,MACDslow,MACDsignal,MACDprice,RSIperiod,RSIprice,5,NArrow+1); //+1 previous fractal set
 fdiff=NormDigits(fup-fdn);  

      if(LongArrow)  target=NormDigits(fup+PercentTrigger*fdiff);
 else if(ShortArrow) target=NormDigits(fdn-PercentTrigger*fdiff); 

 if(fdiff>0)
 {
  for(i=NArrow;i>=1;i--)
  {
   high=iHigh(NULL,TimeFrame,i);
   low =iLow(NULL,TimeFrame,i);
   
   if(LongArrow)
   {
    if(high>=target) 
    {
     NBreakOutUp=i;
     break;
    }
   }
   else if(ShortArrow)
   {  
    if(low<=target)  
    { 
     NBreakOutDn=i;
     break;
    }
   }
  }
 }
 
 int NFChangeUp=1,NFChangeDn=1;

 for(i=NArrow;i>=1;i--)
 {
  if(LongArrow)
  {
   fup =iCustom(NULL,TimeFrame,ciComplexFractal,MAperiod1,MAperiod2,MAshift1,MAshift2,MAmethod1,MAmethod2,MAprice1,MAprice2,MACDfast,MACDslow,MACDsignal,MACDprice,RSIperiod,RSIprice,4,i);
   fup2=iCustom(NULL,TimeFrame,ciComplexFractal,MAperiod1,MAperiod2,MAshift1,MAshift2,MAmethod1,MAmethod2,MAprice1,MAprice2,MACDfast,MACDslow,MACDsignal,MACDprice,RSIperiod,RSIprice,4,i+1);
   if(fup!=fup2) 
   {
    NFChangeUp=i;
    break;
   }
  }
  else if(ShortArrow)
  {
   fdn =iCustom(NULL,TimeFrame,ciComplexFractal,MAperiod1,MAperiod2,MAshift1,MAshift2,MAmethod1,MAmethod2,MAprice1,MAprice2,MACDfast,MACDslow,MACDsignal,MACDprice,RSIperiod,RSIprice,5,i);  
   fdn2=iCustom(NULL,TimeFrame,ciComplexFractal,MAperiod1,MAperiod2,MAshift1,MAshift2,MAmethod1,MAmethod2,MAprice1,MAprice2,MACDfast,MACDslow,MACDsignal,MACDprice,RSIperiod,RSIprice,5,i+1);
   if(fdn!=fdn2) 
   {
    NFChangeDn=i;
    break;
   }   
  } 
 }
 
 BreakUp=false;BreakDn=false;

 if(LongArrow)
 {
  if(NBreakOutUp>=NFChangeUp) BreakUp=true;
 }
 else if(ShortArrow)
 {
  if(NBreakOutDn>=NFChangeDn) BreakDn=true;
 }
  
 return;
}
//+------------------------------------------------------------------+
bool BlackOuts()
{
 if(BlackoutStart>=0&&BlackoutEnd>=0)
 {
  if(BlackoutEnd>BlackoutStart)
  {
   if(Hour()>=BlackoutStart&&Hour()<=BlackoutEnd) return(true);
  }
  else
  {
   if(Hour()>=BlackoutStart||Hour()<=BlackoutEnd) return(true);
  }
 }
 
 if(StartFriA>0&&EndFriA>0)
 {
  if(DayOfWeek()==5)
  {
   if(Day()>=StartFriA && Day()<=EndFriA) return(true);
  }
 }

 if(StartFriB>0&&EndFriB>0)
 {
  if(DayOfWeek()==5)
  {
   if(Day()>=StartFriB && Day()<=EndFriB) return(true);
  }
 } 
 
 if(LastDay>0)
 {
  if(Day()>=LastDay) return(true);
 } 
 
 return(false);
}
//+------------------------------------------------------------------+
double CalcLottage()
{
 if(!ProportionateLots) return(Lots);
 if(AccountEquity()<MinimumEquity) return(0.00);
 return(AccountEquity()/10000.00*Lots);
}
//+------------------------------------------------------------------+
void SendMessage(string message)
{
 if (AlertAlarm) Alert(message);
 if (AlertEmail) SendMail("Complex Fractal Trader Alert!",message);
 return;
}
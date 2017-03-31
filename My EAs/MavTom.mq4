//+----------------------------------------------------------------------+
//|                                                        MavTom EA.mq4 |
//|                                                         David J. Lin |
//|Based on trading strategy by Mark Grzesczuk & Tom Tonelli             |
//|                                                                      |
//|Coded by David J. Lin (dave.j.lin@sbcglobal.net)                      |
//|Evanston, IL, October 1, 2009                                         |
//|update 10/06/09: eight exit conditions, Snake parameter tolerances    |
//|update 10/13/09: RSI entry filter, global profit goal, alert on/off   |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2009, Mark Grzesczuk & Tom Tonelli"
#property link      "http://formula4xm.com"

// Timeframe settings:
extern string TimeFrame_fast="M15";  // fast period string 
extern string TimeFrame_slow="H1";  // slow period string 
// Order Management settings:
extern double Lots=0.01;             // lot size per order 
extern int StopLossOrder=250;        // pips catastrophic stop loss (tacked on actual order)
extern int StopLoss=210;              // pips stop loss stealth (use 0 to deactivate)
extern int TakeProfit=750;            // pips take profit stealth (use 0 to deactivate)
extern int TrailBegin=400;             // pips profit to begin trail (use 0 to deactivate)
extern int Trail=100;                  // pips trail stealth (begins after TrailBegin pips attained)
extern int PipProfitTarget=100;      // pips total profit of all orders in the entire account after which to deactivate all EA activity across the entire platform
// Snake Indicator parameters:
extern int  cPeriod=24;              // cperiod for Snake indicator
extern double Snake_fast_UP= 0.0001; // Snake tolerance level for positive (UP) signals, fast time period 
extern double Snake_fast_DN=-0.0001; // Snake tolerance level for negative (DOWN) signals, fast time period 
extern double Snake_slow_UP= 0.0001; // Snake tolerance level for positive (UP) signals, slow time period 
extern double Snake_slow_DN=-0.0001; // Snake tolerance level for negative (DOWN) signals, slow time period 
// Heiken_Ashi_Smoothed Indicator parameters:
extern int MaMetod  = 2;             // Heiken_Ashi_Smoothed parameter 1
extern int MaPeriod = 6;             // Heiken_Ashi_Smoothed parameter 2
extern int MaMetod2  = 3;            // Heiken_Ashi_Smoothed parameter 3
extern int MaPeriod2 = 2;            // Heiken_Ashi_Smoothed parameter 4
// Slope Direction Line Indicator parameters:
extern int Slope_fast_period=7;     // Slope fast period  
extern int Slope_fast_method=3;      // Slope fast method  
extern int Slope_fast_price=0;       // Slope fast price
extern int Slope_slow_period=7;     // Slope slow period 
extern int Slope_slow_method=2;      // Slope slow method  
extern int Slope_slow_price=0;       // Slope slow price   
// Entry Signal Toggles:
// Fast timeframe:
extern bool Fast_Signals=true;          // true = activate fast period signals, false = deactivate all fast period signals
extern bool Fast_Snake=true;            // true = use fast period Snake criteria, false = don't use fast period Snake criteria
extern bool Fast_HA=true;               // true = use fast period HA criteria, false = don't use fast period HA criteria
extern bool Fast_HAS=true;              // true = use fast period HAS criteria, false = don't use fast period HAS criteria
extern bool Fast_Slope_Fast=true;       // true = use fast period Slope-fast criteria, false = don't use fast period Slope-fast criteria
extern bool Fast_Slope_Slow=true;       // true = use fast period Slope-slow criteria, false = don't use fast period Slope-slow criteria
extern bool Fast_Slope_Relation=true;   // true = use fast period Slope-fast-vs-slow relationship criteria, false = don't use fast period Slope-fast-vs-slow relationship criteria
extern bool Fast_Slope_Fast_Price=true; // true = use fast period Slope-fast-vs-Price criteria, false = don't use fast period Slope-fast-vs-Price criteria
extern bool Fast_Slope_Slow_Price=true; // true = use fast period Slope-slow-vs-Price criteria, false = don't use fast period Slope-slow-vs-Price criteria
// Slow timeframe:
extern bool Slow_Signals=true;          // true = activate slow period signals, false = deactivate all slow period signals
extern bool Slow_Snake=true;            // true = use slow period Snake criteria, false = don't use slow period Snake criteria
extern bool Slow_HA=true;               // true = use slow period HA criteria, false = don't use slow period HA criteria
extern bool Slow_HAS=true;              // true = use slow period HAS criteria, false = don't use slow period HAS criteria
extern bool Slow_Slope_Fast=true;       // true = use slow period Slope-fast criteria, false = don't use slow period Slope-fast criteria
extern bool Slow_Slope_Slow=true;       // true = use slow period Slope-slow criteria, false = don't use slow period Slope-slow criteria
extern bool Slow_Slope_Relation=true;   // true = use slow period Slope-fast-vs-slow relationship criteria, false = don't use slow period Slope-fast-vs-slow relationship criteria
extern bool Slow_Slope_Fast_Price=true; // true = use slow period Slope-fast-vs-Price criteria, false = don't use slow period Slope-fast-vs-Price criteria
extern bool Slow_Slope_Slow_Price=true; // true = use slow period Slope-slow-vs-Price criteria, false = don't use slow period Slope-slow-vs-Price criteria
// Entrance RSI filter
extern bool   Fast_RSI=true;            // true = use RSI filter on fast period, false = don't use RSI filter on fast period 
extern int    Fast_RSI_Period=4;       // fast period RSI period 
extern double Fast_RSI_Long=70;         // fast period critical RSI value for longs 
extern double Fast_RSI_Short=30;        // fast period critical RSI value for shorts 
extern bool   Slow_RSI=false;            // true = use RSI filter on slow period, false = don't use RSI filter on slow period 
extern int    Slow_RSI_Period=14;       // slow period RSI period 
extern double Slow_RSI_Long=70;         // slow period critical RSI value for longs 
extern double Slow_RSI_Short=30;        // slow period critical RSI value for shorts 
// Exit Signal Toggles:
// Fast timeframe:
extern bool Exit_Fast_Signals=false;          // true = use exit critera on fast period 
extern bool Exit_Fast_Snake=true;            // true = use fast period Snake exit criteria, false = don't use fast period Snake exit criteria
extern bool Exit_Fast_HA=true;               // true = use fast period HA exit criteria, false = don't use fast period HA exit criteria
extern bool Exit_Fast_HAS=true;              // true = use fast period HAS exit criteria, false = don't use fast period HAS exit criteria
extern bool Exit_Fast_Slope_Fast=true;       // true = use fast period Slope-fast exit criteria, false = don't use fast period Slope-fast exit criteria
extern bool Exit_Fast_Slope_Slow=true;       // true = use fast period Slope-slow exit criteria, false = don't use fast period Slope-slow exit criteria
extern bool Exit_Fast_Slope_Relation=true;   // true = use fast period Slope-fast-vs-slow relationship exit criteria, false = don't use fast period Slope-fast-vs-slow relationship exit criteria
extern bool Exit_Fast_Slope_Fast_Price=true; // true = use fast period Slope-fast-vs-Price exit criteria, false = don't use fast period Slope-fast-vs-Price exit criteria
extern bool Exit_Fast_Slope_Slow_Price=true; // true = use fast period Slope-slow-vs-Price exit criteria, false = don't use fast period Slope-slow-vs-Price exit criteria
// Slow timeframe:
extern bool Exit_Slow_Signals=false;          // true = use exit critera on slow period 
extern bool Exit_Slow_Snake=true;            // true = use slow period Snake exit criteria, false = don't use slow period Snake exit criteria
extern bool Exit_Slow_HA=true;               // true = use slow period HA exit criteria, false = don't use slow period HA exit criteria
extern bool Exit_Slow_HAS=true;              // true = use slow period HAS exit criteria, false = don't use slow period HAS exit criteria
extern bool Exit_Slow_Slope_Fast=true;       // true = use slow period Slope-fast exit criteria, false = don't use slow period Slope-fast exit criteria
extern bool Exit_Slow_Slope_Slow=true;       // true = use slow period Slope-slow exit criteria, false = don't use slow period Slope-slow exit criteria
extern bool Exit_Slow_Slope_Relation=true;   // true = use slow period Slope-fast-vs-slow relationship exit criteria, false = don't use slow period Slope-fast-vs-slow relationship exit criteria
extern bool Exit_Slow_Slope_Fast_Price=true; // true = use slow period Slope-fast-vs-Price exit criteria, false = don't use slow period Slope-fast-vs-Price exit criteria
extern bool Exit_Slow_Slope_Slow_Price=true; // true = use slow period Slope-slow-vs-Price exit criteria, false = don't use slow period Slope-slow-vs-Price exit criteria
// exit parameters
extern int TimeDelay=1;                      // minutes time delay before a new order can be taken after an exit-criteria-based exit (includes stealth stop-loss, take-profit, trail exits, but not catastrophic-stop-loss exits)
// color parameters
extern color TitleColor=Blue;        // color of text titles
extern color UpColor=Lime;           // color of Up/positive text
extern color DnColor=Red;            // color of Dn/negative/zero text
// alert parameter
extern bool ActivateAlert=true;      // true = activate entry/exit alerts, false = deactivate entry/exit alerts

double lotsmin,lotsmax;
int lotsprecision;
int slippage=3,Number_of_Tries=5;
int magicN;
int tffast,tfslow;
int top=100;
double snakeF0,snakeF1,snakeS0,snakeS1;
double HAF0,HAF1,HAS0,HAS1;
double HASF0,HASF1,HASS0,HASS1;
double SFF0,SFF1,SFS0,SFS1;
double SSF0,SSF1,SSS0,SSS1;
string comment;
bool trading,stopEA;
bool HAfast,HAslow;
bool HASfast,HASslow;
int SFfast,SFslow;
int SSfast,SSslow;
int SRfast,SRslow;
bool SFPfast,SFPslow;
bool SSPfast,SSPslow;
datetime lasttime,exittime,starttime,lastD1;
int Nfast,Nslow,Nexitfast,Nexitslow;
double StopLossOrder_p,StopLoss_p,TakeProfit_p,TrailBegin_p,Trail_p;
double lasttrail,lasttrailprice;
int RSI_Price=PRICE_CLOSE; // RSI applied price setting 
bool RSI_Fast_Long,RSI_Fast_Short,RSI_Slow_Long,RSI_Slow_Short;
double ProfitTarget;
string ciSnake="5EMAsAdvanced";
string ciHA="Heiken Ashi";
string ciHAS="Heiken_Ashi_Smoothed";
string ciSlope="Slope Direction Line";
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//---- 
 lotsmin=MarketInfo(Symbol(),MODE_MINLOT); 
 lotsmax=MarketInfo(Symbol(),MODE_MAXLOT); 
 
 comment=StringConcatenate("MavTom ",DoubleToStr(Period(),0)," ",Symbol());
 
 if(TimeFrame_fast=="M1") tffast=PERIOD_M1;
 else if(TimeFrame_fast=="M5") tffast=PERIOD_M5;
 else if(TimeFrame_fast=="M15") tffast=PERIOD_M15;
 else if(TimeFrame_fast=="M30") tffast=PERIOD_M30;  
 else if(TimeFrame_fast=="H1") tffast=PERIOD_H1; 
 else if(TimeFrame_fast=="H4") tffast=PERIOD_H4;
 else if(TimeFrame_fast=="D1") tffast=PERIOD_D1;
 else if(TimeFrame_fast=="W1") tffast=PERIOD_W1;
 else if(TimeFrame_fast=="MN") tffast=PERIOD_MN1;
 else if(TimeFrame_fast=="m1") tffast=PERIOD_M1;
 else if(TimeFrame_fast=="m5") tffast=PERIOD_M5;
 else if(TimeFrame_fast=="m15") tffast=PERIOD_M15;
 else if(TimeFrame_fast=="m30") tffast=PERIOD_M30;  
 else if(TimeFrame_fast=="h1") tffast=PERIOD_H1; 
 else if(TimeFrame_fast=="h4") tffast=PERIOD_H4;
 else if(TimeFrame_fast=="d1") tffast=PERIOD_D1;
 else if(TimeFrame_fast=="w1") tffast=PERIOD_W1;
 else if(TimeFrame_fast=="mn") tffast=PERIOD_MN1;
 else if(TimeFrame_fast=="1") tffast=PERIOD_M1;
 else if(TimeFrame_fast=="5") tffast=PERIOD_M5;
 else if(TimeFrame_fast=="15") tffast=PERIOD_M15;
 else if(TimeFrame_fast=="30") tffast=PERIOD_M30;  
 else if(TimeFrame_fast=="60") tffast=PERIOD_H1; 
 else if(TimeFrame_fast=="240") tffast=PERIOD_H4; 
 else tffast=0; 
 
 if(TimeFrame_slow=="M1") tfslow=PERIOD_M1;
 else if(TimeFrame_slow=="M5") tfslow=PERIOD_M5;
 else if(TimeFrame_slow=="M15") tfslow=PERIOD_M15;
 else if(TimeFrame_slow=="M30") tfslow=PERIOD_M30;  
 else if(TimeFrame_slow=="H1") tfslow=PERIOD_H1; 
 else if(TimeFrame_slow=="H4") tfslow=PERIOD_H4;
 else if(TimeFrame_slow=="D1") tfslow=PERIOD_D1;
 else if(TimeFrame_slow=="W1") tfslow=PERIOD_W1;
 else if(TimeFrame_slow=="MN") tfslow=PERIOD_MN1;
 else if(TimeFrame_slow=="m1") tfslow=PERIOD_M1;
 else if(TimeFrame_slow=="m5") tfslow=PERIOD_M5;
 else if(TimeFrame_slow=="m15") tfslow=PERIOD_M15;
 else if(TimeFrame_slow=="m30") tfslow=PERIOD_M30;  
 else if(TimeFrame_slow=="h1") tfslow=PERIOD_H1; 
 else if(TimeFrame_slow=="h4") tfslow=PERIOD_H4;
 else if(TimeFrame_slow=="d1") tfslow=PERIOD_D1;
 else if(TimeFrame_slow=="w1") tfslow=PERIOD_W1;
 else if(TimeFrame_slow=="mn") tfslow=PERIOD_MN1;
 else if(TimeFrame_slow=="1") tfslow=PERIOD_M1;
 else if(TimeFrame_slow=="5") tfslow=PERIOD_M5;
 else if(TimeFrame_slow=="15") tfslow=PERIOD_M15;
 else if(TimeFrame_slow=="30") tfslow=PERIOD_M30;  
 else if(TimeFrame_slow=="60") tfslow=PERIOD_H1; 
 else if(TimeFrame_slow=="240") tfslow=PERIOD_H4; 
 else tfslow=0; 

 stopEA=false;
 if(tffast==0) 
 {
  Alert(Symbol()," WARNING: Invalid TimeFrame_fast string! Please enter a valid string.");
  stopEA=true;
 }
 if(tfslow==0) 
 {
  Alert(Symbol()," WARNING: Invalid TimeFrame_slow string! Please enter a valid string.");
  stopEA=true;
 }
 if(tffast==tfslow) 
 {
  Alert(Symbol()," WARNING: the fast and slow timeframes are the same! Please correct.");  
  stopEA=true;
 }
 if(tffast>tfslow) 
 {
  Alert(Symbol()," WARNING: the fast timeframes is greater than the slow timeframe! Please correct.");  
  stopEA=true;
 } 
 
 if(Snake_fast_UP<0)
 {
  Alert(Symbol()," WARNING: the Snake_fast_UP parameter is negative! Please correct.");  
  stopEA=true;
 }  
 if(Snake_fast_DN>0)
 {
  Alert(Symbol()," WARNING: the Snake_fast_DN parameter is positive! Please correct.");  
  stopEA=true;
 }  
 if(Snake_slow_UP<0)
 {
  Alert(Symbol()," WARNING: the Snake_slow_UP parameter is negative! Please correct.");  
  stopEA=true;
 }  
 if(Snake_slow_DN>0)
 {
  Alert(Symbol()," WARNING: the Snake_slow_DN parameter is positive! Please correct.");  
  stopEA=true;
 }  
 
 magicN = 100+tffast+tfslow; 
 lastD1=iTime(NULL,PERIOD_D1,0);
 exittime=0;

 
 if(lotsmin==1)         lotsprecision=0;
 else if(lotsmin==0.50) lotsprecision=1; // for PFG ECN
 else if(lotsmin==0.10) lotsprecision=1;
 else if(lotsmin==0.01) lotsprecision=2;
 else                   lotsprecision=1;

 if(StringFind(Symbol(),"JPY")>0) 
 {
  if(Digits==3)
  {
   StopLossOrder_p=NormPoints(StopLossOrder*10);
   StopLoss_p=NormPoints(StopLoss*10);
   TakeProfit_p=NormPoints(TakeProfit*10);
   TrailBegin_p=NormPoints(TrailBegin*10);
   Trail_p=NormPoints(Trail*10);  
   ProfitTarget=PipProfitTarget*10; // pips
  }
  else
  {
   StopLossOrder_p=NormPoints(StopLossOrder);
   StopLoss_p=NormPoints(StopLoss);
   TakeProfit_p=NormPoints(TakeProfit);
   TrailBegin_p=NormPoints(TrailBegin);
   Trail_p=NormPoints(Trail);  
   ProfitTarget=PipProfitTarget; // pips
  }  
 }
 else
 {
  if(Digits==5)
  {
   StopLossOrder_p=NormPoints(StopLossOrder*10);
   StopLoss_p=NormPoints(StopLoss*10);
   TakeProfit_p=NormPoints(TakeProfit*10);
   TrailBegin_p=NormPoints(TrailBegin*10);
   Trail_p=NormPoints(Trail*10);    
   ProfitTarget=PipProfitTarget*10; // pips   
  }
  else
  {
   StopLossOrder_p=NormPoints(StopLossOrder);
   StopLoss_p=NormPoints(StopLoss);
   TakeProfit_p=NormPoints(TakeProfit);
   TrailBegin_p=NormPoints(TrailBegin);
   Trail_p=NormPoints(Trail);   
   ProfitTarget=PipProfitTarget; // pips   
  }  
 }

// Now check open orders
 trading=false;    
 Status();

 MakeLabel( "tffastt", 220, top-100 );   // TimeFrame label "Fast"
 MakeLabel( "tffastv", 250, top-100 );   // TimeFrame fast 
 MakeLabel( "snake1fv",280, top-100 );   // Snake 1
 MakeLabel( "snake2fv",330, top-100 );   // Snake 2
 MakeLabel( "HAfv",    220, top-85  );   // HA
 MakeLabel( "HASfv",   245, top-85  );   // HAS
 MakeLabel( "SlopeFfv",270, top-85  );   // Slope fast
 MakeLabel( "SlopeSfv",295, top-85  );   // Slope slow
 MakeLabel( "SlopeRfv",320, top-85  );   // Slope fast/slow relationship
 MakeLabel( "SlopeFPfv",345, top-85  );  // Slope fast Price 
 MakeLabel( "SlopeSPfv",370, top-85  );  // Slope slow Price 
  
 MakeLabel( "tfslowt", 410, top-100 );   // TimeFrame label "Slow"
 MakeLabel( "tfslowv", 440, top-100 );   // TimeFrame slow
 MakeLabel( "snake1sv",470, top-100 );   // Snake 1
 MakeLabel( "snake2sv",520, top-100 );   // Snake 2
 MakeLabel( "HAsv",    410, top-85  );   // HA
 MakeLabel( "HASsv",   435, top-85  );   // HAS
 MakeLabel( "SlopeFsv",460, top-85  );   // Slope fast
 MakeLabel( "SlopeSsv",485, top-85  );   // Slope slow
 MakeLabel( "SlopeRsv",510, top-85  );   // Slope fast/slow relationship
 MakeLabel( "SlopeFPsv",535, top-85  );  // Slope fast Price 
 MakeLabel( "SlopeSPsv",560, top-85  );  // Slope slow Price

 ObjectSetText( "tffastt",  "Fast:", 10, "Arial", TitleColor );
 ObjectSetText( "tfslowt",  "Slow:", 10, "Arial", TitleColor );

 ObjectSetText( "tffastv", TimeFrame_fast, 10, "Arial", TitleColor );
 ObjectSetText( "tfslowv", TimeFrame_slow, 10, "Arial", TitleColor ); 

 InitializeCriteria();
 UpdateIndicatorStatus();
 
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
 ObjectDelete( "tffastt" );
 ObjectDelete( "tffastv" );
 ObjectDelete( "tfslowt" );
 ObjectDelete( "tfslowv" ); 
 ObjectDelete( "snake1fv" );  
 ObjectDelete( "snake2fv" );   
 ObjectDelete( "snake1sv" );  
 ObjectDelete( "snake2sv" );  
 ObjectDelete( "HAfv" );   
 ObjectDelete( "HAsv" );  
 ObjectDelete( "HASfv" );   
 ObjectDelete( "HASsv" ); 
 ObjectDelete( "SlopeFfv" ); 
 ObjectDelete( "SlopeFsv" );  
 ObjectDelete( "SlopeSfv" ); 
 ObjectDelete( "SlopeSsv" );  
 ObjectDelete( "SlopeRfv" ); 
 ObjectDelete( "SlopeRsv" );  
 ObjectDelete( "SlopeFPfv" ); 
 ObjectDelete( "SlopeFPsv" );  
 ObjectDelete( "SlopeSPfv" ); 
 ObjectDelete( "SlopeSPsv" );  
 ReleaseSemaphore(); // in case someone breaks in middle of order submission 
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
 if(StopCheck()) return(0);
//---- 
 UpdateIndicatorStatus();
 Main();
 ManageOrders(); 

 lasttime=iTime(NULL,0,0);
  
 if(lastD1==iTime(NULL,PERIOD_D1,0)) return(0);
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert utility functions                                         |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void Main()
{ 
 if(trading) return;
 
 double SL;

 if(EntryCriteria(true))
 {
  if(filter(true))
  {
   SL = NormDigits(Ask-StopLossOrder_p);   
   SendOrderLong(Symbol(),Lots,slippage,0,0,comment,magicN); 
   AddSLTP(SL,0);
   lasttrail=0;
   lasttrailprice=0;
   trading=true;
   AlertEntry(true);
  }
 }

 if(EntryCriteria(false))
 { 
  if(filter(false))
  {
   SL = NormDigits(Bid+StopLossOrder_p);
   SendOrderShort(Symbol(),Lots,slippage,0,0,comment,magicN); 
   AddSLTP(SL,0);   
   lasttrail=9999999999;
   lasttrailprice=9999999999;   
   trading=true;
   AlertEntry(false);
  }
 }
 
 return; 
}
//+------------------------------------------------------------------+
bool filter(bool long)
{
 int Trigger[3], totN=3,i;
  
 for(i=0;i<totN;i++) Trigger[i]=-1;

 if(long) // long filters
 {
  for(i=0;i<totN;i++)
  {
   switch(i)
   {   
    case 0:
     if(TimeEntranceDelay()) Trigger[i]=1;
    break;   
    case 1:
     if(Fast_RSI)
     {
      if(RSI_Fast_Long) Trigger[i]=1;
     }
     else Trigger[i]=1;
    break;
    case 2:
     if(Slow_RSI)
     {
      if(RSI_Slow_Long) Trigger[i]=1;
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
     if(TimeEntranceDelay()) Trigger[i]=1;
    break;   
    case 1:
     if(Fast_RSI)
     {
      if(RSI_Fast_Short) Trigger[i]=1;
     }
     else Trigger[i]=1;     
    break;
    case 2:
     if(Slow_RSI)
     {
      if(RSI_Slow_Short) Trigger[i]=1;
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
void ManageOrders()
{
 int trade,trades=OrdersTotal(),norders=0; 
 double totalprofit;
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  totalprofit+=DetermineProfit();
  
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderMagicNumber()!=magicN) continue; 
  norders++;
  ExitCheck();
  StealthSLTP();
  StealthTrail();
 }

 if(norders==0) trading=false;
 
 if(totalprofit>=ProfitTarget) CloseAll();
 
 return;
}
//+------------------------------------------------------------------+
int MakeLabel( string str, int a, int b ) 
{
 ObjectCreate( str, OBJ_LABEL, 0, 0, 0 );
 ObjectSet( str, OBJPROP_CORNER, 0 );
 ObjectSet( str, OBJPROP_XDISTANCE, a );
 ObjectSet( str, OBJPROP_YDISTANCE, b );
 ObjectSet( str, OBJPROP_BACK, true );
 return(0);
}
//+------------------------------------------------------------------+
void AlertEntry(bool long)
{
 if(!ActivateAlert) return;
 
 string td=TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES);
 if(long) Alert(Symbol()," long entry at ",td);
 else     Alert(Symbol()," short entry at ",td);
 return;
}
//+------------------------------------------------------------------+
void AlertExit(string message, int id=0)
{
 if(!ActivateAlert) return;
 
 Alert(Symbol(),message,id);
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
 for(int z=0;z<Number_of_Tries;z++)
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
 for(int z=0;z<Number_of_Tries;z++)
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
  if(!OrderClose(ticket,NormLots(lots),MarketInfo(OrderSymbol(),MODE_BID),slip,cl))
  {  
   int err = GetLastError();
   Print("OrderClose Long failed, Error: ", err, " Ticket #: ", ticket, " ",OrderSymbol());
   Print("Bid: ", MarketInfo(OrderSymbol(),MODE_BID));   
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
  if(!OrderClose(ticket,NormLots(lots),MarketInfo(OrderSymbol(),MODE_ASK),slip,cl))
  {  
   int err = GetLastError();
   Print("OrderClose Short failed, Error: ", err, " Ticket #: ", ticket, " ",OrderSymbol());
   Print("Ask: ", MarketInfo(OrderSymbol(),MODE_ASK));   
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
void ExitOrder(bool flag_Long,bool flag_Short)
{

 if(OrderType()==OP_BUY&&flag_Long) 
 {
  CloseOrderLong(OrderTicket(),OrderLots(),slippage,Lime);
  GetRSIExit(true);
 }
 else if(OrderType()==OP_SELL&&flag_Short) 
 {
  CloseOrderShort(OrderTicket(),OrderLots(),slippage,Lime);
  GetRSIExit(false);
 }
 
 exittime=TimeCurrent();  
 return;
}
//+------------------------------------------------------------------+
void Status()
{
 int trade,trades=OrdersTotal();           
 for(trade=0;trade<trades;trade++)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderMagicNumber()==magicN)
  {
   trading=true;
   if(OrderType()==OP_BUY)
   {
    lasttrail=0;
    lasttrailprice=0;   
   }
   else if(OrderType()==OP_SELL)
   {
    lasttrail=9999999999;
    lasttrailprice=9999999999;    
   }
   break;
  }
 }
 return;
}
//+------------------------------------------------------------------+ 
void AddSLTP(double sl, double tp)
{
 int trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;

  if(OrderStopLoss()==0)
  {
   if(OrderStopLoss()!=sl || OrderTakeProfit()!=tp)
   {  
    if(OrderMagicNumber()==magicN) ModifyOrder(OrderTicket(),OrderOpenPrice(),sl,tp,0,CLR_NONE);
   }
  }
 } 
 return;
}
//+------------------------------------------------------------------+ 
void ExitCheck()
{
 if(OrderType()==OP_BUY)
 {
  if(ExitCriteria(true))
  {
   ExitOrder(true,false);
   AlertExit(" long exit criteria #",OrderTicket());
  }
 }
 else if(OrderType()==OP_SELL)
 {
  if(ExitCriteria(false))
  {
   ExitOrder(false,true);
   AlertExit(" short exit criteria #",OrderTicket());
  }  
 } 
 return;
}
//+------------------------------------------------------------------+ 
void StealthSLTP()
{
 if(StopLoss>0)
 {
  if(OrderType()==OP_BUY)
  {
   if(Bid<=NormDigits(OrderOpenPrice()-StopLoss_p)) 
   {
    ExitOrder(true,false); 
    AlertExit(" long stealth SL exit #",OrderTicket());    
   }
  }
  else if(OrderType()==OP_SELL)
  {
   if(Ask>=NormDigits(OrderOpenPrice()+StopLoss_p)) 
   { 
    ExitOrder(false,true);   
    AlertExit(" short stealth SL exit #",OrderTicket());       
   }
  }
 }
 
 if(TakeProfit>0)
 {
  if(OrderType()==OP_BUY)
  {
   if(Bid>=NormDigits(OrderOpenPrice()+TakeProfit_p)) 
   {
    ExitOrder(true,false); 
    AlertExit(" long stealth TP exit #",OrderTicket());       
   }
  }
  else if(OrderType()==OP_SELL)
  {
   if(Ask<=NormDigits(OrderOpenPrice()-TakeProfit_p)) 
   {
    ExitOrder(false,true);   
    AlertExit(" short stealth TP exit #",OrderTicket());       
   }
  } 
 } 
 return;
}
//+------------------------------------------------------------------+ 
void StealthTrail()
{
 if(TrailBegin>0)
 {
  if(OrderType()==OP_BUY)
  {
  
   if(Bid>=NormDigits(OrderOpenPrice()+TrailBegin_p)&&Bid>lasttrailprice)
   {
    lasttrailprice=Bid;
    lasttrail=NormDigits(lasttrailprice-Trail_p);
   }
   
   if(Bid<=lasttrail) 
   {
    ExitOrder(true,false);
    AlertExit(" long stealth trail exit #",OrderTicket());        
   }
   
  }
  else if(OrderType()==OP_SELL)
  {

   if(Ask<=NormDigits(OrderOpenPrice()-TrailBegin_p)&&Ask<lasttrailprice)
   {
    lasttrailprice=Ask;
    lasttrail=NormDigits(lasttrailprice+Trail_p);
   }
   
   if(Ask>=lasttrail) 
   {
    ExitOrder(false,true);
    AlertExit(" short stealth trail exit #",OrderTicket());       
   }   
  
  }
 }
 return;
}
//+------------------------------------------------------------------+ 
bool StopCheck()
{
 if(stopEA)
 {
  Alert("The EA is disabled due to input errors.  Please re-apply.");
  return(true);
 }
 
 if(CheckShutDown()) return(true);
 
 else return(false);
} 
//+------------------------------------------------------------------+ 
void UpdateIndicatorStatus()
{
 GetSnake();
 GetHA(); 
 GetHAS(); 
 GetSlope();
 GetRSI();
 return;
}
//+------------------------------------------------------------------+ 
void GetSnake()
{
 snakeF0=iCustom(NULL,tffast,ciSnake,cPeriod,0,0);
 snakeF1=iCustom(NULL,tffast,ciSnake,cPeriod,1,0); 
 snakeS0=iCustom(NULL,tfslow,ciSnake,cPeriod,0,0);
 snakeS1=iCustom(NULL,tfslow,ciSnake,cPeriod,1,0);

 color clr;

 if(snakeF0<=0) clr=DnColor;
 else           clr=UpColor;
 ObjectSetText( "snake1fv", DoubleToStr(snakeF0,4), 11, "Arial", clr );

 if(snakeF1<=0) clr=DnColor;
 else           clr=UpColor; 
 ObjectSetText( "snake2fv", DoubleToStr(snakeF1,4), 11, "Arial", clr );

 if(snakeS0<=0) clr=DnColor;
 else           clr=UpColor;
 ObjectSetText( "snake1sv", DoubleToStr(snakeS0,4), 11, "Arial", clr );

 if(snakeS1<=0) clr=DnColor;
 else           clr=UpColor;
 ObjectSetText( "snake2sv", DoubleToStr(snakeS1,4), 11, "Arial", clr );
 
 return;
}
//+------------------------------------------------------------------+ 
void GetHA()
{
 HAF0=iCustom(NULL,tffast,ciHA,0,0);
 HAF1=iCustom(NULL,tffast,ciHA,1,0); 
 HAS0=iCustom(NULL,tfslow,ciHA,0,0);
 HAS1=iCustom(NULL,tfslow,ciHA,1,0);

 if(HAF0>HAF1) 
 {
  HAfast=false;
  ObjectSetText( "HAfv", "HA", 11, "Arial", DnColor );  
 }
 else
 {
  HAfast=true;
  ObjectSetText( "HAfv", "HA", 11, "Arial", UpColor );  
 } 
 
 if(HAS0>HAS1) 
 { 
  HAslow=false;   
  ObjectSetText( "HAsv", "HA", 11, "Arial", DnColor );  
 }
 else
 {
  HAslow=true;
  ObjectSetText( "HAsv", "HA", 11, "Arial", UpColor );  
 } 

 return;
}
//+------------------------------------------------------------------+ 
void GetHAS()
{
 HASF0=iCustom(NULL,tffast,ciHAS,MaMetod,MaPeriod,MaMetod2,MaPeriod2,0,0);
 HASF1=iCustom(NULL,tffast,ciHAS,MaMetod,MaPeriod,MaMetod2,MaPeriod2,1,0); 
 HASS0=iCustom(NULL,tfslow,ciHAS,MaMetod,MaPeriod,MaMetod2,MaPeriod2,0,0);
 HASS1=iCustom(NULL,tfslow,ciHAS,MaMetod,MaPeriod,MaMetod2,MaPeriod2,1,0);

 if(HASF0>HASF1) 
 {
  HASfast=false;
  ObjectSetText( "HASfv", "HS", 11, "Arial", DnColor );  
 }
 else
 {
  HASfast=true;
  ObjectSetText( "HASfv", "HS", 11, "Arial", UpColor );  
 } 
 
 if(HASS0>HASS1) 
 { 
  HASslow=false;   
  ObjectSetText( "HASsv", "HS", 11, "Arial", DnColor );  
 }
 else
 {
  HASslow=true;
  ObjectSetText( "HASsv", "HS", 11, "Arial", UpColor );  
 } 

 return;
}
//+------------------------------------------------------------------+ 
void GetSlope()
{
// during transitions, both [0] and [1] hold non-empty values, so it's ambiguous which direction it is

 double valueFf,valueFs,valueSf,valueSs; // upper-case = Slope period, lower-case = TimeFrame Period 
                                         // Ff = fast Slope period, fast TimeFrame Period, etc.

// fast timeframe, fast Slope period
 SFF0=iCustom(NULL,tffast,ciSlope,Slope_fast_period,Slope_fast_method,Slope_fast_price,0,0);
 SFF1=iCustom(NULL,tffast,ciSlope,Slope_fast_period,Slope_fast_method,Slope_fast_price,1,0);

 if(SFF0!=EMPTY_VALUE && SFF1!=EMPTY_VALUE) // transition
 {
  SFfast=0;
  valueFf=SFF0;

  ObjectSetText( "SlopeFfv", "SF", 11, "Arial", UpColor );  
 }
 else if(SFF0!=EMPTY_VALUE) 
 {
  SFfast=1;
  valueFf=SFF0;
  
  ObjectSetText( "SlopeFfv", "SF", 11, "Arial", UpColor );  
 }
 else
 {
  SFfast=-1;
  valueFf=SFF1;  
  
  ObjectSetText( "SlopeFfv", "SF", 11, "Arial", DnColor );  
 } 

// slow timeframe, fast Slope period

 SFS0=iCustom(NULL,tfslow,ciSlope,Slope_fast_period,Slope_fast_method,Slope_fast_price,0,0); 
 SFS1=iCustom(NULL,tfslow,ciSlope,Slope_fast_period,Slope_fast_method,Slope_fast_price,1,0);

 if(SFS0!=EMPTY_VALUE && SFS1!=EMPTY_VALUE) // transition 
 { 
  SFslow=0;
  valueFs=SFS0;
  
  ObjectSetText( "SlopeFsv", "SF", 11, "Arial", UpColor );   
 }
 else if(SFS0!=EMPTY_VALUE) 
 { 
  SFslow=1; 
  valueFs=SFS0;  
    
  ObjectSetText( "SlopeFsv", "SF", 11, "Arial", UpColor );  
 }
 else
 {
  SFslow=-1;
  valueFs=SFS1;
  
  ObjectSetText( "SlopeFsv", "SF", 11, "Arial", DnColor );  
 } 

// fast timeframe, slow Slope period 

 SSF0=iCustom(NULL,tffast,ciSlope,Slope_slow_period,Slope_slow_method,Slope_slow_price,0,0);
 SSF1=iCustom(NULL,tffast,ciSlope,Slope_slow_period,Slope_slow_method,Slope_slow_price,1,0);

 if(SSF0!=EMPTY_VALUE && SSF1!=EMPTY_VALUE) // transition
 {
  SSfast=0;
  valueSf=SSF0;  
  
  ObjectSetText( "SlopeSfv", "SS", 11, "Arial", UpColor );  
 }
 else if(SSF0!=EMPTY_VALUE) 
 {
  SSfast=1;
  valueSf=SSF0;  
  
  ObjectSetText( "SlopeSfv", "SS", 11, "Arial", UpColor );  
 }
 else
 {
  SSfast=-1;
  valueSf=SSF1;  
  
  ObjectSetText( "SlopeSfv", "SS", 11, "Arial", DnColor );  
 } 

// slow timeframe, slow Slope period 

 SSS0=iCustom(NULL,tfslow,ciSlope,Slope_slow_period,Slope_slow_method,Slope_slow_price,0,0); 
 SSS1=iCustom(NULL,tfslow,ciSlope,Slope_slow_period,Slope_slow_method,Slope_slow_price,1,0);

 if(SSS0!=EMPTY_VALUE && SSS1!=EMPTY_VALUE) // transition
 { 
  SSslow=0;   
  valueSs=SSS0;  
  
  ObjectSetText( "SlopeSsv", "SS", 11, "Arial", UpColor );  
 } 
 else if(SSS0!=EMPTY_VALUE) 
 { 
  SSslow=1;   
  valueSs=SSS0;
  
  ObjectSetText( "SlopeSsv", "SS", 11, "Arial", UpColor );  
 }
 else
 {
  SSslow=-1;
  valueSs=SSS1;  
  
  ObjectSetText( "SlopeSsv", "SS", 11, "Arial", DnColor );  
 }  

// fast timeframe, fast/slow Slope relationship

  if(valueFf==valueSf) 
  {
   SRfast=0;    
   ObjectSetText( "SlopeRfv", "SR", 11, "Arial", UpColor );   
  }
  else if(valueFf>valueSf) 
  {
   SRfast=1;    
   ObjectSetText( "SlopeRfv", "SR", 11, "Arial", UpColor );
  }
  else 
  {
   SRfast=-1;    
   ObjectSetText( "SlopeRfv", "SR", 11, "Arial", DnColor );
  }  

// slow timeframe, fast/slow Slope relationship

  if(valueFs==valueSs) 
  {
   SRslow=0;    
   ObjectSetText( "SlopeRsv", "SR", 11, "Arial", UpColor );   
  }
  else if(valueFs>valueSs) 
  {
   SRslow=1;    
   ObjectSetText( "SlopeRsv", "SR", 11, "Arial", UpColor );
  }
  else 
  {
   SRslow=-1;    
   ObjectSetText( "SlopeRsv", "SR", 11, "Arial", DnColor );
  } 

// Slope vs. Price:

// fast timeframe, fast Slope vs Price

  if(Bid>=valueFf) 
  {
   SFPfast=true;    
   ObjectSetText( "SlopeFPfv", "PF", 11, "Arial", UpColor );   
  }
  else
  {
   SFPfast=false;    
   ObjectSetText( "SlopeFPfv", "PF", 11, "Arial", DnColor );
  }

// fast timeframe, slow Slope vs Price

  if(Bid>=valueSf) 
  {
   SSPfast=true;    
   ObjectSetText( "SlopeSPfv", "PS", 11, "Arial", UpColor );   
  }
  else
  {
   SSPfast=false;    
   ObjectSetText( "SlopeSPfv", "PS", 11, "Arial", DnColor );
  }

// slow timeframe, fast Slope vs Price

  if(Bid>=valueFs) 
  {
   SFPslow=true;    
   ObjectSetText( "SlopeFPsv", "PF", 11, "Arial", UpColor );   
  }
  else
  {
   SFPslow=false;    
   ObjectSetText( "SlopeFPsv", "PF", 11, "Arial", DnColor );
  }

// slow  timeframe, slow Slope vs Price

  if(Bid>=valueSs) 
  {
   SSPslow=true;    
   ObjectSetText( "SlopeSPsv", "PS", 11, "Arial", UpColor );   
  }
  else
  {
   SSPslow=false;    
   ObjectSetText( "SlopeSPsv", "PS", 11, "Arial", DnColor );
  }
  
 return;
}
//+------------------------------------------------------------------+ 
void GetRSI() // simple reset of toggles ... entrance does not depend on actual value of RSI at entry time 
{
 double rsif=iRSI(NULL,tffast,Fast_RSI_Period,RSI_Price,0);
 double rsis=iRSI(NULL,tfslow,Slow_RSI_Period,RSI_Price,0);
 
 if(rsif<Fast_RSI_Long)  RSI_Fast_Long=true;
 if(rsif>Fast_RSI_Short) RSI_Fast_Short=true; 

 if(rsis<Slow_RSI_Long)  RSI_Slow_Long=true;
 if(rsis>Slow_RSI_Short) RSI_Slow_Short=true; 
 
 return;
}
//+------------------------------------------------------------------+ 
void GetRSIExit(bool long) // only need to check upon order exit, since the RSI entrance filter is meant to prevent multiple order entries 
{
 double rsif=iRSI(NULL,tffast,Fast_RSI_Period,RSI_Price,0);
 double rsis=iRSI(NULL,tfslow,Slow_RSI_Period,RSI_Price,0);
 
 if(long)
 {
  if(rsif>=Fast_RSI_Long)  RSI_Fast_Long=false;
  if(rsis>=Slow_RSI_Long)  RSI_Slow_Long=false;
 }
 else
 {
  if(rsif<=Fast_RSI_Short) RSI_Fast_Short=false; 
  if(rsis<=Slow_RSI_Short) RSI_Slow_Short=false; 
 }

 return;
}
//+------------------------------------------------------------------+ 
void InitializeCriteria()
{
// Entrance criteria:
 Nfast=0;Nslow=0;
 
 if(Fast_Signals)
 {
  if(Fast_Snake) Nfast++;
  if(Fast_HA) Nfast++; 
  if(Fast_HAS) Nfast++; 
  if(Fast_Slope_Fast) Nfast++;
  if(Fast_Slope_Slow) Nfast++;
  if(Fast_Slope_Relation) Nfast++;
  if(Fast_Slope_Fast_Price) Nfast++;
  if(Fast_Slope_Slow_Price) Nfast++;
 }
 else Nfast=-1;

 if(Slow_Signals)
 {
  if(Slow_Snake) Nslow++;
  if(Slow_HA) Nslow++; 
  if(Slow_HAS) Nslow++; 
  if(Slow_Slope_Fast) Nslow++;
  if(Slow_Slope_Slow) Nslow++;
  if(Slow_Slope_Relation) Nslow++;
  if(Slow_Slope_Fast_Price) Nslow++;
  if(Slow_Slope_Slow_Price) Nslow++;
 }
 else Nslow=-1;
 
 if(Fast_Signals&&Nfast==0) 
 {
  Alert("Warning: No fast-timeframe criteria are activated. Please correct.");
  stopEA=true;
 }

 if(Slow_Signals&&Nslow==0) 
 {
  Alert("Warning: No slow-timeframe criteria are activated. Please correct.");
  stopEA=true;
 } 
 
 if(!Fast_Signals && !Slow_Signals) 
 {
  Alert("Warning: Both fast and slow-timeframe criteria are deactivated. Please correct.");
  stopEA=true;  
 }

// Exit criteria
 Nexitfast=0;Nexitslow=0;

 if(Exit_Fast_Signals)
 {
  if(Exit_Fast_Snake) Nexitfast++;
  if(Exit_Fast_HA) Nexitfast++; 
  if(Exit_Fast_HAS) Nexitfast++; 
  if(Exit_Fast_Slope_Fast) Nexitfast++;
  if(Exit_Fast_Slope_Slow) Nexitfast++;
  if(Exit_Fast_Slope_Relation) Nexitfast++;
  if(Exit_Fast_Slope_Fast_Price) Nexitfast++;
  if(Exit_Fast_Slope_Slow_Price) Nexitfast++;
 }
 else Nexitfast=-1;

 if(Exit_Slow_Signals)
 {
  if(Exit_Slow_Snake) Nexitslow++;
  if(Exit_Slow_HA) Nexitslow++; 
  if(Exit_Slow_HAS) Nexitslow++; 
  if(Exit_Slow_Slope_Fast) Nexitslow++;
  if(Exit_Slow_Slope_Slow) Nexitslow++;
  if(Exit_Slow_Slope_Relation) Nexitslow++;
  if(Exit_Slow_Slope_Fast_Price) Nexitslow++;
  if(Exit_Slow_Slope_Slow_Price) Nexitslow++;
 }
 else Nexitslow=-1;

 if(Exit_Fast_Signals&&Nexitfast==0) 
 {
  Alert("Warning: Exit_Fast_Signals is true, but there are no fast-timeframe exit criteria activated. Please correct.");
  stopEA=true;
 }

 if(Exit_Slow_Signals&&Nexitslow==0) 
 {
  Alert("Warning: Exit_Slow_Signals is true, but there are no slow-timeframe exit criteria activated. Please correct.");
  stopEA=true;
 } 
 
 // initialize RSI toggles
 
 RSI_Fast_Long=true;
 RSI_Fast_Short=true;
 RSI_Slow_Long=true;
 RSI_Slow_Short=true;
 
 ResetShutDown();
 
 return;
}
//+------------------------------------------------------------------+ 
bool EntryCriteria(bool long)
{
 int fastn=0,slown=0;
 if(long) // longs 
 {
  if(Fast_Signals) // fast time period 
  {
   if(Fast_Snake)
   {
    if(snakeF0>Snake_fast_UP) fastn++;
   }
   
   if(Fast_HA) 
   {
    if(HAfast) fastn++;
   }
   
   if(Fast_HAS)  
   {
    if(HASfast) fastn++;
   }
   
   if(Fast_Slope_Fast)
   {
    if(SFfast>0) fastn++;
   }   
   
   if(Fast_Slope_Slow)
   {
    if(SSfast>0) fastn++;
   }    
   
   if(Fast_Slope_Relation)
   {
    if(SRfast>0) fastn++;
   }    
   
   if(Fast_Slope_Fast_Price) 
   {
    if(SFPfast) fastn++;
   }
    
   if(Fast_Slope_Slow_Price)
   {
    if(SSPfast) fastn++;
   }   
  }

  if(Slow_Signals) // short time period 
  {
   if(Slow_Snake)
   {
    if(snakeS0>Snake_slow_UP) slown++;
   }
   
   if(Slow_HA) 
   {
    if(HAslow) slown++;
   }
   
   if(Slow_HAS)  
   {
    if(HASslow) slown++;
   }
   
   if(Slow_Slope_Fast)
   {
    if(SFslow>0) slown++;
   }   
   
   if(Slow_Slope_Slow)
   {
    if(SSslow>0) slown++;
   }    
   
   if(Slow_Slope_Relation)
   {
    if(SRslow>0) slown++;
   }    
   
   if(Slow_Slope_Fast_Price) 
   {
    if(SFPslow) slown++;
   }
    
   if(Slow_Slope_Slow_Price)
   {
    if(SSPslow) slown++;
   } 
  }
  
  if(Fast_Signals&&Slow_Signals)
  {
   if(fastn==Nfast&&slown==Nslow) return(true);
  }
  else if(Fast_Signals)
  {
   if(fastn==Nfast) return(true);
  }
  else if(Slow_Signals)
  {
   if(slown==Nslow) return(true);
  }
  
 }
 else // shorts:
 {
  if(Fast_Signals) // fast time period 
  {
   if(Fast_Snake)
   {
    if(snakeF1<Snake_fast_DN) fastn++;
   }
   
   if(Fast_HA) 
   {
    if(!HAfast) fastn++;
   }
   
   if(Fast_HAS)  
   {
    if(!HASfast) fastn++;
   }
   
   if(Fast_Slope_Fast)
   {
    if(SFfast<0) fastn++;
   }   
   
   if(Fast_Slope_Slow)
   {
    if(SSfast<0) fastn++;
   }    
   
   if(Fast_Slope_Relation)
   {
    if(SRfast<0) fastn++;
   }    
   
   if(Fast_Slope_Fast_Price) 
   {
    if(!SFPfast) fastn++;
   }
    
   if(Fast_Slope_Slow_Price)
   {
    if(!SSPfast) fastn++;
   }   
  }

  if(Slow_Signals) // short time period 
  {
   if(Slow_Snake)
   {
    if(snakeS1<Snake_slow_DN) slown++;
   }
   
   if(Slow_HA) 
   {
    if(!HAslow) slown++;
   }
   
   if(Slow_HAS)  
   {
    if(!HASslow) slown++;
   }
   
   if(Slow_Slope_Fast)
   {
    if(SFslow<0) slown++;
   }   
   
   if(Slow_Slope_Slow)
   {
    if(SSslow<0) slown++;
   }    
   
   if(Slow_Slope_Relation)
   {
    if(SRslow<0) slown++;
   }    
   
   if(Slow_Slope_Fast_Price) 
   {
    if(!SFPslow) slown++;
   }
    
   if(Slow_Slope_Slow_Price)
   {
    if(!SSPslow) slown++;
   } 
  }

  if(Fast_Signals&&Slow_Signals)
  {
   if(fastn==Nfast&&slown==Nslow) return(true);
  }
  else if(Fast_Signals)
  {
   if(fastn==Nfast) return(true);
  }
  else if(Slow_Signals)
  {
   if(slown==Nslow) return(true);
  }  
  
 }
 
 return(false);
}
//+------------------------------------------------------------------+ 
bool ExitCriteria(bool long)
{
 int fastn=0,slown=0;
 if(long) // longs 
 {
  if(Exit_Fast_Signals) // fast time period 
  {
   if(Exit_Fast_Snake)
   {
    if(snakeF1<Snake_fast_DN) fastn++;
   }
   
   if(Exit_Fast_HA) 
   {
    if(!HAfast) fastn++;
   }
   
   if(Exit_Fast_HAS)  
   {
    if(!HASfast) fastn++;
   }
   
   if(Exit_Fast_Slope_Fast)
   {
    if(SFfast<0) fastn++;
   }   
   
   if(Exit_Fast_Slope_Slow)
   {
    if(SSfast<0) fastn++;
   }    
   
   if(Exit_Fast_Slope_Relation)
   {
    if(SRfast<0) fastn++;
   }    
   
   if(Exit_Fast_Slope_Fast_Price) 
   {
    if(!SFPfast) fastn++;
   }
    
   if(Exit_Fast_Slope_Slow_Price)
   {
    if(!SSPfast) fastn++;
   }   
  }

  if(Exit_Slow_Signals) // short time period 
  {
   if(Exit_Slow_Snake)
   {
    if(snakeS1<Snake_slow_DN) slown++;
   }
   
   if(Exit_Slow_HA) 
   {
    if(!HAslow) slown++;
   }
   
   if(Exit_Slow_HAS)  
   {
    if(!HASslow) slown++;
   }
   
   if(Exit_Slow_Slope_Fast)
   {
    if(SFslow<0) slown++;
   }   
   
   if(Exit_Slow_Slope_Slow)
   {
    if(SSslow<0) slown++;
   }    
   
   if(Exit_Slow_Slope_Relation)
   {
    if(SRslow<0) slown++;
   }    
   
   if(Exit_Slow_Slope_Fast_Price) 
   {
    if(!SFPslow) slown++;
   }
    
   if(Exit_Slow_Slope_Slow_Price)
   {
    if(!SSPslow) slown++;
   } 
  }
  
  if(Exit_Fast_Signals&&Exit_Slow_Signals)
  {
   if(fastn==Nexitfast&&slown==Nexitslow) return(true);
  }
  else if(Exit_Fast_Signals)
  {
   if(fastn==Nexitfast) return(true);
  }
  else if(Exit_Slow_Signals)
  {
   if(slown==Nexitslow) return(true);
  }
  
 }
 else // shorts:
 {
  if(Exit_Fast_Signals) // fast time period 
  {
   if(Exit_Fast_Snake)
   {
    if(snakeF0>Snake_fast_UP) fastn++;
   }
   
   if(Exit_Fast_HA) 
   {
    if(HAfast) fastn++;
   }
   
   if(Exit_Fast_HAS)  
   {
    if(HASfast) fastn++;
   }
   
   if(Exit_Fast_Slope_Fast)
   {
    if(SFfast>0) fastn++;
   }   
   
   if(Exit_Fast_Slope_Slow)
   {
    if(SSfast>0) fastn++;
   }    
   
   if(Exit_Fast_Slope_Relation)
   {
    if(SRfast>0) fastn++;
   }    
   
   if(Exit_Fast_Slope_Fast_Price) 
   {
    if(SFPfast) fastn++;
   }
    
   if(Exit_Fast_Slope_Slow_Price)
   {
    if(SSPfast) fastn++;
   }   
  }

  if(Exit_Slow_Signals) // short time period 
  {
   if(Exit_Slow_Snake)
   {
    if(snakeS0>Snake_slow_UP) slown++;
   }
   
   if(Exit_Slow_HA) 
   {
    if(HAslow) slown++;
   }
   
   if(Exit_Slow_HAS)  
   {
    if(HASslow) slown++;
   }
   
   if(Exit_Slow_Slope_Fast)
   {
    if(SFslow>0) slown++;
   }   
   
   if(Exit_Slow_Slope_Slow)
   {
    if(SSslow>0) slown++;
   }    
   
   if(Exit_Slow_Slope_Relation)
   {
    if(SRslow>0) slown++;
   }    
   
   if(Exit_Slow_Slope_Fast_Price) 
   {
    if(SFPslow) slown++;
   }
    
   if(Exit_Slow_Slope_Slow_Price)
   {
    if(SSPslow) slown++;
   } 
  }

  if(Exit_Fast_Signals&&Exit_Slow_Signals)
  {
   if(fastn==Nexitfast&&slown==Nexitslow) return(true);
  }
  else if(Exit_Fast_Signals)
  {
   if(fastn==Nexitfast) return(true);
  }
  else if(Exit_Slow_Signals)
  {
   if(slown==Nexitslow) return(true);
  }  
  
 }
 
 return(false);
}
//+------------------------------------------------------------------+
bool TimeEntranceDelay()
{
 if((TimeCurrent()-exittime)>=TimeDelay*60) return(true);
 else return(false);
}
//+------------------------------------------------------------------+
double DetermineProfit() // across all charts 
{
 double price,pointvalue;
 if(OrderType()==OP_BUY)
 {
  price=MarketInfo(OrderSymbol(),MODE_BID);
  pointvalue=MarketInfo(OrderSymbol(),MODE_POINT);
  return(NormDigits((price-OrderOpenPrice())/pointvalue ));
 }
 else if(OrderType()==OP_SELL)
 {
  price=MarketInfo(OrderSymbol(),MODE_ASK); 
  pointvalue=MarketInfo(OrderSymbol(),MODE_POINT);  
  return(NormDigits((OrderOpenPrice()-price)/pointvalue )); 
 }
 return(0); 
}
//+------------------------------------------------------------------+
void CloseAll()
{
 for(int i=OrdersTotal()-1;i>=0;i--)
 {
  OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
  ExitOrder(true,true); 
 }
 ShutDown();
 return;
}
//+------------------------------------------------------------------+
void ResetShutDown()
{
 if(!GlobalVariableCheck("SHUTDOWN")) GlobalVariableSet("SHUTDOWN",0);
 
 GlobalVariableSet("SHUTDOWN",0);
 return;
}
//+------------------------------------------------------------------+
void ShutDown()
{
 if(!GlobalVariableCheck("SHUTDOWN")) GlobalVariableSet("SHUTDOWN",1);
 
 GlobalVariableSet("SHUTDOWN",1);
 return;
}
//+------------------------------------------------------------------+
bool CheckShutDown()
{
 if(GlobalVariableGet("SHUTDOWN")==1) return(true);
 else return(false);
}
//+------------------------------------------------------------------+


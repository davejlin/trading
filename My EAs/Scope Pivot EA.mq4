//+----------------------------------------------------------------------+
//|                                                   Scope Pivot EA.mq4 |
//|                                                         David J. Lin |
//|Based on a pivot strategy (ref: Scope_PivotEA_v1.pdf                  |
//|by BeamFX, Nauman Anees <nanees@BeamFX.com>                           |
//|                                                                      |
//|Coded by David J. Lin (dave.j.lin@sbcglobal.net)                      |
//|Evanston, IL, September 1, 2009                                       |
//|September 8, 2009 added auto-calculation of lots function             |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2009, BeamFX"
#property link      "http://BeamFX.com"

// Pivot parameters
extern int Minimum_Pivot_Distance=10;         // minimum number of pips between pivot line and price to qualify as a trigger 
extern int Max_Look_Up_Bars_Pivot=3;          // number of bars price needs to close above pivot criteria to qualifty as a trigger 

// RSI parameters
extern bool RSI_Active=true;                  // true = use RSI criteria, false = don't use RSI criteria
extern int  RSI_Period=14;                    // RSI period 
extern double Long_RSI=60;                    // RSI above which to allow longs 
extern double Short_RSI=40;                   // RSI below which to allow shorts

// Moving Average parameters:
extern bool Tunnel_MA_Active=true;            // true = Tunnel filter (MA1>MA2 longs, MA1<MA2 shorts) is used, false = Tunnel filter is not used

extern int  Tunnel_MA1_Period=10;             // Tunnel MA1 period 
extern int  Tunnel_MA1_Type=MODE_EMA;         // Tunnel MA1 type
extern int  Tunnel_MA1_Price=PRICE_CLOSE;     // Tunnel MA1 price
extern int  Tunnel_MA1_Shift=0;               // Tunnel MA1 shift

extern int  Tunnel_MA2_Period=20;             // Tunnel MA2 period 
extern int  Tunnel_MA2_Type=MODE_EMA;         // Tunnel MA2 type
extern int  Tunnel_MA2_Price=PRICE_CLOSE;     // Tunnel MA2 price
extern int  Tunnel_MA2_Shift=0;               // Tunnel MA2 shift

// Minimum Cross Distance parameters: 
extern int Min_Cross_Distance=20;             // minimum pip distance between MA1 & MA2 to qualify, use 0 to disable this filter 
extern int Max_Look_Up_Bars_MA=2;             // number of bars to check for close above/below MA1, use 0 to disable this filter   

// Order parameters:
extern int Number_of_Tries=5;                 // maximum number of order submission attempts 

// Time Filter settings:
extern bool Use_Hour_Trade=true;              // true = use time filter to activate EA only during certain hours 
extern int Start_Hour=8;                      // start EA at this hour (platform time) 
extern int End_Hour=16;                       // stop  EA at this hour (platform time)

// Lot and Money Management parameters:
extern bool   Use_Auto_Lot_Determination=true;// true = use automatic calculation of lot sized based on percentage of account equity, false = use Initial_Lot_Size
extern double Risk_Percentage_Factor=1;       // percentage of account equity to risk on the trade for automatic calculation of lot sizes

extern double Initial_Lot_Size=1.0;           // initial lot size
extern double Lot_Size_Increment=0.5;         // factor to reduce initial lot size for next trade (only works when Use_Auto_Lot_Determination=false)

extern int    Max_Trades=3;                   // maximum number of trades the EA submits per day

extern bool   Take_Partial_Profit=true;      // set to true to take partial profits
extern int    Take_Partial_Profit_Number=50;  // pips profit after which to take partial profit
extern double Take_Partial_Profit_Percent=50; // percentage profit to take for partial profit

// Cross Alert parameters:

extern bool Enable_Alert=false;               // alert when MA crosses (up or down)
extern string Sound_File_Name="alert.wav";    // filename of the alert 
extern bool Enable_Email=false;               // set to true to send an email w/ trade descriptions upon trade submission

// Common parameters:
extern int Stop_Loss=100;                     // pips stop loss, set to 0 for no stop loss
extern int Take_Profit=200;                   // pips take profit, set to 0 for no take profit

// Trailing Stop parameters:
extern int Trailing_Stop_Type=1;              // 0 = no trailing stop, 1 = trailing stop once exceeding Trailing_Stop pips
extern int Trailing_Stop=40;                  // pips trailing stop

// Unneeded parameters:
// extern bool Account_Is_Micro=false;        // true = micro account 
// extern bool Show_Settings=true;            // set to true to show settings of all trade conditions on the chart 
// extern bool Max_Look_Up_Type=false;        // true = use confirmation of Max_Look_Up_Bars_MA bars after minimum cross distance is met 

double lotsmin,lotsmax;
int lotsprecision;
bool orderlong,ordershort;
bool initLock,partialexit;
int slippage=5;
int magicN, lotcyclecount;
string comment;
string textheader,timename;
datetime otl,ots,lasttime,starttime,lastD1;
double third;
double Minimum_Pivot_Distance_p,Min_Cross_Distance_p,Take_Partial_Profit_Number_p;
double Stop_Loss_p,Take_Profit_p,Trailing_Stop_p;
double pivot;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//---- 
 starttime=TimeCurrent();
 lotsmin=MarketInfo(Symbol(),MODE_MINLOT); 
 lotsmax=MarketInfo(Symbol(),MODE_MAXLOT); 
 
 comment=StringConcatenate("Scope Pivot ",DoubleToStr(Period(),0)," ",Symbol());
 textheader="Scope Pivot EA: Order Entry Alert";
 
 third=1./3.;
 magicN=100;
 lotcyclecount=0;
 pivot=third*(iHigh(NULL,PERIOD_D1,1)+iLow(NULL,PERIOD_D1,1)+iClose(NULL,PERIOD_D1,1));
 lastD1=iTime(NULL,PERIOD_D1,0);
 
 if(lotsmin==1)         lotsprecision=0;
 else if(lotsmin==0.50) lotsprecision=1; // for PFG ECN
 else if(lotsmin==0.10) lotsprecision=1;
 else if(lotsmin==0.01) lotsprecision=2;
 else                   lotsprecision=1;

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

 if(Use_Hour_Trade)
 {
  if(Start_Hour==End_Hour) Alert("Warning: Start_Hour equals End_Hour. Please change.");
 }

 if(StringFind(Symbol(),"JPY")>0) 
 {
  if(Digits==3)
  {
   Minimum_Pivot_Distance_p=NormPoints(Minimum_Pivot_Distance*10);
   Min_Cross_Distance_p=NormPoints(Min_Cross_Distance*10);
   Take_Partial_Profit_Number_p=NormPoints(Take_Partial_Profit_Number*10);
   Stop_Loss_p=NormPoints(Stop_Loss*10);
   Take_Profit_p=NormPoints(Take_Profit*10);  
   Trailing_Stop_p=NormPoints(Trailing_Stop*10); 
  }
  else
  {
   Minimum_Pivot_Distance_p=NormPoints(Minimum_Pivot_Distance);
   Min_Cross_Distance_p=NormPoints(Min_Cross_Distance);
   Take_Partial_Profit_Number_p=NormPoints(Take_Partial_Profit_Number);
   Stop_Loss_p=NormPoints(Stop_Loss);
   Take_Profit_p=NormPoints(Take_Profit);  
   Trailing_Stop_p=NormPoints(Trailing_Stop);    
  }  
 }
 else
 {
  if(Digits==5)
  {
   Minimum_Pivot_Distance_p=NormPoints(Minimum_Pivot_Distance*10);
   Min_Cross_Distance_p=NormPoints(Min_Cross_Distance*10);
   Take_Partial_Profit_Number_p=NormPoints(Take_Partial_Profit_Number*10);
   Stop_Loss_p=NormPoints(Stop_Loss*10);
   Take_Profit_p=NormPoints(Take_Profit*10);  
   Trailing_Stop_p=NormPoints(Trailing_Stop*10);   
  }
  else
  {
   Minimum_Pivot_Distance_p=NormPoints(Minimum_Pivot_Distance);
   Min_Cross_Distance_p=NormPoints(Min_Cross_Distance);
   Take_Partial_Profit_Number_p=NormPoints(Take_Partial_Profit_Number);
   Stop_Loss_p=NormPoints(Stop_Loss);
   Take_Profit_p=NormPoints(Take_Profit);  
   Trailing_Stop_p=NormPoints(Trailing_Stop);  
  }  
 } 

 initLock=true; partialexit=false;

// Now check open orders
 orderlong=false; ordershort=false; //reset flags
     
 int trade,trades=OrdersTotal();           
 for(trade=0;trade<trades;trade++)// The most recent closed order has the largest position number, so this works forward
                                  // to allow the values of the most recent closed orders to be the ones which are recorded

 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderMagicNumber()!=magicN) continue;
  
  Status();
  break;
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
 Alerts();
 lasttime=iTime(NULL,0,0);
  
 if(lastD1==iTime(NULL,PERIOD_D1,0)) return(0);
 lotcyclecount=0;
 pivot=third*(iHigh(NULL,PERIOD_D1,1)+iLow(NULL,PERIOD_D1,1)+iClose(NULL,PERIOD_D1,1)); 
 lastD1=iTime(NULL,PERIOD_D1,0);
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert utility functions                                         |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void Main()
{ 
 if(GeneralFilters()) return;

 double Lots,SL,TP;
 string td;
  
 if(Bid>=NormDigits(pivot+Minimum_Pivot_Distance_p))
 { 
  if(filter(true))
  {
   SL=StopLong(Ask,Stop_Loss_p);
   TP=TakeLong(Ask,Take_Profit_p);  
    
   Lots=CalcLots();

   SendOrderLong(Symbol(),Lots,slippage,0,0,comment,magicN);  

   lotcyclecount++;
   partialexit=true;

   AddSLTP(SL,TP);

   otl=TimeCurrent();

   if(Enable_Email) SendMessage(true,otl); 
  }
 }
 else if(Bid<=NormDigits(pivot-Minimum_Pivot_Distance_p))
 { 
  if(filter(false))
  {
   SL=StopShort(Bid,Stop_Loss_p);
   TP=TakeShort(Bid,Take_Profit_p);  

   Lots=CalcLots();
   
   SendOrderShort(Symbol(),Lots,slippage,0,0,comment,magicN);

   lotcyclecount++;
   partialexit=true;
      
   AddSLTP(SL,TP);    

   ots=TimeCurrent();

   if(Enable_Email) SendMessage(false,ots);
  }
 }

 return; 
}
//+------------------------------------------------------------------+
bool filter(bool long)
{
 int Trigger[6], totN=6,i,j,barDshift,count;
 double p,var1,var2;
  
 for(i=0;i<totN;i++) Trigger[i]=-1;

 if(long) // long filters
 {
  for(i=0;i<totN;i++)
  {
   switch(i)
   {   
    case 0:
     if(iBarShift(NULL,0,otl,false)>0) Trigger[i]=1;
    break;    
    case 1:
     if(RSI_Active)
     {
      var1=iRSI(NULL,0,RSI_Period,PRICE_CLOSE,0);
      if(var1>=Long_RSI) Trigger[i]=1; 
     }
     else Trigger[i]=1;
    break;
    case 2:
     if(Max_Look_Up_Bars_Pivot>0)
     {
      count=0;
      for(j=1;j<=Max_Look_Up_Bars_Pivot;j++)
      {
       barDshift=iBarShift(NULL,PERIOD_D1,iTime(NULL,0,j),false);
       p=third*(iHigh(NULL,PERIOD_D1,barDshift)+iLow(NULL,PERIOD_D1,barDshift)+iClose(NULL,PERIOD_D1,barDshift));
       var1=iClose(NULL,0,j);
       if(var1>=NormDigits(p+Minimum_Pivot_Distance_p)) count++;
      }
      if (count==Max_Look_Up_Bars_Pivot) Trigger[i]=1;     
     }
     else Trigger[i]=1;
    break;   
    case 3:
     if(Tunnel_MA_Active)
     {
      var1=iMA(NULL,0,Tunnel_MA1_Period,Tunnel_MA1_Shift,Tunnel_MA1_Type,Tunnel_MA1_Price,0);
      var2=iMA(NULL,0,Tunnel_MA2_Period,Tunnel_MA2_Shift,Tunnel_MA2_Type,Tunnel_MA2_Price,0);
      if(var1>var2) Trigger[i]=1;
     } 
     else Trigger[i]=1;
    break;    
    case 4:
     if(Min_Cross_Distance>0)
     {
      var1=iMA(NULL,0,Tunnel_MA1_Period,Tunnel_MA1_Shift,Tunnel_MA1_Type,Tunnel_MA1_Price,0);
      var2=iMA(NULL,0,Tunnel_MA2_Period,Tunnel_MA2_Shift,Tunnel_MA2_Type,Tunnel_MA2_Price,0);

      if(var1>=NormDigits(var2+Min_Cross_Distance_p)) Trigger[i]=1;
     }
     else Trigger[i]=1;
    break; 
    case 5:
     if(Max_Look_Up_Bars_MA>0)
     {
      count=0;
      for(j=1;j<=Max_Look_Up_Bars_MA;j++)
      {
       var1=iMA(NULL,0,Tunnel_MA1_Period,Tunnel_MA1_Shift,Tunnel_MA1_Type,Tunnel_MA1_Price,j);
       var2=iClose(NULL,0,j);
       if(var2>var1) count++;
      }
      if(count==Max_Look_Up_Bars_MA) Trigger[i]=1;
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
     if(iBarShift(NULL,0,ots,false)>0) Trigger[i]=1;
    break;     
    case 1:
     if(RSI_Active)
     {
      var1=iRSI(NULL,0,RSI_Period,PRICE_CLOSE,0);
      if(var1<=Short_RSI) Trigger[i]=1; 
     }
     else Trigger[i]=1;
    break; 
    case 2:
     if(Max_Look_Up_Bars_Pivot>0)
     {
      count=0;
      for(j=1;j<=Max_Look_Up_Bars_Pivot;j++)
      {
       barDshift=iBarShift(NULL,PERIOD_D1,iTime(NULL,0,j),false);
       p=third*(iHigh(NULL,PERIOD_D1,barDshift)+iLow(NULL,PERIOD_D1,barDshift)+iClose(NULL,PERIOD_D1,barDshift));
       var1=iClose(NULL,0,j);
       if(var1<=NormDigits(p-Minimum_Pivot_Distance_p)) count++;
      }
      if(count==Max_Look_Up_Bars_Pivot) Trigger[i]=1;    
     }
     else Trigger[i]=1; 
    break;
    case 3:
     if(Tunnel_MA_Active)
     {
      var1=iMA(NULL,0,Tunnel_MA1_Period,Tunnel_MA1_Shift,Tunnel_MA1_Type,Tunnel_MA1_Price,0);
      var2=iMA(NULL,0,Tunnel_MA2_Period,Tunnel_MA2_Shift,Tunnel_MA2_Type,Tunnel_MA2_Price,0);
      if(var1<var2) Trigger[i]=1;
     } 
     else Trigger[i]=1;
    break;     
    case 4:
     if(Min_Cross_Distance>0)
     {
      var1=iMA(NULL,0,Tunnel_MA1_Period,Tunnel_MA1_Shift,Tunnel_MA1_Type,Tunnel_MA1_Price,0);
      var2=iMA(NULL,0,Tunnel_MA2_Period,Tunnel_MA2_Shift,Tunnel_MA2_Type,Tunnel_MA2_Price,0);

      if(var1<=NormDigits(var2-Min_Cross_Distance_p)) Trigger[i]=1;
     }
     else Trigger[i]=1;
    break;  
    case 5:
     if(Max_Look_Up_Bars_MA>0)
     {
      count=0;
      for(j=1;j<=Max_Look_Up_Bars_MA;j++)
      {
       var1=iMA(NULL,0,Tunnel_MA1_Period,Tunnel_MA1_Shift,Tunnel_MA1_Type,Tunnel_MA1_Price,j);
       var2=iClose(NULL,0,j);
       if(var2<var1) count++;
      }
      if(count==Max_Look_Up_Bars_MA) Trigger[i]=1;
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
bool GeneralFilters()
{
 if(orderlong||ordershort) return(true);
 
 if(Use_Hour_Trade)
 {
  if(TimeFilter()) return(true); 
 } 
 
 if(lotcyclecount>=Max_Trades) return(true);

 if(initLock)// check for 1st cross of application eligibility, EA inactive until a fresh pivot crossing after application
 {
  double open=iOpen(NULL,0,0);
  if((open<=pivot && Bid>=pivot) || (open>=pivot && Bid<=pivot)) 
  {
   initLock=false;
   return(false);
  }
  else return(true);
 }
 
 return(false);
}
//+------------------------------------------------------------------+ 
void ManageOrders()
{
 orderlong=false;ordershort=false;
 int trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;

  if(OrderMagicNumber()!=magicN) continue;
  
  if(OrderType()==OP_BUY)       orderlong=true; 
  else if(OrderType()==OP_SELL) ordershort=true;
 
  if(Trailing_Stop_Type>0) TrailStop(Trailing_Stop_p);
  if(Take_Partial_Profit&&partialexit)  PartExit();
 }
 return;
}
//+------------------------------------------------------------------+
void Alerts()
{
 if(Enable_Alert)
 {
  double ma1=iMA(NULL,0,Tunnel_MA1_Period,Tunnel_MA1_Shift,Tunnel_MA1_Type,Tunnel_MA1_Price,1);
  double ma2=iMA(NULL,0,Tunnel_MA2_Period,Tunnel_MA2_Shift,Tunnel_MA2_Type,Tunnel_MA2_Price,1);
  double ma3=iMA(NULL,0,Tunnel_MA1_Period,Tunnel_MA1_Shift,Tunnel_MA1_Type,Tunnel_MA1_Price,0);
  double ma4=iMA(NULL,0,Tunnel_MA2_Period,Tunnel_MA2_Shift,Tunnel_MA2_Type,Tunnel_MA2_Price,0);
  if(ma1<=ma2 && ma3>=ma4)      
  {
   Alert("Tunnel MA crossed up at ", Bid);
   PlaySound(Sound_File_Name); 
  }
  else if(ma1>=ma2 && ma3<=ma4) 
  {
   Alert("Tunnel MA crossed down at ", Bid);
   PlaySound(Sound_File_Name); 
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
double CalcLots()
{
 double l;
 if(Use_Auto_Lot_Determination) l=DetermineLots();
 else l=MathPow(Lot_Size_Increment,lotcyclecount)*Initial_Lot_Size;
 return(l);
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
void ExitOrder(bool flag_Long,bool flag_Short,double lots=0)
{
 if(lots==0) lots=OrderLots();
 if(OrderType()==OP_BUY&&flag_Long)
  CloseOrderLong(OrderTicket(),lots,slippage,Lime);
 else if(OrderType()==OP_SELL&&flag_Short)
  CloseOrderShort(OrderTicket(),lots,slippage,Lime);
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
double StopLong(double price,double stop) // function to calculate normal stoploss if long
{
 if(stop==0) return(0);
 return(NormDigits(price-stop)); 
             // minus, since the stop loss is below us for long positions
}
//+------------------------------------------------------------------+
double StopShort(double price,double stop) // function to calculate normal stoploss if short
{
 if(stop==0) return(0);
 return(NormDigits(price+stop)); 
             // plus, since the stop loss is above us for short positions
}
//+------------------------------------------------------------------+
double TrailLong(double price,double trail) // function to calculate trail if long, returns Bid if trail=0
{
 if(trail==0) return(Bid);
 return(NormDigits(price-trail)); 
             // minus, since the stop loss is below us for long positions
}
//+------------------------------------------------------------------+
double TrailShort(double price,double trail) // function to calculate trail if short, returns Ask if trail=0
{
 if(trail==0) return(Ask);
 return(NormDigits(price+trail)); 
             // plus, since the stop loss is above us for short positions
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
void Status()
{
 if(OrderType()==OP_BUY)       
 {
  otl=OrderOpenTime();
  orderlong=true;
  lotcyclecount++;
 }
 else if(OrderType()==OP_SELL) 
 {
  ots=OrderOpenTime(); 
  ordershort=true;
  lotcyclecount++;   
 }
 return(0);  
}
//+------------------------------------------------------------------+
void TrailStop(double ts)
{
 if(DetermineProfit()<ts) return; // only begin to trail after trail size is reached
 
 double stopcrnt,stopcal; 
 double profit;
 
 stopcrnt=OrderStopLoss();

// Normal Trailing Stop

//Long               
 if(OrderType()==OP_BUY)
 {
  stopcal=TrailLong(Bid,ts);
  ModifyCompLong(stopcal,stopcrnt);    
 }    
//Short 
 if(OrderType()==OP_SELL)
 {  
  stopcal=TrailShort(Ask,ts);
  ModifyCompShort(stopcal,stopcrnt);
 } 
 return(0);
}
//+------------------------------------------------------------------+
void PartExit()
{
 if(DetermineProfit()<Take_Partial_Profit_Number_p) return; // only partial profit when target is reached

 double exitlots=Take_Partial_Profit_Percent*0.01*OrderLots();
 
 ExitOrder(true,true,exitlots);

 partialexit=false;

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
bool TimeFilter()
{
 if(Start_Hour==End_Hour) return(false);
 
 int timehour=TimeHour(iTime(NULL,0,0)); 
 if(Start_Hour<End_Hour)
 {
  if(timehour<Start_Hour || timehour>=End_Hour) return(true);
 }
 else
 {
  if(timehour<Start_Hour && timehour>=End_Hour) return(true);
 }
 return(false);
}
//+------------------------------------------------------------------+
void SendMessage(bool long, datetime time)
{
 string message,td=TimeToStr(time,TIME_DATE|TIME_MINUTES);
 if(long)
 {
  message=StringConcatenate("Scope Pivot EA ",Symbol()," long entry at ",td,", Period:", timename,", Price:",Ask);
 }
 else
 {
  message=StringConcatenate("Scope Pivot EA ",Symbol()," short entry at ",td,", Period:", timename,", Price:",Bid); 
 }
 SendMail(textheader,message);
 return;
}
//+------------------------------------------------------------------+
double DetermineLots()  // function to determine lot sizes based on account equity
{
 double permitLoss=Risk_Percentage_Factor*0.01*AccountEquity();
 double pipSL=Stop_Loss;
 double valueSL=pipSL*MarketInfo(Symbol(),MODE_TICKVALUE);
 
 double lots=permitLoss/valueSL;
 
 if(lots<lotsmin) return(lotsmin);
 else if(lots>lotsmax) return(lotsmax);
 
 return(lots);
}
//+------------------------------------------------------------------+
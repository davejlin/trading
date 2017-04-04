//+----------------------------------------------------------------------+
//|                                     Supply Demand Leveler Trader.mq4 |
//|                                                         David J. Lin |
//|Based on a Supply & Demand trading strategy                           |
//|Coded by David J. Lin (dave.j.lin@sbcglobal.net)                      |
//|Evanston, IL, July 15, 2008                                           |
//+----------------------------------------------------------------------+
#property copyright "David J. Lin"
#property link      ""

// User adjustable parameters:
extern double SDITrigger=500000;  // threshhold to trigger Supply Demand Imbalance, based on Supply Demand Imbalance indicator
extern double SDIFloor=10;     // minimum value to establish base
extern int SDILookBack=0;      // previous bars to define base (use 0 for strict-cutoff)
extern int SDIEntryRange=2;    // previous bars to define entry range height
// Internal usage parameters:
extern double Lots=0.01;
extern int StopLoss=5;         // pips beyond opposite end of Supply/Demand zone
extern int StopLossMin=50;     // pips stoploss minimum
extern int TakeProfit=200;
extern int ProfitPoint=0;
extern int FixedStop=0;
extern int TrailProfit=0; 
extern int TrailMove=0;

int MATimeFrame=0;
int MAPeriod=20;
int MAShift=0;
int MAMethod=MODE_EMA;
int MAPrice=PRICE_CLOSE;

int CCIPeriod=14;
int CCIPrice=PRICE_TYPICAL;
double CCILimit=25;

int    PeriodsATR = 72;         // H1 ATR Channels
int    MA_Periods = 72; 
int    MA_type = MODE_LWMA;
double Mult_Factor1 = 0.9;
double Mult_Factor2 = 1.8;
double Mult_Factor3 = 2.9;

int  WPRPeriod=36;                     // H1 WPR 
double WPRLong=-80;                    // below which to trigger longs
double WPRShort=-20;                   // above which to trigger shorts

double sh[500],sl[500],dh[500],dl[500]; // stores values sequentially
int Ns,Nd; // current count 
bool orderlong,ordershort;
int Slippage=3;
int Magic=7;
datetime ots,otl,lasttime;
string comment="SDL";
string SDL="Supply Demand Leveler";
string ciATRChannels="ATR_Channels";
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//---- 
 Ns=0;Nd=0;
 SupplyDemandLeveler(true);
 HideTestIndicators(true); 
 lasttime=iTime(NULL,0,0); 
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
//---- 
 if(IsTesting()) GlobalVariablesDeleteAll();
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
//----   

 if(lasttime!=iTime(NULL,0,0)) 
 {
  SupplyDemandLeveler(false); 
//  Alert(lasttime," ",Ns," ",Nd);
  lasttime=iTime(NULL,0,0);
 }
 
 Main();
 ManageOrders(); 

//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert utility functions                                         |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void Main()
{ 
// double sH=iCustom(NULL,0,SDL,SDITrigger,SDIFloor,SDILookBack,SDIEntryRange,false,0,1);
// double sL=iCustom(NULL,0,SDL,SDITrigger,SDIFloor,SDILookBack,SDIEntryRange,false,1,1);
// double dH=iCustom(NULL,0,SDL,SDITrigger,SDIFloor,SDILookBack,SDIEntryRange,false,2,1);
// double dL=iCustom(NULL,0,SDL,SDITrigger,SDIFloor,SDILookBack,SDIEntryRange,false,3,1);   

 double sL=sl[Ns];
 double sH=sh[Ns]; 
 double dL=dl[Nd];
 double dH=dh[Nd];

 if(sL==0 && dH==0) return;
 
 double SL,SL1,SL2,TP;
 
 int cts=iBarShift(NULL,0,ots,false);
 int ctl=iBarShift(NULL,0,otl,false);
 
// if(!orderlong)
 {
  if(dH!=0 && ctl>0)
  {
   if(Bid<=dH)
   {
//    if(filter(true))
    {
     SL1=NormDigits(dl[Nd]-NormPoints(StopLoss));
     SL2=StopLong(Ask,StopLossMin);
     SL=MathMin(SL1,SL2);
     TP=TakeLong(Ask,TakeProfit);  

     SendOrderLong(Symbol(),Lots,Slippage,SL,TP,comment,Magic);
     otl=TimeCurrent();
     Alert("SDL Trader going long ",Symbol(),"!!");
    }
   }
  }
 }

// if(!ordershort)
 {
  if(sL!=0 && cts>0)
  {
   if(Bid>=sL)
   {
//    if(filter(false))
    {
     SL1=NormDigits(sh[Ns]+NormPoints(StopLoss)+(Ask-Bid));
     SL2=StopShort(Bid,StopLossMin);
     SL=MathMax(SL1,SL2);
     TP=TakeShort(Bid,TakeProfit);
   
     SendOrderShort(Symbol(),Lots,Slippage,SL,TP,comment,Magic);
     ots=TimeCurrent();
     Alert("SDL Trader going short ",Symbol(),"!!");    
    }
   }
  }
 }

 return; 
}
//+------------------------------------------------------------------+

bool filter(bool long)
{
 int Trigger[1], totN=0,i;
 double value1,value2;
 
 for(i=0;i<totN;i++) Trigger[i]=-1;

 if(long) // long filters
 {
  for(i=0;i<totN;i++)
  {
   switch(i)
   {
    case 0:   
     value1=iCustom(NULL,0,ciATRChannels,PeriodsATR,MA_Periods,MA_type,Mult_Factor1,Mult_Factor2,Mult_Factor3,2,0);
     if(Bid>value1) Trigger[i]=1;
    break;
    case 1:
     value1=iCustom(NULL,PERIOD_D1,ciATRChannels,PeriodsATR,MA_Periods,MA_type,Mult_Factor1,Mult_Factor2,Mult_Factor3,0,0);
     if(Bid>value1) Trigger[i]=1;
     break;  
    case 2:
     value1=iWPR(NULL,0,WPRPeriod,0);
     if(value1<WPRLong) Trigger[i]=1;
     break;  
    case 3:
     value1=iMA(NULL,MATimeFrame,MAPeriod,MAShift,MAMethod,MAPrice,1);
     value2=iMA(NULL,MATimeFrame,MAPeriod,MAShift,MAMethod,MAPrice,2);     
     if(value1>value2) Trigger[i]=1;    
    break;    
    case 4:
     value1=iCCI(NULL,0,CCIPeriod,CCIPrice,1);
     value2=iCCI(NULL,0,CCIPeriod,CCIPrice,2);
     if(value2<-CCILimit && value1<-CCILimit && value1>value2) Trigger[i]=1;
    break;
    case 5:
    if(sl[Ns]>0 && (sl[Ns]-dh[Nd] > 2*(dh[Nd]-dl[Nd])) ) Trigger[i]=1;
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
     value1=iCustom(NULL,0,ciATRChannels,PeriodsATR,MA_Periods,MA_type,Mult_Factor1,Mult_Factor2,Mult_Factor3,4,0);
     if(Bid<value1) Trigger[i]=1;
    break;   
    case 1:
     value1=iCustom(NULL,PERIOD_D1,ciATRChannels,PeriodsATR,MA_Periods,MA_type,Mult_Factor1,Mult_Factor2,Mult_Factor3,6,0);
     if(Bid<value1) Trigger[i]=1;
     break;   
    case 2:
     value1=iWPR(NULL,0,WPRPeriod,0);
     if(value1>WPRShort) Trigger[i]=1;
     break;       
    case 3:
     value1=iMA(NULL,MATimeFrame,MAPeriod,MAShift,MAMethod,MAPrice,1);
     value2=iMA(NULL,MATimeFrame,MAPeriod,MAShift,MAMethod,MAPrice,2);     
     if(value1<value2) Trigger[i]=1;    
    break;    
    case 4:
     value1=iCCI(NULL,0,CCIPeriod,CCIPrice,1);
     value2=iCCI(NULL,0,CCIPeriod,CCIPrice,2);
     if(value2>CCILimit && value1>CCILimit && value1<value2) Trigger[i]=1;
    break;
    case 5:
    if(dh[Nd]>0 && (sl[Ns]-dh[Nd] > 2*(sh[Ns]-sl[Ns])) ) Trigger[i]=1;    
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
 orderlong=false;ordershort=false;
 int trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;

  if(OrderMagicNumber()!=Magic) continue;

  double profit=DetermineProfit(),atr;

  if(OrderType()==OP_BUY)       
  {
   orderlong=true;
   
   if(profit>0)
   {
    if(Bid>=sl[Ns]&&sl[Ns]>0) 
    {
     ExitOrder(true,false);
     orderlong=false;
    }
   
//    atr=iCustom(NULL,0,ciATRChannels,PeriodsATR,MA_Periods,MA_type,Mult_Factor1,Mult_Factor2,Mult_Factor3,5,0);
//    if(Bid>atr)
//    {
//     ExitOrder(true,false);
//     orderlong=false;
//    }
    
   }
   
  }
  else if(OrderType()==OP_SELL) 
  {
   ordershort=true;
   
   if(profit>0)
   {
    if(Bid<=dh[Nd]) 
    {
     ExitOrder(false,true);
     ordershort=false;
    }  

//    atr=iCustom(NULL,0,ciATRChannels,PeriodsATR,MA_Periods,MA_type,Mult_Factor1,Mult_Factor2,Mult_Factor3,1,0);
//    if(Bid<atr)
//    {
//     ExitOrder(false,true);
//     ordershort=false;
//    }
     
   }

  }

  FixedStopsB(ProfitPoint,FixedStop);
  if(profit>NormPoints(ProfitPoint)) QuantumTrailingStop(TrailProfit,TrailMove);
 } 
 return;
}

//+------------------------------------------------------------------+
int SendPending(string sym, int type, double vol, double price, int slip, double sl, double tp, string comment="", int magic=0, datetime exp=0, color cl=CLR_NONE)
{ 
// In no existing pending order, submit new pending order.   
 int err;
 GetSemaphore();
 for(int z=0;z<5;z++)
 {  
  if(OrderSend(sym,type,NormLots(vol),NormDigits(price),slip,NormDigits(sl),NormDigits(tp),comment,magic,exp,cl)<0)
  {  
   err = GetLastError();
   Print("OrderSend Pending failed, Error: ", err, " Magic Number: ", magic, " Type: ", type);
   Print("Price: ", price, " S/L ", sl, " T/P ", tp);
   if(err>4000) break;
   RefreshRates();
  }
  else
   break;
 }
 ReleaseSemaphore();
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
 return(MathMax(0.01,NormalizeDouble(lots,2)));
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
void QuantumTrailingStop(int TP, int TM) // for every additional TP of profit above ProfitPoint, lock in an additional TM
{
 if(TP<=0) return;
  
 double stopcrnt,stopcal,profit,openprice; 
 int profitpips;
 
 stopcrnt= NormDigits(OrderStopLoss());
 openprice=NormDigits(OrderOpenPrice());
 profit=NormDigits(DetermineProfit());
             
 if(OrderType()==OP_BUY)
 {
  if(stopcrnt<openprice) return;
  profitpips=(stopcrnt-openprice)/Point;
  profitpips+=(TP-TM)+TP;

  if(profit>=NormPoints(profitpips))
  {
   stopcal=stopcrnt+NormPoints(TM);
   if (stopcal==stopcrnt) return;
   ModifyCompLong(stopcal,stopcrnt); 
  }
 }    

 if(OrderType()==OP_SELL)
 {  
  if(stopcrnt>openprice) return; 
  profitpips=(openprice-stopcrnt)/Point;
  profitpips+=(TP-TM)+TP;

  if(profit>=NormPoints(profitpips))
  {
   stopcal=stopcrnt-NormPoints(TM);

   if (stopcal==stopcrnt) return;  
   ModifyCompShort(stopcal,stopcrnt); 
  }
 }  
 
 return(0);
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
    stopcal=TakeLong(OrderOpenPrice(),PFS);
    ModifyCompLong(stopcal,stopcrnt);   
   }
  }    
//Short 
  if(OrderType()==OP_SELL)
  {  
   profit=OrderOpenPrice()-Ask;
   
   if(profit>=profitpoint)
   {
    stopcal=TakeShort(OrderOpenPrice(),PFS);
    ModifyCompShort(stopcal,stopcrnt);
   }
  }  
 return(0);
} 
//+------------------------------------------------------------------+
double TakeLong(double price,int take)  // function to calculate takeprofit if long
{
 if(take==0)
  return(0.0); // if no take profit

 return(NormDigits(price+NormPoints(take))); 
             // plus, since the take profit is above us for long positions
}
//+------------------------------------------------------------------+
double TakeShort(double price,int take)  // function to calculate takeprofit if short
{
 if(take==0)
  return(0.0); // if no take profit

 return(NormDigits(price-NormPoints(take))); 
             // minus, since the take profit is below us for short positions
}
//+------------------------------------------------------------------+
double StopShort(double price,int stop) // function to calculate normal stoploss if short
{
 if(stop==0)
  return(0.0); // if no stop loss
 return(NormDigits(price+NormPoints(stop))); 
             // plus, since the stop loss is above us for short positions
}
//+------------------------------------------------------------------+
double StopLong(double price,int stop) // function to calculate normal stoploss if long
{
 if(stop==0)
  return(0.0); // if no stop loss
 return(NormDigits(price-NormPoints(stop))); 
             // minus, since the stop loss is below us for long positions
             // Point is 0.01 or 0.001 depending on currency, so stop*POINT is a way to convert pips into price with multiplication 
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
void SupplyDemandLeveler(bool first)
{
 int i,j,s,n,lb,limit;
 double SDI[];
 double average,open,close,high,low,price1,price2;
 double range1,range2,range3,range4,mid1,mid2,close0,close1,open0,open1,high0,high1,low0,low1;
 bool trigger;
 
 if(first) limit=Bars-1;
 else      limit=1;
 
 if(SDILookBack==0) 
 {
  lb=1;
  ArrayResize(SDI,2);
 }
 else               
 {
  lb=SDILookBack;
  ArrayResize(SDI,SDILookBack+1);
 }
 
 for(i=limit;i>0;i--)
 {
  for(j=0;j<=lb;j++)
  {
   s=i+j;
   close0=iClose(NULL,0,s);
   close1=iClose(NULL,0,s+1);
  
   open0=iOpen(NULL,0,s);
   open1=iOpen(NULL,0,s+1);

   mid1=MathAbs(close0+open0);
   mid2=MathAbs(close1+open1);
  
   range1=0.5*MathAbs(mid1-mid2)/Point; // midpoint distance (midpoint of 1 minus midpoint of 2)

   mid1=MathAbs(close0-open0);
   mid2=MathAbs(close1-open1);
  
   range2=MathAbs(mid1-mid2)/Point; // difference of open/close range
  
   high0=iHigh(NULL,0,s);
   high1=iHigh(NULL,0,s+1);
  
   low0=iLow(NULL,0,s);
   low1=iLow(NULL,0,s+1);
   
   range3=MathAbs(high0-high1)/Point; // compare high distance 
   range4=MathAbs(low0-low1)/Point; // compare low distance
  
   SDI[j]=range1*range2*range3*range4;
  }
  
  high=iHigh(NULL,0,i);
  low=iLow(NULL,0,i);
  close=iClose(NULL,0,i);
  open=iOpen(NULL,0,i);  
 
// Destroy old levels

  n=Ns;
  for(j=n;j>=0;j--) // if more than one destroyed per bar 
  {
   if(sl[j]==0) break;
   if(high<=sl[j]) break;

   sh[j]=0;    
   sl[j]=0;      
   Ns--;  
 
  }

  n=Nd;
  for(j=n;j>=0;j--) // if more than one destroyed per bar 
  {  
   if(dh[j]==0) break;
   if(low>=dh[j]) break;
   
   dl[j]=0;    
   dh[j]=0;
   Nd--;
  
  }

  trigger=false;

  if(SDILookBack==0)
  {
   if(SDI[0]>SDITrigger && SDI[1]<SDITrigger) trigger=true;
   else trigger=false;
  }
  else
  {
   if(SDI[0]>SDITrigger)
   {
    trigger=true;  
    for(j=1;j<=SDILookBack;j++)
    {
     if(SDI[j]>SDIFloor) 
     {
      trigger=false;
      break;
     }
    }
   }
  }       

  if(trigger)
  {

   if(close>open)
   {
    price1=iHigh(NULL,0,i+1);
    s=iLowest(NULL,0,MODE_LOW,SDIEntryRange,i);   
    price2=iLow(NULL,0,s);    
    if(close>price1)
    {
     Nd++;    
     dh[Nd]=price1;
     dl[Nd]=price2;
     if(i==1) Alert("SDL new Demand Level ",Symbol()," ",TimeToStr(Time[i])," ",SDI[0]," ",SDI[1],"!!");   
    }
   } 
   else if(close<open)
   {
    s=iHighest(NULL,0,MODE_HIGH,SDIEntryRange,i);
    price1=iHigh(NULL,0,s);  
    price2=iLow(NULL,0,i+1);    
    if(close<price2)
    {
     Ns++;     
     sh[Ns]=price1;
     sl[Ns]=price2; 
     if(i==1) Alert("SDL new Supply Level ",Symbol()," ",TimeToStr(Time[i])," ",SDI[0]," ",SDI[1],"!!");     
    }
   }
  }
    
 } 
 return;
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
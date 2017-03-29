//+----------------------------------------------------------------------+
//|                                              Fractal RS Trader 2.mq4 |
//|                                                         David J. Lin |
//| Fractal RS Trader 2(Fractal Resistance & Support Trader)             |
//| written for geneva wheeless (gkw1018@yahoo.com)                      |
//|                                                                      |
//| focused version: entry=Trigger 2, TP=best armpit, SL=best fractal    |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|dave.j.lin@sbcglobal.net                                              |
//|Evanston, IL, March 17, 2008                                          |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2008, David J. Lin"
#property link      ""

// User adjustable parameters:

extern bool AllowAll=true;         // true = take all line signals, false = take only most current line signals
extern bool filter1=false;         // filter 1:  two most recent low fractals must be upwardly ascending for longs, high fractals must be descending for shorts 
extern bool filter2=false;         // filter 2:  lows must not have been lower than most recent low fractal for longs, highs must not have been higher than most recent high fractal for shorts   

                                   // Lottage:  enter zero ("0") if order is undesired 
extern double Lots21=0.01;         // Trigger 2 Order 1 lottage per trade
extern double Lots22=0.00;         // Trigger 2 Order 2 lottage per trade
extern double Lots23=0.00;         // Trigger 2 Order 3 lottage per trade

extern int MinTP=2;                // pips minimum profit (or else don't take trade)

                                   // Take Profits:
                                   // positive values = pip TP
                                   // zero or negative values = pips from highest/lowest arm-pit value in range at order inception
                                   
extern int TakeProfit21=-1;         // Trigger 2 Order 1 pips desired TP
extern int TakeProfit22=0;         // Trigger 2 Order 2 pips desired TP
extern int TakeProfit23=0;         // Trigger 2 Order 3 pips desired TP

                                   // Stop Losses:

extern double StopLossPercent=0; // positive value = use percentage of account as basis for stop-loss 
                                    // zero or negative value = don't use percentage as basis for stop-loss
                                       
extern int StopLossMin=5;         // minimum SL
extern int StopLossMax=50;        // maximum SL

                                   // positive values = pip SL
                                   // zero or negative value = pips from highest/lowest contrary fractal level in range at order inception
                                   // use -999 for SL when close under the first available contrary fractal level from order inception

extern int StopLoss21=-999;          // Trigger 2 Order 1 pips desired SL
extern int StopLoss22=0;           // Trigger 2 Order 2 pips desired SL
extern int StopLoss23=0;           // Trigger 2 Order 3 pips desired SL 

                                   // Trail: 
                                   // positive values = for every additional TrailProfit of profit, raise the SL by TrailMove to lock in more profit
                                   // zero = trail is not desired
                                   // negative number = use Fractal Trail
    
extern int TrailProfit21=0;        // Trigger 2 Order 1 pips desired TrailProfit
extern int TrailMove21=0;          // Trigger 2 Order 1 pips desired TrailMove
extern int TrailProfit22=0;        // Trigger 2 Order 2 pips desired TrailProfit
extern int TrailMove22=0;          // Trigger 2 Order 2 pips desired TrailMove
extern int TrailProfit23=0;        // Trigger 2 Order 3 pips desired TrailProfit
extern int TrailMove23=0;          // Trigger 2 Order 3 pips desired TrailMove

extern int TrailFractalTimeFrame=0;// Timeframe of Fractal Trail (0=chart timeframe, or enter chart's minute value, e.g. "30" for M30 chart)

extern int NoTradeHourStart=-1;    // platform time inclusive (use negative value to turn off)
extern int NoTradeHourEnd=-1;      // platform time inclusive (use negative value to turn off)

extern datetime StartDate=D'2006.10.15';
// Internal usage parameters:
int Slippage=3,bo=0;
double Lots[3];
int magic[3],TakeProfit[3],StopLoss[3],TrailProfit[3],TrailMove[3];
string comment[3];
datetime ot;
int lotsprecision=2;
double lotsmin,lotsmax;
color clrL=Blue,clrS=Red;
string strL="FractRS L",strS="FractRS S";
int code=1,Norders=3;
bool LongExit,ShortExit;//LongExitSL,ShortExitSL;
datetime lasttime,FractUpTime,FractDownTime;
int FractUpi, FractDowni;
double FractUp, FractDown;
double lastResistance,lastSupport,lastestResistance,lastestSupport;
double LastR[100],LastS[100],LastRt[100],LastSt[100];
int NR=0,NS=0;
bool first=true;
double MinTPPoints;
int adjlevelR,adjlevelS;
double barU[],barD[];
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//----

 lotsmin=MarketInfo(Symbol(),MODE_MINLOT); 
 lotsmax=MarketInfo(Symbol(),MODE_MAXLOT);

 if(lotsmin==0.10) lotsprecision=1;

 Lots[0]=Lots21;
 Lots[1]=Lots22;
 Lots[2]=Lots23;  
 
 StopLoss[0]=StopLoss21;
 StopLoss[1]=StopLoss22;
 StopLoss[2]=StopLoss23;   
 
 TakeProfit[0]=TakeProfit21;
 TakeProfit[1]=TakeProfit22;
 TakeProfit[2]=TakeProfit23;   

 TrailProfit[0]=TrailProfit21;
 TrailProfit[1]=TrailProfit22;
 TrailProfit[2]=TrailProfit23;

 TrailMove[0]=TrailMove21;
 TrailMove[1]=TrailMove22;
 TrailMove[2]=TrailMove23;
 
 magic[0] =210000+Period(); 
 magic[1] =210001+Period();
 magic[2] =210002+Period();   
 
 string pd;
 switch(Period())
 {
  case 1:     pd="M1"; break;
  case 5:     pd="M5"; break;
  case 15:    pd="M15";break;
  case 30:    pd="M30";break;
  case 60:    pd="H1"; break;
  case 240:   pd="H4"; break;
  case 1440:  pd="D1"; break;
  case 10080: pd="W1"; break;
  case 40320: pd="M1"; break;
  default:    pd="Unknown";break;
 }  
 
 comment[0]  =StringConcatenate(pd," FractRS 21"); 
 comment[1]  =StringConcatenate(pd," FractRS 22"); 
 comment[2]  =StringConcatenate(pd," FractRS 23");

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
 
 first=true;
 NR=0;NS=0;
 MinTPPoints=NormPoints(MinTP);
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
 if(noRun()) return(0);
//----
 if(lasttime!=iTime(NULL,0,0)) 
 {
  Signals();
 }
 SubmitOrders();
 ExitSignals();  
 ManageOrders();
 lasttime=iTime(NULL,0,0); 
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert utility functions                                         |
//+------------------------------------------------------------------+

void SubmitOrders()
{
 if(AllowAll) Trigger2A();
 else         Trigger2B();
 return;
}
//+------------------------------------------------------------------+
void Trigger2A() // take all line signals
{ 
 int i,checktime=iBarShift(NULL,0,ot,false);
 if(checktime<bo) return;

 double lots,SL,TP; 

 int NRadj=NR-adjlevelR; // for inter-bar entries (possibility of violating multiple lines per bar)
 if(NRadj>0)
 {
  if(Bid<=LastR[NRadj])
  {
   if(Filter(true))
   {
    for(i=0;i<Norders;i++)
    {
     lots=Lots[i];
     if(lots<=0) continue;     
     SL=StopLong(Ask,StopLoss[i],NRadj,lots);
     TP=TakeLong(Ask,TakeProfit[i],NRadj);

     if(NormDigits(TP-Ask)<MinTPPoints) continue;
       
     SendOrderLong(Symbol(),lots,Slippage,SL,TP,comment[i],magic[i],0,Blue);      
    }
    adjlevelR++; 
    ot=TimeCurrent();
   }
  } 
 }
 
 int NSadj=NS-adjlevelS; // for inter-bar entries (possibility of violating multiple lines per bar)
 if(NSadj>0)
 { 
  if(Bid>=LastS[NSadj])
  {
   if(Filter(false))
   {     
    for(i=0;i<Norders;i++)
    {   
     lots=Lots[i];
     if(lots<=0) continue;     
     SL=StopShort(Bid,StopLoss[i],NSadj,lots);
     TP=TakeShort(Bid,TakeProfit[i],NSadj);

     if(NormDigits(Bid-TP)<MinTPPoints) continue;       
       
     SendOrderShort(Symbol(),lots,Slippage,SL,TP,comment[i],magic[i],0,Red);        
    }
    adjlevelS++;          
    ot=TimeCurrent();
   }
  }
 }
 return;
}
//+------------------------------------------------------------------+
void Trigger2B() // take only most current line signals
{ 
 int i,checktime=iBarShift(NULL,0,ot,false);
 if(checktime<bo) return;

 double lots,SL,TP; 

 int NRadj=NR-adjlevelR; // for inter-bar entries (possibility of violating multiple lines per bar)
 if(NRadj>0)
 {
  if(LastR[NRadj]==lastestResistance)
  {
   if(Bid<=LastR[NRadj])
   {
    if(Filter(true))
    {
     for(i=0;i<Norders;i++)
     {
      lots=Lots[i];
      if(lots<=0) continue;     
      SL=StopLong(Ask,StopLoss[i],NRadj,lots);
      TP=TakeLong(Ask,TakeProfit[i],NRadj);

       if(NormDigits(TP-Ask)<MinTPPoints) continue;
       
      SendOrderLong(Symbol(),lots,Slippage,SL,TP,comment[i],magic[i],0,Blue);      
     }
     adjlevelR++; 
     ot=TimeCurrent();
    }
   }
  } 
 }
 
 int NSadj=NS-adjlevelS; // for inter-bar entries (possibility of violating multiple lines per bar)
 if(NSadj>0)
 {
  if(LastS[NSadj]==lastestSupport)
  { 
   if(Bid>=LastS[NSadj])
   {
    if(Filter(false))
    {     
     for(i=0;i<Norders;i++)
     {   
      lots=Lots[i];
      if(lots<=0) continue;     
      SL=StopShort(Bid,StopLoss[i],NSadj,lots);
      TP=TakeShort(Bid,TakeProfit[i],NSadj);

       if(NormDigits(Bid-TP)<MinTPPoints) continue;       
       
      SendOrderShort(Symbol(),lots,Slippage,SL,TP,comment[i],magic[i],0,Red);        
     }
     adjlevelS++;          
     ot=TimeCurrent();       
    }
   }
  }
 }
 return;
}
//+------------------------------------------------------------------+
void Signals()
{
 FractalRS();
 FractalLatest();
 adjlevelR=0; // for inter-bar entries (possibility of violating multiple lines per bar)
 adjlevelS=0; // for inter-bar entries (possibility of violating multiple lines per bar)
 return;
}
//+------------------------------------------------------------------+
void FractalLatest()
{
 int i;
 for(i=3;i<10000;i++)
 {
  if(iFractals(NULL,0, MODE_UPPER, i)<=0) continue;
//  FractUp=iHigh(NULL,PERIOD_H1,i);
  FractUpi=i;
  break;
 }

 for(i=3;i<10000;i++)
 {
  if(iFractals(NULL,0, MODE_LOWER, i)<=0) continue;
//  FractDown=iLow(NULL,PERIOD_H1,i);
  FractDowni=i;
  break;
 } 
 return;
}
//+------------------------------------------------------------------+
void FractalRS()
{
 int i,imax,iaug;
 double Fup,Fdn,close,open,low,high,price;
 bool newS,newR;
 
 if(first) 
 {
  int shift=iBarShift(NULL,0,StartDate,false);  
  imax=shift-2; 
  lastResistance=EMPTY_VALUE;
  lastSupport=EMPTY_VALUE;
  first=false;
 } 
 else imax=1;

 for(i=imax;i>=1;i--)
 {   
//  LongExitSL=false;ShortExitSL=false;
  iaug=i+2;
  Fup=iFractals(NULL,0,MODE_UPPER,iaug);
  if(Fup>0) 
  {
   FractUp=iHigh(NULL,0,iaug);
   FractUpTime=iTime(NULL,0,iaug);
   lastResistance=EMPTY_VALUE; // refresh for a new fractal
  }
  
  Fdn=iFractals(NULL,0,MODE_LOWER,iaug);
  if(Fdn>0) 
  { 
   FractDown=iLow(NULL,0,iaug);
   FractDownTime=iTime(NULL,0,iaug);   
   lastSupport=EMPTY_VALUE; // refresh for a new fractal
  }

  close=NormDigits(iClose(NULL,0,i));
  open =NormDigits(iOpen(NULL,0,i));
  low  =NormDigits(iLow(NULL,0,i));
  high =NormDigits(iHigh(NULL,0,i));
  
  newS=false;
  if(FractDown!=lastSupport) 
  {
   if(close<FractDown && open<FractDown)
   {
    FractalArray(FractDown,high,low,true,true);
    lastSupport=FractDown;    
    lastestSupport=FractDown; // need latest to avoid entering upon pre-existing FRS line
    newS=true;
//    LongExitSL=true;
   }
  }

  if(!newS)
  {
   if(NS>0)
   {
    price=LastS[NS];
    if(high>=price)
    {        
     // Demote Array
     FractalArray(price,high,low,true,false);
     lastSupport=price;  // avoid marking the same fractal after violation
    }
   }
  }

  newR=false;
  if(FractUp!=lastResistance) 
  {
   if(close>FractUp && open>FractUp)
   {
    FractalArray(FractUp,high,low,false,true);
    lastResistance=FractUp;
    lastestResistance=FractUp; // need latest to avoid entering upon pre-existing FRS line
    newR=true;
//    ShortExitSL=true;      
   } 
  }

  if(!newR)
  {
   if(NR>0)
   {
    price=LastR[NR];    
    if(low<=price)
    { 
     // Demote Array
     FractalArray(FractUp,high,low,false,false);
     lastResistance=price;  // avoid marking the same fractal after violation     
    } 
   }
  }

 }  
 return;
}
//+------------------------------------------------------------------+
void FractalArray(double price, double high, double low, bool SupRes, bool AddSub)
{
 int i;
 
 if(NS>99) Alert("Warning ... Support Array limit of 100 exceeded!");
 if(NR>99) Alert("Warning ... Resistance Array limit of 100 exceeded!");
 
 if(SupRes)
 {
  if(AddSub)
  {
   NS++;
   LastS[NS]=price;
   LastSt[NS]=FractDownTime;
  }
  else
  {
   for(i=NS;i>=1;i--)
   {
    if(high>=LastS[i])
    {
     NS--;         
    }
    else break;
   }
  }
 }
 else
 {
  if(AddSub)
  {
   NR++;      
   LastR[NR]=price;  
   LastRt[NR]=FractUpTime;    
  }
  else
  {
   for(i=NR;i>=1;i--)
   {
    if(low<=LastR[i])
    {
     NR--;        
    }
    else break;
   }  
  }
 }
 return;
}
//+------------------------------------------------------------------+
void ManageOrders()
{
 int j,mn,trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  
  mn=OrderMagicNumber();
  
  for(j=0;j<Norders;j++)
  {
   if(mn==magic[j]) 
   {
    ManageOrder(j);
   } 
  }
 
 }
 return;
}
//+------------------------------------------------------------------+
void ManageOrder(int j)
{
 double profit=DetermineProfit();
 double frac;
 int i,shift;

 if(lasttime!=iTime(NULL,0,0))
 {
  if(StopLoss[j]==-999) FractalSLClose();
 } 
   
 if(TrailProfit[j]!=0) 
 {
  if(TrailProfit[j]>0) // pip trail
  {
   if(profit>=NormPoints(TrailProfit[j]))
   {
    QuantumTrailingStop(TrailProfit[j],TrailMove[j]);  
    FixedStopsB(TrailProfit[j],TrailMove[j]);
   }
  }
  else // Fractal Trail
  {
   if(lasttime!=iTime(NULL,0,0))
   { 
    shift=iBarShift(NULL,TrailFractalTimeFrame,OrderOpenTime(),false); 
    if(shift<3) return; // don't trail w/ "old" fracs
       
    if(OrderType()==OP_BUY)
    {
     if(TrailFractalTimeFrame==0) frac=FractDown;
     else 
     { 
      for(i=3;i<shift;i++)
      {
       frac=iFractals(NULL,TrailFractalTimeFrame, MODE_LOWER, i);
       if(frac>0) break;
      }
     }
     ModifyCompLong(frac,OrderStopLoss());
    }
    else if(OrderType()==OP_SELL)
    {
     if(TrailFractalTimeFrame==0) frac=FractUp;
     else 
     {
      for(i=3;i<=shift;i++)
      {
       frac=iFractals(NULL,TrailFractalTimeFrame, MODE_UPPER, i);
       if(frac>0) break;
      }
     }
     frac=NormDigits(frac+(Ask-Bid));
     ModifyCompShort(frac,OrderStopLoss());
    }
   }
  }
 }
 return;
}
//+------------------------------------------------------------------+
void ExitSignals()
{
 LongExit=false;ShortExit=false;
 if(NR>0)
 {
  if(Bid==LastR[NR]) ShortExit=true;
 }
 if(NS>0)
 {
  if(Bid==LastS[NS]) LongExit=true;
 }
 return;
}
//+------------------------------------------------------------------+
bool Filter(bool long)
{
 if(!filter1 && !filter2) return(true);
 int Trigger[2], totN=2,N,i,j,k;
 double value[2],index[2];
 bool trig;
 
 for(i=0;i<totN;i++) Trigger[i]=-1;

 if(long) // long filters
 {

  N=0;
  for(j=3;j<10000;j++)
  {
   if(iFractals(NULL,0, MODE_LOWER, j)<=0) continue;
   value[N]=iLow(NULL,0,j);
   index[N]=j;
   N++;
   if(N>1) break;
  }

  for(i=0;i<totN;i++)
  {
   switch(i)
   { 
    case 0:
     if(filter1)
     {
      if(value[1]<value[0]&&value[1]<Bid&&value[0]<Bid) Trigger[i]=1;
     }
     else Trigger[i]=1;
     break; 
    case 1:   
     if(filter2)
     {
      for(k=0;k<=index[1]-1;k++) // 11/16/07 avoid entries if price exceeded the last fractal any time
      {
       if(iLow(NULL,0,k)<value[0]) return(false);
      }
      Trigger[i]=1;     
     }
     else Trigger[i]=1;
     break;     
   }
   if(Trigger[i]<0) return(false);       
  } 
 }
 else // short filters
 {

  N=0;
  for(j=3;j<10000;j++)
  {
   if(iFractals(NULL,0, MODE_UPPER, j)<=0) continue;
   value[N]=iHigh(NULL,0,j);
   index[N]=j;     
   N++;
   if(N>1) break;
  } 
 
  for(i=0;i<totN;i++)
  {
   switch(i)
   { 
    case 0:
     if(filter1)
     {
      if(value[1]>value[0]&&value[1]>Bid&&value[0]>Bid) Trigger[i]=1; 
     }
     else Trigger[i]=1;
     break;
    case 1:
     if(filter2)
     {  
      for(k=0;k<=index[1]-1;k++) // 11/16/07 avoid entries if price exceeded last fractal any time
      {
       if(iHigh(NULL,0,k)>value[0]) return(false);
      }
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
double StopLong(double price,int stop, int nsr, double lots) // function to calculate stoploss if long
{
 if(StopLossPercent<=0)
 {
  if(stop==-999) return(NormDigits(price-NormPoints(StopLossMax)));

  double slmax=NormDigits(price-NormPoints(StopLossMax));
  double slmin=NormDigits(price-NormPoints(StopLossMin));
  double sl,sl1;

  if(stop<=0)
  {
   sl1=NormDigits(FractalSL(true,nsr,price)-NormPoints(-stop));
  }
  else
  {
   sl1=NormDigits(price-NormPoints(stop));
  }

  sl=MathMin(sl1,slmin);
  sl=MathMax(sl,slmax); 
 }
 else
 {
  double value=AccountBalance()*StopLossPercent;
  sl=NormDigits( price-((value*Point)/(lots*MarketInfo(Symbol(),MODE_TICKVALUE))) );
 }
 
 return(sl); 
}
//+------------------------------------------------------------------+
double StopShort(double price,int stop, int nsr, double lots) // function to calculate stoploss if short
{
 if(StopLossPercent<=0)
 {
  if(stop==-999) return(NormDigits(price+NormPoints(StopLossMax)));

  double slmax=NormDigits(price+NormPoints(StopLossMax));
  double slmin=NormDigits(price+NormPoints(StopLossMin));
  double sl,sl1;
 
  if(stop<=0)
  {
   sl1=NormDigits(FractalSL(false,nsr,price)+NormPoints(-stop));
  } 
  else
  {
   sl1=NormDigits(price+NormPoints(stop));  
  }
 
  sl=MathMax(sl1,slmin);
  sl=MathMin(sl,slmax);
 }
 else
 {
  double value=AccountBalance()*StopLossPercent;
  sl=NormDigits( price+((value*Point)/(lots*MarketInfo(Symbol(),MODE_TICKVALUE))) );
 } 
 return(sl); 
}
//+------------------------------------------------------------------+
double TakeLong(double price,int take, int nsr)  // function to calculate takeprofit if long
{
 if(take<=0) // Arm Pit TPs
 {
  return(NormDigits(ArmPitTargets(true,nsr)-NormPoints(-take)));  
 }
 
 return(NormDigits(price+NormPoints(take))); 
}
//+------------------------------------------------------------------+
double TakeShort(double price,int take, int nsr)  // function to calculate takeprofit if short
{
 if(take<=0) // Arm Pit TPs
 {
  return(NormDigits(ArmPitTargets(false,nsr)+NormPoints(-take))); 
 }

 return(NormDigits(price-NormPoints(take))); 
}
//+------------------------------------------------------------------+
void FixedStopsB(int PP,int PFS)
{
  if(PFS<=0) return;

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
    stopcal=TakeLong(OrderOpenPrice(),PFS,-1);
    ModifyCompLong(stopcal,stopcrnt);   
   }
  }    
//Short 
  if(OrderType()==OP_SELL)
  {  
   profit=OrderOpenPrice()-Ask;
   
   if(profit>=profitpoint)
   {
    stopcal=TakeShort(OrderOpenPrice(),PFS,-1);
    ModifyCompShort(stopcal,stopcrnt);
   }
  }  
 return(0);
} 
//+------------------------------------------------------------------+
void QuantumTrailingStop(int TP, int TM) // for every additional TP of profit above SLMove, lock in an additional TM
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
 return(MathMax(NormalizeDouble(lotsmin,lotsprecision),NormalizeDouble(lots,lotsprecision)));
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
 {
  CloseOrderLong(OrderTicket(),OrderLots(),Slippage,Lime);
 }
 else if(OrderType()==OP_SELL&&flag_Short)
 {
  CloseOrderShort(OrderTicket(),OrderLots(),Slippage,Lime);
 }
 return;
}

//+------------------------------------------------------------------+
void Status(int mn)
{   
      if(mn==magic[0]) ot=OrderOpenTime();
 else if(mn==magic[1]) ot=OrderOpenTime();
 else if(mn==magic[2]) ot=OrderOpenTime();

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
bool noRun()
{
 if(NoTradeHourStart>=0&&NoTradeHourEnd>=0)
 {
  if(NoTradeHourEnd>NoTradeHourStart)
  {
   if(Hour()>=NoTradeHourStart&&Hour()<=NoTradeHourEnd) return(true);
  }
  else
  {
   if(Hour()>=NoTradeHourStart||Hour()<=NoTradeHourEnd) return(true);
  }
 }
 return(false);
}
//+------------------------------------------------------------------+
double ArmPitTargets(bool flag, int nsr)
{
 int i,shift;
 double keep;

 if(flag)
 {
  shift=iBarShift(NULL,0,LastRt[nsr],false);
  FillArmPitArrays(shift);
  keep=0;
  for(i=1;i<=shift;i++)
  {
   // Up:  highest "low"
   if(barD[i]>keep) keep=barD[i];
  }
 }
 else
 {
  shift=iBarShift(NULL,0,LastSt[nsr],false);
  FillArmPitArrays(shift);
  keep=999999;
  for(i=1;i<=shift;i++)
  {
   // Dn: lowest "high"
   if(barU[i]<keep) keep=barU[i];
  } 
  keep=NormDigits(keep+(Ask-Bid)); // spread
 }
 
 return(keep);
}
//+------------------------------------------------------------------+
void FillArmPitArrays(int shift)
{
 int i;double close,open;
 ArrayResize(barU,shift+1);
 ArrayResize(barD,shift+1);
 for(i=1;i<=shift;i++)
 {
  close=iClose(NULL,0,i);
  open=iOpen(NULL,0,i);
  if(close>open)
  {
   barU[i]=close;
   barD[i]=open;
  }
  else // includes possibility of equivalence
  {
   barU[i]=open;
   barD[i]=close;   
  }   
 }
 return;
}
//+------------------------------------------------------------------+
double FractalSL(bool flag, int nsr, double price)
{
 int i,shift;
 double keep,frac,pricetarget;
 
 if(flag)
 {
  pricetarget=NormDigits(price-NormPoints(StopLossMin));
  shift=iBarShift(NULL,0,LastRt[nsr],false); 
  keep=999999.;
  for(i=1;i<=shift;i++)
  {
   frac=iFractals(NULL,0, MODE_LOWER, i);
   if(frac>0)
   {
    if(frac<keep) keep=frac;
   }  
  }
  
  if(keep>pricetarget) // if no good frac level ... keep searching
  {
   for(i=shift+1;i<=10000;i++)
   {
    frac=iFractals(NULL,0, MODE_LOWER, i);
    if(frac>0)
    {
     if(frac<keep) keep=frac;
    }    
    if(keep<pricetarget) return(keep);
   }
  }
  
 }
 else
 {
  pricetarget=NormDigits(price+NormPoints(StopLossMin)+(Ask-Bid));
  shift=iBarShift(NULL,0,LastSt[nsr],false); 
  keep=0.;
  for(i=1;i<=shift;i++)
  {
   frac=iFractals(NULL,0, MODE_UPPER, i);
   if(frac>0)
   {
    if(frac>keep) keep=NormDigits(frac+(Ask-Bid));
   }  
  }
  
  if(keep<pricetarget) // if no good frac level ... keep searching
  {
   for(i=shift+1;i<=10000;i++)
   {
    frac=iFractals(NULL,0, MODE_UPPER, i);
    if(frac>0)
    {
     if(frac>keep) keep=NormDigits(frac+(Ask-Bid));
    }    
    if(keep>pricetarget) return(keep);
   }
  }
 
 }

 return(keep);
}
//+------------------------------------------------------------------+
void FractalSLClose()
{
 int i,shift=iBarShift(NULL,0,OrderOpenTime(),false);
 double close=iClose(NULL,0,1);
 double pricetarget,frac;
 
 if(OrderType()==OP_BUY)
 {
  pricetarget=NormDigits(OrderOpenPrice()-NormPoints(StopLossMin));
  for(i=shift+1;i<=10000;i++)
  {
   frac=iFractals(NULL,0, MODE_LOWER, i);
   if(frac>0)
   {
    if(frac<pricetarget)
    {
     if(close<frac) 
     {
      ExitOrder(true,false);
      return;
     }
     else return;
    }
   }
  }
 }
 else if(OrderType()==OP_SELL)
 {
  pricetarget=NormDigits(OrderOpenPrice()+NormPoints(StopLossMin));
  for(i=shift+1;i<=10000;i++)
  {
   frac=iFractals(NULL,0, MODE_UPPER, i);
   if(frac>0)
   {
    if(frac>pricetarget)
    {
     if(close>frac) 
     {
      ExitOrder(false,true);
      return;
     }
     else return;
    }
   }
  } 
 }
 return;
}
//+------------------------------------------------------------------+


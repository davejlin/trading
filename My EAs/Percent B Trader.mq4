//+----------------------------------------------------------------------+
//|                                                 Percent B Trader.mq4 |
//|                                                         David J. Lin |
//| Percent B Trader                                                     |
//| written for Suresh Sundaram (sureshst_31@yahoo.com)                  |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|dave.j.lin@sbcglobal.net                                              |
//|Evanston, IL, September 11, 2007                                      |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2007 Suresh Sundaram & David J. Lin"

//---- user adjustable parameters

extern int SpreadNoTrade=10;  // if spreads equal or exceed this value, don't enter new orders

extern double LevelHigh=0.80;
extern double LevelLow=0.20;

extern int TF1_BBPeriod=20;
extern int TF1_Shift=0;
extern int TF1_Price=PRICE_CLOSE;
extern double TF1_StdDeviation=2.0;

extern int TF2_BBPeriod=20;
extern int TF2_Shift=0;
extern int TF2_Price=PRICE_CLOSE;
extern double TF2_StdDeviation=2.0;

extern int TF1=PERIOD_H4;
extern int TF2=PERIOD_D1;

extern double Lots1=0.01;            // lottage per trade O1
extern double Lots2=0.01;            // lottage per trade O2 (use negative number if no extra lot is desired)
extern double Lots3=0.01;            // lottage per trade O3 (use negative number if no extra lot is desired)
extern double Lots4=0.01;            // lottage per trade O4 (use negative number if no extra lot is desired)
extern double Lots5=0.01;            // lottage per trade O5 (use negative number if no extra lot is desired)

extern int TakeProfit1=25;           // pips desired TP O1 (use negative number if no TP is desired)
extern int TakeProfit2=50;           // pips desired TP O2 (use negative number if no TP is desired)
extern int TakeProfit3=75;           // pips desired TP O3 (use negative number if no TP is desired)
extern int TakeProfit4=100;          // pips desired TP O4 (use negative number if no TP is desired)
extern int TakeProfit5=125;          // pips desired TP O5 (use negative number if no TP is desired)

extern int StopLoss=50;              // pips desired SL (use negative number if no SL is desired)
extern int TrailStart=25;            // pips profit after which to trail stop by TrailPips (use negative number if not desired)
extern int TrailPips=5;              // pips desired trailing stop, engages after TrailStart is hit 

extern int MaxNumberTrades=8;        // maximum number of trades open simultaneously

extern bool CloseContrary=true;     // true = close Lots1 and Lots2 upon contrary entry; false = don't close any orders upon contrary entry

extern int NoTradeDay1=-1;           // no trade on this day of week (0=Sunday, 5=Friday, negative=off)
extern int NoTradeDay2=-1;           // no trade on this day of week (0=Sunday, 5=Friday, negative=off)

extern int NoTradeHourStart=-1;      // platform time inclusive (use negative value to turn off)
extern int NoTradeHourEnd=-1;        // platform time inclusive (use negative value to turn off)

extern datetime NoTradeCalendarDate1=D'2007.12.25'; // no trade on these calender dates
extern datetime NoTradeCalendarDate2=D'2008.01.01';
extern datetime NoTradeCalendarDate3=D'2008.12.25';

extern double FreeMargin_Limit=100;  // no trade if free margin dips below this value (dollars)

// Internal usage parameters:

datetime ExpirationDate=D'2020.12.31'; // EA does not function after this date 
int AccNumber=-1;                      // EA functions only for this account number (set to negative number if this filter is not desired)
bool DemoOnly=false;                   // if set to true, EA functions only in demo accounts 

int Slippage=3,bo=1;
int lotsprecision=2,Nlots=5;
double lotsmin,lotsmax;
bool LongExit,ShortExit,trigL,trigS,trigLR,trigSR;
datetime lasttime,ot;
double v01,v02,v11,v12;
string comment[],commentR[];
int NL[],NS[],magic[],TakeProfit[];
double Lots[];
datetime bodates[];
color clrL=Blue,clrS=Red;
string strL="Long",strS="Short";
int code=1;
string TextHeader="%B Entry Alert!!"; // header of email message 
string ciBands="Bands";
string ciMTFDBP="MTF Double Percent B";
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//----
 ArrayResize(bodates,3);
 ArrayResize(TakeProfit,Nlots);
 ArrayResize(Lots,Nlots);
 ArrayResize(magic,Nlots);
 ArrayResize(NL,Nlots);
 ArrayResize(NS,Nlots); 
 ArrayResize(comment,Nlots);
 ArrayResize(commentR,Nlots); 
 
 bodates[0]=NoTradeCalendarDate1;
 bodates[1]=NoTradeCalendarDate2;
 bodates[2]=NoTradeCalendarDate3;  
 
 lotsmin=MarketInfo(Symbol(),MODE_MINLOT); 
 lotsmax=MarketInfo(Symbol(),MODE_MAXLOT);

 if(lotsmin==0.10) lotsprecision=1;
 
 Lots[0]=Lots1;Lots[1]=Lots2;Lots[2]=Lots3;Lots[3]=Lots4;Lots[4]=Lots5;
 TakeProfit[0]= TakeProfit1;TakeProfit[1]=TakeProfit2;TakeProfit[2]=TakeProfit3;TakeProfit[3]=TakeProfit4;TakeProfit[4]=TakeProfit5;
 magic[0]=10001;magic[1]=10002;magic[2]=10003;magic[3]=10004;magic[4]=10005;
 comment[0]="%B1";comment[1]="%B2";comment[2]="%B3";comment[3]="%B4";comment[4]="%B5";
 commentR[0]="%BR1";commentR[1]="%BR2";commentR[2]="%BR3";commentR[3]="%BR4";commentR[4]="%BR5"; 

// First check closed trades
 int j,trade,s;string sym;                      
 int trades=OrdersHistoryTotal();           
 for(trade=0;trade<trades;trade++)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_HISTORY);
  if(OrderSymbol()!=Symbol()) continue;
  int D1bars=iBarShift(sym,PERIOD_D1,OrderCloseTime(),false); 
  if(D1bars>30) continue;
  for(j=0;j<Nlots;j++)
  {
   if(OrderMagicNumber()==magic[j]) ot=OrderOpenTime();
  }
 }

// Now check open orders          
 trades=OrdersTotal();           
 for(trade=0;trade<trades;trade++)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  for(j=0;j<Nlots;j++)
  {    
   if(OrderMagicNumber()==magic[j]) ot=OrderOpenTime();
  }
  if(OrderType()==OP_BUY)       DrawCross(OrderOpenPrice(),OrderOpenTime(),strL,clrL,code);
  else if(OrderType()==OP_SELL) DrawCross(OrderOpenPrice(),OrderOpenTime(),strS,clrS,code);
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
 for(int i=1;i<4;i++)
 {
  if(noRun(i)) return(0);
 }

//----
// if(lasttime!=iTime(NULL,0,0))
 {
  Trigger();
  SubmitOrders();
 }
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
 LongExit=false; ShortExit=false;

 if(BlackOuts()) return;
     
 double lots,SL,TP; 
 bool Long=true,Short=true;
 
 int i,j,checktime=iBarShift(NULL,0,ot,false);
 if(checktime<bo) return;

 Long=true;
 for(j=0;j<Nlots;j++)
 {
  if(NL[j]>=MaxNumberTrades) Long=false; 
 }

 if(Long)
 {
  if(trigL)
  {
   if(Filter(true))
   { 
    SL=StopLong(Ask,StopLoss);
    for(j=0;j<Nlots;j++)
    {
     if(Lots[j]>0) 
     {
      TP=TakeLong(Ask,TakeProfit[j]);    
      SendOrderLong(Symbol(),Lots[j],Slippage,SL,TP,comment[j],magic[j],0,Blue);
      NL[j]++;
     }
    }
    Message("Long",Ask,v01,v11);
    ShortExit=true;
    ot=TimeCurrent();
   }
  }
 }

 Long=true;
 for(j=0;j<Nlots;j++)
 {
  if(NL[j]>=MaxNumberTrades) Long=false; 
 }
 
 if(Long) 
 {
  if(trigLR)
  {
   if(Filter(true))
   { 
    SL=StopLong(Ask,StopLoss);
    for(j=0;j<Nlots;j++)
    {
     if(Lots[j]>0) 
     {
      TP=TakeLong(Ask,TakeProfit[j]);    
      SendOrderLong(Symbol(),Lots[j],Slippage,SL,TP,commentR[j],magic[j],0,Blue);
      NL[j]++;      
     }
    }
    Message("Long Reversal",Ask,v01,v11);    
    ShortExit=true;
    ot=TimeCurrent();
   }
  } 
  
 } 

 Short=true;
 for(j=0;j<Nlots;j++)
 {
  if(NS[j]>=MaxNumberTrades) Short=false; 
 }

 if(Short)
 {
  if(trigS)
  { 
   if(Filter(false))
   {  
    SL=StopShort(Bid,StopLoss);
    for(j=0;j<Nlots;j++)
    {
     if(Lots[j]>0) 
     {
      TP=TakeShort(Bid,TakeProfit[j]);
      SendOrderShort(Symbol(),Lots[j],Slippage,SL,TP,comment[j],magic[j],0,Red);
      NS[j]++;        
     }
    }   
    Message("Short",Bid,v01,v11);       
    LongExit=true;
    ot=TimeCurrent();
   }
  }
 }

 Short=true;
 for(j=0;j<Nlots;j++)
 {
  if(NS[j]>=MaxNumberTrades) Short=false; 
 }
 
 if(Short)
 {
  if(trigSR)
  { 
   if(Filter(false))
   {  
    SL=StopShort(Bid,StopLoss);
    for(j=0;j<Nlots;j++)
    {
     if(Lots[j]>0) 
     {
      TP=TakeShort(Bid,TakeProfit[j]);
      SendOrderShort(Symbol(),Lots[j],Slippage,SL,TP,commentR[j],magic[j],0,Red);  
      NS[j]++;       
     }
    }     
    Message("Short Reversal",Bid,v01,v11);     
    LongExit=true;
    ot=TimeCurrent();
   }
  }  
  
 }
 
 return;
}
//+------------------------------------------------------------------+
void Trigger()
{
 trigL=false;trigS=false;trigLR=false;trigSR=false;
 bool internal=true;

 double a,b,close,bl,bh;
 int shift; 

 int i=1;
 int time1=iTime(NULL,0,i);
 int time2=iTime(NULL,0,i+1);

 if(internal)
 { 
  shift=iBarShift(NULL,TF1,time1,false);
  close=iClose(NULL,TF1,shift);

//  bh=iCustom(NULL,TF1,ciBands,TF1_BBPeriod,TF1_Shift,TF1_StdDeviation,1,shift);
//  bl=iCustom(NULL,TF1,ciBands,TF1_BBPeriod,TF1_Shift,TF1_StdDeviation,2,shift);

  bh=myBands(TF1,TF1_BBPeriod,TF1_Shift,TF1_Price,TF1_StdDeviation,1,shift);
  bl=myBands(TF1,TF1_BBPeriod,TF1_Shift,TF1_Price,TF1_StdDeviation,2,shift); 

  a=close-bl;
  b=1.0/(bh-bl);

  if(bl!=bh) v01=a*b;
  v01=NormalizeDouble(v01,4);

  shift=iBarShift(NULL,TF1,time2,false);
  close=iClose(NULL,TF1,shift);

//  bh=iCustom(NULL,TF1,ciBands,TF1_BBPeriod,TF1_Shift,TF1_StdDeviation,1,shift);
//  bl=iCustom(NULL,TF1,ciBands,TF1_BBPeriod,TF1_Shift,TF1_StdDeviation,2,shift);

  bh=myBands(TF1,TF1_BBPeriod,TF1_Shift,TF1_Price,TF1_StdDeviation,1,shift);
  bl=myBands(TF1,TF1_BBPeriod,TF1_Shift,TF1_Price,TF1_StdDeviation,2,shift); 

  a=close-bl;
  b=1.0/(bh-bl);

  if(bl!=bh) v02=a*b;
  v02=NormalizeDouble(v02,4);

  shift=iBarShift(NULL,TF2,time1,false);  
  close=iClose(NULL,TF2,shift);

//  bh=iCustom(NULL,TF2,ciBands,TF2_BBPeriod,TF2_Shift,TF2_StdDeviation,1,shift);
//  bl=iCustom(NULL,TF2,ciBands,TF2_BBPeriod,TF2_Shift,TF2_StdDeviation,2,shift);

  bh=myBands(TF2,TF2_BBPeriod,TF2_Shift,TF2_Price,TF2_StdDeviation,1,shift);
  bl=myBands(TF2,TF2_BBPeriod,TF2_Shift,TF2_Price,TF2_StdDeviation,2,shift);

  a=close-bl;
  b=1.0/(bh-bl);

  if(bl!=bh) v11=a*b;
  v11=NormalizeDouble(v11,4);  
 
  shift=iBarShift(NULL,TF2,time2,false); 
  close=iClose(NULL,TF2,shift);

//  bh=iCustom(NULL,TF2,ciBands,TF2_BBPeriod,TF2_Shift,TF2_StdDeviation,1,shift);
//  bl=iCustom(NULL,TF2,ciBands,TF2_BBPeriod,TF2_Shift,TF2_StdDeviation,2,shift);

  bh=myBands(TF2,TF2_BBPeriod,TF2_Shift,TF2_Price,TF2_StdDeviation,1,shift);
  bl=myBands(TF2,TF2_BBPeriod,TF2_Shift,TF2_Price,TF2_StdDeviation,2,shift);

  a=close-bl;
  b=1.0/(bh-bl);

  if(bl!=bh) v12=a*b;
  v12=NormalizeDouble(v12,4);  
 
  if(v01>LevelLow && (v12<LevelLow && v11>LevelLow))  trigL=true;
  if(v11>LevelLow && (v02<LevelLow && v01>LevelLow))  trigL=true;   
  if(v01<LevelHigh&& (v12>LevelHigh&& v11<LevelHigh)) trigS=true;
  if(v11<LevelHigh&& (v02>LevelHigh&& v01<LevelHigh)) trigS=true;
  if(v01>LevelHigh&& (v12<LevelHigh&& v11>LevelHigh)) trigLR=true;
  if(v11>LevelHigh&& (v02<LevelHigh&& v01>LevelHigh)) trigLR=true;
  if(v01<LevelLow && (v12>LevelLow && v11<LevelLow))  trigSR=true;
  if(v11<LevelLow && (v02>LevelLow && v01<LevelLow))  trigSR=true;

 }
 else
 {
  v01=iCustom(NULL,0,ciMTFDBP,LevelHigh,LevelLow,TF1_BBPeriod,TF1_Shift,TF1_Price,TF1_StdDeviation,TF2_BBPeriod,TF2_Shift,TF2_Price,TF2_StdDeviation,TF1,TF2,2,1);
  v02=iCustom(NULL,0,ciMTFDBP,LevelHigh,LevelLow,TF1_BBPeriod,TF1_Shift,TF1_Price,TF1_StdDeviation,TF2_BBPeriod,TF2_Shift,TF2_Price,TF2_StdDeviation,TF1,TF2,3,1);
  v11=iCustom(NULL,0,ciMTFDBP,LevelHigh,LevelLow,TF1_BBPeriod,TF1_Shift,TF1_Price,TF1_StdDeviation,TF2_BBPeriod,TF2_Shift,TF2_Price,TF2_StdDeviation,TF1,TF2,4,1);
  v12=iCustom(NULL,0,ciMTFDBP,LevelHigh,LevelLow,TF1_BBPeriod,TF1_Shift,TF1_Price,TF1_StdDeviation,TF2_BBPeriod,TF2_Shift,TF2_Price,TF2_StdDeviation,TF1,TF2,5,1);
 
  if(v01!=EMPTY_VALUE) trigL=true;
  if(v02!=EMPTY_VALUE) trigS=true;
  if(v11!=EMPTY_VALUE) trigLR=true;
  if(v12!=EMPTY_VALUE) trigSR=true;   
 } 
 return;
}
//+------------------------------------------------------------------+
void ManageOrders()
{
 for(int j=0;j<Nlots;j++) {NL[j]=0;NS[j]=0;}
 double profit=0;
 int i,trail,trade,trades=OrdersTotal(); 
 int mn;
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
 
  mn=OrderMagicNumber();

  for(j=0;j<Nlots;j++)
  {
   if(mn==magic[j])
   {
   
    if(OrderType()==OP_BUY)
    {
     NL[j]++; 
     
     if(CloseContrary)
     {
      if(mn==magic[0]||mn==magic[1])
      {
       if(LongExit) 
       {
        ExitOrder(true,false);    
        NL[j]--;
       }
      }
     }
    }
    else if(OrderType()==OP_SELL)
    {
     NS[j]++;
     
     if(CloseContrary)
     {
      if(mn==magic[0]||mn==magic[1])
      {      
       if(ShortExit) 
       {
        ExitOrder(false,true);   
        NS[j]--;
       }
      }
     }
    }
   
    if(TrailStart>0) 
    {
     if(DetermineProfit()>NormPoints(TrailStart))
     {
      TrailingStop(TrailPips);
     }
    }   
     
   }
  }

 } 
 return;
}
//+------------------------------------------------------------------+
bool Filter(bool long)
{
 int Trigger[0], totN=0, i,j;
 double value1;
 
 for(i=0;i<totN;i++) Trigger[i]=-1;

 if(long) // long filters
 {
  for(i=0;i<totN;i++)
  {
   switch(i)
   { 
    case 0:
     Trigger[i]=1;
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
     Trigger[i]=1;
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
 if(take<=0) return(0.0);

 return(NormDigits(price+NormPoints(take))); 
}
//+------------------------------------------------------------------+
double TakeShort(double price,int take)  // function to calculate takeprofit if short
{
 if(take<=0) return(0.0); // if no take profit
 return(NormDigits(price-NormPoints(take))); 
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
  CloseOrderLong(OrderTicket(),OrderLots(),Slippage,Lime);
 else if(OrderType()==OP_SELL&&flag_Short)
  CloseOrderShort(OrderTicket(),OrderLots(),Slippage,Lime);
 return;
}
//+------------------------------------------------------------------+
void Message(string type, double price, double va, double vb)
{
 string td=TimeToStr(iTime(NULL,0,0),TIME_DATE|TIME_MINUTES);
 string message=StringConcatenate(Symbol()," ",type," at price=",price," at ",td,". TF1%B=",va," TF2%B=",vb);
 SendMail(TextHeader,message);
 Alert(message);
}
//+------------------------------------------------------------------+
bool noRun(int flag)
{
 switch(flag)
 {
  case 1:
   if(TimeCurrent()>ExpirationDate) return(true);
   else return(false);
  break;
  case 2:
   if(AccNumber>0 && AccountNumber()!=AccNumber) return(true);
   else return(false);
  break;
  case 3:
   if(DemoOnly && !IsDemo()) return(true);
   else return(false);
  break;
 } 
 return(false);
}
//+------------------------------------------------------------------+
bool BlackOuts()
{
 int i;

 if(AccountFreeMargin()<FreeMargin_Limit) return(true);

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
 
 int thisday=Day(); 
 int thismonth=Month();
 int thisyear=Year();

 for(i=0;i<3;i++)
 {
  if(thisyear==TimeYear(bodates[i])&&thismonth==TimeMonth(bodates[i])&&thisday==TimeDay(bodates[i]))
   return(true);
 }

 thisday=DayOfWeek();
 if(thisday==NoTradeDay1 || thisday==NoTradeDay2) return(true);
  
 if(NormDigits(Ask-Bid)>=NormPoints(SpreadNoTrade)) return(true); 
  
 return(false);
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
double myBands(int tf,int period,int mashift,int price,double dev,int mode,int shift)
{
 int i,method=MODE_SMA;
 double sd=0.0, v1, bb, deviation;
 double ma=iMA(NULL,tf,period,mashift,method,price,shift);
 
 for(i=shift;i<=shift+period-1;i++)
 {
  v1=iClose(NULL,tf,i)-ma; 
  sd+=MathPow(v1,2);
 }
 sd/=period;
 deviation=MathSqrt(sd);
 deviation*=dev;
 
 switch(mode)
 {
  case 1: bb=ma+deviation; break;
  case 2: bb=ma-deviation; break;
 }
 bb=NormDigits(bb);
 return(bb);
}
//+------------------------------------------------------------------+


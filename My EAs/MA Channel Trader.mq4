//+----------------------------------------------------------------------+
//|                                                MA Channel Trader.mq4 |
//|                                                         David J. Lin |
//| MA Channel Trader                                                    |
//| written for Suresh Sundaram (sureshst_31@yahoo.com)                  |
//|                                                                      |
//|Coded by David J. Lin                                                 |
//|dave.j.lin@sbcglobal.net                                              |
//|Evanston, IL, February 2, 2008                                        |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2008 Suresh Sundaram & David J. Lin"

//---- user adjustable parameters
extern int MAPeriod1=40;             // MA Channel
extern int MAShift1=0;
extern int MAMethod1=MODE_SMA;
extern int MAPrice1a=PRICE_HIGH;
extern int MAPrice1b=PRICE_LOW;

extern int MAPeriod2=15;             // MA Filter Line
extern int MAShift2=0;
extern int MAMethod2=MODE_EMA;
extern int MAPrice2=PRICE_CLOSE;

extern int MAChannelLimit=80;        // pips MA Channel distance limit:  if close exceeds this number of pips from closest MA channel line, don't trade

extern double Lots1=0.01;            // lottage per trade O1
extern double Lots2=0.01;            // lottage per trade O2 (use negative number if no extra lot is desired)
extern double Lots3=0.01;            // lottage per trade O3 (use negative number if no extra lot is desired)
extern double Lots4=0.01;            // lottage per trade O4 (use negative number if no extra lot is desired)
extern double Lots5=0.01;            // lottage per trade O5 (use negative number if no extra lot is desired)

extern int TakeProfit1=-1;           // pips desired TP O1 (use negative number if no TP is desired)
extern int TakeProfit2=-1;           // pips desired TP O2 (use negative number if no TP is desired)
extern int TakeProfit3=-1;           // pips desired TP O3 (use negative number if no TP is desired)
extern int TakeProfit4=-1;           // pips desired TP O4 (use negative number if no TP is desired)
extern int TakeProfit5=-1;           // pips desired TP O5 (use negative number if no TP is desired)

extern int StopLoss=-1;              // pips desired SL (use negative number if no SL is desired)
extern int TrailStart=-1;            // pips profit after which to trail stop by TrailPips (use negative number if not desired)
extern int TrailPips=-1;             // pips desired trailing stop, engages after TrailStart is hit 

extern int MaxNumberTrades=1;        // maximum number of trades open simultaneously

extern bool CloseContrary=true;      // true = close all lots upon contrary entry; false = don't close any orders upon contrary entry

extern int NoTradeDay1=-1;           // no trade on this day of week (0=Sunday, 5=Friday, negative=off)
extern int NoTradeDay2=-1;           // no trade on this day of week (0=Sunday, 5=Friday, negative=off)

extern int NoTradeHourStart=-1;      // platform time inclusive (use negative value to turn off)
extern int NoTradeHourEnd=-1;        // platform time inclusive (use negative value to turn off)

extern datetime NoTradeCalendarDate1=D'2008.12.25'; // no trade on these calender dates
extern datetime NoTradeCalendarDate2=D'2009.01.01';
extern datetime NoTradeCalendarDate3=D'2009.12.25';

extern int SpreadNoTrade=10;  // if spreads equal or exceed this value, don't enter new orders

extern double FreeMargin_Limit=100;  // no trade if free margin dips below this value (dollars)

extern bool MessageAlert=false;      // toggle on to send email & screen messages to alert order entry

// Internal usage parameters:

datetime ExpirationDate=D'2020.12.31'; // EA does not function after this date 
int AccNumber=-1;                      // EA functions only for this account number (set to negative number if this filter is not desired)
bool DemoOnly=false;                   // if set to true, EA functions only in demo accounts 

int Slippage=3,bo=1;
int lotsprecision=2,Nlots=5;
double lotsmin,lotsmax;
bool LongExit,ShortExit,trigL,trigS,exitL,exitS;
datetime lasttime,ot;
double v01,v02,v11,v12;
string comment[];
int NL[],NS[],magic[],TakeProfit[];
double Lots[];
datetime bodates[];
color clrL=Blue,clrS=Red;
string strL="Long",strS="Short";
int code=1;
string TextHeader="MA Channel Alert!!"; // header of email message 
bool MAFilterLineLock=true; // only 1 entry per occurance of MA Filter Line in MA Channel
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
 
 bodates[0]=NoTradeCalendarDate1;
 bodates[1]=NoTradeCalendarDate2;
 bodates[2]=NoTradeCalendarDate3;  
 
 lotsmin=MarketInfo(Symbol(),MODE_MINLOT); 
 lotsmax=MarketInfo(Symbol(),MODE_MAXLOT);

 if(lotsmin==0.10) lotsprecision=1;
 
 Lots[0]=Lots1;Lots[1]=Lots2;Lots[2]=Lots3;Lots[3]=Lots4;Lots[4]=Lots5;
 TakeProfit[0]= TakeProfit1;TakeProfit[1]=TakeProfit2;TakeProfit[2]=TakeProfit3;TakeProfit[3]=TakeProfit4;TakeProfit[4]=TakeProfit5;
 magic[0]=11001;magic[1]=11002;magic[2]=11003;magic[3]=11004;magic[4]=11005;
 comment[0]="MAC1";comment[1]="MAC2";comment[2]="MAC3";comment[3]="MAC4";comment[4]="MAC5";

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
 MAFilterLineLock=true; // only 1 entry per occurance of MA Filter Line in MA Channel
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
 if(lasttime!=iTime(NULL,0,0))
 {
  Trigger();
  SubmitOrders();
 }
 AlertMode();
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
    if(MessageAlert) Message("Long",Ask);
    ShortExit=true;
    MAFilterLineLock=true;
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
    if(MessageAlert) Message("Short",Bid);       
    LongExit=true;
    MAFilterLineLock=true;    
    ot=TimeCurrent();
   }
  }
 }
 
 return;
}
//+------------------------------------------------------------------+
void Trigger()
{
 trigL=false;trigS=false;
 exitL=false;exitS=false;
 
 double mach1=iMA(NULL,0,MAPeriod1,MAShift1,MAMethod1,MAPrice1a,1);   
 double macl1=iMA(NULL,0,MAPeriod1,MAShift1,MAMethod1,MAPrice1b,1);
 double mach2=iMA(NULL,0,MAPeriod1,MAShift1,MAMethod1,MAPrice1a,2);   
 double macl2=iMA(NULL,0,MAPeriod1,MAShift1,MAMethod1,MAPrice1b,2); 
 double maf1=iMA(NULL,0,MAPeriod2,MAShift2,MAMethod2,MAPrice2,1); 
 double maf2=iMA(NULL,0,MAPeriod2,MAShift2,MAMethod2,MAPrice2,2);
 double open1=iOpen(NULL,0,1);
 double close1=iClose(NULL,0,1); 
 double open2=iOpen(NULL,0,2);
 double close2=iClose(NULL,0,2); 
 double distance;

 if(close1<macl1) exitL=true;
 if(close1>mach1) exitS=true;
 if(maf2>mach2&&maf1<mach1) exitL=true;
 if(maf2<macl2&&maf1>macl1) exitS=true;
 
 if(maf1<mach1&&maf1>macl1) MAFilterLineLock=false;
 
 if(MAFilterLineLock) return;
 
 if(maf1>mach1)
 {
  if(close1>mach1 && open1>mach1)
  {  
   distance=NormDigits(close1-mach1-NormPoints(MAChannelLimit)); 
   if(distance<0) 
   {   
    if(maf1>maf2) trigL=true;
   }
  }
 }
 
 if(maf1<macl1)
 { 
  if(close1<macl1 && open1<macl1)
  {
   distance=NormDigits(macl1-close1-NormPoints(MAChannelLimit)); 
   if(distance<0) 
   { 
    if(maf1<maf2) trigS=true;
   }
  }
 }
 

 
 return;
}
//+------------------------------------------------------------------+
void AlertMode()
{
 double mach1=iMA(NULL,0,MAPeriod1,MAShift1,MAMethod1,MAPrice1a,0);   
 double macl1=iMA(NULL,0,MAPeriod1,MAShift1,MAMethod1,MAPrice1b,0);

 if(Bid<mach1 && Bid>macl1)
 {
  double maf1=iMA(NULL,0,MAPeriod2,MAShift2,MAMethod2,MAPrice2,0); 
  double maf2=iMA(NULL,0,MAPeriod2,MAShift2,MAMethod2,MAPrice2,1); 
  
  if(maf1>maf2) Comment("Bid inside MA Channel, looking for long.");
  else          Comment("Bid inside MA Channel, looking for short.");
 }
 else Comment("Bid is outside of MA Channel.");
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
      if(LongExit) 
      {
       ExitOrder(true,false);    
       NL[j]--;
      }
     }
     
     if(exitL)
     {
      ExitOrder(exitL,exitS);     
      NL[j]--;
     }
          
    }
    else if(OrderType()==OP_SELL)
    {
     NS[j]++;
     
     if(CloseContrary)
     {     
      if(ShortExit) 
      {
       ExitOrder(false,true);   
       NS[j]--;
      }
     }
     
     if(exitS)
     {
      ExitOrder(exitL,exitS);     
      NS[j]--;
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
void Message(string type, double price)
{
 string td=TimeToStr(iTime(NULL,0,0),TIME_DATE|TIME_MINUTES);
 string message=StringConcatenate(Symbol()," ",type," at price=",price," at ",td,".");
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



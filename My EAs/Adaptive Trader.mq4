//+----------------------------------------------------------------------+
//|                                                  Adaptive Trader.mq4 |
//|                                                         David J. Lin |
//|                                                                      |
//|Based on the adaptive indicators (MAMA, FAMA, FRAMA) by Dr. J. Ehlers |
//|Written for Jason (soeasy69@rogers.com)                               |
//|                                                                      |
//|Coded by David J. Lin (dave.j.lin@sbcglobal.net)                      |                                      |
//|Evanston, IL, July 25, 2007                                           |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2007, David J. Lin"
#property link      ""

// User adjustable parameters:
extern double Lots = 0.01;       // use negative whole numbers for percentage of margin (e.g. -20 for 20% margin per trade)
extern int  StopLoss=0;
extern int  TakeProfit=0;    
extern int  TrailStop=0;  
extern bool UseMAMA=true;     // true=use MAMA, false=use FRAMA
extern int  CrossDelay=2;

extern bool Trade_US=true;
extern int  US_Start_Hour=15;
extern int  US_Start_Minute=0;
extern int  US_Stop_Hour=19;
extern int  US_Stop_Minute=00;
extern bool Trade_Asian=false;
extern int  Asian_Start_Hour=0;
extern int  Asian_Start_Minute=0;
extern int  Asian_Stop_Hour=7;
extern int  Asian_Stop_Minute=0;
extern bool Trade_Europe=true;
extern int  Europe_Start_Hour=7;
extern int  Europe_Start_Minute=0;
extern int  Europe_Stop_Hour=15;
extern int  Europe_Stop_Minute=0;

// MAMA indicator parameters
extern double MAMAFastLimit = 0.5;
extern double MAMASlowLimit = 0.05;
int    MAMAmaxbars=5000;

// FRAMA indicator parameters

int FRAMA_N=16;    // should be an even integer

// Internal usage parameters:
int Slippage=3,bo=1,ot;
int lotsprecision=2,magic;
double lotsmin,lotsmax,rMargin,PercentMargin,Profit;
bool LongOrder,ShortOrder,Margin=false;
bool LongExit,ShortExit;
string comment="Adaptive";
string ciMAMA="MAMA";
string ciFRAMA="FRAMA";
bool AlertAlarm=true,AlertEmail=true;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//---- 
 lotsmin=MarketInfo(Symbol(),MODE_MINLOT); 
 lotsmax=MarketInfo(Symbol(),MODE_MAXLOT);
 rMargin=MarketInfo(Symbol(),MODE_MARGINREQUIRED);

 if(lotsmin==0.10) lotsprecision=1;
 if(Lots==0) Lots=lotsmin;
 
 if(Lots<0) 
 {
  Lots=MathAbs(Lots);
  PercentMargin=0.01*Lots;
  Margin=true;
 } 
 
 magic=13197144+Period();

 if(Symbol()=="#EPU7" || Symbol()=="SPSEP7" || Symbol()=="S&P500")
 {
  StopLoss*=25;
  TakeProfit*=25;
  TrailStop*=25;  
 }
 
 HideTestIndicators(true);

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
 ManageOrders();
 SubmitOrders();
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert utility functions                                         |
//+------------------------------------------------------------------+

void SubmitOrders()
{
 double SL,TP;
 
 LongExit=false; ShortExit=false;

 if(StopLoss>0)
 {
  if(Profit<0)
  {
   if(!LongOrder || !ShortOrder) return;
  }
 }
   
 int i,checktime=iBarShift(NULL,0,ot,false);

 if(checktime<bo) return;
 
 double lots; string message;
  
 if(LongOrder)
 {
  if(Trigger(true))
  {
   if(Filter(true))
   {  
    if(Margin) lots=DetermineLots();
    else lots=Lots;  
    SL=StopLong(Ask,StopLoss);
    TP=TakeLong(Ask,TakeProfit);
    SendOrderLong(Symbol(),lots,Slippage,SL,TP,comment,magic,0,Blue);
    ot=TimeCurrent();
    if (AlertAlarm||AlertEmail)
    {
     message=StringConcatenate(Symbol()," Adaptive Trader Long Entry at Ask=",DoubleToStr(Ask,Digits),", SL=",DoubleToStr(SL,Digits)," TP=",DoubleToStr(TP,Digits)," at ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES));
     SendMessage(message);
    }    
   }
   ShortExit=true;
  }
 }
 
 if(ShortOrder)
 {
  if(Trigger(false))
  { 
   if(Filter(false))
   { 
    if(Margin) lots=DetermineLots();
    else lots=Lots;
    SL=StopShort(Bid,StopLoss);
    TP=TakeShort(Bid,TakeProfit); 
    SendOrderShort(Symbol(),lots,Slippage,SL,TP,comment,magic,0,Red);     
    ot=TimeCurrent();
    if (AlertAlarm||AlertEmail)
    {
     message=StringConcatenate(Symbol()," Adaptive Trader Short Entry at Bid=",DoubleToStr(Bid,Digits),", SL=",DoubleToStr(SL,Digits)," TP=",DoubleToStr(TP,Digits)," at ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES));
     SendMessage(message);
    }     
   }
   LongExit=true;
  }
 }
 
 return;
}

//+------------------------------------------------------------------+

void ManageOrders()
{
 LongOrder=true;ShortOrder=true;
 
 int i,j,trail,trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  
  if(OrderMagicNumber()!=magic) continue;
  
  if(OrderType()==OP_BUY)
  {
   LongOrder=false;     
   if(LongExit) 
   {
    ExitOrder(true,false);    
    LongOrder=true;
   }
  }
  else if(OrderType()==OP_SELL)
  {
   ShortOrder=false;
   if(ShortExit) 
   {
    ExitOrder(false,true);   
    ShortOrder=true;
   }
  }
  
  TrailStop(TrailStop);
  Profit=DetermineProfit();
  
 } 
 return;
}

//+------------------------------------------------------------------+
bool Filter(bool long)
{
 int Trigger[1], totN=1, i;
 
 for(i=0;i<totN;i++) Trigger[i]=-1;

 if(long) // long filters
 {
  for(i=0;i<totN;i++)
  {
   switch(i)
   { 
    case 0:
     if(TimeFilter()) Trigger[i]=1;
     break;  
   }
  }
 }
 else // short filters
 {
  for(i=0;i<totN;i++)
  { 
   switch(i)
   {  
    case 0:
     if(TimeFilter()) Trigger[i]=1;    
     break;                         
   } 
  }
 }
  
 for(i=0;i<totN;i++) 
  if(Trigger[i]<0) return(false); // one anti-trigger is sufficient to not trigger at all, so return false (to order)

 return(true);  // no anti-trigger:  so, return true (to order)
}

//+------------------------------------------------------------------+

int SendOrderLong(string sym, double vol, int slip, double sl, double tp, string comment="", int m=0, datetime exp=0, color cl=CLR_NONE)
{ 
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
 return;
}
//+------------------------------------------------------------------+

int SendOrderShort(string sym, double vol, int slip, double sl, double tp, string comment="", int m=0, datetime exp=0, color cl=CLR_NONE)
{  
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
 return;
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
 return;
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
 return;
} 
//+------------------------------------------------------------------+
double TakeLong(double price,int take)
{
 if(take==0)
  return(0.0); // if no take profit

 return(NormDigits(price+NormPoints(take))); 
}
//+------------------------------------------------------------------+
double TakeShort(double price,int take) 
{
 if(take==0)
  return(0.0); // if no take profit

 return(NormDigits(price-NormPoints(take))); 
}

//+------------------------------------------------------------------+
double StopLong(double price,int stop)
{
 if(stop==0)
  return(0.0); // if no stop loss
 return(NormDigits(price-NormPoints(stop))); 
}

//+------------------------------------------------------------------+
double StopShort(double price,int stop)
{
 if(stop==0)
  return(0.0); // if no stop loss
 return(NormDigits(price+NormPoints(stop))); 
}
//+------------------------------------------------------------------+
double TrailLong(double price,int trail)
{
 return(price-NormPoints(trail)); 
}
//+------------------------------------------------------------------+
double TrailShort(double price,int trail)
{
 return(price+NormPoints(trail)); 
}
//+------------------------------------------------------------------+
void TrailStop(int TS)
{
 if(TS<=0) return;
 
 double stopcrnt,stopcal; 
 double profit;
 
 stopcrnt=OrderStopLoss();

//Long               
 if(OrderType()==OP_BUY)
 {
  stopcal=TrailLong(Bid,TS);
  ModifyCompLong(stopcal,stopcrnt);    
 }    
//Short 
 if(OrderType()==OP_SELL)
 {  
  stopcal=TrailShort(Ask,TS);
  ModifyCompShort(stopcal,stopcrnt);
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
 return;
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
 return(MathMax(NormalizeDouble(lotsmin,lotsprecision),NormalizeDouble(lots,lotsprecision)));
}
//+------------------------------------------------------------------+
double DetermineLots()
{
 double pMargin=PercentMargin*AccountFreeMargin();
 double lots=pMargin/rMargin;
 if(lots<lotsmin) return(lotsmin);
 else if(lots>lotsmax) return(lotsmax);
 return(lots);
}
//+------------------------------------------------------------------+
double DetermineProfit()
{
 if(OrderType()==OP_BUY)  
  return(Bid-OrderOpenPrice());
 else if(OrderType()==OP_SELL)
  return(OrderOpenPrice()-Ask); 
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
bool Trigger(bool long)
{
 int i; double sig0,sigX,base0,baseX;

 if(UseMAMA)
 {
  sig0=iCustom(NULL,0,ciMAMA,MAMAFastLimit,MAMASlowLimit,MAMAmaxbars,0,1);
  sigX=iCustom(NULL,0,ciMAMA,MAMAFastLimit,MAMASlowLimit,MAMAmaxbars,0,CrossDelay);
 }
 else
 {
  sig0=iCustom(NULL,0,ciFRAMA,FRAMA_N,0,1);
  sigX=iCustom(NULL,0,ciFRAMA,FRAMA_N,0,CrossDelay);
 }

 base0=iCustom(NULL,0,ciMAMA,MAMAFastLimit,MAMASlowLimit,MAMAmaxbars,1,1);
 baseX=iCustom(NULL,0,ciMAMA,MAMAFastLimit,MAMASlowLimit,MAMAmaxbars,1,CrossDelay);

 if(long)
 {
  if(sig0>base0&&sigX<=baseX)
  {

   if(sigX==baseX) // in case of hugging lines
   {

    for(i=CrossDelay+1;i<=100;i++)
    {
     if(UseMAMA) sig0=iCustom(NULL,0,ciMAMA,MAMAFastLimit,MAMASlowLimit,MAMAmaxbars,0,i);
     else        sig0=iCustom(NULL,0,ciFRAMA,FRAMA_N,0,i);
    
     base0=iCustom(NULL,0,ciMAMA,MAMAFastLimit,MAMASlowLimit,MAMAmaxbars,1,i);     
  
     if(sig0>base0) return(false);
     else if(sig0<base0) break;
    }
    
   }
   
   for(i=1;i<CrossDelay;i++)
   {
    if(UseMAMA) sig0=iCustom(NULL,0,ciMAMA,MAMAFastLimit,MAMASlowLimit,MAMAmaxbars,0,i);
    else        sig0=iCustom(NULL,0,ciFRAMA,FRAMA_N,0,i);
    
    base0=iCustom(NULL,0,ciMAMA,MAMAFastLimit,MAMASlowLimit,MAMAmaxbars,1,i);   
    if(sig0<base0) return(false);
   }
   return(true);
  }
 }
 else 
 {
  if(sig0<base0&&sigX>=baseX)
  {
  
   if(sigX==baseX) // in case of hugging lines
   {

    for(i=CrossDelay+1;i<=100;i++)
    {
     if(UseMAMA) sig0=iCustom(NULL,0,ciMAMA,MAMAFastLimit,MAMASlowLimit,MAMAmaxbars,0,i);
     else        sig0=iCustom(NULL,0,ciFRAMA,FRAMA_N,0,i);
    
     base0=iCustom(NULL,0,ciMAMA,MAMAFastLimit,MAMASlowLimit,MAMAmaxbars,1,i);     
  
     if(sig0<base0) return(false);
     else if(sig0>base0) break;
    }
    
   }
  
   for(i=1;i<CrossDelay;i++)
   {
    if(UseMAMA) sig0=iCustom(NULL,0,ciMAMA,MAMAFastLimit,MAMASlowLimit,MAMAmaxbars,0,i);
    else        sig0=iCustom(NULL,0,ciFRAMA,FRAMA_N,0,i);
   
    base0=iCustom(NULL,0,ciMAMA,MAMAFastLimit,MAMASlowLimit,MAMAmaxbars,1,i);   
    if(sig0>base0) return(false);
   } 
   return(true);
  }
 }
 return(false);
}
//+------------------------------------------------------------------+
bool TimeFilter()
{
 int hour=Hour(),min=Minute();

 if(Trade_Asian) 
 {
  if(hour>=Asian_Start_Hour && min>=Asian_Start_Minute)
  {
   if(hour<=Asian_Stop_Hour)
   {
    if(hour<Asian_Stop_Hour) return(true);
    else if(hour==Asian_Stop_Hour && min<=Asian_Stop_Minute) return(true);
   }
  }
 }

 if(Trade_Europe) 
 {
  if(hour>=Europe_Start_Hour && min>=Europe_Start_Minute)
  {
   if(hour<=Europe_Stop_Hour)
   {
    if(hour<Europe_Stop_Hour) return(true);
    else if(hour==Europe_Stop_Hour && min<=Europe_Stop_Minute) return(true);
   }
  }
 }

 if(Trade_US) 
 {
  if(hour>=US_Start_Hour && min>=US_Start_Minute)
  {
   if(hour<=US_Stop_Hour)
   {
    if(hour<US_Stop_Hour) return(true); 
    else if(hour==US_Stop_Hour && min<=US_Stop_Minute) return(true); 
   }
  }
 }
 
 return(false);
} 
//+------------------------------------------------------------------+
void SendMessage(string message)
{
 if (AlertAlarm) Alert(message);
 if (AlertEmail) SendMail("Adaptive Trader Alert!",message);
 return;
}


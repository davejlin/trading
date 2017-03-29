//+----------------------------------------------------------------------+
//|                                        InsideBar BreakOut Trader.mq4 |
//|                                                         David J. Lin |
//|BreakOut based on 1 MasterBar & 4 InsideBars range                    |
//|Written for Jason Hughes <Jasonhughes3@aol.com>                       |
//|                                                                      |
//|Coded by David J. Lin (dave.j.lin@sbcglobal.net)                      |
//|Evanston, IL, November 28, 2007                                       |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2007, Jason Hughes & David J. Lin"
#property link      ""

// User adjustable parameters:
extern int TakeProfit=70;            // pips desired TP (use negative number if no TP is desired)
extern int StopLoss=30;              // pips desired SL (use negative number if no SL is desired)
extern int SLProfit=-1;              // pips profit after which to move SL  (use negative number if not desired)
extern int SLMove=0;                 // pips to move SL to BE+SLMove after SLProfit is reached
extern bool FixedLots =true;         // true = use fixed number of lottage as specified by FixedLottage, false = use PercentRisk
extern double FixedLottage =0.01;    // fixed number of lots per trade (used if FixedLots=true)
extern double PercentRisk =0.010;    // percentage of account balance at risk per trade (used if FixedLots=false)

extern bool Trade_Asian=true;
extern int  Asian_Start_Hour=0;
extern int  Asian_Start_Minute=0;
extern int  Asian_Stop_Hour=7;
extern int  Asian_Stop_Minute=59;
extern bool Trade_Europe=true;
extern int  Europe_Start_Hour=8;
extern int  Europe_Start_Minute=0;
extern int  Europe_Stop_Hour=15;
extern int  Europe_Stop_Minute=59;
extern bool Trade_US=true;
extern int  US_Start_Hour=16;
extern int  US_Start_Minute=0;
extern int  US_Stop_Hour=23;
extern int  US_Stop_Minute=59;

double RangeBuffer=4;                // pips the inside bar can exceed master bar

// Internal usage parameters:
int Slippage=3,bo=5,magic1=432101,magic2=432102;
int lotsprecision=2;
double lotsmin,lotsmax;
bool Order;
bool LongTrigger=false,ShortTrigger=false,FSFlag=false;
string comment1="IBBO Primary",comment2="IBBO Secondary";
color clrL=Blue,clrS=Red;
string strL="Long",strS="Short";
string RangeHiName,RangeLoName,ExitTimeName,LongTriggerName,ShortTriggerName,FSFlagName;
double RangeHi,RangeLo;
double RangeHiDefault=0,RangeLoDefault=9999;
int code=1;
int Norders;
datetime lasttime,etime;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//----

 lotsmin=MarketInfo(Symbol(),MODE_MINLOT); 
 lotsmax=MarketInfo(Symbol(),MODE_MAXLOT);

 if(lotsmin==0.10) lotsprecision=1;

// Now check open orders
                       
 int trade,trades=OrdersTotal();           
 for(trade=0;trade<trades;trade++)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()!=Symbol())
   continue;

  if(OrderType()==OP_BUY)       DrawCross(OrderOpenPrice(),OrderOpenTime(),strL,clrL,code);
  else if(OrderType()==OP_SELL) DrawCross(OrderOpenPrice(),OrderOpenTime(),strS,clrS,code);
 }
 
 HideTestIndicators(true);
 ManageOrders();
 
 RangeHiName=StringConcatenate("IBBO_",Symbol(),"_RangeHi");
 RangeLoName=StringConcatenate("IBBO_",Symbol(),"_RangeLo");
 ExitTimeName=StringConcatenate("IBBO_",Symbol(),"_ExitTimeName"); 
 LongTriggerName=StringConcatenate("IBBO_",Symbol(),"_LongTrigger");
 ShortTriggerName=StringConcatenate("IBBO_",Symbol(),"_ShortTrigger"); 
 FSFlagName=StringConcatenate("IBBO_",Symbol(),"_FSFlag"); 
 
 if(!GlobalVariableCheck(RangeHiName)) GlobalVariableSet(RangeHiName,RangeHiDefault);
 if(!GlobalVariableCheck(RangeLoName)) GlobalVariableSet(RangeLoName,RangeLoDefault);
 if(!GlobalVariableCheck(ExitTimeName)) GlobalVariableSet(ExitTimeName,etime);
 if(!GlobalVariableCheck(LongTriggerName)) GlobalVariableSet(LongTriggerName,0);
 if(!GlobalVariableCheck(ShortTriggerName)) GlobalVariableSet(ShortTriggerName,0);
 if(!GlobalVariableCheck(FSFlagName)) GlobalVariableSet(FSFlagName,0);
   
 RangeHi=GlobalVariableGet(RangeHiName);
 RangeLo=GlobalVariableGet(RangeLoName);
 etime=GlobalVariableGet(ExitTimeName);
 LongTrigger=GlobalVariableGet(LongTriggerName);
 ShortTrigger=GlobalVariableGet(ShortTriggerName); 
 FSFlag=GlobalVariableGet(FSFlagName);  
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
 TriggerOrders(); 
 SubmitOrders();
 ManageOrders();
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert utility functions                                         |
//+------------------------------------------------------------------+

void SubmitOrders()
{     
 if(!Order) return;

 if(RangeHi==RangeHiDefault && RangeLo==RangeLoDefault) return;

 double lots,SL,TP; 

 if(LongTrigger)
 {
  double RangeHi2=NormDigits(RangeHi+NormPoints(2));
  if(Bid>RangeHi&&Bid<RangeHi2)
  {
   if(TimeFilter())
   {
    SL=StopLong(Ask,StopLoss); // needed for lottage, but use 0 for internal monitoring
    lots=DetermineLots(Ask,SL,1);    
    TP=TakeLong(Ask,TakeProfit); // tp internally monitored
    SendOrderLong(Symbol(),lots,Slippage,0,0,comment1,magic1,0,Blue);
    LongTrigger=false;
    GlobalVariableSet(LongTriggerName,LongTrigger);   
    FSFlag=false;
    GlobalVariableSet(FSFlagName,FSFlag);    
    return;
   }
  }
 } 

 if(ShortTrigger)
 { 
  double RangeLo2=NormDigits(RangeLo-NormPoints(2));
  if(Bid<RangeLo&&Bid>=RangeLo2)
  {  
   if(TimeFilter())
   {  
    SL=StopShort(Bid,StopLoss); // needed for lottage, but use 0 for internal monitoring
    lots=DetermineLots(SL,Bid,1);     
    TP=TakeShort(Bid,TakeProfit); // tp internally monitored
    SendOrderShort(Symbol(),lots,Slippage,0,0,comment1,magic1,0,Red);  
    ShortTrigger=false;
    GlobalVariableSet(ShortTriggerName,ShortTrigger); 
    FSFlag=false;  
    GlobalVariableSet(FSFlagName,FSFlag);        
    return;
   }
  }
 }
 
 return;
}

//+------------------------------------------------------------------+

void TriggerOrders()
{
 if(!Order) return;

 if(lasttime==iTime(NULL,0,0)) return;
 lasttime=iTime(NULL,0,0); 
 
 int checktime=iBarShift(NULL,0,etime,false);
 if(checktime<bo) return;
 
 double high[5],low[5]; int i;

 for(i=0;i<5;i++)
 {
  high[i]=iHigh(NULL,0,i+1);
  low[i]=iLow(NULL,0,i+1);
 }
  
 double rangehigh=NormDigits(high[4]+NormPoints(RangeBuffer));
 double rangelow =NormDigits(low[4]-NormPoints(RangeBuffer));
  
 int N=0; 
 double highest=RangeHiDefault,lowest=RangeLoDefault;
 for(i=0;i<4;i++)
 {
  if(high[i]>rangehigh) break;
  if(low[i]<rangelow)   break;
  if(high[i]>highest)   highest=high[i];
  if(low[i]<lowest)     lowest=low[i];
  N++;
 }
 
 if(N==4) // new inside bar formation
 {
  if(!LongTrigger&&!ShortTrigger)
  {
   LongTrigger=true;
   ShortTrigger=true;
   GlobalVariableSet(LongTriggerName,LongTrigger);   
   GlobalVariableSet(ShortTriggerName,ShortTrigger);      
   datetime time1=iTime(NULL,0,1);
   datetime time2=iTime(NULL,0,4); 
   RangeHi=highest;
   RangeLo=lowest;
   GlobalVariableSet(RangeHiName,RangeHi);
   GlobalVariableSet(RangeLoName,RangeLo);

   string name = StringConcatenate("BO Box",TimeYear(time1),".",TimeMonth(time1),".",TimeDay(time1),".",TimeHour(time1),".",TimeMinute(time1));
   if (!ObjectCreate(name,OBJ_RECTANGLE,0,time1,RangeLo,time2,RangeHi,0,0))
   {
    Print("MT4 error: cannot draw the rectangle. Error ",GetLastError());
   }
   else
   {
    ObjectSet(name,OBJPROP_COLOR,NavajoWhite);
   }
  }
 }  
 return;  
}

//+------------------------------------------------------------------+

void ManageOrders()
{
 Order=true;
 int i,j,trail,trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;

  if(OrderMagicNumber()==magic1)
  { 
   Order=ManagePrimary();
  }
  else if(OrderMagicNumber()==magic2)
  {
   Order=ManageSecondary();   
  }
  
  if(!Order)
  {
   if(SLProfit>0) 
   {
    FixedStopsB(SLProfit,SLMove);
   }
  }
 } 
 return;
}
//+------------------------------------------------------------------+

bool ManagePrimary()
{
 double SL,TP,lots,profit=DetermineProfit();
 if(OrderType()==OP_BUY)
 {
  if(profit>=NormPoints(TakeProfit))
  {
   ExitOrder(true,false);
   etime=TimeCurrent(); 
   GlobalVariableSet(ExitTimeName,etime);     
   ResetParams();    
   return(true);
  }
  else if(profit<=-NormPoints(StopLoss)) 
  {
   ExitOrder(true,false);
   etime=TimeCurrent();   
   GlobalVariableSet(ExitTimeName,etime);    
   if(Bid<RangeHi&&Bid>RangeLo) // within range, wait for opposite trigger
   {
    return(true);
   }
   if(Bid<RangeLo) // outside of range, immediately reverse
   {
    SL=StopShort(Bid,StopLoss); // needed for lottage, but use 0 for internal monitoring
    lots=DetermineLots(SL,Bid,1);     
    TP=TakeShort(Bid,TakeProfit); // tp internally monitored
    SendOrderShort(Symbol(),lots,Slippage,0,0,comment2,magic2,0,Red); 
    ResetParams();      
    return(false); 
   }
  }
 }
 else if(OrderType()==OP_SELL)
 {
  if(profit>=NormPoints(TakeProfit))
  {
   ExitOrder(false,true);
   etime=TimeCurrent();   
   GlobalVariableSet(ExitTimeName,etime);    
   ResetParams();   
   return(true);   
  } 
  else if(profit<=-NormPoints(StopLoss)) 
  {
   ExitOrder(false,true);
   etime=TimeCurrent();   
   GlobalVariableSet(ExitTimeName,etime);    
   if(Bid<RangeHi&&Bid>RangeLo) // within range, wait for opposite trigger
   {
    return(true);
   }   
   if(Bid>RangeHi) // outside of range, immediately reverse
   {
    SL=StopLong(Ask,StopLoss); // needed for lottage, but use 0 for internal monitoring
    lots=DetermineLots(Ask,SL,1);     
    TP=TakeLong(Ask,TakeProfit); // tp internally monitored
    SendOrderLong(Symbol(),lots,Slippage,0,0,comment2,magic2,0,Blue);
    ResetParams();   
    return(false); 
   }
  }   
 }
 return(false);
}
//+------------------------------------------------------------------+

bool ManageSecondary()
{ 
 double SL,TP,lots,profit=DetermineProfit();
 if(OrderType()==OP_BUY)
 {
  if(profit>=NormPoints(TakeProfit))
  {
   ExitOrder(true,false);
   etime=TimeCurrent();  
   GlobalVariableSet(ExitTimeName,etime); 
   ResetParams();     
   return(true);
  }
  else if(profit<=-NormPoints(StopLoss)) 
  {
   ExitOrder(true,false);
   etime=TimeCurrent();   
   GlobalVariableSet(ExitTimeName,etime); 
   ResetParams();     
   return(true);   
  }
 }
 else if(OrderType()==OP_SELL)
 {
  if(profit>=NormPoints(TakeProfit))
  {
   ExitOrder(false,true);
   etime=TimeCurrent();   
   GlobalVariableSet(ExitTimeName,etime);    
   ResetParams();     
   return(true);   
  } 
  else if(profit<=-NormPoints(StopLoss)) 
  {
   ExitOrder(false,true);
   etime=TimeCurrent();   
   GlobalVariableSet(ExitTimeName,etime);
   ResetParams();   
   return(true);
  }   
 }
 return(false);
}
//+------------------------------------------------------------------+
void ResetParams()
{
 RangeHi=RangeHiDefault;
 RangeLo=RangeLoDefault;
 GlobalVariableSet(RangeHiName,RangeHiDefault);
 GlobalVariableSet(RangeLoName,RangeLoDefault);
 LongTrigger=false;
 ShortTrigger=false;
 GlobalVariableSet(LongTriggerName,LongTrigger);   
 GlobalVariableSet(ShortTriggerName,ShortTrigger); 
 return;
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
void ExitOrder(bool flag_Long,bool flag_Short)
{
 if(OrderType()==OP_BUY&&flag_Long)
  CloseOrderLong(OrderTicket(),OrderLots(),Slippage,Lime);
 else if(OrderType()==OP_SELL&&flag_Short)
  CloseOrderShort(OrderTicket(),OrderLots(),Slippage,Lime);
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
 if(take<0) return(0.0);

 return(NormDigits(price+NormPoints(take))); 
}
//+------------------------------------------------------------------+
double TakeShort(double price,int take)  // function to calculate takeprofit if short
{
 if(take<0) return(0.0); // if no take profit
 return(NormDigits(price-NormPoints(take))); 
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
double DetermineLots(double value1, double value2, double number)  // function to determine lot sizes based on account balance
{
 if(FixedLots) return(FixedLottage);
 if(value1<=0||value2<=0) return(lotsmin);
 
 double permitLoss=PercentRisk*AccountBalance();
 double pipSL=(value1-value2)/Point;
 double valueSL=pipSL*MarketInfo(Symbol(),MODE_TICKVALUE);
 
 double lots=permitLoss/valueSL;
 lots/=number;
 
 if(lots<lotsmin) return(lotsmin);
 else if(lots>lotsmax) return(lotsmax);
 
 return(lots);
}
//+------------------------------------------------------------------+
void FixedStopsB(int PP,int PFS)
{
 double stopcrnt,stopcal;
 double profit=DetermineProfit(),profitpoint;

 stopcrnt=OrderStopLoss();
 profitpoint=NormPoints(PP);  

//Long               

 if(OrderType()==OP_BUY)
 {
  if(profit>=profitpoint || FSFlag)
  {
   FSFlag=true;
   GlobalVariableSet(FSFlagName,FSFlag);     
   stopcal=TakeLong(OrderOpenPrice(),PFS);
   if(Bid<=stopcal) 
   {
    ExitOrder(true,false);
    etime=TimeCurrent();   
    GlobalVariableSet(ExitTimeName,etime);
    ResetParams(); 
   } 
  }
 }    
//Short 
 if(OrderType()==OP_SELL)
  {  
  if(profit>=profitpoint || FSFlag)
  {
   FSFlag=true;   
   GlobalVariableSet(FSFlagName,FSFlag);       
   stopcal=TakeShort(OrderOpenPrice(),PFS);
   if(Ask>=stopcal) 
   {
    ExitOrder(false,true);
    etime=TimeCurrent();   
    GlobalVariableSet(ExitTimeName,etime);
    ResetParams(); 
   } 
  }
 } 
 return(0);
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
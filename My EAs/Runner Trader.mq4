//+----------------------------------------------------------------------+
//|                                                    Runner Trader.mq4 |
//|                                                         David J. Lin |
//|Avi Frister's Forex Runner trading method                             |
//|Written for Jason Hughes <Jasonhughes3@aol.com>                       |
//|                                                                      |
//|Coded by David J. Lin (dave.j.lin@sbcglobal.net)                      |
//|Evanston, IL, December 3, 2007                                        |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2007, Jason Hughes & David J. Lin"
#property link      ""

// User adjustable parameters:
extern int TriggerPips=30;           // directional pip move at which to enter trade
extern int TakeProfit=40;            // pips desired TP
extern int StopLoss=20;              // pips desired SL
extern int SLProfit1=10;             // pips profit after which to move SL (uses SLMove1) (use negative number if not desired)
extern int SLMove1=-10;              // pips to move SL to BE+SLMove1 after SLProfit1 is reached
extern int SLProfit2=6;              // hours after which to move stops to break-even (uses SLMove2) (use negative number if not desired)
extern int SLMove2=0;                // pips to move SL to BE+SLMove2 after SLProfit2 hours have elapsed
extern int ResetOrders=4;            // hours after which to reset orders (allow both new longs & shorts)
extern bool FixedLots=true;          // true = use fixed number of lottage as specified by FixedLottage, false = use PercentRisk
extern double FixedLottage =0.01;    // fixed number of lots per trade (used if FixedLots=true)
extern double PercentRisk =0.010;    // percentage of account balance at risk per trade (used if FixedLots=false)
extern int ResetHour=7;              // GMT hour at which to automatically re-set the EA (if no open orders exist in the market)
extern int MaxNumberOrdersDaily=1;   // maximum number of orders permitted in a day (reset at ResetHour)

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

// Internal usage parameters:
int Slippage=3,bo=1,magic=432103;
int lotsprecision=2;
double lotsmin,lotsmax;
bool Order,LongOrder,ShortOrder,FSFlag[2];
string comment="Runner";
color clrL=Blue,clrS=Red;
string strL="Long",strS="Short";
int code=1,NDaily,lastday;
datetime ot,lasttime,etime,hightime,lowtime;
bool noRun=false,DailyFlag=false;
double P[3];
double TriggerPoints;
string BidName,HighName,LowName,ExitTimeName,LongOrderName,ShortOrderName,FSFlag1Name,FSFlag2Name,HighTimeName,LowTimeName;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//----
 lotsmin=MarketInfo(Symbol(),MODE_MINLOT); 
 lotsmax=MarketInfo(Symbol(),MODE_MAXLOT);

 if(lotsmin==0.10) lotsprecision=1;

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

 BidName=StringConcatenate("RUNNER_",Symbol(),"_Bid");
 HighName=StringConcatenate("RUNNER_",Symbol(),"_High");
 LowName=StringConcatenate("RUNNER_",Symbol(),"_Low"); 
 ExitTimeName=StringConcatenate("RUNNER_",Symbol(),"_ExitTime");  
 HighTimeName=StringConcatenate("RUNNER_",Symbol(),"_HighTime"); 
 LowTimeName=StringConcatenate("RUNNER_",Symbol(),"_LowTime");   
 LongOrderName=StringConcatenate("RUNNER_",Symbol(),"_LOrder");
 ShortOrderName=StringConcatenate("RUNNER_",Symbol(),"_SOrder"); 
 FSFlag1Name=StringConcatenate("RUNNER_",Symbol(),"_FSFlag1"); 
 FSFlag2Name=StringConcatenate("RUNNER_",Symbol(),"_FSFlag2"); 
 
 if(!GlobalVariableCheck(BidName)) GlobalVariableSet(BidName,0);
 if(!GlobalVariableCheck(HighName)) GlobalVariableSet(HighName,0);
 if(!GlobalVariableCheck(LowName)) GlobalVariableSet(LowName,0); 
 if(!GlobalVariableCheck(ExitTimeName)) GlobalVariableSet(ExitTimeName,etime);
 if(!GlobalVariableCheck(HighTimeName)) GlobalVariableSet(HighTimeName,hightime);
 if(!GlobalVariableCheck(LowTimeName)) GlobalVariableSet(LowTimeName,lowtime);  
 if(!GlobalVariableCheck(LongOrderName)) GlobalVariableSet(LongOrderName,1);
 if(!GlobalVariableCheck(ShortOrderName)) GlobalVariableSet(ShortOrderName,1);
 if(!GlobalVariableCheck(FSFlag1Name)) GlobalVariableSet(FSFlag1Name,0);
 if(!GlobalVariableCheck(FSFlag2Name)) GlobalVariableSet(FSFlag2Name,0); 
   
 P[0]=GlobalVariableGet(BidName);
 P[1]=GlobalVariableGet(HighName);
 P[2]=GlobalVariableGet(LowName); 
 etime=GlobalVariableGet(ExitTimeName);
 hightime=GlobalVariableGet(HighTimeName);
 lowtime=GlobalVariableGet(LowTimeName);  
 LongOrder=GlobalVariableGet(LongOrderName);
 ShortOrder=GlobalVariableGet(ShortOrderName); 
 FSFlag[0]=GlobalVariableGet(FSFlag1Name); 
 FSFlag[1]=GlobalVariableGet(FSFlag2Name);    

 if(P[0]==0&&P[1]==0&&P[2]==0) ResetPrices(); // if initializing

 ManageOrders();
 TriggerPoints=NormPoints(TriggerPips);
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
 DailyResetPrices();
 UpdatePrices();
 SubmitOrders();  
 ManageOrders();
 
 if(lastday==iTime(NULL,PERIOD_D1,0)) return(0);
 lastday=iTime(NULL,PERIOD_D1,0);
 DailyFlag=false;
//----
 return(0);
}
//+------------------------------------------------------------------+
//| expert utility functions                                         |
//+------------------------------------------------------------------+
void DailyResetPrices()
{
 if(!Order) return;
 if(Hour()!=ResetHour) return;
 if(DailyFlag) return;
 
 ResetPrices();       // reset prices 
 etime=TimeCurrent(); // reset exit times
 RecordGVs(0);
 NDaily=0;            // reset number of order count
 DailyFlag=true;      // toggle daily flag
 
 return;
}
//+------------------------------------------------------------------+
void ResetPrices()
{
 P[0]=Bid;
 P[1]=P[0];
 P[2]=P[0];
 hightime=TimeCurrent();
 lowtime=TimeCurrent();
 RecordGVs(1);
 return;
}
//+------------------------------------------------------------------+
void UpdatePrices()
{ 
 if(Bid>P[1]) 
 {
  P[1]=Bid;
  hightime=TimeCurrent();  
 }
 if(Bid<P[2]) 
 {
  P[2]=Bid;
  lowtime=TimeCurrent();    
 }
 
 P[0]=Bid;
            
 RecordGVs(1);
 
 int checktime=iBarShift(NULL,PERIOD_H1,etime,false);
 if(checktime>=ResetOrders)
 {
  LongOrder=true;
  ShortOrder=true;
  RecordGVs(2);
 }    
 return;
}
//+------------------------------------------------------------------+
void RecordGVs(int flag)
{
 switch(flag)
 {
  case 0:
   GlobalVariableSet(ExitTimeName,etime);
  break; 
  case 1:
   GlobalVariableSet(BidName,P[0]);
   GlobalVariableSet(HighName,P[1]);
   GlobalVariableSet(LowName,P[2]);
   GlobalVariableSet(HighTimeName,hightime);
   GlobalVariableSet(LowTimeName,lowtime);
   break;
  case 2:
   GlobalVariableSet(LongOrderName,LongOrder);
   GlobalVariableSet(ShortOrderName,ShortOrder);
  break;
  case 3:
   GlobalVariableSet(FSFlag1Name,FSFlag[0]);
   GlobalVariableSet(FSFlag2Name,FSFlag[1]);   
  break;
 }
 return; 
}
//+------------------------------------------------------------------+
void SubmitOrders()
{    
 if(!Order) return;
 if(NDaily>=MaxNumberOrdersDaily) return;
 double lots,SL,TP,target; 
 
// int i,checktime=iBarShift(NULL,0,ot,false);
// if(checktime<bo) return;

 if(LongOrder)
 {
  target=NormDigits(P[0]-P[2]-TriggerPoints);
  if(target==0)  
  {
   if(TimeFilter())
   {  
    SL=StopLong(Ask,StopLoss);
    lots=DetermineLots(Ask,SL,1);   
//  TP=TakeLong(Ask,TakeProfit);
    SendOrderLong(Symbol(),lots,Slippage,0,0,comment,magic,0,Blue);
    ot=TimeCurrent();
    FSFlag[0]=false;
    FSFlag[1]=false;
    RecordGVs(3);   
    DrawLines(1);
    ResetPrices(); 
    NDaily++;
   }
  }
 } 

 if(ShortOrder)
 {
  target=NormDigits(P[1]-P[0]-TriggerPoints);
  if(target==0)  
  {  
   if(TimeFilter())
   {  
    SL=StopShort(Bid,StopLoss);
    lots=DetermineLots(SL,Bid,1); 
//  TP=TakeShort(Bid,TakeProfit);
    SendOrderShort(Symbol(),lots,Slippage,0,0,comment,magic,0,Red);  
    ot=TimeCurrent();
    FSFlag[0]=false;
    FSFlag[1]=false;
    RecordGVs(3);  
    DrawLines(2);     
    ResetPrices();  
    NDaily++;
   }
  }
 }
 
 return;
}

//+------------------------------------------------------------------+

void ManageOrders()
{
 Order=true;

 double profit=0;
 int i,j,trail,trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;
  if(OrderMagicNumber()!=magic) continue;

  if(OrderType()==OP_BUY)
  {
   Order=ManagePrimary();
  }
  else if(OrderType()==OP_SELL)
  {
   Order=ManagePrimary();
  }
  
  if(!Order)
  {
   if(SLProfit1>0) 
   {
    FixedStopsB(SLProfit1,SLMove1,0);
   }
   if(SLProfit2>0) 
   {
    int checktime=iBarShift(NULL,PERIOD_H1,OrderOpenTime(),false);
    if(checktime>=SLProfit2) 
     FixedStopsB(0,SLMove2,1);
   }
  }  
 } 
 return;
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
bool ManagePrimary()
{
 double SL,TP,lots,target,profit=DetermineProfit();
 if(OrderType()==OP_BUY)
 {
  if(profit>=NormPoints(TakeProfit))
  {
   ExitOrder(true,false);
   etime=TimeCurrent();  
   RecordGVs(0);      
   ResetPrices();  
   LongOrder=false;
   ShortOrder=true;
   RecordGVs(2); 
   return(true);
  }
  else if(profit<=-NormPoints(StopLoss)) 
  {
   ExitOrder(true,false);
   etime=TimeCurrent();
   RecordGVs(0);      
   ResetPrices(); 
   LongOrder=true;
   ShortOrder=true;  
   RecordGVs(2);      
   return(true);   
  }

  target=NormDigits(P[1]-P[0]-TriggerPoints);
  if(target==0)  
  {  
   ExitOrder(true,false);
   SL=StopShort(Bid,StopLoss);
   lots=DetermineLots(SL,Bid,1); 
//  TP=TakeShort(Bid,TakeProfit);
   SendOrderShort(Symbol(),lots,Slippage,0,0,comment,magic,0,Red);  
   ot=TimeCurrent();
   FSFlag[0]=false;
   FSFlag[1]=false;
   RecordGVs(3);   
   DrawLines(2);   
   ResetPrices();  
  }
  
 }
 else if(OrderType()==OP_SELL)
 {
  if(profit>=NormPoints(TakeProfit))
  {
   ExitOrder(false,true);
   etime=TimeCurrent(); 
   RecordGVs(0);          
   ResetPrices();
   LongOrder=true;
   ShortOrder=false;  
   RecordGVs(2);    
   return(true);   
  } 
  else if(profit<=-NormPoints(StopLoss)) 
  {
   ExitOrder(false,true);
   etime=TimeCurrent(); 
   RecordGVs(0);       
   ResetPrices();
   LongOrder=true;
   ShortOrder=true;  
   RecordGVs(2);    
   return(true); 
  }   
  
  target=NormDigits(P[0]-P[2]-TriggerPoints);
  if(target==0)  
  {
   ExitOrder(false,true);
   SL=StopLong(Ask,StopLoss);
   lots=DetermineLots(Ask,SL,1);   
//  TP=TakeLong(Ask,TakeProfit);
   SendOrderLong(Symbol(),lots,Slippage,0,0,comment,magic,0,Blue);
   ot=TimeCurrent();
   FSFlag[0]=false;
   FSFlag[1]=false;
   RecordGVs(3);   
   DrawLines(1);   
   ResetPrices();
  }
  
 }
 return(false);
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
void FixedStopsB(int PP,int PFS,int set)
{
 double stopcrnt,stopcal;
 double profit=DetermineProfit(),profitpoint;

 stopcrnt=OrderStopLoss();
 profitpoint=NormPoints(PP);  

//Long               

 if(OrderType()==OP_BUY)
 {
  if(profit>=profitpoint || FSFlag[set])
  {
   FSFlag[set]=true; 
   RecordGVs(3);   
   stopcal=TakeLong(OrderOpenPrice(),PFS);
   if(Bid<=stopcal) 
   {
    ExitOrder(true,false);
    etime=TimeCurrent(); 
    RecordGVs(0);     
    LongOrder=true;
    ShortOrder=true;
    RecordGVs(2);      
    ResetPrices();    
   } 
  }
 }    
//Short 
 if(OrderType()==OP_SELL)
  {  
  if(profit>=profitpoint || FSFlag[set])
  {
   FSFlag[set]=true;   
   RecordGVs(3);    
   stopcal=TakeShort(OrderOpenPrice(),PFS);
   if(Ask>=stopcal) 
   {
    ExitOrder(false,true);
    etime=TimeCurrent(); 
    RecordGVs(0);     
    LongOrder=true;
    ShortOrder=true;
    RecordGVs(2);     
    ResetPrices();
   } 
  }
 } 
 return(0);
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
void Status(int mn)
{   
 if(mn==magic) ot=OrderOpenTime();
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
void DrawLines(int flag)
{
 datetime time=iTime(NULL,0,1);
 string name= StringConcatenate("Runner",TimeYear(time),".",TimeMonth(time),".",TimeDay(time),".",TimeHour(time),".",TimeMinute(time));
 switch(flag)
 {
  case 1:
   if (!ObjectCreate(name,OBJ_TREND,0,lowtime,P[2],time,Bid,0,0))
   {
    Print("MT4 error: cannot draw the line. Error ",GetLastError());
   }
   else
   {
    ObjectSet(name,OBJPROP_COLOR,Blue);
    ObjectSet(name,OBJPROP_RAY,0);    
    ObjectSet(name,OBJPROP_STYLE,STYLE_DASH);
   }  
  break;
  case 2:
   if (!ObjectCreate(name,OBJ_TREND,0,hightime,P[1],time,Bid,0,0))
   {
    Print("MT4 error: cannot draw the line. Error ",GetLastError());
   }
   else
   {
    ObjectSet(name,OBJPROP_COLOR,Red);
    ObjectSet(name,OBJPROP_RAY,0);
    ObjectSet(name,OBJPROP_STYLE,STYLE_DASH);
   }    
  break;
 }
 return;
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


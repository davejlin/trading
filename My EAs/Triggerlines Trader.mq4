//+----------------------------------------------------------------------+
//|                                              Triggerlines Trader.mq4 |
//|                                                         David J. Lin |
//|Based on Triggerline indicator
//|Written for Leo Lepore (forexleo@yahoo.com)                           |
//|                                                                      |
//|Coded by David J. Lin (dave.j.lin@sbcglobal.net)                      |                                      |
//|Evanston, IL, September 12, 2007                                      |
//+----------------------------------------------------------------------+
#property copyright "Copyright © 2007, David J. Lin"
#property link      ""

// User adjustable parameters:

extern double Lots=1.0;             // lottage per trade

extern int TakeProfit=-1;           // pips desired TP 
extern int StopLoss=-1;             // pips desired SL beyond highest high/lowest low in past 3 bars 

                              // Move Stops:  after reaching BE+SLProfit, move SL to BE+SLMove
extern int SLProfit=25;             // pips profit after which to move SL (use negative number if not desired)
extern int SLMove=1;                // pips to move SL to BE+SLMove after SLProfit is reached

                              // Trail: for every additional TrailProfit of profit above SLMove, lock in an additional TrailMove of profit
extern int TrailProfit=10;           // pips desired trailing profit above SLProfit, engages after SLProfit is hit (use negative number if not desired)
extern int TrailMove=5;             // pips desired trailing stop added onto previous stop, engages after SLProfit is hit

extern int TriggerLinesR = 24;       // Triggerlines Rperiod (enter negative value to turn off ADX filter)
extern int TriggerLinesLSMA = 6;     // Triggerlines LSMA period

extern int ADXPeriod=-1;             // period for ADX (enter negative value to turn off ADX filter)
extern double ADXLimit=-1;           // ADX value above which to allow triggers

extern double PSARStep=-1;          // PSAR1 step (enter negative value to turn off PSAR 1 filter)
extern double PSARMax=-1;          // PSAR1 max 

// ADX parameter settins
int ADXPrice=PRICE_CLOSE;

// Internal usage parameters:
int Slippage=3,bo=1;
int lotsprecision=2;

color clrL=Blue,clrS=Red;
string strL="Long",strS="Short";
int code=1;

double lotsmin,lotsmax;
bool LongExit,ShortExit;
bool LongTrigger,ShortTrigger;
int ot,NordersL,NordersS,MaxOrders=1;
string comment;
int magic;
datetime lasttime;
int window=2;
bool fTL[3,3]; // 1st element should be size window+1
int TF[3];
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//----
 lotsmin=MarketInfo(Symbol(),MODE_MINLOT); 
 lotsmax=MarketInfo(Symbol(),MODE_MAXLOT);
 if(lotsmin==0.10) lotsprecision=1;
 
 magic=300000+Period();  
 
 string pd;
 switch(Period())
 {
  case 1:     pd="M1"; TF[0]=PERIOD_M1;TF[1]=PERIOD_M5;TF[2]=PERIOD_M15;break;
  case 5:     pd="M5"; TF[0]=PERIOD_M5;TF[1]=PERIOD_M15;TF[2]=PERIOD_M30;break;
  case 15:    pd="M15";TF[0]=PERIOD_M15;TF[1]=PERIOD_M30;TF[2]=PERIOD_H1;break;
  case 30:    pd="M30";TF[0]=PERIOD_M30;TF[1]=PERIOD_H1;TF[2]=PERIOD_H4;break;
  case 60:    pd="H1"; TF[0]=PERIOD_H1;TF[1]=PERIOD_H4;TF[2]=PERIOD_D1;break;
  case 240:   pd="H4"; TF[0]=PERIOD_H4;TF[1]=PERIOD_D1;TF[2]=PERIOD_W1;break;
  case 1440:  pd="D1"; TF[0]=PERIOD_D1;TF[1]=PERIOD_W1;TF[2]=PERIOD_MN1;break;
  case 10080: pd="W1"; TF[0]=PERIOD_W1;TF[1]=PERIOD_MN1;TF[2]=PERIOD_MN1;break;
  case 40320: pd="M1"; TF[0]=PERIOD_MN1;TF[1]=PERIOD_MN1;TF[2]=PERIOD_MN1;break;
  default:    pd="Unknown";break;
 }
 comment  =StringConcatenate(pd," Triggerlines");
 
// First check closed trades
 int trade;                         
 int trades=OrdersHistoryTotal();           
 for(trade=0;trade<trades;trade++)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_HISTORY);

  if(OrderSymbol()!=Symbol())
   continue;

  int D1bars=iBarShift(NULL,PERIOD_D1,OrderCloseTime(),false);
  if(D1bars>10)
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
//----
 if(lasttime!=iTime(NULL,0,0))
 {
  Triggers();
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
 LongExit=false;ShortExit=false; 
 TriggerlineOrder();
 return;
}
//+------------------------------------------------------------------+
void TriggerlineOrder()
{      
 int i,shift,checktime=iBarShift(NULL,TF[2],ot,false);
 if(checktime<bo) return;

 double lots,SL,TP; 
  
 if(NordersL<MaxOrders)
 { 
  if(LongTrigger)
  {
   if(Filter(true))
   {
    lots=Lots; 
    SL=StopLong(Ask,StopLoss);
    TP=TakeLong(Ask,TakeProfit);
    SendOrderLong(Symbol(),lots,Slippage,SL,TP,comment,magic,0,Blue);
    ShortExit=true;
    ot=TimeCurrent();
    NordersL++;    
    return;
   }
  }
 } 

 if(NordersS<MaxOrders)
 { 
  if(ShortTrigger)
  { 
   if(Filter(false))
   {      
    lots=Lots;
    SL=StopShort(Bid,StopLoss);
    TP=TakeShort(Bid,TakeProfit);
    SendOrderShort(Symbol(),lots,Slippage,SL,TP,comment,magic,0,Red);  
    LongExit=true;         
    ot=TimeCurrent();
    NordersS++;    
    return;
   }
  }
 }
 return;
}
//+------------------------------------------------------------------+
void Triggers()
{
 LongTrigger=false;  ShortTrigger=false;

 TriggerLines();
 
 for(int i = window; i >= 1; i--)
 {
 
  if(fTL[i,2]==false && fTL[i-1,2]==true)
  {
   if(fTL[i-1,0]==true && fTL[i-1,1]==true) 
   {
    if(iTime(NULL,TF[2],i-1)>ot) LongTrigger=true;
   }
  }

  if(fTL[i,2]==true && fTL[i-1,2]==false)
  {
   if(fTL[i-1,0]==false && fTL[i-1,1]==false) 
   {
    if(iTime(NULL,TF[2],i-1)>ot) ShortTrigger=true;
   }
  }  
  
 }   
 return;
}
//+------------------------------------------------------------------+
bool Filter(bool long)
{
 int Trigger[2], totN=2, i,j;
 double value1;
 
 for(i=0;i<totN;i++) Trigger[i]=-1;

 if(long) // long filters
 {
  for(i=0;i<totN;i++)
  {
   switch(i)
   {  
    case 0:
     if(ADXPeriod>0)
     {
      value1=iADX(NULL,0,ADXPeriod,ADXPrice,MODE_MAIN,0);
      if(value1>=ADXLimit) Trigger[i]=1;
     }
     else Trigger[i]=1;     
     break; 
    case 1:
     if(PSARStep>0)
     {
      value1=iSAR(NULL,0,PSARStep,PSARMax,0);
      if(Bid>value1) Trigger[i]=1;
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
     if(ADXPeriod>0)
     {    
      value1=iADX(NULL,0,ADXPeriod,ADXPrice,MODE_MAIN,0);
      if(value1>=ADXLimit) Trigger[i]=1;
     }
     else Trigger[i]=1;     
     break; 
    case 1:
     if(PSARStep>0)
     {
      value1=iSAR(NULL,0,PSARStep,PSARMax,0);
      if(Bid<value1) Trigger[i]=1;
     }
     else Trigger[i]=1;
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
void ManageOrders()
{
 NordersL=0;NordersS=0;
 double profit=0;
 int i,mn,trail,trade,trades=OrdersTotal(); 
 for(trade=trades-1;trade>=0;trade--)
 {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
  if(OrderSymbol()!=Symbol()) continue;

  mn=OrderMagicNumber();
  if(mn==magic)
  {
   if(OrderType()==OP_BUY)
   {
    NordersL++; 
    if(LongExit) 
    {
//     profit=DetermineProfit();    
//     if(profit>0)
     {
      ExitOrder(true,false);    
      NordersL--;
     }       
    }
   }
   else if(OrderType()==OP_SELL)
   {
    NordersS++;
    if(ShortExit) 
    {
//     profit=DetermineProfit();    
//     if(profit>0)
     {
      ExitOrder(false,true);   
      NordersS--;
     }
    }     
   }
  
   if(SLProfit>0) 
   {
    profit=DetermineProfit();
    if(profit>=NormPoints(SLProfit))
    {   
     if(TrailProfit>0) QuantumTrailingStop(TrailProfit,TrailMove);    
     FixedStopsB(SLProfit,SLMove);
    }
   }
  } 
 }
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
   for(int z=0;z<10;z++)
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
   for(int z=0;z<10;z++)
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
double StopLong(double price,int stop)
{
 if(stop<=0) return(0.0);
 return(price-NormPoints(stop));
}
//+------------------------------------------------------------------+
double StopShort(double price,int stop) 
{
 if(stop<=0) return(0.0);
 return(price+NormPoints(stop));
}
//+------------------------------------------------------------------+
double TakeLong(double price,int take)  
{
 if(take<=0) return(0.0);
 return(price+NormPoints(take));
}
//+------------------------------------------------------------------+
double TakeShort(double price,int take) 
{
 if(take<=0) return(0.0);
 return(price-NormPoints(take)); 
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
  profitpips+=(SLProfit-SLMove)+TP;

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
  profitpips+=(SLProfit-SLMove)+TP;

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
  return(NormDigits(Bid-OrderOpenPrice()));
 } 
 else if(OrderType()==OP_SELL)
 { 
  return(NormDigits(OrderOpenPrice()-Ask)); 
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
void TriggerLines()
{ 
 int i,j,k;
 int var_124 = TriggerLinesR;
 int var_128 = TriggerLinesLSMA;
 double var_132,var_140,arr_160,arr_168;
 double arr_156[4]; // window+2
 
 for(k=0;k<3;k++)
 {
  for (i = window+1; i >= 0; i--)
  {
   arr_160 = 0;
   for (j = var_124; j >= 1; j--)
   {
    var_132 = var_124 + 1;
    var_132 = var_132 / 3.0;
    var_140 = 0;
    var_140 = (j - var_132) * iOpen(NULL,TF[k],(var_124 - j) + i);
    arr_160 += var_140;
   }
   arr_156[i] = arr_160 * 6.0 / (var_124 * (var_124 + 1));
  }
 
  for(i = window; i >= 0; i--)
  {
   arr_168 = arr_156[i+1] + ((arr_156[i] - arr_156[i+1]) * 2) / (var_128 + 1);

   if (arr_156[i] < arr_168) fTL[i,k]=false; // red ... short 
   else fTL[i,k]=true; // blue ... long
  }
 }
 
 return;
}